# GDCubism 插件编译与使用指南

本文档说明如何编译 GDCubism 插件，以便在 Marionet 项目中使用 Live2D 模型渲染功能。

---

## 重要声明

GDCubism 是由 MizunagiKB 开发的独立项目，采用 MIT 许可证。

- 官方仓库: https://github.com/MizunagiKB/gd_cubism
- 作者: MizunagiKB
- 许可证: MIT License

本文档为编译指南，内容基于官方文档整理。如有疑问，请参考官方文档或联系原作者。

---

## 目录

- [概述](#概述)
- [准备工作](#准备工作)
- [获取源代码](#获取源代码)
- [获取 Live2D SDK](#获取-live2d-sdk)
- [平台编译指南](#平台编译指南)
  - [Windows](#windows-编译)
  - [macOS](#macos-编译)
  - [Linux](#linux-编译)
  - [iOS](#ios-编译-实验性)
  - [Android](#android-编译-实验性)
- [已知问题](#已知问题)
- [自定义 Framework](#自定义-framework)
- [集成到项目](#集成到项目)

---

## 概述

GDCubism 是连接 Godot Engine 与 Live2D Cubism SDK 的桥接插件。编译后会生成平台特定的二进制文件，用于在 Godot 项目中渲染 Live2D 模型。

### 编译产物

编译完成后会在 `demo/addons/gd_cubism/bin/` 目录下生成以下文件：

**Windows:**
- `libgd_cubism.windows.debug.x86_64.dll`
- `libgd_cubism.windows.release.x86_64.dll`

**macOS:**
- `libgd_cubism.macos.debug.framework`
- `libgd_cubism.macos.release.framework`

**Linux:**
- `libgd_cubism.linux.debug.x86_64.so`
- `libgd_cubism.linux.release.x86_64.so`

---

## 准备工作

### 所有平台通用要求

- **Python** 3.8 或更高版本
- **SCons** 构建系统

### SCons 版本要求

重要提示: SCons 4.8 存在已知问题，会导致构建失败。请使用 SCons 4.7：

```bash
# 安装指定版本的 SCons
pip install scons==4.7

# 如果已安装 4.8 或更高版本，可以降级
pip install scons==4.7 --force-reinstall
```

相关问题追踪: https://github.com/godotengine/godot/pull/94117

---

## 获取源代码

### 克隆 GDCubism 仓库

```bash
# 克隆仓库
git clone https://github.com/MizunagiKB/gd_cubism.git
cd gd_cubism

# 初始化子模块
git submodule update --init
```

### 版本选择

- 使用最新的稳定版本（推荐）
- 如需测试特定功能或修复，可切换到相应分支

```bash
# 查看可用分支
git branch -a

# 切换到特定分支（如有需要）
git checkout <branch_name>
```

---

## 获取 Live2D SDK

### 下载 SDK

从 Live2D 官方网站下载 Cubism SDK for Native：

官方网站: https://www.live2d.com/

注意事项:
- Cubism SDK for Native 包含 Cubism SDK Core 和 Cubism Native Framework
- 下载时需要接受 Live2D 的许可协议
- 用于开发和测试是免费的

### 配置 SDK 目录结构

下载后，将 SDK 解压到 GDCubism 项目的 `thirdparty` 目录，确保目录结构如下：

```
gd_cubism/
└── thirdparty/
    └── CubismSdkForNative-5-r.1/
        ├── CHANGELOG.md
        ├── Core/
        │   ├── CHANGELOG.md
        │   ├── LICENSE.md
        │   ├── README.ja.md
        │   ├── README.md
        │   ├── RedistributableFiles.txt
        │   ├── dll/
        │   ├── include/
        │   └── lib/
        ├── Framework/
        │   ├── CHANGELOG.md
        │   ├── CMakeLists.txt
        │   ├── LICENSE.md
        │   ├── README.ja.md
        │   ├── README.md
        │   ├── TRANSLATION.md
        │   └── src/
        ├── LICENSE.md
        ├── NOTICE.ja.md
        ├── NOTICE.md
        ├── README.ja.md
        ├── README.md
        └── Samples/
```

提示: 直接将下载的 SDK 文件夹放入 `thirdparty` 目录并解压即可获得正确的结构。

---

## 平台编译指南

### Windows 编译

#### 环境要求

- Visual Studio 2019 或更高版本（Community 版本即可）
- Python 3.8+
- SCons 4.7

#### Visual Studio 配置

重要提示: 必须安装 C++ 工作负载。

如果安装时未选择 C++ 支持：
1. 重新运行 Visual Studio Installer
2. 点击"修改"（Modify）按钮
3. 在"工作负载"中勾选"使用 C++ 的桌面开发"
4. 完成安装

注意: 从"添加或删除程序"启动安装程序只显示修复选项，无法添加 C++ 工具。

参考文档: [Godot Engine 4.1 Documentation](https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_for_windows.html)

#### 编译步骤

```bash
# 编译 Debug 版本
scons platform=windows vsproj=yes arch=x86_64 target=template_debug

# 编译 Release 版本
scons platform=windows vsproj=yes arch=x86_64 target=template_release
```

#### 编译产物

- `demo/addons/gd_cubism/bin/libgd_cubism.windows.debug.x86_64.dll`
- `demo/addons/gd_cubism/bin/libgd_cubism.windows.release.x86_64.dll`

---

### macOS 编译

#### 环境要求

- Xcode（包含命令行工具）
- Python 3.8+
- SCons 4.7

#### 编译步骤

**Intel Mac (x86_64):**

```bash
# Debug 版本
scons platform=macos arch=x86_64 target=template_debug

# Release 版本
scons platform=macos arch=x86_64 target=template_release
```

**Apple Silicon (arm64):**

```bash
# Debug 版本
scons platform=macos arch=arm64 target=template_debug

# Release 版本
scons platform=macos arch=arm64 target=template_release
```

**Universal Binary (推荐):**

如需构建 Universal Binary（同时支持 Intel 和 Apple Silicon），需先创建链接文件：

```bash
# 进入 SDK Core 目录
pushd thirdparty/CubismSdkForNative-5-r.1/Core/lib/macos

# 创建 universal 目录并合并库文件
mkdir universal
lipo -create arm64/libLive2DCubismCore.a x86_64/libLive2DCubismCore.a \
     -output universal/libLive2DCubismCore.a

popd

# 编译 Universal Binary
scons platform=macos arch=universal target=template_debug
scons platform=macos arch=universal target=template_release
```

#### 编译产物

- `demo/addons/gd_cubism/bin/libgd_cubism.macos.debug.framework`
- `demo/addons/gd_cubism/bin/libgd_cubism.macos.release.framework`

---

### Linux 编译

#### 环境要求

- GCC 7+ 或 Clang 6+
- Python 3.8+
- SCons 4.7
- 发行版特定的依赖包

#### 依赖包安装

不同 Linux 发行版需要的包可能不同，请参考 Godot Engine 文档：

[Compiling for Linux, *BSD](https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_for_linuxbsd.html)

常见依赖（Ubuntu/Debian）:

```bash
sudo apt-get update
sudo apt-get install build-essential scons pkg-config \
     libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev \
     libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev
```

#### 编译步骤

```bash
# Debug 版本
scons platform=linux arch=x86_64 target=template_debug

# Release 版本
scons platform=linux arch=x86_64 target=template_release
```

#### 编译产物

- `demo/addons/gd_cubism/bin/libgd_cubism.linux.debug.x86_64.so`
- `demo/addons/gd_cubism/bin/libgd_cubism.linux.release.x86_64.so`

---

### iOS 编译（实验性）

注意: iOS 编译仅确认可以构建，未进行完整的功能测试。

#### 环境要求

- Xcode
- Python 3.8+
- SCons 4.7

#### Xcode 路径配置

如果仅使用命令行工具，可能需要指定 Xcode 路径：

```bash
sudo xcode-select --switch /Applications/Xcode.app
```

#### 编译步骤

**ARM64 架构:**

```bash
# Debug 版本
scons platform=ios arch=arm64 target=template_debug

# Release 版本
scons platform=ios arch=arm64 target=template_release
```

**Universal Binary:**

```bash
# Debug 版本
scons platform=ios arch=universal target=template_debug

# Release 版本
scons platform=ios arch=universal target=template_release
```

#### 编译产物

- `libgd_cubism.ios.debug.arm64.dylib`
- `libgd_cubism.ios.release.arm64.dylib`
- `libgd_cubism.ios.debug.universal.dylib`
- `libgd_cubism.ios.release.universal.dylib`

---

### Android 编译（实验性）

注意: Android 编译仅确认可以构建，未进行完整的功能测试。

#### 环境要求

- Python 3.8+
- SCons 4.7
- Android Studio
- Azul Zulu JDK 21.28.85

#### Android Studio 配置

1. 启动 Android Studio
2. 打开 SDK Manager（Welcome 界面 → More Actions → SDK Manager）
3. 安装以下组件：

**SDK Platforms:**
- Android API 34
- Android 10 ("Q")

**SDK Tools:**
- Android SDK Build-Tools 34
- NDK (Side by side)
- Android SDK Command-line Tools (latest)
- CMake
- Android Emulator
- Android SDK Platform-Tools
- Android SDK Tools (Obsolete)

#### 环境变量配置

如果编译未启动，设置以下环境变量：

**Windows:**

```cmd
set ANDROID_SDK_ROOT=D:\Android\sdk
set ANDROID_HOME=D:\Android\sdk
set ANDROID_NDK_HOME=%ANDROID_SDK_ROOT%\ndk\26.0.10792818
set ANDROID_NDK_ROOT=%ANDROID_SDK_ROOT%\ndk\26.0.10792818
```

**Linux/macOS:**

```bash
export ANDROID_SDK_ROOT=/path/to/Android/sdk
export ANDROID_HOME=/path/to/Android/sdk
export ANDROID_NDK_HOME=$ANDROID_SDK_ROOT/ndk/26.0.10792818
export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/26.0.10792818
```

#### 编译步骤

```bash
# ARMv7 架构
scons platform=android target=template_debug arch=armv7
scons platform=android target=template_release arch=armv7

# ARM64 架构
scons platform=android target=template_debug arch=arm64v8
scons platform=android target=template_release arch=arm64v8
```

#### 编译产物

- `libgd_cubism.android.debug.arm32.so`
- `libgd_cubism.android.release.arm32.so`
- `libgd_cubism.android.debug.arm64.so`
- `libgd_cubism.android.release.arm64.so`

---

## 已知问题

### 内存泄漏问题（Vulkan 渲染器）

在某些环境下，当 Godot 窗口处于非显示状态时，使用 Vulkan 渲染器（Forward+、Mobile）会发生内存泄漏。

该问题在 macOS 环境中尚未完全解决。

#### 解决方案

GDCubism 提供了一个对策参数 `COUNTERMEASURES_90017_90030`：

**默认配置（推荐）:**

```bash
# 窗口非显示时不调用 Live2D 模型绘制
scons platform=<platform> COUNTERMEASURES_90017_90030=1
```

**禁用对策:**

```bash
# 无论窗口状态始终调用绘制（可能导致内存泄漏）
scons platform=<platform> COUNTERMEASURES_90017_90030=0
```

相关 Issue:
- https://github.com/godotengine/godot/issues/89651
- https://github.com/godotengine/godot/issues/90017
- https://github.com/godotengine/godot/issues/90030

### 与 Cubism Editor 的行为差异

GDCubism 使用的 Cubism Native Framework 虽然能够播放 Cubism Editor 创建的 Live2D 模型，但在绘制优先级和动作表现上可能存在差异。

参考文档:
- [Cubism 5 新功能的 SDK 对应](https://docs.live2d.com/en/cubism-sdk-manual/top/)
- [Cubism Editor 与平台比较](https://docs.live2d.com/en/cubism-editor-manual/platform-sdk-comparison/)
- [工作流程导致的动作差异](https://docs.live2d.com/en/cubism-editor-manual/motion-workflow-difference/)

建议: 在 Cubism Editor 中导出模型后，在实际运行环境中测试效果。

---

## 自定义 Framework

GDCubism 默认使用 Cubism SDK 附带的 Cubism Native Framework。如需使用最新版本或自定义扩展的 Framework：

### 获取自定义 Framework

```bash
pushd thirdparty
git clone https://github.com/Live2D/CubismNativeFramework.git
popd
```

### 优先级

构建系统会优先使用 `thirdparty/CubismNativeFramework/`（如存在），而非 SDK 附带的版本。

### 恢复默认

不再需要自定义 Framework 时，删除该目录即可：

```bash
rm -rf thirdparty/CubismNativeFramework
```

---

## 集成到项目

### 复制编译产物

将编译生成的二进制文件复制到 Marionet 项目的插件目录：

```bash
# 从 GDCubism 项目目录
cp -r demo/addons/gd_cubism /path/to/marionet/addons/

# 确保包含 bin/ 目录及其内容
```

### 在 Godot 中启用插件

1. 打开 Marionet 项目
2. 菜单: 项目 → 项目设置 → 插件
3. 找到 "GDCubism" 并勾选启用
4. 重启 Godot 编辑器

### 验证安装

检查是否出现错误：
- 打开 Godot 控制台
- 如无关于 GDCubism 或 Live2D 的错误信息，说明安装成功

测试渲染：
- 在场景中添加 Live2D 模型节点
- 加载示例模型文件
- 查看是否正确显示

---

## 故障排查

### 编译失败

**SCons 版本问题:**

```bash
# 检查 SCons 版本
scons --version

# 应显示 4.7.x，如为 4.8.x，请降级
pip install scons==4.7 --force-reinstall
```

**SDK 路径问题:**

- 确认 `thirdparty/CubismSdkForNative-5-r.1/` 目录存在
- 检查目录结构是否完整（包含 Core/ 和 Framework/）

**编译器未找到（Windows）:**

- 确认安装了 Visual Studio C++ 工作负载
- 确认编译环境是否正确
- 运行 "Developer Command Prompt for VS" 再执行 scons

### 插件加载失败

**二进制文件缺失:**

- 检查 `addons/gd_cubism/bin/` 目录
- 确认平台对应的 .dll/.so/.framework 文件存在

**架构不匹配:**

- Windows/Linux: 确认是 x86_64 架构
- macOS: 使用 universal 或匹配您 Mac 架构的版本

**权限问题（macOS/Linux）:**

```bash
# 添加执行权限
chmod +x addons/gd_cubism/bin/*.so
chmod +x addons/gd_cubism/bin/*.framework
```

### 模型显示异常

**模型文件问题:**

- 确认 .model3.json、.moc3 文件完整
- 检查贴图文件是否存在

**版本兼容性:**

- 确认模型是使用兼容版本的 Cubism Editor 导出
- 参考 Live2D 官方文档检查 SDK 版本兼容性

---

## 参考资源

### GDCubism

- 官方仓库: https://github.com/MizunagiKB/gd_cubism
- 许可证: MIT License
- 作者: MizunagiKB

### Live2D

- 官方网站: https://www.live2d.com/
- SDK 下载: https://www.live2d.com/en/download/cubism-sdk/download-native/
- 文档: https://docs.live2d.com/

### Godot Engine

- 官方网站: https://godotengine.org/
- 编译文档: https://docs.godotengine.org/en/stable/contributing/development/compiling/

---

## 许可证声明

GDCubism 插件采用 MIT 许可证。

编译后的二进制文件链接了 Live2D Cubism SDK，因此受 Live2D 专有许可证约束。
详细信息请参阅项目根目录的 LICENSE 文件。

---

最后更新: 2025-10-19