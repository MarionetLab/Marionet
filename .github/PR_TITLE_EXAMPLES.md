# PR 标题格式参考

## 📋 推荐格式（Conventional Commits）

```
<type>(<scope>): <description>

type: 变更类型
scope: 影响范围（可选）
description: 简短描述
```

## 🎯 常用类型

| 类型 | 说明 | 何时使用 |
|------|------|----------|
| `feat` | 新功能 | 添加新功能、新特性 |
| `fix` | Bug 修复 | 修复问题、错误 |
| `chore` | 构建/工具 | CI配置、依赖更新、构建脚本 |
| `docs` | 文档 | README、文档、注释更新 |
| `refactor` | 重构 | 代码重构、不改变功能 |
| `style` | 代码风格 | 格式化、缩进、命名 |
| `test` | 测试 | 添加/修改测试 |
| `perf` | 性能优化 | 提升性能的改动 |

## ✅ 好的示例

### 标准格式（推荐）
```
feat(renderer): 添加 Live2D 动画系统
fix(core): 修复服务定位器初始化问题
chore(ci): 添加 GitHub Actions CI/CD 配置
docs(readme): 更新安装说明和快速开始指南
refactor(model): 优化模型加载逻辑
perf(animation): 优化动画渲染性能
test(service): 添加配置服务单元测试
style: 统一代码缩进格式
```

### 无 scope（也可以）
```
feat: 添加心情系统
fix: 修复内存泄漏
chore: 更新依赖版本
docs: 完善贡献指南
```

### 多行描述（PR 描述中补充）
```
标题: feat(memory): 添加长期记忆系统

PR 描述中详细说明:
- 实现记忆存储和检索
- 支持记忆衰减
- 添加记忆优先级
```

## ⚠️ 可接受但不推荐

```
Add CI/CD configuration
Update documentation
Fix renderer bug
Improve performance
```

这些标题可以通过 CI，但建议改为 Conventional Commits 格式。

## ❌ 不好的示例

```
❌ Dev                    （太短、无意义）
❌ update                 （太模糊）
❌ fix                    （没说修复什么）
❌ 更新                   （太模糊）
❌ WIP                    （不应提交 WIP 到 main）
❌ merge                  （应该说明合并什么）
❌ .                      （无意义）
```

## 🎨 Scope 参考

根据项目结构，常用的 scope：

- `renderer` - 渲染相关
- `core` - 核心系统
- `service` - 服务模块
- `model` - 模型相关
- `ui` - 用户界面
- `config` - 配置系统
- `ci` - CI/CD
- `docs` - 文档
- `build` - 构建系统
- `deps` - 依赖管理

## 📝 实际使用建议

### 如果你的改动是...

**添加 CI/CD 配置**:
```
✅ chore(ci): 添加 GitHub Actions CI/CD 自动化检查
✅ feat(ci): 添加代码质量自动化检查流程
```

**修复一个 Bug**:
```
✅ fix(renderer): 修复 Live2D 模型加载失败问题
✅ fix(core): 修复服务初始化顺序错误
```

**添加新功能**:
```
✅ feat(emotion): 添加基础心情系统
✅ feat(memory): 实现长期记忆存储
```

**更新文档**:
```
✅ docs(contributing): 更新贡献指南和 CI 说明
✅ docs: 添加 CI/CD 使用指南
```

**重构代码**:
```
✅ refactor(service): 优化服务定位器实现
✅ refactor: 统一错误处理逻辑
```

## 🔧 修改 PR 标题

在 GitHub PR 页面：
1. 点击标题旁边的 "Edit" 按钮
2. 修改为符合格式的标题
3. 保存后 CI 自动重新运行

## 💡 为什么要规范标题？

1. **自动生成 CHANGELOG** - 可以自动分类变更
2. **清晰的历史记录** - 一眼看出每个提交做了什么
3. **版本管理** - 自动判断版本号升级（major/minor/patch）
4. **团队协作** - 统一的格式降低沟通成本

---

**参考资源**:
- [Conventional Commits 官方规范](https://www.conventionalcommits.org/)
- [Angular 提交规范](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)

