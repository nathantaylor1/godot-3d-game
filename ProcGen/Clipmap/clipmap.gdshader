shader_type spatial;
// render_mode world_vertex_coords;

global uniform sampler2D heightmap;
global uniform float amplitude;
global uniform vec3 clipmap_position;
global uniform float clipmap_partition_length;
global uniform float lod_step;

varying vec2 normalmap_position;
varying vec3 vert;

float get_height(vec3 world_vertex) {
	vec2 heightmap_position = (world_vertex.xz + 0.5) / float(textureSize(heightmap, 0).x);
	return texture(heightmap, heightmap_position).r * amplitude;
}

vec3 get_normal(vec3 vertex, float adjacent_distance) {
	vec3 west_vert = vertex + vec3(adjacent_distance, 0, 0);
	west_vert.y = get_height(west_vert);
	vec3 north_vert = vertex + vec3(0, 0, adjacent_distance);
	north_vert.y = get_height(north_vert);
	return normalize(cross(north_vert - vertex, west_vert - vertex));
}

vec3 to_normalmap(vec3 n) {
	n *= vec3(1.0, 1.0, -1.0);
	n = n / 2.0 + 0.5;
	n = vec3(n.x, n.z, n.y);
	return n;
}

void vertex() {
	// Called for every vertex the material is visible on.
	vec3 world_vertex = VERTEX + MODEL_MATRIX[3].xyz;
	normalmap_position = (world_vertex.xz + vec2(0.5)) / float(textureSize(heightmap, 0).x);
	VERTEX.y = get_height(world_vertex);
	
	float lod = floor(
		max(
			abs(world_vertex.x - clipmap_position.x), 
			abs(world_vertex.z - clipmap_position.z)
		) / float(clipmap_partition_length) + 0.5
	) * lod_step;
	
	float subdivision_length = min(pow(2, lod), clipmap_partition_length);
	
	vec3 fraction = fract((VERTEX + clipmap_partition_length / 2.0) / subdivision_length);
	VERTEX.y = mix(
		mix(
			get_height(world_vertex - vec3(fraction.x * subdivision_length, 0, 0)), 
			get_height(world_vertex + vec3((1.0-fraction.x) * subdivision_length, 0, 0)), 
			fraction.x
		), 
		mix(
			get_height(world_vertex - vec3(0, 0, fraction.z * subdivision_length)), 
			get_height(world_vertex + vec3(0, 0, (1.0-fraction.z) * subdivision_length)), 
			fraction.z
		), 
		ceil(fraction.z)
	);
	
	// NORMAL = get_normal(VERTEX, float(subdivision_length));
	vert = world_vertex;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 interpolated_vert = vert;
	interpolated_vert.y = get_height(vert);
	vec3 normal = get_normal(interpolated_vert, 1.0);
	NORMAL_MAP = to_normalmap(normal);
}
