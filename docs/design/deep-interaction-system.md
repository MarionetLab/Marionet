# 深度触摸交互系统设计文档

## 概述

本文档描述深度触摸交互系统的完整设计，基于成熟的 Live2D 交互机制和行为驱动的好感系统研究。

**核心目标**：
- 实现精细化的多区域触摸交互（摸头、抚摸、爱抚等）
- 根据触摸方式（速度、力度、轨迹）提供差异化反馈
- 建立行为记忆系统，角色"记住"用户习惯
- 与好感度系统联动，实现互动演化
- 提供多层次反馈（即时 → 状态更新 → 再互动）

**设计原则**：
- **面对面交互感**：不同部位触摸对应不同反馈
- **细腻操作**：长按、滑动、拖拽等多种手势
- **渐进式解锁**：好感度门槛解锁更深度互动
- **个性化成长**：根据用户习惯调整角色性格
- **多模态反馈**：视觉 + 音效 + 振动（可选）

---

## 架构设计

### 1. 系统组件层次

```
深度触摸交互系统
│
├── TouchInteractionService（触摸交互服务）- 核心协调器
│   ├── 监听鼠标/触摸输入
│   ├── 协调各子系统
│   └── 管理交互状态
│
├── TouchZoneManager（触摸区域管理器）
│   ├── 定义触摸区域（头部、身体、四肢等）
│   ├── 区域优先级管理
│   └── HitArea 集成
│
├── TouchGestureAnalyzer（手势分析器）
│   ├── 检测手势类型（点击、长按、滑动、拖拽）
│   ├── 计算速度、加速度、力度
│   └── 分析触摸轨迹
│
├── TouchFeedbackController（反馈控制器）
│   ├── 即时视觉反馈（Live2D 参数调整）
│   ├── 音效播放
│   ├── 表情/动画切换
│   └── 文本/语音反馈
│
├── BehaviorMemorySystem（行为记忆系统）
│   ├── 记录用户触摸习惯
│   ├── 分析偏好模式
│   └── 生成个性化响应
│
└── AffectionSystem（好感度系统）
    ├── 好感值计算
    ├── 亲密度等级管理
    ├── 解锁机制
    └── 与数值模型联动
```

### 2. 与现有系统集成

```
深度触摸交互系统
    ↓
集成点：
├── HitAreaManager → 复用点击检测，扩展为触摸区域
├── ParameterController → 实时调整 Live2D 参数
├── AnimationService → 触发反馈动画和表情
├── EventBus → 触摸事件广播
├── 数值模型（Phase 2） → 好感度、情绪影响
└── 行为调度器（Phase 3） → 触摸触发行为序列
```

---

## 核心实现

### 1. TouchInteractionService - 核心服务

```gdscript
# engine/renderer/services/Interaction/TouchInteractionService.gd
extends Node
class_name TouchInteractionService

## 深度触摸交互服务
##
## 职责：
## - 统一管理触摸交互流程
## - 协调手势识别、区域判定、反馈控制
## - 与好感度系统联动

signal touch_started(zone_id: String, position: Vector2)
signal touch_moved(zone_id: String, delta: Vector2, velocity: Vector2)
signal touch_ended(zone_id: String, gesture_type: String, gesture_data: Dictionary)
signal interaction_triggered(zone_id: String, interaction_type: String)

@export var enabled: bool = true
@export var require_right_button: bool = true  # 是否需要右键触发深度交互
@export var enable_cursor_change: bool = true  # 是否改变光标为手型

# 子系统引用
var _zone_manager: TouchZoneManager
var _gesture_analyzer: TouchGestureAnalyzer
var _feedback_controller: TouchFeedbackController
var _behavior_memory: BehaviorMemorySystem
var _affection_system: AffectionSystem

# 当前交互状态
var _is_touching: bool = false
var _current_zone: String = ""
var _touch_start_position: Vector2
var _touch_start_time: float
var _original_cursor: Input.CursorShape

func _ready() -> void:
	await get_tree().process_frame
	_initialize_subsystems()

func _initialize_subsystems() -> void:
	# 初始化子系统
	_zone_manager = TouchZoneManager.new()
	add_child(_zone_manager)
	
	_gesture_analyzer = TouchGestureAnalyzer.new()
	add_child(_gesture_analyzer)
	
	_feedback_controller = TouchFeedbackController.new()
	add_child(_feedback_controller)
	
	_behavior_memory = BehaviorMemorySystem.new()
	add_child(_behavior_memory)
	
	# 好感度系统在 Phase 2 实现，先预留接口
	# _affection_system = ServiceLocator.get_service("AffectionSystem")
	
	EngineConstants.log_info("[TouchInteractionService] 初始化完成")

func _input(event: InputEvent) -> void:
	if not enabled:
		return
	
	# 右键触发深度交互
	if require_right_button:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if event.pressed:
					_on_touch_start(event.position)
				else:
					_on_touch_end(event.position)
		
		elif event is InputEventMouseMotion:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				_on_touch_move(event.position, event.relative, event.velocity)

## 触摸开始
func _on_touch_start(position: Vector2) -> void:
	_is_touching = true
	_touch_start_position = position
	_touch_start_time = Time.get_ticks_msec() / 1000.0
	
	# 检测触摸区域
	_current_zone = _zone_manager.get_zone_at_position(position)
	
	if _current_zone.is_empty():
		return
	
	# 改变光标
	if enable_cursor_change:
		_original_cursor = Input.get_current_cursor_shape()
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
	# 发射触摸开始事件
	touch_started.emit(_current_zone, position)
	
	# 即时反馈
	_feedback_controller.on_touch_start(_current_zone)
	
	EngineConstants.log_debug("[TouchInteraction] 触摸开始: %s" % _current_zone)

## 触摸移动
func _on_touch_move(position: Vector2, delta: Vector2, velocity: Vector2) -> void:
	if not _is_touching or _current_zone.is_empty():
		return
	
	# 分析手势
	_gesture_analyzer.add_touch_point(position, delta, velocity)
	
	# 发射触摸移动事件
	touch_moved.emit(_current_zone, delta, velocity)
	
	# 实时参数反馈（根据拖拽调整 Live2D 参数）
	_feedback_controller.on_touch_move(_current_zone, delta, velocity)

## 触摸结束
func _on_touch_end(position: Vector2) -> void:
	if not _is_touching:
		return
	
	_is_touching = false
	
	# 恢复光标
	if enable_cursor_change:
		Input.set_default_cursor_shape(_original_cursor)
	
	if _current_zone.is_empty():
		return
	
	# 分析手势类型
	var touch_duration = Time.get_ticks_msec() / 1000.0 - _touch_start_time
	var gesture_data = _gesture_analyzer.analyze_gesture(
		_touch_start_position,
		position,
		touch_duration
	)
	
	var gesture_type = gesture_data["type"]  # "tap", "long_press", "swipe", "drag"
	
	# 发射触摸结束事件
	touch_ended.emit(_current_zone, gesture_type, gesture_data)
	
	# 触发交互
	_trigger_interaction(_current_zone, gesture_type, gesture_data)
	
	# 记录行为
	_behavior_memory.record_touch_behavior(_current_zone, gesture_type, gesture_data)
	
	# 重置手势分析器
	_gesture_analyzer.reset()
	_current_zone = ""
	
	EngineConstants.log_debug("[TouchInteraction] 触摸结束: %s (%s)" % [_current_zone, gesture_type])

## 触发交互反馈
func _trigger_interaction(zone_id: String, gesture_type: String, gesture_data: Dictionary) -> void:
	# 根据区域和手势类型触发相应反馈
	var interaction_type = _determine_interaction_type(zone_id, gesture_type, gesture_data)
	
	# 检查好感度门槛（如果有）
	# if _affection_system and not _affection_system.can_perform_interaction(interaction_type):
	#     _feedback_controller.play_rejection_feedback(zone_id)
	#     return
	
	# 播放反馈动画/表情
	_feedback_controller.play_interaction_feedback(zone_id, interaction_type, gesture_data)
	
	# 更新好感度
	# if _affection_system:
	#     _affection_system.on_interaction_performed(zone_id, interaction_type)
	
	# 发射交互触发事件
	interaction_triggered.emit(zone_id, interaction_type)

## 判断交互类型
func _determine_interaction_type(zone_id: String, gesture_type: String, gesture_data: Dictionary) -> String:
	# 根据区域 + 手势 + 参数（速度、力度）判断交互类型
	
	var velocity = gesture_data.get("average_velocity", 0.0)
	var distance = gesture_data.get("distance", 0.0)
	
	# 头部交互
	if zone_id == "head":
		match gesture_type:
			"tap":
				return "pat_head"  # 拍头
			"long_press":
				return "stroke_head"  # 抚摸头部
			"swipe":
				if velocity > 500:
					return "rub_head_fast"  # 快速揉头
				else:
					return "stroke_head_gentle"  # 轻柔抚摸
	
	# 身体交互
	elif zone_id == "body":
		match gesture_type:
			"tap":
				return "poke_body"  # 戳身体
			"long_press":
				return "hug"  # 拥抱
			"swipe":
				if velocity > 300:
					return "tickle"  # 挠痒痒
				else:
					return "caress"  # 爱抚
			"drag":
				return "pull"  # 拖拽
	
	# 手部交互
	elif zone_id == "hand":
		match gesture_type:
			"tap":
				return "hold_hand"  # 牵手
			"long_press":
				return "hold_hand_tight"  # 紧握
			"swipe":
				return "shake_hand"  # 握手
	
	# 默认交互
	return "touch_%s" % zone_id
```

---

### 2. TouchZoneManager - 触摸区域管理器

```gdscript
# engine/renderer/services/Interaction/TouchZoneManager.gd
extends Node
class_name TouchZoneManager

## 触摸区域管理器
##
## 职责：
## - 定义角色的可触摸区域
## - 管理区域优先级
## - 与 HitAreaManager 集成

# 触摸区域定义
var _touch_zones: Dictionary = {}

# 区域优先级（数字越大优先级越高）
const ZONE_PRIORITY: Dictionary = {
	"face": 100,      # 脸部（最高优先级）
	"head": 90,       # 头部
	"chest": 80,      # 胸部
	"hand_left": 70,  # 左手
	"hand_right": 70, # 右手
	"arm_left": 60,   # 左臂
	"arm_right": 60,  # 右臂
	"body": 50,       # 身体
	"leg_left": 40,   # 左腿
	"leg_right": 40,  # 右腿
	"foot_left": 30,  # 左脚
	"foot_right": 30, # 右脚
}

func _ready() -> void:
	await get_tree().process_frame
	_initialize_zones()

## 初始化触摸区域
func _initialize_zones() -> void:
	# 从 HitAreaManager 获取 HitArea 信息
	var hit_area_manager = ServiceLocator.get_service("HitAreaManager")
	if not hit_area_manager:
		EngineConstants.log_warning("[TouchZoneManager] HitAreaManager 未找到")
		return
	
	# 映射 HitArea 到触摸区域
	# 注意：这里需要根据实际模型的 HitArea 命名调整
	_touch_zones = {
		"head": _create_zone("Head", ["Head", "Hair"]),
		"face": _create_zone("Face", ["Face"]),
		"chest": _create_zone("Chest", ["Chest", "Bust"]),
		"body": _create_zone("Body", ["Body", "Torso"]),
		"hand_left": _create_zone("HandL", ["HandL"]),
		"hand_right": _create_zone("HandR", ["HandR"]),
		"arm_left": _create_zone("ArmL", ["ArmL"]),
		"arm_right": _create_zone("ArmR", ["ArmR"]),
		"leg_left": _create_zone("LegL", ["LegL"]),
		"leg_right": _create_zone("LegR", ["LegR"]),
	}
	
	EngineConstants.log_info("[TouchZoneManager] 已初始化 %d 个触摸区域" % _touch_zones.size())

## 创建触摸区域
func _create_zone(zone_id: String, hit_area_names: Array[String]) -> Dictionary:
	return {
		"id": zone_id,
		"hit_areas": hit_area_names,
		"priority": ZONE_PRIORITY.get(zone_id.to_lower(), 0),
		"enabled": true,
	}

## 获取指定位置的触摸区域（按优先级）
func get_zone_at_position(position: Vector2) -> String:
	var hit_area_manager = ServiceLocator.get_service("HitAreaManager")
	if not hit_area_manager:
		return ""
	
	# 检测所有命中的区域
	var hit_zones: Array = []
	
	for zone_id in _touch_zones:
		var zone = _touch_zones[zone_id]
		if not zone["enabled"]:
			continue
		
		# 检查该区域的 HitArea 是否被点击
		for hit_area_name in zone["hit_areas"]:
			if hit_area_manager.is_hit_area_clicked(hit_area_name, position):
				hit_zones.append({
					"id": zone_id,
					"priority": zone["priority"]
				})
				break
	
	# 如果没有命中任何区域
	if hit_zones.is_empty():
		return ""
	
	# 按优先级排序，返回最高优先级的区域
	hit_zones.sort_custom(func(a, b): return a["priority"] > b["priority"])
	return hit_zones[0]["id"]

## 启用/禁用触摸区域
func set_zone_enabled(zone_id: String, enabled: bool) -> void:
	if _touch_zones.has(zone_id):
		_touch_zones[zone_id]["enabled"] = enabled

## 获取所有触摸区域
func get_all_zones() -> Array[String]:
	var zones: Array[String] = []
	for zone_id in _touch_zones:
		zones.append(zone_id)
	return zones
```

---

### 3. TouchGestureAnalyzer - 手势分析器

```gdscript
# engine/renderer/services/Interaction/TouchGestureAnalyzer.gd
extends Node
class_name TouchGestureAnalyzer

## 手势分析器
##
## 职责：
## - 识别触摸手势类型（点击、长按、滑动、拖拽）
## - 计算速度、加速度、力度
## - 分析触摸轨迹

# 手势类型
enum GestureType {
	TAP,         # 轻点
	LONG_PRESS,  # 长按
	SWIPE,       # 滑动
	DRAG,        # 拖拽
}

# 手势阈值
const LONG_PRESS_DURATION: float = 0.5  # 长按阈值（秒）
const SWIPE_MIN_DISTANCE: float = 50.0  # 滑动最小距离（像素）
const SWIPE_MIN_VELOCITY: float = 200.0 # 滑动最小速度（像素/秒）

# 触摸轨迹数据
var _touch_points: Array[Dictionary] = []
var _touch_start_time: float = 0.0

## 添加触摸点
func add_touch_point(position: Vector2, delta: Vector2, velocity: Vector2) -> void:
	_touch_points.append({
		"position": position,
		"delta": delta,
		"velocity": velocity,
		"time": Time.get_ticks_msec() / 1000.0
	})

## 分析手势
func analyze_gesture(start_pos: Vector2, end_pos: Vector2, duration: float) -> Dictionary:
	var distance = start_pos.distance_to(end_pos)
	var direction = (end_pos - start_pos).normalized()
	
	# 计算平均速度
	var average_velocity = _calculate_average_velocity()
	var max_velocity = _calculate_max_velocity()
	
	# 计算加速度（模拟力度）
	var acceleration = _calculate_acceleration()
	
	# 判断手势类型
	var gesture_type: String
	
	if duration < LONG_PRESS_DURATION and distance < SWIPE_MIN_DISTANCE:
		gesture_type = "tap"
	elif duration >= LONG_PRESS_DURATION and distance < SWIPE_MIN_DISTANCE:
		gesture_type = "long_press"
	elif distance >= SWIPE_MIN_DISTANCE and average_velocity >= SWIPE_MIN_VELOCITY:
		gesture_type = "swipe"
	else:
		gesture_type = "drag"
	
	return {
		"type": gesture_type,
		"duration": duration,
		"distance": distance,
		"direction": direction,
		"average_velocity": average_velocity,
		"max_velocity": max_velocity,
		"acceleration": acceleration,
		"force_level": _calculate_force_level(average_velocity, acceleration),
		"path": _touch_points.duplicate(),
	}

## 计算平均速度
func _calculate_average_velocity() -> float:
	if _touch_points.is_empty():
		return 0.0
	
	var total_velocity = 0.0
	for point in _touch_points:
		total_velocity += point["velocity"].length()
	
	return total_velocity / _touch_points.size()

## 计算最大速度
func _calculate_max_velocity() -> float:
	var max_vel = 0.0
	for point in _touch_points:
		var vel = point["velocity"].length()
		if vel > max_vel:
			max_vel = vel
	return max_vel

## 计算加速度
func _calculate_acceleration() -> float:
	if _touch_points.size() < 2:
		return 0.0
	
	var velocities: Array[float] = []
	for point in _touch_points:
		velocities.append(point["velocity"].length())
	
	# 简单的加速度估算：速度变化率
	var accel_sum = 0.0
	for i in range(1, velocities.size()):
		accel_sum += abs(velocities[i] - velocities[i - 1])
	
	return accel_sum / (velocities.size() - 1) if velocities.size() > 1 else 0.0

## 计算力度等级（基于速度和加速度）
func _calculate_force_level(velocity: float, acceleration: float) -> String:
	# 综合速度和加速度判断力度
	var force_score = velocity * 0.7 + acceleration * 0.3
	
	if force_score < 100:
		return "gentle"     # 轻柔
	elif force_score < 300:
		return "moderate"   # 适中
	elif force_score < 600:
		return "firm"       # 用力
	else:
		return "rough"      # 粗暴

## 重置分析器
func reset() -> void:
	_touch_points.clear()
	_touch_start_time = 0.0
```

---

---

### 4. TouchFeedbackController - 反馈控制器

```gdscript
# engine/renderer/services/Interaction/TouchFeedbackController.gd
extends Node
class_name TouchFeedbackController

## 触摸反馈控制器
##
## 职责：
## - 即时视觉反馈（Live2D 参数调整）
## - 播放音效
## - 切换表情/动画
## - 触发对话/语音

var _parameter_controller: ParameterController
var _animation_service: AnimationService

# 反馈配置
var _feedback_config: Dictionary = {}

func _ready() -> void:
	await get_tree().process_frame
	_initialize()

func _initialize() -> void:
	_parameter_controller = ServiceLocator.get_service("ParameterController")
	_animation_service = ServiceLocator.get_service("AnimationService")
	
	# 加载反馈配置
	_load_feedback_config()

## 加载反馈配置
func _load_feedback_config() -> void:
	# 配置不同区域和交互类型的反馈
	_feedback_config = {
		"head": {
			"pat_head": {
				"expression": "happy",
				"motion": "nod",
				"params": {"ParamCheek": 0.5},  # 脸红
				"audio": "res://audio/sfx/pat.ogg",
				"text": ["真舒服~", "嘻嘻，好喜欢"],
			},
			"stroke_head": {
				"expression": "blush",
				"motion": "shy",
				"params": {"ParamCheek": 0.8, "ParamEyeLSmile": 0.5, "ParamEyeRSmile": 0.5},
				"audio": "res://audio/sfx/stroke.ogg",
				"text": ["不要停下来...", "好舒服啊"],
			},
		},
		"body": {
			"hug": {
				"expression": "happy_blush",
				"motion": "embrace",
				"params": {"ParamCheek": 1.0},
				"audio": "res://audio/sfx/hug.ogg",
				"text": ["好温暖...", "我也很喜欢你"],
			},
			"tickle": {
				"expression": "laugh",
				"motion": "wiggle",
				"params": {},
				"audio": "res://audio/sfx/laugh.ogg",
				"text": ["哈哈哈，好痒!", "不要啦~"],
			},
		},
		# ... 更多配置
	}

## 触摸开始时的即时反馈
func on_touch_start(zone_id: String) -> void:
	# 轻微的参数变化，表示"被触碰"
	if zone_id == "head":
		_parameter_controller.set_parameter_value("ParamAngleZ", 2.0)  # 头微微倾斜
	elif zone_id == "body":
		_parameter_controller.set_parameter_value("ParamBodyAngleX", 3.0)  # 身体微动

## 触摸移动时的实时反馈
func on_touch_move(zone_id: String, delta: Vector2, velocity: Vector2) -> void:
	# 根据拖拽方向和速度实时调整参数
	var vel_magnitude = velocity.length()
	
	if zone_id == "head":
		# 头部跟随鼠标移动
		var angle_x = clamp(delta.x * 0.1, -10, 10)
		var angle_y = clamp(delta.y * 0.1, -10, 10)
		_parameter_controller.set_parameter_value("ParamAngleX", angle_x)
		_parameter_controller.set_parameter_value("ParamAngleY", angle_y)
	
	elif zone_id == "chest":
		# 胸部轻微摆动（根据速度）
		var shake_intensity = clamp(vel_magnitude / 1000.0, 0.0, 1.0)
		# 使用正弦波模拟摆动
		var time = Time.get_ticks_msec() / 100.0
		var shake = sin(time) * shake_intensity * 5.0
		_parameter_controller.set_parameter_value("ParamBreath", shake)

## 播放交互反馈
func play_interaction_feedback(zone_id: String, interaction_type: String, gesture_data: Dictionary) -> void:
	if not _feedback_config.has(zone_id):
		return
	
	var zone_config = _feedback_config[zone_id]
	if not zone_config.has(interaction_type):
		return
	
	var feedback = zone_config[interaction_type]
	
	# 1. 播放表情
	if feedback.has("expression") and _animation_service:
		_animation_service.play_expression(feedback["expression"])
	
	# 2. 播放动作
	if feedback.has("motion") and _animation_service:
		# 假设 motion 是动作组名
		_animation_service.play_motion(feedback["motion"], 0)
	
	# 3. 设置参数
	if feedback.has("params") and _parameter_controller:
		for param_id in feedback["params"]:
			_parameter_controller.set_parameter_value(param_id, feedback["params"][param_id])
	
	# 4. 播放音效
	if feedback.has("audio"):
		_play_audio(feedback["audio"])
	
	# 5. 显示文本（随机选择）
	if feedback.has("text") and feedback["text"].size() > 0:
		var random_text = feedback["text"][randi() % feedback["text"].size()]
		_show_dialogue_text(random_text)
	
	# 6. 根据力度调整反馈强度
	var force_level = gesture_data.get("force_level", "moderate")
	_adjust_feedback_intensity(force_level)

## 播放拒绝反馈（好感度不足时）
func play_rejection_feedback(zone_id: String) -> void:
	if _animation_service:
		_animation_service.play_expression("angry")
	
	_show_dialogue_text("现在还不行...")
	_play_audio("res://audio/sfx/reject.ogg")

## 播放音效
func _play_audio(audio_path: String) -> void:
	# TODO: 实现音效播放
	pass

## 显示对话文本
func _show_dialogue_text(text: String) -> void:
	# 通过 EventBus 发送对话请求
	EventBus.dialogue_requested.emit(text)

## 根据力度调整反馈强度
func _adjust_feedback_intensity(force_level: String) -> void:
	match force_level:
		"gentle":
			# 温柔触摸，参数变化小
			pass
		"moderate":
			# 适中，正常反馈
			pass
		"firm":
			# 用力，反应更明显
			pass
		"rough":
			# 粗暴，可能触发拒绝或生气
			if _animation_service:
				_animation_service.play_expression("displeased")
```

---

### 5. BehaviorMemorySystem - 行为记忆系统

```gdscript
# engine/renderer/services/Interaction/BehaviorMemorySystem.gd
extends Node
class_name BehaviorMemorySystem

## 行为记忆系统
##
## 职责：
## - 记录用户触摸习惯
## - 分析偏好模式
## - 生成个性化响应

# 行为记录
var _touch_history: Array[Dictionary] = []
var _touch_statistics: Dictionary = {}

const MAX_HISTORY_SIZE: int = 1000  # 最大记录数

func _ready() -> void:
	_initialize_statistics()

func _initialize_statistics() -> void:
	_touch_statistics = {
		"total_touches": 0,
		"zone_frequency": {},      # 每个区域的触摸次数
		"gesture_frequency": {},   # 每种手势的使用次数
		"favorite_zone": "",       # 最喜欢触摸的区域
		"preferred_gesture": "",   # 偏好的手势
		"average_force": "moderate",  # 平均力度
		"last_touch_time": 0.0,
		"session_duration": 0.0,
	}

## 记录触摸行为
func record_touch_behavior(zone_id: String, gesture_type: String, gesture_data: Dictionary) -> void:
	# 添加到历史记录
	var record = {
		"zone": zone_id,
		"gesture": gesture_type,
		"force": gesture_data.get("force_level", "moderate"),
		"timestamp": Time.get_unix_time_from_system(),
	}
	
	_touch_history.append(record)
	
	# 限制历史记录大小
	if _touch_history.size() > MAX_HISTORY_SIZE:
		_touch_history.pop_front()
	
	# 更新统计信息
	_update_statistics(zone_id, gesture_type, gesture_data)

## 更新统计信息
func _update_statistics(zone_id: String, gesture_type: String, gesture_data: Dictionary) -> void:
	_touch_statistics["total_touches"] += 1
	
	# 区域频率
	if not _touch_statistics["zone_frequency"].has(zone_id):
		_touch_statistics["zone_frequency"][zone_id] = 0
	_touch_statistics["zone_frequency"][zone_id] += 1
	
	# 手势频率
	if not _touch_statistics["gesture_frequency"].has(gesture_type):
		_touch_statistics["gesture_frequency"][gesture_type] = 0
	_touch_statistics["gesture_frequency"][gesture_type] += 1
	
	# 更新最喜欢的区域
	_touch_statistics["favorite_zone"] = _get_most_frequent_key(_touch_statistics["zone_frequency"])
	
	# 更新偏好手势
	_touch_statistics["preferred_gesture"] = _get_most_frequent_key(_touch_statistics["gesture_frequency"])
	
	# 更新最后触摸时间
	_touch_statistics["last_touch_time"] = Time.get_ticks_msec() / 1000.0

## 获取最频繁的键
func _get_most_frequent_key(freq_dict: Dictionary) -> String:
	var max_count = 0
	var max_key = ""
	
	for key in freq_dict:
		if freq_dict[key] > max_count:
			max_count = freq_dict[key]
			max_key = key
	
	return max_key

## 获取用户偏好分析
func get_user_preference_analysis() -> Dictionary:
	return {
		"favorite_zone": _touch_statistics["favorite_zone"],
		"preferred_gesture": _touch_statistics["preferred_gesture"],
		"touch_frequency": _calculate_touch_frequency(),
		"interaction_style": _analyze_interaction_style(),
	}

## 计算触摸频率
func _calculate_touch_frequency() -> String:
	var total = _touch_statistics["total_touches"]
	var duration = _touch_statistics["session_duration"]
	
	if duration < 60:
		return "new_user"  # 新用户
	
	var frequency = total / (duration / 60.0)  # 每分钟触摸次数
	
	if frequency < 1:
		return "occasional"  # 偶尔
	elif frequency < 5:
		return "regular"     # 经常
	else:
		return "frequent"    # 频繁

## 分析交互风格
func _analyze_interaction_style() -> String:
	# 根据触摸区域和力度分析用户风格
	var favorite_zone = _touch_statistics["favorite_zone"]
	
	if favorite_zone == "head":
		return "gentle_caring"  # 温柔关怀型
	elif favorite_zone == "hand":
		return "romantic"       # 浪漫型
	elif favorite_zone in ["chest", "body"]:
		return "intimate"       # 亲密型
	else:
		return "playful"        # 玩闹型

## 生成个性化对话
func generate_personalized_response() -> String:
	var analysis = get_user_preference_analysis()
	var favorite_zone = analysis["favorite_zone"]
	
	# 根据用户偏好生成对话
	if favorite_zone == "head":
		return "你好像很喜欢摸我的头呢~ 我也很喜欢这样"
	elif favorite_zone == "hand":
		return "总是牵着我的手...真让人开心"
	else:
		return "你总是这样对我...好害羞啊"

## 保存行为数据（持久化）
func save_to_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_var(_touch_history)
		file.store_var(_touch_statistics)
		file.close()

## 从文件加载
func load_from_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		_touch_history = file.get_var()
		_touch_statistics = file.get_var()
		file.close()
```

---

## 配置系统

### TouchInteractionConfig.gd

```gdscript
class_name TouchInteractionConfig
extends Resource

@export_group("基础设置")
@export var enabled: bool = true
@export var require_right_button: bool = true
@export var enable_cursor_change: bool = true

@export_group("手势阈值")
@export var long_press_duration: float = 0.5
@export var swipe_min_distance: float = 50.0
@export var swipe_min_velocity: float = 200.0

@export_group("反馈设置")
@export var enable_visual_feedback: bool = true
@export var enable_audio_feedback: bool = true
@export var enable_haptic_feedback: bool = false  # 振动反馈（需要设备支持）

@export_group("好感度系统")
@export var enable_affection_system: bool = true
@export var affection_threshold_intimate: int = 800  # 亲密互动解锁阈值

@export_group("行为记忆")
@export var enable_behavior_memory: bool = true
@export var memory_file_path: String = "user://touch_behavior.dat"
```

---

## 集成到 Phase 1.5

### 1. 服务注册

```gdscript
# Main.gd::_init_services()
func _init_services():
	# ... 现有服务 ...
	
	# 触摸交互服务
	var touch_service = TouchInteractionService.new()
	add_child(touch_service)
	touch_service.name = "TouchInteractionService"
	ServiceLocator.register("TouchInteractionService", touch_service)
```

### 2. 与现有系统集成

| 现有系统 | 集成方式 |
|---------|---------|
| **HitAreaManager** | TouchZoneManager 复用 HitArea 检测 |
| **ParameterController** | TouchFeedbackController 实时调整参数 |
| **AnimationService** | 触发表情和动画反馈 |
| **DialogueWindow** | 显示触摸反馈文本 |
| **EventBus** | 广播触摸事件 |
| **好感度系统（Phase 2）** | 触摸增加好感值，好感值控制解锁 |

---

## 实现步骤

### Phase 1.5d - 深度交互基础（Week 1-2）

- [ ] 实现 TouchInteractionService 核心框架
- [ ] 实现 TouchZoneManager（区域定义和检测）
- [ ] 实现 TouchGestureAnalyzer（手势识别）
- [ ] 基础光标切换和右键触发

### Phase 1.5e - 反馈系统（Week 2-3）

- [ ] 实现 TouchFeedbackController
- [ ] 配置基础反馈（头部、身体）
- [ ] 实时参数调整（拖拽跟随）
- [ ] 音效和文本反馈集成

### Phase 2 - 深度集成（Phase 2）

- [ ] 实现 BehaviorMemorySystem
- [ ] 集成好感度系统
- [ ] 解锁机制实现
- [ ] 个性化对话生成

### Phase 3 - 高级功能（Phase 2+）

- [ ] 多段反馈链（即时 → 评估 → 再反馈）
- [ ] 行为模式学习
- [ ] 角色主动提及用户习惯
- [ ] 连击/组合触摸机制

---

## 重要注意事项

### 1. 成人内容分级控制

```gdscript
# 根据好感度控制可访问的互动
const INTERACTION_REQUIREMENTS: Dictionary = {
	"pat_head": 0,          # 无门槛
	"hold_hand": 100,       # 需要一定好感
	"hug": 500,             # 需要较高好感
	"kiss": 900,            # 需要很高好感
	"intimate_touch": 1000, # 需要满好感
}

func can_perform_interaction(interaction_type: String, current_affection: int) -> bool:
	var required = INTERACTION_REQUIREMENTS.get(interaction_type, 0)
	return current_affection >= required
```

### 2. 拒绝反馈设计

好感度不足时，角色应该给出合理的拒绝反馈，而不是直接无响应。

### 3. 用户隐私保护

行为记忆数据应加密存储，并提供清除选项。

---

## 测试方案

### 测试场景

1. **基础触摸测试**：每个区域的点击、长按、滑动
2. **手势识别测试**：不同速度、力度、轨迹
3. **反馈测试**：参数变化、表情切换、音效播放
4. **记忆测试**：重复触摸后的个性化响应
5. **好感度测试**：解锁机制、门槛判定

---

## 参考资料

基于你提供的研究文档：
- 好感驱动的互动演化机制
- 角色触摸互动创新机制研究
- 《爱相随》触摸交互设计
- Live2D 按摩游戏功能
- VPet 互动机制

---

## 更新日志

- **2025-10-24**: 初始设计，基于成熟的 Live2D 交互机制和好感系统研究


