# CI/CD 故障排除指南

> 常见 CI 错误及解决方案

---

## 🔍 Godot 项目验证错误

### ❌ 错误: "Unrecognized UID"

**完整错误信息**:
```
ERROR: Unrecognized UID: "uid://dr6ijw6u2hjcu".
   at: get_id_path (core/io/resource_uid.cpp:199)
Couldn't detect whether to run the editor, the project manager or a specific project. Aborting.
```

**原因**:
- Godot 的 UID 缓存文件（`.godot/uid_cache.bin`）被 `.gitignore` 忽略
- CI 环境是全新的，没有这个缓存文件
- Godot 需要先导入项目才能生成 UID 映射

**解决方案**:
✅ **已在 CI 配置中自动处理**

CI 现在会：
1. 先用 `--import` 导入项目生成 UID 缓存
2. 等待导入完成
3. 再运行验证
4. 忽略 UID 相关的警告，只关注严重错误

**如果你看到这个错误**:
- 不用担心，这是预期的行为
- 检查 CI 日志，确保后续的"验证项目完整性"步骤通过
- 如果验证步骤也失败，才需要检查其他问题

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

## 🔍 PR 格式错误

### ❌ 错误: "PR 标题必须符合 Conventional Commits 格式"

**错误信息**:
```
错误: PR 标题必须符合 Conventional Commits 格式
示例: feat(renderer): 添加新的动画系统
当前标题: 更新代码
```

**解决方案**:
在 GitHub PR 页面修改标题为：

```
feat(scope): 添加新功能
fix(scope): 修复某个问题
refactor(scope): 重构某个模块
docs(scope): 更新文档
```

**类型列表**:
- `feat` - 新功能
- `fix` - Bug 修复
- `refactor` - 重构
- `docs` - 文档
- `style` - 代码风格
- `test` - 测试
- `chore` - 构建/工具

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

