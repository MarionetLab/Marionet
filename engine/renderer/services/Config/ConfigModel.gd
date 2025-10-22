# ConfigModel.gd
# 配置数据模型 - 定义配置项的数据结构
extends RefCounted
class_name ConfigModel

# ========== 配置项定义 ==========

# 模型设置
var model_index: int = 0

# 抗锯齿设置
var smaa: float = 0.10
var debanding: bool = true
var mipmap: bool = true

# 相机设置
var zoom: float = 0.44

# 视口设置
var resolution: int = 2048
var hdr: bool = true
var lod: float = 0.6

# ========== 转换函数 ==========

# 从字典创建
static func from_dict(data: Dictionary) -> ConfigModel:
	var config = ConfigModel.new()
	
	if data.has("model_index"):
		config.model_index = data["model_index"]
	if data.has("smaa"):
		config.smaa = data["smaa"]
	if data.has("debanding"):
		config.debanding = data["debanding"]
	if data.has("mipmap"):
		config.mipmap = data["mipmap"]
	if data.has("zoom"):
		config.zoom = data["zoom"]
	if data.has("resolution"):
		config.resolution = data["resolution"]
	if data.has("hdr"):
		config.hdr = data["hdr"]
	if data.has("lod"):
		config.lod = data["lod"]
	
	return config

# 转换为字典
func to_dict() -> Dictionary:
	return {
		"model_index": model_index,
		"smaa": smaa,
		"debanding": debanding,
		"mipmap": mipmap,
		"zoom": zoom,
		"resolution": resolution,
		"hdr": hdr,
		"lod": lod
	}

# 验证配置
func validate() -> bool:
	if model_index < 0:
		return false
	if smaa < 0.0 or smaa > 1.0:
		return false
	if zoom < 0.001 or zoom > 1.0:
		return false
	if resolution not in [1024, 1536, 2048, 4096]:
		return false
	if lod < 0.0 or lod > 1.0:
		return false
	
	return true

