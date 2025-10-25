# 测试数据说明

本目录包含用于测试对话渲染系统和口型同步系统的预设测试数据。

## 文件说明

### `long_dialogue_test.json`

对话文字渲染系统的综合测试数据，包含以下测试用例：

| 测试 ID | 描述 | 预期行数 | 测试目的 |
|---------|------|----------|---------|
| `short_normal` | 单行短文本 | 1 | 基础功能 |
| `medium_multiline` | 中等长度文本 | 3 | 自动换行 |
| `long_paragraph` | 长段落 | 8 | 接近行数限制 |
| `extreme_long` | 超长文本 | 20+ | 滚动/截断处理 |
| `rich_text_test` | 富文本格式 | 3 | BBCode 支持 |
| `punctuation_test` | 标点符号 | 2 | 停顿延迟 |
| `mixed_language` | 中英混排 | 4 | 多语言支持 |
| `special_chars` | 特殊字符 | 5 | Unicode 兼容性 |
| `single_very_long_word` | 超长单词 | 3 | 强制换行 |
| `empty_lines` | 空行处理 | 6 | 垂直间距 |

### `lip_sync_test.json`

口型同步系统的测试数据，包含 15 个测试用例：

| 测试 ID | 描述 | 测试目的 |
|---------|------|---------|
| `aeiou_vowels` | 中文元音 | AEIOU 基础映射 |
| `english_vowels` | 英文元音 | 英文 AEIOU 映射 |
| `chinese_greeting` | 中文日常对话 | 自然度观察 |
| `english_greeting` | 英文日常对话 | 元音辅音映射 |
| `mixed_language` | 多语言混合 | 中英日切换 |
| `fast_speech` | 快速对话 | 性能测试 |
| `consonants_test` | 中文辅音 | 声母映射 |
| `punctuation_pause` | 标点符号 | 闭嘴检测 |
| `long_sentence` | 长句测试 | 稳定性 |
| `special_characters` | 特殊字符 | 边界情况 |
| `empty_and_spaces` | 空格测试 | 空白处理 |
| `japanese_hiragana` | 日文平假名 | 日文映射 |
| `japanese_katakana` | 日文片假名 | 日文映射 |
| `korean_test` | 韩文测试 | 韩文映射 |
| `silent_pause` | 换行停顿 | 停顿检测 |

**预期准确率**：
- 英文元音：95%
- 英文辅音：60%
- 中文整体：60%
- 日文整体：70%
- 韩文整体：65%
- 标点符号：100%

## 使用方法

### 在代码中加载测试数据

```gdscript
# 加载测试文件
var file = FileAccess.open("res://renderer/test_data/long_dialogue_test.json", FileAccess.READ)
if file:
	var test_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	# 遍历测试用例
	for test in test_data["test_dialogues"]:
		print("测试: %s - %s" % [test["id"], test["description"]])
		character_window.show_dialogue(test["text"])
		await get_tree().create_timer(3.0).timeout
```

### 运行对话渲染测试

```gdscript
# 创建测试脚本 (engine/renderer/scripts/TestDialogueRendering.gd)
extends Node

@onready var character_window = $CharacterWindow

func _ready():
	_run_tests()

func _run_tests():
	var file = FileAccess.open("res://renderer/test_data/long_dialogue_test.json", FileAccess.READ)
	var test_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	var config = test_data["test_config"]
	
	for test in test_data["test_dialogues"]:
		print("\n=== 测试: %s ===" % test["description"])
		
		# 测试所有位置预设
		for pos in config["test_all_positions"]:
			character_window.dialogue_position = CharacterWindow.DialoguePosition[pos]
			character_window.show_dialogue(test["text"])
			
			await get_tree().create_timer(config["auto_delay_between_tests"]).timeout
			
			character_window.hide_dialogue()
			await get_tree().create_timer(0.5).timeout
```

### 运行口型同步测试

```gdscript
# 创建测试脚本 (engine/renderer/scripts/TestLipSync.gd)
extends Node

@onready var character_window = $CharacterWindow
@onready var lip_sync_service = ServiceLocator.get_service("LipSyncService")

func _ready():
	_run_lip_sync_tests()

func _run_lip_sync_tests():
	var file = FileAccess.open("res://renderer/test_data/lip_sync_test.json", FileAccess.READ)
	var test_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	print("=== 口型同步测试开始 ===")
	print("手动验证清单:")
	for item in test_data["manual_verification_checklist"]:
		print("  - %s" % item)
	print()
	
	for test in test_data["test_sentences"]:
		print("\n[测试 %s]" % test["id"])
		print("描述: %s" % test["description"])
		if test.has("notes"):
			print("注意: %s" % test["notes"])
		
		# 显示对话（自动触发口型同步）
		character_window.show_dialogue(test["text"])
		
		# 等待打字机效果完成
		var estimated_time = test["text"].length() * test_data["test_config"]["typewriter_speed"]
		await get_tree().create_timer(estimated_time + 1.0).timeout
		
		character_window.hide_dialogue()
		await get_tree().create_timer(1.0).timeout
	
	print("\n=== 测试完成 ===")
```

### 手动测试口型映射

```gdscript
# 在 Godot 控制台或调试脚本中测试单个字符
var mapper = MouthShapeMapper.new()

# 测试中文
print(mapper.map_character_to_mouth_shape("你"))  # 应输出 A/E/I/O/U 之一

# 测试英文
print(mapper.map_character_to_mouth_shape("a"))  # 应输出 "A"
print(mapper.map_character_to_mouth_shape("e"))  # 应输出 "E"

# 测试标点
print(mapper.map_character_to_mouth_shape("."))  # 应输出 "CLOSED"
print(mapper.map_character_to_mouth_shape(" "))  # 应输出 "CLOSED"
```

## 测试配置

### 性能基准 (`performance_benchmarks`)

```json
{
	"target_fps": 60,              // 目标帧率
	"max_render_time_ms": 16.67,   // 最大单帧渲染时间
	"max_memory_mb": 50,            // 最大内存占用
	"acceptable_lines": 10,         // 可接受的最大行数
	"warning_lines": 15,            // 警告阈值
	"critical_lines": 20            // 严重阈值（需要优化）
}
```

### 测试配置 (`test_config`)

```json
{
	"auto_delay_between_tests": 3.0,  // 测试间隔（秒）
	"skip_on_click": true,             // 点击跳过
	"show_debug_info": true,           // 显示调试信息
	"test_all_positions": [...]        // 测试所有位置预设
}
```

## 添加新测试用例

复制以下模板到 `test_dialogues` 数组：

```json
{
	"id": "your_test_id",
	"text": "你的测试文本内容",
	"expected_lines": 5,
	"description": "测试描述 - 测试目的"
}
```

## 已知问题

- 超长单词（无空格）可能导致水平溢出，需要启用 `break_mode = TextServer.BREAK_WORD_BOUND`
- 某些 Emoji 可能导致行高不一致（Godot 字体渲染限制）
- 极长文本（1000+ 行）可能影响性能，建议启用滚动或分页

## 相关文档

- `docs/design/dialogue-rendering-system.md` - 对话渲染系统详细设计
- `docs/roadmap.md` - 项目路线图
- `docs/CODING_STANDARDS.md` - 编码规范

---

最后更新：2025-10-24

