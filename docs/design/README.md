# 技术设计文档

本目录包含 Marionet 项目的详细技术设计文档。

## 文档目的

- **与 roadmap.md 分离**: roadmap 聚焦于规划和里程碑，设计文档聚焦于具体实现
- **便于深入阅读**: 详细的架构设计、API 定义、代码示例
- **支持独立更新**: 技术设计可以独立迭代，不影响整体路线图

## 文档索引

### 核心系统设计

- [ ] `character-config-system.md` - 人物配置与管理系统
  - 人物配置文件格式（JSON/TOML）
  - 角色卡系统（Character Card）
  - 多人物管理机制
  - 渲染窗口与中控解耦架构
  - 人物切换流程（重启机制）
  - 配置加载与验证
  - 预设对话素材管理
  - 提示词模板系统

- [ ] `module-system.md` - 模块管理系统
  - ModuleManager 核心实现
  - MVVM 框架设计
  - 依赖管理机制
  - 控制面板集成

- [ ] `external-services.md` - 外部服务接口
  - 通用模型接口（LLM/VLM/TTS）
  - Provider 适配器模式
  - HTTP 调用封装
  - 配置管理

- [ ] `perception-system.md` - 感知系统
  - 基础感知器（键鼠/窗口/音频/时间）
  - 深度感知器（截图/OCR/VLM）
  - 上下文构建器
  - 数据隐私保护

- [ ] `memory-system.md` - 记忆系统
  - 短期记忆（RAM + SQLite）
  - 序列记忆（对话/交互/感知）
  - 符号化记忆（推理/关联）
  - 记忆固化机制

- [ ] `decision-system.md` - 决策系统
  - 快速决策（规则引擎/小模型）
  - 慢速决策（LLM 调用）
  - 行为生成器（Action 构建）
  - 决策与记忆联动
  - 决策理由记录

- [ ] `arbitration-system.md` - 仲裁核心
  - 优先级队列（用户输入/系统/主动/定时）
  - 冲突处理策略
  - 可抢占调度
  - 状态机设计

- [ ] `dispatcher-system.md` - 行为调度器
  - 二层任务系统（Action + Task）
  - 任务队列管理
  - 执行规则（原子性/可打断）
  - 任务执行器（对话/动画/观察）
  - 反馈机制

### 功能设计

- [ ] `action-sequence.md` - 动作序列模块
  - 动作库设计
  - 执行状态管理
  - 与渲染层集成

- [ ] `perception.md` - 感知数据采集
  - 键鼠监测
  - 窗口状态感知
  - 音频感知
  - 数据结构化

- [ ] `numerical-models.md` - 数值模型
  - 关系建模（好感度/等级）
  - 心情建模（数学表示）
  - 性格建模（大五人格）
  - 影响决策机制

### 渲染层设计

- [x] `rendering-layer-checklist.md` - 渲染层功能完整性检查清单 ✅
  - 系统性检查 Phase 1.5 是否有遗漏
  - 发现 2 个严重遗漏，19 个建议补充功能
  - 完整性评分和优先级分析
  - 推荐行动计划

- [x] `dialogue-rendering-system.md` - 对话文字渲染系统 ✅
  - **CanvasLayer 方案**（非独立窗口）
  - 多位置预设（头顶/左右侧/下方/中间）
  - 打字机效果实现
  - 自动跟随人物窗口
  - 超长文本处理（滚动/截断/分页）
  - LLM 流式输出接入
  - 富文本渲染（BBCode）
  - 交互功能（点击跳过/自动隐藏）
  - 包含完整测试数据和测试脚本

- [x] `lip-sync-system.md` - 口型同步系统 ✅
  - **ParameterController** - 通用 Live2D 参数控制器
  - **MouthShapeMapper** - 中精度字符映射（~70% 准确率）
  - **LipSyncService** - 口型同步服务
  - 支持多语言（中英日韩）
  - 文本驱动模式（打字机效果同步）
  - 音频驱动模式（未来，TTS 集成后）
  - 可配置精度级别
  - 包含完整映射规则和测试方案

- [x] `deep-interaction-system.md` - 深度触摸交互系统 ✅
  - **TouchInteractionService** - 触摸交互核心服务
  - **TouchZoneManager** - 多区域触摸管理（头/身体/四肢等）
  - **TouchGestureAnalyzer** - 手势识别（点击/长按/滑动/拖拽）
  - **TouchFeedbackController** - 多层次反馈控制
  - **BehaviorMemorySystem** - 行为记忆与个性化
  - 右键触发、光标切换、实时参数调整
  - 速度/加速度/力度分析
  - 好感度系统联动（Phase 2）
  - 基于成熟的 Live2D 交互研究

- [ ] `animation-enhancement-system.md` - 动画增强系统
  - ~~自动眨眼~~ ✅ 已通过 GDCubismEffectEyeBlink 实现
  - ~~呼吸动画~~ ✅ 已通过 GDCubismEffectBreath 实现
  - 眨眼随机化配置（可选优化）
  - 动画混合与过渡
  - 动画队列系统
  - 点击反馈动画

- [ ] `performance-and-stability.md` - 性能监控与稳定性
  - **ErrorRecoveryService** - 错误恢复机制（P1）
  - 性能监控系统（Debug 模式）
  - 资源管理优化

### UI 设计

- [ ] `control-panel.md` - 控制面板
  - 整体布局
  - 功能模块划分
  - 配置界面设计

- [ ] `floating-ball.md` - 悬浮球系统
  - 交互设计
  - 快捷菜单
  - 对话记录查看

## 文档规范

每个设计文档应包含：

1. **概述**: 模块目的和职责
2. **架构设计**: 系统架构图和组件关系
3. **接口定义**: 公共 API 和数据结构
4. **实现方案**: 关键实现细节和代码示例
5. **集成方式**: 如何与其他模块集成
6. **测试方案**: 如何验证功能正确性
7. **性能考虑**: 性能要求和优化策略
8. **未来扩展**: 预留的扩展点

## 更新原则

- **先设计后实现**: 重要功能先写设计文档
- **设计即文档**: 设计文档应详细到可直接指导编码
- **同步更新**: 架构变更时及时更新设计文档
- **版本记录**: 重大设计变更应记录版本和日期

---

**最后更新**: 2025-10-24

