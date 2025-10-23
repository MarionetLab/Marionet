# 🚨 重要：重启 Godot 的步骤

> **当前状态**：C# 代码已编译成功，但 Godot 需要重新加载

---

## ✅ 已完成的操作

1. ✅ 所有 C# 代码修复完成
2. ✅ Legacy 文件夹已忽略
3. ✅ 项目配置已优化
4. ✅ `.godot` 缓存已清理
5. ✅ DLL 已成功编译

---

## 🎯 **必须执行的步骤**

### 步骤 1：完全关闭 Godot

1. 点击 Godot 窗口的 **X** 按钮
2. 确保进程管理器中没有 Godot 进程
3. **等待 5 秒**，确保所有文件句柄释放

### 步骤 2：重新打开 Godot

1. 启动 Godot
2. 打开项目列表
3. 选择 **engine** 项目
4. 点击 **编辑** 或 **运行**
5. **等待编辑器完全加载**（底部状态栏显示 "Ready"）

### 步骤 3：检查控制台

在 Godot 编辑器底部的 **"输出"** 标签页中，应该看到：

✅ **正确的输出**：
```
[WindowService] 已初始化
[WindowService] 窗口句柄已获取，窗口已设置为 layered + 点击穿透
[MouseDetection] 已找到 WindowService
[MouseDetection] 穿透检测已启用
[MouseDetection] 已找到 SubViewport，将使用它进行像素检测
```

❌ **不应该有的错误**：
```
ERROR: Failed to create an autoload
ERROR: script is not compiling
```

### 步骤 4：运行项目

1. 按 **F5** 或点击右上角的播放按钮
2. 观察控制台输出
3. 测试功能：
   - 点击透明区域（不应触发动画）
   - 点击人物模型（应触发动画）
   - 中键拖动窗口

---

## 🔧 **如果还是报错**

### 方案 A：检查 Godot 版本

确保使用的是 **Godot 4.5.1 Mono 版本**：
```
帮助 → 关于 Godot → 查看版本号
```

### 方案 B：手动构建

如果看到构建错误，尝试：
1. 在 Godot 中，点击右上角的 **".NET"** 按钮
2. 选择 **"Build Solution"**
3. 查看 MSBuild 面板的输出

### 方案 C：使用 Visual Studio

1. 用 Visual Studio 打开 `engine/renderer.sln`
2. **生成** → **清理解决方案**
3. **生成** → **重新生成解决方案**
4. 关闭 Visual Studio
5. 重启 Godot

---

## 📊 **诊断信息**

### 当前编译状态
```
✅ Debug DLL: D:\desktop\Marionet\engine\.godot\mono\temp\bin\Debug\MarionetEngine.dll
✅ Release DLL: D:\desktop\Marionet\engine\.godot\mono\temp\bin\Release\MarionetEngine.dll
✅ 项目配置: engine/renderer.csproj
✅ 导出配置: engine/export_presets.cfg
```

### 关键文件
```
✅ WindowService.cs - 窗口服务
✅ MouseDetection.cs - 鼠标检测服务
✅ Main.gd - 主场景脚本
✅ project.godot - 项目配置
```

---

## 💡 **提示**

- 第一次重新加载可能需要 10-20 秒
- Godot 会自动检测 C# 代码变化并重新编译
- 如果看到 "Mono: Initializing..." 说明正在加载 .NET 运行时
- 耐心等待，不要在加载过程中操作

---

## ❓ **常见问题**

### Q: 为什么需要重启？
A: Godot 在启动时加载 C# 程序集，修改后必须重启才能加载新的 DLL。

### Q: 清理缓存会丢失什么吗？
A: 不会。`.godot` 只是缓存文件夹，删除后会自动重新生成。

### Q: 可以直接运行吗？
A: 可以，但第一次运行时 Godot 会自动重新编译，可能需要等待。

---

**请完全关闭 Godot，等待 5 秒，然后重新打开！** 🚀

