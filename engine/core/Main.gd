# Main.gd
# 主入口 - 负责初始化和协调各个服务
extends Node2D

# 服务引用（通过 ServiceLocator 获取）
var model_service: Node
var animation_service: Node
var eye_tracking_service: Node
var config_service: Node
var window_service: Node  # C# WindowService
var mouse_detection_service: Node  # C# MouseDetectionService

# 节点引用
var sub_viewport: SubViewport = null  # Live2D 渲染的 SubViewport

# 窗口拖拽相关
var drag_offset: Vector2 = Vector2.ZERO
var is_dragging: bool = false

func _ready():
	# 添加到组（供其他节点查找）
	add_to_group("main_scene")
	add_to_group("main")

	# 获取 SubViewport 节点引用
	sub_viewport = get_node_or_null("Sprite2D/SubViewport")
	if not sub_viewport:
		EngineConstants.log_error("[Main] 无法找到 SubViewport 节点")

	# 窗口穿透由 MouseDetectionService 自动控制
	EngineConstants.log_info("[Main] MouseDetectionService 将自动控制窗口穿透")

	# 初始化服务
	EngineConstants.log_info("开始初始化服务...")
	_init_services()

	# 加载配置
	EngineConstants.log_info("加载配置...")
	await config_service.load_config()

	# 加载默认模型
	EngineConstants.log_info("加载默认模型...")
	await model_service.load_default_model()

	EngineConstants.log_info("初始化完成！")

# 初始化服务
func _init_services():
	# 创建服务实例
	model_service = preload("res://renderer/services/Live2D/ModelService.gd").new()
	animation_service = preload("res://renderer/services/Live2D/AnimationService.gd").new()
	eye_tracking_service = preload("res://renderer/services/Live2D/EyeTrackingService.gd").new()
	config_service = preload("res://renderer/services/Config/ConfigService.gd").new()

	# 添加为子节点
	add_child(model_service)
	add_child(animation_service)
	add_child(eye_tracking_service)
	add_child(config_service)

	# 设置节点名称
	model_service.name = "ModelService"
	animation_service.name = "AnimationService"
	eye_tracking_service.name = "EyeTrackingService"
	config_service.name = "ConfigService"

	# 注册到服务定位器
	ServiceLocator.register("ModelService", model_service)
	ServiceLocator.register("AnimationService", animation_service)
	ServiceLocator.register("EyeTrackingService", eye_tracking_service)
	ServiceLocator.register("ConfigService", config_service)

	# 获取 WindowService（C# autoload）
	await get_tree().process_frame  # 等待一帧，确保 WindowService 初始化完成
	window_service = get_node_or_null("/root/WindowService")
	if window_service:
		EngineConstants.log_info("[Main] WindowService 已找到")
	else:
		EngineConstants.log_warning("[Main] WindowService 未找到")

	# 等待额外的帧以确保 MouseDetectionService 完全初始化
	await get_tree().process_frame
	await get_tree().process_frame

	# 获取 MouseDetectionService（由 WindowService 在 C# 中创建）
	mouse_detection_service = get_node_or_null("/root/WindowService/MouseDetectionService")
	if mouse_detection_service:
		EngineConstants.log_info("[Main] MouseDetectionService 已找到")
		EngineConstants.log_info(
			"[Main] MouseDetectionService 类型: %s" % mouse_detection_service.get_class()
		)
	else:
		EngineConstants.log_warning("[Main] MouseDetectionService 未找到")

	# 连接动画播放信号（动画切换时更新mask）
	if animation_service and animation_service.has_signal("animation_played"):
		animation_service.animation_played.connect(_on_animation_played)

	# 连接模型加载信号（模型加载完成后强制更新mask）
	if model_service and model_service.has_signal("model_loaded"):
		model_service.model_loaded.connect(_on_model_loaded)

	EngineConstants.log_info("所有服务已注册")

func _process(_delta):
	# 中键拖动窗口
	var middle_button_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)

	if middle_button_pressed and not is_dragging:
		# 开始拖动
		var mouse_global = Vector2(DisplayServer.mouse_get_position())
		var window_pos = Vector2(get_tree().root.position)
		drag_offset = mouse_global - window_pos
		is_dragging = true
		EngineConstants.log_debug("[Main] 开始拖动，偏移: %s" % drag_offset)

	elif not middle_button_pressed and is_dragging:
		# 结束拖动
		is_dragging = false
		EngineConstants.log_debug("[Main] 停止拖动")

	elif is_dragging:
		# 拖动中，更新窗口位置
		var mouse_global = Vector2(DisplayServer.mouse_get_position())
		var new_window_pos = mouse_global - drag_offset
		get_tree().root.position = Vector2i(new_window_pos)

func _input(event):
	# 快捷键
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			toggle_control_panel()
		elif event.keycode == KEY_F2:
			# 切换HitArea可视化
			var visualizer = get_node_or_null("Sprite2D/SubViewport/HitAreaVisualizerInner")
			if visualizer and visualizer.has_method("toggle_debug_mode"):
				visualizer.toggle_debug_mode()
			else:
				EngineConstants.log_warning("[Main] HitAreaVisualizerInner未找到或没有toggle方法")
		elif event.keycode == KEY_ESCAPE:
			close_control_panel()

	# 鼠标左键点击事件（触发动画）
	elif event is InputEventMouseButton and event.pressed:
		if (event.button_index == MOUSE_BUTTON_LEFT and
			mouse_detection_service and
			mouse_detection_service.has_method("is_position_clickable")):
			# 检测点击位置
			var is_on_character = mouse_detection_service.is_position_clickable(event.position)

			if is_on_character:
				# 点击在人物上，触发动画
				if animation_service:
					animation_service.play_random_animation()
					print("[Main] 点击人物，触发动画")

# ========== 对外接口（供控制面板调用） ==========

func toggle_control_panel():
	EngineConstants.log_info("切换控制面板 (未实现)")

func close_control_panel():
	EngineConstants.log_info("关闭控制面板 (未实现)")

func get_available_models() -> Array:
	if model_service:
		return model_service.get_available_models()
	return []

func get_current_model_index() -> int:
	if model_service:
		return model_service.get_current_model_index()
	return 0

func switch_model(index: int):
	if model_service:
		await model_service.switch_model(index)

func switch_model_lightweight(index: int):
	if model_service:
		await model_service.switch_model(index)

func apply_model_switch_only(index: int):
	if model_service:
		await model_service.load_model(index)

func clear_control_panel_reference():
	EngineConstants.log_info("清理控制面板引用 (未实现)")

# ========== 回调函数 ==========

func _on_animation_played(_anim_type: String, anim_name: String):
	EngineConstants.log_debug("[Main] 动画切换: %s" % anim_name)

func _on_model_loaded(model_name: String):
	EngineConstants.log_info("[Main] 模型加载完成: %s" % model_name)
