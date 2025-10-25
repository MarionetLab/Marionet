# 对话文字渲染系统设计文档

## 概述

本文档描述对话文字渲染系统的详细设计，包括架构、实现方案、CanvasLayer 使用指南和代码示例。

**核心目标**：
- 在人物窗口内渲染对话文本（无背景）
- 支持多种位置预设（头顶、左侧、右侧、下方、中间）
- 实现打字机效果
- 避免独立窗口的性能和交互问题
- 处理超长文本的边界情况

---

## 架构设计

### 1. 组件层次结构

```
CharacterWindow (Window)
├── Live2DSprite (GDCubismUserModel)
├── DialogueCanvasLayer (CanvasLayer)  ← 关键组件
│   └── DialogueContainer (Control)
│       ├── DialogueLabel (RichTextLabel)
│       └── DialogueAnimator (Node) - 打字机效果控制器
└── [其他组件...]
```

### 2. 为什么使用 CanvasLayer？

**CanvasLayer 特性**：
- 独立于父节点的渲染层（可以设置 z-index）
- 子节点可以相对屏幕坐标定位
- 不受父窗口裁剪限制
- 无额外窗口开销
- 自动跟随父窗口（通过代码控制）

**对比独立窗口**：
| 特性 | CanvasLayer | 独立透明窗口 |
|------|-------------|-------------|
| 性能开销 | 零（同一窗口） | 高（900x900 透明判断） |
| 鼠标穿透 | 无问题 | 需要复杂判断 |
| 交互复杂度 | 简单 | 复杂（区域判断） |
| 代码维护 | 易 | 难 |

---

## 实现方案

### 方案 1：基础实现（推荐用于 Phase 1.5 早期）

#### 场景结构 (Character.tscn)

```
CharacterWindow (Window)
├── Live2DSprite (GDCubismUserModel)
└── DialogueCanvasLayer (CanvasLayer)
    └── DialogueLabel (RichTextLabel)
```

#### 代码实现

**CharacterWindow.gd**

```gdscript
extends Window
class_name CharacterWindow

# 对话位置预设
enum DialoguePosition {
	TOP,       # 头顶上方
	LEFT,      # 左侧
	RIGHT,     # 右侧
	BOTTOM,    # 下方
	CENTER     # 中间（人物身上）
}

@onready var live2d_sprite: GDCubismUserModel = $Live2DSprite
@onready var dialogue_layer: CanvasLayer = $DialogueCanvasLayer
@onready var dialogue_label: RichTextLabel = $DialogueCanvasLayer/DialogueLabel

# 配置参数
@export var dialogue_position: DialoguePosition = DialoguePosition.TOP
@export var position_offset: Vector2 = Vector2(0, -100)  # 相对偏移
@export var max_width: float = 400.0  # 文本最大宽度
@export var typewriter_speed: float = 0.05  # 每字符间隔（秒）

var _typewriter_active: bool = false
var _current_text: String = ""
var _visible_chars: int = 0

func _ready() -> void:
	# CanvasLayer 设置
	dialogue_layer.layer = 100  # 最高渲染层级
	dialogue_layer.follow_viewport_enabled = false
	
	# RichTextLabel 设置
	dialogue_label.bbcode_enabled = true
	dialogue_label.scroll_active = false
	dialogue_label.custom_minimum_size = Vector2(max_width, 0)
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.visible = false
	
	# 文字样式（提高可读性）
	dialogue_label.add_theme_constant_override("shadow_offset_x", 2)
	dialogue_label.add_theme_constant_override("shadow_offset_y", 2)
	dialogue_label.add_theme_constant_override("outline_size", 2)
	
	# 监听对话事件
	var event_bus = get_node("/root/EventBus")
	if event_bus:
		event_bus.dialogue_requested.connect(_on_dialogue_requested)

func _process(_delta: float) -> void:
	# 每帧更新文本位置（跟随人物窗口）
	if dialogue_label.visible:
		_update_dialogue_position()

## 显示对话（公共接口）
func show_dialogue(text: String, use_typewriter: bool = true) -> void:
	_current_text = text
	dialogue_label.text = text
	dialogue_label.visible = true
	
	if use_typewriter:
		_start_typewriter_effect()
	else:
		dialogue_label.visible_ratio = 1.0

## 隐藏对话
func hide_dialogue() -> void:
	dialogue_label.visible = false
	_typewriter_active = false

## 跳过打字机效果
func skip_typewriter() -> void:
	if _typewriter_active:
		dialogue_label.visible_ratio = 1.0
		_typewriter_active = false

## 更新对话位置
func _update_dialogue_position() -> void:
	var window_pos = global_position
	var base_pos: Vector2
	
	# 根据预设位置计算基准坐标
	match dialogue_position:
		DialoguePosition.TOP:
			base_pos = window_pos + Vector2(size.x / 2, 0) + position_offset
		DialoguePosition.LEFT:
			base_pos = window_pos + Vector2(0, size.y / 2) + position_offset
		DialoguePosition.RIGHT:
			base_pos = window_pos + Vector2(size.x, size.y / 2) + position_offset
		DialoguePosition.BOTTOM:
			base_pos = window_pos + Vector2(size.x / 2, size.y) + position_offset
		DialoguePosition.CENTER:
			base_pos = window_pos + Vector2(size.x / 2, size.y / 2) + position_offset
	
	# 居中文本（根据实际宽度）
	var text_width = dialogue_label.size.x
	dialogue_label.global_position = base_pos - Vector2(text_width / 2, 0)

## 打字机效果
func _start_typewriter_effect() -> void:
	_typewriter_active = true
	dialogue_label.visible_ratio = 0.0
	
	var char_count = _current_text.length()
	for i in range(char_count):
		if not _typewriter_active:
			break
		
		dialogue_label.visible_ratio = float(i + 1) / char_count
		
		# 标点符号延迟（句号、问号、感叹号停顿更长）
		var current_char = _current_text[i]
		var delay = typewriter_speed
		if current_char in ["。", ".", "？", "?", "！", "!"]:
			delay *= 3.0
		elif current_char in ["，", ",", "；", ";"]:
			delay *= 1.5
		
		await get_tree().create_timer(delay).timeout
	
	_typewriter_active = false

## 信号回调
func _on_dialogue_requested(text: String) -> void:
	show_dialogue(text)

## 处理点击跳过
func _on_dialogue_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			skip_typewriter()
```

---

### 方案 2：高级实现（支持超长文本滚动）

#### 场景结构 (Character.tscn)

```
CharacterWindow (Window)
├── Live2DSprite (GDCubismUserModel)
└── DialogueCanvasLayer (CanvasLayer)
    └── DialogueContainer (Control)
        ├── DialogueScrollContainer (ScrollContainer)
        │   └── DialogueLabel (RichTextLabel)
        └── ControlButtons (HBoxContainer) - 可选
            ├── SkipButton (Button)
            └── CloseButton (Button)
```

#### 增强代码

**DialogueManager.gd** (新增管理器)

```gdscript
extends Node
class_name DialogueManager

## 对话管理器 - 处理复杂对话逻辑

signal dialogue_started(text: String)
signal dialogue_completed()
signal typewriter_skipped()

const MAX_LINES: int = 10  # 最大显示行数
const FADE_OUT_LINE: int = 8  # 从第几行开始淡出

var _character_window: CharacterWindow = null
var _dialogue_queue: Array[String] = []
var _is_processing: bool = false

func setup(character_window: CharacterWindow) -> void:
	_character_window = character_window

## 添加对话到队列
func queue_dialogue(text: String) -> void:
	_dialogue_queue.append(text)
	if not _is_processing:
		_process_next_dialogue()

## 立即显示对话（清空队列）
func show_dialogue_immediately(text: String) -> void:
	_dialogue_queue.clear()
	_show_dialogue(text)

## 处理队列中的下一条对话
func _process_next_dialogue() -> void:
	if _dialogue_queue.is_empty():
		_is_processing = false
		return
	
	_is_processing = true
	var text = _dialogue_queue.pop_front()
	await _show_dialogue(text)
	
	# 等待一段时间再显示下一条
	await get_tree().create_timer(1.0).timeout
	_process_next_dialogue()

## 显示对话内部实现
func _show_dialogue(text: String) -> void:
	dialogue_started.emit(text)
	
	# 检查文本长度
	var line_count = text.count("\n") + 1
	if line_count > MAX_LINES:
		push_warning("对话文本超过最大行数限制 (%d > %d)" % [line_count, MAX_LINES])
		# 可选：启用滚动或截断
	
	_character_window.show_dialogue(text)
	
	# 等待打字机效果完成（简化实现，实际需要信号）
	var estimated_time = text.length() * _character_window.typewriter_speed
	await get_tree().create_timer(estimated_time).timeout
	
	dialogue_completed.emit()

## 处理超长文本（截断或滚动）
func _handle_long_text(text: String) -> String:
	var lines = text.split("\n")
	if lines.size() <= MAX_LINES:
		return text
	
	# 策略1：保留最后 MAX_LINES 行
	var start_index = lines.size() - MAX_LINES
	return "\n".join(lines.slice(start_index))
	
	# 策略2：添加滚动提示（可选）
	# return text + "\n[color=gray][...更多内容，点击查看对话历史][/color]"
```

---

## CanvasLayer 使用指南

### 1. CanvasLayer 基础

**创建方式**：
```gdscript
# 方式1：场景编辑器创建
# Window -> 添加子节点 -> CanvasLayer

# 方式2：代码创建
var canvas_layer = CanvasLayer.new()
canvas_layer.layer = 100  # 设置渲染层级（越大越上层）
canvas_layer.follow_viewport_enabled = false  # 不跟随视口缩放
add_child(canvas_layer)
```

**关键属性**：
- `layer`: 渲染层级（-128 到 127），默认 0
- `follow_viewport_enabled`: 是否跟随视口变换（缩放/旋转）
- `follow_viewport_scale`: 跟随视口缩放倍数

### 2. 坐标系统

**重要概念**：
- CanvasLayer 的子节点使用**屏幕坐标**（相对屏幕左上角）
- 不受父窗口的 `position` 影响（需要手动计算）

**坐标转换**：
```gdscript
# 父窗口坐标 -> 屏幕坐标
var screen_pos = global_position + local_offset

# 子节点在 CanvasLayer 中设置位置
dialogue_label.global_position = screen_pos
```

### 3. 性能考虑

**CanvasLayer 性能特性**：
- ✅ 同一窗口内渲染（无额外窗口开销）
- ✅ 批量绘制（Godot 自动优化）
- ✅ 无像素透明判断

**最佳实践**：
```gdscript
# ✅ 推荐：只更新必要的属性
func _process(_delta):
	if dialogue_label.visible:
		dialogue_label.global_position = _calculate_position()

# ❌ 避免：每帧重新创建节点
func _process(_delta):
	dialogue_label.queue_free()  # 不要这样做！
	dialogue_label = RichTextLabel.new()
```

---

## 超长文本测试方案

### 1. 测试文本准备

**创建测试文件**：`engine/renderer/test_data/long_dialogue.json`

```json
{
	"test_dialogues": [
		{
			"id": "short_test",
			"text": "这是一个简短的测试对话。",
			"expected_lines": 1
		},
		{
			"id": "medium_test",
			"text": "这是一个中等长度的测试对话，用于验证自动换行功能是否正常工作。它包含足够的文字来触发换行，但不会超出最大行数限制。",
			"expected_lines": 3
		},
		{
			"id": "long_test",
			"text": "这是一个超长测试对话...[重复 500 字]...用于测试滚动和淡出效果。",
			"expected_lines": 15
		},
		{
			"id": "extreme_test",
			"text": "极限测试...[重复 2000 字]...测试性能极限。",
			"expected_lines": 50
		}
	]
}
```

### 2. 测试脚本

**TestDialogueRendering.gd**

```gdscript
extends Node

@onready var character_window = $CharacterWindow
var test_data: Dictionary = {}

func _ready():
	_load_test_data()
	_run_tests()

func _load_test_data():
	var file = FileAccess.open("res://renderer/test_data/long_dialogue.json", FileAccess.READ)
	if file:
		test_data = JSON.parse_string(file.get_as_text())
		file.close()

func _run_tests():
	print("=== 对话渲染测试开始 ===")
	
	for test in test_data["test_dialogues"]:
		print("\n测试: %s" % test["id"])
		character_window.show_dialogue(test["text"])
		await get_tree().create_timer(5.0).timeout
		
		# 检查渲染是否超出窗口
		var label_rect = character_window.dialogue_label.get_global_rect()
		var screen_rect = get_viewport().get_visible_rect()
		
		if not screen_rect.encloses(label_rect):
			push_warning("⚠️ 文本超出屏幕范围！")
		else:
			print("✅ 渲染正常")
		
		character_window.hide_dialogue()
		await get_tree().create_timer(1.0).timeout
	
	print("\n=== 测试完成 ===")
```

### 3. 边界情况处理

**问题 1：文本超出屏幕**
```gdscript
# 解决方案：限制最大高度
dialogue_label.custom_minimum_size = Vector2(400, 0)
dialogue_label.custom_maximum_size = Vector2(400, 600)  # 限制最大高度
dialogue_label.clip_contents = true  # 裁剪超出内容
```

**问题 2：文本行数过多**
```gdscript
# 解决方案：启用滚动
# 将 RichTextLabel 放入 ScrollContainer
var scroll_container = ScrollContainer.new()
scroll_container.custom_minimum_size = Vector2(400, 300)
scroll_container.add_child(dialogue_label)

# 自动滚动到底部（新内容）
scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
```

**问题 3：性能问题（极长文本）**
```gdscript
# 解决方案：分页或截断
const MAX_CHARS: int = 1000

func show_dialogue(text: String):
	if text.length() > MAX_CHARS:
		# 策略1：截断并提示
		text = text.substr(0, MAX_CHARS) + "...\n[点击查看完整对话]"
		
		# 策略2：分页显示
		_show_paginated_dialogue(text)
```

---

## 配置系统集成

### DialogueConfig.gd

```gdscript
class_name DialogueConfig
extends Resource

## 对话渲染配置

@export_group("位置设置")
@export var position_preset: CharacterWindow.DialoguePosition = CharacterWindow.DialoguePosition.TOP
@export var custom_offset: Vector2 = Vector2(0, -100)

@export_group("样式设置")
@export var max_width: float = 400.0
@export var max_height: float = 600.0
@export var font_size: int = 20
@export var text_color: Color = Color.WHITE
@export var shadow_enabled: bool = true
@export var outline_enabled: bool = true

@export_group("动画设置")
@export var typewriter_enabled: bool = true
@export var typewriter_speed: float = 0.05
@export var auto_hide_delay: float = 5.0  # 自动隐藏延迟（秒，0 为禁用）

@export_group("长文本处理")
@export var max_lines: int = 10
@export var overflow_behavior: OverflowBehavior = OverflowBehavior.SCROLL

enum OverflowBehavior {
	CLIP,      # 裁剪
	SCROLL,    # 滚动
	FADE_OUT,  # 淡出旧内容
	PAGINATE   # 分页
}

## 从配置文件加载
static func load_from_file(path: String) -> DialogueConfig:
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path) as DialogueConfig
	return DialogueConfig.new()

## 保存到配置文件
func save_to_file(path: String) -> void:
	ResourceSaver.save(self, path)
```

---

## 实现步骤

### Phase 1: 基础功能 (Week 1-2)

- [ ] 创建 DialogueCanvasLayer 和 DialogueLabel
- [ ] 实现基础位置跟随逻辑
- [ ] 实现 5 种位置预设（TOP/LEFT/RIGHT/BOTTOM/CENTER）
- [ ] 实现基础打字机效果
- [ ] 添加文字阴影/描边

### Phase 2: 高级功能 (Week 3)

- [ ] 实现超长文本滚动
- [ ] 添加点击跳过功能
- [ ] 实现自动隐藏
- [ ] 集成 DialogueConfig 配置系统
- [ ] 添加富文本支持（颜色、粗体等）

### Phase 3: 测试与优化 (Week 4)

- [ ] 创建测试数据和测试脚本
- [ ] 用超长文本测试边界情况
- [ ] 性能分析和优化
- [ ] 编写使用文档

---

## 常见问题

### Q1: CanvasLayer 的子节点会被父窗口裁剪吗？

**A**: 不会。CanvasLayer 渲染在独立的图层，不受父窗口的 `clip_contents` 影响。但如果显示超出屏幕，会被屏幕边界裁剪。

### Q2: 如何让文本始终在屏幕内？

**A**: 检测边界并自动调整位置：
```gdscript
func _clamp_to_screen(pos: Vector2, size: Vector2) -> Vector2:
	var screen_size = get_viewport().get_visible_rect().size
	pos.x = clamp(pos.x, 0, screen_size.x - size.x)
	pos.y = clamp(pos.y, 0, screen_size.y - size.y)
	return pos
```

### Q3: 打字机效果会卡顿吗？

**A**: 不会。使用 `visible_ratio` 而非逐字添加文本，性能很好：
```gdscript
# ✅ 高性能
dialogue_label.visible_ratio = 0.5  # 显示一半

# ❌ 低性能（避免）
dialogue_label.text = text.substr(0, i)  # 每次重新设置文本
```

### Q4: 如何处理 LLM 流式输出？

**A**: 逐 token 追加文本：
```gdscript
func on_llm_token_received(token: String):
	dialogue_label.text += token
	# 打字机效果可以禁用，直接显示流式内容
```

---

## 参考资源

- [Godot CanvasLayer 官方文档](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html)
- [Godot RichTextLabel 官方文档](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html)
- `docs/CODING_STANDARDS.md` - 项目编码规范
- `docs/roadmap.md` - 项目路线图

---

## 更新日志

- **2025-10-24**: 初始版本，基于 CanvasLayer 方案设计
- **待定**: 实现完成后更新实际效果截图和性能数据

