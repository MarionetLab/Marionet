# ⚡ 混合检测：最终方案

> **版本**: 1.1  
> **更新时间**: 2025-10-23  
> **架构**: 混合检测（轻量级主动 + 被动）

---

## 🎯 **问题回顾**

### 纯被动检测的问题

在纯被动检测模式下：
```
用户鼠标移到人物上（不点击）
    ↓
窗口仍然是 "穿透" 状态
    ↓
用户按下中键拖动
    ↓
中键事件被穿透到下层窗口 ❌
    ↓
Godot 收不到中键事件 ❌
    ↓
无法拖动窗口 ❌
```

**根本原因**：在穿透状态下，Windows 会将所有鼠标事件穿透到下层窗口，Godot 无法接收。

---

## 💡 **混合检测方案**

### 设计思路

**结合主动检测和被动检测的优点**：
- ✅ **轻量级主动检测**：每 10 帧检测一次鼠标是否在人物上
- ✅ **只改变穿透状态**：不频繁调用 Windows API，只在状态改变时调用
- ✅ **接收中键事件**：鼠标在人物上时禁用穿透，可以接收中键拖动
- ✅ **背景穿透**：鼠标不在人物上时启用穿透，点击穿透到桌面

### 核心逻辑

```csharp
private bool _lastHoverState = false;  // 上次鼠标悬停状态

public override void _PhysicsProcess(double delta)
{
    // 每 10 帧检测一次（约 6 次/秒）
    frameCounter++;
    if (frameCounter < 10) return;
    frameCounter = 0;
    
    // 检查鼠标是否在人物上
    bool isOnCharacter = IsPositionClickable(mousePosition, _targetViewport);
    
    // 只在状态改变时调用 Windows API
    if (isOnCharacter != _lastHoverState)
    {
        _lastHoverState = isOnCharacter;
        
        if (isOnCharacter)
        {
            // 鼠标移到人物上，禁用穿透
            _windowService.SetClickThrough(false);
        }
        else
        {
            // 鼠标移出人物，启用穿透
            _windowService.SetClickThrough(true);
        }
    }
}
```

---

## 📊 **性能分析**

### 主动检测频率对比

| 方案 | GetImage() 频率 | Windows API 调用 | 性能 |
|------|-----------------|------------------|------|
| **主动（每帧）** | 60 次/秒 | ~60 次/秒 | ❌ 严重卡顿 |
| **主动（每5帧）** | 12 次/秒 | ~12 次/秒 | ⚠️ 仍有卡顿 |
| **纯被动** | ~0.2 次/秒 | ~0.2 次/秒 | ✅ 流畅，但无法拖动 |
| **混合（每10帧）** | **6 次/秒** | **~1 次/秒** | ✅ **流畅 + 可拖动** |

### 为什么混合方案性能好？

#### 1. GetImage() 调用频率低
```
60 FPS → 每 10 帧检测一次 = 6 次/秒
对于 2048x2048 纹理：6 × 16MB = 96MB/秒
```
**vs 纯被动**: ~3MB/秒（假设每秒点击 1 次）  
**vs 主动（每5帧）**: 192MB/秒

**结论**: 比主动（每5帧）快 2 倍，比纯被动慢，但仍然可接受

#### 2. Windows API 调用极少
```
只在鼠标 "进入/离开" 人物时调用
平均每秒 ~1 次（用户移动鼠标频率）
```

**vs 主动（每5帧）**: 12 次/秒  
**结论**: 减少 12 倍的 API 调用

#### 3. 状态变化检测
```csharp
if (isOnCharacter != _lastHoverState)  // 只在状态改变时
{
    _windowService.SetClickThrough(...);  // 才调用 API
}
```

**效果**: 鼠标静止时，完全不调用 Windows API

---

## 🔄 **事件流程**

### 场景 1：鼠标从背景移到人物上

```
1. 鼠标在背景上
   - _lastHoverState = false
   - 窗口穿透启用
    ↓
2. _PhysicsProcess() 检测（第 10 帧）
   - IsPositionClickable() → false
   - isOnCharacter == _lastHoverState → 不变化
    ↓
3. 用户移动鼠标到人物上
    ↓
4. _PhysicsProcess() 检测（第 10 帧）
   - IsPositionClickable() → true
   - isOnCharacter != _lastHoverState → 状态改变！
   - SetClickThrough(false) → 禁用穿透
   - _lastHoverState = true
   - 输出: "[MouseDetection] 鼠标移到人物上，禁用穿透"
    ↓
5. 现在用户可以：
   - 左键点击 → 触发动画 ✅
   - 中键拖动 → 拖动窗口 ✅
```

---

### 场景 2：鼠标在人物上，中键拖动

```
1. 鼠标在人物上
   - _lastHoverState = true
   - 窗口穿透禁用
    ↓
2. 用户按下中键
   - Main._process() 检测到 MOUSE_BUTTON_MIDDLE
   - SetEnabled(false) → 暂停 MouseDetectionService
   - SetClickThrough(false) → 确保穿透禁用
   - is_dragging = true
    ↓
3. 拖动中...
   - _process() 持续更新窗口位置
   - MouseDetectionService 暂停，不检测
    ↓
4. 用户释放中键
   - is_dragging = false
   - SetEnabled(true) → 恢复 MouseDetectionService
   - MouseDetectionService 在下一次 _PhysicsProcess() 时自动调整穿透状态
    ↓
5. 如果鼠标仍在人物上：
   - IsPositionClickable() → true
   - SetClickThrough(false)（保持不穿透）
   
   如果鼠标已移出人物：
   - IsPositionClickable() → false
   - SetClickThrough(true)（恢复穿透）
```

---

### 场景 3：鼠标从人物移出到背景

```
1. 鼠标在人物上
   - _lastHoverState = true
   - 窗口穿透禁用
    ↓
2. 用户移动鼠标到背景
    ↓
3. _PhysicsProcess() 检测（第 10 帧）
   - IsPositionClickable() → false
   - isOnCharacter != _lastHoverState → 状态改变！
   - SetClickThrough(true) → 启用穿透
   - _lastHoverState = false
   - 输出: "[MouseDetection] 鼠标移出人物，启用穿透"
    ↓
4. 现在：
   - 点击背景 → 穿透到桌面 ✅
   - 中键拖动 → 无效（事件被穿透）
```

---

## 💻 **代码实现**

### MouseDetectionService.cs

```csharp
private bool _lastHoverState = false;  // 上次鼠标悬停状态

public override void _PhysicsProcess(double delta)
{
    if (!isEnabled || _windowService == null || GetViewport() == null)
    {
        return;
    }
    
    // 性能优化：每 10 帧检测一次（约 6 次/秒）
    frameCounter++;
    if (frameCounter < 10)
    {
        return;
    }
    frameCounter = 0;
    
    // 获取鼠标位置
    Vector2 mousePosition = GetViewport().GetMousePosition();
    
    // 检查是否在人物上
    bool isOnCharacter = IsPositionClickable(mousePosition, _targetViewport);
    
    // 只在状态改变时调用 Windows API
    if (isOnCharacter != _lastHoverState)
    {
        _lastHoverState = isOnCharacter;
        
        if (isOnCharacter)
        {
            // 鼠标移到人物上，禁用穿透
            _windowService.SetClickThrough(false);
            GD.Print($"[MouseDetection] 鼠标移到人物上，禁用穿透");
        }
        else
        {
            // 鼠标移出人物，启用穿透
            _windowService.SetClickThrough(true);
            GD.Print($"[MouseDetection] 鼠标移出人物，启用穿透");
        }
    }
}
```

### Main.gd

```gdscript
func _process(_delta):
    var middle_button_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
    
    if middle_button_pressed and not is_dragging:
        # 开始拖动
        is_dragging = true
        
        # 暂停 MouseDetectionService（避免状态冲突）
        if mouse_detection_service:
            mouse_detection_service.SetEnabled(false)
        
        # 确保窗口不穿透
        var window_service = ServiceLocator.get_service("WindowService")
        if window_service:
            window_service.SetClickThrough(false)
    
    elif not middle_button_pressed and is_dragging:
        # 结束拖动
        is_dragging = false
        
        # 恢复 MouseDetectionService
        if mouse_detection_service:
            mouse_detection_service.SetEnabled(true)
        
        # MouseDetectionService 会在下一帧自动调整穿透状态
    
    elif is_dragging:
        # 拖动中，更新窗口位置
        var mouse_global = Vector2(DisplayServer.mouse_get_position())
        var new_window_pos = mouse_global - drag_offset
        get_tree().root.position = Vector2i(new_window_pos)

func _input(event):
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        # 左键点击：检查是否可点击
        if mouse_detection_service and sub_viewport:
            var is_clickable = mouse_detection_service.IsPositionClickable(event.position, sub_viewport)
            if is_clickable:
                if animation_service:
                    animation_service.play_random_animation()
```

---

## 🎉 **优势总结**

### vs 纯被动检测

| 特性 | 纯被动 | 混合 |
|------|--------|------|
| **性能** | ✅ 最优 | ✅ 优秀 |
| **中键拖动** | ❌ 不支持 | ✅ 支持 |
| **背景穿透** | ✅ 支持 | ✅ 支持 |
| **点击动画** | ✅ 支持 | ✅ 支持 |

### vs 主动检测（每5帧）

| 特性 | 主动（每5帧） | 混合（每10帧） |
|------|---------------|----------------|
| **GetImage() 频率** | 12 次/秒 | 6 次/秒（2 倍优化）|
| **Windows API 频率** | 12 次/秒 | ~1 次/秒（12 倍优化）|
| **响应延迟** | ~83ms | ~166ms（可接受）|
| **中键拖动** | ✅ 支持 | ✅ 支持 |

---

## 📝 **调优建议**

### 如果性能仍有问题

**降低检测频率**：
```csharp
if (frameCounter < 15)  // 每 15 帧（4 次/秒）
```

**减小纹理分辨率**：
```gdscript
sub_viewport.size = Vector2i(1024, 1024)  # 而不是 2048x2048
```

### 如果响应太慢

**提高检测频率**：
```csharp
if (frameCounter < 5)  // 每 5 帧（12 次/秒）
```

---

## 🔥 **接下来的步骤**

### 1️⃣ 重新加载 Godot 项目

### 2️⃣ 运行项目 (F5)

### 3️⃣ 测试功能

**测试 A：性能**
- [ ] 模型渲染流畅，60 FPS 稳定
- [ ] CPU/GPU 占用适中（比纯被动略高，但仍然低）

**测试 B：鼠标悬停**
- [ ] 鼠标移到人物上 → 日志：`鼠标移到人物上，禁用穿透`
- [ ] 鼠标移出人物 → 日志：`鼠标移出人物，启用穿透`

**测试 C：中键拖动**
- [ ] 鼠标在人物上，按住中键 → 可以拖动窗口 ✅
- [ ] 拖动流畅，无卡顿
- [ ] 释放中键 → 窗口停止拖动

**测试 D：背景穿透**
- [ ] 鼠标在背景上，点击 → 穿透到桌面 ✅

**测试 E：点击动画**
- [ ] 鼠标在人物上，左键点击 → 触发动画 ✅

---

## 💡 **FAQ**

### Q: 为什么不用更低的频率（如每 20 帧）？
**A**: 响应延迟会太高（~333ms），用户会感觉到明显的延迟。

### Q: 为什么不在鼠标移动事件中检测？
**A**: 鼠标移动事件在穿透状态下可能收不到，而且频率太高（可能每帧都触发）。

### Q: 能否只在鼠标移动时才检测？
**A**: 理论上可以，但实现复杂，且性能提升有限。

---

**维护者**: Marionet 开发团队  
**最后更新**: 2025-10-23

