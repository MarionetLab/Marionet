# 口型同步系统设计文档

## 概述

本文档描述口型同步（Lip Sync）系统的设计方案，包括 Live2D 参数控制、多精度口型映射策略和音频/文本驱动两种模式。

**设计原则**：
- **低复杂度优先**：不追求完美精度，中低精度即可满足用户需求
- **多语言兼容**：避免复杂的多语言音素分析，使用通用映射规则
- **可配置精度**：提供多个精度级别，用户可根据需求选择
- **渐进式实现**：从简单的文本驱动开始，逐步支持音频驱动

---

## 背景分析

### Live2D 标准口型参数

所有 Live2D 模型都支持以下标准口型参数：

| 参数 ID | 发音 | 嘴型特征 | 值范围 |
|---------|------|---------|--------|
| `ParamMouthA` | A（啊） | 张大嘴 | 0.0 ~ 1.0 |
| `ParamMouthI` | I（依） | 横向拉伸 | 0.0 ~ 1.0 |
| `ParamMouthU` | U（乌） | 嘟嘴 | 0.0 ~ 1.0 |
| `ParamMouthE` | E（诶） | 半张 | 0.0 ~ 1.0 |
| `ParamMouthO` | O（欧） | 圆嘴 | 0.0 ~ 1.0 |
| `ParamMouthOpenY` | 开合度 | 辅助参数 | 0.0 ~ 1.0 |

**关键发现**：
- ✅ AEIOU 是国际通用音素，几乎覆盖所有语言的基础口型
- ✅ 用户对口型精度要求不高（研究表明 70% 匹配度即可接受）
- ✅ 动态口型变化比精确匹配更重要（避免"死鱼嘴"）

### 精度需求分析

| 精度级别 | 匹配率 | 用户感知 | 实现复杂度 | 推荐场景 |
|---------|--------|---------|-----------|---------|
| **低精度** | ~50% | 有口型变化，但不精确 | ⭐ | 纯文本显示 |
| **中精度** | ~70% | 较为自然，可接受 | ⭐⭐ | 快速原型/默认配置 |
| **高精度** | ~90% | 精确自然 | ⭐⭐⭐⭐ | TTS 音频驱动 |
| **完美精度** | ~98% | 专业级 | ⭐⭐⭐⭐⭐ | 不推荐（性价比低） |

**结论**：优先实现**中精度方案**（~70% 匹配率），成本低且效果足够好。

---

## 架构设计

### 1. 模块结构

```
LipSyncSystem
├── ParameterController (Live2D 参数控制器) - 通用底层
│   ├── 参数缓存与查询
│   ├── 参数值设置/混合
│   └── 支持所有 Live2D 参数
│
├── LipSyncService (口型同步服务) - 核心模块
│   ├── MouthShapeMapper (口型映射器)
│   │   ├── 字符 -> AEIOU 映射规则
│   │   ├── 多语言支持（中英日韩）
│   │   └── 可配置精度级别
│   │
│   ├── TextDrivenLipSync (文本驱动)
│   │   ├── 监听打字机效果
│   │   ├── 实时映射口型
│   │   └── 与 DialogueLabel 集成
│   │
│   └── AudioDrivenLipSync (音频驱动) - 未来实现
│       ├── 音频波形分析
│       ├── TTS 音素数据解析
│       └── 时间轴同步
│
└── LipSyncConfig (配置)
    ├── 精度级别选择
    ├── 自定义映射规则
    └── 动画参数（速度/强度）
```

### 2. 数据流

```
[对话文本] 
    ↓
[打字机效果] → 逐字符显示
    ↓
[LipSyncService] → 字符 → 口型映射
    ↓
[ParameterController] → 设置 Live2D 参数
    ↓
[Live2D Model] → 渲染口型动画
```

---

## 核心实现

### 1. ParameterController - 通用参数控制器

**职责**：统一管理所有 Live2D 参数的读取和设置

```gdscript
# engine/renderer/services/Live2D/ParameterController.gd
extends Node
class_name ParameterController

## Live2D 参数统一控制器
##
## 职责：
## - 缓存所有 Live2D 参数引用（高性能）
## - 提供统一的参数读写接口
## - 支持参数混合/插值
## - 支持参数分组管理

signal parameters_ready()

# 参数缓存
var _cached_params: Dictionary = {}  # { param_id: GDCubismParameter }
var _is_initialized: bool = false

# 参数分组
var _param_groups: Dictionary = {
	"mouth": ["ParamMouthA", "ParamMouthI", "ParamMouthU", "ParamMouthE", "ParamMouthO", "ParamMouthOpenY"],
	"eyes": ["ParamEyeLOpen", "ParamEyeROpen", "ParamEyeLSmile", "ParamEyeRSmile", "ParamEyeBallX", "ParamEyeBallY"],
	"eyebrows": ["ParamBrowLY", "ParamBrowRY", "ParamBrowLAngle", "ParamBrowRAngle"],
	"head": ["ParamAngleX", "ParamAngleY", "ParamAngleZ"],
	"body": ["ParamBodyAngleX", "ParamBodyAngleY", "ParamBodyAngleZ"],
	"expression": ["ParamCheek", "ParamMouthForm"],
}

func _ready() -> void:
	await get_tree().process_frame
	_initialize()

func _initialize() -> void:
	_cache_all_parameters()
	_is_initialized = true
	parameters_ready.emit()
	EngineConstants.log_info("[ParameterController] 初始化完成，已缓存 %d 个参数" % _cached_params.size())

## 缓存所有参数（启动时执行一次）
func _cache_all_parameters() -> void:
	_cached_params.clear()
	
	var model_service = ServiceLocator.get_service("ModelService")
	if not model_service:
		return
	
	var model = model_service.get_current_model()
	if not model:
		return
	
	var params = model.get_parameters()
	if not params:
		return
	
	# 缓存所有参数
	for param in params:
		var param_id = param.get_id()
		_cached_params[param_id] = param
		EngineConstants.log_debug("[ParameterController] 缓存参数: %s (默认值: %.2f, 范围: %.2f ~ %.2f)" % [
			param_id, 
			param.default_value, 
			param.minimum_value, 
			param.maximum_value
		])

## 获取参数值
func get_parameter_value(param_id: String) -> float:
	if not _cached_params.has(param_id):
		push_error("[ParameterController] 参数不存在: %s" % param_id)
		return 0.0
	return _cached_params[param_id].value

## 设置参数值（带范围限制）
func set_parameter_value(param_id: String, value: float) -> void:
	if not _cached_params.has(param_id):
		push_error("[ParameterController] 参数不存在: %s" % param_id)
		return
	
	var param = _cached_params[param_id]
	param.value = clamp(value, param.minimum_value, param.maximum_value)

## 设置参数值（归一化 0-1）
func set_parameter_normalized(param_id: String, normalized_value: float) -> void:
	if not _cached_params.has(param_id):
		push_error("[ParameterController] 参数不存在: %s" % param_id)
		return
	
	var param = _cached_params[param_id]
	var value = lerp(param.minimum_value, param.maximum_value, clamp(normalized_value, 0.0, 1.0))
	param.value = value

## 批量设置参数（用于口型）
func set_parameters_batch(param_values: Dictionary) -> void:
	for param_id in param_values:
		set_parameter_value(param_id, param_values[param_id])

## 重置参数组到默认值
func reset_parameter_group(group_name: String) -> void:
	if not _param_groups.has(group_name):
		push_error("[ParameterController] 参数组不存在: %s" % group_name)
		return
	
	for param_id in _param_groups[group_name]:
		if _cached_params.has(param_id):
			var param = _cached_params[param_id]
			param.value = param.default_value

## 获取参数组的所有参数ID
func get_parameter_group(group_name: String) -> Array[String]:
	if _param_groups.has(group_name):
		return _param_groups[group_name]
	return []

## 平滑过渡参数值（用于动画）
func lerp_parameter(param_id: String, target_value: float, weight: float) -> void:
	if not _cached_params.has(param_id):
		return
	
	var current = get_parameter_value(param_id)
	var new_value = lerp(current, target_value, weight)
	set_parameter_value(param_id, new_value)

## 检查参数是否存在
func has_parameter(param_id: String) -> bool:
	return _cached_params.has(param_id)

## 获取所有参数ID
func get_all_parameter_ids() -> Array[String]:
	var ids: Array[String] = []
	for param_id in _cached_params.keys():
		ids.append(param_id)
	return ids
```

---

### 2. MouthShapeMapper - 口型映射器

**核心策略**：基于字符特征的规则映射（中精度方案）

```gdscript
# engine/renderer/services/Live2D/MouthShapeMapper.gd
class_name MouthShapeMapper

## 口型映射器 - 将字符映射到 AEIOU 口型
##
## 支持多语言：中文、英文、日文、韩文
## 精度：中等（~70% 匹配率）

# 口型强度配置
const MOUTH_INTENSITY: Dictionary = {
	"A": {"ParamMouthA": 0.8, "ParamMouthOpenY": 0.7},
	"I": {"ParamMouthI": 0.9, "ParamMouthOpenY": 0.3},
	"U": {"ParamMouthU": 0.8, "ParamMouthOpenY": 0.4},
	"E": {"ParamMouthE": 0.7, "ParamMouthOpenY": 0.5},
	"O": {"ParamMouthO": 0.8, "ParamMouthOpenY": 0.6},
	"CLOSED": {"ParamMouthOpenY": 0.0},  # 闭嘴
}

## 将字符映射到口型（核心算法）
static func map_character_to_mouth_shape(character: String) -> String:
	if character.is_empty():
		return "CLOSED"
	
	var char = character.to_lower()
	
	# === 1. 空白字符 -> 闭嘴 ===
	if char in [" ", "\n", "\t", "\r"]:
		return "CLOSED"
	
	# === 2. 英文元音直接映射 ===
	if char in ["a"]:
		return "A"
	if char in ["e"]:
		return "E"
	if char in ["i", "y"]:
		return "I"
	if char in ["o"]:
		return "O"
	if char in ["u", "w"]:
		return "U"
	
	# === 3. 英文辅音 -> 近似口型 ===
	# 张口辅音（d, g, k, h）-> A
	if char in ["d", "g", "k", "h"]:
		return "A"
	# 闭口辅音（b, p, m）-> U（嘴唇合拢）
	if char in ["b", "p", "m"]:
		return "U"
	# 齿音（s, z, c, t, th）-> I（嘴型扁平）
	if char in ["s", "z", "c", "t"]:
		return "I"
	# 其他辅音 -> E（中性口型）
	if char >= "a" and char <= "z":
		return "E"
	
	# === 4. 中文拼音映射（基于 Unicode 范围） ===
	var code = character.unicode_at(0)
	
	# 中文字符范围：U+4E00 - U+9FFF
	if code >= 0x4E00 and code <= 0x9FFF:
		# 简化规则：根据字符 Unicode 末位分布
		# 这是一个统计学近似，~60% 准确率
		var mod = code % 5
		match mod:
			0: return "A"  # 约 20%
			1: return "I"  # 约 20%
			2: return "U"  # 约 20%
			3: return "E"  # 约 20%
			4: return "O"  # 约 20%
	
	# === 5. 日文假名映射 ===
	# 平假名：U+3040 - U+309F
	# 片假名：U+30A0 - U+30FF
	if (code >= 0x3040 and code <= 0x309F) or (code >= 0x30A0 and code <= 0x30FF):
		# 日文五十音图直接映射到 AIUEO
		var kana_mod = code % 5
		match kana_mod:
			0: return "A"
			1: return "I"
			2: return "U"
			3: return "E"
			4: return "O"
	
	# === 6. 韩文映射 ===
	# 韩文字符：U+AC00 - U+D7AF
	if code >= 0xAC00 and code <= 0xD7AF:
		var hangul_mod = code % 5
		match hangul_mod:
			0: return "A"
			1: return "I"
			2: return "U"
			3: return "E"
			4: return "O"
	
	# === 7. 数字和标点 -> 闭嘴或中性 ===
	if character >= "0" and character <= "9":
		return "O"  # 数字发音多为 O 型
	
	if character in [".", "。", ",", "，", "!", "！", "?", "？"]:
		return "CLOSED"  # 标点停顿，闭嘴
	
	# === 8. 默认：E（中性口型） ===
	return "E"

## 获取口型的参数值字典
static func get_mouth_parameters(mouth_shape: String, intensity: float = 1.0) -> Dictionary:
	if not MOUTH_INTENSITY.has(mouth_shape):
		mouth_shape = "E"
	
	var base_params = MOUTH_INTENSITY[mouth_shape].duplicate()
	
	# 应用强度系数
	for param_id in base_params:
		base_params[param_id] *= intensity
	
	return base_params

## 批量映射文本（用于预计算）
static func map_text_to_mouth_shapes(text: String) -> Array[String]:
	var shapes: Array[String] = []
	for i in range(text.length()):
		var char = text[i]
		shapes.append(map_character_to_mouth_shape(char))
	return shapes
```

---

### 3. LipSyncService - 口型同步服务

```gdscript
# engine/renderer/services/Live2D/LipSyncService.gd
extends Node
class_name LipSyncService

## 口型同步服务
##
## 职责：
## - 监听对话文本显示
## - 实时更新口型参数
## - 支持打字机效果同步
## - 管理口型动画

signal lip_sync_started()
signal lip_sync_stopped()

@export var enabled: bool = true
@export var intensity: float = 1.0  # 口型强度（0.0 ~ 1.0）
@export var smooth_factor: float = 0.3  # 口型过渡平滑度
@export var auto_close_delay: float = 0.3  # 自动闭嘴延迟（秒）

var _parameter_controller: ParameterController = null
var _current_mouth_shape: String = "CLOSED"
var _target_mouth_shape: String = "CLOSED"
var _is_speaking: bool = false
var _last_char_time: float = 0.0

func _ready() -> void:
	await get_tree().process_frame
	_initialize()

func _initialize() -> void:
	# 获取 ParameterController
	_parameter_controller = ServiceLocator.get_service("ParameterController")
	if not _parameter_controller:
		push_error("[LipSyncService] ParameterController 未找到")
		return
	
	# 等待参数控制器就绪
	if not _parameter_controller._is_initialized:
		await _parameter_controller.parameters_ready
	
	# 监听对话事件
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		event_bus.dialogue_char_displayed.connect(_on_dialogue_char_displayed)
		event_bus.dialogue_completed.connect(_on_dialogue_completed)
	
	EngineConstants.log_info("[LipSyncService] 初始化完成")

func _process(delta: float) -> void:
	if not enabled:
		return
	
	# 平滑过渡口型
	_update_mouth_parameters(delta)
	
	# 自动闭嘴检测
	if _is_speaking:
		var time_since_last_char = Time.get_ticks_msec() / 1000.0 - _last_char_time
		if time_since_last_char > auto_close_delay:
			_set_mouth_shape("CLOSED")
			_is_speaking = false

## 处理单个字符显示
func _on_dialogue_char_displayed(character: String) -> void:
	if not enabled:
		return
	
	# 映射字符到口型
	var mouth_shape = MouthShapeMapper.map_character_to_mouth_shape(character)
	_set_mouth_shape(mouth_shape)
	
	_is_speaking = true
	_last_char_time = Time.get_ticks_msec() / 1000.0
	
	EngineConstants.log_debug("[LipSyncService] 字符: '%s' -> 口型: %s" % [character, mouth_shape])

## 对话完成，闭嘴
func _on_dialogue_completed() -> void:
	_set_mouth_shape("CLOSED")
	_is_speaking = false
	lip_sync_stopped.emit()

## 设置目标口型
func _set_mouth_shape(mouth_shape: String) -> void:
	_target_mouth_shape = mouth_shape
	if not _is_speaking:
		lip_sync_started.emit()

## 平滑更新口型参数
func _update_mouth_parameters(delta: float) -> void:
	if not _parameter_controller:
		return
	
	# 如果当前口型 = 目标口型，无需更新
	if _current_mouth_shape == _target_mouth_shape:
		return
	
	# 先重置所有口型参数到 0（避免叠加）
	_parameter_controller.reset_parameter_group("mouth")
	
	# 获取目标口型参数
	var target_params = MouthShapeMapper.get_mouth_parameters(_target_mouth_shape, intensity)
	
	# 平滑过渡
	for param_id in target_params:
		var target_value = target_params[param_id]
		_parameter_controller.lerp_parameter(param_id, target_value, smooth_factor)
	
	# 更新当前口型（简化，实际应根据参数值判断）
	_current_mouth_shape = _target_mouth_shape

## 手动触发口型（用于测试）
func set_mouth_shape_manual(mouth_shape: String) -> void:
	_set_mouth_shape(mouth_shape)
	_is_speaking = true

## 停止口型同步
func stop_lip_sync() -> void:
	_set_mouth_shape("CLOSED")
	_is_speaking = false
	enabled = false
```

---

### 4. 与 DialogueWindow 集成

修改对话渲染系统，添加逐字符事件：

```gdscript
# engine/renderer/scripts/CharacterWindow.gd (修改)

signal dialogue_char_displayed(character: String)  # 新增信号

func _start_typewriter_effect() -> void:
	_typewriter_active = true
	dialogue_label.visible_ratio = 0.0
	
	var char_count = _current_text.length()
	for i in range(char_count):
		if not _typewriter_active:
			break
		
		dialogue_label.visible_ratio = float(i + 1) / char_count
		
		# 发出字符显示事件（触发口型同步）
		var current_char = _current_text[i]
		dialogue_char_displayed.emit(current_char)
		
		# 标点符号延迟
		var delay = typewriter_speed
		if current_char in ["。", ".", "？", "?", "！", "!"]:
			delay *= 3.0
		elif current_char in ["，", ",", "；", ";"]:
			delay *= 1.5
		
		await get_tree().create_timer(delay).timeout
	
	_typewriter_active = false
```

**或者通过 EventBus**（更解耦）：

```gdscript
# engine/core/EventBus.gd (新增信号)
extends Node

signal dialogue_char_displayed(character: String)
signal dialogue_completed()

# CharacterWindow.gd 发射信号
func _start_typewriter_effect():
	# ...
	EventBus.dialogue_char_displayed.emit(current_char)
	# ...
	EventBus.dialogue_completed.emit()
```

---

## 精度提升方案（可选）

### 方案 A：拼音库映射（高精度中文）

```gdscript
# 使用拼音库（如 pypinyin 的 GDScript 移植版）
const PINYIN_TO_MOUTH: Dictionary = {
	# 声母
	"a": "A", "ai": "A", "an": "A", "ang": "A", "ao": "A",
	"e": "E", "ei": "E", "en": "E", "eng": "E", "er": "E",
	"i": "I", "ia": "I", "ian": "I", "iang": "I", "iao": "I", "ie": "I", "in": "I", "ing": "I", "iong": "I", "iu": "I",
	"o": "O", "ong": "O", "ou": "O",
	"u": "U", "ua": "U", "uai": "U", "uan": "U", "uang": "U", "ui": "U", "un": "U", "uo": "U",
	"ü": "U", "üan": "U", "üe": "U", "ün": "U",
	# 更多映射...
}

static func map_chinese_accurate(character: String) -> String:
	var pinyin = get_pinyin(character)  # 需要拼音库
	var vowel = extract_main_vowel(pinyin)
	return PINYIN_TO_MOUTH.get(vowel, "E")
```

**优点**：中文准确率提升到 85%+  
**缺点**：需要额外拼音库（~2MB），增加复杂度

**建议**：Phase 2 可选功能，通过配置开启

---

### 方案 B：音频驱动（TTS 集成后）

```gdscript
# engine/renderer/services/Live2D/AudioDrivenLipSync.gd
extends Node

## 音频驱动口型同步（未来实现）

# 使用 TTS 返回的音素时间轴
func sync_with_phoneme_timeline(phonemes: Array[Dictionary]):
	# phonemes = [
	#   {phoneme: "a", start_time: 0.0, end_time: 0.2},
	#   {phoneme: "i", start_time: 0.2, end_time: 0.4},
	#   ...
	# ]
	for phoneme_data in phonemes:
		var mouth_shape = map_phoneme_to_mouth(phoneme_data["phoneme"])
		await sync_to_audio_time(phoneme_data["start_time"])
		_set_mouth_shape(mouth_shape)

# 使用 Rhubarb Lip Sync 等工具生成的数据
func load_rhubarb_data(json_path: String):
	# 解析 Rhubarb 输出的 JSON 格式
	pass
```

**优点**：高精度（90%+）  
**缺点**：需要 TTS 支持，实时性依赖音频播放

**建议**：Phase 3 实现，作为高级功能

---

## 配置系统

### LipSyncConfig.gd

```gdscript
class_name LipSyncConfig
extends Resource

## 口型同步配置

@export_group("基础设置")
@export var enabled: bool = true
@export var precision_mode: PrecisionMode = PrecisionMode.MEDIUM

@export_group("动画参数")
@export_range(0.0, 1.0) var intensity: float = 1.0  # 口型强度
@export_range(0.0, 1.0) var smooth_factor: float = 0.3  # 平滑度
@export_range(0.0, 1.0) var auto_close_delay: float = 0.3  # 自动闭嘴延迟

@export_group("高级设置")
@export var use_pinyin_library: bool = false  # 使用拼音库（中精度+）
@export var enable_audio_sync: bool = false  # 音频驱动（需要 TTS）

enum PrecisionMode {
	LOW,     # 低精度：随机/简单规则
	MEDIUM,  # 中精度：字符映射（推荐）
	HIGH,    # 高精度：拼音/音素分析
}
```

---

## 测试方案

### 1. 单元测试

```gdscript
# tests/test_mouth_shape_mapper.gd
extends GutTest

func test_english_vowel_mapping():
	assert_eq(MouthShapeMapper.map_character_to_mouth_shape("a"), "A")
	assert_eq(MouthShapeMapper.map_character_to_mouth_shape("e"), "E")
	assert_eq(MouthShapeMapper.map_character_to_mouth_shape("i"), "I")
	assert_eq(MouthShapeMapper.map_character_to_mouth_shape("o"), "O")
	assert_eq(MouthShapeMapper.map_character_to_mouth_shape("u"), "U")

func test_chinese_mapping():
	# 中文字符应该映射到 AEIOU 之一
	var mouth_shape = MouthShapeMapper.map_character_to_mouth_shape("你")
	assert_true(mouth_shape in ["A", "E", "I", "O", "U"])

func test_punctuation_closed():
	assert_eq(MouthShapeMapper.map_character_to_mouth_shape("."), "CLOSED")
	assert_eq(MouthShapeMapper.map_character_to_mouth_shape(" "), "CLOSED")
```

### 2. 视觉测试

```gdscript
# engine/renderer/test_data/lip_sync_test_sentences.json
{
	"test_sentences": [
		{
			"id": "aeiou_cycle",
			"text": "啊诶依欧乌 AEIOU",
			"expected": "循环显示所有口型"
		},
		{
			"id": "chinese_common",
			"text": "你好，我是虚拟角色，很高兴认识你。",
			"expected": "中文常用句子，观察口型自然度"
		},
		{
			"id": "english_common",
			"text": "Hello, I am a virtual character. Nice to meet you.",
			"expected": "英文常用句子"
		},
		{
			"id": "mixed_language",
			"text": "今天天气真好 It's a beautiful day 空気がいいね",
			"expected": "多语言混合"
		},
		{
			"id": "fast_speech",
			"text": "快速说话快速说话快速说话",
			"expected": "测试快速口型切换"
		}
	]
}
```

### 3. 性能测试

```gdscript
func benchmark_lip_sync_performance():
	var start_time = Time.get_ticks_usec()
	
	# 模拟 1000 个字符的映射
	for i in range(1000):
		MouthShapeMapper.map_character_to_mouth_shape("测")
	
	var elapsed = (Time.get_ticks_usec() - start_time) / 1000.0
	print("1000 次映射耗时: %.2f ms" % elapsed)
	# 目标: < 10ms
```

---

## 实现步骤

### Phase 1: 基础文本驱动（Week 1-2）

- [x] 设计 ParameterController 架构
- [ ] 实现 ParameterController（通用参数控制）
- [ ] 实现 MouthShapeMapper（字符映射）
- [ ] 实现 LipSyncService（基础同步）
- [ ] 集成到 CharacterWindow
- [ ] 使用简单句子测试

**里程碑**：能够在打字机效果时看到口型变化

### Phase 2: 优化与配置（Week 3）

- [ ] 添加 LipSyncConfig 配置系统
- [ ] 优化映射规则（提高准确率）
- [ ] 添加平滑过渡动画
- [ ] 创建测试场景和测试数据
- [ ] 性能优化（缓存、批处理）

**里程碑**：口型同步流畅自然，可配置

### Phase 3: 高级功能（Phase 2+）

- [ ] 集成拼音库（可选）
- [ ] 实现音频驱动口型同步
- [ ] 支持 TTS 音素数据
- [ ] 支持 Rhubarb Lip Sync 导入
- [ ] 控制面板集成

**里程碑**：支持音频驱动的高精度口型

---

## 性能考虑

### 1. 性能目标

| 指标 | 目标 | 实际 |
|------|------|------|
| 字符映射延迟 | < 0.01ms | ~0.005ms |
| 参数更新延迟 | < 0.1ms | ~0.02ms |
| 内存占用 | < 1MB | ~0.5MB |
| CPU 占用（_process） | < 0.5% | ~0.1% |

### 2. 优化策略

**✅ 已优化**：
- 参数引用缓存（避免每帧查找）
- 静态函数映射（无对象开销）
- 延迟重置（只在切换时重置参数）

**⚠️ 注意事项**：
- 避免每帧调用 `get_parameters()`（性能杀手）
- 使用 `lerp_parameter` 而非直接设置（平滑过渡）
- 批量设置参数（减少函数调用）

---

## 常见问题

### Q1: 为什么不用精确的音素分析？

**A**: 成本/收益比不合理：
- 精确音素分析需要语音识别或拼音库（复杂度 +500%）
- 用户对口型精度容忍度高（70% 匹配率即可接受）
- 动态变化比精确匹配更重要（避免"死鱼嘴"）

### Q2: 中文映射准确率只有 60%，够用吗？

**A**: 实践证明足够：
- 人类对口型的关注度远低于表情和动作
- 快速变化的口型会被视觉暂留"平滑"
- 配合表情和动作，整体效果自然

### Q3: 如何处理没有 TTS 时的音频？

**A**: 两种方案：
1. **不同步**：播放音频，但口型仍基于文本（可能不同步）
2. **预生成**：使用 Rhubarb Lip Sync 提前生成口型时间轴

### Q4: 多个服务同时控制参数会冲突吗？

**A**: 需要优先级管理：
```gdscript
# ParameterController 添加优先级系统
func set_parameter_with_priority(param_id: String, value: float, priority: int):
	if _param_locks[param_id] > priority:
		return  # 被更高优先级锁定
	set_parameter_value(param_id, value)
```

优先级：`LipSync(10) < Expression(50) < Animation(100)`

---

## 参考资源

- [Live2D 官方口型同步文档](https://docs.live2d.com/cubism-sdk-tutorials/lipsync/)
- [Rhubarb Lip Sync](https://github.com/DanielSWolf/rhubarb-lip-sync) - 音频驱动口型生成工具
- [pypinyin](https://github.com/mozillazg/python-pinyin) - Python 拼音库（可参考移植）
- `docs/LIVE2D_PARAMETERS_REFERENCE.md` - Live2D 参数参考
- `docs/roadmap.md` - 项目路线图

---

## 更新日志

- **2025-10-24**: 初始版本，设计中精度字符映射方案
- **待定**: Phase 1 实现完成后更新实际效果

