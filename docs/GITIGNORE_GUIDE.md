# .gitignore 配置说明

本文档说明了 Marionet 项目的 `.gitignore` 配置策略。

## 主要忽略内容

### 1. Live2D 模型文件 ⚠️ 重要

**完全忽略模型目录**:
```
engine/Live2D/models/
renderer/Live2D/models/
```

**原因**: 
- Live2D 模型文件通常很大（单个模型 50-200MB）
- 包含大量纹理和动画文件
- 不适合直接放在 Git 仓库

**如何获取模型**:
请参考 `engine/Live2D/models/README.md` 获取模型文件的方法。

---

### 2. 第三方插件二进制文件

**忽略 gd_cubism 插件二进制**:
```
engine/addons/gd_cubism/bin/*.dll
engine/addons/gd_cubism/bin/*.lib
engine/addons/gd_cubism/bin/*.exp
```

**原因**:
- gd_cubism 插件的二进制文件受许可证限制
- 不能二次分发
- 用户需要自行从官方下载

**如何获取插件**:
请参考 `engine/addons/gd_cubism/bin/README.md`。

---

### 3. Godot 引擎生成文件

**忽略内容**:
- `.godot/` - Godot 4 的导入缓存
- `.import/` - Godot 3 的导入缓存
- `*.import` - 资源导入配置
- `export_presets.cfg` - 导出预设（包含个人设置）

**原因**:
- 这些文件是自动生成的
- 每个开发者环境不同
- 会频繁变化，造成不必要的冲突

---

### 4. .NET / C# 构建产物

**忽略内容**:
- `bin/`, `obj/` - 构建输出
- `.vs/`, `.vscode/`, `.idea/` - IDE 配置
- `*.user`, `*.suo` - 个人设置

**原因**:
- 这些是编译中间文件和个人设置
- 可以通过构建命令重新生成
- 不同开发者的设置不同

---

### 5. 环境配置文件

**忽略内容**:
- `.env`, `.env.*` - 环境变量
- `*.local.json` - 本地配置
- `*.secret.json` - 机密配置
- `settings.json` - 个人设置

**保留文件**:
- `settings_example.json` ✅ - 示例配置（已添加 `!` 规则）
- `*.example.json` ✅ - 所有示例配置

**使用方法**:
```bash
# 复制示例配置
cp settings_example.json settings.json
# 然后修改 settings.json 中的个人配置
```

---

### 6. 大文件和资源文件

**忽略内容**:
- 设计源文件: `*.psd`, `*.ai`, `*.blend1`
- 压缩包: `*.zip`, `*.7z`, `*.rar`
- 视频文件: `*.mp4`, `*.avi`, `*.mov`
- 大音频文件: `*.wav`

**注意**:
- 小的音效文件（`.ogg`, `.mp3`）不被忽略
- 如果需要上传特定大文件，使用 Git LFS

---

### 7. 系统和临时文件

**忽略内容**:
- Windows: `Thumbs.db`, `Desktop.ini`
- macOS: `.DS_Store`, `._*`
- Linux: `*~`, `.directory`
- 备份文件: `*.bak`, `*.old`
- 日志文件: `*.log`

---

## 特殊规则说明

### 使用 `!` 保留特定文件

某些重要文件即使匹配忽略规则也要保留：

```gitignore
# 忽略所有 .json 配置
*.local.json
*.secret.json

# 但保留示例配置
!settings_example.json
!*.example.json

# 保留重要文档
!README.md
!LICENSE.md
```

### 目录忽略

```gitignore
# 忽略整个目录
engine/Live2D/models/

# 忽略所有 node_modules（任意位置）
**/node_modules/

# 只忽略根目录的 temp
/temp/
```

---

## 验证 .gitignore 是否生效

### 1. 检查特定文件是否被忽略

```bash
# 检查 models 目录
git check-ignore -v engine/Live2D/models/

# 检查具体文件
git check-ignore -v engine/Live2D/models/hiyori_pro_zh/runtime/hiyori_pro_t11.moc3
```

### 2. 查看被忽略的文件列表

```bash
# 显示所有被忽略的文件
git status --ignored

# 过滤特定目录
git status --ignored | grep "models"
```

### 3. 查看未追踪的文件

```bash
# 查看所有未追踪的文件
git status --untracked-files=all

# 如果 models 目录没有出现，说明忽略生效
```

---

## 常见问题

### Q1: 我添加了文件但无法提交？

检查是否被 `.gitignore` 忽略：
```bash
git check-ignore -v your_file.txt
```

如果需要强制添加：
```bash
git add -f your_file.txt
```

### Q2: 已经提交的文件如何移除追踪？

```bash
# 从 Git 移除但保留本地文件
git rm --cached path/to/file

# 移除整个目录
git rm -r --cached path/to/directory/

# 然后提交更改
git commit -m "Remove tracked files that should be ignored"
```

### Q3: .gitignore 不生效？

可能是因为文件已经被追踪。解决方法：

```bash
# 1. 清除 Git 缓存
git rm -r --cached .

# 2. 重新添加所有文件
git add .

# 3. 提交更改
git commit -m "Apply .gitignore rules"
```

### Q4: 如何忽略某个文件但不修改 .gitignore？

使用 `.git/info/exclude` 文件（仅对本地生效）：

```bash
# 编辑 .git/info/exclude
echo "my_local_config.json" >> .git/info/exclude
```

---

## 最佳实践

### 1. 提交前检查

```bash
# 查看将要提交的文件
git status

# 确保没有不该提交的大文件
git diff --staged --stat

# 检查文件大小
git ls-files -s | awk '{print $4, $2}' | sort -n
```

### 2. 定期清理

```bash
# 清理未追踪的文件（谨慎使用！）
git clean -fd

# 预览将要删除的文件
git clean -fdn
```

### 3. 使用 .gitattributes

对于一致性要求高的文件，使用 `.gitattributes`：

```gitattributes
# 统一换行符
*.gd text eol=lf
*.cs text eol=lf

# 标记为二进制
*.png binary
*.moc3 binary
```

---

## 项目特定配置

### Live2D 模型管理

**本地开发**:
1. 将模型放入 `engine/Live2D/models/`
2. 模型会被自动忽略，不会提交到仓库
3. 其他开发者需要自行获取模型

**团队协作**:
- 使用内部文件服务器或云存储共享模型
- 或使用 Git LFS（需要额外配置）

### 第三方插件

**gd_cubism**:
1. 源代码和配置文件会被提交
2. 二进制文件（`.dll`, `.lib`）不会被提交
3. 开发者需要从官方下载插件二进制

---

## 相关文档

- Live2D 模型获取: `engine/Live2D/models/README.md`
- gd_cubism 插件: `engine/addons/gd_cubism/bin/README.md`
- Git LFS 配置: `LFS_SETUP.md` (如果使用)

---

## 修改 .gitignore

如果需要修改 `.gitignore` 规则：

1. 编辑 `.gitignore` 文件
2. 测试规则是否生效：
   ```bash
   git check-ignore -v your_file
   ```
3. 如果需要应用到已追踪的文件：
   ```bash
   git rm -r --cached .
   git add .
   git commit -m "Update .gitignore rules"
   ```

---

**文档版本**: v1.0  
**最后更新**: 2025-10-22  
**维护者**: Marionet 开发团队
