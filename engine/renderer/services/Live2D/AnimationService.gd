# AnimationService.gd
# 动画服务 - 负责Live2D动画和表情的播放管理
extends Node

# ========== 信号 ==========
signal animation_played(anim_type: String, anim_name: String)
signal animations_loaded(motions_count: int, expressions_count: int)

# ========== 状态变量 ==========
var available_motions: Dictionary = {}
var available_expressions: Array = []
var is_playing: bool = false
var auto_reset_timer: float = 0.0

# ========== 初始化 ==========
func _ready():
	# 监听模型加载信号
	var model_service = ServiceLocator.get_service("ModelService")
	if model_service:
		model_service.model_loaded.connect(_on_model_loaded)

func _process(delta: float):
	# 更新自动恢复计时器
	if is_playing:
		auto_reset_timer += delta
		if auto_reset_timer >= EngineConstants.AUTO_RESET_DURATION:
			reset_to_idle()

# 模型加载完成后重新加载动作
func _on_model_loaded(_model_name: String):
	await get_tree().create_timer(0.1).timeout  # 等待模型完全加载
	load_motions_and_expressions()

# ========== 加载动作和表情 ==========
func load_motions_and_expressions():
	var model_service = ServiceLocator.get_service("ModelService")
	if not model_service:
		EngineConstants.log_error("[AnimationService] ModelService 未找到")
		return
	
	var model = model_service.get_current_model()
	if not model:
		EngineConstants.log_error("[AnimationService] 模型未加载")
		return
	
	EngineConstants.log_info("[AnimationService] 加载动作和表情...")
	
	# 获取可用动作
	available_motions = model.get_motions()
	EngineConstants.log_info("[AnimationService] 动作组数量: %d" % available_motions.size())
	
	# 获取可用表情
	available_expressions = model.get_expressions()
	EngineConstants.log_info("[AnimationService] 表情数量: %d" % available_expressions.size())
	
	# 发送信号
	animations_loaded.emit(available_motions.size(), available_expressions.size())

# ========== 播放动画 ==========
func play_random_animation():
	var has_motions = not available_motions.is_empty()
	var has_expressions = not available_expressions.is_empty()
	
	if not has_motions and not has_expressions:
		EngineConstants.log_warning("[AnimationService] 没有可用的动画")
		return
	
	# 50% 概率选择动作或表情
	if has_motions and has_expressions:
		if randf() > 0.5:
			play_random_motion()
		else:
			play_random_expression()
	elif has_motions:
		play_random_motion()
	else:
		play_random_expression()

func play_random_motion():
	if available_motions.is_empty():
		return
	
	var model_service = ServiceLocator.get_service("ModelService")
	if not model_service:
		return
	
	var model = model_service.get_current_model()
	if not model:
		return
	
	# 随机选择动作组
	var groups = available_motions.keys()
	var random_group = groups[randi() % groups.size()]
	var motions_in_group = available_motions[random_group]
	
	# 获取随机动作编号
	var random_motion_no = _get_random_motion_number(motions_in_group)
	
	if random_motion_no < 0:
		return
	
	# 播放动作
	var success = model.start_motion(random_group, random_motion_no, EngineConstants.Priority.NORMAL)
	
	if success:
		model.anim_motion = random_group
		is_playing = true
		auto_reset_timer = 0.0
		animation_played.emit("motion", "%s_%d" % [random_group, random_motion_no])
	else:
		# 尝试强制播放
		model.start_motion(random_group, random_motion_no, EngineConstants.Priority.FORCE)
		model.anim_motion = random_group
		is_playing = true
		auto_reset_timer = 0.0

func play_random_expression():
	if available_expressions.is_empty():
		return
	
	var model_service = ServiceLocator.get_service("ModelService")
	if not model_service:
		return
	
	var model = model_service.get_current_model()
	if not model:
		return
	
	# 随机选择表情
	var random_expression = available_expressions[randi() % available_expressions.size()]
	
	# 播放表情
	model.start_expression(random_expression)
	
	is_playing = true
	auto_reset_timer = 0.0
	animation_played.emit("expression", random_expression)

# 播放指定动作
func play_motion(group: String, index: int, priority: int = EngineConstants.Priority.NORMAL) -> bool:
	var model_service = ServiceLocator.get_service("ModelService")
	if not model_service:
		return false
	
	var model = model_service.get_current_model()
	if not model:
		return false
	
	var success = model.start_motion(group, index, priority)
	
	if success:
		model.anim_motion = group
		is_playing = true
		auto_reset_timer = 0.0
		animation_played.emit("motion", "%s_%d" % [group, index])
	
	return success

# 播放指定表情
func play_expression(expression_name: String):
	var model_service = ServiceLocator.get_service("ModelService")
	if not model_service:
		return
	
	var model = model_service.get_current_model()
	if not model:
		return
	
	model.start_expression(expression_name)
	is_playing = true
	auto_reset_timer = 0.0
	animation_played.emit("expression", expression_name)

# ========== 控制函数 ==========
func reset_to_idle():
	var model_service = ServiceLocator.get_service("ModelService")
	if not model_service:
		return
	
	var model = model_service.get_current_model()
	if not model:
		return
	
	# 停止表情
	model.start_expression("")
	
	# 播放 Idle 动作
	if available_motions.has(EngineConstants.DEFAULT_IDLE_ANIMATION):
		var idle_motions = available_motions[EngineConstants.DEFAULT_IDLE_ANIMATION]
		var idle_index = _get_random_motion_number(idle_motions)
		
		if idle_index >= 0:
			model.start_motion(EngineConstants.DEFAULT_IDLE_ANIMATION, idle_index, EngineConstants.Priority.NORMAL)
			model.anim_motion = EngineConstants.DEFAULT_IDLE_ANIMATION
	else:
		model.anim_motion = ""
	
	is_playing = false
	auto_reset_timer = 0.0

func stop_all_animations():
	var model_service = ServiceLocator.get_service("ModelService")
	if not model_service:
		return
	
	var model = model_service.get_current_model()
	if not model:
		return
	
	model.start_expression("")
	model.anim_motion = ""
	
	is_playing = false
	auto_reset_timer = 0.0

# ========== 内部辅助函数 ==========
func _get_random_motion_number(motions_data) -> int:
	# 处理不同类型的动作数据
	if motions_data is Array:
		if motions_data.size() > 0:
			return motions_data[randi() % motions_data.size()]
		return 0
	elif motions_data is int:
		if motions_data > 0:
			return randi() % motions_data
		return 0
	elif motions_data is float:
		var int_value = int(motions_data)
		if int_value > 0:
			return randi() % int_value
		return 0
	elif motions_data is String:
		var int_value = motions_data.to_int()
		if int_value > 0:
			return randi() % int_value
		return 0
	
	return 0

