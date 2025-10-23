# 开发环境配置指南

> 为 Marionet 项目配置最佳开发环境

---

## 目录

- [前置要求](#前置要求)
- [编辑器配置](#编辑器配置)
- [Git 配置](#git-配置)
- [工具推荐](#工具推荐)
- [常见问题](#常见问题)

---

## 前置要求

### 必需软件

1. **Godot Engine 4.3+** (.NET 版本)
   ```bash
   # 下载地址
   https://godotengine.org/download
   ```

2. **.NET SDK 8.0+**
   ```bash
   # 验证安装
   dotnet --version
   
   # 应输出: 8.0.x 或更高
   ```

3. **Git**
   ```bash
   # 验证安装
   git --version
   ```

---

## 编辑器配置

### VSCode（推荐）

#### 1. 安装 VSCode

下载: https://code.visualstudio.com/

#### 2. 安装推荐扩展

打开项目后，VSCode 会自动提示安装推荐扩展。或手动安装：

**必需扩展**:
- `geequlim.godot-tools` - Godot 支持
- `ms-dotnettools.csharp` - C# 支持
- `editorconfig.editorconfig` - EditorConfig 支持

**推荐扩展**:
- `eamodio.gitlens` - Git 增强
- `yzhang.markdown-all-in-one` - Markdown 支持
- `gruntfuggly.todo-tree` - TODO 高亮

```bash
# 或使用命令行安装
code --install-extension geequlim.godot-tools
code --install-extension ms-dotnettools.csharp
code --install-extension editorconfig.editorconfig
```

#### 3. 配置 Godot 路径

在 VSCode 设置中（`Ctrl+,` 或 `Cmd+,`）:

```json
{
	"godot_tools.editor_path": "C:/Path/To/Godot_v4.3-stable_mono_win64.exe"
}
```

#### 4. 验证配置

1. 打开任意 `.gd` 文件
2. 检查语法高亮是否正常
3. 按 `F5` 应该能启动 Godot 编辑器

### JetBrains Rider（可选）

Rider 提供更强大的 C# 支持，但需要付费。

#### 配置步骤

1. 安装 Godot Support 插件
2. 打开 `renderer/renderer.sln`
3. 配置 Godot 可执行文件路径

---

## Git 配置

### 1. 配置提交模板

```bash
# 设置提交消息模板
git config --local commit.template .gitmessage

# 现在每次 git commit 会自动显示模板
```

### 2. 配置用户信息

```bash
# 设置你的名字和邮箱
git config --local user.name "Your Name"
git config --local user.email "your.email@example.com"
```

### 3. 配置行尾符

```bash
# Windows 用户
git config --global core.autocrlf true

# macOS/Linux 用户
git config --global core.autocrlf input
```

### 4. 配置编辑器

```bash
# 使用 VSCode 作为默认编辑器
git config --global core.editor "code --wait"

# 或使用 vim
git config --global core.editor "vim"
```

### 5. 安装 Git Hooks（可选）

创建 `.git/hooks/pre-commit` 文件：

```bash
#!/bin/sh
# Pre-commit hook for Marionet

echo "🔍 检查代码规范..."

# 检查是否有混用 Tab 和空格
if git diff --cached --check; then
    echo "✅ 代码格式检查通过"
else
    echo "❌ 发现格式问题，请修复后再提交"
    echo ""
    echo "提示："
    echo "  - GDScript 使用 Tab 缩进"
    echo "  - C# 使用 4 个空格缩进"
    echo "  - 移除行尾空格"
    exit 1
fi

# 检查提交消息格式
commit_msg_file=$(git rev-parse --git-dir)/COMMIT_EDITMSG
if [ -f "$commit_msg_file" ]; then
    # 这里可以添加提交消息格式检查
    :
fi

echo "✅ 所有检查通过"
exit 0
```

然后赋予执行权限：

```bash
chmod +x .git/hooks/pre-commit
```

---

## 工具推荐

### 代码质量

1. **EditorConfig**
   - 自动应用项目的编码风格
   - 项目已包含 `.editorconfig`
   - 大多数编辑器自动支持

2. **Markdownlint**
   - 检查 Markdown 文档格式
   - VSCode 扩展: `davidanson.vscode-markdownlint`

### Git 工具

1. **GitKraken** / **GitHub Desktop**
   - 图形化 Git 客户端
   - 更直观的分支管理

2. **Git Graph** (VSCode 扩展)
   - 在 VSCode 中查看 Git 历史
   - 扩展 ID: `mhutchie.git-graph`

### 调试工具

1. **Godot Remote Debugger**
   - 在 Godot 编辑器中启用
   - 可以实时查看变量和调用栈

2. **.NET Debugger** (VSCode/Rider)
   - 调试 C# 代码
   - 设置断点和单步执行

---

## 验证配置

### 检查清单

运行以下命令验证环境配置：

```bash
# 1. 检查 Git
git --version
git config user.name
git config user.email

# 2. 检查 .NET
dotnet --version

# 3. 检查 Godot（在项目目录中）
godot --version

# 4. 测试 EditorConfig
# 打开任意 .gd 文件，按 Tab 应该插入制表符
# 打开任意 .cs 文件，按 Tab 应该插入 4 个空格
```

### 测试提交流程

```bash
# 1. 创建测试分支
git checkout -b test/setup-verification

# 2. 修改文件
echo "# Test" >> test.md

# 3. 提交（应该显示提交模板）
git add test.md
git commit

# 4. 检查提交消息格式
git log -1

# 5. 清理
git checkout dev
git branch -D test/setup-verification
git restore test.md
```

---

## 常见问题

### Q1: Godot 无法识别 C# 代码

**解决方案**:
1. 在 Godot 编辑器中点击 `Build` → `Build Solution`
2. 确保安装了 .NET SDK 8.0+
3. 重启 Godot 编辑器

### Q2: VSCode 中 GDScript 没有语法高亮

**解决方案**:
1. 安装 `godot-tools` 扩展
2. 重启 VSCode
3. 打开任意 `.gd` 文件检查

### Q3: Git 提交时没有显示模板

**解决方案**:
```bash
# 重新设置模板
git config --local commit.template .gitmessage

# 验证配置
git config --local --list | grep commit.template
```

### Q4: EditorConfig 没有生效

**解决方案**:
1. 确保安装了 EditorConfig 扩展
2. 重启编辑器
3. 检查 `.editorconfig` 文件是否存在于项目根目录

### Q5: 代码格式不一致

**解决方案**:
```bash
# 检查当前文件编码和行尾符
file -bi filename.gd

# 转换行尾符（如果需要）
dos2unix filename.gd  # CRLF → LF
unix2dos filename.bat  # LF → CRLF
```

### Q6: C# 项目无法编译

**解决方案**:
```bash
# 清理并重新构建
cd renderer
dotnet clean
dotnet build

# 在 Godot 中重新构建
# Build → Clean → Build Solution
```

---

## 快速参考

### 常用命令

```bash
# 开发流程
git checkout dev
git pull upstream dev
git checkout -b feat/your-feature
# ... 进行开发 ...
git add .
git commit  # 使用模板
git push origin feat/your-feature

# 运行项目
cd renderer
godot project.godot

# 构建 C# 项目
cd renderer
dotnet build

# 格式化代码（如果有格式化工具）
dotnet format
```

### 快捷键

**VSCode**:
- `Ctrl+Shift+P` / `Cmd+Shift+P` - 命令面板
- `F5` - 启动 Godot
- `Ctrl+K Ctrl+F` - 格式化选中代码
- `Ctrl+/` - 切换注释

**Godot**:
- `F5` - 运行项目
- `F6` - 运行当前场景
- `Ctrl+Shift+E` - 导出项目
- `Ctrl+Alt+P` - 重新导入资源

---

## 进阶配置

### 自定义 VSCode 任务

创建 `.vscode/tasks.json`:

```json
{
	"version": "2.0.0",
	"tasks": [
		{
			"label": "Build C# Project",
			"type": "shell",
			"command": "dotnet build renderer/renderer.csproj",
			"group": {
				"kind": "build",
				"isDefault": true
			}
		},
		{
			"label": "Run Godot",
			"type": "shell",
			"command": "godot --path renderer project.godot",
			"problemMatcher": []
		}
	]
}
```

使用 `Ctrl+Shift+B` 快速构建。

### 配置调试器

创建 `.vscode/launch.json`:

```json
{
	"version": "0.2.0",
	"configurations": [
		{
			"name": "Launch Godot",
			"type": "godot",
			"request": "launch",
			"project": "${workspaceFolder}/renderer",
			"port": 6007,
			"address": "127.0.0.1"
		}
	]
}
```

---

## 相关文档

- [编码规范](./CODING_STANDARDS.md) - 完整的代码风格指南
- [贡献指南](./CONTRIBUTING.md) - 如何参与项目
- [快速参考](./QUICK_REFERENCE.md) - 编码规范速查表

---

<p align="center">
  <strong>配置完成！</strong><br>
  <i>现在你已经准备好开始贡献代码了</i><br>
  <sub>祝编码愉快！ 🚀</sub>
</p>

