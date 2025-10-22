# 大动作系统实现路线图

**目标**: 为Marionet桌宠实现丰富的大动作和表情系统

---

## 当前状态

### 已实现 ✅
- 头部追踪（XYZ全轴）
- 眼球追踪（XY）
- 身体追踪（XYZ全轴，混合控制）
- 全局鼠标追踪（超出窗口仍追踪）

### 可用资源
- 68个Live2D参数
- 8个手臂参数
- 完整表情控制
- 物理引擎支持

---

## 实现阶段

### Phase 1: 基础架构 (1-2天)

**目标**: 建立参数控制基础设施

#### 1.1 创建参数管理器
```
engine/renderer/services/Live2D/ParameterManager.gd
```
**功能**:
- 缓存所有参数引用
- 提供统一的参数访问接口
- 参数值验证和范围检查

```gdscript
class_name ParameterManager

var _cached_params: Dictionary = {}

func get_param(param_id: String) -> GDCubismParameter
func set_param(param_id: String, value: float)
func reset_param(param_id: String)
func reset_all_params()
```

#### 1.2 创建动画控制器
```
engine/renderer/services/Live2D/AnimationController.gd
```
**功能**:
- Tween动画管理
- 多参数同步动画
- 动画队列和优先级

```gdscript
class_name AnimationController

func animate_param(param_id: String, target: float, duration: float)
func animate_params(params: Dictionary, duration: float)
func stop_animation(param_id: String)
func stop_all_animations()
```

**测试**:
- 单参数动画
- 多参数同步动画
- 动画中断和恢复

---

### Phase 2: 表情系统 (2-3天)

**目标**: 实现10种基础表情

#### 2.1 创建表情服务
```
engine/renderer/services/Live2D/ExpressionService.gd
```

#### 2.2 表情列表

| 表情 | 涉及参数 | 优先级 |
|------|---------|--------|
| 开心 | 眼微笑+嘴上扬+脸颊红 | P0 |
| 生气 | 眉下压+眉角度+眼微闭 | P0 |
| 惊讶 | 眉上扬+眼睁大+嘴张开 | P0 |
| 害羞 | 脸颊红+眼微笑+嘴微笑 | P0 |
| 难过 | 眉下垂+眼微闭+嘴下垂 | P1 |
| 困惑 | 眉上扬(单边)+眼转动 | P1 |
| 得意 | 眼微闭+嘴微笑+头微扬 | P1 |
| 疲惫 | 眼半闭+肩下垂+呼吸慢 | P2 |
| 兴奋 | 眼睁大+眉上扬+嘴大笑 | P2 |
| 无聊 | 眼半闭+眉平+嘴平 | P2 |

#### 2.3 实现示例
```gdscript
# 表情：开心
func set_happy():
    param_mgr.set_param("ParamEyeLSmile", 1.0)
    param_mgr.set_param("ParamEyeRSmile", 1.0)
    param_mgr.set_param("ParamMouthForm", 1.0)
    param_mgr.set_param("ParamCheek", 0.8)

# 表情：生气
func set_angry():
    param_mgr.set_param("ParamBrowLY", -0.5)
    param_mgr.set_param("ParamBrowRY", -0.5)
    param_mgr.set_param("ParamBrowLAngle", -1.0)
    param_mgr.set_param("ParamBrowRAngle", 1.0)
    param_mgr.set_param("ParamEyeLOpen", 0.7)
    param_mgr.set_param("ParamEyeROpen", 0.7)
```

**测试**:
- 表情切换流畅性
- 表情持续时间
- 表情组合

---

### Phase 3: 手势系统 (3-4天)

**目标**: 实现10种常用手势

#### 3.1 创建手势服务
```
engine/renderer/services/Live2D/GestureService.gd
```

#### 3.2 手势列表

| 手势 | 涉及参数 | 动画时长 | 优先级 |
|------|---------|---------|--------|
| 挥手 | ArmRA+ArmRB+HandR | 1.5s | P0 |
| 招手 | ArmRA+ArmRB+HandR | 2.0s | P0 |
| 比心 | ArmLA+ArmRA+ArmLB+ArmRB+HandL+HandR | 2.0s | P0 |
| 敬礼 | ArmRA+ArmRB+HandR | 1.0s | P1 |
| 鞠躬 | BodyAngleY+ArmLA+ArmRA | 1.5s | P1 |
| 耸肩 | Shoulder | 0.5s | P1 |
| 指向 | ArmRA+ArmRB+HandR | 1.0s | P1 |
| 拍手 | ArmLA+ArmRA+ArmLB+ArmRB | 1.5s | P2 |
| 双手叉腰 | ArmLA+ArmRA+HandL+HandR | 1.0s | P2 |
| 双臂抱胸 | ArmLA+ArmRA+ArmLB+ArmRB | 1.0s | P2 |

#### 3.3 实现示例
```gdscript
# 手势：挥手
func play_wave():
    var anim = AnimationController.new()
    
    # 举起手臂
    anim.animate_param("ParamArmRA", 10.0, 0.3)
    await anim.finished
    
    # 挥动3次
    for i in range(3):
        anim.animate_param("ParamHandR", 1.0, 0.2)
        await anim.finished
        anim.animate_param("ParamHandR", 0.0, 0.2)
        await anim.finished
    
    # 放下手臂
    anim.animate_param("ParamArmRA", 0.0, 0.3)
    await anim.finished

# 手势：比心
func play_heart():
    var params = {
        "ParamArmLA": 5.0,
        "ParamArmRA": 5.0,
        "ParamArmLB": 8.0,
        "ParamArmRB": 8.0,
        "ParamHandL": 1.0,
        "ParamHandR": 1.0
    }
    anim_ctrl.animate_params(params, 0.5)
    
    # 保持2秒
    await get_tree().create_timer(2.0).timeout
    
    # 恢复
    anim_ctrl.reset_all_params()
```

**测试**:
- 手势流畅性
- 手势中断处理
- 手势队列管理

---

### Phase 4: 呼吸和物理 (1-2天)

**目标**: 添加自然的呼吸效果和物理增强

#### 4.1 呼吸系统
```gdscript
# engine/renderer/services/Live2D/BreathService.gd
class_name BreathService

var breath_speed: float = 2.0  # 呼吸速度
var breath_intensity: float = 0.5  # 呼吸强度
var _time: float = 0.0

func _process(delta):
    _time += delta
    var value = sin(_time * breath_speed) * breath_intensity + 0.5
    param_mgr.set_param("ParamBreath", value)
```

#### 4.2 物理效果增强
```gdscript
# 风吹效果
func simulate_wind():
    param_mgr.set_param("ParamHairFront", 5.0)
    param_mgr.set_param("ParamHairBack", 5.0)
    param_mgr.set_param("ParamSkirt", 3.0)
    # 物理引擎会自动恢复

# 摇晃效果（被戳时）
func simulate_poke():
    param_mgr.set_param("ParamBustY", 3.0)
    # 物理引擎会自动恢复
```

---

### Phase 5: 高级功能 (2-3天)

**目标**: 动作组合和智能触发

#### 5.1 动作序列
```gdscript
# engine/renderer/services/Live2D/SequencePlayer.gd
class_name SequencePlayer

# 播放动作序列
func play_sequence(sequence: Array):
    for action in sequence:
        match action.type:
            "expression":
                expr_service.set_expression(action.id)
            "gesture":
                await gesture_service.play_gesture(action.id)
            "wait":
                await get_tree().create_timer(action.duration).timeout
```

#### 5.2 组合动作示例
```gdscript
# 组合：开心地挥手
var happy_wave = [
    {"type": "expression", "id": "happy"},
    {"type": "wait", "duration": 0.5},
    {"type": "gesture", "id": "wave"},
    {"type": "wait", "duration": 1.0},
    {"type": "expression", "id": "neutral"}
]
sequence_player.play_sequence(happy_wave)
```

#### 5.3 智能触发
```gdscript
# 根据情境自动选择动作
func on_user_click():
    var mood = character_state.get_mood()
    match mood:
        "happy":
            play_random_happy_gesture()
        "bored":
            play_attention_seeking_gesture()
```

---

### Phase 6: 优化和扩展 (持续)

#### 6.1 性能优化
- 参数缓存优化
- 动画批处理
- 物理计算优化

#### 6.2 动作库扩展
- 更多表情（15-20种）
- 更多手势（20-30种）
- 复杂组合动作

#### 6.3 编辑器工具
- 动作预览工具
- 参数调试面板
- 动作录制功能

---

## 文件结构

```
engine/renderer/services/Live2D/
├── EyeTrackingService.gd          (已完成)
├── ParameterManager.gd            (Phase 1)
├── AnimationController.gd         (Phase 1)
├── ExpressionService.gd           (Phase 2)
├── GestureService.gd              (Phase 3)
├── BreathService.gd               (Phase 4)
├── SequencePlayer.gd              (Phase 5)
└── presets/
    ├── expressions.json           (表情预设)
    ├── gestures.json              (手势预设)
    └── sequences.json             (序列预设)
```

---

## API设计示例

### 对外接口
```gdscript
# 在Main.gd或其他脚本中调用

# 表情
ModelService.set_expression("happy")
ModelService.set_expression("angry")

# 手势
await ModelService.play_gesture("wave")
await ModelService.play_gesture("heart")

# 组合
await ModelService.play_action("happy_wave")
await ModelService.play_action("bow_greeting")

# 自动行为
ModelService.enable_auto_breath(true)
ModelService.set_idle_behavior("random_gestures")
```

---

## 测试计划

### 单元测试
- ParameterManager 参数访问
- AnimationController 动画播放
- ExpressionService 表情切换
- GestureService 手势执行

### 集成测试
- 表情+手势组合
- 动作序列播放
- 眼动追踪+表情协调
- 物理效果+动作协调

### 性能测试
- 多参数同时更新
- 连续动作播放
- 内存占用
- CPU占用

---

## 里程碑

### Milestone 1: 基础架构 (Week 1)
- [x] 眼动追踪完成
- [ ] ParameterManager 完成
- [ ] AnimationController 完成
- [ ] 单元测试通过

### Milestone 2: 表情系统 (Week 2)
- [ ] ExpressionService 完成
- [ ] 10种基础表情实现
- [ ] 表情切换流畅
- [ ] 集成测试通过

### Milestone 3: 手势系统 (Week 3)
- [ ] GestureService 完成
- [ ] 10种基础手势实现
- [ ] 手势动画流畅
- [ ] 集成测试通过

### Milestone 4: 高级功能 (Week 4)
- [ ] BreathService 完成
- [ ] SequencePlayer 完成
- [ ] 组合动作实现
- [ ] 完整测试通过

---

## 风险和挑战

### 技术挑战
1. **参数范围未知**: 需要逐个测试参数的有效范围
2. **动画平滑性**: 需要精细调整Tween曲线
3. **动作冲突**: 需要设计优先级和中断机制
4. **物理协调**: 手动参数可能与物理引擎冲突

### 解决方案
1. 创建参数测试工具，快速验证范围
2. 提供多种Easing选项，可配置
3. 实现动作优先级队列
4. 在修改物理参数前临时禁用物理

---

## 后续扩展方向

### 短期
- 语音识别+唇同步
- 更多预设表情和手势
- 自定义动作编辑器

### 中期
- 情绪系统（影响动作选择）
- 记忆系统（记住用户偏好）
- 多角色支持

### 长期
- AI驱动的动作生成
- 实时动作捕捉集成
- 社区动作分享平台

---

**文档版本**: v1.0  
**预计开发周期**: 4周（Phase 1-4）  
**最后更新**: 2025-10-22  
**维护者**: Marionet 开发团队
