# Marionet 原型架构设计 v1.0

**最后更新**: 2025年10月22日  
**状态**: 原型阶段 - 增量开发中  
**版本**: Prototype v1.0

## 🎯 原型目标

构建一个可运行的桌宠原型，具备以下核心功能：
1. ✅ Live2D模型渲染和展示
2. ✅ 窗口透明和点击穿透
3. ✅ 基础眼动追踪
4. 🔄 动画播放系统（开发中）
5. 📋 配置管理（计划中）
6. 📋 控制面板UI（计划中）

## 🏗️ 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│                     Marionet 桌宠系统                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────┐  ┌──────────────────────────────────┐  │
│  │   核心层       │  │         服务层                    │  │
│  │   (Core)       │  │       (Services)                 │  │
│  │                │  │                                  │  │
│  │  • Main        │→│  Window    Live2D     Config    │  │
│  │  • Constants   │  │    ↓         ↓         ↓       │  │
│  │  • Service     │  │  Mouse   Model    Settings     │  │
│  │    Locator     │  │  Detection Animation           │  │
│  │                │  │          EyeTrack              │  │
│  └────────────────┘  └──────────────────────────────────┘  │
│           ↓                        ↓                        │
│  ┌────────────────────────────────────────────────────┐    │
│  │              表现层 (Presentation)                  │    │
│  │                                                     │    │
│  │    Scene: L2D          UI: ControlPanel            │    │
│  │    • SubViewport       • 模型切换                   │    │
│  │    • Live2D Model      • 参数调节                   │    │
│  │    • Camera2D          • 动画控制                   │    │
│  └────────────────────────────────────────────────────┘    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## 📦 核心模块

### 1. 核心层 (Core Layer)

**职责**: 系统初始化、生命周期管理、全局服务访问

#### Main.gd
```gdscript
# 主入口 - 应用程序启动点
extends Node2D

职责:
- 初始化所有服务
- 管理服务生命周期
- 协调服务间通信
- 处理全局输入事件（拖拽、快捷键）

关键方法:
- _ready(): 服务初始化
- _init_services(): 创建和注册服务
- _input(): 全局输入处理
```

#### ServiceLocator.gd
```gdscript
# 服务定位器 - 解耦服务依赖
extends Node

职责:
- 服务注册和查找
- 服务生命周期追踪
- 依赖注入支持

接口:
- register(name: String, service: Node)
- get_service(name: String) -> Node
- has_service(name: String) -> bool
```

#### Constants.gd
```gdscript
# 全局常量 - 配置和常量定义
extends Node

内容:
- 路径常量 (MODEL_BASE_PATH, CONFIG_PATH)
- Live2D设置 (动画时间、重置时长)
- 眼动追踪参数 (平滑因子、最大距离)
- 性能设置 (目标FPS、队列大小)
- 日志系统 (log_info, log_warning, log_error)
```

### 2. 服务层 (Service Layer)

#### Window 服务组

**WindowService.cs**
```csharp
// Windows API集成 - 窗口属性控制
职责:
- 窗口句柄获取和管理
- 设置窗口为分层窗口 (WS_EX_LAYERED)
- 控制点击穿透 (WS_EX_TRANSPARENT)

API封装:
- GetActiveWindow()
- SetWindowLong()
- SetClickThrough(bool enabled)
```

**MouseDetection.cs**
```csharp
// 像素检测 - 智能穿透控制
职责:
- 检测鼠标下像素的透明度
- 动态切换点击穿透状态
- 性能优化（避免每帧检测）

算法:
1. 获取视口纹理
2. 转换鼠标坐标到图像坐标
3. 读取像素Alpha值
4. Alpha > 0.5 时禁用穿透
```

#### Live2D 服务组

**ModelService.gd**
```gdscript
# 模型管理 - Live2D模型生命周期
extends Node

职责:
- 扫描和加载可用模型
- 模型切换和卸载
- 模型状态管理
- 发送模型加载信号

接口:
- get_available_models() -> Array
- load_model(index: int)
- get_current_model() -> GDCubismUserModel

信号:
- model_loaded(model_name: String)
- model_unloaded()
```

**AnimationService.gd**
```gdscript
# 动画管理 - 动画播放控制
extends Node

职责:
- 加载可用动画列表
- 播放动画（动作和表情）
- 动画队列管理
- 随机动画选择

接口:
- play_random_animation()
- play_motion(group: String, index: int)
- play_expression(index: int)

信号:
- animations_loaded(motion_count, expression_count)
```

**EyeTrackingService.gd**
```gdscript
# 眼动追踪 - 鼠标跟随实现
extends Node

职责:
- 跟踪鼠标位置
- 计算目标视线方向
- 平滑插值更新
- 空闲状态处理（回到中心）

算法:
1. 将鼠标坐标转换为归一化坐标 (-1 到 1)
2. 应用平滑因子进行插值
3. 限制在最大距离内
4. 设置到 GDCubismEffectTargetPoint
```

#### Config 服务组

**ConfigService.gd**
```gdscript
# 配置管理 - 设置加载和保存
extends Node

职责:
- 加载配置文件（JSON）
- 保存用户设置
- 提供配置访问接口
- 配置验证

数据:
- 当前模型索引
- 窗口位置
- 用户偏好设置
```

**ConfigModel.gd**
```gdscript
# 配置模型 - 数据结构定义
class_name ConfigModel

属性:
- current_model_index: int
- window_position: Vector2
- volume: float
- auto_start: bool
```

### 3. 表现层 (Presentation Layer)

#### L2D.tscn
```
场景结构:
L2d (Node2D)
  └─ Sprite2D
      └─ SubViewport (transparent_bg=true, use_hdr_2d=false)
          ├─ Camera2D
          └─ GDCubismUserModel
              ├─ GDCubismEffectBreath
              ├─ GDCubismEffectEyeBlink
              ├─ GDCubismEffectCustom
              ├─ GDCubismEffectHitArea
              └─ GDCubismEffectTargetPoint

关键设置:
- SubViewport.transparent_bg = true （透明背景）
- use_hdr_2d = false （关闭HDR，避免透明度问题）
- window/subwindows/embed_subwindows = false （关键透明度设置）
```

#### ControlPanel.tscn
```
（计划中）
控制面板功能:
- 模型切换下拉框
- 动画播放按钮
- 参数调节滑块
- 配置保存/加载
```

## 🔄 数据流和交互

### 启动流程
```
1. Godot引擎启动
   ↓
2. 加载自动加载单例
   - ServiceLocator
   - EngineConstants
   - WindowService (初始化Windows API)
   - MouseDetection (启动像素检测)
   ↓
3. Main.gd._ready()
   ↓
4. _init_services() 创建服务实例
   - ModelService
   - AnimationService
   - EyeTrackingService
   - ConfigService
   ↓
5. 注册服务到 ServiceLocator
   ↓
6. config_service.load_config()
   ↓
7. model_service.load_default_model()
   ↓
8. 系统就绪 ✅
```

### 用户交互流程

**鼠标移动**
```
用户移动鼠标
   ↓
Main._input(InputEventMouseMotion)
   ↓
eye_tracking_service.update_target(position)
   ↓
计算归一化坐标
   ↓
平滑插值
   ↓
GDCubismEffectTargetPoint.set_target()
   ↓
Live2D模型视线更新 ✅
```

**窗口拖动**
```
用户按下中键
   ↓
Main._input(MOUSE_BUTTON_MIDDLE pressed)
   ↓
记录拖动偏移量 = 鼠标位置 - 窗口位置
   ↓
用户移动鼠标
   ↓
新窗口位置 = 当前鼠标位置 - 拖动偏移量
   ↓
更新窗口位置 ✅
```

**点击穿透**
```
_physics_process() 每帧
   ↓
MouseDetection.DetectPassthrough()
   ↓
获取鼠标位置下的像素
   ↓
读取Alpha值
   ↓
Alpha > 0.5? 
   ├─ 是 → 禁用穿透（可点击）
   └─ 否 → 启用穿透（点击穿过）
   ↓
WindowService.SetClickThrough() ✅
```

**模型加载**
```
model_service.load_model(index)
   ↓
查找模型路径
   ↓
加载 model3.json
   ↓
设置到 GDCubismUserModel
   ↓
发送 model_loaded 信号
   ↓
AnimationService 监听信号
   ↓
加载动画列表
   ↓
EyeTrackingService 监听信号
   ↓
重新查找 TargetPoint 节点 ✅
```

## 🎨 技术栈

### 渲染引擎
- **Godot 4.5**: 主引擎
- **gd_cubism**: Live2D Cubism SDK for Godot
- **OpenGL Compatibility**: 渲染模式（确保透明度兼容）

### 编程语言
- **GDScript**: 主要逻辑（约80%）
- **C#**: Windows API集成（约20%）

### 关键技术点
1. **窗口透明**: 
   - `window/size/transparent=true`
   - `window/per_pixel_transparency/allowed=true`
   - `window/subwindows/embed_subwindows=false` ⭐ 关键设置

2. **点击穿透**: 
   - Windows API `WS_EX_LAYERED` + `WS_EX_TRANSPARENT`
   - 像素级Alpha检测

3. **Live2D渲染**: 
   - SubViewport with `transparent_bg=true`
   - `use_hdr_2d=false` 避免HDR干扰透明度

## 📋 开发路线图

### Phase 1: 核心功能 ✅
- [x] 项目结构搭建
- [x] 窗口透明和穿透
- [x] Live2D模型渲染
- [x] 基础眼动追踪
- [x] 服务架构实现

### Phase 2: 完善功能 🔄
- [x] 窗口拖动优化
- [ ] 动画系统完善
- [ ] 配置管理实现
- [ ] 多模型支持
- [ ] 性能优化

### Phase 3: 用户体验 📋
- [ ] 控制面板UI
- [ ] 快捷键支持
- [ ] 托盘图标
- [ ] 开机自启动
- [ ] 用户文档

### Phase 4: 高级功能 📋
- [ ] 语音交互
- [ ] AI对话集成
- [ ] 表情识别
- [ ] 桌面互动
- [ ] 插件系统

## 🔧 技术债务和已知问题

### 当前问题
1. ⚠️ 眼动追踪在鼠标超出窗口后会重置
   - **影响**: 用户体验略差
   - **优先级**: 中
   - **计划**: Phase 2优化

2. ⚠️ 动画加载时序问题
   - **影响**: 启动时有警告日志
   - **优先级**: 低
   - **计划**: Phase 2修复

3. 📋 缺少错误恢复机制
   - **影响**: 服务初始化失败时可能崩溃
   - **优先级**: 中
   - **计划**: Phase 2添加

### 技术债务
1. 缺少单元测试
2. 缺少性能监控
3. 日志系统需要完善
4. 错误处理不够健壮

## 🎯 增量开发策略

### 开发原则
1. **小步快跑**: 每次只添加一个小功能
2. **持续测试**: 每次修改后验证功能
3. **文档同步**: 代码和文档同步更新
4. **保持简单**: 避免过度设计

### 当前迭代重点
- ✅ 修复C#继承问题
- ✅ 清理冗余文件
- ✅ 完善项目文档
- 🔄 优化眼动追踪
- 📋 实现配置持久化
- 📋 添加控制面板UI

### 下一步计划
1. **本周**: 完善动画系统，修复眼动追踪
2. **下周**: 实现配置管理，添加控制面板
3. **月底**: 性能优化，用户体验改进

## 📊 性能指标

### 目标性能
- **帧率**: 60 FPS
- **内存**: < 200MB
- **CPU**: < 5%（空闲时）
- **启动时间**: < 3秒

### 当前性能（估算）
- **帧率**: ~60 FPS ✅
- **内存**: ~150MB ✅
- **CPU**: ~3% ✅
- **启动时间**: ~2秒 ✅

## 🔐 安全考虑

### 当前实现
- 配置文件存储在用户目录
- 不涉及网络通信
- 不收集用户数据

### 未来考虑
- API密钥管理（AI集成时）
- 数据加密（配置敏感信息）
- 更新验证（自动更新时）

## 📚 参考资源

### 技术文档
- [Godot 官方文档](https://docs.godotengine.org/)
- [Live2D Cubism SDK](https://www.live2d.com/sdk/)
- [gd_cubism GitHub](https://github.com/MizunagiKB/gd_cubism)

### 项目文档
- `docs/architecture/` - 详细架构设计
- `report/` - 开发报告和日志
- `README.md` - 项目总览

## ✅ 检查清单

### 开发环境
- [x] Godot 4.5 安装
- [x] .NET 8 SDK 安装
- [x] gd_cubism 插件配置
- [x] Live2D 模型准备

### 运行状态
- [x] 项目可以启动
- [x] 窗口透明度正常
- [x] Live2D 模型渲染
- [x] 服务正确注册
- [x] 无编译错误

### 功能验证
- [x] 窗口拖动（中键）
- [x] 点击穿透检测
- [ ] 眼动追踪稳定性
- [ ] 动画播放
- [ ] 配置加载保存

---

**版本历史**
- v1.0 (2025-10-22): 初始版本，原型架构设计完成
