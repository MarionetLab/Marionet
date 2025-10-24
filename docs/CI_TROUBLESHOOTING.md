# CI/CD 故障排除指南

> 常见 CI 错误及解决方案

---

## 🔍 Godot 项目相关"错误"（实际上正常）

### ℹ️ "GDExtension dynamic library not found"

**完整错误信息**:
```
ERROR: GDExtension dynamic library not found: 'res://addons/gd_cubism/gd_cubism.gdextension'.
ERROR: Could not find type "GDCubismUserModel" in the current scope.
ERROR: Failed to compile depended scripts.
```

**这不是真正的错误！**

**原因**:
- CI 环境不包含 GDCubism 插件（插件二进制不提交到仓库）
- 依赖插件的代码自然无法编译
- 这是**预期的、正常的行为**

**为什么这样设计？**
1. 插件二进制文件很大，不适合 Git 跟踪
2. 插件可能有许可证限制
3. 不同平台需要不同的二进制文件

**CI 的检查策略**:
- ✅ 检查 GDScript 语法和代码风格（不依赖插件）
- ✅ 检查 C# 代码编译（不依赖插件）
- ✅ 检查项目文件结构
- ❌ **不运行完整的 Godot 验证**（需要插件）

**如果你看到这些错误**:
- ✅ 不用担心，这是正常的
- ✅ 检查其他 CI 检查是否通过
- ✅ 在本地开发环境（有插件）测试完整功能

**本地开发环境**:
- 手动下载 GDCubism 插件到 `engine/addons/gd_cubism/bin/`
- 参考: `engine/addons/gd_cubism/bin/README.md`
- 在本地 Godot 编辑器中运行完整测试

---

### ℹ️ "Failed to instantiate an autoload"

**错误信息**:
```
ERROR: Failed to instantiate an autoload, script 'res://renderer/services/Window/WindowService.cs' does not inherit from 'Node'.
```

**原因**:
- C# 代码在 CI 环境中可能没有被编译
- Godot 无法加载未编译的 C# 脚本

**这也是正常的**:
- CI 会单独运行 C# 编译检查（`dotnet build`）
- 如果 C# 编译检查通过，代码就是正确的
- Godot autoload 的错误可以忽略（CI 环境限制）

---

### ✅ CI 中真正重要的检查

CI 专注于**不需要插件**就能验证的内容：

1. **GDScript 代码风格** - 使用 `gdlint`
2. **C# 代码编译** - 使用 `dotnet build`
3. **项目文件结构** - 检查必需文件存在
4. **文件命名规范** - PascalCase 等
5. **文档完整性** - 必需文档存在
6. **安全扫描** - 敏感信息检测

**完整的运行时测试**: 在本地开发环境进行

---

## 🔍 GDScript 代码风格错误

### ❌ 错误: "line too long"

**错误信息**:
```
renderer/scripts/MyScript.gd:42:1: E501 line too long (105 > 100 characters)
```

**解决方案**:
1. 将长行分割成多行
2. 或者使用变量临时存储中间结果

**示例**:
```gdscript
# ❌ 错误 - 行太长
var result = ServiceLocator.get_service("VeryLongServiceName").call_very_long_method_name(param1, param2, param3)

# ✅ 正确 - 拆分成多行
var service = ServiceLocator.get_service("VeryLongServiceName")
var result = service.call_very_long_method_name(
    param1, 
    param2, 
    param3
)
```

### ❌ 错误: "expected indent of X, found Y"

**错误信息**:
```
renderer/scripts/MyScript.gd:15:1: E111 expected indent of 1 tab, found 4 spaces
```

**原因**: 使用了空格而不是 Tab 缩进

**解决方案**:
1. 在编辑器中设置使用 Tab 缩进
2. 替换所有空格缩进为 Tab

**VS Code 设置**:
```json
{
  "[gdscript]": {
    "editor.insertSpaces": false,
    "editor.tabSize": 4
  }
}
```

### ❌ 错误: "function name should be in snake_case"

**错误信息**:
```
renderer/scripts/MyScript.gd:20:1: N802 function name should be in snake_case
```

**解决方案**:
```gdscript
# ❌ 错误
func MyFunction():
    pass

# ✅ 正确
func my_function():
    pass
```

---

## 🔍 C# 编译错误

### ❌ 错误: "The type or namespace name 'XXX' could not be found"

**错误信息**:
```
error CS0246: The type or namespace name 'Godot' could not be found
```

**原因**: 缺少 using 引用

**解决方案**:
```csharp
// 添加必要的 using
using Godot;
using System;
```

### ❌ 错误: "CS1061: does not contain a definition for"

**错误信息**:
```
error CS1061: 'Node' does not contain a definition for 'GetNode'
```

**原因**: Godot 4.x API 变更

**解决方案**:
```csharp
// ❌ Godot 3.x
GetNode("Path");

// ✅ Godot 4.x
GetNode<Node>("Path");
// 或
GetNode("Path") as Node;
```

---

## 🔍 PR 格式检查

### ℹ️ PR 标题格式建议

**CI 检查是宽松的**，以下标题都能通过：

**✅ 推荐格式（最佳）**:
```
feat(renderer): 添加 Live2D 动画系统
fix(core): 修复服务初始化问题
chore(ci): 添加 CI/CD 配置
docs: 更新贡献指南
```

**✅ 可接受格式**:
```
Add CI/CD configuration
Update documentation
Fix renderer bug
Feature: Add animation system
```

**⚠️  不推荐但能通过**:
```
Update files          （只要有 10+ 字符且有意义）
Improve performance
```

**❌ 会失败的标题**:
```
Dev                   （太短）
update                （太模糊）
.                     （无意义）
```

### 🔧 如何修改 PR 标题

1. 进入 GitHub PR 页面
2. 点击标题旁边的 "Edit" 按钮
3. 修改为有意义的标题（推荐使用 Conventional Commits）
4. 保存后 CI 自动重新运行

### 📚 详细格式参考

完整示例和最佳实践：[PR 标题格式参考](../.github/PR_TITLE_EXAMPLES.md)

### ❌ 错误: "PR 描述过短或为空"

**错误信息**:
```
错误: PR 描述过短或为空
请添加详细的 PR 描述
```

**解决方案**:
使用 PR 模板填写完整的描述：
- 变更类型
- 变更说明
- 相关 Issue
- 测试情况

---

## 🔍 文件结构错误

### ❌ 错误: "文件名不符合 PascalCase 命名规范"

**错误信息**:
```
警告: renderer/scripts/my_script.gd 不符合 PascalCase 命名规范
```

**解决方案**:
```bash
# GDScript 和 C# 文件应使用 PascalCase
mv my_script.gd MyScript.gd
mv my_service.cs MyService.cs

# 更新所有引用这些文件的地方
```

### ❌ 错误: "检测到不应提交的插件二进制文件"

**错误信息**:
```
错误: 检测到不应提交的插件二进制文件
请将以下文件添加到 .gitignore:
engine/addons/gd_cubism/bin/libgd_cubism.windows.release.x86_64.dll
```

**解决方案**:
```bash
# 从 Git 中移除这些文件
git rm --cached engine/addons/gd_cubism/bin/*.dll
git rm --cached engine/addons/gd_cubism/bin/*.so
git rm --cached engine/addons/gd_cubism/bin/*.dylib

# 确保 .gitignore 包含这些规则
echo "engine/addons/gd_cubism/bin/*.dll" >> .gitignore
echo "engine/addons/gd_cubism/bin/*.so" >> .gitignore
echo "engine/addons/gd_cubism/bin/*.dylib" >> .gitignore

# 提交更改
git commit -m "chore: 移除不应提交的插件二进制文件"
```

---

## 🔍 安全扫描错误

### ❌ 错误: "发现可能的硬编码敏感信息"

**错误信息**:
```
警告: 发现可能的硬编码敏感信息
renderer/scripts/ApiManager.gd:15: api_key = "sk-xxxxx"
```

**解决方案**:
```gdscript
# ❌ 错误 - 硬编码密钥
const API_KEY = "sk-1234567890abcdef"

# ✅ 正确 - 从配置文件读取
var config = ConfigService.load_config()
var api_key = config.get("api_key", "")
```

**最佳实践**:
1. 敏感信息存储在配置文件（`settings.json`）
2. 配置文件添加到 `.gitignore`
3. 提供示例配置（`settings_example.json`）

---

## 🔍 文档检查错误

### ❌ 错误: "缺少必需文档"

**错误信息**:
```
错误: 缺少必需文档 docs/architecture/architecture.md
```

**解决方案**:
确保以下文档存在：
- `README.md`
- `docs/CONTRIBUTING.md`
- `docs/CODING_STANDARDS.md`
- `docs/architecture/architecture.md`

### ❌ 警告: "检测到较大的代码变更，但没有文档更新"

**错误信息**:
```
⚠️  警告: 检测到较大的代码变更，但没有文档更新
建议检查是否需要更新以下文档:
- docs/architecture/architecture.md (架构变更)
```

**解决方案**:
检查是否需要更新相关文档：
- 架构变更 → 更新 `docs/architecture/architecture.md`
- API 变更 → 更新函数文档注释
- 用户功能 → 更新 `README.md`

---

## 🔧 通用故障排除步骤

### 1. 查看详细日志

```bash
# 进入 GitHub Actions
# 点击失败的检查
# 展开详细步骤
# 查看完整错误信息
```

### 2. 本地复现问题

```bash
# 安装检查工具
pip install gdtoolkit==4.*

# 运行相同的检查
cd engine
gdlint renderer/ core/
dotnet build MarionetEngine.csproj
```

### 3. 修复并重新测试

```bash
# 修复问题
# ...

# 本地验证
gdlint renderer/ core/

# 提交修复
git add .
git commit -m "fix: 修复 CI 检查问题"
git push
```

### 4. CI 会自动重新运行

推送后，GitHub Actions 会自动重新运行所有检查。

---

## 📞 获取帮助

如果以上方案都无法解决问题：

1. **查看文档**:
   - [CI/CD 指南](CI_CD_GUIDE.md)
   - [贡献指南](CONTRIBUTING.md)
   - [编码规范](CODING_STANDARDS.md)

2. **搜索 Issues**:
   - 在 GitHub Issues 中搜索类似问题

3. **创建 Issue**:
   - 提供完整的错误信息
   - 附上 CI 日志链接
   - 说明已经尝试的解决方案

---

## 🔮 预防措施

### 提交前检查清单

```bash
# 1. 代码风格
gdlint renderer/ core/

# 2. C# 编译
dotnet build MarionetEngine.csproj

# 3. 提交消息格式
# feat(scope): 描述

# 4. 文件命名
# PascalCase.gd, PascalCase.cs

# 5. 没有敏感信息
# 检查代码中是否有硬编码的密钥
```

### 使用 Pre-commit Hook

运行设置脚本时选择安装 pre-commit hook：

```bash
# Linux / macOS
./scripts/setup-dev.sh

# Windows
.\scripts\setup-dev.ps1
```

hook 会在每次提交前自动运行检查。

---

<p align="center">
  <strong>遇到问题不要慌！</strong><br>
  <sub>大多数 CI 错误都很容易修复 🛠️</sub>
</p>

