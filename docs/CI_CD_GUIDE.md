# CI/CD 持续集成指南

> Marionet 项目的自动化检查和部署指南

---

## 📋 概览

本项目使用 GitHub Actions 实现自动化的代码质量检查和持续集成。

### 触发时机

- **Push 到 `dev` 或 `main` 分支**: 运行完整的 CI 检查
- **创建 PR 到 `main`**: 运行 PR 专用检查 + 完整 CI
- **更新 PR**: 自动重新运行所有检查

---

## 🔍 检查内容

### 1. GDScript 代码检查

**工具**: `gdlint` (gdtoolkit 4.x)

**检查项**:
- 语法错误
- 代码风格（缩进、行长度、命名等）
- 复杂度分析
- 最佳实践违规

**配置文件**: `.gdlintrc`

**本地运行**:
```bash
pip install gdtoolkit==4.*
cd engine
gdlint renderer/ core/
```

### 2. C# 代码编译

**工具**: .NET SDK 8.0

**检查项**:
- 编译错误
- 类型检查
- 语法验证

**本地运行**:
```bash
cd engine
dotnet build MarionetEngine.csproj --configuration Release
```

### 3. Godot 项目验证

**工具**: Godot Headless 模式

**检查项**:
- 项目文件完整性
- 场景文件有效性
- 资源引用正确性

**运行方式**: CI 中自动使用 Godot Headless

### 4. 文件结构检查

**检查项**:
- 文件命名规范（PascalCase for `.gd`/`.cs`）
- 禁止提交的文件（插件二进制、大文件等）
- 目录结构完整性

### 5. 文档完整性

**检查项**:
- 必需文档是否存在
- Markdown 格式正确性
- 大改动是否更新了文档

### 6. 安全扫描

**检查项**:
- 硬编码的密码、API Key
- 敏感信息泄露
- 不安全的代码模式

---

## 📝 PR 专用检查

针对 PR 到 `main` 分支的额外检查：

### PR 格式验证
- **标题格式**: 必须符合 Conventional Commits
  ```
  ✅ feat(renderer): 添加新的动画系统
  ✅ fix(core): 修复服务定位器初始化问题
  ❌ 更新代码
  ❌ fix bug
  ```

- **描述长度**: 至少 20 字符
- **源分支**: 不能直接从 `main` 创建 PR

### 变更分析
- 统计变更文件类型
- 检测破坏性 API 变更
- 提示大改动需要更新文档

### 代码质量门禁
- GDScript 代码必须通过 `gdlint`
- C# 代码必须编译成功
- 不能引入新的安全问题

---

## ⚙️ CI 配置

### 主 CI 流程 (`.github/workflows/ci.yml`)

```yaml
触发: push 到 dev/main, PR 到 dev/main
检查:
  - GDScript 语法和风格
  - C# 编译
  - Godot 项目验证
  - 文件结构
  - 文档完整性
  - 安全扫描
```

### PR 检查流程 (`.github/workflows/pr-check.yml`)

```yaml
触发: PR 到 main
检查:
  - PR 格式验证
  - 变更分析
  - 代码质量门禁
  - 破坏性变更检测
```

---

## 🛠️ 本地开发工作流

### 1. 提交前检查

在提交代码前，运行本地检查：

```bash
# 安装检查工具
pip install gdtoolkit==4.*

# 进入项目目录
cd engine

# 检查 GDScript 代码
gdlint renderer/ core/

# 检查 C# 代码
dotnet build MarionetEngine.csproj

# 如果有错误，修复后再提交
```

### 2. 创建 PR

```bash
# 推送到你的分支
git push origin feat/your-feature

# 在 GitHub 上创建 PR
# 系统会自动加载 PR 模板并触发 CI
```

### 3. 查看 CI 结果

1. 进入 PR 页面
2. 查看 "Checks" 标签
3. 点击失败的检查查看详细日志
4. 根据错误信息修复问题

### 4. 修复并重新检查

```bash
# 修复问题
# ...

# 提交修复
git add .
git commit -m "fix: 修复 CI 检查问题"
git push

# CI 会自动重新运行
```

---

## 🚫 忽略的文件

以下文件/目录不会被 CI 检查：

- `.godot/` - Godot 导入缓存
- `engine/addons/gd_cubism/bin/` - 插件二进制（不上传）
- `engine/Live2D/models/` - Live2D 模型（大文件）
- `bin/`, `obj/` - .NET 编译输出
- `.vs/`, `.vscode/`, `.idea/` - IDE 配置

详见 `.gitignore` 文件。

---

## 🔧 CI 配置文件

### `.github/workflows/ci.yml`
主 CI 流程配置

**关键配置**:
- Godot 版本: 4.5-stable
- .NET 版本: 8.0.x
- gdtoolkit 版本: 4.x

### `.github/workflows/pr-check.yml`
PR 专用检查配置

**检查重点**:
- PR 格式
- 代码质量门禁
- 破坏性变更

### `.gdlintrc`
GDScript 代码风格配置

**主要规则**:
- 行长度: 100 字符
- 函数复杂度: 15
- 最大参数: 5
- 缩进: Tab
- 命名: PascalCase/snake_case/SCREAMING_SNAKE_CASE

### `.gitattributes`
Git 文件属性配置

**关键设置**:
- 统一行尾为 LF
- 二进制文件标记
- Live2D 文件处理

---

## ❓ 常见问题

### Q: CI 检查失败了怎么办？

**A**: 
1. 查看 GitHub Actions 日志找到具体错误
2. 在本地运行相同的检查工具
3. 修复问题后重新提交
4. CI 会自动重新运行

### Q: 如何跳过 CI 检查？

**A**: 
不建议跳过 CI 检查。如果确实需要（如紧急修复文档），可以在 commit message 中添加 `[skip ci]`：
```bash
git commit -m "docs: 修复拼写错误 [skip ci]"
```

### Q: GDScript 检查总是失败

**A**:
常见原因：
- 行长度超过 100 字符
- 缩进使用空格而不是 Tab
- 变量/函数命名不符合 snake_case
- 类名不符合 PascalCase

运行 `gdlint` 查看具体问题。

### Q: C# 编译失败

**A**:
常见原因：
- 缺少 using 引用
- 类型不匹配
- Godot API 使用错误

在本地运行 `dotnet build` 查看详细错误。

### Q: 如何更新 CI 配置？

**A**:
1. 修改 `.github/workflows/*.yml` 文件
2. 提交 PR
3. CI 会使用新配置运行
4. 验证无误后合并

### Q: 插件二进制文件怎么处理？

**A**:
- **开发环境**: 手动下载插件到 `engine/addons/gd_cubism/bin/`
- **CI 环境**: 目前 CI 会跳过需要插件的测试
- **未来**: 考虑使用 GitHub Releases 或缓存

参考: `engine/addons/gd_cubism/bin/README.md`

---

## 📊 CI 状态徽章

可以在 README 中添加 CI 状态徽章：

```markdown
![CI](https://github.com/YOUR_USERNAME/Marionet/workflows/CI/badge.svg)
![PR Check](https://github.com/YOUR_USERNAME/Marionet/workflows/PR%20Check/badge.svg)
```

---

## 🔮 未来改进

- [ ] 添加自动化测试（单元测试、集成测试）
- [ ] 代码覆盖率报告
- [ ] 性能基准测试
- [ ] 自动生成 CHANGELOG
- [ ] 自动化发布流程
- [ ] 多平台构建（Windows/Linux/macOS）

---

## 📞 问题反馈

如果遇到 CI 相关问题，请：

1. 查看本文档
2. 查看 GitHub Actions 日志
3. 搜索现有 Issues
4. 创建新 Issue 并附上详细信息

---

<p align="center">
  <strong>自动化让开发更高效！</strong><br>
  <sub>CI/CD 是代码质量的守护者 🛡️</sub>
</p>

