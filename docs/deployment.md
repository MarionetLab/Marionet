# GitHub Pages 部署指南

本指南将帮助您将 Marionet 文档部署到 GitHub Pages。

## 前置条件

1. 确保您的仓库是公开的
2. 确保您有仓库的管理员权限
3. 确保您的 GitHub 账户已启用 GitHub Pages

## 部署步骤

### 1. 启用 GitHub Pages

1. 进入您的仓库设置页面：`https://github.com/TLSLime/Marionet-docs/settings/pages`
2. 在左侧菜单中找到 "Pages" 选项
3. 在 "Source" 部分选择 "GitHub Actions"
4. 点击 "Save" 保存设置

!!! warning "重要步骤"
    如果看不到 "GitHub Actions" 选项，请确保：
    - 仓库是公开的（Public）
    - 您有仓库的管理员权限
    - 仓库中已经存在 `.github/workflows/` 文件夹

### 2. 推送代码

将以下文件推送到您的仓库：

```
.github/workflows/docs.yml  # GitHub Actions 工作流
mkdocs.yml                  # MkDocs 配置
requirements.txt            # Python 依赖
docs/index.md              # 文档首页
```

### 3. 等待部署

1. 推送代码后，GitHub Actions 会自动开始构建
2. 您可以在 "Actions" 标签页中查看构建进度
3. 构建成功后，文档将自动部署到 GitHub Pages

### 4. 访问文档

部署完成后，您可以通过以下链接访问文档：

```
https://[您的用户名].github.io/Marionet-docs/
```

## 本地预览

在部署之前，您可以在本地预览文档：

```bash
# 安装依赖
pip install -r requirements.txt

# 启动本地服务器
mkdocs serve

# 在浏览器中访问 http://127.0.0.1:8000
```

## 自定义配置

### 修改站点信息

编辑 `mkdocs.yml` 文件中的以下部分：

```yaml
site_name: Marionet（魔法人偶师）
site_description: 智能陪伴向的桌面宠物框架
site_url: https://tlslim.github.io/Marionet-docs/
```

### 添加 Google Analytics

在 `mkdocs.yml` 中修改：

```yaml
extra:
  analytics:
    provider: google
    property: G-XXXXXXXXXX  # 替换为您的 GA ID
```

### 自定义主题

您可以在 `mkdocs.yml` 中修改主题配置：

```yaml
theme:
  name: material
  palette:
    primary: purple
    accent: deep purple
```

## 故障排除

### 构建失败

1. 检查 `requirements.txt` 中的依赖版本
2. 确保所有 Markdown 文件格式正确
3. 查看 GitHub Actions 日志中的错误信息

### 页面无法访问

1. 确保 GitHub Pages 已正确启用
2. 检查仓库设置中的 Pages 配置
3. 等待几分钟让 DNS 传播

### 部署失败（404错误）

如果遇到 "Failed to create deployment (status: 404)" 错误：

1. **检查仓库权限**：
   - 确保仓库是公开的
   - 确保您有管理员权限

2. **重新启用 GitHub Pages**：
   - 进入仓库设置 → Pages
   - 如果已启用，先选择 "None" 保存
   - 然后重新选择 "GitHub Actions" 保存

3. **检查工作流文件**：
   - 确保 `.github/workflows/docs.yml` 文件存在
   - 确保文件语法正确

4. **重新触发部署**：
   - 在 Actions 页面手动重新运行工作流
   - 或者推送一个新的提交

### 样式问题

1. 确保使用了正确的 Material 主题
2. 检查 CSS 文件是否正确加载
3. 清除浏览器缓存

## 更新文档

每次推送更改到 `main` 分支时，文档都会自动重新构建和部署。您无需手动操作。

## 支持

如果您遇到问题，请：

1. 查看 [MkDocs 官方文档](https://www.mkdocs.org/)
2. 查看 [Material 主题文档](https://squidfunk.github.io/mkdocs-material/)
3. 在项目 Issues 中提问
