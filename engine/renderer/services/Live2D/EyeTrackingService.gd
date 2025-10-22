# EyeTrackingService.gd
# 眼动追踪服务 - 负责Live2D模型的眼动跟随鼠标
extends Node

# ========== 状态变量 ==========
var target_position: Vector2 = Vector2.ZERO
var current_position: Vector2 = Vector2.ZERO
var target_point_node: GDCubismEffectTargetPoint = null
var idle_timer: float = 0.0
var is_enabled: bool = true

# ========== 初始化 ==========
func _ready():
	# 监听模型加载信号
	var model_service = ServiceLocator.get_service("ModelService")
	if model_service:
		model_service.model_loaded.connect(_on_model_loaded)
	
	await get_tree().process_frame
	_find_target_point_node()

func _process(delta: float):
	if not is_enabled or not target_point_node:
		return
	
	# 更新空闲计时器
	idle_timer += delta
	
	# 使用全局鼠标位置，即使鼠标超出窗口也继续追踪
	var global_mouse_pos = Vector2(DisplayServer.mouse_get_position())
	var window_pos = Vector2(get_tree().root.position)
	var window_size = get_viewport().get_visible_rect().size
	
	# 转换为窗口内相对坐标
	var local_mouse_pos = global_mouse_pos - window_pos
	
	# 始终更新目标位置（即使鼠标超出窗口）
	update_target_global(local_mouse_pos, window_size)
	
	# 检查鼠标是否在窗口内，用于空闲检测
	var is_in_window = (local_mouse_pos.x >= 0 and local_mouse_pos.x <= window_size.x and 
						 local_mouse_pos.y >= 0 and local_mouse_pos.y <= window_size.y)
	
	# 如果鼠标在窗口内，重置空闲计时器
	if is_in_window:
		idle_timer = 0.0
	# 如果鼠标超出窗口且空闲时间过长，才归中
	elif idle_timer > EngineConstants.EYE_IDLE_THRESHOLD:
		target_position = target_position.lerp(Vector2.ZERO, 0.02)
	
	# 平滑更新当前位置
	current_position = current_position.lerp(target_position, EngineConstants.EYE_SMOOTH_FACTOR)
	
	# 应用到模型
	target_point_node.set_target(current_position)
	
	# 手动设置身体Y和Z轴参数（GDCubismEffectTargetPoint不支持）
	_update_body_parameters()

# 模型加载后重新查找节点
func _on_model_loaded(_model_name: String):
	await get_tree().process_frame
	_find_target_point_node()

# ========== 查找眼动追踪节点 ==========
func _find_target_point_node():
	var model_service = ServiceLocator.get_service("ModelService")
	if not model_service:
		return
	
	var model = model_service.get_current_model()
	if not model:
		return
	
	# 在模型子节点中查找 GDCubismEffectTargetPoint
	for child in model.get_children():
		if child is GDCubismEffectTargetPoint:
			target_point_node = child
			_configure_target_point()
			EngineConstants.log_info("[EyeTrackingService] 眼动追踪节点已找到")
			return
	
	EngineConstants.log_warning("[EyeTrackingService] 未找到眼动追踪节点")

# 配置眼动追踪节点
func _configure_target_point():
	if not target_point_node:
		return
	
	# 注意：GDCubismEffectTargetPoint 的所有参数在场景文件中配置
	# 包括：head_angle_x/y/z, body_angle_x, eyes_angle_x/y, 各种range值
	# 这些属性是只读的，不能在运行时修改
	
	# 设置初始位置
	target_point_node.set_target(Vector2.ZERO)
	
	EngineConstants.log_info("[EyeTrackingService] 眼动追踪已就绪")

# ========== 更新目标位置 ==========
# 全局鼠标追踪（支持超出窗口范围）
func update_target_global(local_mouse_pos: Vector2, window_size: Vector2):
	if not is_enabled:
		return
	
	# 转换为归一化坐标（允许超出-1到1的范围）
	var center = window_size * 0.5
	var relative = local_mouse_pos - center
	
	var normalized_pos = Vector2(
		relative.x / (center.x),
		-relative.y / (center.y)  # Y轴取反
	)
	
	# 限制范围（允许超出窗口一定范围）
	var max_range = 2.0  # 允许追踪到窗口外2倍距离
	target_position.x = clamp(normalized_pos.x, -max_range, max_range)
	target_position.y = clamp(normalized_pos.y, -max_range, max_range)

# 窗口内鼠标追踪（兼容旧接口）
func update_target(mouse_pos: Vector2):
	if not is_enabled:
		return
	
	# 转换为归一化坐标
	var screen_size = get_viewport().get_visible_rect().size
	var center = screen_size * 0.5
	var relative = mouse_pos - center
	
	var normalized_pos = Vector2(
		relative.x / (screen_size.x * 0.5),
		-relative.y / (screen_size.y * 0.5)  # Y轴取反
	)
	
	# 限制范围
	target_position.x = clamp(normalized_pos.x, -EngineConstants.EYE_MAX_DISTANCE, EngineConstants.EYE_MAX_DISTANCE)
	target_position.y = clamp(normalized_pos.y, -EngineConstants.EYE_MAX_DISTANCE, EngineConstants.EYE_MAX_DISTANCE)
	
	# 重置空闲计时器
	idle_timer = 0.0

# ========== 控制函数 ==========
func set_enabled(enabled: bool):
	is_enabled = enabled
	if not enabled and target_point_node:
		target_point_node.set_target(Vector2.ZERO)
		current_position = Vector2.ZERO
		target_position = Vector2.ZERO

func reset():
	target_position = Vector2.ZERO
	current_position = Vector2.ZERO
	idle_timer = 0.0
	if target_point_node:
		target_point_node.set_target(Vector2.ZERO)

# ========== 手动身体参数控制 ==========
# GDCubismEffectTargetPoint 只支持 BodyAngleX
# BodyAngleY 和 BodyAngleZ 需要手动设置
func _update_body_parameters():
	var model_service = ServiceLocator.get_service("ModelService")
	if not model_service:
		return
	
	var model = model_service.get_current_model()
	if not model:
		return
	
	# 获取模型参数
	var params = model.get_parameters()
	if not params:
		return
	
	# 查找并设置身体参数
	for param in params:
		var param_id = param.get_id()
		
		# BodyAngleY：身体上下转动（跟随target的Y值）
		if param_id == "ParamBodyAngleY":
			var value = current_position.y * 10.0  # 范围约 -10 到 +10 度
			param.set_value(value)
		
		# BodyAngleZ：身体倾斜（根据X和Y的组合）
		elif param_id == "ParamBodyAngleZ":
			var value = current_position.x * current_position.y * 5.0  # 范围约 -5 到 +5 度
			param.set_value(value)
