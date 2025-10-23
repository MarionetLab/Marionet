# 类名索引 (Class Index)

**最后更新**: 2025-10-22  
**用途**: 记录项目中所有已定义的类名，避免命名冲突  
**维护**: 添加新类时必须更新此文档

---

## 自动加载单例 (Autoload Singletons)

这些类作为Godot自动加载单例，在整个应用生命周期中全局可访问。
**注意**: 自动加载脚本不应使用 `class_name` 定义。

| 单例名称 | 文件路径 | 类型 | 说明 |
|---------|---------|------|------|
| ServiceLocator | engine/core/ServiceLocator.gd | GDScript | 服务定位器，管理服务注册和查找 |
| EngineConstants | engine/core/Constants.gd | GDScript | 全局常量定义和日志系统 |
| WindowService | engine/renderer/services/Window/WindowService.cs | C# | Windows API集成，窗口属性管理 |
| MouseDetectionService | engine/renderer/services/Window/MouseDetection.cs | C# | 像素检测，点击穿透控制 |

**访问方式**:
```gdscript
# GDScript 示例
ServiceLocator.register("MyService", service)
EngineConstants.log_info("消息")
WindowService.SetClickThrough(true)
MouseDetectionService.SetEnabled(true)
```

---

## GDScript 类定义 (class_name)

### 活跃类 (当前使用)

| 类名 | 文件路径 | 继承自 | 说明 |
|------|---------|--------|------|
| ConfigModel | engine/renderer/services/Config/ConfigModel.gd | RefCounted | 配置数据模型 |

**总计**: 1 个活跃 GDScript 类

### Legacy 类 (历史备份)

以下类位于 `engine/legacy/` 目录，仅供参考，不在当前系统中使用。

| 类名 | 文件路径 | 继承自 | 说明 |
|------|---------|--------|------|
| EyeTrackingManager | engine/legacy/src/EyeTrackingManager.gd | Node | 旧版眼动追踪管理器 |
| ConfigManager | engine/legacy/src/ConfigManager.gd | Node | 旧版配置管理器 |
| ModelManager | engine/legacy/src/ModelManager.gd | Node | 旧版模型管理器 |
| ControlPanelManager | engine/legacy/src/ControlPanelManager.gd | Node | 旧版控制面板管理器 |
| AnimationManager | engine/legacy/src/AnimationManager.gd | Node | 旧版动画管理器 |
| HitAreaManager | engine/legacy/src/HitAreaManager.gd | Node | 旧版点击区域管理器 |

**总计**: 6 个 Legacy 类

---

## C# 类定义 (public class)

### 项目类 (当前使用)

| 类名 | 文件路径 | 继承自 | partial | 说明 |
|------|---------|--------|---------|------|
| WindowService | engine/renderer/services/Window/WindowService.cs | Node | Yes | Windows API 窗口服务 |
| MouseDetectionService | engine/renderer/services/Window/MouseDetection.cs | Node | Yes | 鼠标像素检测服务 |

**总计**: 2 个活跃 C# 类

### Legacy 类 (历史备份)

| 类名 | 文件路径 | 继承自 | partial | 说明 |
|------|---------|--------|---------|------|
| MouseDetection | engine/legacy/src/MouseDetection.cs | Node | Yes | 旧版鼠标检测 |
| ApiManager | engine/legacy/src/ApiManager.cs | Node | Yes | 旧版API管理器 |

**总计**: 2 个 Legacy C# 类

---

## 第三方插件类 (gd_cubism)

以下类由 gd_cubism 插件提供，用于 Live2D Cubism 集成。

| 类名 | 文件路径 | 继承自 | 说明 |
|------|---------|--------|------|
| GDCubismEffectCS | engine/addons/gd_cubism/cs/gd_cubism_effect_cs.cs | Node | Cubism效果基类 |
| GDCubismEffectHitAreaCS | engine/addons/gd_cubism/cs/gd_cubism_effect_hit_area_cs.cs | GDCubismEffectCS | 点击区域效果 |
| GDCubismEffectCustomCS | engine/addons/gd_cubism/cs/gd_cubism_effect_custom_cs.cs | GDCubismEffectCS | 自定义效果 |
| GDCubismEffectTargetPointCS | engine/addons/gd_cubism/cs/gd_cubism_effect_target_point_cs.cs | GDCubismEffectCS | 目标点效果（眼动追踪） |
| GDCubismUserModelCS | engine/addons/gd_cubism/cs/gd_cubism_user_model_cs.cs | GodotObject | Live2D用户模型 |
| GDCubismValueAbsCS | engine/addons/gd_cubism/cs/gd_cubism_value_abs_cs.cs | GodotObject | Cubism值抽象类 |
| GDCubismParameterCS | engine/addons/gd_cubism/cs/gd_cubism_parameter_cs.cs | GDCubismValueAbsCS | Cubism参数 |
| GDCubismPartOpacityCS | engine/addons/gd_cubism/cs/gd_cubism_part_opacity_cs.cs | GDCubismValueAbsCS | 部件不透明度 |

**总计**: 8 个插件类

**使用示例**:
```gdscript
# 在场景中使用 Godot 节点类型（非 CS 后缀）
var model = $GDCubismUserModel
var target_point = $GDCubismEffectTargetPoint
```

---

## 服务类 (无 class_name，通过 ServiceLocator 访问)

以下服务类不使用 `class_name` 定义，通过 ServiceLocator 注册和访问。

| 服务名称 | 文件路径 | 继承自 | 说明 |
|---------|---------|--------|------|
| ModelService | engine/renderer/services/Live2D/ModelService.gd | Node | Live2D模型管理服务 |
| AnimationService | engine/renderer/services/Live2D/AnimationService.gd | Node | 动画播放管理服务 |
| EyeTrackingService | engine/renderer/services/Live2D/EyeTrackingService.gd | Node | 眼动追踪服务 |
| ConfigService | engine/renderer/services/Config/ConfigService.gd | Node | 配置管理服务 |

**总计**: 4 个服务类

**访问方式**:
```gdscript
# 通过 ServiceLocator 获取服务
var model_service = ServiceLocator.get_service("ModelService")
var animation_service = ServiceLocator.get_service("AnimationService")
```

---

## 统计总结

### 按类型统计
| 类型 | 活跃 | Legacy | 插件 | 总计 |
|------|------|--------|------|------|
| GDScript class_name | 1 | 6 | 0 | 7 |
| C# public class | 2 | 2 | 8 | 12 |
| GDScript 服务（无class_name） | 4 | 0 | 0 | 4 |
| 自动加载单例 | 4 | 0 | 0 | 4 |
| **总计** | **11** | **8** | **8** | **27** |

### 按模块统计
| 模块 | 类数量 |
|------|--------|
| 核心层 (Core) | 3 个（自动加载） |
| 窗口服务 (Window) | 2 个 |
| Live2D服务 | 3 个 |
| 配置服务 (Config) | 2 个 |
| 插件 (gd_cubism) | 8 个 |
| Legacy | 8 个 |

---

## GDCubism 插件类

### 核心类

GDCubism 是第三方 GDExtension 插件，提供 Live2D Cubism SDK 集成。

| 类名 | 类型 | 说明 | 重要度 |
|------|------|------|--------|
| `GDCubismUserModel` | Node2D | Live2D 模型主控制类 | ⭐⭐⭐⭐⭐ |
| `GDCubismEffectTargetPoint` | Node | 眼动追踪效果节点 | ⭐⭐⭐⭐ |
| `GDCubismEffectHitArea` | Node | 交互区域检测节点 | ⭐⭐⭐⭐ |
| `GDCubismParameter` | GodotObject | 模型参数控制 | ⭐⭐⭐⭐⭐ |
| `GDCubismPartOpacity` | GodotObject | 部件透明度控制 | ⭐⭐⭐ |

### 使用示例

```gdscript
# 获取模型
var model: GDCubismUserModel = $GDCubismUserModel

# 播放动画
model.start_motion("Idle", 0, GDCubismUserModel.PriorityEnum.PriorityNormal)

# 播放表情
model.start_expression("happy")

# 直接控制参数
var params = model.get_parameters()
for param in params:
	if param.get_id() == "ParamBodyAngleY":
		param.set_value(10.0)

# 眼动追踪
var eye_tracking: GDCubismEffectTargetPoint = $EyeTracking
eye_tracking.set_target(Vector2(0.5, 0.5))  # 归一化坐标
```

### 已知限制

⚠️ **GDCubismEffectTargetPoint 限制**:
- ✅ 支持: HeadAngleX/Y/Z, BodyAngleX, EyesAngleX/Y
- ❌ 不支持: BodyAngleY, BodyAngleZ
- **解决方案**: 通过 `get_parameters()` 手动控制缺失的参数

详见: [GDCubism 插件分析报告](./GDCUBISM_PLUGIN_ANALYSIS.md)

---

## 命名规范

### GDScript
```gdscript
# 自动加载单例：不使用 class_name
# 文件: ServiceLocator.gd
extends Node
# 不定义 class_name

# 普通类：使用 class_name
# 文件: ConfigModel.gd
extends RefCounted
class_name ConfigModel

# 服务类：不使用 class_name，通过 ServiceLocator 注册
# 文件: ModelService.gd
extends Node
# 不定义 class_name
```

### C#
```csharp
// 自动加载单例：使用 public partial class
// 文件: WindowService.cs
using Godot;
public partial class WindowService : Node
{
    // 实现
}

// 普通类：使用 public class 或 public partial class
// 文件: ConfigData.cs
public class ConfigData
{
    // 实现
}
```

---

## 类名冲突检查

### 当前状态
- 无活跃类之间的命名冲突
- 无自动加载与 class_name 的冲突
- Legacy 类与活跃类隔离，无冲突

### 预防措施
1. 添加新类前检查此文档
2. 使用描述性的类名，避免通用名称
3. 服务类统一通过 ServiceLocator 访问
4. 自动加载单例不定义 class_name

---

## 添加新类的流程

### 1. 检查命名冲突
查阅本文档，确保类名唯一。

### 2. 确定类型
- **自动加载单例**: 不使用 class_name
- **服务类**: 不使用 class_name，通过 ServiceLocator 注册
- **数据模型/工具类**: 使用 class_name

### 3. 创建文件
按照命名规范创建文件。

### 4. 更新文档
在本文档中添加新类的记录。

### 5. 提交代码
确保文档和代码同时提交。

---

## 类依赖关系

### 核心依赖
```
Main.gd
  ├─> ServiceLocator (注册服务)
  ├─> EngineConstants (日志和常量)
  └─> 所有服务类 (创建和管理)

服务类
  ├─> ServiceLocator (获取其他服务)
  └─> EngineConstants (日志和常量)
```

### 服务间依赖
```
ModelService (核心)
  └─> 被其他服务依赖

AnimationService
  └─> ModelService (获取当前模型)

EyeTrackingService
  └─> ModelService (获取模型节点)

ConfigService
  └─> 独立，无依赖
```

### 窗口服务依赖
```
WindowService (独立)
  └─> Windows API

MouseDetection
  └─> WindowService (调用穿透控制)
```

---

## 未来计划

### 即将添加的类
- UIService - UI管理服务
- AudioService - 音频管理服务
- DialogService - 对话管理服务
- StateManager - 状态机管理

### 可能重构的类
- ConfigModel - 可能拆分为多个配置类
- ServiceLocator - 可能添加依赖注入功能

---

## 维护说明

### 更新频率
每次添加或删除类定义时必须更新此文档。

### 更新责任
负责添加类的开发者必须同时更新此文档。

### 审查要点
- 类名是否唯一
- 继承关系是否正确
- 自动加载配置是否正确
- 命名规范是否遵守

---

## 技术注意事项

### GDCubismEffectTargetPoint 参数限制

**重要发现**: GDCubismEffectTargetPoint 对身体参数的支持有限

**支持的参数**:
- head_angle_x, head_angle_y, head_angle_z（头部完整）
- body_angle_x（身体仅X轴）
- eyes_angle_x, eyes_angle_y（眼球完整）

**不支持的参数** (需手动控制):
- body_angle_y（身体Y轴）
- body_angle_z（身体Z轴）

**解决方案**: 在 EyeTrackingService 中手动设置 ParamBodyAngleY 和 ParamBodyAngleZ

参考文档: `report/BODY_TRACKING_IMPLEMENTATION.md`

### 大动作系统开发参考

**完整参数文档**: `docs/LIVE2D_PARAMETERS_REFERENCE.md`  
- 68个参数的完整说明
- 参数分组和用途
- 实现建议和代码示例

**能力评估报告**: `report/CAPABILITY_ASSESSMENT.md`  
- 大动作系统可行性分析
- 性能评估
- 风险评估

**开发路线图**: `docs/GESTURE_SYSTEM_ROADMAP.md`  
- 4阶段开发计划
- 表情和手势列表
- API设计示例

---

**文档版本**: v1.1  
**维护者**: Marionet 开发团队  
**最后更新**: 2025-10-22
