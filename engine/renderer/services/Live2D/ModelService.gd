# ModelService.gd
# 模型管理服务 - 负责Live2D模型的加载、切换和管理
extends Node

# ========== 信号 ==========
signal model_loaded(model_name: String)
signal model_switched(model_index: int)
signal models_scanned(models_count: int)

# ========== 状态变量 ==========
var available_models: Array[Dictionary] = []
var current_model_index: int = 0
var current_model: GDCubismUserModel = null

# ========== 初始化 ==========
func _ready():
	await get_tree().process_frame
	_find_model_node()
	scan_available_models()

# 查找 GDCubismUserModel 节点
func _find_model_node():
	# 尝试从根节点查找
	current_model = get_tree().root.get_node_or_null("Main/Sprite2D/SubViewport/GDCubismUserModel")
	
	if not current_model:
		# 备用查找方法
		var main_nodes = get_tree().get_nodes_in_group("main_scene")
		if main_nodes.size() > 0:
			current_model = main_nodes[0].get_node_or_null("Sprite2D/SubViewport/GDCubismUserModel")
	
	if current_model:
		EngineConstants.log_info("[ModelService] GDCubismUserModel 节点已找到")
	else:
		EngineConstants.log_error("[ModelService] 无法找到 GDCubismUserModel 节点")

# ========== 模型扫描 ==========
func scan_available_models():
	EngineConstants.log_info("[ModelService] 开始扫描可用模型...")
	available_models.clear()
	
	var dir = DirAccess.open(EngineConstants.MODEL_BASE_PATH)
	if not dir:
		EngineConstants.log_error("[ModelService] 无法打开模型目录: %s" % EngineConstants.MODEL_BASE_PATH)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir() and file_name not in [".", ".."]:
			var model_info = _scan_model_directory(file_name)
			if model_info:
				available_models.append(model_info)
				EngineConstants.log_info("[ModelService] 找到模型: %s" % file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	EngineConstants.log_info("[ModelService] 总共找到 %d 个模型" % available_models.size())
	models_scanned.emit(available_models.size())

# 扫描单个模型目录
func _scan_model_directory(folder_name: String) -> Dictionary:
	var model_path = EngineConstants.MODEL_BASE_PATH + folder_name + "/runtime/"
	
	# 尝试多种文件名格式
	var possible_files = [
		model_path + folder_name + ".model3.json",
		model_path + "mao_pro.model3.json",
		model_path + "hiyori_pro_t11.model3.json",
		model_path + folder_name.replace("_zh", "") + ".model3.json"
	]
	
	for model_file in possible_files:
		if FileAccess.file_exists(model_file):
			return {
				"name": folder_name,
				"path": model_file,
				"display_name": folder_name.replace("_", " ").capitalize()
			}
	
	return {}

# ========== 模型加载 ==========
func load_default_model():
	if available_models.size() > 0:
		await load_model(0)
	else:
		EngineConstants.log_warning("[ModelService] 没有可用模型")

func load_model(index: int):
	if index < 0 or index >= available_models.size():
		EngineConstants.log_error("[ModelService] 无效的模型索引: %d" % index)
		return
	
	if not current_model:
		EngineConstants.log_error("[ModelService] GDCubismUserModel 未初始化")
		return
	
	current_model_index = index
	var model_info = available_models[current_model_index]
	
	EngineConstants.log_info("[ModelService] 加载模型: %s" % model_info["name"])
	
	# 停止当前动画
	_stop_current_animation()
	
	# 设置模型资源
	current_model.assets = model_info["path"]
	
	# 等待模型加载
	await get_tree().create_timer(0.5).timeout
	
	# 发送信号
	model_loaded.emit(model_info["name"])

# ========== 模型切换 ==========
func switch_model(index: int):
	if index == current_model_index:
		EngineConstants.log_info("[ModelService] 已经是当前模型，跳过切换")
		return
	
	await load_model(index)
	model_switched.emit(index)

# 停止当前动画
func _stop_current_animation():
	if not current_model:
		return
	
	current_model.start_expression("")
	current_model.anim_motion = ""
	
	# 通知动画服务停止
	var animation_service = ServiceLocator.get_service("AnimationService")
	if animation_service and animation_service.has_method("stop_all_animations"):
		animation_service.stop_all_animations()

# ========== 对外接口 ==========
func get_available_models() -> Array:
	return available_models

func get_current_model_index() -> int:
	return current_model_index

func get_current_model_info() -> Dictionary:
	if current_model_index < available_models.size():
		return available_models[current_model_index]
	return {}

func get_next_model_index() -> int:
	if available_models.size() <= 1:
		return current_model_index
	return (current_model_index + 1) % available_models.size()

func get_previous_model_index() -> int:
	if available_models.size() <= 1:
		return current_model_index
	var prev_index = current_model_index - 1
	if prev_index < 0:
		prev_index = available_models.size() - 1
	return prev_index

# 获取当前模型对象（供其他服务使用）
func get_current_model() -> GDCubismUserModel:
	return current_model

