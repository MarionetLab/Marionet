# HitArea Visualizer 使用指南

**版本**: v1.0  
**最后更新**: 2025-10-23  
**适用范围**: Marionet Engine - Live2D 可视化调试工具

---

## 概述

`HitAreaVisualizerInner` 是一个专为 Live2D Cubism 模型设计的可视化调试工具，能够在运行时显示模型的 HitArea（可触发区域）和主要身体部位的包围盒。

### 核心特性

- ✅ **精确提取**：直接从 GDCubism 模型的 mesh 顶点数据提取包围盒
- ✅ **低耦合设计**：独立模块，不依赖主渲染框架
- ✅ **灵活过滤**：支持仅显示官方 HitArea 或额外显示主要身体部位
- ✅ **实时更新**：自动跟踪模型动画变化
- ✅ **无性能影响**：仅在调试模式启用时工作

### 适用场景

1. **调试点击区域**：可视化 Live2D 模型的可点击区域
2. **验证模型设置**：检查模型的 HitArea 是否正确配置
3. **开发辅助**：快速定位不同身体部位的坐标范围
4. **性能测试**：验证不同部位的 mesh 数量和复杂度

---

## 快速开始

### 1. 添加到场景

在 Godot 编辑器中：

1. 打开你的 Live2D 场景（如 `L2D.tscn`）
2. 定位到 `SubViewport` 节点（包含 `GDCubismUserModel` 的那个）
3. 右键点击 `SubViewport` → **Add Child Node** → 选择 `Node2D`
4. 将新节点重命名为 `HitAreaVisualizerInner`
5. 在 Inspector 中，点击脚本图标，选择 `HitAreaVisualizerInner.gd`

### 2. 配置参数

在 Inspector 中配置以下参数：

```
Model Node Path: ../GDCubismUserModel  (相对路径，指向模型节点)
Update Interval: 0.1                    (更新间隔，秒)
Show On Start: false                    (启动时是否显示)
Show Only Hit Areas: true               (只显示官方HitArea)
Show Body Parts: false                  (额外显示主要身体部位)
```

### 3. 运行和使用

- **F5** 运行场景
- **F2** 切换可视化显示（红色边框标记可触发区域）
- 观察模型的 HitArea 和身体部位

---

## 参数详解

### @export 参数

| 参数名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `model_node_path` | NodePath | `"../GDCubismUserModel"` | 指向 GDCubismUserModel 节点的路径（相对或绝对） |
| `update_interval` | float | `0.1` | HitArea 更新间隔（秒），建议 0.05-0.2 |
| `show_on_start` | bool | `false` | 是否在启动时自动显示可视化 |
| `show_only_hit_areas` | bool | `true` | 仅显示官方定义的 HitArea |
| `show_body_parts` | bool | `false` | 额外显示主要身体部位（胸、腹、四肢、头） |

### 样式配置（代码中修改）

```gdscript
var border_color: Color = Color(1.0, 0.0, 0.0, 0.9)  # 红色边框
var fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)  # 透明填充
var text_color: Color = Color(1.0, 1.0, 1.0, 1.0)  # 白色文字
var border_width: float = 8.0  # 边框宽度
```

**修改方法**：

1. 打开 `HitAreaVisualizerInner.gd`
2. 找到 `# ========== 样式配置 ==========` 部分
3. 修改颜色和宽度值
4. 保存并重新运行

---

## 过滤模式详解

### 模式 1：仅显示 HitArea（默认）

```gdscript
show_only_hit_areas = true
show_body_parts = false
```

**效果**：只显示模型中官方定义的 `HitArea` mesh

**适用场景**：
- 验证模型的 HitArea 是否正确配置
- 检查点击穿透逻辑是否符合预期

### 模式 2：显示 HitArea + 主要身体部位

```gdscript
show_only_hit_areas = true
show_body_parts = true
```

**效果**：显示 `HitArea` + 以下身体部位：
- Body（身体）
- Chest（胸部）
- Torso（躯干）
- Head / Face（头部/脸部）
- ArmL / ArmR（左右手臂）
- LegL / LegR（左右腿）
- HandL / HandR（左右手）
- FootL / FootR（左右脚）

**适用场景**：
- 开发部位特定的交互逻辑
- 验证不同部位的坐标范围

### 模式 3：显示所有 mesh

```gdscript
show_only_hit_areas = false
show_body_parts = false  # 此时无效
```

**效果**：显示模型的所有 mesh（可能有 100+ 个，会导致性能问题）

**警告**：⚠️ 仅用于调试，不建议在生产环境使用

---

## API 参考

### 公共方法

#### `toggle_debug_mode()`

切换调试模式（显示/隐藏可视化）

```gdscript
# 在 Main.gd 中调用
var visualizer = get_node("Sprite2D/SubViewport/HitAreaVisualizerInner")
visualizer.toggle_debug_mode()
```

**用途**：由 Main.gd 的 F2 按键调用

---

#### `set_debug_mode(enabled: bool)`

编程式设置调试模式

```gdscript
# 启用可视化
visualizer.set_debug_mode(true)

# 禁用可视化
visualizer.set_debug_mode(false)
```

**用途**：在代码中控制可视化状态

---

#### `is_debug_mode_enabled() -> bool`

获取当前调试模式状态

```gdscript
if visualizer.is_debug_mode_enabled():
    print("可视化已启用")
```

**返回值**：`true` 表示当前正在显示可视化

---

## 工作原理

### 1. 坐标系映射

```
Live2D Model (local) → GDCubismUserModel.to_global() → SubViewport (world) → 绘制
```

- 使用 `model_node.to_global()` 将模型本地坐标转换到 SubViewport 坐标系
- 确保可视化和模型在同一坐标空间，避免映射错误

### 2. Mesh 提取流程

```
GDCubismUserModel.get_meshes()
  ↓
遍历所有 mesh (Dictionary 或 Array)
  ↓
提取 MeshInstance2D.mesh (ArrayMesh)
  ↓
读取 surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
  ↓
计算顶点包围盒 (min/max x/y)
  ↓
绘制矩形边框
```

### 3. 为什么放在 SubViewport 内部？

**问题**：如果放在主 Viewport，会出现以下问题：
- 坐标映射复杂（需要额外转换）
- 可视化可能被主 Viewport 的其他节点遮挡
- 缩放和变换不同步

**解决方案**：放在与模型相同的 SubViewport 中
- 坐标系统一致
- 自动跟随模型缩放
- 绘制顺序可控（通过 `z_index`）

---

## 常见问题

### Q1: 按 F2 没有反应？

**检查清单**：
1. 确认 `HitAreaVisualizerInner` 已添加到 SubViewport
2. 确认 `model_node_path` 正确指向 `GDCubismUserModel`
3. 检查控制台是否有错误信息
4. 确认 Main.gd 中已实现 F2 按键监听

**解决方法**：
```gdscript
# 在 Main.gd 的 _input() 中添加
if event.keycode == KEY_F2:
    var visualizer = get_node("Sprite2D/SubViewport/HitAreaVisualizerInner")
    if visualizer:
        visualizer.toggle_debug_mode()
```

---

### Q2: 显示的区域不正确（偏移或全屏）？

**原因**：可能将 `HitAreaVisualizerInner` 添加到了主 Viewport 而不是 SubViewport

**解决方法**：
1. 删除当前的 `HitAreaVisualizerInner` 节点
2. 确保添加到 **SubViewport** 下（与 GDCubismUserModel 同级）
3. 重新配置 `model_node_path = "../GDCubismUserModel"`

---

### Q3: 显示了太多区域，看不清？

**解决方法**：启用过滤模式

```gdscript
# 只显示官方 HitArea
show_only_hit_areas = true
show_body_parts = false

# 或显示 HitArea + 主要身体部位
show_only_hit_areas = true
show_body_parts = true
```

---

### Q4: 性能影响如何？

**性能数据**（基于 130 个 mesh 的模型）：

| 模式 | 处理的 mesh 数量 | FPS 影响 |
|------|------------------|----------|
| 仅 HitArea | 1 | 几乎无影响 |
| HitArea + 身体部位 | ~10 | < 1 FPS |
| 所有 mesh | 130 | 5-10 FPS |

**建议**：
- 生产环境：`show_on_start = false`（默认关闭）
- 调试时：按需使用 F2 切换
- 避免在生产环境启用"显示所有 mesh"模式

---

## 高级用法

### 自定义身体部位关键词

修改 `_update_hit_areas()` 中的 `body_keywords`：

```gdscript
var body_keywords = [
    "Body", "Chest", "Torso", "Head", "Face",
    "ArmL", "ArmR", "LegL", "LegR",
    "HandL", "HandR", "FootL", "FootR",
    # 添加你自己的关键词
    "Wing", "Tail", "Accessory"
]
```

### 修改可视化样式

```gdscript
# 改为蓝色半透明填充 + 黄色边框
var border_color = Color(1.0, 1.0, 0.0, 1.0)  # 黄色
var fill_color = Color(0.0, 0.0, 1.0, 0.3)  # 蓝色半透明
var border_width = 4.0  # 更细的边框
```

### 导出 HitArea 数据

在 `_update_hit_areas()` 最后添加：

```gdscript
# 打印所有 HitArea 的坐标
for area in hit_areas:
    print("%s: %s" % [area["name"], area["rect"]])

# 或保存到 JSON
var data = {}
for area in hit_areas:
    data[area["name"]] = {
        "x": area["rect"].position.x,
        "y": area["rect"].position.y,
        "width": area["rect"].size.x,
        "height": area["rect"].size.y
    }
var file = FileAccess.open("user://hitareas.json", FileAccess.WRITE)
file.store_string(JSON.stringify(data, "\t"))
file.close()
```

---

## 与其他模块的集成

### 与点击检测系统集成

```gdscript
# 在 MouseDetection.cs 中
var visualizer = GetNode("/root/Main/Sprite2D/SubViewport/HitAreaVisualizerInner");
if (visualizer != null && visualizer.Call("is_debug_mode_enabled"))
{
    // 可视化已启用，添加额外的调试信息
}
```

### 与动画系统集成

```gdscript
# 在 AnimationService.gd 中
func _on_animation_changed(anim_name: String):
    # 动画切换时强制更新可视化
    var visualizer = ServiceLocator.get_service("HitAreaVisualizer")
    if visualizer:
        visualizer._update_hit_areas()
```

---

## 故障排除

### 错误信息：`model_node为null`

**原因**：`model_node_path` 配置错误

**解决方法**：
1. 检查场景树结构
2. 确认 GDCubismUserModel 节点名称正确
3. 尝试使用绝对路径：`/root/Main/Sprite2D/SubViewport/GDCubismUserModel`

---

### 错误信息：`model_node没有get_meshes方法`

**原因**：指向的节点不是 GDCubismUserModel

**解决方法**：
1. 检查 `model_node_path` 是否指向正确的节点
2. 确认该节点类型为 `GDCubismUserModel`

---

### 错误信息：`get_meshes()返回null`

**原因**：模型尚未加载完成

**解决方法**：
1. 确保模型已加载（等待 `model_service.load_default_model()` 完成）
2. 延迟启用可视化（设置 `show_on_start = false`，稍后按 F2）

---

## 最佳实践

### ✅ 推荐做法

1. **默认关闭**：设置 `show_on_start = false`
2. **按需启用**：通过 F2 切换
3. **启用过滤**：`show_only_hit_areas = true`
4. **合理的更新间隔**：`update_interval = 0.1`（10 FPS）

### ❌ 避免做法

1. ❌ 在生产环境启用 `show_on_start = true`
2. ❌ 显示所有 mesh（`show_only_hit_areas = false`）
3. ❌ 更新间隔过低（< 0.05 秒）
4. ❌ 将可视化节点放在主 Viewport

---

## 相关文档

- [HitArea 迁移指南](./HITAREA_MIGRATION_GUIDE.md) - SubViewport 迁移方案
- [GDCubism 插件分析](./GDCUBISM_PLUGIN_ANALYSIS.md) - 插件 API 详解
- [编码规范](./CODING_STANDARDS.md) - 代码风格指南

---

## 更新日志

### v1.0 (2025-10-23)

- ✅ 初始版本发布
- ✅ 支持从 mesh 顶点提取包围盒
- ✅ 支持过滤 HitArea 和身体部位
- ✅ 支持 F2 快捷键切换
- ✅ 完整文档和 API 参考

---

**维护者**: Marionet 开发团队  
**许可证**: 遵循项目主许可证  
**问题反馈**: 通过项目 Issue 跟踪系统

