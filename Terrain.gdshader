shader_type spatial;

uniform sampler2D grass_texture;
uniform sampler2D rocks_texture;
uniform sampler2D sand_texture;

uniform float min_rock_slope:hint_range(0.f,1.f) = 0.5f;
uniform float max_grass_slope:hint_range(0.f,1.f) = 0.9f;
uniform float min_rockgrass_height = -8.f;
uniform float max_sand_height = -6.f;

varying float normal_y;
varying float vertex_y;

void vertex() {
	// Called for every vertex the material is visible on.
	normal_y = NORMAL.y;
	vertex_y = VERTEX.y;
}

void fragment() {
	// Called for every pixel the material is visible on.
	// Albedo Values
	vec3 grass_albedo = texture(grass_texture, UV*4.f).xyz;
	vec3 rocks_albedo = texture(rocks_texture, UV*4.f).xyz;
	vec3 sand_albedo = texture(sand_texture, UV*4.f).xyz;
	// Weights
	float rock_grass_weight = normal_y;
	float sand_rockgrass_weight = vertex_y;
	// Calculate Rock/Grass Weight
	rock_grass_weight = min(max_grass_slope, max(min_rock_slope, rock_grass_weight));
	rock_grass_weight -= min_rock_slope;
	rock_grass_weight /= max_grass_slope - min_rock_slope;
	// Calculate Rock/Grass Weight
	sand_rockgrass_weight = min(max_sand_height, max(min_rockgrass_height, sand_rockgrass_weight));
	sand_rockgrass_weight -= min_rockgrass_height;
	sand_rockgrass_weight /= max_sand_height - min_rockgrass_height;
	// Mix and Assign Albedo
	vec3 rockgrass_albedo = mix(rocks_albedo, grass_albedo, rock_grass_weight);
	ALBEDO = mix(sand_albedo, rockgrass_albedo, sand_rockgrass_weight);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
