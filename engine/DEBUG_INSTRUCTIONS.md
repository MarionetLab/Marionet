# 🔍 调试指南：窗口穿透问题

> 当前状态：已添加大量调试日志

---

## 🎯 **测试步骤**

### 1. 重新打开 Godot

1. **完全关闭 Godot**
2. **重新打开 Godot**
3. **打开 engine 项目**
4. **运行项目 (F5)**

### 2. 观察控制台输出

**应该看到的日志**：

#### 启动日志
```
[WindowService] 已初始化
[WindowService] 窗口句柄已获取，窗口已设置为 layered + 点击穿透
[MouseDetection] 已找到 WindowService
[MouseDetection] 穿透检测已启用
[MouseDetection] 已找到 SubViewport，将使用它进行像素检测
```

#### 运行时日志（每60帧）
```
[MouseDetection] _PhysicsProcess - isEnabled=true, _windowService=OK, _targetViewport=OK
```

#### 坐标检测日志（每30帧）
```
[MouseDetection] DetectPassthrough - pos=(450,450), tex=(1024,1024), size=(2048,2048), window=(900,900), alpha=0.98, clickable=true
```

#### 状态变化日志
```
[MouseDetection] ⚠️ 状态变化: clickable=true, shouldPassthrough=false
[MouseDetection] ⚠️ 正在调用 WindowService.SetClickThrough(false)
[MouseDetection] ✅ 窗口穿透状态已更新: 禁用（可点击区域）
```

---

## 🐛 **诊断清单**

### 问题 A：没有任何 MouseDetection 日志

**可能原因**：
- MouseDetectionService 没有加载
- 自动加载配置错误

**检查**：
- 查看是否有 `[MouseDetection] 已找到 WindowService` 日志
- 如果没有，说明 MouseDetectionService 没有启动

### 问题 B：有日志但 _targetViewport=NULL

**可能原因**：
- SubViewport 没有找到
- FindSubViewport() 失败

**检查**：
- 应该看到 `[MouseDetection] 已找到 SubViewport` 日志
- 如果看到 `[MouseDetection] 无法找到 SubViewport`，说明场景结构问题

### 问题 C：alpha 值总是 0.00

**可能原因**：
- 坐标转换仍然有问题
- SubViewport 纹理是空的或透明的

**检查**：
- 查看日志中的 `tex=` 坐标
- 查看 `size=` 和 `window=` 大小
- 查看 `alpha=` 值

### 问题 D：状态没有变化

**可能原因**：
- lastClickableState 初始化错误
- SetClickability() 没有被调用

**检查**：
- 应该看到 `[MouseDetection] ⚠️ 状态变化` 日志
- 如果只看到 `状态未变`，说明检测结果一直相同

---

## 📊 **预期的日志流程**

### 鼠标从透明区域移到人物上

```
1. 初始状态（透明区域）
[MouseDetection] alpha=0.00, clickable=false
[MouseDetection] 状态未变: lastClickableState=false

2. 移动到人物上
[MouseDetection] alpha=0.98, clickable=true
[MouseDetection] ⚠️ 状态变化: clickable=true, shouldPassthrough=false
[MouseDetection] ⚠️ 正在调用 WindowService.SetClickThrough(false)
[MouseDetection] ✅ 窗口穿透状态已更新: 禁用（可点击区域）

3. 保持在人物上
[MouseDetection] alpha=0.98, clickable=true
[MouseDetection] 状态未变: lastClickableState=true
```

### 鼠标从人物移到透明区域

```
1. 在人物上
[MouseDetection] alpha=0.98, clickable=true
[MouseDetection] 状态未变: lastClickableState=true

2. 移动到透明区域
[MouseDetection] alpha=0.00, clickable=false
[MouseDetection] ⚠️ 状态变化: clickable=false, shouldPassthrough=true
[MouseDetection] ⚠️ 正在调用 WindowService.SetClickThrough(true)
[MouseDetection] ✅ 窗口穿透状态已更新: 启用（透明区域）

3. 保持在透明区域
[MouseDetection] alpha=0.00, clickable=false
[MouseDetection] 状态未变: lastClickableState=false
```

---

## ❓ **请报告以下信息**

运行项目后，请告诉我：

### 1. 启动日志
```
是否看到了：
[ ] [WindowService] 已初始化
[ ] [WindowService] 窗口已设置为 layered + 点击穿透
[ ] [MouseDetection] 已找到 WindowService
[ ] [MouseDetection] 已找到 SubViewport
```

### 2. 运行时日志
```
是否看到：
[ ] _PhysicsProcess 日志
[ ] isEnabled=true
[ ] _windowService=OK
[ ] _targetViewport=OK
```

### 3. 坐标检测日志
```
请复制一段完整的检测日志，例如：
[MouseDetection] DetectPassthrough - pos=(...), tex=(...), alpha=..., clickable=...
```

### 4. 状态变化日志
```
移动鼠标时是否看到：
[ ] ⚠️ 状态变化 日志
[ ] ⚠️ 正在调用 WindowService.SetClickThrough 日志
[ ] ✅ 窗口穿透状态已更新 日志
```

### 5. 实际行为
```
[ ] 鼠标在人物上时可以拖动
[ ] 鼠标在人物上时可以点击
[ ] 鼠标在背景上时穿透
```

---

## 🔧 **如果看不到任何日志**

### 步骤 1：检查自动加载
打开 `project.godot`，确认有：
```ini
[autoload]
MouseDetectionService="*res://renderer/services/Window/MouseDetection.cs"
```

### 步骤 2：检查编译
确认没有编译错误：
```
底部 "输出" 标签 → 查找 "error" 或 "CS"
```

### 步骤 3：检查场景
确认场景结构：
```
Main
└── Sprite2D
    └── SubViewport
        └── GDCubismUserModel
```

---

**请运行测试并复制所有相关日志！** 🔍

