@tool
extends EditorScript

func _run():
	# 加载草坪模型
	var grass_scene := load("res://assets/models/tile/roadTile_036.gltf") as PackedScene
	if not grass_scene:
		print("无法加载草地模型！")
		return
	
	# 实例化获取 Mesh
	var temp := grass_scene.instantiate()
	var mesh_inst := temp.get_child(0) as MeshInstance3D
	if not mesh_inst:
		print("无法获取 Mesh！")
		temp.queue_free()
		return
	
	# 创建并填充 MeshLibrary
	var library := MeshLibrary.new()
	library.create_item(0)
	library.set_item_mesh(0, mesh_inst.mesh)
	library.set_item_name(0, "Grass")
	
	# 保存到文件
	var err := ResourceSaver.save(library, "res://assets/models/tile/grass_tileset.tres")
	if err == OK:
		print("MeshLibrary 创建成功！")
	else:
		print("保存失败：", err)
	
	temp.queue_free()
