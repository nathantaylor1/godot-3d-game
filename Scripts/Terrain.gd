@tool
extends StaticBody3D


@export var generate_mesh : bool = false : set = _gen_mesh


@export var mesh_size: int = 4
@export var amplitude: int = 16
@export var noise: FastNoiseLite = FastNoiseLite.new()


func _gen_mesh(__) -> void:
	print_debug("Generating Mesh...")
	# Create and resize plane mesh.
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(mesh_size, mesh_size)
	plane_mesh.subdivide_width = mesh_size - 1
	plane_mesh.subdivide_depth = mesh_size - 1
	
	# Get mesh vertices and add height via noise.
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var data = surface_tool.commit_to_arrays()
	var vertices = data[ArrayMesh.ARRAY_VERTEX]
	
	for i in vertices.size():
		var vertex = vertices[i]
		vertices[i].y = noise.get_noise_2d(vertex.x, vertex.z) * amplitude
	
	data[ArrayMesh.ARRAY_VERTEX] = vertices
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)
	
	surface_tool.create_from(array_mesh, 0)
	surface_tool.generate_normals()
	
	# Assign Mesh to MeshInstance3D
	$MeshInstance3D.mesh = surface_tool.commit()
	$CollisionShape3D.shape = array_mesh.create_trimesh_shape()
