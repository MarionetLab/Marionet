# 核心系统 (Core Furnace)

> 系统的"大脑"，负责感知、决策和调度

---

**文档信息**
- **状态**: 🔨 进行中
- **最后更新**: 2025-01
- **相关文档**: 
  - [对话系统](./dialogue-system.md) - 决策结果的主要表现形式
  - [记忆与情感](./memory-emotion.md) - 为决策提供历史数据
  - [视觉与表现](./visual-performance.md) - 执行表现层输出
  - [功能索引](./README.md) - 返回功能导航

---

## 目录

- [概述](#概述)
- [Perception Unit（感知单元）](#perception-unit感知单元)
- [Decision Unit（决策单元）](#decision-unit决策单元)
- [Arbitration Unit（仲裁核心）](#arbitration-unit仲裁核心)
- [Control Dispatcher（行为调度器）](#control-dispatcher行为调度器)
- [实现考虑](#实现考虑)
- [FAQ](#faq)

---

## 概述

Core Furnace 是 Marionet 的核心引擎，实现了 **"感知 → 决策 → 表现"** 的完整流程。

```
┌─────────────────────────────────────────┐
│        Perception Unit                  │
│   环境感知 | 数据采集 | 状态监控        │
└────────────────┬────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│        Decision Unit                    │
│   行为决策 | 模式切换 | 学习适应        │
└────────────────┬────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│      Arbitration Unit                   │
│   优先级仲裁 | 冲突解决 | 队列管理      │
└────────────────┬────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│     Control Dispatcher                  │
│   行为调度 | 任务执行 | 状态管理        │
└─────────────────────────────────────────┘
```

**设计原则**：
- **单一职责** - 每个单元专注一个核心功能
- **数据驱动** - 基于感知数据做决策
- **可解释性** - 记录决策理由和执行过程
- **可扩展性** - 模块化设计，易于添加新功能

---

## Perception Unit（感知单元）

### 功能概述

感知单元负责捕获环境上下文，为决策提供信息基础。

### 监控内容

#### 1. 系统活动监控

**键鼠活动**
- 输入频率（每分钟按键/点击次数/拖动行为）
- 鼠标移动模式（快速/缓慢/静止）
- 空闲时长检测

**前台窗口**
- 应用名称（Chrome、VS Code、游戏等）
- 窗口标题（文档名、网页标题）
- 切换频率（评估专注度）
- 场景分类（什么类型的软件）

**音频状态**
- 是否播放音乐
- 是否在通话（麦克风/扬声器）
- 音量变化

#### 2. 内容感知

**输入内容监控**
- 用户输入的文字（需明确授权）
- 用途：理解用户正在做什么
- 隐私保护：敏感内容过滤，可随时关闭

**剪贴板监控**
- 复制的内容
- 用途：提供上下文相关建议
- 隐私保护：仅保留必要信息，读取后及时清理

#### 3. 视觉识别（高级功能）

**屏幕截图分析**
- OCR 文字识别
- 图像分类（编程/游戏/视频/文档）
- 场景理解（VLM 分析）

**触发时机**：
- 决策需要时按需采样
- 共同活动时定期采样
- 避免持续高频采样

#### 4. 时间信息

- 当前时间（小时:分钟）
- 时段（早晨/上午/下午/傍晚/夜间）
- 星期几
- 是否节假日

### 数据结构

```csharp
class PerceptionContext {
    // 时间信息
    DateTime timestamp;
    TimeOfDay time_of_day;  // Morning, Afternoon, Evening, Night
    DayOfWeek day_of_week;
    
    // 活动信息
    string foreground_app;
    string window_title;
    int keyboard_frequency;  // 每分钟按键数
    int mouse_activity;      // 移动距离（像素）
    int idle_seconds;        // 空闲秒数
    
    // 音频状态
    bool audio_playing;
    bool microphone_active;
    bool speaker_active;
    
    // 内容信息
    string recent_input;     // 最近输入内容
    string clipboard;        // 剪贴板内容
    
    // 视觉信息
    ScreenCapture screenshot;
    string ocr_text;
    SceneType scene_type;    // Coding, Gaming, Video, Document
    
    // 推断信息
    ActivityType activity;   // Work, Entertainment, Rest, Unknown
    FocusLevel focus;        // High, Medium, Low
}
```

### 隐私保护机制

**分级授权**：
```csharp
enum PrivacyLevel {
    Minimal,      // 仅基础系统信息（窗口名、时间）
    Standard,     // + 键鼠活动、音频状态
    Enhanced,     // + 输入内容、剪贴板（过滤敏感信息）
    Full          // + 屏幕截图、OCR 分析
}
```

**敏感内容过滤**：
- 密码字段自动跳过
- 银行/支付页面不采集
- 正则匹配敏感模式（身份证、手机号）

**用户控制**：
- 授权级别可随时调整
- 一键禁用所有监控
- 查看和删除采集的数据
- 数据保留时长限制

### 性能优化

**采样策略**：
- 基础信息：鼠标30-60HZ事件驱动，键盘、麦克风、扬声器同样为输入事件判断，按需采样
- 视觉识别：按需触发

**懒加载**：
- 未使用的监控器不初始化
- 功能关闭时立即停止采集

**缓存机制**：
- 只有窗口切换才会再采样一次，没有变化不会采样
- OCR 结果缓存

### 输出

结构化的 `PerceptionContext` 对象，传递给 Decision Unit。

> 💡 **相关**: 视觉识别部分需要 [视觉与表现 - OCR/VLM](./visual-performance.md#视觉识别) 支持

---

## Decision Unit（决策单元）

### 功能概述

Decision Unit 基于感知数据做出行为决策，判断**是否互动**、**如何互动**、**何时切换模式**。

### 决策内容

#### 1. 是否互动

**判断因素**：
```
是否互动 = f(当前活动, 专注度, 好感度, 上次互动时间, 用户偏好, 模式状态)
```

**决策规则**：

| 活动类型 | 专注度 | 默认策略 | 活跃模式覆盖 |
| -------- | ------ | -------- | ----------- |
| 工作     | 高     | 静默     | 降低频率互动 |
| 工作     | 中     | 定时提醒 | 正常互动     |
| 工作     | 低     | 可互动   | 提高频率互动 |
| 娱乐     | 任意   | 可互动   | 积极互动     |
| 休息     | 任意   | 可互动   | 放松闲聊     |

**强否决条件**（无论什么模式都不打扰，除非用户要求）：
- 全屏应用 + 高专注（游戏除外）
- 检测到会议软件（腾讯会议、Zoom、Teams）
- 演示模式（PowerPoint 全屏）
- 用户明确设置"勿扰时段"

> **关于模式判断标准，详见这个设计文件**：[判断准则](judgement.md)

#### 2. 互动方式

根据场景选择合适的互动强度：

**微提示（Hint）**
- 表现：简单动画、表情变化
- 用途：低侵入的存在感
- 示例：身体轻舞、眨眼、其他低侵入活动

**轻语气泡（Bubble）**
- 表现：短文字气泡，不打断，不播放语音，代表想法
- 用途：轻度提醒
- 示例："已经1小时了～"

**主动对话（Dialogue）**
- 表现：完整对话 + TTS
- 用途：深度互动
- 示例："要不要休息一下？我陪你聊聊天～"

#### 3. 互动内容

**内容来源**：
- 模板库（快速响应，占位符）
- 记忆检索（个性化定制）
- LLM 生成（深度对话）

**内容类型**：
- 问候和告别
- 工作提醒
- 游戏评论
- 闲聊话题
- 关怀问候
- 待补充

#### 4. 模式切换

**模式类型**：

```csharp
enum CompanionMode {
    Work,          // 工作陪伴 - 低频提醒
    Entertainment, // 娱乐陪伴 - 积极互动
    Rest,          // 休息陪伴 - 放松闲聊
    Silent         // 静默模式 - 完全静默
}
```

**自动切换规则**：
- 检测到 IDE/编辑器 → Work
- 检测到游戏 → Entertainment  
- 检测到视频播放器 → Entertainment
- 空闲 > 5分钟 → Rest
- 强否决条件 → Silent

**用户可覆盖**：
- 手动指定模式
- 优先级高于自动判断


### 状态覆盖机制

#### 活跃模式（Override Mode）

**触发方式**：
- 用户通过控制面板开启
- 快捷键或悬浮球菜单
- 自动过期时间

**效果**：
```
活跃模式 ON:
  互动频率 × 1.5
  主动性阈值 ↓ 30%
  礼貌等级限制 ↓
  
活跃模式 OFF:
  恢复默认决策
```

**时间限制**：
- 30分钟 / 1小时 / 2小时
- 自动过期恢复默认
- 用户可手动提前结束

**应用场景**：
- 工作时仍希望陪伴
- 游戏时想要更多互动
- 看视频时希望吐槽

#### 礼貌模式（默认）

遵循完整决策规则：
- 专注时保持安静
- 根据场合选择方式
- 尊重用户习惯

### 行为学习系统

#### 学习内容

**1. 时间偏好**
```csharp
class TimePreference {
    Dictionary<DayOfWeek, float[]> hourly_activity;  // 每小时活跃度
    Dictionary<DayOfWeek, float> daily_activity;     // 每日活跃度
    
    // 分析结果
    TimeSlot[] preferred_times;    // 偏好时间段
    TimeSlot[] avoid_times;        // 避免时间段
    float confidence;              // 置信度 (0-1)
}
```

**示例**：
```
偏好时间：
- 周一至周五 20:00-22:00（晚间放松时段）
- 周六周日 10:00-12:00（周末上午）

避免时间：
- 周一至周五 09:00-12:00（工作专注时段）
- 周一至周五 14:00-17:00（下午工作时段）
```

**2. 活动偏好**
```csharp
class ActivityPreference {
    Dictionary<ActivityType, InteractionPattern> patterns;
    
    struct InteractionPattern {
        float interaction_rate;      // 互动接受率
        string preferred_type;       // 偏好类型（text/voice）
        int sample_size;             // 样本数量
    }
}
```

**示例**：
```
编程: {
  interaction_rate: 0.3,
  preferred_type: "text",
  sample_size: 120
}

游戏: {
  interaction_rate: 0.8,
  preferred_type: "voice",
  sample_size: 45
}
```

**3. 互动方式偏好**
- 文字气泡 vs 语音对话
- 短句 vs 长对话
- 主动 vs 被动

#### 学习机制

**数据收集**：
```
每次互动记录：
  - 时间（年月日时分秒，星期）
  - 活动类型（工作/娱乐/休息）
  - 互动方式（Hint/Bubble/Dialogue）
  - 用户反应（点击/忽略/关闭/回复）
  - 模式状态（活跃/礼貌）
```

**统计分析**：
```python
# 伪代码示例
def analyze_preference():
    for day in weekdays:
        for hour in 24:
            interactions = get_interactions(day, hour)
            positive = count_positive_reactions(interactions)
            total = len(interactions)
            
            if total >= MIN_SAMPLE_SIZE:
                activity_rate = positive / total
                
                if activity_rate > THRESHOLD_HIGH:
                    mark_as_preferred(day, hour)
                elif activity_rate < THRESHOLD_LOW:
                    mark_as_avoid(day, hour)
```

**置信度评估**：
```
置信度 = f(样本数量, 一致性, 时间跨度)

样本数量 >= 100 → 高置信度
样本数量 50-100 → 中置信度  
样本数量 < 50 → 低置信度
```

**应用决策**：
```csharp
float CalculateInteractionProbability(Context ctx) {
    float base_prob = GetBaseProbability(ctx.activity, ctx.focus);
    
    // 应用时间偏好
    if (IsPreferredTime(ctx.time)) {
        base_prob *= 1.2;  // +20%
    } else if (IsAvoidTime(ctx.time)) {
        base_prob *= 0.5;  // -50%
    }
    
    // 应用活动偏好
    var pattern = GetActivityPattern(ctx.activity);
    if (pattern.confidence > 0.7) {
        base_prob *= pattern.interaction_rate;
    }
    
    return Clamp(base_prob, 0, 1);
}
```

#### 学习时间线

**初始阶段（短时间）**
- 使用默认规则
- 收集数据，不应用学习结果
- 样本数量不足，置信度低

**适应阶段（中等时间）**
- 开始应用高置信度的模式
- 保守调整，避免过拟合
- 样本数量达标，置信度中等

**成熟阶段（长时间）**
- 完全应用学习结果
- 持续更新和优化
- 样本充足，置信度高

#### 用户控制

**查看学习结果**：
- 可视化图表（热力图）
- 详细统计数据
- 置信度指标

**手动调整**：
- 标记特定时段为"偏好"或"避免"
- 覆盖自动学习结果
- 优先级高于学习数据

**重置学习**：
- 清除学习数据
- 恢复默认行为
- 重新开始学习

> 💡 **相关**: 学习数据存储在 [记忆系统](./memory-emotion.md#行为模式记忆) 中

### 决策流程

```
1. 获取感知上下文 (PerceptionContext)
2. 识别当前活动类型 (ActivityType)
3. 评估专注度 (FocusLevel)
4. 检查强否决条件 → 如果满足，返回 Silent
5. 查询行为学习数据 → 应用时间/活动偏好
6. 检查模式覆盖 → 应用活跃模式修正
7. 计算互动概率 → 基于多因素加权
8. 判断是否互动 → 概率 + 随机因子
9. 如果互动，选择互动方式 (Hint/Bubble/Dialogue)
10. 如果互动，生成互动内容 (模板/记忆/LLM)
11. 生成 Action，传递给 Arbitration Unit
```

### 可解释性

每次决策都记录理由：

```csharp
class DecisionReason {
    string decision;           // "Interact" or "Silent"
    string reason;             // "User is highly focused on coding"
    Dictionary<string, float> factors;  // 各因素权重
    float final_probability;   // 最终概率
    bool overridden;           // 是否被覆盖
}
```

**示例**：
```json
{
  "decision": "Silent",
  "reason": "User is in a meeting (detected Zoom)",
  "factors": {
    "strong_veto": 1.0,
    "activity": 0.0,
    "focus": 0.0
  },
  "final_probability": 0.0,
  "overridden": false
}
```

```json
{
  "decision": "Interact",
  "reason": "Preferred time (weekday evening) + gaming activity",
  "factors": {
    "activity": 0.8,
    "focus": 0.6,
    "time_preference": 1.2,
    "activity_preference": 0.8,
    "override_mode": 1.5
  },
  "final_probability": 0.86,
  "overridden": true
}
```

### 实现考虑

- **规则引擎** + **权重计算**
- 可配置的决策参数（JSON 配置文件）
- 决策日志记录（用于调试和优化）
- A/B 测试不同策略
- 学习数据定期备份

---

## Arbitration Unit（仲裁核心）

### 功能概述

Arbitration Unit 处理多来源请求的冲突和优先级，确保系统行为的有序性。

### 请求来源

**用户输入（最高优先级）**
- 用户主动点击
- 用户发起对话
- 用户操作控制面板

**系统警告（特殊优先级）**
- 错误提示
- 权限请求
- 紧急通知

**主动陪伴（中优先级）**
- Decision Unit 生成的互动
- 环境变化触发的反应

**定时任务（低优先级）**
- 日常仪式（早安、晚安）
- 周期提醒（番茄钟）

**背景动作（最低优先级）**
- Idle 动画
- 微表情
- 环境观察

### 优先级规则

```
用户输入 > 系统警告 > 主动对话 > 定时提醒 > 背景动作
```

**示例**：
```
当前执行：背景 Idle 动画
新请求：用户点击对话
处理：立即中断 Idle，执行用户对话

当前执行：主动对话 "要休息吗？"
新请求：定时提醒 "番茄钟结束"
处理：等待当前对话完成，再执行提醒
```

### 冲突处理策略

#### 1. 高优先级中断低优先级

```csharp
if (new_request.priority > current_action.priority) {
    if (current_action.can_interrupt) {
        InterruptCurrent();
        ExecuteNew(new_request);
    } else {
        QueueRequest(new_request);
    }
}
```

#### 2. 同级请求排队

```csharp
if (new_request.priority == current_action.priority) {
    QueueRequest(new_request);
}
```

#### 3. 可打断 vs 不可打断

**可打断的动作**：
- Idle 动画
- 等待任务
- 观察任务

**不可打断的动作**：
- 正在播放的对话（TTS）
- 正在执行的动画（非循环）
- 正在处理的用户输入

#### 4. 超时机制

```csharp
// 防止低优先级任务永远得不到执行
if (queued_request.wait_time > MAX_WAIT_TIME) {
    queued_request.priority++;  // 提升优先级
}
```

### 队列管理

**优先级队列**：
```csharp
class RequestQueue {
    PriorityQueue<ActionRequest> queue;
    
    void Enqueue(ActionRequest request) {
        queue.Enqueue(request, request.priority);
        OnQueueChanged();
    }
    
    ActionRequest Dequeue() {
        return queue.Dequeue();
    }
    
    void Clear(Func<ActionRequest, bool> predicate) {
        // 清除满足条件的请求（例如过期的请求）
    }
}
```

**去重逻辑**：
```csharp
// 避免相同请求重复排队
if (queue.Contains(request.id)) {
    queue.Remove(request.id);
}
queue.Enqueue(request);
```

### 状态管理

```csharp
enum ArbitrationState {
    Idle,       // 空闲
    Executing,  // 执行中
    Waiting,    // 等待（不可打断的任务）
    Paused      // 暂停
}
```

### 实现考虑

- 优先级队列数据结构
- 可抢占调度算法
- 请求超时和清理
- 并发安全（线程锁）
- 性能监控（队列长度、等待时间）

---

## Control Dispatcher（行为调度器）

### 功能概述

Control Dispatcher 管理桌宠的行为执行，基于《模拟人生》的**二层行为系统**。

### 核心概念

#### 大任务（Action）- 行为序列

完整的行为意图，由多个小任务组成。

**结构**：
```csharp
class Action {
    ActionId id;
    ActionType type;        // WorkCompanion, GamingCompanion, Greeting
    Priority priority;      // High, Normal, Low
    
    List<Task> tasks;       // 小任务序列
    int current_task_index; // 当前执行位置
    
    bool can_interrupt;     // 是否允许打断
    bool can_resume;        // 是否可恢复
    
    ActionState state;      // Pending, Running, Paused, Completed, Cancelled
}
```

**类型**：

| 类型 | 可打断 | 可恢复 | 示例 |
|------|-------|-------|------|
| 陪伴类 | ✅ | ✅ | 陪伴工作、陪伴游戏 |
| 仪式类 | ✅ | ❌ | 早安问候、晚安告别 |
| 响应类 | ❌ | ❌ | 响应用户输入 |

**状态机**：
```
Pending → Running → Completed
   ↓         ↓
Cancelled  Paused → Running (恢复)
```

#### 小任务（Task）- 原子操作

不可分割的最小操作单元。

**结构**：
```csharp
abstract class Task {
    TaskId id;
    TaskState state;  // Pending, Running, Completed, Failed
    
    // 是否支持快速结束
    abstract bool CanQuickFinish();
    
    // 执行任务
    abstract async Task Execute();
    
    // 请求快速结束
    virtual void RequestQuickFinish() { }
}
```

**类型**：

**1. 对话任务（不可打断、不可快速结束）**
```csharp
class DialogueTask : Task {
    string content;
    
    bool CanQuickFinish() => false;
    
    async Task Execute() {
        // 1. LLM 生成（如果内容为空）
        if (content == null) {
            content = await LLM.Generate();
        }
        
        // 2. TTS 生成
        audio = await TTS.Generate(content);
        
        // 3. 播放 + 口型同步
        await PlayWithLipSync(audio);
    }
}
```

**2. 等待任务（可快速结束）**
```csharp
class WaitTask : Task {
    TimeSpan duration;
    bool quick_finish_requested = false;
    
    bool CanQuickFinish() => true;
    
    void RequestQuickFinish() {
        quick_finish_requested = true;
    }
    
    async Task Execute() {
        var elapsed = TimeSpan.Zero;
        while (elapsed < duration) {
            await Delay(1000);
            elapsed += TimeSpan.FromSeconds(1);
            
            if (quick_finish_requested) {
                break;  // 立即结束
            }
        }
    }
}
```

**3. 观察任务（可快速结束）**
```csharp
class ObserveTask : Task {
    bool quick_finish_requested = false;
    
    bool CanQuickFinish() => true;
    
    void RequestQuickFinish() {
        quick_finish_requested = true;
    }
    
    async Task Execute() {
        // 采样环境数据
        context = await CollectEnvironmentData();
        
        if (!quick_finish_requested) {
            await Delay(1000);
        }
    }
}
```

**4. 动画任务（可快速结束）**
```csharp
class AnimationTask : Task {
    Animation animation;
    bool quick_finish_requested = false;
    
    bool CanQuickFinish() => true;
    
    void RequestQuickFinish() {
        quick_finish_requested = true;
    }
    
    async Task Execute() {
        PlayAnimation(animation);
        
        if (quick_finish_requested) {
            await WaitCurrentLoopFinish();
        } else {
            await WaitAnimationFinish();
        }
    }
}
```

### 任务队列结构

```
┌─────────────────────────────────────────┐
│     大任务队列（Action Queue）            │
│   [陪伴工作] → [日常仪式] → [闲聊]       │
└────────────────┬────────────────────────┘
                 ↓
        当前执行的大任务
                 ↓
┌─────────────────────────────────────────┐
│  小任务队列（Task Queue，当前大任务内）   │
│  [观察]✓ → [等待]▶ → [提醒] → [idle]    │
└─────────────────────────────────────────┘
                 ↓
        当前执行的小任务（不可打断）
```

### 执行规则

**核心原则**：**小任务原子性，大任务可打断**

#### 规则 1：小任务执行中
- ❌ 不接受任何打断
- ✅ 必须完整执行完成
- ✅ 执行完成后检查打断请求

#### 规则 2：大任务打断
- ✅ 可在小任务之间打断
- ✅ 等待当前小任务完成
- ✅ 取消剩余小任务
- ✅ 执行新的大任务

#### 规则 3：大任务队列
- 高优先级插队
- 低优先级排队
- 同优先级 FIFO

### 场景示例

#### 场景 1：工作 → 游戏切换

**初始状态**：
```
大任务队列: [陪伴工作]
当前大任务: 陪伴工作
小任务队列: [观察30分钟] → [工作提醒对话] → [idle动画]
当前小任务: [观察30分钟] (执行中，已15分钟)
```

**触发事件**：用户关闭 IDE，打开游戏

**系统响应**：
```
1. 检测环境变化：工作 → 游戏
2. Decision Unit 生成新大任务：[陪伴游戏]
3. Dispatcher 收到打断请求

4. 打断流程：
   a. 等待当前小任务[观察30分钟]完成（不打断）
   b. 小任务完成后，检查打断标记
   c. 取消剩余小任务：[工作提醒对话] [idle动画]
   d. 从大任务队列移除[陪伴工作]

5. 执行新大任务[陪伴游戏]：
   a. 展开小任务序列：[游戏识别] → [开场对话] → [陪玩观察]
   b. 开始执行第一个小任务[游戏识别]
```

**时间线**：
```
00:00  用户切换到游戏
00:00  系统检测到环境变化
00:00  生成大任务[陪伴游戏]，标记打断请求
00:00  当前小任务[观察]继续执行（不打断）

00:15  小任务[观察]完成
00:15  检测到打断标记
00:15  取消剩余小任务
00:15  大任务[陪伴工作]终止

00:15  开始大任务[陪伴游戏]
00:15  小任务[游戏识别]开始
00:16  小任务[游戏识别]完成
00:16  小任务[开场对话]开始："哇！要玩艾尔登之环了吗？"
00:19  小任务[开场对话]完成
00:19  小任务[陪玩观察]开始
```

#### 场景 2：用户主动输入

**初始状态**：
```
大任务队列: [陪伴工作]
当前大任务: 陪伴工作
小任务队列: [观察] → [等待30分钟] → [提醒]
当前小任务: [等待30分钟] (执行中，已10分钟)
```

**触发事件**：用户通过悬浮球输入对话

**系统响应**：
```
1. 收到高优先级大任务[响应用户对话]
2. 立即标记打断请求

3. 打断流程：
   a. 当前小任务[等待30分钟]支持快速结束
   b. 请求快速结束，小任务立即完成
   c. 取消剩余小任务：[提醒]
   d. 暂停大任务[陪伴工作]（可恢复）

4. 执行[响应用户对话]：
   a. 展开小任务：[解析输入] → [生成回复] → [返回工作陪伴]
   b. 顺序执行

5. 完成后恢复：
   a. 大任务[响应用户对话]完成
   b. 恢复[陪伴工作]
   c. 重新规划小任务队列
```

### 调度器实现

```csharp
class BehaviorDispatcher {
    Queue<Action> action_queue;
    Action current_action;
    Task current_task;
    
    bool interrupt_requested = false;
    Action interrupt_action = null;
    Stack<Action> paused_action_stack;
    
    // 添加大任务
    void EnqueueAction(Action action) {
        if (action.priority == Priority.High) {
            RequestInterrupt(action);
        } else {
            action_queue.Enqueue(action);
        }
        TryExecuteNext();
    }
    
    // 请求打断
    void RequestInterrupt(Action newAction) {
        interrupt_requested = true;
        interrupt_action = newAction;
        
        // 如果当前小任务支持快速结束
        if (current_task?.CanQuickFinish() == true) {
            current_task.RequestQuickFinish();
        }
    }
    
    // 执行大任务
    async void ExecuteAction(Action action) {
        current_action = action;
        action.state = ActionState.Running;
        
        // 逐个执行小任务
        for (int i = 0; i < action.tasks.Count; i++) {
            // 检查打断请求
            if (interrupt_requested) {
                HandleInterrupt();
                return;
            }
            
            // 执行小任务
            current_task = action.tasks[i];
            await ExecuteTask(current_task);
            current_task = null;
        }
        
        // 大任务完成
        current_action.state = ActionState.Completed;
        current_action = null;
        TryExecuteNext();
    }
    
    // 执行小任务
    async Task ExecuteTask(Task task) {
        task.state = TaskState.Running;
        
        try {
            await task.Execute();
            task.state = TaskState.Completed;
        } catch (Exception e) {
            task.state = TaskState.Failed;
            HandleTaskFailure(task, e);
        }
    }
    
    // 处理打断
    void HandleInterrupt() {
        // 1. 取消剩余小任务
        int remainingTasks = current_action.tasks.Count - current_action.current_task_index - 1;
        
        // 2. 标记当前大任务
        if (current_action.can_resume) {
            current_action.state = ActionState.Paused;
            paused_action_stack.Push(current_action);
        } else {
            current_action.state = ActionState.Cancelled;
        }
        
        current_action = null;
        
        // 3. 执行新大任务
        ExecuteAction(interrupt_action);
        
        // 4. 重置标记
        interrupt_requested = false;
        interrupt_action = null;
    }
    
    // 尝试执行下一个
    void TryExecuteNext() {
        if (current_action != null) return;
        
        // 检查暂停任务
        if (paused_action_stack.Count > 0) {
            Action pausedAction = paused_action_stack.Pop();
            ResumeAction(pausedAction);
            return;
        }
        
        // 执行队列中的下一个
        if (action_queue.Count > 0) {
            ExecuteAction(action_queue.Dequeue());
        }
    }
    
    // 恢复大任务
    void ResumeAction(Action action) {
        // 重新规划（环境可能已变化）
        List<Task> remaining = ReplanRemainingTasks(action);
        action.tasks = remaining;
        action.state = ActionState.Running;
        
        ExecuteAction(action);
    }
}
```

### 大任务生成器

```csharp
class ActionGenerator {
    Action Generate(Goal goal, Context context) {
        switch (goal.type) {
            case GoalType.WorkCompanion:
                return new Action {
                    type = ActionType.WorkCompanion,
                    priority = Priority.Normal,
                    can_interrupt = true,
                    can_resume = true,
                    tasks = [
                        new ObserveTask(),
                        new WaitTask(duration: 30.Minutes()),
                        new DialogueTask("休息一下吧"),
                        new IdleAnimationTask()
                    ]
                };
            
            case GoalType.Greeting:
                return new Action {
                    type = ActionType.Greeting,
                    priority = Priority.High,
                    can_interrupt = false,
                    can_resume = false,
                    tasks = [
                        new DialogueTask("早安～"),
                        new DialogueTask("今天有什么计划吗？"),
                        new TransitionTask(GoalType.WorkCompanion)
                    ]
                };
            
            case GoalType.GamingCompanion:
                return new Action {
                    type = ActionType.GamingCompanion,
                    priority = Priority.Normal,
                    can_interrupt = true,
                    can_resume = true,
                    tasks = [
                        new GameRecognitionTask(),
                        new DialogueTask(content: null),  // LLM 生成
                        new GamingObserveTask()
                    ]
                };
        }
    }
}
```

### 调度日志示例

```
[10:30:00] Action Enqueued: WorkCompanion (Priority: Normal)
[10:30:00] Action Started: WorkCompanion
[10:30:00]   Task[1/4] Started: ObserveTask
[10:30:01]   Task[1/4] Completed: ObserveTask (1s)
[10:30:01]   Task[2/4] Started: WaitTask (30min)

[10:35:00] Environment Change: IDE → Game
[10:35:00] Action Enqueued: GamingCompanion (Priority: High)
[10:35:00] Interrupt Requested
[10:35:00]   Current Task: WaitTask (supports quick finish)
[10:35:00]   Request Quick Finish: WaitTask

[10:35:00]   Task[2/4] Completed: WaitTask (5min, shortened)
[10:35:00] Interrupt Handling:
[10:35:00]   Cancelled 2 remaining tasks
[10:35:00]   Action Paused: WorkCompanion (can_resume: true)
[10:35:00]   Pushed to resume stack

[10:35:00] Action Started: GamingCompanion
[10:35:00]   Task[1/3] Started: GameRecognitionTask
[10:35:01]   Task[1/3] Completed: GameRecognitionTask
[10:35:01]   Task[2/3] Started: DialogueTask
[10:35:04]   Task[2/3] Completed: DialogueTask
[10:35:04]   Task[3/3] Started: GamingObserveTask
```

---

## 实现考虑

### 性能优化

**感知层**：
- 按需采样，避免持续高频
- 智能缓存，减少重复计算
- 异步处理，不阻塞主线程

**决策层**：
- 规则引擎 + 快速查表
- 行为学习数据预加载
- 决策结果缓存（相同上下文）

**调度层**：
- 任务池复用
- 状态持久化
- 并发安全

### 可扩展性

**新增感知数据**：
```csharp
// 实现 IPerceptionProvider 接口
class CustomPerceptionProvider : IPerceptionProvider {
    PerceptionData Collect() {
        // 采集自定义数据
    }
}
```

**新增决策规则**：
```csharp
// 实现 IDecisionRule 接口
class CustomDecisionRule : IDecisionRule {
    bool ShouldInteract(Context ctx) {
        // 自定义判断逻辑
    }
}
```

**新增任务类型**：
```csharp
// 继承 Task 基类
class CustomTask : Task {
    // 实现自定义任务
}
```

### 测试与调试

**单元测试**：
- 感知数据解析
- 决策规则计算
- 任务执行逻辑

**集成测试**：
- 完整流程模拟
- 边界条件测试
- 性能压力测试

**可视化调试**：
- 实时查看感知数据
- 决策理由可视化
- 任务队列状态监控

---

## FAQ

**Q: 为什么使用 Action/Task 二层结构？**

A: 灵感来自《模拟人生》的行为系统。大任务（Action）代表完整意图，可以被打断和恢复；小任务（Task）是原子操作，执行中不可打断，保证状态一致性。这种设计兼顾了灵活性和稳定性。

**Q: 行为学习会不会过拟合？**

A: 通过以下机制避免过拟合：
1. 置信度阈值 - 样本数量不足时不应用
2. 保守调整 - 权重变化控制在合理范围
3. 用户可覆盖 - 手动调整优先级最高
4. 定期衰减 - 长期未触发的模式会降低权重

**Q: 如何平衡性能和功能？**

A: 采用渐进式策略：
- 基础功能始终运行（窗口、键鼠监控）
- 高级功能按需启用（视觉识别、行为学习）
- 性能不足时自动降级
- 用户可手动调整监控频率

**Q: 隐私如何保护？**

A: 多层保护机制：
1. 分级授权 - 用户明确同意每个级别
2. 敏感过滤 - 自动跳过密码、支付等
3. 本地存储 - 数据不上传云端
4. 随时关闭 - 一键禁用所有监控
5. 数据控制 - 查看、编辑、删除

**Q: 大任务被频繁打断怎么办？**

A: 设计了保护机制：
1. 优先级系统 - 低优先级不打断高优先级
2. 冷却时间 - 同类型大任务不频繁触发
3. 最小执行时间 - 大任务至少执行一个小任务
4. 恢复机制 - 可恢复的大任务会被保留

---

**下一步阅读**:
- [对话系统](./dialogue-system.md) - 了解 Fast/Slow 双通道机制
- [记忆与情感](./memory-emotion.md) - 深入记忆系统和行为学习
- [功能索引](./README.md) - 返回功能导航

---

<p align="center">
  <i>Core Furnace: The Brain of Marionet</i><br>
  <sub>最后更新: 2025-01</sub>
</p>