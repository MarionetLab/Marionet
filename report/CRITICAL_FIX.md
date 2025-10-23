# 🚨 关键修复：MouseDetectionService 加载失败

## 问题诊断

错误信息：
```
E 0:00:01:380   start: Failed to instantiate an autoload, script 'res://renderer/services/Window/MouseDetection.cs' does not inherit from 'Node'.
```

**根本原因**：Godot 的 C# 程序集缓存没有正确更新，导致 MouseDetectionService 没有被加载。

**结果**：
- ✅ 窗口穿透功能的代码是正确的
- ❌ 但是 MouseDetectionService 根本没有运行
- ❌ 所以窗口一直保持穿透状态

---

## ✅ 已执行的修复

### 1. 清理了 Godot 缓存
```powershell
Remove-Item -Recurse -Force ".godot/mono"
```

### 2. 重新编译了项目
```powershell
dotnet clean renderer.csproj
dotnet build renderer.csproj -c Debug
```

---

## 🎯 接下来的步骤

### 步骤 1：重新打开 Godot

1. **完全关闭 Godot**（如果还在运行）
2. **重新打开 Godot**
3. **打开 engine 项目**
4. **Godot 会自动重新构建 C# 程序集**

### 步骤 2：等待构建完成

在 Godot 底部的 "输出" 或 "MSBuild" 标签中，应该看到：
```
Building solution...
Build succeeded.
```

### 步骤 3：运行项目

按 **F5** 运行项目。

### 步骤 4：验证修复

**如果修复成功，控制台应该会看到：**

#### 启动日志
```
[WindowService] 已初始化
[WindowService] 窗口句柄已获取，窗口已设置为 layered + 点击穿透
[MouseDetection] 已找到 WindowService
[MouseDetection] 穿透检测已启用，将根据像素透明度动态调整窗口穿透状态
[MouseDetection] 已找到 SubViewport，将使用它进行像素检测
```

**如果还是看不到这些日志** → 说明自动加载配置有问题，请告诉我。

#### 运行时日志（每60帧）
```
[MouseDetection] _PhysicsProcess - isEnabled=true, _windowService=OK, _targetViewport=OK
```

#### 坐标检测日志（每30帧，移动鼠标时）
```
[MouseDetection] DetectPassthrough - pos=(450,450), tex=(1024,1024), size=(2048,2048), window=(900,900), alpha=0.98, clickable=true
```

#### 状态变化日志（从背景移到人物时）
```
[MouseDetection] ⚠️ 状态变化: clickable=true, shouldPassthrough=false
[MouseDetection] ⚠️ 正在调用 WindowService.SetClickThrough(false)
[MouseDetection] ✅ 窗口穿透状态已更新: 禁用（可点击区域）
```

---

## 🎯 预期的正确行为

### ✅ 鼠标在人物上时
- **可以左键点击触发动画**
- **可以中键拖动窗口**
- **控制台日志：** `alpha=0.98, clickable=true`
- **控制台日志：** `窗口穿透状态已更新: 禁用（可点击区域）`

### ✅ 鼠标在背景上时
- **点击会穿透到桌面下的窗口**
- **无法拖动窗口**
- **控制台日志：** `alpha=0.00, clickable=false`
- **控制台日志：** `窗口穿透状态已更新: 启用（透明区域）`

---

## 🐛 如果还是不行

### 检查清单

#### 1. 检查自动加载配置
打开 `project.godot`，确认有：
```ini
[autoload]
ServiceLocator="*res://core/ServiceLocator.gd"
EngineConstants="*res://core/Constants.gd"
WindowService="*res://renderer/services/Window/WindowService.cs"
MouseDetectionService="*res://renderer/services/Window/MouseDetection.cs"
```

#### 2. 检查构建输出
在 Godot 底部 "MSBuild" 标签中查找错误：
- 如果看到 `error CS...` → 编译错误
- 如果看到 `Build succeeded` → 编译成功

#### 3. 检查场景结构
确认 Main 场景中有：
```
Main
└── Sprite2D
    └── SubViewport
        └── GDCubismUserModel
```

#### 4. 查看完整的错误日志
在 Godot 控制台中，查找所有 `[ERROR]` 或 `E 0:00:xx:xxx` 开头的行。

---

## 📝 重要提示

**为什么之前没有看到日志？**

因为 `MouseDetectionService` 根本没有被加载！Godot 在启动时就报错了：
```
Failed to instantiate an autoload, script 'res://renderer/services/Window/MouseDetection.cs' does not inherit from 'Node'.
```

这个错误导致：
- ❌ MouseDetectionService 没有运行
- ❌ 没有任何日志输出
- ❌ 窗口穿透功能完全失效
- ❌ 窗口一直保持 `WS_EX_TRANSPARENT` 状态（在 WindowService 初始化时设置的）

**现在应该可以了！** ✅

---

## 📊 日志示例（正确运行时）

```
========== 启动 ==========
[WindowService] 已初始化
[WindowService] 窗口句柄已获取，窗口已设置为 layered + 点击穿透
[MouseDetection] 已找到 WindowService
[MouseDetection] 穿透检测已启用
[MouseDetection] 已找到 SubViewport

========== 运行中（每60帧） ==========
[MouseDetection] _PhysicsProcess - isEnabled=true, _windowService=OK, _targetViewport=OK

========== 鼠标移动到人物上 ==========
[MouseDetection] DetectPassthrough - pos=(450,450), tex=(1024,1024), alpha=0.98, clickable=true
[MouseDetection] ⚠️ 状态变化: clickable=true, shouldPassthrough=false
[MouseDetection] ⚠️ 正在调用 WindowService.SetClickThrough(false)
[MouseDetection] ✅ 窗口穿透状态已更新: 禁用（可点击区域）

========== 鼠标移动到背景 ==========
[MouseDetection] DetectPassthrough - pos=(50,50), tex=(102,102), alpha=0.00, clickable=false
[MouseDetection] ⚠️ 状态变化: clickable=false, shouldPassthrough=true
[MouseDetection] ⚠️ 正在调用 WindowService.SetClickThrough(true)
[MouseDetection] ✅ 窗口穿透状态已更新: 启用（透明区域）
```

---

**请重新打开 Godot，运行项目，并复制所有控制台日志！** 🔍

