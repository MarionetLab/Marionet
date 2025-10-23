# 开发规范文档总结

> 完整的项目规范体系 | 更新日期: 2025-01-22

---

## 📚 文档结构

Marionet 项目的开发规范体系包含以下文档：

### 核心文档

| 文档 | 说明 | 适用对象 |
|------|------|---------|
| [编码规范](./CODING_STANDARDS.md) | 完整的代码风格指南，包含 GDScript 和 C# 规范 | 所有开发者 |
| [贡献指南](./CONTRIBUTING.md) | 如何参与项目开发、提交代码、报告 Bug | 所有贡献者 |
| [快速参考](./QUICK_REFERENCE.md) | 一页纸速查表，快速查找编码规范 | 日常开发 |
| [环境配置](./SETUP_GUIDE.md) | 开发环境配置、工具安装、常见问题 | 新手入门 |

### 配置文件

| 文件 | 说明 | 自动化 |
|------|------|--------|
| `.editorconfig` | 编辑器配置，统一代码格式 | ✅ 自动应用 |
| `.gitmessage` | Git 提交消息模板 | ✅ 自动显示 |
| `.vscode/settings.json` | VSCode 编辑器设置 | ✅ 自动应用 |
| `.vscode/extensions.json` | 推荐的 VSCode 扩展 | ⚠️ 需手动安装 |

### 模板文件

| 文件 | 说明 | 使用场景 |
|------|------|---------|
| `.github/pull_request_template.md` | PR 描述模板 | 创建 PR 时 |
| `.github/ISSUE_TEMPLATE/bug_report.md` | Bug 报告模板 | 报告 Bug 时 |
| `.github/ISSUE_TEMPLATE/feature_request.md` | 功能请求模板 | 提出新功能时 |

---

## 🎯 快速导航

### 我想...

| 需求 | 查看文档 |
|------|---------|
| **开始贡献代码** | [贡献指南](./CONTRIBUTING.md) → [环境配置](./SETUP_GUIDE.md) |
| **查看代码规范** | [快速参考](./QUICK_REFERENCE.md) 或 [完整规范](./CODING_STANDARDS.md) |
| **提交代码** | [Git 提交规范](./CONTRIBUTING.md#git-提交规范) |
| **报告 Bug** | [Bug 报告模板](./.github/ISSUE_TEMPLATE/bug_report.md) |
| **提出新功能** | [功能请求模板](./.github/ISSUE_TEMPLATE/feature_request.md) |
| **配置编辑器** | [环境配置指南](./SETUP_GUIDE.md#编辑器配置) |
| **解决问题** | [常见问题](./SETUP_GUIDE.md#常见问题) |

---

## 📋 规范要点

### GDScript 规范摘要

```gdscript
# ✅ 正确的 GDScript 代码
class_name PlayerController
extends CharacterBody2D

const MAX_SPEED: float = 300.0  # 常量 - SCREAMING_SNAKE_CASE

@export var speed: float = 200.0  # 导出变量 - snake_case
var current_health: int = 100     # 公共变量 - snake_case
var _internal_state: int = 0      # 私有变量 - _snake_case

signal health_changed(new_health: int)  # 信号 - snake_case，过去式

func move_player(direction: Vector2) -> void:  # 函数 - snake_case
	velocity = direction * speed
	move_and_slide()

func _update_animation() -> void:  # 私有函数 - _snake_case
	pass
```

### C# 规范摘要

```csharp
// ✅ 正确的 C# 代码
public partial class WindowService : Node
{
	private const int MaxRetries = 3;  // 常量 - PascalCase
	
	private IntPtr _windowHandle;      // 字段 - _camelCase
	
	public bool IsInitialized { get; set; }  // 属性 - PascalCase
	
	public void SetClickThrough(bool enabled)  // 方法 - PascalCase
	{
		// 参数 - camelCase
		// 局部变量 - camelCase
		int retryCount = 0;
		// ...
	}
	
	private void InitializeWindow()  // 私有方法 - PascalCase
	{
		// ...
	}
}
```

### Git 提交规范摘要

```bash
# 格式
<type>(<scope>): <subject>

# 示例
feat(emotion): 添加心情系统基础框架
fix(animation): 修复动画播放卡顿问题
refactor(core): 重构服务定位器实现
docs(api): 更新 API 文档

# 分支命名
git checkout -b feat/add-emotion-system
git checkout -b fix/eye-tracking-bug
```

---

## 🛠️ 工具配置

### 必需工具

- ✅ **Godot Engine 4.3+** (.NET 版本)
- ✅ **.NET SDK 8.0+**
- ✅ **Git**

### 推荐工具

- 📝 **VSCode** + Godot Tools 扩展
- 🔍 **GitKraken** 或 GitHub Desktop
- 📖 **Markdown Preview** 扩展

### 自动化配置

所有配置文件已包含在项目中，克隆项目后：

1. **编辑器配置** - 自动应用（通过 `.editorconfig`）
2. **提交模板** - 需运行一次配置命令
3. **扩展推荐** - VSCode 会自动提示安装

```bash
# 一次性配置 Git 提交模板
git config --local commit.template .gitmessage
```

---

## ✅ 检查清单

### 新开发者入门

- [ ] 阅读 [贡献指南](./CONTRIBUTING.md)
- [ ] 阅读 [快速参考](./QUICK_REFERENCE.md)
- [ ] 按照 [环境配置](./SETUP_GUIDE.md) 设置开发环境
- [ ] 配置 Git 提交模板
- [ ] 安装推荐的编辑器扩展
- [ ] 验证环境配置（运行测试）

### 提交代码前

- [ ] 代码符合 [编码规范](./CODING_STANDARDS.md)
- [ ] 所有函数有类型注解
- [ ] 添加了必要的注释
- [ ] 提交消息符合规范
- [ ] 已测试所有功能
- [ ] 没有遗留调试代码

### 创建 PR 前

- [ ] 从 `dev` 分支创建
- [ ] 分支名称符合规范
- [ ] 提交历史清晰
- [ ] 解决了所有冲突
- [ ] 填写完整的 PR 描述
- [ ] 通过所有检查

---

## 📈 规范层级

### Level 1 - 必须遵守（MUST）

- ✅ 文件编码 UTF-8
- ✅ 命名约定（类名、函数名、变量名）
- ✅ 类型注解（所有公共 API）
- ✅ Git 提交消息格式

### Level 2 - 强烈建议（SHOULD）

- ⚠️ 行长度限制（100 字符）
- ⚠️ 函数长度限制（50 行）
- ⚠️ 参数数量限制（5 个）
- ⚠️ 文档注释（公共 API）

### Level 3 - 可选（MAY）

- 💡 代码组织（分组注释）
- 💡 TODO 注释格式
- 💡 性能注释

---

## 🔄 更新历史

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0 | 2025-01-22 | 初始版本，包含完整的规范体系 |

---

## 📞 获取帮助

### 遇到问题？

1. **查看文档** - 首先查看相关文档
2. **搜索 Issue** - 搜索是否有类似问题
3. **提问** - 创建新 Issue 并详细描述问题

### 文档反馈

如果你发现文档有错误或可以改进的地方：

1. 创建 Issue 说明问题
2. 或直接提交 PR 修改文档

---

## 🎓 学习路径

### 新手开发者

```
1. 阅读 贡献指南 （15 分钟）
   ↓
2. 配置开发环境 （30 分钟）
   ↓
3. 阅读 快速参考 （10 分钟）
   ↓
4. 查看代码示例 （30 分钟）
   ↓
5. 开始第一个 PR （1-2 小时）
```

### 经验开发者

```
1. 快速浏览 快速参考 （5 分钟）
   ↓
2. 了解项目特定规则 （10 分钟）
   ↓
3. 开始贡献
```

---

## 📊 规范统计

### 文档覆盖

- ✅ **GDScript** - 完整覆盖（命名、格式、最佳实践）
- ✅ **C#** - 完整覆盖（命名、格式、异步编程）
- ✅ **Git** - 完整覆盖（提交、分支、PR）
- ✅ **文档** - 完整覆盖（Markdown、注释）
- ✅ **项目结构** - 完整覆盖（目录、文件组织）

### 自动化程度

- 🤖 **编辑器格式化** - 85% 自动化（通过 EditorConfig）
- 🤖 **代码检查** - 30% 自动化（通过 Linter，待完善）
- 🤖 **提交规范** - 50% 自动化（模板提示）
- 📝 **手动审查** - 仍需人工 Code Review

---

## 🌟 最佳实践

### 代码质量

1. **先保证正确，再考虑优化**
2. **代码是写给人看的，机器只是顺便执行**
3. **简单 > 复杂 > 错误**
4. **命名应该自解释**

### 协作

1. **小步提交，频繁推送**
2. **PR 应该聚焦单一主题**
3. **及时回应 Review 意见**
4. **保持友好和专业的沟通**

### 文档

1. **代码即文档，文档即代码**
2. **注释解释"为什么"而不是"是什么"**
3. **保持文档与代码同步**
4. **API 文档是公共契约**

---

## 🔗 相关链接

### 外部规范参考

- [Godot GDScript 风格指南](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Google C# 风格指南](https://google.github.io/styleguide/csharp-style.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)

### 项目文档

- [项目 README](../README.md)
- [项目愿景](./docs/vision/vision.md)
- [架构设计](./docs/architecture/architecture.md)

---

<p align="center">
  <strong>规范让协作更高效</strong><br>
  <i>一致的代码风格是团队协作的基石</i><br>
  <sub>Marionet Project | v1.0 | 2025-01-22</sub>
</p>

