# Marionet 项目结构

**更新日期**: 2025年10月22日  
**状态**: 重构后的清晰结构

## 📁 目录结构

```
Marionet/
├── engine/                          # Godot 引擎项目
│   ├── core/                       # 核心系统
│   │   ├── Main.gd                # ✅ 主入口（新架构）
│   │   ├── Constants.gd           # ✅ 全局常量定义
│   │   └── ServiceLocator.gd      # ✅ 服务定位器
│   │
│   ├── renderer/                   # 渲染层
│   │   ├── services/              # 服务层（新架构）
│   │   │   ├── Window/           # 窗口相关服务
│   │   │   │   ├── WindowService.cs      # ✅ 窗口管理
│   │   │   │   └── MouseDetection.cs     # ✅ 鼠标检测
│   │   │   ├── Live2D/           # Live2D相关服务
│   │   │   │   ├── ModelService.gd       # ✅ 模型管理
│   │   │   │   ├── AnimationService.gd   # ✅ 动画管理
│   │   │   │   └── EyeTrackingService.gd # ✅ 眼动追踪
│   │   │   └── Config/           # 配置相关服务
│   │   │       ├── ConfigService.gd      # ✅ 配置管理
│   │   │       └── ConfigModel.gd        # ✅ 配置模型
│   │   ├── ui/                    # UI组件
│   │   │   └── ControlPanel/     # 控制面板
│   │   └── scenes/                # 场景文件
│   │       ├── L2D.tscn          # Live2D场景
│   │       └── ControlPanel.tscn  # 控制面板场景
│   │
│   ├── addons/                     # Godot插件
│   │   └── gd_cubism/            # Live2D Cubism插件
│   │       ├── bin/              # 二进制文件
│   │       ├── cs/               # C#绑定
│   │       └── res/              # 资源文件
│   │
│   ├── Live2D/                     # Live2D资源
│   │   └── models/               # 模型文件
│   │       ├── hiyori_pro_zh/   # 日向模型
│   │       └── mao_pro_zh/      # 猫模型
│   │
│   ├── legacy/                     # 历史代码（仅供参考）
│   │   └── src/                  # 旧架构代码
│   │
│   ├── icon/                       # 项目图标
│   ├── project.godot              # ✅ Godot项目配置
│   ├── renderer.csproj            # ✅ C#项目配置
│   ├── renderer.sln               # ✅ Visual Studio解决方案
│   ├── GlobalUsings.cs            # ✅ 全局Using声明
│   └── settings_example.json      # 配置示例
│
├── bridge/                         # 桥接层（计划中）
│   └── grpc/                      # gRPC通信
│
├── docs/                           # 项目文档
│   └── docs/                      
│       ├── architecture/          # 架构文档
│       ├── api/                   # API文档
│       └── guides/                # 使用指南
│
├── .gitignore                      # Git忽略配置
├── .gitattributes                  # Git LFS配置
├── README.md                       # 项目说明
├── CONFIG_CHECK_REPORT.md          # 配置检查报告
├── CLEANUP_PLAN.md                 # 清理计划
├── FIXES_APPLIED.md                # 修复记录
└── PROJECT_STRUCTURE.md            # 本文档

```

## 🏗️ 架构说明

### 核心层 (core/)
**职责**: 系统初始化、服务管理、全局常量

- **Main.gd**: 应用入口，负责服务注册和初始化
- **ServiceLocator.gd**: 服务定位器，解耦服务依赖
- **Constants.gd**: 全局常量定义

### 服务层 (renderer/services/)
**职责**: 业务逻辑封装，功能模块化

#### Window服务
- **WindowService.cs**: Windows API集成，窗口属性管理
- **MouseDetection.cs**: 像素级透明度检测，点击穿透控制

#### Live2D服务
- **ModelService.gd**: 模型加载、切换、生命周期管理
- **AnimationService.gd**: 动画播放、队列管理
- **EyeTrackingService.gd**: 眼动追踪逻辑

#### Config服务
- **ConfigService.gd**: 配置加载、保存、管理
- **ConfigModel.gd**: 配置数据模型

### 表现层 (renderer/ui/, scenes/)
**职责**: UI展示、场景组织

- **L2D.tscn**: Live2D渲染场景
- **ControlPanel.tscn**: 控制面板UI

## 📦 关键文件说明

### 项目配置
- `project.godot`: Godot引擎配置，包含自动加载单例定义
- `renderer.csproj`: C#项目配置
- `GlobalUsings.cs`: 全局Using声明，简化C#代码

### 自动加载单例
在 `project.godot` 中定义：
```ini
[autoload]
ServiceLocator="*res://core/ServiceLocator.gd"
EngineConstants="*res://core/Constants.gd"
WindowService="*res://renderer/services/Window/WindowService.cs"
MouseDetection="*res://renderer/services/Window/MouseDetection.cs"
```

## 🗑️ 已清理的文件

### 删除的冗余文件
- `engine/src/` 整个目录（48个文件）
  - 旧的Manager类
  - 旧的MouseDetection实现
  - 旧的main.gd
  - 等等...

### 删除的临时文件
- `engine/renderer.csproj.old*`（6个备份文件）
- `engine/addons/gd_cubism/bin/~*.dll`（临时DLL）
- `engine/addons/gd_cubism/bin/*.TMP`（临时文件）

### 保留的文件
- `engine/legacy/`: 完整保留作为历史参考

## 🎯 开发指南

### 添加新服务
1. 在 `renderer/services/` 下创建服务文件
2. 在 `Main.gd` 中注册到 `ServiceLocator`
3. 通过 `ServiceLocator.get_service()` 获取服务

### 添加新功能
1. 确定功能所属层级（核心/服务/表现）
2. 创建对应的服务或组件
3. 更新文档

### 修改配置
1. 修改 `settings_example.json`
2. 使用 `ConfigService` 加载配置
3. 通过 `EngineConstants` 访问常量

## 📊 项目统计

### 代码行数（估算）
- GDScript: ~2000行
- C#: ~500行
- 总计: ~2500行

### 文件数量
- 源代码文件: ~20个
- 场景文件: ~2个
- 配置文件: ~5个
- 文档文件: ~10个

### 目录数量
- 核心目录: 3个
- 服务目录: 3个
- 资源目录: 2个

## 🔧 维护指南

### 定期检查
- [ ] 检查是否有新的临时文件
- [ ] 检查是否有冗余代码
- [ ] 更新文档反映实际结构
- [ ] 验证所有路径引用正确

### 代码审查要点
- [ ] 新代码是否放在正确的目录
- [ ] 是否符合架构设计
- [ ] 是否有适当的文档
- [ ] 是否有必要的测试

## 📚 相关文档

- [架构设计](/docs/docs/architecture/architecture.md)
- [重构状态](/docs/docs/architecture/refactor-status.md)
- [开发指南](/docs/docs/development.md)
- [API文档](/docs/docs/api/)

## ✅ 验证清单

项目结构清理后验证：
- [x] src目录已删除
- [x] 临时文件已清理
- [x] legacy目录保留
- [x] 新架构文件完整
- [x] 项目可以启动
- [x] 文档已更新
