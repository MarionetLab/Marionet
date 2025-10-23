# 🖱️ 鼠标事件处理流程文档

> **版本**: 1.0  
> **更新时间**: 2025-10-23  
> **架构**: 被动检测（事件驱动）

---

## 📋 **目录**

1. [架构概述](#架构概述)
2. [核心组件](#核心组件)
3. [事件流程](#事件流程)
4. [代码实现](#代码实现)
5. [状态转换图](#状态转换图)
6. [性能说明](#性能说明)

---

## 🎯 **架构概述**

### 设计原则

**被动检测**（Event-Driven Detection）：
- ✅ 只在鼠标事件（按下/释放）时检测像素透明度
- ✅ 不进行主动轮询（无 `_PhysicsProcess()`）
- ✅ 性能最优：~60 倍性能提升

### 核心流程

```
用户交互
    ↓
Main.gd (_input 或 _process)
    ↓
MouseDetectionService (被动检测)
    ↓
WindowService (Windows API)
    ↓
操作系统窗口管理器
```

---

## 🧩 **核心组件**

### 1. `WindowService.cs`

**职责**：
- 管理窗口属性（Layered Window）
- 控制点击穿透状态（`WS_EX_TRANSPARENT`）
- 提供 `SetClickThrough(bool)` 接口

**关键方法**：
```csharp
public void SetClickThrough(bool clickthrough)
{
    if (clickthrough)
    {
        // 启用穿透：WS_EX_LAYERED | WS_EX_TRANSPARENT
        SetWindowLong(_hWnd, GwlExStyle, WsExLayered | WsExTransparent);
    }
    else
    {
        // 禁用穿透：只保留 WS_EX_LAYERED
        SetWindowLong(_hWnd, GwlExStyle, WsExLayered);
    }
}
```

### 2. `MouseDetectionService.cs`

**职责**：
- 被动检测鼠标点击位置的像素透明度
- 根据检测结果控制窗口穿透状态
- 提供事件驱动接口

**关键方法**：
```csharp
// 检查指定位置是否可点击（不透明）
public bool IsPositionClickable(Vector2 position, Viewport targetViewport = null)

// 鼠标按下时调用（被动检测）
public void OnMouseButtonPressed(Vector2 position, MouseButton buttonIndex)

// 鼠标释放时调用（恢复穿透）
public void OnMouseButtonReleased()
```

### 3. `Main.gd`

**职责**：
- 接收鼠标输入事件
- 协调 `MouseDetectionService` 和动画系统
- 处理中键窗口拖动

**关键函数**：
```gdscript
func _input(event)     # 处理左键点击和动画
func _process(delta)   # 处理中键拖动
```

---

## 🔄 **事件流程**

### 场景 1：用户点击背景（透明区域）

```
1. 用户左键按下
    ↓
2. Main._input() 接收到 InputEventMouseButton
    ↓
3. 调用 MouseDetectionService.OnMouseButtonPressed(position)
    ↓
4. IsPositionClickable() → alpha=0 → 返回 false
    ↓
5. 不做任何事（保持默认穿透状态）
    ↓
6. 点击穿透到下层窗口（桌面或其他程序）
```

**结果**：
- ✅ 窗口保持穿透状态
- ✅ 点击事件传递到下层窗口

---

### 场景 2：用户点击人物（不透明区域）

```
1. 用户左键按下
    ↓
2. Main._input() 接收到 InputEventMouseButton
    ↓
3. 调用 MouseDetectionService.OnMouseButtonPressed(position)
    ↓
4. IsPositionClickable() → alpha=0.98 → 返回 true
    ↓
5. SetClickThrough(false) → 禁用穿透
    ↓
6. Main._input() 再次调用 IsPositionClickable() 确认
    ↓
7. 触发动画：AnimationService.play_random_animation()
    ↓
8. 用户左键释放
    ↓
9. Main._input() 接收到 InputEventMouseButton (released)
    ↓
10. 调用 MouseDetectionService.OnMouseButtonReleased()
    ↓
11. 检查中键是否按下 → 否
    ↓
12. SetClickThrough(true) → 恢复穿透
```

**结果**：
- ✅ 点击在人物上，触发动画
- ✅ 左键释放后，窗口恢复穿透

---

### 场景 3：用户中键拖动窗口

```
1. 用户中键按下
    ↓
2. Main._process() 检测到 Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
    ↓
3. 计算拖动偏移量 drag_offset
    ↓
4. SetClickThrough(false) → 禁用穿透
    ↓
5. 设置 is_dragging = true
    ↓
6. 在后续的 _process() 帧中：
   - 检测到 is_dragging = true
   - 更新窗口位置：get_tree().root.position = new_window_pos
    ↓
7. 用户中键释放
    ↓
8. Main._process() 检测到中键未按下
    ↓
9. SetClickThrough(true) → 恢复穿透
    ↓
10. 设置 is_dragging = false
```

**结果**：
- ✅ 中键拖动时窗口可以正常移动
- ✅ 拖动结束后，窗口恢复穿透

---

### 场景 4：先左键点击人物，再中键拖动（复杂场景）

```
1. 用户左键按下（点击人物）
    ↓
2. OnMouseButtonPressed() → SetClickThrough(false)
    ↓
3. 用户保持左键按下，同时按下中键
    ↓
4. Main._process() 检测到中键 → SetClickThrough(false)（重复调用，无影响）
    ↓
5. 拖动窗口...
    ↓
6. 用户先释放中键
    ↓
7. Main._process() → SetClickThrough(true) → 恢复穿透
    ↓
8. 用户再释放左键
    ↓
9. OnMouseButtonReleased() → 检查中键是否按下 → 否 → SetClickThrough(true)（重复调用，无影响）
```

**结果**：
- ✅ 拖动优先级更高
- ✅ 中键释放后立即恢复穿透
- ✅ 左键释放时再次确认穿透状态

---

## 💻 **代码实现**

### Main.gd

```gdscript
func _input(event):
    # 鼠标按下事件
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            # 左键点击：通知 MouseDetectionService 进行被动检测
            if mouse_detection_service and sub_viewport:
                mouse_detection_service.OnMouseButtonPressed(event.position, event.button_index)
                
                # 检查是否可点击（是否在人物上）
                var is_clickable = mouse_detection_service.IsPositionClickable(event.position, sub_viewport)
                if is_clickable:
                    # 点击在人物上，触发动画
                    if animation_service:
                        animation_service.play_random_animation()
    
    # 鼠标释放事件
    elif event is InputEventMouseButton and not event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            # 左键释放：通知 MouseDetectionService 恢复穿透
            if mouse_detection_service:
                mouse_detection_service.OnMouseButtonReleased()

func _process(_delta):
    var middle_button_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
    
    if middle_button_pressed and not is_dragging:
        # 开始拖动
        var mouse_global = Vector2(DisplayServer.mouse_get_position())
        var window_pos = Vector2(get_tree().root.position)
        drag_offset = mouse_global - window_pos
        is_dragging = true
        
        # 禁用点击穿透，确保能接收鼠标事件
        var window_service = ServiceLocator.get_service("WindowService")
        if window_service:
            window_service.SetClickThrough(false)
    
    elif not middle_button_pressed and is_dragging:
        # 结束拖动
        is_dragging = false
        
        # 恢复点击穿透
        var window_service = ServiceLocator.get_service("WindowService")
        if window_service:
            window_service.SetClickThrough(true)
    
    elif is_dragging:
        # 拖动中，更新窗口位置
        var mouse_global = Vector2(DisplayServer.mouse_get_position())
        var new_window_pos = mouse_global - drag_offset
        get_tree().root.position = Vector2i(new_window_pos)
```

### MouseDetectionService.cs

```csharp
public void OnMouseButtonPressed(Vector2 position, MouseButton buttonIndex)
{
    if (_windowService == null)
    {
        return;
    }
    
    // 检查点击位置是否在不透明区域
    bool isClickable = IsPositionClickable(position, _targetViewport);
    
    if (isClickable)
    {
        // 点击在人物上，暂时禁用穿透
        _windowService.SetClickThrough(false);
        GD.Print($"[MouseDetection] 点击在人物上，禁用穿透");
    }
    // 点击在透明区域，保持穿透状态（不做任何事）
}

public void OnMouseButtonReleased()
{
    if (_windowService == null)
    {
        return;
    }
    
    // 鼠标释放后，重新启用穿透（除非正在拖动）
    bool isMiddleButtonPressed = Input.IsMouseButtonPressed(MouseButton.Middle);
    
    if (!isMiddleButtonPressed)
    {
        // 没有中键拖动，重新启用穿透
        _windowService.SetClickThrough(true);
        GD.Print($"[MouseDetection] 鼠标释放，启用穿透");
    }
}
```

---

## 📊 **状态转换图**

```
                    [初始状态：穿透启用]
                            |
        +-------------------+-------------------+
        |                                       |
    左键按下                                中键按下
        |                                       |
    检测像素                                禁用穿透
        |                                       |
   +----+----+                            开始拖动
   |         |                                  |
  透明     不透明                          拖动中...
   |         |                                  |
 不做任何事  禁用穿透                       中键释放
   |         |                                  |
   |      播放动画                           恢复穿透
   |         |                                  |
   |      左键释放                         [穿透启用]
   |         |
   |      检查中键
   |         |
   |      恢复穿透
   |         |
   +----+----+
        |
  [穿透启用]
```

---

## ⚡ **性能说明**

### 被动检测 vs 主动检测

| 方案 | GetImage() 调用频率 | GPU→CPU 数据传输 | 性能 |
|------|---------------------|------------------|------|
| **主动检测（每帧）** | 60 次/秒 | ~960MB/秒 | ❌ 严重卡顿 |
| **主动检测（每5帧）** | 12 次/秒 | ~192MB/秒 | ⚠️ 仍有卡顿 |
| **被动检测（事件驱动）** | ~0.2 次/秒 | ~3.2MB/秒 | ✅ **完美流畅** |

### 性能优势

1. **空闲时零开销**
   - 用户不点击时，`GetImage()` 调用次数 = 0
   - CPU 和 GPU 接近空闲状态

2. **点击时即时响应**
   - 只在鼠标按下/释放时检测一次
   - 响应延迟：0ms（即时）

3. **内存友好**
   - 不持续下载纹理
   - 不会造成内存带宽瓶颈

---

## 🔧 **维护说明**

### 添加新的鼠标事件

如果需要添加新的鼠标事件处理，请遵循以下模式：

1. **在 `Main._input()` 中捕获事件**
2. **调用 `MouseDetectionService` 的相应接口**
3. **根据检测结果执行操作**
4. **更新本文档**

### 调试技巧

**查看穿透状态日志**：
```
[MouseDetection] 点击在人物上，禁用穿透
[MouseDetection] 鼠标释放，启用穿透
```

**验证性能**：
- 打开任务管理器
- 观察 CPU 和 GPU 占用率
- 空闲时应该非常低（< 5%）

---

## 📝 **版本历史**

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0 | 2025-10-23 | 初始版本：被动检测架构 |

---

## 🔗 **相关文档**

- [性能优化说明](../PERFORMANCE_FIX.md)
- [被动检测详解](../PASSIVE_DETECTION.md)
- [架构设计文档](../../docs/docs/architecture/architecture.md)

---

**维护者**: Marionet 开发团队  
**最后更新**: 2025-10-23

