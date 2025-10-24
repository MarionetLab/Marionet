# GitHub Actions 工作流

本目录包含项目的 CI/CD 自动化工作流配置。

## 工作流列表

### 1. `ci.yml` - 主 CI 流程

**触发时机**:
- Push 到 `dev` 或 `main` 分支
- Pull Request 到 `dev` 或 `main` 分支

**检查内容**:
1. **GDScript 检查** - 语法和代码风格（使用 gdlint）
2. **C# 编译检查** - 验证 C# 代码可以编译
3. **Godot 项目检查** - 验证项目文件完整性
4. **文件结构检查** - 检查命名规范和禁止文件
5. **文档完整性检查** - 验证必需文档存在
6. **安全检查** - 扫描敏感信息泄露

**运行时间**: 约 5-10 分钟

### 2. `pr-check.yml` - PR 合并前检查

**触发时机**:
- Pull Request 到 `main` 分支

**检查内容**:
1. **PR 信息验证** - 标题格式、描述完整性、源分支
2. **变更分析** - 统计变更类型、提醒文档更新
3. **代码质量门禁** - 强制 GDScript 代码风格
4. **破坏性变更检查** - 检测 API 变更

**运行时间**: 约 3-5 分钟

## 环境要求

- **Godot**: 4.5-stable (Mono 版本)
- **.NET**: 8.0.x
- **Python**: 3.11
- **gdtoolkit**: 4.x

## 本地测试

在提交前可以在本地运行相同的检查：

```bash
# 安装依赖
pip install gdtoolkit==4.*

# GDScript 检查
cd engine
gdlint renderer/ core/

# C# 编译
dotnet build MarionetEngine.csproj
```

## 配置文件

- `.gdlintrc` - GDScript 代码风格配置
- `.gitattributes` - Git 文件属性
- `.gitignore` - 忽略文件配置

## 徽章

可以在 README 中使用这些徽章：

```markdown
![CI](https://github.com/YOUR_USERNAME/Marionet/workflows/CI%20-%20%E4%BB%A3%E7%A0%81%E8%B4%A8%E9%87%8F%E6%A3%80%E6%9F%A5/badge.svg)
```

## 故障排除

### CI 失败常见原因

1. **GDScript 语法错误**
   - 运行 `gdlint` 查看具体问题
   - 检查代码风格配置

2. **C# 编译失败**
   - 检查 using 引用
   - 验证类型匹配

3. **文件命名不规范**
   - GDScript/C# 文件必须使用 PascalCase
   - 检查文件扩展名

4. **PR 格式错误**
   - 标题必须符合 Conventional Commits
   - 描述不能过短

### 如何重新触发 CI

- 推送新的 commit
- 或在 GitHub Actions 页面点击 "Re-run jobs"

## 更多信息

详细文档请参考: [CI/CD Guide](../../docs/CI_CD_GUIDE.md)

