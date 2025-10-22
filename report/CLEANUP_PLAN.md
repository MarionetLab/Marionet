# 项目清理计划

**日期**: 2025年10月22日  
**目标**: 清理冗余文件，保持开发环境清晰

## 📋 冗余文件识别

### 1. engine/src/ 目录 - 旧架构文件
**状态**: ⚠️ 应该删除（已被新架构替代）

这些文件与新架构冲突：
- `engine/src/MouseDetection.cs` - 被 `engine/renderer/services/Window/MouseDetection.cs` 替代
- `engine/src/ApiManager.cs` - 被 `WindowService.cs` 替代
- `engine/src/main.gd` - 被 `engine/core/Main.gd` 替代
- `engine/src/*Manager.gd` - 被 `engine/renderer/services/` 下的服务替代

### 2. engine/legacy/ 目录 - 历史备份
**状态**: ✅ 保留（作为历史参考）

这是旧代码的备份，可以保留用于参考。

## 🗑️ 删除文件列表

### 优先删除（与新架构冲突）

#### C# 文件
- [ ] `engine/src/MouseDetection.cs`
- [ ] `engine/src/MouseDetection.cs.uid`
- [ ] `engine/src/ApiManager.cs`
- [ ] `engine/src/ApiManager.cs.uid`

#### GDScript 文件
- [ ] `engine/src/main.gd`
- [ ] `engine/src/main.gd.uid`
- [ ] `engine/src/AnimationManager.gd`
- [ ] `engine/src/AnimationManager.gd.uid`
- [ ] `engine/src/ConfigManager.gd`
- [ ] `engine/src/ConfigManager.gd.uid`
- [ ] `engine/src/ControlPanel.gd`
- [ ] `engine/src/ControlPanel.gd.uid`
- [ ] `engine/src/ControlPanelManager.gd`
- [ ] `engine/src/ControlPanelManager.gd.uid`
- [ ] `engine/src/EyeTrackingManager.gd`
- [ ] `engine/src/EyeTrackingManager.gd.uid`
- [ ] `engine/src/HitAreaManager.gd`
- [ ] `engine/src/HitAreaManager.gd.uid`
- [ ] `engine/src/ModelManager.gd`
- [ ] `engine/src/ModelManager.gd.uid`
- [ ] `engine/src/models.gd`
- [ ] `engine/src/models.gd.uid`
- [ ] `engine/src/sub_viewport.gd`
- [ ] `engine/src/sub_viewport.gd.uid`

## ✅ 保留文件

### engine/core/ - 核心系统
- `Main.gd` - 新的主入口
- `Constants.gd` - 全局常量
- `ServiceLocator.gd` - 服务定位器

### engine/renderer/services/ - 新架构服务
- `Window/WindowService.cs` - 窗口服务
- `Window/MouseDetection.cs` - 鼠标检测
- `Live2D/ModelService.gd` - 模型服务
- `Live2D/AnimationService.gd` - 动画服务
- `Live2D/EyeTrackingService.gd` - 眼动追踪服务
- `Config/ConfigService.gd` - 配置服务
- `Config/ConfigModel.gd` - 配置模型

### engine/legacy/ - 历史备份
- 保留整个目录作为参考

## 🎯 清理后的目录结构

```
engine/
├── core/                    # 核心系统
│   ├── Main.gd             # 主入口
│   ├── Constants.gd        # 全局常量
│   └── ServiceLocator.gd   # 服务定位器
├── renderer/               # 渲染相关
│   ├── services/          # 服务层
│   │   ├── Window/       # 窗口服务
│   │   ├── Live2D/       # Live2D服务
│   │   └── Config/       # 配置服务
│   └── scenes/           # 场景文件
├── legacy/                # 历史备份
│   └── src/              # 旧代码
├── Live2D/               # Live2D资源
└── project.godot         # 项目配置
```

## 📊 清理统计

### 删除文件数量
- C# 文件: 4个
- GDScript 文件: 22个
- UID 文件: 22个
- **总计**: 48个文件

### 保留文件
- 核心文件: ~10个
- 服务文件: ~15个
- 场景文件: ~5个
- Legacy备份: 全部保留

## 🚀 执行清理

### 手动清理步骤
1. 备份当前状态（可选）
2. 删除 `engine/src/` 目录
3. 验证项目运行正常
4. 提交清理后的代码

### 自动清理命令
```bash
# 删除整个 src 目录
rm -rf engine/src/

# 或者在 Windows PowerShell
Remove-Item -Recurse -Force engine\src\
```

## ⚠️ 注意事项

1. **备份**: 在删除前确保有Git提交或其他备份
2. **验证**: 删除后运行项目确保功能正常
3. **Legacy**: 保留legacy目录以供参考
4. **文档**: 更新相关文档反映新结构

## ✅ 验证清单

清理后验证：
- [ ] 项目可以启动
- [ ] 窗口透明度正常
- [ ] 窗口拖动正常
- [ ] Live2D模型加载正常
- [ ] 服务正常注册
- [ ] 无引用错误

## 📝 后续工作

清理完成后：
1. 更新 README.md 反映新结构
2. 更新架构文档
3. 添加迁移指南
4. 创建开发环境设置文档
