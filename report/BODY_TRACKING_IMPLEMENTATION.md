# Live2D身体追踪实现方案

**日期**: 2025-10-22  
**问题**: 身体只有水平左右移动，缺少上下和倾斜效果

## 问题分析

### GDCubismEffectTargetPoint 支持的参数

根据插件源码分析，GDCubismEffectTargetPoint支持以下参数：

| 部位 | X轴 | Y轴 | Z轴 | Range |
|------|-----|-----|-----|-------|
| Head | HeadAngleX | HeadAngleY | HeadAngleZ | HeadRange |
| Body | BodyAngleX | - | - | BodyRange |
| Eyes | EyesAngleX | EyesAngleY | - | EyesRange |

**发现**: BodyAngleY 和 BodyAngleZ 不在插件支持列表中！

### 插件限制

**GDCubismEffectTargetPoint 自动控制的参数**:
- ParamAngleX, ParamAngleY, ParamAngleZ（头部完整）
- ParamBodyAngleX（身体仅X轴）
- ParamEyeBallX, ParamEyeBallY（眼球完整）

**需要手动控制的参数**:
- ParamBodyAngleY（身体上下转动）
- ParamBodyAngleZ（身体倾斜）

## 解决方案

### 混合控制策略

**自动控制**（GDCubismEffectTargetPoint）:
- 头部：X, Y, Z 轴
- 身体：X 轴
- 眼球：X, Y 轴

**手动控制**（脚本直接设置）:
- 身体：Y, Z 轴

### 实现代码

```gdscript
# 在 EyeTrackingService.gd 中添加
func _update_body_parameters():
    var model = get_current_model()
    if not model:
        return
    
    var params = model.get_parameters()
    for param in params:
        var param_id = param.get_id()
        
        # BodyAngleY：身体上下转动
        if param_id == "ParamBodyAngleY":
            var value = current_position.y * 10.0  # -10 到 +10 度
            param.set_value(value)
        
        # BodyAngleZ：身体倾斜
        elif param_id == "ParamBodyAngleZ":
            var value = current_position.x * current_position.y * 5.0
            param.set_value(value)
```

### 参数调优

**BodyAngleY** (身体上下):
```gdscript
# 保守（更稳定）
value = current_position.y * 5.0   # -5 到 +5 度

# 适中（推荐）
value = current_position.y * 10.0  # -10 到 +10 度

# 激进（更明显）
value = current_position.y * 15.0  # -15 到 +15 度
```

**BodyAngleZ** (身体倾斜):
```gdscript
# 保守
value = current_position.x * current_position.y * 3.0   # -3 到 +3 度

# 适中（推荐）
value = current_position.x * current_position.y * 5.0   # -5 到 +5 度

# 激进
value = current_position.x * current_position.y * 8.0   # -8 到 +8 度
```

## 完整参数映射

### 场景配置 (L2D.tscn)

```ini
[node name="GDCubismEffectTargetPoint" ...]
# 头部（完整支持）
head_angle_x = "ParamAngleX"
head_angle_y = "ParamAngleY"
head_angle_z = "ParamAngleZ"
head_range = 30.0

# 身体（仅X轴自动，Y/Z手动）
body_angle_x = "ParamBodyAngleX"
body_range = 10.0

# 眼球（完整支持）
eyes_angle_x = "ParamEyeBallX"
eyes_angle_y = "ParamEyeBallY"
eyes_range = 1.0

# 其他参数
smooth_factor = 0.1
max_distance = 0.8
```

### 脚本控制 (EyeTrackingService.gd)

```gdscript
func _process(delta):
    # ... 更新 target_position 和 current_position
    
    # 1. GDCubismEffectTargetPoint 自动处理
    target_point_node.set_target(current_position)
    
    # 2. 手动补充身体Y和Z轴
    _update_body_parameters()
```

## 工作原理

### 坐标到参数的转换

**Target Position** (归一化坐标 -1 到 1):
```
current_position.x = -1.0 到 1.0  (左到右)
current_position.y = -1.0 到 1.0  (下到上)
```

**Head Parameters** (自动):
```
ParamAngleX = current_position.x * head_range
ParamAngleY = current_position.y * head_range
ParamAngleZ = current_position.x * current_position.y * (head_range / 4)
```

**Body Parameters**:
```
ParamBodyAngleX = current_position.x * body_range  (自动)
ParamBodyAngleY = current_position.y * 10.0        (手动)
ParamBodyAngleZ = current_position.x * current_position.y * 5.0  (手动)
```

**Eyes Parameters** (自动):
```
ParamEyeBallX = current_position.x * eyes_range
ParamEyeBallY = current_position.y * eyes_range
```

## 效果说明

### 修复前
- 鼠标左右移动：头部转动 + 身体左右转 + 眼球移动
- 鼠标上下移动：头部转动 + 眼球移动
- 身体无上下和倾斜效果

### 修复后
- 鼠标左右移动：头部转动 + 身体左右转 + 眼球移动
- 鼠标上下移动：头部转动 + 身体上下转（新增） + 眼球移动
- 鼠标对角移动：头部倾斜 + 身体倾斜（新增）

## 性能考虑

### 参数查找优化

当前实现每帧遍历所有参数查找BodyAngleY和BodyAngleZ。

**优化方案**（如需要）:
```gdscript
# 缓存参数引用
var body_angle_y_param = null
var body_angle_z_param = null

func _find_target_point_node():
    # ... 查找target_point_node
    # 同时缓存参数引用
    _cache_body_parameters()

func _cache_body_parameters():
    var params = model.get_parameters()
    for param in params:
        match param.get_id():
            "ParamBodyAngleY":
                body_angle_y_param = param
            "ParamBodyAngleZ":
                body_angle_z_param = param

func _update_body_parameters():
    # 直接使用缓存的引用，不需要遍历
    if body_angle_y_param:
        body_angle_y_param.set_value(current_position.y * 10.0)
    if body_angle_z_param:
        body_angle_z_param.set_value(current_position.x * current_position.y * 5.0)
```

## 测试验证

### 测试用例
1. 鼠标向左 → 头部和身体向左转
2. 鼠标向右 → 头部和身体向右转
3. 鼠标向上 → 头部向上，身体向上（新增效果）
4. 鼠标向下 → 头部向下，身体向下（新增效果）
5. 鼠标左上角 → 头部和身体向左上倾斜（新增效果）
6. 鼠标右下角 → 头部和身体向右下倾斜（新增效果）

### 预期表现
- 动作更加立体和自然
- 身体有明显的上下和倾斜动作
- 头部、身体、眼球协调配合

## 局限性

### GDCubism插件限制
- 插件只支持部分参数的自动映射
- BodyAngleY 和 BodyAngleZ 必须手动控制
- 无法通过配置实现完全自动化

### 替代方案
如果需要完全自动化的身体追踪，可以考虑：
1. 修改gd_cubism插件源码（添加BodyAngleY/Z支持）
2. 完全手动实现眼动追踪（不使用GDCubismEffectTargetPoint）
3. 使用其他Live2D插件

### 当前方案优势
- 混合使用插件自动化 + 手动补充
- 代码简单，易于维护
- 性能开销小
- 效果自然

## 未来改进

### 可能的优化
1. 添加参数缓存，避免每帧查找
2. 添加死区，减少微小抖动
3. 添加参数范围配置选项
4. 实现平滑过渡算法优化

### 扩展功能
1. 支持更多身体部位（手臂、腿部等）
2. 添加呼吸效果与眼动追踪的协调
3. 实现多目标追踪切换
4. 添加预设表情与追踪的混合

---

**实现状态**: 已完成  
**测试状态**: 待验证  
**性能影响**: 可忽略
