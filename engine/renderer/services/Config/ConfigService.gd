# ConfigService.gd
# 配置服务 - 负责配置的加载、保存和管理
extends Node

# ========== 信号 ==========
signal config_loaded(config: Dictionary)
signal config_saved(config: Dictionary)

# ========== 配置路径 ==========
var config_file_path = "user://engine_config.json"
var backup_config_path = "user://engine_config.json.backup"

# ========== 默认配置 ==========
var default_config = {
	"model_index": 0,
	"smaa": 0.10,
	"debanding": true,
	"mipmap": true,
	"zoom": 0.44,
	"resolution": 2048,
	"hdr": true,
	"lod": 0.6
}

# 当前配置
var current_config: Dictionary = {}

# ========== 加载配置 ==========
func load_config():
	EngineConstants.log_info("[ConfigService] 加载配置...")
	
	# 检查配置文件是否存在
	if not FileAccess.file_exists(config_file_path):
		EngineConstants.log_info("[ConfigService] 配置文件不存在，使用默认配置")
		await apply_config(default_config)
		return
	
	# 读取配置文件
	var file = FileAccess.open(config_file_path, FileAccess.READ)
	if not file:
		EngineConstants.log_error("[ConfigService] 无法打开配置文件，错误代码: %s" % FileAccess.get_open_error())
		await apply_config(default_config)
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	# 解析 JSON
	if json_string.strip_edges().is_empty():
		EngineConstants.log_warning("[ConfigService] 配置文件为空，使用默认配置")
		await apply_config(default_config)
		return
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		EngineConstants.log_error("[ConfigService] JSON 解析失败: %s" % json.get_error_message())
		await apply_config(default_config)
		return
	
	var config = json.data
	if not config is Dictionary:
		EngineConstants.log_error("[ConfigService] 配置格式错误")
		await apply_config(default_config)
		return
	
	# 验证并应用配置
	var validated_config = _validate_config(config)
	await apply_config(validated_config)

# ========== 应用配置 ==========
func apply_config(config: Dictionary):
	current_config = config.duplicate()
	
	# 应用模型设置
	if config.has("model_index"):
		var model_service = ServiceLocator.get_service("ModelService")
		if model_service:
			var model_index = config["model_index"]
			if model_index >= 0 and model_index < model_service.available_models.size():
				await model_service.load_model(model_index)
	
	# 应用相机缩放
	if config.has("zoom"):
		var camera = get_tree().root.get_node_or_null("Main/Sprite2D/SubViewport/Camera2D")
		if camera:
			var zoom_value = clamp(config["zoom"], 0.001, 1.0)
			camera.zoom = Vector2(zoom_value, zoom_value)
	
	# 应用视口设置
	var viewport = get_tree().root.get_node_or_null("Main/Sprite2D/SubViewport")
	if viewport:
		if config.has("resolution"):
			var resolution = config["resolution"]
			viewport.size = Vector2i(resolution, resolution)
		
		if config.has("hdr"):
			viewport.use_hdr_2d = config["hdr"]
		
		if config.has("lod"):
			viewport.mesh_lod_threshold = config["lod"]
	
	EngineConstants.log_info("[ConfigService] 配置已应用")
	config_loaded.emit(current_config)

# ========== 保存配置 ==========
func save_config(config: Dictionary = current_config) -> bool:
	EngineConstants.log_info("[ConfigService] 保存配置...")
	
	# 验证配置
	var validated_config = _validate_config(config)
	
	# 备份旧配置
	_backup_config_file()
	
	# 保存新配置
	var file = FileAccess.open(config_file_path, FileAccess.WRITE)
	if not file:
		EngineConstants.log_error("[ConfigService] 无法创建配置文件，错误代码: %s" % FileAccess.get_open_error())
		return false
	
	var json_string = JSON.stringify(validated_config, "\t")
	file.store_string(json_string)
	file.close()
	
	# 验证保存是否成功
	if FileAccess.file_exists(config_file_path):
		current_config = validated_config.duplicate()
		config_saved.emit(current_config)
		EngineConstants.log_info("[ConfigService] 配置已保存")
		return true
	else:
		EngineConstants.log_error("[ConfigService] 配置保存失败")
		return false

# ========== 验证配置 ==========
func _validate_config(config: Dictionary) -> Dictionary:
	var validated_config = default_config.duplicate()
	
	# 验证每个配置项
	for key in config.keys():
		if key in default_config:
			var value = config[key]
			var expected_type = typeof(default_config[key])
			var actual_type = typeof(value)
			
			# 类型检查和转换
			var converted_value = value
			var type_valid = false
			
			# 处理数字类型转换
			if expected_type == TYPE_INT and actual_type == TYPE_FLOAT:
				converted_value = int(value)
				type_valid = true
			elif expected_type == TYPE_FLOAT and actual_type == TYPE_INT:
				converted_value = float(value)
				type_valid = true
			elif actual_type == expected_type:
				type_valid = true
			
			if type_valid:
				validated_config[key] = converted_value
			else:
				EngineConstants.log_warning("[ConfigService] 配置项 %s 类型错误，使用默认值" % key)
	
	return validated_config

# ========== 备份和恢复 ==========
func _backup_config_file():
	if FileAccess.file_exists(config_file_path):
		var source_file = FileAccess.open(config_file_path, FileAccess.READ)
		var backup_file = FileAccess.open(backup_config_path, FileAccess.WRITE)
		if source_file and backup_file:
			backup_file.store_string(source_file.get_as_text())
			source_file.close()
			backup_file.close()

func restore_from_backup():
	if FileAccess.file_exists(backup_config_path):
		var backup_file = FileAccess.open(backup_config_path, FileAccess.READ)
		var main_file = FileAccess.open(config_file_path, FileAccess.WRITE)
		if backup_file and main_file:
			main_file.store_string(backup_file.get_as_text())
			backup_file.close()
			main_file.close()
			EngineConstants.log_info("[ConfigService] 已从备份恢复配置")

# ========== 对外接口 ==========
func get_current_config() -> Dictionary:
	return current_config.duplicate()

func reset_to_default():
	await apply_config(default_config)
	save_config(default_config)

func update_config(key: String, value):
	if key in current_config:
		current_config[key] = value
		save_config(current_config)

