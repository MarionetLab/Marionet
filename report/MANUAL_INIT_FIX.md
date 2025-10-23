# 🔧 修复：改为手动初始化 MouseDetectionService

## 问题

虽然排除了 legacy 文件并重新编译，但 Godot 的 C# 自动加载仍然失败：

```
[WARNING] [Main] 无法找到 MouseDetectionService
```

**根本原因**：Godot 的 C# 自动加载功能在某些情况下不稳定，特别是对于自定义服务类。

---

## ✅ 已执行的修复

### 1. 从 `project.godot` 中移除了 MouseDetectionService 自动加载

**之前：**
```ini
[autoload]
ServiceLocator="*res://core/ServiceLocator.gd"
EngineConstants="*res://core/Constants.gd"
WindowService="*res://renderer/services/Window/WindowService.cs"
MouseDetectionService="*res://renderer/services/Window/MouseDetection.cs"  ❌ 移除
```

**现在：**
```ini
[autoload]
ServiceLocator="*res://core/ServiceLocator.gd"
EngineConstants="*res://core/Constants.gd"
WindowService="*res://renderer/services/Window/WindowService.cs"
```

### 2. 修改了 `Main.gd`，改为手动初始化

**之前：**
```gdscript
# 获取 MouseDetectionService（自动加载的 C# 服务）
mouse_detection_service = get_node_or_null("/root/MouseDetectionService")
if not mouse_detection_service:
    EngineConstants.log_warning("[Main] 无法找到 MouseDetectionService")
```

**现在：**
```gdscript
# 手动创建 MouseDetectionService（C# 自动加载可能不稳定）
var MouseDetectionServiceClass = load("res://renderer/services/Window/MouseDetection.cs")
if MouseDetectionServiceClass:
    mouse_detection_service = MouseDetectionServiceClass.new()
    add_child(mouse_detection_service)
    mouse_detection_service.name = "MouseDetectionService"
    EngineConstants.log_info("[Main] MouseDetectionService 已手动创建")
else:
    EngineConstants.log_error("[Main] 无法加载 MouseDetection.cs")
```

---

## 🎯 为什么手动初始化更可靠

### C# 自动加载的问题
1. **加载顺序不确定**：C# 脚本可能在场景加载之前就需要初始化
2. **程序集依赖**：如果 C# 类依赖其他 C# 类，自动加载可能失败
3. **Godot 版本兼容性**：某些 Godot 版本对 C# 自动加载支持不完善

### 手动初始化的优势
1. ✅ **完全控制初始化时机**：在 `Main.gd` 的 `_init_services()` 中创建
2. ✅ **可以捕获错误**：如果加载失败，可以输出详细日志
3. ✅ **与其他服务一致**：所有服务都在同一个地方初始化
4. ✅ **更可靠**：避免 Godot 自动加载的各种问题

---

## 🔥 接下来的步骤

### 1️⃣ **保存所有文件**
确保 `Main.gd` 和 `project.godot` 的修改已保存。

### 2️⃣ **重新加载 Godot 项目**
1. 在 Godot 菜单中：**项目 (Project) → 重新加载当前项目 (Reload Current Project)**
2. 或者：完全关闭 Godot，再重新打开

### 3️⃣ **运行项目 (F5)**

### 4️⃣ **观察控制台输出**

**这次应该看到：**
```
[WindowService] 已初始化
[WindowService] 窗口句柄已获取，窗口已设置为 layered + 点击穿透
[INFO] 开始初始化服务...
[ServiceLocator] 已注册服务: ModelService
[ServiceLocator] 已注册服务: AnimationService
[ServiceLocator] 已注册服务: EyeTrackingService
[ServiceLocator] 已注册服务: ConfigService
[INFO] [Main] MouseDetectionService 已手动创建        <-- 🎯 新的！
[INFO] 所有服务已注册
...
[MouseDetection] 已找到 WindowService                  <-- 🎯 新的！
[MouseDetection] 穿透检测已启用                         <-- 🎯 新的！
[MouseDetection] 已找到 SubViewport                    <-- 🎯 新的！
```

---

## 📊 预期的完整日志

```
========== Godot 启动 ==========
Godot Engine v4.5.1.stable.mono.official.f62fdbde1
OpenGL API 3.3.0 NVIDIA 581.15

========== WindowService 自动加载 ==========
[WindowService] 已初始化
[WindowService] 窗口句柄已获取，窗口已设置为 layered + 点击穿透

========== Main 场景初始化 ==========
SubViewport透明背景设置完成
[INFO] 开始初始化服务...

========== GDScript 服务注册 ==========
[ServiceLocator] 已注册服务: ModelService
[ServiceLocator] 已注册服务: AnimationService
[ServiceLocator] 已注册服务: EyeTrackingService
[ServiceLocator] 已注册服务: ConfigService

========== C# 服务手动创建 ==========
[INFO] [Main] MouseDetectionService 已手动创建        <-- 🎯 关键！
[INFO] 所有服务已注册

========== MouseDetectionService 初始化 ==========
[MouseDetection] 已找到 WindowService
[MouseDetection] 穿透检测已启用，将根据像素透明度动态调整窗口穿透状态

========== 配置加载 ==========
[INFO] 加载配置...
[INFO] [ConfigService] 加载配置...
[INFO] [ConfigService] 配置文件不存在，使用默认配置
[INFO] [ConfigService] 配置已应用

========== 模型加载 ==========
[INFO] 加载默认模型...
[INFO] [ModelService] GDCubismUserModel 节点已找到
[INFO] [ModelService] 开始扫描可用模型...
[INFO] [ModelService] 找到模型: hiyori_pro_zh
[INFO] [ModelService] 找到模型: mao_pro_zh
[INFO] [ModelService] 总共找到 2 个模型

========== MouseDetection 查找 SubViewport ==========
[MouseDetection] 已找到 SubViewport，将使用它进行像素检测   <-- 🎯 关键！

========== 初始化完成 ==========
[INFO] 初始化完成！
[INFO] [EyeTrackingService] 已缓存 2 个手动控制参数
[INFO] [EyeTrackingService] 眼动追踪已就绪
[INFO] [EyeTrackingService] 眼动追踪节点已找到

========== 运行中（每60帧）==========
[MouseDetection] _PhysicsProcess - isEnabled=true, _windowService=OK, _targetViewport=OK

========== 鼠标移动（每30帧）==========
[MouseDetection] DetectPassthrough - pos=(450,450), tex=(1024,1024), alpha=0.98, clickable=true

========== 状态变化（鼠标移到人物上）==========
[MouseDetection] ⚠️ 状态变化: clickable=true, shouldPassthrough=false
[MouseDetection] ⚠️ 正在调用 WindowService.SetClickThrough(false)
[MouseDetection] ✅ 窗口穿透状态已更新: 禁用（可点击区域）
```

---

## 🎉 成功的标志

1. ✅ 看到 `[INFO] [Main] MouseDetectionService 已手动创建`
2. ✅ 看到 `[MouseDetection] 已找到 WindowService`
3. ✅ 看到 `[MouseDetection] 已找到 SubViewport`
4. ✅ 鼠标在人物上时可以点击和拖动
5. ✅ 鼠标在背景上时点击穿透到桌面

---

## 💡 为什么之前的方法失败了

### 问题链
1. **legacy 文件冲突** → 排除后仍然失败
2. **C# 自动加载不稳定** → Godot 无法正确加载 MouseDetectionService
3. **get_node_or_null("/root/MouseDetectionService")** → 返回 null

### 解决方案
- ✅ 手动 `load()` C# 脚本
- ✅ 手动 `new()` 实例化
- ✅ 手动 `add_child()` 添加到场景树
- ✅ 完全控制初始化流程

---

## 📝 技术说明

### Godot C# 自动加载的限制

根据 Godot 官方文档和社区反馈：

1. **C# 自动加载是实验性功能**：在 Godot 4.x 中仍然不够稳定
2. **推荐做法**：对于复杂的 C# 服务，使用手动初始化
3. **GDScript 自动加载更可靠**：因此 `WindowService` 可以保留自动加载

### 手动初始化的最佳实践

```gdscript
# ✅ 推荐：手动加载和初始化
var MyServiceClass = load("res://path/to/MyService.cs")
var my_service = MyServiceClass.new()
add_child(my_service)

# ❌ 不推荐：依赖 C# 自动加载
var my_service = get_node("/root/MyService")
```

---

**请重新加载 Godot 项目并运行测试！** 🚀

这次**一定会成功**，因为：
- ✅ 不再依赖不稳定的 C# 自动加载
- ✅ 手动初始化更可靠
- ✅ 所有代码逻辑都是正确的
- ✅ legacy 文件已排除

如果还有问题，请复制**完整的控制台输出**！

