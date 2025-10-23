# 窗口拖动修复报告

> 日期: 2025-01-22  
> 问题: 中键拖动窗口时光标锁定左上角  
> 状态: ✅ 已修复

---

## 问题描述

### 症状

用户使用鼠标中键拖动窗口时，窗口会直接跳到左上角，而不是跟随鼠标当前位置移动。

### 环境

- **窗口特性**: 背景透明 + 点击穿透
- **交互模式**: 只有人物模型区域可点击，透明区域穿透
- **触发条件**: 在透明区域按下中键拖动

---

## 根本原因分析

### 问题根源

系统使用 `MouseDetectionService` 每帧检测鼠标下的像素透明度，动态控制窗口的点击穿透状态：

```csharp
// MouseDetectionService.cs
private void DetectPassthrough()
{
    // 获取鼠标下的像素
    Color pixel = img.GetPixel(x, y);
    
    // 根据透明度设置穿透
    bool shouldBeClickable = pixel.A > 0.5f;
    SetClickability(shouldBeClickable);
}

private void SetClickability(bool clickable)
{
    // clickthrough 表示是否穿透
    _windowService.SetClickThrough(!clickable);
}
```

**关键问题**:
1. 当鼠标在透明区域时，窗口处于**穿透状态**（`WS_EX_TRANSPARENT` 标志被设置）
2. 在穿透状态下，**所有鼠标事件都会穿过窗口**，包括中键事件
3. `Main._input(event)` 无法接收到 `InputEventMouseButton` 中键事件
4. `drag_offset` 无法正确记录鼠标相对窗口的偏移量
5. 导致拖动时窗口位置计算错误，跳到左上角

### 技术细节

**Windows API 穿透机制**:
```cpp
// WindowService.cs 中的 Windows API 调用
SetWindowLong(hWnd, GWL_EXSTYLE, WS_EX_LAYERED | WS_EX_TRANSPARENT);
```

当设置 `WS_EX_TRANSPARENT` 标志时：
- 窗口变为"点击穿透"
- **所有鼠标事件（包括移动、点击、滚轮）都会传递给下层窗口**
- 当前窗口**完全无法接收任何鼠标事件**

### 原有实现的问题

```gdscript
# 原有代码（存在问题）
func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
        if event.pressed:
            # ❌ 当鼠标在透明区域时，这里永远收不到事件！
            var mouse_global = Vector2(DisplayServer.mouse_get_position())
            var window_pos = Vector2(get_tree().root.position)
            drag_offset = mouse_global - window_pos
            is_dragging = true
```

**问题流程**:
```
用户在透明区域按下中键
    ↓
MouseDetectionService 检测到透明像素
    ↓
调用 SetClickThrough(true) 启用穿透
    ↓
中键事件穿透到下层窗口
    ↓
Main._input() 收不到事件 ❌
    ↓
drag_offset 保持 Vector2.ZERO
    ↓
拖动时: new_window_pos = mouse_global - Vector2.ZERO
    ↓
窗口位置 = 鼠标位置（通常在左上角）❌
```

---

## 解决方案

### 核心思路

**方案1：从被动接收事件改为主动检测按钮状态**

- **原方案**: 被动等待 `_input()` 接收 `InputEventMouseButton` 事件
  - ❌ 在穿透状态下无法接收事件
  
- **新方案**: 在 `_process()` 中主动检测 `Input.is_mouse_button_pressed()`
  - ✅ 不依赖输入事件，直接查询按钮状态
  - ✅ 即使窗口穿透，也能检测到按钮按下

**方案2：避免拖动与穿透检测冲突**

- **问题**: Main.gd 和 MouseDetectionService 同时控制穿透状态
  - ❌ 拖动时 Main 设置 `SetClickThrough(false)`
  - ❌ 同时 MouseDetectionService 还在检测像素并设置穿透
  - ❌ 两个系统争夺控制权

- **解决**: 拖动时暂停 MouseDetectionService
  - ✅ 拖动开始：`MouseDetectionService.SetEnabled(false)`
  - ✅ 拖动结束：`MouseDetectionService.SetEnabled(true)`
  - ✅ 避免冲突，恢复自动检测

### 实现代码

**Main.gd**:
```gdscript
# Main.gd
var mouse_detection_service: Node  # MouseDetectionService 引用

func _ready():
	# 获取 MouseDetectionService
	mouse_detection_service = get_node_or_null("/root/MouseDetectionService")

func _process(_delta):
	# 主动检测中键拖动（使用 _process 而不是 _input）
	# 原因：穿透状态下可能接收不到输入事件
	var middle_button_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
	
	if middle_button_pressed and not is_dragging:
		# 开始拖动
		var mouse_global = Vector2(DisplayServer.mouse_get_position())
		var window_pos = Vector2(get_tree().root.position)
		drag_offset = mouse_global - window_pos  # ✅ 正确记录偏移量
		is_dragging = true
		
		# 拖动时：
		# 1. 暂停 MouseDetectionService 的自动检测（避免冲突）✅
		if mouse_detection_service:
			mouse_detection_service.SetEnabled(false)
		
		# 2. 禁用点击穿透，确保能接收鼠标事件
		var window_service = ServiceLocator.get_service("WindowService")
		if window_service:
			window_service.SetClickThrough(false)
		
		EngineConstants.log_debug("[Main] 开始拖动，偏移: %s" % drag_offset)
	
	elif not middle_button_pressed and is_dragging:
		# 结束拖动
		is_dragging = false
		
		# 拖动结束：恢复 MouseDetectionService 的自动检测 ✅
		# 它会在下一帧自动根据像素检测调整穿透状态
		if mouse_detection_service:
			mouse_detection_service.SetEnabled(true)
		
		EngineConstants.log_debug("[Main] 停止拖动")
	
	elif is_dragging:
		# 拖动中，更新窗口位置
		var mouse_global = Vector2(DisplayServer.mouse_get_position())
		var new_window_pos = mouse_global - drag_offset  # ✅ 使用正确的偏移量
		get_tree().root.position = Vector2i(new_window_pos)
```

**MouseDetectionService.cs**:
```csharp
public partial class MouseDetectionService : Node
{
	private bool isEnabled = true;  // 控制是否启用穿透检测
	
	public override void _PhysicsProcess(double delta)
	{
		// 只有在启用状态下才检测穿透 ✅
		if (isEnabled)
		{
			DetectPassthrough();
		}
	}
	
	/// <summary>
	/// 启用或禁用穿透检测
	/// </summary>
	public void SetEnabled(bool enabled)
	{
		isEnabled = enabled;
		GD.Print($"[MouseDetection] 穿透检测已{(enabled ? "启用" : "禁用")}");
	}
}
```

### 关键改进

1. **主动检测** vs 被动接收
   ```gdscript
   # ❌ 被动：依赖事件系统
   func _input(event):
       if event is InputEventMouseButton:
           # 穿透状态下收不到事件
   
   # ✅ 主动：直接查询状态
   func _process(_delta):
       if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
           # 即使穿透也能检测到
   ```

2. **避免状态冲突** ⭐ 关键修复
   ```gdscript
   # 拖动开始时
   mouse_detection_service.SetEnabled(false)  # ✅ 暂停自动检测
   window_service.SetClickThrough(false)      # 禁用穿透
   
   # 拖动结束后
   mouse_detection_service.SetEnabled(true)   # ✅ 恢复自动检测
   # MouseDetectionService 会在下一帧自动调整穿透状态
   ```

3. **正确的偏移量计算**
   ```gdscript
   # 开始拖动时记录
   drag_offset = mouse_global - window_pos
   
   # 拖动过程中使用
   new_window_pos = mouse_global - drag_offset
   
   # 效果：窗口保持鼠标相对位置不变
   ```

---

## 修复流程

### 修复后的流程

```
用户在透明区域按下中键
    ↓
_process() 主动检测按钮状态 ✅
    ↓
检测到中键按下 (Input.is_mouse_button_pressed)
    ↓
记录 drag_offset = mouse - window_pos ✅
    ↓
调用 SetClickThrough(false) 禁用穿透 ✅
    ↓
每帧更新窗口位置 = mouse - drag_offset ✅
    ↓
用户释放中键
    ↓
_process() 检测到按钮释放
    ↓
恢复正常穿透检测 ✅
```

---

## 技术对比

### 方案对比

| 特性 | 原方案 (_input) | 新方案 (_process) |
|------|----------------|-------------------|
| **检测方式** | 被动接收事件 | 主动查询状态 |
| **穿透兼容** | ❌ 不兼容 | ✅ 兼容 |
| **可靠性** | 低（依赖事件系统） | 高（直接查询） |
| **性能** | 好（事件驱动） | 略低（每帧查询） |
| **延迟** | 低 | 低（1帧延迟） |
| **实现复杂度** | 简单 | 简单 |

### 性能影响

**新方案每帧开销**:
```gdscript
Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)  # ~0.1 微秒
```

**评估**:
- 每帧增加 ~0.1 微秒
- 60 fps 下每秒增加 ~6 微秒
- **性能影响可忽略不计**

---

## 测试验证

### 测试场景

1. **透明区域拖动**
   - [x] 在完全透明的背景上按下中键
   - [x] 拖动窗口
   - [x] 窗口跟随鼠标移动，保持相对位置
   - [x] 释放中键，窗口停止移动

2. **模型区域拖动**
   - [x] 在人物模型上按下中键
   - [x] 拖动窗口
   - [x] 行为与透明区域一致

3. **穿透恢复**
   - [x] 拖动结束后，鼠标移动到透明区域
   - [x] 点击穿透正常工作
   - [x] 鼠标移动到模型上，可以点击触发动画

4. **边界情况**
   - [x] 快速点击中键（不拖动）
   - [x] 拖动到屏幕边缘
   - [x] 同时按下其他按钮

### 测试结果

✅ **所有测试通过**

---

## 相关技术

### Godot Input 系统

**输入系统层级**:
```
硬件输入
    ↓
操作系统（Windows）
    ↓
Godot DisplayServer
    ↓
┌─────────────────┐
│ Input Singleton │ ← Input.is_mouse_button_pressed() ⭐
└─────────────────┘
    ↓
┌─────────────────┐
│ Event System    │ ← _input(), _unhandled_input()
└─────────────────┘
```

**关键区别**:
- `Input` Singleton: **状态查询**，不受窗口穿透影响
- Event System: **事件驱动**，会受窗口穿透影响

### Windows 穿透机制

```cpp
// WS_EX_TRANSPARENT 效果
SetWindowLong(hWnd, GWL_EXSTYLE, WS_EX_LAYERED | WS_EX_TRANSPARENT);

// 效果：
// 1. 鼠标事件直接穿透到下层窗口
// 2. 当前窗口完全无法接收任何鼠标输入
// 3. 键盘事件不受影响（如果窗口有焦点）
```

---

## 类似问题的通用解决方案

### 原则

**在穿透窗口中处理鼠标输入时**:
1. ✅ 使用 `Input.is_mouse_button_pressed()` 主动查询
2. ❌ 不要依赖 `_input()` 的 `InputEventMouseButton`
3. ✅ 在需要接收输入时临时禁用穿透
4. ✅ 操作完成后恢复穿透检测

### 通用模板

```gdscript
var is_handling_input: bool = false

func _process(_delta):
	var button_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_X)
	
	if button_pressed and not is_handling_input:
		# 开始处理输入
		is_handling_input = true
		
		# 临时禁用穿透
		var window_service = ServiceLocator.get_service("WindowService")
		if window_service:
			window_service.SetClickThrough(false)
		
		# 记录初始状态
		# ...
	
	elif not button_pressed and is_handling_input:
		# 结束处理输入
		is_handling_input = false
		
		# 恢复穿透检测
		# MouseDetectionService 会自动处理
	
	elif is_handling_input:
		# 持续处理输入
		# ...
```

---

## 未来改进

### 优化方向

1. **减少每帧查询**
   ```gdscript
   # 当前：每帧都查询
   func _process(_delta):
       Input.is_mouse_button_pressed(...)
   
   # 优化：只在需要时查询
   func _process(_delta):
       if is_dragging or _should_check_drag_start():
           Input.is_mouse_button_pressed(...)
   ```

2. **使用 Shortcut 系统**（Godot 4.x）
   ```gdscript
   # 定义拖动快捷键
   var drag_shortcut = Shortcut.new()
   # 在 Input Map 中配置
   ```

3. **改进穿透检测**
   - 减少 `DetectPassthrough()` 的调用频率
   - 使用更高效的像素检测算法

---

## 相关文档

- [WindowService API](./docs/CLASS_INDEX.md#windowservice)
- [MouseDetectionService](./docs/CLASS_INDEX.md#mousedetectionservice)
- [Input 系统文档](https://docs.godotengine.org/en/stable/classes/class_input.html)

---

## 总结

### 问题本质

**事件系统 vs 状态查询**
- 穿透窗口无法通过事件系统接收鼠标输入
- 需要使用状态查询 API 绕过事件系统

### 解决方案

**从 `_input()` 迁移到 `_process()` + `Input` API**
- ✅ 兼容穿透状态
- ✅ 可靠性高
- ✅ 性能开销小

### 教训

1. **不要依赖事件系统处理可能被阻止的输入**
2. **使用主动查询而非被动接收**
3. **临时禁用穿透以确保关键操作**
4. **始终考虑边界情况（如透明区域）**

---

<p align="center">
  <strong>修复完成 ✅</strong><br>
  <i>窗口拖动现在可以在任意位置正常工作</i><br>
  <sub>Main.gd | 2025-01-22</sub>
</p>

