# Legacy 代码目录

**状态**: 只读，仅供参考  
**用途**: 历史代码备份，重构前的原始实现

## 说明

此目录包含项目重构前的旧架构代码，保留用于：
1. 参考旧实现逻辑
2. 对比新旧架构差异
3. 回溯某些设计决策

## 注意事项

1. 此目录中的代码不会被当前系统使用
2. 文件中可能有引用错误（因为src目录已删除）
3. 不要修改此目录中的文件
4. 不要在新代码中引用此目录的文件

## 目录内容

### src/ 目录
包含旧架构的所有源文件：
- AnimationManager.gd
- ApiManager.cs
- ConfigManager.gd
- ControlPanel.gd
- ControlPanelManager.gd
- EyeTrackingManager.gd
- HitAreaManager.gd
- main.gd
- ModelManager.gd
- models.gd
- MouseDetection.cs
- sub_viewport.gd

## 新旧架构对比

### 旧架构（此目录）
```
src/
├── main.gd                    # 单一入口
├── *Manager.gd                # 管理器模式
├── ApiManager.cs              # Windows API
└── MouseDetection.cs          # 鼠标检测
```

### 新架构（当前系统）
```
core/
├── Main.gd                    # 主入口
├── ServiceLocator.gd          # 服务定位器
└── Constants.gd               # 全局常量

renderer/services/
├── Window/                    # 窗口服务
├── Live2D/                    # Live2D服务
└── Config/                    # 配置服务
```

## 如需删除

如果确定不再需要参考旧代码，可以删除此目录：
```bash
rm -rf engine/legacy/
```

或在Windows PowerShell:
```powershell
Remove-Item -Recurse -Force engine\legacy\
```

---

**创建日期**: 2025-10-22  
**维护**: 只读，不再更新
