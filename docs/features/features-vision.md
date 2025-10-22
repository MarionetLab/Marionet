# Marionet 功能愿景

> 详细功能设计与实现方案

---

## 目录

- [文档说明](#文档说明)
- [核心系统 (Core Furnace)](#核心系统-core-furnace)
- [对话系统](#对话系统)
- [记忆与情感](#记忆与情感)
- [陪伴功能](#陪伴功能)
- [视觉与表现](#视觉与表现)
- [系统工具](#系统工具)
- [性能与优化](#性能与优化)

---

## 文档说明

本文档详细描述 Marionet 的各个功能模块设计。所有功能基于 **"感知 → 决策 → 表现"** 框架，保证系统的有机统一。

**开发原则**：
- 功能服务于陪伴体验，而非功能堆砌
- 模块化设计，可独立开关
- 离线优先，AI 增强
- 性能可控，体验优先

---

## 核心系统 (Core Furnace)

核心系统是整个框架的"大脑"，负责感知、决策和调度。

### Perception Unit（感知单元）

**功能**：捕获环境上下文，为决策提供信息基础。

**监控内容**：
- **键鼠活动** - 输入频率、鼠标移动模式
- **前台窗口** - 应用名称、窗口标题、切换频率
- **音频状态** - 是否播放音乐、是否在通话
- **输入内容** - 用户输入的文字（需授权）
- **剪贴板** - 复制的内容（可选）
- **时间信息** - 当前时间、时段、星期
- **视觉识别** - 屏幕截图、OCR、图像理解（可选）

**实现考虑**：
- 隐私保护：所有监控需用户授权，可随时关闭
- 性能优化：按需采样，避免持续高频监控
- 数据过滤：只保留必要信息，及时清理敏感数据

**输出**：结构化的上下文数据，传递给决策单元

### Decision Unit（决策单元）

**功能**：基于感知数据做出行为决策。

**决策内容**：
- **是否互动** - 判断当前是否适合打扰
- **互动方式** - 微提示 / 轻语气泡 / 主动对话
- **互动内容** - 选择台词、表情、动作
- **模式切换** - 工作模式 / 娱乐模式 / 休息模式
- **好奇心触发** - 随机探索和主动观察

**决策因素**：
- 当前活动类型（工作/娱乐/休息）
- 用户专注度（高/中/低）
- 好感度和心情值
- 上次互动时间
- 记忆中的偏好
- 用户互动习惯（行为学习）

**决策流程**：
```
感知数据 → 活动识别 → 专注度评估 → 互动时机判断 → 策略选择
```

**状态覆盖机制**：

用户可以主动控制桌宠的活跃度：

**1. 活跃模式（Override Mode）**
- **触发方式**：用户通过控制面板或快捷方式开启
- **效果**：暂时忽略"是否适合打扰"的判断
- **表现**：
  - 提高主动互动频率
  - 更积极地评论和反应
  - 降低礼貌等级的限制
- **时间限制**：
  - 可设置持续时间（30分钟 / 1小时 / 2小时）
  - 时间到后自动恢复默认决策模式
  - 用户可手动提前结束
- **场景**：用户工作/游戏时仍希望桌宠陪伴

**2. 礼貌模式（默认）**
- 遵循完整的决策判断
- 专注时保持安静
- 根据场合选择互动方式

**行为学习系统**：

桌宠会学习用户的互动偏好，自适应调整活跃度：

**学习内容**：
- **时间偏好**：
  - 每周哪几天用户更愿意互动
  - 每天的哪个时间段互动频率高
  - 节假日 vs 工作日的差异
- **活动偏好**：
  - 哪些活动时用户喜欢互动（游戏/看视频/工作间隙）
  - 哪些活动时用户希望安静（深度专注/会议）
- **互动方式偏好**：
  - 偏好文字气泡还是语音对话
  - 喜欢的互动频率

**学习机制**：
```
记录互动 → 统计模式 → 置信度评估 → 调整权重 → 应用决策
```

**应用效果**：
- **偏好时间段** - 在用户常互动的时间更活跃（互动频率 +20%）
- **非偏好时间段** - 保持默认行为，不受影响
- **渐进调整** - 需要 2-4 周的数据积累
- **可查看** - 用户可在控制面板查看学习到的模式
- **可重置** - 用户不满意时可重置学习数据

**实现考虑**：
- 规则引擎 + 权重计算
- 可配置的决策参数
- 记录决策理由（用于调试和优化）
- 行为数据隐私保护（仅本地分析）
- 提供行为模式可视化图表

### Arbitration Unit（仲裁核心）

**功能**：处理多来源请求的冲突和优先级。

**请求来源**：
- 用户输入（最高优先级）
- 主动陪伴（中优先级）
- 定时任务（低优先级）
- 系统事件（特殊优先级）

**优先级规则**：
```
用户输入 > 系统警告 > 主动对话 > 定时提醒 > 背景动作
```

**冲突处理**：
- 高优先级请求中断低优先级
- 同级请求排队执行
- 可打断的动作 vs 不可打断的动作
- 超时机制防止阻塞

**实现考虑**：
- 优先级队列
- 可抢占调度
- 动作状态机

### Control Dispatcher（行为调度器）

**功能**：管理桌宠的行为执行，基于《模拟人生》的二层行为系统。

**设计思路**：**大任务（Action） + 小任务（Task）** 的层次结构

---

### 核心概念

**1. 小任务（Task）- 原子操作**

不可分割的最小操作单元，例如：
- 对话原子（LLM生成 + TTS + 播放 + 口型）
- 动画原子（播放一个完整动画）
- 观察原子（采样一次环境数据）

**特点**：
- **原子性** - 执行中不可打断
- **简单** - 单一职责
- **快速** - 执行时间短（通常 < 10秒）

**2. 大任务（Action）- 行为序列**

由多个小任务组成的完整行为，例如：

```
【陪伴工作】大任务:
  → [观察环境]小任务
  → [等待30分钟]小任务
  → [工作提醒对话]小任务
  → [idle动画]小任务

【日常问候】大任务:
  → [检测上线]小任务
  → [问候对话]小任务
  → [询问计划对话]小任务
  → [切换工作模式]小任务
```

**特点**：
- **可打断** - 等当前小任务完成后可以打断
- **可取消** - 未执行的小任务可以取消
- **有目标** - 完整的行为意图

**3. 任务队列**

两层队列结构：

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

---

### 执行规则

**核心原则**：**小任务原子性，大任务可打断**

**规则1：小任务执行中**
- 不接受任何打断
- 必须完整执行完成
- 执行完成后检查是否有打断请求

**规则2：大任务打断**
- 可以在小任务之间打断
- 等待当前小任务完成
- 取消剩余小任务
- 执行新的大任务

**规则3：大任务队列**
- 高优先级大任务可以插队
- 低优先级大任务排队等待
- 同优先级按FIFO顺序

---

### 模拟人生式场景示例

#### 场景：工作 → 游戏切换（完整流程）

**初始状态**：
```
大任务队列: [陪伴工作]
当前大任务: 陪伴工作
小任务队列: [观察30分钟] → [工作提醒对话] → [idle动画]
当前小任务: [观察30分钟] (执行中，已15分钟)
```

**触发事件**：用户关闭IDE，打开游戏

**系统响应**：
```
1. 检测环境变化：工作 → 游戏
2. 决策单元生成新大任务：[陪伴游戏]
3. 调度器收到打断请求

4. 打断流程：
   a. 等待当前小任务[观察30分钟]完成（不打断）
   b. 小任务完成后，检查打断标记
   c. 取消剩余小任务：[工作提醒对话] [idle动画]
   d. 从大任务队列移除[陪伴工作]

5. 执行新大任务[陪伴游戏]：
   a. 从大任务队列取出[陪伴游戏]
   b. 展开小任务序列：[游戏识别] → [开场对话] → [陪玩观察]
   c. 开始执行第一个小任务[游戏识别]
```

**时间线**：
```
00:00  用户切换到游戏
00:00  系统检测到环境变化
00:00  生成大任务[陪伴游戏]，标记打断请求
00:00  当前小任务[观察]继续执行（不打断）

00:15  小任务[观察]完成
00:15  检测到打断标记
00:15  取消剩余小任务：[工作提醒] [idle]
00:15  大任务[陪伴工作]终止

00:15  开始大任务[陪伴游戏]
00:15  小任务[游戏识别]开始
00:16  小任务[游戏识别]完成
00:16  小任务[开场对话]开始："哇！要玩艾尔登之环了吗？"
00:19  小任务[开场对话]完成
00:19  小任务[陪玩观察]开始
```

#### 场景：用户主动输入（高优先级打断）

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
   d. 暂停大任务[陪伴工作]（入栈，可恢复）

4. 执行[响应用户对话]：
   a. 展开小任务：[解析输入] → [生成回复对话] → [返回工作陪伴]
   b. 顺序执行小任务

5. 完成后恢复：
   a. 大任务[响应用户对话]完成
   b. 恢复[陪伴工作]（出栈）
   c. 重新规划小任务队列
```

---

### 大任务（Action）设计

**大任务结构**：

```csharp
class Action {
    ActionId id;
    ActionType type;  // WorkCompanion, GamingCompanion, Greeting, etc.
    Priority priority;  // High, Normal, Low
    
    List<Task> tasks;  // 小任务序列
    int current_task_index;  // 当前执行到第几个
    
    bool can_interrupt = true;  // 是否允许打断
    bool can_resume = false;    // 是否可恢复
    
    ActionState state;  // Pending, Running, Paused, Completed, Cancelled
}
```

**大任务类型**：

**1. 陪伴类（可打断，可恢复）**
- 陪伴工作
- 陪伴游戏
- 陪伴观看视频

**2. 仪式类（可打断，不可恢复）**
- 早安问候
- 晚安告别
- 定时提醒

**3. 响应类（不可打断，高优先级）**
- 响应用户输入
- 响应用户点击

**大任务状态机**：
```
Pending → Running → Completed
    ↓         ↓
Cancelled  Paused → Running (恢复)
```

---

### 小任务（Task）设计

**小任务结构**：

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

**小任务类型**：

**1. 对话小任务（不可快速结束）**
```csharp
class DialogueTask : Task {
    string content;
    
    bool CanQuickFinish() => false;
    
    async Task Execute() {
        // 1. LLM生成
        if (content == null) {
            content = await LLM.Generate();
        }
        
        // 2. TTS生成
        audio = await TTS.Generate(content);
        
        // 3. 播放 + 口型
        await PlayWithLipSync(audio);
    }
}
```

**2. 等待小任务（可快速结束）**
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

**3. 观察小任务（可快速结束）**
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
            await Delay(1000);  // 正常等待
        }
        // 快速结束时直接完成
    }
}
```

**4. 动画小任务（可快速结束）**
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
            // 播放完当前循环后结束
            await WaitCurrentLoopFinish();
        } else {
            // 正常播放完整动画
            await WaitAnimationFinish();
        }
    }
}
```

---

### 调度器实现

```csharp
class BehaviorDispatcher {
    Queue<Action> action_queue;      // 大任务队列
    Action current_action;            // 当前大任务
    Task current_task;                // 当前小任务
    
    bool interrupt_requested = false;
    Action interrupt_action = null;
    
    // 添加大任务
    void EnqueueAction(Action action) {
        if (action.priority == Priority.High) {
            // 高优先级，请求打断
            RequestInterrupt(action);
        } else {
            // 普通优先级，加入队列
            action_queue.Enqueue(action);
        }
        
        TryExecuteNext();
    }
    
    // 请求打断
    void RequestInterrupt(Action newAction) {
        interrupt_requested = true;
        interrupt_action = newAction;
        
        // 如果当前小任务支持快速结束，请求快速结束
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
            // 检查是否有打断请求
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
        
        // 执行下一个大任务
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
        // 1. 取消当前大任务的剩余小任务
        int remainingTasks = current_action.tasks.Count - current_action.current_task_index - 1;
        Log.Info($"取消 {remainingTasks} 个剩余小任务");
        
        // 2. 标记当前大任务为中断
        if (current_action.can_resume) {
            current_action.state = ActionState.Paused;
            // 可恢复的大任务，压入栈
            paused_action_stack.Push(current_action);
        } else {
            current_action.state = ActionState.Cancelled;
        }
        
        current_action = null;
        
        // 3. 执行打断的新大任务
        ExecuteAction(interrupt_action);
        
        // 4. 重置打断标记
        interrupt_requested = false;
        interrupt_action = null;
    }
    
    // 尝试执行下一个
    void TryExecuteNext() {
        if (current_action != null) {
            return;  // 有大任务在执行
        }
        
        // 检查是否有暂停的任务可恢复
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
        // 重新规划剩余部分（可能环境已变化）
        List<Task> remaining = ReplanRemainingTasks(action);
        action.tasks = remaining;
        action.state = ActionState.Running;
        
        ExecuteAction(action);
    }
}
```

---

### 大任务生成器

**根据目标生成大任务序列**：

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
                        new WaitTask(duration: 30min),
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
                        new DialogueTask(content: null),  // LLM生成
                        new GamingObserveTask()
                    ]
                };
        }
    }
}
```

---

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
[10:35:00]   Cancelled 2 remaining tasks: [DialogueTask, IdleTask]
[10:35:00]   Action Paused: WorkCompanion (can_resume: true)
[10:35:00]   Pushed to resume stack

[10:35:00] Action Started: GamingCompanion
[10:35:00]   Task[1/3] Started: GameRecognitionTask
[10:35:01]   Task[1/3] Completed: GameRecognitionTask (game: Elden Ring)
[10:35:01]   Task[2/3] Started: DialogueTask
[10:35:04]   Task[2/3] Completed: DialogueTask ("要挑战艾尔登之环了吗？")
[10:35:04]   Task[3/3] Started: GamingObserveTask
```

---

### 优化与扩展

**1. 小任务缓存**
```csharp
// 常用小任务预生成
Dictionary<string, Task> task_cache = {
    ["greeting"] = new DialogueTask("你好～"),
    ["idle"] = new IdleAnimationTask(),
    ...
};
```

**2. 大任务模板**
```csharp
// 预定义常见大任务模板
Dictionary<GoalType, ActionTemplate> templates;
```

**3. 动态调整**
```csharp
// 根据用户偏好调整任务参数
if (user_prefers_less_chat) {
    wait_duration *= 2;  // 减少互动频率
}
```

**4. 并行任务（未来）**
```csharp
// 背景任务 + 前台任务
BackgroundAction: [心情自然衰减] [记忆总结]
ForegroundAction: [陪伴工作]
```

---

### 实现考虑

- **状态持久化** - 保存大任务队列和进度
- **异常恢复** - 小任务失败时的降级策略
- **性能监控** - 大任务执行时长、打断频率统计
- **可视化调试** - 实时查看大任务队列和小任务进度
- **灵活配置** - 大任务模板、小任务参数可配置
- **日志完整性** - 记录完整的执行和打断流程

这个设计完美复刻了《模拟人生》的行为系统，同时针对桌宠场景做了适配。

---

## 对话系统

对话系统负责与用户的文字和语音交互。

### Fast / Slow 双通道机制

**设计思路**：平衡响应速度和回复质量。

**Fast 通道（快速响应）**：
- **触发条件**：用户发起对话
- **响应时间**：< 300ms
- **实现方式**：
  - 本地模板匹配
  - 规则引擎预设回复
  - 本地小模型（可选）
- **作用**：提供即时反馈，避免等待感

**Slow 通道（深度回复）**：
- **触发条件**：需要复杂推理的对话
- **响应时间**：1-5s（流式输出）
- **实现方式**：
  - 调用云端 LLM
  - 检索增强生成（RAG）
  - 结合记忆上下文
- **作用**：提供高质量、个性化回复

**协同机制**：
```
用户输入 → Fast 通道立即响应 → Slow 通道异步生成 → 流式替换 Fast 回复
```

**实现考虑**：
- Fast 回复要自然，避免"机器人感"
- Slow 回复流式输出，逐字替换
- 根据问题复杂度智能选择通道
- 离线时仅使用 Fast 通道

### Chat Core（对话核心）

**功能**：管理对话流程和上下文。

**核心功能**：
- **上下文管理** - 维护对话历史（最近 N 轮）
- **角色人格** - 加载角色卡，保持人格一致性
- **情绪状态** - 根据好感度和心情调整语气
- **打断处理** - 支持用户打断 AI 的回复
- **多轮对话** - 理解上下文，能接上话茬

**Prompt 构建**：
```
系统提示词（角色设定）
+ 长期记忆（相关事件）
+ 当前状态（时间、活动、心情）
+ 对话历史（最近 N 轮）
+ 用户输入
```

**实现考虑**：
- Token 控制，避免超出上下文长度
- 关键信息提取和压缩
- 人格一致性检测
- 敏感内容过滤

### TTS（语音合成）

**功能**：将文字转换为语音。

**实现方案**：
- **本地 TTS** - Windows SAPI / Linux espeak（低质量但免费）
- **云端 TTS** - Azure / Google / 其他（高质量但有成本）
- **混合策略** - 短句本地，长句云端

**高级功能**：
- **情绪表达** - 根据情绪调整语速、音调
- **口型同步** - 生成 viseme 数据供 Live2D 使用
- **断句优化** - 自然的停顿和语气
- **缓存机制** - 缓存常用台词

**实现考虑**：
- 流式播放，降低延迟
- 音频队列管理
- 支持打断和跳过
- 离线降级策略

---

## 记忆与情感

记忆和情感系统让陪伴者"记住"和"感受"。

### Memory 系统

**功能**：存储和检索交互记忆。

**记忆类型**：

**1. 短期记忆（Session Memory）**
- 当前会话的对话历史
- 最近的活动记录
- 存储：内存中
- 生命周期：当前会话

**2. 长期记忆（Long-term Memory）**
- 用户偏好（喜好、习惯）
- 重要事件（第一次见面、特殊对话）
- 情感事件（开心的、难过的）
- 存储：图数据库（Neo4j）
- 生命周期：持久化

**3. 事实记忆（Factual Memory）**
- 用户教导的知识
- 客观事实（生日、职业）
- 存储：结构化数据库
- 生命周期：持久化，可编辑

**4. 行为模式记忆（Behavioral Pattern）**
- 互动时间偏好（每周、每日统计）
- 活动类型偏好（工作/游戏/休息时的互动意愿）
- 互动方式偏好（文字/语音/表情）
- 存储：时序数据库 + 统计分析
- 生命周期：持久化，定期更新

**行为模式存储结构**：
```
{
  "weekly_pattern": {
    "Monday": [活跃度分时段统计],
    "Tuesday": [...],
    ...
  },
  "activity_pattern": {
    "coding": {interaction_rate: 0.3, preferred_type: "text"},
    "gaming": {interaction_rate: 0.7, preferred_type: "voice"},
    ...
  },
  "confidence": 0.75,  // 数据置信度
  "sample_size": 120   // 样本数量
}
```

**记忆检索**：
- 基于相似度的语义检索
- 基于时间的时序检索
- 基于关联的图检索
- 重要性加权排序

**实现考虑**：
- 图数据库建模记忆关联
- 向量数据库加速语义检索
- 定期总结和压缩
- 隐私保护和数据加密

### Affection / Mood（好感度与心情）

**功能**：模拟情感状态，影响行为表现。

**好感度系统**：
- **数值范围**：0-100
- **等级划分**：陌生 / 熟悉 / 信任 / 亲密
- **影响因素**：
  - 互动频率（正向）
  - 被长期忽略（负向）
  - 特殊事件（大幅波动）
- **影响效果**：
  - 台词选择（低好感度更礼貌）
  - 主动频率（高好感度更主动）
  - 解锁内容（亲密台词、特殊互动）

**心情系统**：
- **数值范围**：-100 ~ +100
- **状态**：低落 / 平静 / 愉快 / 兴奋
- **影响因素**：
  - 近期互动质量
  - 被打断或忽略
  - 用户的情绪（同理心）
  - 自然衰减（回归平静）
- **影响效果**：
  - 表情和动作
  - 语气和措辞
  - 互动意愿

**实现考虑**：
- 数值平滑变化，避免跳变
- 可配置的衰减速率
- 日志记录情感变化原因
- 提供情感曲线可视化

### Progressive Memory（渐进记忆）

**功能**：长期记忆的总结和回顾。

**周期总结**：
- **每日总结** - 今天发生了什么
- **每周回顾** - 本周的重要事件
- **每月回顾** - 本月的变化和成长

**记忆优化**：
- **重要性评分** - 根据情感强度、提及频率评分
- **记忆压缩** - 合并相似记忆，提取关键信息
- **遗忘机制** - 低重要性的记忆逐渐淡化

**可编辑历史**：
- 用户可查看和编辑记忆
- 删除不想要的记忆
- 标记重要记忆
- 修正错误理解

**实现考虑**：
- LLM 辅助总结生成
- 向量聚类识别相似记忆
- 提供时间线视图
- 导出记忆数据

---

## 陪伴功能

陪伴功能提供日常互动的趣味性和仪式感。

### Rituals（日常仪式）

**功能**：建立固定的互动习惯。

**仪式类型**：

**1. 时间仪式**
- 早安问候（检测上线时间）
- 晚安道别（检测下线时间）
- 午休提醒（中午时段）
- 特殊节日（生日、节假日）

**2. 活动仪式**
- 工作开始/结束
- 游戏启动/退出
- 番茄钟提醒（25分钟专注）

**3. 成就仪式**
- 连续打卡（streak）
- 互动里程碑（认识 N 天）
- 好感度突破

**实现考虑**：
- 可配置的触发条件
- 避免过于频繁
- 台词多样化，避免重复
- 记录仪式历史

### Surprises / Easter Eggs（惊喜与彩蛋）

**功能**：增加趣味性和探索感。

**触发机制**：
- **随机事件** - 低概率触发特殊台词或动作
- **隐藏台词** - 特定条件下解锁
- **特殊反应** - 对特定内容的独特回应
- **收藏系统** - 收集特殊时刻的截图或台词

**彩蛋设计原则**：
- 稀有但不罕见（保持新鲜感）
- 有意义的惊喜（而非无聊的随机）
- 可回顾的记录

**实现考虑**：
- 概率控制和冷却时间
- 彩蛋解锁条件判断
- 提供彩蛋图鉴

### Teach-the-Agent（教学系统）

**功能**：用户主动教导知识和技能。

**教学内容**：

**1. 事实教学**
- 用户信息（姓名、生日、职业）
- 偏好（喜欢/不喜欢）
- 关系（朋友、家人）

**2. 表达教学**
- 特定词语的含义
- 梗和网络用语
- 专业术语

**3. 技能教学**
- 如何完成某个任务
- 何时应该做什么

**教学流程**：
```
用户教导 → 结构化存储 → 知识验证 → 应用实践 → 反馈确认
```

**优先级**：
- 教学内容优先级高于预训练知识
- 冲突时以用户教导为准
- 可纠正和更新

**实现考虑**：
- 自然语言解析教学意图
- 结构化存储（键值对/关系）
- 应用时的知识检索
- 提供教学历史管理

### Shared Activities（共同活动）

**功能**：和用户一起进行活动。

**活动类型**：

**1. 观看内容**
- 检测视频播放器
- 识别视频内容（标题、画面）
- 实时评论和互动
- 记录观看历史

**2. 游戏陪玩**
- 检测游戏窗口
- 识别游戏画面和事件
- 提供评论和建议
- 记录游戏时长和成就

**3. 其他活动**
- 一起听音乐
- 陪伴工作学习
- 定时活动（番茄钟）

**活动记录**：
- 活动类型和时长
- 关键事件（通关、失败）
- 情绪标记（开心、沮丧）
- 形成共同回忆

**实现考虑**：
- 窗口检测和内容识别
- 评论时机的智能判断
- 避免过度打扰
- 记录结构化数据

---

## 视觉与表现

视觉表现层负责将内部状态转化为可见的动画和表情。

### Renderer（渲染管理器）

**功能**：管理 Live2D 模型的渲染和动作。

**核心组件**：

**1. 动作字典（Motion Dictionary）**
- 预定义动作集合（idle、走路、挥手等）
- 动作参数（速度、循环、优先级）
- 动作组合和序列
- 动作混合（blend）

**2. 情绪映射（Emotion Mapping）**
- 情绪状态 → Live2D 参数
  - 开心 → 嘴角上扬、眼睛弯曲
  - 难过 → 嘴角下垂、眉毛皱起
  - 惊讶 → 眼睛放大、嘴巴张开
- 平滑过渡，避免跳变
- 复合情绪的混合表现

**3. 口型映射（Viseme Mapping）**
- TTS 音素 → Live2D 口型参数
- 音素时间对齐
- 呼吸和闭合
- 语速匹配

**实现考虑**：
- 使用 GDCubism 驱动 Live2D
- 参数缓动和插值
- 动作状态机
- 性能优化（帧率控制）

### VTuber 表现（高级特性）

**功能**：提供更精细的表演效果。

**高级功能**：

**1. 精确口型同步**
- 音素级别的精确对齐
- 支持快慢语速
- 停顿和换气
- 表情联动（说话时的微表情）

**2. 音乐同步**
- 检测音乐节拍（BPM）
- 动作跟随节奏
- 哼唱动画（口型 + 表情）
- 情绪匹配音乐氛围

**3. 微表情系统**
- 自然的眨眼
- 视线游移
- 呼吸起伏
- 小动作（整理头发、歪头）

**4. 眼神交互**
- 看向鼠标位置
- 看向活动窗口
- 对话时的目光交流
- 闲置时的环境观察

**实现考虑**：
- 物理模拟（头发、衣服摆动）
- 程序化动画生成
- 参数驱动 vs 关键帧动画
- 与对话和情绪系统联动

---

## 系统工具

系统工具提供管理、调试和扩展功能。

### 悬浮球交互系统

**功能**：提供快捷的交互入口和功能访问。

**核心设计**：一个小型悬浮球，作为桌宠的快捷控制中心。

**触发方式**：

**1. 持续按压热键**
- 按住指定热键（如 Ctrl+Space）
- 显示悬浮球
- 松开热键关闭

**2. 点击触发**
- 点击桌宠身上的特定区域
- 或点击任务栏图标
- 显示悬浮球

**3. 快捷输入模式**
- 特定热键组合（如 Ctrl+Shift+Space）
- 悬浮球直接变形为输入框
- 跳过菜单，快速输入

**交互流程**：

**标准模式（饼状菜单）**：
```
触发悬浮球 → 显示饼状菜单 → 选择功能 → 执行操作
```

饼状菜单选项：
- **聊天** - 打开对话输入框
- **设置** - 调节桌宠参数（缩放、透明度、位置锁定等）
- **控制面板** - 打开主控制面板
- **活跃模式** - 切换活跃/礼貌模式
- **快速命令** - 常用操作快捷方式
- **更多** - 扩展功能菜单

**快捷输入模式（变形输入框）**：
```
快捷触发 → 悬浮球变形为输入框 → 选择交互模式 → 输入内容 → 执行
```

输入框功能：

**1. 模式选择器**
- **聊天模式** - 自然对话
- **教学模式** - 教导知识和技能
- **操作模式** - 执行桌面操作（需授权）
- **表情模式** - 快速触发表情和动作

**2. 输入增强**
- 自动补全（历史输入）
- 快捷指令（/help, /mood, /memory）
- 表情符号选择器
- 语音输入（可选）

**3. 快速反馈**
- 输入时实时预览
- 简短回复直接显示在输入框下方
- 长回复切换到对话窗口

**视觉设计**：

**悬浮球状态**：
- **默认** - 半透明小球，带呼吸光效
- **悬停** - 高亮显示
- **激活** - 展开为饼状菜单或变形为输入框
- **处理中** - 加载动画

**饼状菜单**：
- 径向分布
- 图标 + 文字标签
- 悬停高亮
- 平滑动画过渡

**输入框**：
- 从悬浮球平滑变形
- 半透明背景，毛玻璃效果
- 模式切换标签
- 发送按钮

**定位与显示**：
- **默认位置** - 桌宠附近或屏幕边缘
- **自动隐藏** - 未激活时淡出
- **自适应** - 根据屏幕空间调整位置
- **跨屏支持** - 多显示器环境下智能定位

**实现考虑**：
- 轻量级渲染（避免影响性能）
- 热键冲突检测
- 快捷操作历史记录
- 键盘快捷键支持（不用鼠标也能操作）
- 自定义热键和菜单项
- 无障碍支持

### 控制面板（核心管理器）

**功能**：统一的功能管理界面。

**管理内容**：
- 模块开关（启用/禁用功能）
- 参数配置（主动性、互动频率）
- **活跃模式控制**：
  - 切换活跃/礼貌模式
  - 设置活跃模式持续时间
  - 查看当前模式状态
- **行为学习管理**：
  - 查看学习到的时间偏好（可视化图表）
  - 查看活动偏好统计
  - 重置学习数据
  - 开启/关闭行为学习功能
- 角色切换
- 好感度和心情查看
- 记忆管理
- 日志查看

**界面设计**：
- 分类标签页
- 搜索和过滤
- 快捷操作
- 实时预览

### Explainable Proactivity（可解释主动性）

**功能**：解释系统的主动行为。

**核心机制**：
- 每次主动互动附带理由
  - "你已经专注工作1小时了，休息一下吧"
  - "检测到游戏画面，想和你一起玩"
- 行为日志记录
  - 时间、触发条件、决策理由
- 行为分析
  - 主动互动的合理性统计
  - 用户接受度分析
  - 优化建议

**作用**：
- 增加透明度
- 帮助用户理解系统行为
- 辅助调试和优化
- 建立信任

### ControlARM（简易桌面控制）

**功能**：提供基础的桌面控制能力。

**支持操作**（需用户授权）：
- 打开应用程序
- 输出文字内容
- 截图功能
- 调用外部服务（天气、搜索）

**安全机制**：
- 明确的权限申请
- 操作前确认
- 操作日志记录
- 可随时撤销授权

**实现考虑**：
- 使用系统 API
- 沙盒执行
- 错误处理
- 跨平台兼容

### 适配开发工具

**功能**：辅助创建和配置新角色。

**工具功能**：

**1. 角色配置编辑器**
- 可视化编辑人格参数
- 台词库管理
- 表情动作配置
- 实时预览

**2. 模型封装工具**
- Live2D 模型导入
- 参数映射设置
- 加密和打包
- 合规性检查

**3. 行为编辑器**
- 可视化的行为树
- 触发条件设置
- 动作序列编排
- 测试和调试

**4. 配置生成器**
- 基于模板快速生成配置
- 参数验证
- 导出配置包

**实现考虑**：
- 独立的桌面应用
- 拖拽式界面
- 实时预览和测试
- 详细的文档和教程

### Social Share / Community（社区功能）

**功能**：社区互动和资源分享。

**功能模块**：

**1. 记忆回顾**
- 导出记忆时间线
- 生成回忆视频/图集
- 分享到社交平台

**2. 在线更新**
- 检查框架更新
- 下载新版本
- 更新日志查看

**3. 插件获取**
- 社区插件市场
- 插件安装和管理
- 评分和评论

**4. 故障汇报**
- 崩溃日志收集
- 问题反馈
- 社区支持

**5. 社区服务**
- 角色配置分享（合规）
- 台词库交流
- 使用教程
- 开发者交流

**实现考虑**：
- 隐私保护（可选分享）
- 内容审核机制
- 合规性检查
- API 接口设计

### 模块版本管理器

**功能**：管理可选模块的生命周期。

**管理功能**：
- 模块安装/卸载
- 版本查看和切换
- 依赖关系检查
- 冲突检测

**模块类型**：
- 核心模块（不可卸载）
- 可选模块（可自由安装）
- 第三方模块（社区提供）

**实现考虑**：
- 语义化版本管理
- 依赖树解析
- 回滚机制
- 完整性校验

---

## 性能与优化

性能优化保证系统的流畅运行。

### 离线降级策略

**核心思路**：网络故障时平滑降级，保证基础功能。

**降级层次**：

**1. 完全在线模式**
- 云端 LLM 对话
- 云端 TTS
- 在线更新
- 社区功能

**2. 混合模式**
- Fast 本地 + Slow 云端
- 本地 TTS + 云端备选
- 离线记忆 + 在线同步

**3. 完全离线模式**
- 本地模板对话
- 本地 TTS
- 本地记忆
- 预设动作和台词

**降级触发**：
- 检测网络连接
- API 调用失败
- 超时重试后降级
- 用户手动切换

**实现考虑**：
- 平滑过渡，用户无感
- 明确提示当前模式
- 缓存云端响应
- 离线数据同步

### 缓存策略

**功能**：减少重复计算和网络请求。

**缓存内容**：

**1. LLM 回复缓存**
- 常见问题的回复
- 基于输入哈希的缓存键
- LRU 淘汰策略
- 定期清理

**2. TTS 音频缓存**
- 常用台词的音频
- 问候语、常用回复
- 预渲染高频内容
- 压缩存储

**3. 表情动作缓存**
- 常用表情的渲染结果
- 动作序列缓存
- 关键帧插值

**4. 视觉识别缓存**
- OCR 结果缓存
- 图像分类结果
- 相似图像匹配

**实现考虑**：
- 缓存大小限制
- 缓存命中率统计
- 智能预加载
- 过期策略

### 资源管理（多角色/多开）

**功能**：支持多个角色同时运行。

**资源分配**：
- **主角色** - 完整功能，高优先级
- **副角色** - 降低互动频率，共享资源

**管理策略**：
- 按需加载模型和资源
- 内存占用控制
- CPU 时间分配
- 避免资源竞争

**多角色互动**：
- 角色间可以"对话"
- 角色关系设定
- 协同互动（一起评论）

**实现考虑**：
- 资源池管理
- 优先级调度
- 内存监控和释放
- 性能指标可视化

---

## 功能优先级

### 第一阶段（v0.1 - v1.0）

**核心功能**：
- ✅ Perception Unit（基础感知）
- ✅ Decision Unit（简单决策 + 状态覆盖机制）
- ✅ Fast/Slow 双通道对话
- ✅ Memory 系统（基础版）
- ✅ Renderer（Live2D 渲染）
- ✅ Affection/Mood（好感度）
- ✅ 悬浮球交互系统（基础版）
- ✅ 控制面板（基础功能）

### 第二阶段（v1.0 - v2.0）

**扩展功能**：
- Shared Activities（共同活动）
- Rituals（日常仪式）
- Progressive Memory（渐进记忆）
- VTuber 表现（高级特性）
- 控制面板（完整版）
- 适配开发工具
- **行为学习系统（完整版）**
- **悬浮球（完整功能和自定义）**

### 第三阶段（v2.0+）

**高级功能**：
- Teach-the-Agent（教学系统）
- ControlARM（桌面控制）
- Social Share（社区功能）
- Surprises / Easter Eggs（惊喜系统）
- 多角色支持
- 插件生态

---

## 总结

Marionet 的功能设计遵循以下原则：

1. **有机统一** - 所有功能基于统一框架，相互配合
2. **模块化** - 功能可独立开关，按需组合
3. **渐进增强** - 核心功能优先，高级功能逐步添加
4. **性能可控** - 资源占用可预测，性能可监控
5. **用户可控** - 隐私保护，功能可配置

所有功能的最终目标：**提供自然、有温度的陪伴体验**。

---

<p align="center">
  <i>功能服务于体验，而非功能本身</i>
</p>