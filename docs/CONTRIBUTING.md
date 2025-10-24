# 贡献指南

> 欢迎为 Marionet 项目做出贡献！

---

## 快速开始

### 1. Fork 并 Clone 项目

```bash
# Fork 项目到你的 GitHub 账户，然后克隆
git clone https://github.com/YOUR_USERNAME/Marionet.git
cd Marionet

# 添加上游仓库
git remote add upstream https://github.com/ORIGINAL_OWNER/Marionet.git
```

### 2. 创建分支

```bash
# 同步最新代码
git fetch upstream
git checkout dev
git merge upstream/dev

# 创建功能分支
git checkout -b feat/your-feature-name
```

### 3. 开发和测试

```bash
# 打开 Godot 编辑器
cd renderer
godot project.godot

# 进行开发...
# 测试你的更改...
```

### 4. 提交代码

```bash
# 添加更改
git add .

# 提交（遵循提交规范）
git commit -m "feat(module): 添加新功能的描述"

# 推送到你的仓库
git push origin feat/your-feature-name
```

### 5. 创建 Pull Request

1. 访问你的 Fork 仓库
2. 点击 "Pull Request"
3. 选择 `dev` 作为目标分支
4. 填写 PR 描述（会自动加载模板）
5. 提交并等待自动 CI 检查
6. 等待 Code Review

**CI 自动检查流程**:
- ✅ GDScript 语法和代码风格检查
- ✅ C# 代码编译检查
- ✅ Godot 项目完整性验证
- ✅ 文件命名规范检查
- ✅ 文档完整性检查
- ✅ 安全扫描（敏感信息泄露）

如果 CI 检查失败，请根据错误信息修复后重新提交。

---

## 开发规范

### 必读文档

在开始贡献之前，请务必阅读：

- 📖 **[编码规范](./CODING_STANDARDS.md)** - 代码风格和最佳实践
- 📖 **[架构文档](./docs/architecture/architecture.md)** - 项目架构设计
- 📖 **[项目愿景](./docs/vision/vision.md)** - 项目目标和理念

### 代码风格快速参考

#### GDScript

```gdscript
# ✅ 正确
class_name PlayerController
extends CharacterBody2D

const MAX_SPEED: float = 300.0

var current_speed: float = 0.0
var _internal_state: int = 0

func move_player(direction: Vector2) -> void:
	velocity = direction * MAX_SPEED
	move_and_slide()

func _update_animation() -> void:
	pass
```

#### C#

```csharp
// ✅ 正确
public partial class WindowService : Node
{
	private const int MaxRetries = 3;
	
	private IntPtr _windowHandle;
	
	public bool IsInitialized { get; private set; }
	
	public void SetClickThrough(bool enabled)
	{
		// Implementation
	}
	
	private void InitializeWindow()
	{
		// Implementation
	}
}
```

### 提交消息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

**常用类型**:
- `feat` - 新功能
- `fix` - Bug 修复
- `refactor` - 重构
- `docs` - 文档
- `test` - 测试
- `chore` - 构建/工具

**示例**:
```
feat(emotion): 添加心情系统基础框架

实现了基础的心情状态管理：
- 添加 MoodType 枚举
- 实现 MoodModel 类
- 添加心情值衰减机制

Closes #123
```

---

## 贡献流程

### 报告 Bug

**创建 Issue 时包含**:

1. **标题**: 简洁描述问题
2. **环境**: 操作系统、Godot 版本等
3. **重现步骤**: 详细的步骤
4. **期望行为**: 应该发生什么
5. **实际行为**: 实际发生了什么
6. **截图/日志**: 如果有的话

**Bug 报告模板**:

```markdown
## 环境信息
- OS: Windows 11 / macOS 14 / Ubuntu 22.04
- Godot 版本: 4.3.0
- 项目版本: v0.1.0

## 问题描述
简洁清晰地描述 bug

## 重现步骤
1. 打开 '...'
2. 点击 '....'
3. 滚动到 '....'
4. 看到错误

## 期望行为
应该...

## 实际行为
实际...

## 截图
如果适用，添加截图帮助解释问题

## 日志输出
```
粘贴相关日志
```

## 额外信息
其他可能有用的信息
```

### 提出新功能

**创建 Feature Request 时包含**:

1. **问题陈述**: 这个功能解决什么问题？
2. **解决方案**: 你希望如何实现？
3. **替代方案**: 还考虑过哪些方案？
4. **额外信息**: 截图、原型等

**功能请求模板**:

```markdown
## 功能描述
清晰简洁地描述你想要的功能

## 动机
为什么需要这个功能？它解决什么问题？

## 建议的实现
描述你希望如何实现这个功能

## 替代方案
描述你考虑过的其他解决方案

## 额外信息
任何其他有助于理解的信息
```

### 提交 Pull Request

#### PR 检查清单

提交 PR 前确保：

- [ ] 代码遵循 [编码规范](./CODING_STANDARDS.md)
- [ ] 所有测试通过（本地 + CI 自动检查）
- [ ] 添加了必要的文档
- [ ] 提交消息符合规范
- [ ] 代码已在本地测试
- [ ] 没有引入新的警告或错误
- [ ] 更新了 CHANGELOG（如果是重要功能）
- [ ] CI 自动检查全部通过（GDScript、C#、文档等）

#### PR 描述模板

```markdown
## 变更类型
- [ ] 新功能 (feat)
- [ ] Bug 修复 (fix)
- [ ] 重构 (refactor)
- [ ] 文档 (docs)
- [ ] 测试 (test)
- [ ] 其他 (chore)

## 变更说明
简要描述这个 PR 做了什么

## 相关 Issue
Closes #issue_number

## 测试
描述你如何测试这些更改

## 截图（如果适用）
添加截图展示变更效果

## 检查清单
- [ ] 代码遵循项目规范
- [ ] 已添加/更新文档
- [ ] 已测试所有功能
- [ ] 没有引入新的警告
- [ ] 提交消息符合规范
```

#### Review 流程

1. **提交 PR** - 填写完整的 PR 描述（使用提供的模板）
2. **自动检查** - CI/CD 自动运行检查（5-10 分钟）
   - GDScript 语法检查
   - C# 编译验证
   - 代码风格检查
   - 文档完整性验证
   - 安全扫描
3. **代码审查** - 维护者进行 Code Review
4. **修改反馈** - 根据反馈和 CI 结果修复问题
5. **合并** - 所有检查通过且审查完成后合并

---

## 开发环境设置

### 必需软件

1. **Godot Engine 4.3+**
   - 下载: https://godotengine.org/download
   - 需要 .NET 版本

2. **.NET SDK 8.0+**
   - 下载: https://dotnet.microsoft.com/download
   - C# 支持必需

3. **Git**
   - 下载: https://git-scm.com/downloads

### 推荐工具

1. **VSCode** 或 **Rider**
   - 更好的代码编辑体验
   - 推荐插件:
     - GDScript (for VSCode)
     - C# (for VSCode)
     - EditorConfig

2. **Git GUI 工具**
   - GitKraken
   - GitHub Desktop
   - SourceTree

### 环境配置

#### 1. 克隆项目

```bash
git clone https://github.com/YOUR_USERNAME/Marionet.git
cd Marionet
```

#### 2. 配置 Godot

```bash
# 在 Godot 编辑器中打开项目
cd renderer
godot project.godot

# 或使用命令行
godot --path renderer --editor
```

#### 3. 构建 C# 项目

在 Godot 编辑器中:
- 点击 `Build` → `Build Solution`
- 等待编译完成

#### 4. 配置 EditorConfig

项目根目录已包含 `.editorconfig`，大多数编辑器会自动识别。

#### 5. 安装 Git Hooks（可选）

```bash
# 安装 pre-commit hook
cp .git/hooks/pre-commit.sample .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

---

## 测试

### 运行测试

```bash
# Godot 中运行测试场景
godot --path renderer --headless --quit res://tests/test_main.tscn

# C# 单元测试（如果有）
dotnet test renderer/tests/
```

### 编写测试

**GDScript 测试示例**:

```gdscript
# tests/test_model_service.gd
extends GutTest

func before_each():
	# 设置测试环境
	pass

func test_model_loading():
	var service = ModelService.new()
	assert_not_null(service, "服务应该被创建")
	
	service.load_model(0)
	assert_eq(service.get_current_model_index(), 0, "模型索引应该是 0")

func after_each():
	# 清理测试环境
	pass
```

**C# 测试示例**:

```csharp
// tests/WindowServiceTests.cs
using Xunit;

public class WindowServiceTests
{
	[Fact]
	public void SetClickThrough_ShouldChangeState()
	{
		// Arrange
		var service = new WindowService();
		
		// Act
		service.SetClickThrough(true);
		
		// Assert
		Assert.True(service.IsClickThrough);
	}
}
```

---

## 文档贡献

### 文档类型

1. **代码文档**
   - GDScript: 使用 `##` 注释
   - C#: 使用 XML 文档注释

2. **Markdown 文档**
   - README, 设计文档, API 文档
   - 放在 `docs/` 目录

3. **注释**
   - 代码中的行内注释
   - 解释 **为什么** 而不是 **是什么**

### 文档规范

```markdown
# 标题（使用 Heading 1）

> 简短描述

## 主要章节（Heading 2）

### 子章节（Heading 3）

#### 详细内容（Heading 4）

- 使用列表
- 保持简洁

\```gdscript
# 代码示例要有语法高亮
func example():
	pass
\```

> **注意**: 重要提示使用引用块
```

---

## CI/CD 持续集成

### 自动化检查

本项目使用 GitHub Actions 进行自动化检查，确保代码质量：

#### 1. 代码推送到 dev/main 分支时
自动触发完整的 CI 检查流程

#### 2. 创建 PR 时
运行以下检查：

**基础检查**:
- **GDScript 语法**: 使用 `gdlint` 检查代码风格
- **C# 编译**: 验证 C# 代码可以正常编译
- **Godot 项目**: 验证项目文件完整性

**代码质量**:
- **命名规范**: 检查文件和代码命名是否符合规范
- **代码风格**: 行长度、缩进、注释等
- **安全扫描**: 检测硬编码的敏感信息

**文档检查**:
- **必需文档**: 确保核心文档存在
- **Markdown 格式**: 检查文档格式正确性
- **文档同步**: 提醒大改动需要更新文档

**PR 格式**:
- **标题格式**: 必须符合 Conventional Commits
- **描述完整性**: PR 描述不能过短
- **源分支检查**: 不能直接从 main 创建 PR

### 本地运行检查

在提交前，可以在本地运行检查：

```bash
# GDScript 代码风格检查
pip install gdtoolkit
cd engine
gdlint renderer/ core/

# C# 编译检查
dotnet build engine/MarionetEngine.csproj
```

### CI 失败处理

如果 CI 检查失败：

1. **查看 GitHub Actions 日志**
   - 进入 PR 页面
   - 点击 "Details" 查看失败的检查
   - 阅读错误信息

2. **常见问题**:
   - **GDScript 语法错误**: 检查代码风格，运行 `gdlint`
   - **C# 编译失败**: 在本地运行 `dotnet build` 修复
   - **命名不规范**: 确保文件名使用 PascalCase
   - **PR 标题格式**: 使用 `feat(scope): description` 格式

3. **修复并重新提交**:
   ```bash
   # 修复问题后
   git add .
   git commit -m "fix: 修复 CI 检查问题"
   git push
   ```
   CI 会自动重新运行检查

### 忽略的文件

以下文件不会触发 CI 检查：
- `.gitignore` 中列出的文件
- `engine/addons/gd_cubism/bin/` 目录（插件二进制）
- Live2D 模型文件

### CI 配置文件

- `.github/workflows/ci.yml` - 主 CI 流程
- `.github/workflows/pr-check.yml` - PR 专用检查
- `.gdlintrc` - GDScript 代码风格配置

---

## 沟通渠道

### Issue 讨论

- 使用 GitHub Issues 讨论功能和 Bug
- 添加适当的标签（bug, enhancement, question）
- @提及相关人员

### 代码审查

- 提出建设性意见
- 解释 **为什么** 而不是只说 **怎么做**
- 礼貌和尊重

### 寻求帮助

如果遇到问题：

1. 查看 [文档](./README.md)
2. 搜索现有的 Issues
3. 创建新 Issue 并详细描述问题

---

## 许可证

通过提交代码，你同意将你的贡献按照项目的 [MIT License](../LICENSE.md) 进行许可。

---

## 行为准则

### 我们的承诺

为了营造开放和友好的环境，我们承诺:

- ✅ 使用友好和包容的语言
- ✅ 尊重不同的观点和经验
- ✅ 优雅地接受建设性批评
- ✅ 关注对社区最有利的事情
- ✅ 对其他社区成员表示同理心

### 不可接受的行为

- ❌ 使用性别化的语言或图像
- ❌ 挑衅、侮辱或贬损性评论
- ❌ 公开或私下骚扰
- ❌ 未经许可发布他人私人信息
- ❌ 其他不专业或不受欢迎的行为

---

## 致谢

感谢所有为 Marionet 项目做出贡献的开发者！

你的每一个 PR、Issue、建议都在帮助这个项目变得更好。

---

## 常见问题

### Q: 我不熟悉 Godot/GDScript，可以贡献吗？

A: 当然可以！你可以：
- 改进文档
- 报告 Bug
- 提出建议
- 帮助测试

### Q: 如何选择合适的 Issue？

A: 查找标签为 `good first issue` 或 `help wanted` 的 Issue。

### Q: PR 多久会被审查？

A: 通常在 3-7 天内。如果超过一周没有回应，可以礼貌地催一下。

### Q: 我的 PR 被拒绝了怎么办？

A: 不要灰心！阅读反馈，改进代码，或者讨论其他方案。

### Q: 可以直接修改 main 分支吗？

A: 不可以。请始终从 `dev` 分支创建功能分支，然后提交 PR。

### Q: CI 检查一直失败怎么办？

A: 先查看具体错误信息，常见问题包括代码风格、编译错误等。可以在本地运行 `gdlint` 和 `dotnet build` 提前检查。

### Q: 为什么我的 PR 没有触发 CI？

A: 检查是否正确配置了 GitHub Actions 权限，或者查看仓库的 Actions 标签页是否有错误日志。

---

<p align="center">
  <strong>感谢你的贡献！</strong><br>
  <i>每一行代码都让 Marionet 变得更好</i><br>
  <sub>Happy Coding! 🎉</sub>
</p>

