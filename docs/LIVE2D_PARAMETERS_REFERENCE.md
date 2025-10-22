# Live2D模型参数完整参考

**模型**: hiyori_pro_zh  
**日期**: 2025-10-22  
**用途**: 大动作系统开发参考

## 参数分类概览

| 分组 | 参数数量 | 支持情况 | 适用场景 |
|------|---------|---------|---------|
| 脸部 (Face) | 4 | ✅ 完全支持 | 眼动追踪(自动) |
| 眼睛 (Eyes) | 4 | ✅ 完全支持 | 表情、眨眼 |
| 眼珠 (Eyeballs) | 2 | ✅ 完全支持 | 眼动追踪(自动) |
| 眉毛 (Brows) | 6 | ✅ 完全支持 | 表情、情绪 |
| 嘴巴 (Mouth) | 2 | ✅ 完全支持 | 表情、唇同步 |
| 身体 (Body) | 6 | ⚠️ 部分支持 | 姿态控制 |
| 手臂 (Arms) | 8 | ✅ 完全支持 | 大动作 |
| 摇动 (Sway) | 8 | ✅ 完全支持 | 物理效果 |
| 辫子/侧发 | 28 | ✅ 完全支持 | 物理链 |

**总计**: 68个参数

---

## 详细参数列表

### 1. 脸部参数 (ParamGroupFace) - 4个

| 参数ID | 中文名 | 当前状态 | 用途 | 控制方式 |
|--------|--------|---------|------|---------|
| ParamAngleX | 角度 X | ✅ 已实现 | 头部左右转 | GDCubismEffectTargetPoint |
| ParamAngleY | 角度 Y | ✅ 已实现 | 头部上下转 | GDCubismEffectTargetPoint |
| ParamAngleZ | 角度 Z | ✅ 已实现 | 头部倾斜 | GDCubismEffectTargetPoint |
| ParamCheek | 脸颊泛红 | ⭕ 未使用 | 害羞表情 | 手动设置 |

**实现建议**:
```gdscript
# ParamCheek 用于表情系统
func show_shy_expression():
    param.set_value(1.0)  # 0.0 = 无, 1.0 = 最红
```

---

### 2. 眼睛参数 (ParamGroupEyes) - 4个

| 参数ID | 中文名 | 当前状态 | 用途 | 范围 |
|--------|--------|---------|------|------|
| ParamEyeLOpen | 左眼 开闭 | ⚠️ 自动眨眼 | 眨眼动画 | 0.0~1.0 |
| ParamEyeLSmile | 左眼 微笑 | ⭕ 未使用 | 微笑表情 | 0.0~1.0 |
| ParamEyeROpen | 右眼 开闭 | ⚠️ 自动眨眼 | 眨眼动画 | 0.0~1.0 |
| ParamEyeRSmile | 右眼 微笑 | ⭕ 未使用 | 微笑表情 | 0.0~1.0 |

**实现建议**:
```gdscript
# 表情：开心微笑
func smile():
    get_param("ParamEyeLSmile").set_value(1.0)
    get_param("ParamEyeRSmile").set_value(1.0)

# 表情：眨眼（单独控制）
func wink_left():
    get_param("ParamEyeLOpen").set_value(0.0)
```

---

### 3. 眼珠参数 (ParamGroupEyeballs) - 2个

| 参数ID | 中文名 | 当前状态 | 用途 | 控制方式 |
|--------|--------|---------|------|---------|
| ParamEyeBallX | 眼珠 X | ✅ 已实现 | 眼珠左右 | GDCubismEffectTargetPoint |
| ParamEyeBallY | 眼珠 Y | ✅ 已实现 | 眼珠上下 | GDCubismEffectTargetPoint |

**已完成**: 由眼动追踪系统自动控制

---

### 4. 眉毛参数 (ParamGroupBrows) - 6个

| 参数ID | 中文名 | 当前状态 | 用途 | 范围 |
|--------|--------|---------|------|------|
| ParamBrowLY | 左眉 上下 | ⭕ 未使用 | 眉毛高度 | -1.0~1.0 |
| ParamBrowRY | 右眉 上下 | ⭕ 未使用 | 眉毛高度 | -1.0~1.0 |
| ParamBrowLX | 左眉 左右 | ⭕ 未使用 | 眉毛位置 | -1.0~1.0 |
| ParamBrowRX | 右眉 左右 | ⭕ 未使用 | 眉毛位置 | -1.0~1.0 |
| ParamBrowLAngle | 左眉 角度 | ⭕ 未使用 | 眉毛角度 | -1.0~1.0 |
| ParamBrowRAngle | 右眉 角度 | ⭕ 未使用 | 眉毛角度 | -1.0~1.0 |
| ParamBrowLForm | 左眉 变形 | ⭕ 未使用 | 眉形变化 | 0.0~1.0 |
| ParamBrowRForm | 右眉 变形 | ⭕ 未使用 | 眉形变化 | 0.0~1.0 |

**实现建议** (表情系统):
```gdscript
# 表情：惊讶
func surprised():
    get_param("ParamBrowLY").set_value(1.0)   # 眉毛上扬
    get_param("ParamBrowRY").set_value(1.0)
    get_param("ParamEyeLOpen").set_value(1.0)
    get_param("ParamEyeROpen").set_value(1.0)

# 表情：生气
func angry():
    get_param("ParamBrowLAngle").set_value(-1.0)  # 眉毛倾斜
    get_param("ParamBrowRAngle").set_value(1.0)
    get_param("ParamBrowLY").set_value(-0.5)      # 眉毛压低
    get_param("ParamBrowRY").set_value(-0.5)
```

---

### 5. 嘴巴参数 (ParamGroupMouth) - 2个

| 参数ID | 中文名 | 当前状态 | 用途 | 范围 |
|--------|--------|---------|------|------|
| ParamMouthForm | 嘴 变形 | ⭕ 未使用 | 嘴形（笑/撅） | -1.0~1.0 |
| ParamMouthOpenY | 嘴 开闭 | ⚠️ 唇同步组 | 说话动画 | 0.0~1.0 |

**实现建议**:
```gdscript
# 表情：微笑
func smile_mouth():
    get_param("ParamMouthForm").set_value(1.0)  # 嘴角上扬

# 表情：撅嘴
func pout():
    get_param("ParamMouthForm").set_value(-1.0)

# 唇同步（已在model3.json中配置）
# "LipSync": ["ParamMouthOpenY"]
```

---

### 6. 身体参数 (ParamGroupBody) - 6个 ⚠️

| 参数ID | 中文名 | 当前状态 | 用途 | 控制方式 |
|--------|--------|---------|------|---------|
| ParamBodyAngleX | 身体旋转 X | ✅ 已实现 | 身体左右转 | GDCubismEffectTargetPoint |
| ParamBodyAngleY | 身体旋转 Y | ✅ 已实现 | 身体上下转 | 手动设置(EyeTrackingService) |
| ParamBodyAngleZ | 身体旋转 Z | ✅ 已实现 | 身体倾斜 | 手动设置(EyeTrackingService) |
| ParamBreath | 呼吸 | ⭕ 未使用 | 呼吸动画 | 自动循环 |
| ParamShoulder | 肩 | ⭕ 未使用 | 肩部动作 | 大动作系统 |
| ParamLeg | 腿 | ⭕ 未使用 | 腿部动作 | 大动作系统 |

**重要**: BodyAngleY/Z 不被 GDCubismEffectTargetPoint 支持，需手动设置

**实现建议** (大动作系统):
```gdscript
# 呼吸效果（自动循环）
var breath_time = 0.0
func _process(delta):
    breath_time += delta
    var breath_value = sin(breath_time * 2.0) * 0.5 + 0.5
    get_param("ParamBreath").set_value(breath_value)

# 大动作：耸肩
func shrug():
    get_param("ParamShoulder").set_value(1.0)
    await get_tree().create_timer(0.5).timeout
    get_param("ParamShoulder").set_value(0.0)
```

---

### 7. 手臂参数 (ParamGroupArms) - 8个 ✅

| 参数ID | 中文名 | 当前状态 | 用途 | 范围 |
|--------|--------|---------|------|------|
| ParamArmLA | 左臂 A | ⭕ 未使用 | 上臂动作 | -10.0~10.0 |
| ParamArmRA | 右臂 A | ⭕ 未使用 | 上臂动作 | -10.0~10.0 |
| ParamArmLB | 左臂 B | ⭕ 未使用 | 下臂动作 | -10.0~10.0 |
| ParamArmRB | 右臂 B | ⭕ 未使用 | 下臂动作 | -10.0~10.0 |
| ParamHandLB | 左手B 旋转 | ⭕ 未使用 | 手腕旋转 | -10.0~10.0 |
| ParamHandRB | 右手B 旋转 | ⭕ 未使用 | 手腕旋转 | -10.0~10.0 |
| ParamHandL | 左手 | ⭕ 未使用 | 手势 | 0.0~1.0 |
| ParamHandR | 右手 | ⭕ 未使用 | 手势 | 0.0~1.0 |

**这是大动作系统的核心！**

**实现建议** (大动作系统):
```gdscript
# 大动作：挥手
func wave_hand():
    var tween = create_tween()
    tween.tween_method(
        func(v): get_param("ParamArmRA").set_value(v),
        0.0, 10.0, 0.3
    )
    tween.tween_method(
        func(v): get_param("ParamHandRB").set_value(v),
        0.0, 10.0, 0.2
    )
    # 循环挥动
    for i in range(3):
        tween.tween_method(
            func(v): get_param("ParamHandR").set_value(v),
            0.0, 1.0, 0.2
        )
        tween.tween_method(
            func(v): get_param("ParamHandR").set_value(v),
            1.0, 0.0, 0.2
        )

# 大动作：双手比心
func heart_gesture():
    get_param("ParamArmLA").set_value(5.0)
    get_param("ParamArmRA").set_value(5.0)
    get_param("ParamArmLB").set_value(8.0)
    get_param("ParamArmRB").set_value(8.0)
    get_param("ParamHandL").set_value(1.0)
    get_param("ParamHandR").set_value(1.0)

# 大动作：指向前方
func point_forward():
    get_param("ParamArmRA").set_value(8.0)
    get_param("ParamArmRB").set_value(10.0)
    get_param("ParamHandR").set_value(0.5)
```

---

### 8. 摇动参数 (ParamGroupSway) - 8个 ✅

| 参数ID | 中文名 | 当前状态 | 用途 | 控制方式 |
|--------|--------|---------|------|---------|
| ParamBustY | 胸部摇动 | ⚠️ 物理 | 物理摇动 | Physics3.json |
| ParamHairAhoge | 呆毛摇动 | ⚠️ 物理 | 物理摇动 | Physics3.json |
| ParamHairFront | 前发摇动 | ⚠️ 物理 | 物理摇动 | Physics3.json |
| ParamHairBack | 后发摇动 | ⚠️ 物理 | 物理摇动 | Physics3.json |
| ParamSideupRibbon | 发饰摇动 | ⚠️ 物理 | 物理摇动 | Physics3.json |
| ParamRibbon | 蝴蝶结摇动 | ⚠️ 物理 | 物理摇动 | Physics3.json |
| ParamSkirt | 裙子摇动 | ⚠️ 物理 | 物理摇动 | Physics3.json |
| ParamSkirt2 | 裙子上卷 | ⚠️ 物理 | 物理摇动 | Physics3.json |

**这些参数通常由物理引擎自动控制**

可以通过以下方式控制物理：
```gdscript
# 启用/禁用物理
model.set_physics_evaluate(true/false)

# 手动触发摇动（模拟风吹效果）
func wind_effect():
    get_param("ParamHairFront").set_value(5.0)
    get_param("ParamHairBack").set_value(5.0)
    get_param("ParamSkirt").set_value(3.0)
    # 物理引擎会自动恢复平衡
```

---

### 9. 辫子和侧发参数 - 28个 ✅

这些是物理链参数，用于细腻的头发摇动效果：

**辫子左** (7个): Param_Angle_Rotation_1~7_ArtMesh62  
**辫子右** (7个): Param_Angle_Rotation_1~7_ArtMesh61  
**侧发左** (7个): Param_Angle_Rotation_1~7_ArtMesh55  
**侧发右** (7个): Param_Angle_Rotation_1~7_ArtMesh54

**通常由物理引擎自动处理，不需要手动控制**

---

## 大动作系统实现规划

### 支持情况总结

**✅ 完全可实现的大动作**:
1. **手臂动作** (8个参数)
   - 挥手、招手、比心、敬礼
   - 指向、推、拉
   - 手势变化

2. **身体动作** (3个参数 + 肩/腿)
   - 鞠躬、后仰
   - 耸肩
   - 踢腿、站立姿态

3. **表情组合** (眼睛+眉毛+嘴+脸颊)
   - 开心、生气、惊讶、害羞
   - 困惑、得意、难过
   - 眨眼、微笑

4. **特效** (呼吸+物理)
   - 呼吸动画
   - 头发飘动
   - 衣服摇动

### 建议的动作库结构

```gdscript
# engine/renderer/services/Live2D/GestureService.gd
class_name GestureService
extends Node

enum Gesture {
    WAVE,           # 挥手
    HEART,          # 比心
    POINT,          # 指向
    SHRUG,          # 耸肩
    BOW,            # 鞠躬
    JUMP,           # 跳跃
}

enum Expression {
    HAPPY,          # 开心
    ANGRY,          # 生气
    SURPRISED,      # 惊讶
    SHY,            # 害羞
    SAD,            # 难过
    CONFUSED,       # 困惑
}

func play_gesture(gesture: Gesture):
    match gesture:
        Gesture.WAVE:
            _play_wave_animation()
        Gesture.HEART:
            _play_heart_gesture()
        # ...

func set_expression(expr: Expression):
    match expr:
        Expression.HAPPY:
            _set_happy_expression()
        # ...
```

### 实现优先级

**P0 - 立即可用**:
- [x] 头部追踪（已完成）
- [x] 眼球追踪（已完成）
- [x] 身体追踪（已完成）

**P1 - 基础大动作**:
- [ ] 手臂控制系统
- [ ] 基础表情系统（5-10种）
- [ ] 呼吸动画

**P2 - 高级动作**:
- [ ] 组合动作（挥手+微笑）
- [ ] 动作序列播放
- [ ] 平滑过渡系统

**P3 - 特殊效果**:
- [ ] 物理效果增强
- [ ] 动态姿态切换
- [ ] 自定义动作录制

---

## GDCubism插件支持情况

### 自动控制（GDCubismEffectTargetPoint）
✅ HeadAngleX/Y/Z  
✅ BodyAngleX  
✅ EyesAngleX/Y  

### 手动控制（GDCubismParameter）
✅ 所有其他参数（68个）  
✅ 通过 `get_parameters()` 访问  
✅ 通过 `param.set_value()` 设置  

### Motion系统
✅ StartMotion(group, no, priority)  
✅ StartMotionLoop()  
✅ StopMotion()  

### Expression系统
✅ GetExpressions()  
✅ StartExpression(id)  
✅ StopExpression()  

---

## 性能考虑

### 参数更新成本
- 眼动追踪：每帧2个参数（EyeBallX/Y）
- 身体追踪：每帧5个参数（BodyAngle X/Y/Z + Head XYZ）
- 呼吸动画：每帧1个参数
- 大动作：动作期间 2-8个参数

**预估**: 同时运行全部系统约 10-15个参数/帧，性能影响可忽略

### 优化建议
1. 缓存参数引用，避免每帧查找
2. 使用Tween进行平滑过渡
3. 大动作完成后重置参数
4. 物理参数交给引擎处理

---

## 测试清单

### 基础功能
- [x] 头部追踪（XYZ）
- [x] 眼球追踪（XY）
- [x] 身体追踪（XYZ）

### 待测试参数组
- [ ] 表情参数（眼睛+眉毛+嘴）
- [ ] 手臂参数（8个）
- [ ] 身体参数（呼吸+肩+腿）
- [ ] 物理摇动效果

### 集成测试
- [ ] 表情+动作组合
- [ ] 动作过渡平滑性
- [ ] 物理效果协调性

---

## 结论

**大动作系统完全可行！**

当前Live2D模型提供了：
- ✅ 68个可控参数
- ✅ 8个手臂参数（大动作核心）
- ✅ 完整的表情控制
- ✅ 身体姿态控制
- ✅ 物理效果支持

**唯一限制**: GDCubismEffectTargetPoint 对部分参数的自动化支持有限，但可以通过 `GDCubismParameter` 手动控制所有参数。

**建议**: 创建一个独立的 `GestureService` 来管理大动作和表情系统。

---

**文档版本**: v1.0  
**最后更新**: 2025-10-22  
**维护者**: Marionet 开发团队
