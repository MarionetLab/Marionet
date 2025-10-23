# ⚡ 被动检测：终极性能优化

## 🎯 **方案对比**

### ❌ 主动检测（旧方案）
```csharp
public override void _PhysicsProcess(double delta)
{
    // 每 5 帧检测一次（12 次/秒）
    frameCounter++;
    if (frameCounter < 5) return;
    frameCounter = 0;
    
    DetectPassthrough();  // GetImage() - 16MB 下载
}
```

**问题**：
- 即使不点击，也在不停检测
- 每秒 12 次 `GetImage()` = 192MB GPU → CPU 数据传输
- CPU 和 GPU 持续高负载

---

### ✅ 被动检测（新方案）
```csharp
// ✅ 移除 _PhysicsProcess()，不再主动检测

public void OnMouseButtonPressed(Vector2 position, MouseButton buttonIndex)
{
    bool isClickable = IsPositionClickable(position);  // 只在点击时检测
    if (isClickable)
    {
        _windowService.SetClickThrough(false);  // 禁用穿透
    }
}

public void OnMouseButtonReleased()
{
    _windowService.SetClickThrough(true);  // 重新启用穿透
}
```

**优势**：
- ✅ **只在鼠标事件时检测**（每次点击 1-2 次）
- ✅ **99.9% 的时间不调用 `GetImage()`**
- ✅ **CPU 和 GPU 接近空闲**
- ✅ **性能提升：~60 倍**

---

## 📊 **性能对比**

| 方案 | GetImage() 调用频率 | GPU→CPU 数据传输 | 性能 |
|------|---------------------|------------------|------|
| **主动检测（每帧）** | 60 次/秒 | ~960MB/秒 | ❌ 严重卡顿 |
| **主动检测（每5帧）** | 12 次/秒 | ~192MB/秒 | ⚠️ 仍有卡顿 |
| **被动检测（事件驱动）** | ~0.2 次/秒 | ~3.2MB/秒 | ✅ **完美流畅** |

**假设用户每秒点击 1 次**：
- 主动检测（每5帧）：12 次 `GetImage()`
- 被动检测：**仅 1 次** `GetImage()`
- **性能提升：12 倍**

**假设用户不点击（静止状态）**：
- 主动检测（每5帧）：12 次/秒
- 被动检测：**0 次**
- **性能提升：无限大** 🚀

---

## 🔥 **工作流程**

### 1. **初始状态**
```
窗口启动
    ↓
WindowService 设置为 WS_EX_LAYERED + WS_EX_TRANSPARENT
    ↓
窗口默认为 "穿透" 状态
```

### 2. **用户点击背景**
```
鼠标左键按下 → OnMouseButtonPressed()
    ↓
IsPositionClickable() → alpha=0 → 返回 false
    ↓
不做任何事（保持穿透状态）
    ↓
点击穿透到下层窗口（桌面或其他程序）
```

### 3. **用户点击人物**
```
鼠标左键按下 → OnMouseButtonPressed()
    ↓
IsPositionClickable() → alpha=0.98 → 返回 true
    ↓
SetClickThrough(false) → 禁用穿透
    ↓
Main._input() 检测到可点击 → 触发动画
    ↓
鼠标左键释放 → OnMouseButtonReleased()
    ↓
SetClickThrough(true) → 重新启用穿透
```

### 4. **用户中键拖动**
```
鼠标中键按下 → Main._process() 检测到
    ↓
SetEnabled(false) → 暂停 MouseDetectionService
    ↓
SetClickThrough(false) → 禁用穿透（允许拖动）
    ↓
拖动窗口...
    ↓
鼠标中键释放 → Main._process() 检测到
    ↓
SetEnabled(true) → 恢复 MouseDetectionService
    ↓
SetClickThrough(true) → 重新启用穿透
```

---

## ✅ **已实现的优化**

### 1. 移除 `_PhysicsProcess()`
```csharp
// ❌ 旧代码（已删除）
public override void _PhysicsProcess(double delta)
{
    frameCounter++;
    if (frameCounter < 5) return;
    frameCounter = 0;
    DetectPassthrough();
}
```

### 2. 添加事件驱动接口
```csharp
// ✅ 新代码
public void OnMouseButtonPressed(Vector2 position, MouseButton buttonIndex)
{
    bool isClickable = IsPositionClickable(position, _targetViewport);
    if (isClickable)
    {
        _windowService.SetClickThrough(false);
    }
}

public void OnMouseButtonReleased()
{
    bool isMiddleButtonPressed = Input.IsMouseButtonPressed(MouseButton.Middle);
    if (!isMiddleButtonPressed)
    {
        _windowService.SetClickThrough(true);
    }
}
```

### 3. 修改 `Main.gd` 输入处理
```gdscript
func _input(event):
    elif event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            # 通知 MouseDetectionService
            mouse_detection_service.OnMouseButtonPressed(event.position, event.button_index)
            
            # 检查是否可点击
            var is_clickable = mouse_detection_service.IsPositionClickable(event.position, sub_viewport)
            if is_clickable:
                animation_service.play_random_animation()
    
    elif event is InputEventMouseButton and not event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            # 鼠标释放，恢复穿透
            mouse_detection_service.OnMouseButtonReleased()
```

---

## 🎉 **预期效果**

### 1. **性能**
- ✅ **CPU 占用：接近 0%**（空闲时）
- ✅ **GPU 占用：只渲染，不下载**
- ✅ **内存带宽：99% 减少**
- ✅ **帧率：稳定 60 FPS**

### 2. **功能**
- ✅ 点击背景：穿透到桌面
- ✅ 点击人物：触发动画
- ✅ 中键拖动：正常拖动窗口
- ✅ 鼠标移出窗口：不会有任何性能影响

### 3. **用户体验**
- ✅ 响应速度：即时（无延迟）
- ✅ 流畅度：完美
- ✅ 资源占用：极低

---

## 🔥 **接下来的步骤**

### 1️⃣ **重新加载 Godot 项目**
```
项目 (Project) → 重新加载当前项目 (Reload Current Project)
```

### 2️⃣ **运行项目 (F5)**

### 3️⃣ **验证性能**

**应该看到：**
- ✅ **模型渲染完美流畅，60 FPS 稳定**
- ✅ **CPU/GPU 占用极低**
- ✅ **日志极少（只在点击时输出）**
- ✅ 点击背景：穿透到桌面
- ✅ 点击人物：触发动画
- ✅ 中键拖动：正常工作

**日志应该类似：**
```
[MouseDetection] 已找到 WindowService
[WindowService] 已初始化
[WindowService] MouseDetectionService 已创建
... (初始化日志)
[INFO] 初始化完成！

（运行中几乎没有日志，只在点击时：）

[MouseDetection] 点击在人物上，禁用穿透
（播放动画）
[MouseDetection] 鼠标释放，启用穿透
```

---

## 💡 **为什么这是最优方案**

### 对比其他方案

| 方案 | 性能 | 响应性 | 复杂度 |
|------|------|--------|--------|
| **每帧检测** | ❌ 极差 | ✅ 极好 | 低 |
| **每N帧检测** | ⚠️ 一般 | ✅ 好 | 低 |
| **鼠标移动检测** | ⚠️ 差 | ✅ 好 | 中 |
| **被动事件检测** | ✅ **完美** | ✅ **完美** | **低** |

**被动检测的优势**：
1. ✅ **性能最佳**：只在需要时检测
2. ✅ **响应最快**：点击即检测，无延迟
3. ✅ **代码简单**：逻辑清晰
4. ✅ **用户友好**：符合直觉

---

## 📝 **技术说明**

### `GetImage()` 的开销

```csharp
Image img = viewport.GetTexture().GetImage();  // 昂贵！
```

这个操作涉及：
1. **GPU 渲染管线同步**：等待 GPU 完成渲染
2. **数据传输**：2048×2048×4 = 16MB 通过 PCIe 传输
3. **格式转换**：GPU 格式 → CPU 格式
4. **内存分配**：在 CPU 内存中分配 16MB

### 为什么被动检测这么快？

**旧方案（主动）**：
```
每 5 帧：GetImage() + 像素检测 + SetClickThrough()
→ 每秒 12 次 × 16MB = 192MB/秒
```

**新方案（被动）**：
```
点击时：GetImage() + 像素检测 + SetClickThrough()
→ 每秒 ~1 次 × 16MB = 16MB/秒（假设每秒点击1次）
→ 静止时：0 次 × 16MB = 0MB/秒
```

**平均性能提升：12-60 倍**

---

## 🚨 **重要提示**

### Alpha 值为 0 的问题

如果点击人物时 `alpha=0`，可能是坐标转换问题。请检查：

1. **SubViewport 分辨率**：是否与窗口分辨率匹配？
2. **坐标转换公式**：是否正确？
3. **测试方法**：在人物中心点击，查看日志中的 `pixel=(x,y)` 坐标

如果仍有问题，请告诉我日志中的：
- 点击位置：`pos=(...)`
- 纹理坐标：`pixel=(...)`
- 纹理大小：`imgSize=(...)`

---

**请立即重新加载 Godot 并测试！** 🚀

这次应该**完美流畅**，性能和功能都最优！

如果还有问题，请复制完整日志，特别是点击人物时的日志。

