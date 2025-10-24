# HitAreaVisualizerInner.gd
# Live2D HitArea 可视化工具
# 用途：在SubViewport内部渲染Live2D模型的HitArea和主要身体部位
# 特性：直接从GDCubism模型的mesh顶点数据提取包围盒，精确显示
# 快捷键：F2 切换显示/隐藏
#
# 使用方法：
#   1. 将此脚本作为Node2D添加到SubViewport中（与GDCubismUserModel同级）
#   2. 设置 model_node_path 指向 GDCubismUserModel 节点
#   3. 运行时按 F2 切换可视化

extends Node2D

# ========== 导出配置 ==========
@export var model_node_path: NodePath = NodePath("../GDCubismUserModel")  # 模型节点路径（相对路径）
@export var update_interval: float = 0.1  # 更新间隔（秒）
@export var show_on_start: bool = false  # 启动时是否显示
@export var show_only_hit_areas: bool = true  # 只显示官方HitArea
@export var show_body_parts: bool = false  # 额外显示主要身体部位（胸、腹、四肢、头）

# ========== 内部变量 ==========
var debug_mode: bool = false
var model_node: Node = null
var hit_areas: Array = []
var update_timer: float = 0.0

# ========== 样式配置 ==========
var border_color: Color = Color(1.0, 0.0, 0.0, 0.9)  # 红色边框
var fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)  # 透明填充
var text_color: Color = Color(1.0, 1.0, 1.0, 1.0)  # 白色文字
var border_width: float = 8.0  # 边框宽度（在SubViewport中会被缩放）

func _ready():
	z_index = 100  # 确保绘制在模型之上
	set_process_input(true)
	set_process_unhandled_input(true)

	# 等待场景树准备就绪
	await get_tree().process_frame
	await get_tree().process_frame

	# 获取模型节点
	model_node = get_node_or_null(model_node_path)
	if not model_node:
		EngineConstants.log_warning("[HitAreaVisualizerInner] 相对路径未找到模型，尝试绝对路径")
		# 尝试绝对路径
		var main_node = get_tree().root.get_node_or_null("Main")
		if main_node:
			model_node = main_node.get_node_or_null("Sprite2D/SubViewport/GDCubismUserModel")
			if model_node:
				model_node_path = NodePath("/root/Main/Sprite2D/SubViewport/GDCubismUserModel")

	if not model_node:
		EngineConstants.log_error("[HitAreaVisualizerInner] 无法找到模型节点，路径: %s" % str(model_node_path))

	debug_mode = show_on_start
	if debug_mode and model_node:
		_update_hit_areas()

func _input(event: InputEvent):
	# F2 切换调试模式
	if event is InputEventKey and event.keycode == KEY_F2 and event.pressed and not event.echo:
		debug_mode = !debug_mode
		if debug_mode:
			_update_hit_areas()
		queue_redraw()
		get_viewport().set_input_as_handled()

func _process(delta):
	if not debug_mode:
		return

	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		_update_hit_areas()
		queue_redraw()

func _update_hit_areas():
	"""从GDCubism模型的mesh顶点数据提取HitArea包围盒"""
	hit_areas.clear()

	if not model_node:
		EngineConstants.log_error("[HitAreaVisualizerInner] model_node为null")
		return

	if not model_node.has_method("get_meshes"):
		EngineConstants.log_error("[HitAreaVisualizerInner] model_node没有get_meshes方法")
		return

	var meshes = model_node.get_meshes()
	if not meshes:
		EngineConstants.log_error("[HitAreaVisualizerInner] get_meshes()返回null")
		return

	# 获取所有mesh的keys（兼容Dictionary和Array两种返回类型）
	var mesh_keys = []
	if typeof(meshes) == TYPE_DICTIONARY:
		mesh_keys = meshes.keys()
	elif typeof(meshes) == TYPE_ARRAY:
		for i in range(meshes.size()):
			mesh_keys.append(i)

	# 处理每个mesh
	for key in mesh_keys:
		var mesh_name = str(key)

		# 过滤：只显示HitArea或主要身体部位
		if show_only_hit_areas:
			var is_hit_area = mesh_name == "HitArea"
			var is_body_part = false

			if show_body_parts:
				# 主要身体部位的关键词（根据Live2D模型命名规则）
				var body_keywords = [
					"Body", "Chest", "Torso", "Head", "Face",
					"ArmL", "ArmR", "LegL", "LegR",
					"HandL", "HandR", "FootL", "FootR"
				]
				for keyword in body_keywords:
					if mesh_name.contains(keyword):
						is_body_part = true
						break

			if not is_hit_area and not is_body_part:
				continue  # 跳过非HitArea且非身体部位的mesh

		var mesh_item = meshes[key] if typeof(meshes) == TYPE_DICTIONARY else meshes[key]

		# 如果是MeshInstance2D，提取其.mesh属性
		if mesh_item is MeshInstance2D:
			mesh_item = mesh_item.mesh

		if not (mesh_item is ArrayMesh):
			continue

		var surface_count = mesh_item.get_surface_count()
		if surface_count == 0:
			continue

		var arrays = mesh_item.surface_get_arrays(0)
		if typeof(arrays) != TYPE_ARRAY or arrays.size() <= Mesh.ARRAY_VERTEX:
			continue

		var vertices = arrays[Mesh.ARRAY_VERTEX]
		if not vertices or vertices.size() == 0:
			continue

		# 在SubViewport的坐标系中计算包围盒
		var min_x = INF
		var min_y = INF
		var max_x = -INF
		var max_y = -INF

		for v in vertices:
			# 将模型本地坐标转换到SubViewport坐标系
			var world_pos = model_node.to_global(Vector2(v.x, v.y))
			min_x = min(min_x, world_pos.x)
			min_y = min(min_y, world_pos.y)
			max_x = max(max_x, world_pos.x)
			max_y = max(max_y, world_pos.y)

		if min_x != INF:
			var rect = Rect2(
				Vector2(min_x, min_y),
				Vector2(max_x - min_x, max_y - min_y)
			)
			hit_areas.append({"name": mesh_name, "rect": rect})

func _draw():
	"""在SubViewport内绘制HitArea"""
	if not debug_mode:
		return

	if hit_areas.size() == 0:
		return

	for area in hit_areas:
		var rect: Rect2 = area["rect"]

		# 绘制半透明填充
		if fill_color.a > 0:
			draw_rect(rect, fill_color)

		# 绘制边框
		draw_rect(rect, border_color, false, border_width)

		# 绘制区域名称
		var label_pos = rect.position + Vector2(10, -10)
		draw_string(ThemeDB.fallback_font, label_pos, area["name"],
					HORIZONTAL_ALIGNMENT_LEFT, -1, 32, text_color)

# ========== 公共接口 ==========

func toggle_debug_mode():
	"""切换调试模式（由Main.gd的F2按键调用）"""
	debug_mode = !debug_mode
	if debug_mode:
		# 重新获取模型节点（以防在_ready时还未加载）
		if not model_node:
			model_node = get_node_or_null(model_node_path)
			if not model_node:
				# 尝试绝对路径
				var main_node = get_tree().root.get_node_or_null("Main")
				if main_node:
					model_node = main_node.get_node_or_null("Sprite2D/SubViewport/GDCubismUserModel")

		_update_hit_areas()
	queue_redraw()

func set_debug_mode(enabled: bool):
	"""设置调试模式（编程式调用）"""
	debug_mode = enabled
	if debug_mode:
		_update_hit_areas()
	queue_redraw()

func is_debug_mode_enabled() -> bool:
	"""获取当前调试模式状态"""
	return debug_mode
