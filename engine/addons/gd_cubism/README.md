# GD Cubism 插件二进制文件目录

此目录用于存放 GD Cubism 插件的编译二进制文件。由于许可证和文件大小限制，我们不将二进制文件上传到 Git 仓库。

## 重要说明

**`bin/` 目录不包含在仓库中**，你需要：
1. 自行编译插件，或
2. 从其他来源获取预编译的二进制文件

然后将 `bin/` 文件夹放到本目录（`engine/addons/gd_cubism/`）下。

## 快速开始：获取二进制文件

### 方法 1：从官方下载（推荐）

1. **访问 GD Cubism 官方发布页**  
   https://github.com/MizunagiKB/gd_cubism/releases

2. **下载对应版本**  
   - 选择与你的 Godot 版本匹配的 GD Cubism 版本
   - 下载适合你操作系统的压缩包（Windows/Linux/macOS）

3. **提取二进制文件**  
   解压后，将 `bin/` 文件夹（包含 `.dll`、`.so` 或 `.dylib` 文件）复制到：
   ```
   engine/addons/gd_cubism/bin/
   ```

4. **重启 Godot**  
   重新打开项目，插件会自动加载。

### 方法 2：自行编译

如果需要自定义编译或官方版本不可用：

1. 克隆 GD Cubism 仓库：
   ```bash
   git clone https://github.com/MizunagiKB/gd_cubism.git
   ```

2. 按照官方文档编译：  
   https://github.com/MizunagiKB/gd_cubism

3. 将编译生成的 `bin/` 文件夹复制到本目录下。

## 目录结构示例

配置完成后，目录结构应如下：

```
gd_cubism/
├── README.md              ← 本文件
├── gd_cubism.gdextension  ← 插件配置文件
├── res/                   ← 资源文件（着色器等）
└── bin/                   ← 二进制文件（你需要添加）
    ├── libgd_cubism.windows.debug.x86_64.dll      (Windows)
    ├── libgd_cubism.windows.release.x86_64.dll
    ├── libgd_cubism.linux.debug.x86_64.so         (Linux)
    ├── libgd_cubism.linux.release.x86_64.so
    ├── libgd_cubism.macos.debug.universal.dylib   (macOS)
    └── libgd_cubism.macos.release.universal.dylib
```

## 所需二进制文件列表

根据你的操作系统，需要以下文件：

| 平台 | 文件名 |
|-----|--------|
| **Windows (x64)** | `libgd_cubism.windows.debug.x86_64.dll`<br>`libgd_cubism.windows.release.x86_64.dll` |
| **Linux (x64)** | `libgd_cubism.linux.debug.x86_64.so`<br>`libgd_cubism.linux.release.x86_64.so` |
| **macOS (通用)** | `libgd_cubism.macos.debug.universal.dylib`<br>`libgd_cubism.macos.release.universal.dylib` |

**注意**：Debug 版本用于开发调试，Release 版本用于发布。建议两者都下载。

## 验证安装

在 Godot 编辑器中验证插件是否正确安装：

1. 打开项目（`engine/project.godot`）
2. 进入 **项目 → 项目设置 → 插件**
3. 检查是否显示 **GD Cubism** 插件并已启用
4. 尝试在场景中添加 `GDCubismUserModel` 节点

### 常见问题

**Q: 为什么仓库里没有 `bin/` 文件夹？**  
A: 二进制文件体积大且包含许可证限制，我们不将其上传到 Git。

**Q: 插件无法加载怎么办？**  
A: 检查以下项：
- `bin/` 文件夹是否在正确位置
- 二进制文件名是否正确
- 是否下载了与 Godot 版本匹配的插件版本
- 重启 Godot 编辑器

**Q: 需要下载所有平台的文件吗？**  
A: 不需要。仅下载你当前使用的操作系统对应的文件即可。

**Q: CI/CD 环境如何处理？**  
A: 项目的 GitHub Actions 会自动从缓存或发布页下载插件二进制文件。

## 许可证

GD Cubism 插件遵循其自身的许可协议，详情请参阅：
- [GD Cubism License](https://github.com/MizunagiKB/gd_cubism/blob/main/LICENSE)
- [Live2D Cubism SDK License](https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html)

---

**文档更新**: 2025-10-25
