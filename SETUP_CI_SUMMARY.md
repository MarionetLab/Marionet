# CI/CD 自动化配置总结

> 为 Marionet 项目添加的 CI/CD 自动化检查系统

---

## ✅ 已完成的工作

### 1. GitHub Actions 工作流

创建了两个主要的 CI 工作流：

#### `.github/workflows/ci.yml` - 主 CI 流程
**触发条件**: 
- Push 到 `dev` 或 `main` 分支
- Pull Request 到 `dev` 或 `main`

**检查内容**:
1. **GDScript 检查** - 使用 `gdlint` 检查代码语法和风格
2. **C# 编译检查** - 验证 C# 代码可以正常编译
3. **Godot 项目验证** - 使用 Godot Headless 模式验证项目完整性
4. **文件结构检查** - 验证文件命名规范（PascalCase）
5. **文档完整性** - 检查必需文档是否存在
6. **安全扫描** - 检测硬编码的敏感信息

#### `.github/workflows/pr-check.yml` - PR 专用检查
**触发条件**: 
- Pull Request 到 `main` 分支

**检查内容**:
1. **PR 格式验证** - 标题必须符合 Conventional Commits
2. **变更分析** - 统计变更类型，提醒文档更新
3. **代码质量门禁** - 强制通过 gdlint 检查
4. **破坏性变更检测** - 检测 API 变更

### 2. 配置文件

#### `.gdlintrc` - GDScript 代码风格配置
```
- 行长度: 100 字符
- 函数复杂度: 15
- 最大参数: 5
- 缩进: Tab
- 命名规范: PascalCase/snake_case/SCREAMING_SNAKE_CASE
```

#### `.gitattributes` - Git 文件属性
- 统一行尾为 LF
- 标记二进制文件
- Live2D 文件特殊处理

#### `.gitignore` - 已配置忽略
- ✅ 插件二进制文件 (`engine/addons/gd_cubism/bin/*.dll`)
- ✅ Live2D 模型文件
- ✅ 编译输出（bin/, obj/）
- ✅ IDE 配置文件

### 3. PR 模板

#### `.github/PULL_REQUEST_TEMPLATE.md`
自动加载的 PR 模板，包含：
- 变更类型选择
- 详细描述指导
- 完整的检查清单
- 破坏性变更提醒

### 4. 文档更新

#### 新增文档:
- **`docs/CI_CD_GUIDE.md`** - CI/CD 完整指南
- **`.github/workflows/README.md`** - 工作流说明
- **`engine/addons/gd_cubism/bin/README.md`** - 插件获取指南

#### 更新文档:
- **`docs/CONTRIBUTING.md`** - 添加 CI/CD 章节
- **`README.md`** - 添加 CI 徽章和快速设置说明

### 5. 开发工具脚本

#### `scripts/setup-dev.sh` (Linux/macOS)
#### `scripts/setup-dev.ps1` (Windows)

自动化开发环境设置脚本，包含：
- 检查必需工具（Git, Python, .NET, Godot）
- 安装 `gdtoolkit` 代码检查工具
- 验证 GD Cubism 插件
- 可选安装 Git pre-commit hook
- 运行初始代码检查

---

## 📁 新增/修改的文件

### 新增文件 (11个)
```
.github/
├── workflows/
│   ├── ci.yml              # 主 CI 流程
│   ├── pr-check.yml        # PR 检查流程
│   └── README.md           # 工作流说明
├── PULL_REQUEST_TEMPLATE.md # PR 模板
.gdlintrc                    # GDScript 代码风格配置
.gitattributes               # Git 文件属性配置
docs/
└── CI_CD_GUIDE.md          # CI/CD 指南
engine/
└── addons/gd_cubism/bin/
    └── README.md           # 插件获取说明
scripts/
├── setup-dev.sh            # Linux/macOS 设置脚本
└── setup-dev.ps1           # Windows 设置脚本
SETUP_CI_SUMMARY.md         # 本文件
```

### 修改文件 (2个)
```
docs/CONTRIBUTING.md         # 添加 CI/CD 章节
README.md                    # 添加 CI 徽章和说明
```

---

## 🚀 使用方式

### 开发者本地检查

在提交代码前运行：

```bash
# 安装检查工具
pip install gdtoolkit==4.*

# 检查 GDScript
cd engine
gdlint renderer/ core/

# 检查 C# 编译
dotnet build MarionetEngine.csproj
```

### 自动 CI 流程

1. **推送到 dev 分支**
   ```bash
   git push origin dev
   ```
   → 自动触发完整 CI 检查

2. **创建 PR 到 main**
   ```bash
   # 在 GitHub 网页上创建 PR
   ```
   → 自动触发 PR 专用检查 + 完整 CI

3. **查看 CI 结果**
   - 进入 GitHub PR 页面
   - 查看 "Checks" 标签
   - 点击失败的检查查看详细日志

4. **修复问题后重新提交**
   ```bash
   git commit -m "fix: 修复 CI 检查问题"
   git push
   ```
   → CI 自动重新运行

---

## 🔧 CI 环境配置

### 工具版本
- **Godot**: 4.5-stable (Mono 版本)
- **.NET SDK**: 8.0.x
- **Python**: 3.11
- **gdtoolkit**: 4.x

### 运行平台
- **OS**: Ubuntu Latest (GitHub Actions)
- **运行时间**: 5-10 分钟（完整 CI）

---

## ⚠️ 重要说明

### 插件二进制文件处理

**问题**: `engine/addons/gd_cubism/bin/` 下的插件二进制文件不能上传到 Git

**解决方案**:
1. ✅ `.gitignore` 已配置忽略所有 `.dll`, `.so`, `.dylib` 文件
2. ✅ 创建了 `engine/addons/gd_cubism/bin/README.md` 说明如何获取插件
3. ✅ CI 中暂时跳过需要插件的高级测试
4. ✅ 文件结构检查会警告意外提交的二进制文件

**开发者需要做的**:
- 手动下载 GD Cubism 插件到本地 `engine/addons/gd_cubism/bin/`
- 参考 `engine/addons/gd_cubism/bin/README.md`

### Live2D 模型文件

**问题**: Live2D 模型文件较大，不适合 Git 跟踪

**解决方案**:
1. ✅ `.gitignore` 已配置忽略整个 `engine/Live2D/models/` 目录
2. ✅ 忽略所有 `.moc3`, `.can3`, `.cmo3` 等模型文件

---

## 📊 CI 检查统计

### 检查项总数: 6 大类
1. GDScript 语法和代码风格
2. C# 代码编译
3. Godot 项目完整性
4. 文件结构和命名规范
5. 文档完整性
6. 安全扫描

### 强制性检查 (必须通过)
- ✅ GDScript 语法正确
- ✅ C# 代码可以编译
- ✅ Godot 项目文件完整
- ✅ 没有提交禁止文件

### 警告性检查 (建议通过)
- ⚠️ 代码风格问题
- ⚠️ 文档可能需要更新
- ⚠️ 检测到 API 变更

---

## 🔮 未来改进计划

- [ ] 添加自动化单元测试
- [ ] 代码覆盖率报告
- [ ] 性能基准测试
- [ ] 自动生成 CHANGELOG
- [ ] 多平台构建（Windows/Linux/macOS）
- [ ] 自动化发布流程
- [ ] 缓存 GD Cubism 插件（避免每次下载）

---

## 📝 Git 提交说明

本次改动的提交建议：

```bash
git add .
git commit -m "chore(ci): 添加 GitHub Actions CI/CD 自动化检查

- 添加主 CI 流程（GDScript/C#/Godot 检查）
- 添加 PR 专用检查（格式验证/变更分析）
- 创建 PR 模板和开发环境设置脚本
- 更新贡献指南和 CI/CD 文档
- 配置 gdlint 代码风格检查

详见 SETUP_CI_SUMMARY.md"
```

---

## 🎯 核心原则

### ✅ 最小化改动
- 没有修改任何核心代码文件
- 只添加了配置文件和文档
- 不影响现有功能

### ✅ 渐进式集成
- CI 检查可以逐步完善
- 暂时允许部分警告通过
- 可以根据需要调整检查严格度

### ✅ 开发者友好
- 提供本地检查工具
- 详细的错误信息和修复指导
- 自动化设置脚本

### ✅ 文档完善
- 每个配置文件都有说明
- 提供了完整的 CI/CD 指南
- 更新了贡献指南

---

## 📞 问题反馈

如果在使用 CI/CD 过程中遇到问题：

1. 查看 [CI/CD 指南](docs/CI_CD_GUIDE.md)
2. 查看 GitHub Actions 日志
3. 在 Issue 中反馈

---

<p align="center">
  <strong>CI/CD 配置完成！</strong><br>
  <sub>自动化让开发更高效 🚀</sub>
</p>

