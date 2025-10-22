# 眼动追踪修复报告

**日期**: 2025-10-22  
**问题**: 鼠标超出窗口后眼动追踪停止，缺少Z轴旋转

## 问题分析

### 问题1: 鼠标超出窗口后停止追踪

**现象**: 当鼠标移出渲染窗口范围后，人物视线停止跟随

**原因**: 
- 原代码只使用窗口内的鼠标坐标 `get_viewport().get_mouse_position()`
- 当鼠标移出窗口时，坐标不再更新
- 导致视线停留在最后位置或重置

**影响**: 用户体验差，视线跟踪不连续

### 问题2: 缺少Z轴旋转

**现象**: Live2D模型身体只有水平左右移动，没有倾斜效果

**原因**:
- GDCubismEffectTargetPoint未配置HeadAngleZ参数
- 未映射到Live2D的ParamAngleZ参数
- 场景文件中缺少Z轴参数设置

**影响**: 动作表现不自然，缺少立体感

## 修复方案

### 修复1: 全局鼠标追踪

**核心思路**: 使用全局屏幕坐标，即使鼠标超出窗口也能追踪

**修改文件**: `engine/renderer/services/Live2D/EyeTrackingService.gd`

**修改内容**:
```gdscript
# 修改前
func _process(delta: float):
    var mouse_pos = get_viewport().get_mouse_position()
    # 只在窗口内追踪

# 修改后
func _process(delta: float):
    # 使用全局鼠标位置
    var global_mouse_pos = Vector2(DisplayServer.mouse_get_position())
    var window_pos = Vector2(get_tree().root.position)
    var local_mouse_pos = global_mouse_pos - window_pos
    
    # 检查是否在窗口内
    if is_in_window:
        update_target(local_mouse_pos)
        idle_timer = 0.0
    else:
        # 保持当前位置，不立即重置
        if idle_timer > THRESHOLD:
            target_position.lerp(Vector2.ZERO, 0.02)
```

**关键改进**:
1. 使用 `DisplayServer.mouse_get_position()` 获取全局鼠标坐标
2. 转换全局坐标为窗口内相对坐标
3. 鼠标超出窗口时保持目标位置，不立即重置
4. 只在空闲超时后才逐渐归中

### 修复2: Z轴旋转支持

**核心思路**: 完整配置GDCubismEffectTargetPoint的所有参数映射

**修改文件**: 
- `engine/scenes/L2D.tscn`
- `engine/renderer/services/Live2D/EyeTrackingService.gd`

**场景文件配置**:
```gdscript
[node name="GDCubismEffectTargetPoint" ...]
head_angle_x = "ParamAngleX"    # 头部X轴（左右）
head_angle_y = "ParamAngleY"    # 头部Y轴（上下）
head_angle_z = "ParamAngleZ"    # 头部Z轴（倾斜）新增
head_range = 30.0

body_angle_x = "ParamBodyAngleX"  # 身体X轴
body_range = 10.0

eyes_angle_x = "ParamEyeBallX"    # 眼球X轴
eyes_angle_y = "ParamEyeBallY"    # 眼球Y轴
eyes_range = 1.0
```

**脚本配置**:
```gdscript
func _configure_target_point():
    # 设置参数映射
    target_point_node.head_angle_x = "ParamAngleX"
    target_point_node.head_angle_y = "ParamAngleY"
    target_point_node.head_angle_z = "ParamAngleZ"  # 关键：Z轴
    target_point_node.body_angle_x = "ParamBodyAngleX"
    target_point_node.eyes_angle_x = "ParamEyeBallX"
    target_point_node.eyes_angle_y = "ParamEyeBallY"
```

**参数说明**:
- **head_angle_z**: 控制头部倾斜，增加动作自然度
- **head_range**: 头部移动的角度范围（度数）
- **body_range**: 身体移动的角度范围（度数）
- **eyes_range**: 眼球移动的范围（归一化值）

## 实现细节

### 坐标转换

```gdscript
# 全局屏幕坐标
global_mouse_pos = DisplayServer.mouse_get_position()

# 窗口位置
window_pos = get_tree().root.position

# 转换为窗口内相对坐标
local_mouse_pos = global_mouse_pos - window_pos

# 转换为归一化坐标 (-1 到 1)
var center = screen_size * 0.5
var relative = local_mouse_pos - center
var normalized = Vector2(
    relative.x / (screen_size.x * 0.5),
    -relative.y / (screen_size.y * 0.5)  # Y轴取反
)
```

### Live2D参数映射

GDCubismEffectTargetPoint会自动根据目标位置计算并设置以下参数：

| Live2D参数 | 映射属性 | 说明 |
|-----------|---------|------|
| ParamAngleX | head_angle_x | 头部左右转动 |
| ParamAngleY | head_angle_y | 头部上下转动 |
| ParamAngleZ | head_angle_z | 头部左右倾斜 |
| ParamBodyAngleX | body_angle_x | 身体左右转动 |
| ParamEyeBallX | eyes_angle_x | 眼球左右移动 |
| ParamEyeBallY | eyes_angle_y | 眼球上下移动 |

**计算公式** (由GDCubismEffectTargetPoint内部实现):
```
AngleZ = target.x * target.y * range_factor
```
这样当鼠标在对角线方向时，头部会有倾斜效果。

## 修复效果

### 修复前
- 鼠标超出窗口：视线立即停止或重置
- 动作表现：平面化，缺少倾斜
- 用户体验：不连续，不自然

### 修复后
- 鼠标超出窗口：保持当前视线方向，空闲后缓慢归中
- 动作表现：立体化，有头部倾斜效果
- 用户体验：流畅连续，更自然

## 参数调优建议

### 敏感度调整
```gdscript
# 低敏感度（更稳定）
head_range = 20.0
body_range = 5.0
eyes_range = 0.8

# 中敏感度（推荐）
head_range = 30.0
body_range = 10.0
eyes_range = 1.0

# 高敏感度（更活泼）
head_range = 45.0
body_range = 15.0
eyes_range = 1.5
```

### 平滑度调整
在 `EngineConstants.gd` 中：
```gdscript
# 平滑因子（越小越平滑，但响应越慢）
const EYE_SMOOTH_FACTOR = 0.08  # 默认
# 可调整范围: 0.05 (很平滑) 到 0.15 (很灵敏)

# 最大距离（限制视线移动范围）
const EYE_MAX_DISTANCE = 0.8  # 默认
# 可调整范围: 0.5 (保守) 到 1.0 (完整范围)
```

## 测试验证

### 测试用例
1. 鼠标在窗口内移动 - 视线应跟随
2. 鼠标移出窗口上方 - 视线应保持向上
3. 鼠标移出窗口左侧 - 视线应保持向左
4. 鼠标移出窗口对角 - 应有头部倾斜效果
5. 空闲2秒后 - 视线应缓慢归中

### 预期结果
- 视线追踪连续不断
- 有明显的头部倾斜效果
- 空闲时自然归中
- 动作流畅不抖动

## 后续优化方向

### 性能优化
- 添加死区（小幅移动不触发更新）
- 降低更新频率（非每帧检测）
- 缓存计算结果

### 功能增强
- 添加眼动追踪暂停功能
- 支持自定义参数范围
- 添加预设配置（活泼/平静）
- 支持多目标切换

### 用户体验
- 添加眼动追踪可视化调试
- 提供UI调节界面
- 保存用户偏好设置

---

**修复状态**: 已完成  
**测试状态**: 待验证  
**文档更新**: 已完成

## 重要说明

### GDCubismEffectTargetPoint 参数配置

**关键发现**: GDCubismEffectTargetPoint 的参数映射属性是只读的，必须在场景文件中配置。

**错误做法**:
```gdscript
# 运行时设置 - 这会导致错误！
target_point_node.eyes_angle_x = "ParamEyeBallX"  # 错误！
target_point_node.head_range = 30.0               # 错误！
```

**正确做法**:
```gdscript
# 在场景文件 L2D.tscn 中配置
[node name="GDCubismEffectTargetPoint" ...]
head_angle_x = "ParamAngleX"
head_angle_y = "ParamAngleY"
head_angle_z = "ParamAngleZ"
head_range = 30.0
body_angle_x = "ParamBodyAngleX"
body_range = 10.0
eyes_angle_x = "ParamEyeBallX"
eyes_angle_y = "ParamEyeBallY"
eyes_range = 1.0
```

**脚本中**:
```gdscript
# 只能调用方法，不能修改属性
target_point_node.set_target(Vector2(x, y))  # 正确

# 可以读取属性值
var smooth = target_point_node.smooth_factor  # 正确
var range = target_point_node.max_distance    # 正确
```
