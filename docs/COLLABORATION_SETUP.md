# 协作开发环境配置指南

> 克隆项目后如何快速搭建开发环境

---

## 📋 仓库包含的内容

### ✅ 已包含（可以直接使用）

| 类型 | 内容 | 说明 |
|------|------|------|
| **核心代码** | 所有 `.gd` 和 `.cs` 文件 | 项目的主要逻辑 |
| **项目配置** | `project.godot`, `.csproj`, `.sln` | Godot 和 C# 项目文件 |
| **插件框架** | GDCubism 配置和 C# 包装 | 插件的结构和接口 |
| **Shader** | 所有 `.gdshader` 文件 | Live2D 渲染着色器 |
| **场景文件** | 所有 `.tscn` 文件 | Godot 场景 |
| **文档** | `docs/` 目录下所有文档 | 开发文档 |
| **脚本** | `scripts/` 开发工具脚本 | 自动化脚本 |
| **CI/CD** | `.github/` 工作流配置 | 自动化检查 |
| **示例配置** | `settings_example.json` | 配置文件模板 |

### ❌ 不包含（需要自己添加）

| 类型 | 位置 | 获取方式 |
|------|------|----------|
| **GDCubism 插件二进制** | `engine/addons/gd_cubism/bin/` | [下载地址](https://github.com/MizunagiKB/gd_cubism/releases) |
| **Live2D 模型** | `engine/Live2D/models/` | 自己准备或使用官方示例 |
| **个人配置** | `engine/settings.json` | 复制 `settings_example.json` 并修改 |

---

## 🚀 快速开始（新成员）

### 1. 克隆仓库

```bash
git clone https://github.com/YOUR_USERNAME/Marionet.git
cd Marionet
```

### 2. 安装必需工具

**必需**:
- Godot 4.5+ (Mono 版本) - [下载](https://godotengine.org/download)
- .NET SDK 8.0+ - [下载](https://dotnet.microsoft.com/download)
- Git - [下载](https://git-scm.com/)

**推荐**:
- Visual Studio 2022 或 VS Code
- Python 3.11+ (用于开发工具)

### 3. 下载 GDCubism 插件二进制

**方法 1: 从官方下载**

1. 访问 [GDCubism Releases](https://github.com/MizunagiKB/gd_cubism/releases)
2. 下载适合你平台的版本：
   - Windows: `libgd_cubism.windows.release.x86_64.dll`
   - Linux: `libgd_cubism.linux.release.x86_64.so`
   - macOS: `libgd_cubism.macos.release.universal.dylib`
3. 解压并复制 `.dll` / `.so` / `.dylib` 文件到：
   ```
   engine/addons/gd_cubism/bin/
   ```

**验证**:
```bash
# Windows
dir engine\addons\gd_cubism\bin\*.dll

# Linux/macOS
ls engine/addons/gd_cubism/bin/*.so
ls engine/addons/gd_cubism/bin/*.dylib
```

### 4. 准备 Live2D 模型（可选）

**如果只是开发核心功能**，可以跳过这一步。

**如果需要测试渲染**:

1. 获取 Live2D 模型（官方示例或自己的）
2. 放到 `engine/Live2D/models/` 目录：
   ```
   engine/Live2D/models/
   ├── your_model/
   │   ├── your_model.model3.json
   │   ├── your_model.moc3
   │   └── ...
   ```

### 5. 配置项目

```bash
# 复制示例配置
cd engine
cp settings_example.json settings.json

# 根据需要修改 settings.json
# （这个文件不会被提交到 Git）
```

### 6. 运行开发环境设置脚本

**Linux / macOS**:
```bash
chmod +x scripts/setup-dev.sh
./scripts/setup-dev.sh
```

**Windows PowerShell**:
```powershell
.\scripts\setup-dev.ps1
```

脚本会自动：
- 检查必需工具
- 安装代码检查工具（gdlint）
- 验证插件是否安装
- 运行初始检查

### 7. 打开项目

**在 Godot 中**:
```bash
cd engine
godot project.godot
```

**或者使用命令行**:
```bash
godot --path engine --editor
```

### 8. 编译 C# 项目

在 Godot 编辑器中：
1. 点击菜单 `Build` → `Build Solution`
2. 等待编译完成

或者命令行：
```bash
cd engine
dotnet build MarionetEngine.csproj
```

---

## ✅ 验证安装

运行以下检查确保环境配置正确：

### 检查 1: Godot 项目加载

```bash
cd engine
godot --headless --quit
# 应该没有严重错误（插件相关警告是正常的）
```

### 检查 2: C# 编译

```bash
cd engine
dotnet build MarionetEngine.csproj
# 应该编译成功
```

### 检查 3: GDScript 代码风格

```bash
pip install gdtoolkit==4.*
cd engine
gdlint renderer/ core/
# 应该没有错误（或只有少量警告）
```

### 检查 4: 插件是否加载

在 Godot 编辑器中：
1. 打开 `项目设置` → `插件`
2. 查看是否有 "GD Cubism" 插件
3. 如果看到插件，说明二进制文件安装正确

---

## 📂 目录结构说明

```
Marionet/
├── engine/                    # Godot 项目（渲染引擎）
│   ├── addons/
│   │   └── gd_cubism/         # Live2D 插件
│   │       ├── bin/           # ❌ 二进制文件（自己下载）
│   │       ├── cs/            # ✅ C# 包装类（已包含）
│   │       ├── res/shader/    # ✅ Shader（已包含）
│   │       └── gd_cubism.gdextension  # ✅ 插件配置（已包含）
│   ├── core/                  # ✅ 核心系统（已包含）
│   ├── renderer/              # ✅ 渲染服务（已包含）
│   ├── scenes/                # ✅ 场景文件（已包含）
│   ├── Live2D/
│   │   └── models/            # ❌ 模型文件（自己准备）
│   ├── project.godot          # ✅ Godot 配置（已包含）
│   ├── MarionetEngine.csproj  # ✅ C# 项目（已包含）
│   └── settings_example.json  # ✅ 配置示例（已包含）
├── src/                       # ✅ C# 核心逻辑（已包含）
├── docs/                      # ✅ 文档（已包含）
├── scripts/                   # ✅ 开发脚本（已包含）
└── .github/                   # ✅ CI/CD（已包含）
```

---

## 🔧 开发工作流

### 日常开发

```bash
# 1. 同步最新代码
git fetch upstream
git checkout dev
git merge upstream/dev

# 2. 创建功能分支
git checkout -b feat/your-feature

# 3. 开发...
# 在 Godot 中编辑场景和脚本
# 在 IDE 中编辑 C# 代码

# 4. 本地检查（避免 CI 失败）
cd engine
gdlint renderer/ core/
dotnet build MarionetEngine.csproj

# 5. 提交
git add .
git commit -m "feat(scope): 描述"

# 6. 推送
git push origin feat/your-feature

# 7. 创建 PR
# 在 GitHub 上创建 Pull Request
# CI 会自动运行检查
```

### 处理合并冲突

```bash
# 更新你的分支
git fetch upstream
git rebase upstream/dev

# 解决冲突后
git add .
git rebase --continue

# 强制推送（rebase 后需要）
git push -f origin feat/your-feature
```

---

## ⚠️ 常见问题

### Q: 克隆后 Godot 打不开项目

**A**: 可能原因：
1. 没有安装 Godot Mono 版本（需要 C# 支持）
2. 没有下载或编译 GDCubism 插件二进制

**解决**:
- 确保下载的是 **Godot Mono** 版本
- 下载插件到 `engine/addons/gd_cubism/bin/`
- 重新打开项目

### Q: Godot 报很多红色错误

**A**: 如果是以下错误，是**正常的**（在下载插件前）:
```
ERROR: GDExtension dynamic library not found
ERROR: Could not find type "GDCubismUserModel"
```

下载插件后这些错误会消失。

### Q: C# 脚本编译失败

**A**: 
1. 在 Godot 中点击 `Build` → `Clean`
2. 然后 `Build` → `Build Solution`
3. 如果还是失败，重启 Godot

### Q: Git 忽略了我的改动

**A**: 检查 `.gitignore`，以下文件**不应该**提交：
- `engine/addons/gd_cubism/bin/*.dll` - 插件二进制
- `engine/Live2D/models/` - Live2D 模型
- `engine/settings.json` - 个人配置
- `.godot/` - Godot 缓存
- `bin/`, `obj/` - 编译输出

### Q: CI 检查失败怎么办？

**A**: 查看 [CI 故障排除指南](CI_TROUBLESHOOTING.md)

---

## 📞 获取帮助

如果遇到问题：

1. **查看文档**:
   - [贡献指南](CONTRIBUTING.md)
   - [CI/CD 指南](CI_CD_GUIDE.md)
   - [故障排除](CI_TROUBLESHOOTING.md)

2. **搜索 Issues**:
   - 在 GitHub Issues 中搜索类似问题

3. **创建 Issue**:
   - 提供详细的环境信息
   - 附上错误日志
   - 说明已尝试的解决方案

---

## 🎯 开发环境检查清单

完成以下检查，确保环境配置正确：

```
环境工具:
□ Godot 4.5+ (Mono 版本) 已安装
□ .NET SDK 8.0+ 已安装
□ Git 已安装
□ Python 3.11+ 已安装（可选）

插件和依赖:
□ GDCubism 插件二进制已下载到 engine/addons/gd_cubism/bin/
□ Live2D 模型已准备（如果需要测试渲染）
□ settings.json 已创建（从 settings_example.json 复制）

验证:
□ Godot 能正常打开项目
□ Godot 能看到 GDCubism 插件
□ C# 项目能成功编译
□ gdlint 代码检查通过
□ 能运行主场景（F5）

开发工具（可选）:
□ VS Code / Visual Studio 已配置
□ gdtoolkit 已安装（pip install gdtoolkit）
□ Git GUI 工具已安装
```

---

<p align="center">
  <strong>环境配置完成！</strong><br>
  <sub>开始你的开发之旅吧 🚀</sub>
</p>

