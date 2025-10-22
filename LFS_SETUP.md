# Git LFS 设置说明

本项目使用Git LFS (Large File Storage) 来管理大文件，特别是Live2D模型文件。

## 已配置的LFS文件类型

### Live2D模型文件
- `*.moc3` - Live2D模型文件
- `*.model3.json` - 模型配置文件
- `*.motion3.json` - 动作文件
- `*.exp3.json` - 表情文件
- `*.physics3.json` - 物理配置文件
- `*.pose3.json` - 姿势配置文件
- `*.cdi3.json` - 显示配置文件
- `*.can3` - 画布文件
- `*.cmo3` - 动作文件

### 图像文件
- `*.png`, `*.jpg`, `*.jpeg` - 纹理文件
- `*.gif`, `*.bmp`, `*.tga` - 其他图像格式

### 二进制文件
- `*.dll`, `*.lib`, `*.exp` - Windows库文件
- `*.so`, `*.dylib` - Linux/macOS库文件

## 首次设置LFS

如果您是第一次克隆此仓库，需要安装Git LFS：

### Windows
```bash
# 下载并安装Git LFS
# https://git-lfs.github.io/

# 或者使用Chocolatey
choco install git-lfs

# 或者使用Scoop
scoop install git-lfs
```

### macOS
```bash
# 使用Homebrew
brew install git-lfs
```

### Linux
```bash
# Ubuntu/Debian
sudo apt install git-lfs

# CentOS/RHEL
sudo yum install git-lfs
```

## 初始化LFS

在项目根目录运行：

```bash
# 初始化Git LFS
git lfs install

# 拉取LFS文件
git lfs pull
```

## 添加新的大文件

当添加新的大文件时，确保文件类型在`.gitattributes`中已配置：

```bash
# 添加文件（会自动使用LFS）
git add path/to/large/file.moc3

# 提交
git commit -m "Add new Live2D model"

# 推送（包括LFS文件）
git push
```

## 检查LFS状态

```bash
# 查看LFS跟踪的文件
git lfs ls-files

# 查看LFS状态
git lfs status

# 查看LFS配置
git lfs track
```

## 注意事项

1. **文件大小限制**：GitHub LFS有存储和带宽限制
2. **克隆时间**：首次克隆可能需要较长时间下载LFS文件
3. **网络要求**：需要稳定的网络连接来下载LFS文件
4. **存储成本**：LFS使用GitHub的存储配额

## 故障排除

### 如果LFS文件没有正确下载：
```bash
# 重新拉取LFS文件
git lfs pull

# 或者重置并重新拉取
git lfs checkout
```

### 如果遇到权限问题：
```bash
# 检查LFS配置
git config --list | grep lfs

# 重新初始化LFS
git lfs uninstall
git lfs install
```

## 更多信息

- [Git LFS官方文档](https://git-lfs.github.io/)
- [GitHub LFS文档](https://docs.github.com/en/repositories/working-with-files/managing-large-files)
