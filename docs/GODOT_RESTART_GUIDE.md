# 🚨 **立即执行：关闭并重启 Godot**

> **当前状态**：所有代码已修复，但 Godot 必须重启才能生效

---

## ⚠️ **为什么必须重启？**

1. **DLL 文件被锁定**：Godot 正在使用旧的 DLL，阻止新版本生成
2. **缓存问题**：Godot 编辑器缓存了旧的配置和程序集
3. **自动加载问题**：Godot 在启动时加载 C# 自动加载脚本，修改后必须重启

---

## ✅ **已完成的修复**

1. ✅ WindowService 和 MouseDetection 代码修复
2. ✅ SubViewport 像素检测修复
3. ✅ Legacy 文件夹忽略
4. ✅ Unsafe 代码支持配置（新增 Directory.Build.props）
5. ✅ 项目配置优化
6. ✅ .godot 缓存清理

---

## 🎯 **重启步骤（必须按顺序执行）**

### 步骤 1：完全关闭 Godot（重要！）

1. **停止所有运行的场景**
   - 如果有项目在运行，按 `F8` 或点击停止按钮

2. **关闭 Godot 编辑器**
   - 点击窗口右上角的 `X` 按钮
   - 确保所有 Godot 窗口都关闭

3. **验证进程已终止**
   - 按 `Ctrl + Shift + Esc` 打开任务管理器
   - 查找 "Godot" 进程
   - 如果还有，右键 → **结束任务**

4. **等待 10 秒**
   - 让 Windows 释放所有文件句柄
   - 这一步很重要！

### 步骤 2：重新打开 Godot

1. **启动 Godot**
   ```
   双击 Godot 快捷方式或可执行文件
   ```

2. **打开项目**
   ```
   选择 "engine" 项目 → 点击 "编辑"
   ```

3. **等待完全加载**
   ```
   底部状态栏显示 "Ready"
   底部可能显示 "Mono: Initializing..."
   等待所有初始化完成（约 10-30 秒）
   ```

4. **检查输出标签页**
   ```
   点击底部的 "输出" 标签
   查看是否有错误消息
   ```

### 步骤 3：验证修复

**预期看到的输出**：
```
[WindowService] 已初始化
[WindowService] 窗口句柄已获取，窗口已设置为 layered + 点击穿透
[MouseDetection] 已找到 WindowService
[MouseDetection] 穿透检测已启用，将根据像素透明度动态调整窗口穿透状态
[MouseDetection] 已找到 SubViewport，将使用它进行像素检测
```

**不应该看到的错误**：
- ❌ `ERROR: Failed to create an autoload`
- ❌ `script is not compiling`
- ❌ `CS0227: 不安全代码只会在使用 /unsafe 编译的情况下出现`

### 步骤 4：运行项目

1. **按 F5 运行项目**

2. **测试功能**：
   - ✅ 点击透明区域（不应触发动画）
   - ✅ 点击人物模型（应触发动画）
   - ✅ 中键拖动窗口
   - ✅ 眼动追踪跟随鼠标

---

## 🔧 **如果还是有问题**

### 问题 A：仍然显示 "script is not compiling"

**解决方案**：
1. 关闭 Godot
2. 删除 `engine/.godot/` 文件夹
3. 删除 `engine/bin/` 和 `engine/obj/` 文件夹
4. 重新打开 Godot

### 问题 B：MSBuild 报 CS0227 错误

**解决方案**：
1. 确认 `engine/Directory.Build.props` 文件存在
2. 这个文件会全局启用 unsafe 代码支持
3. 重新打开 Godot

### 问题 C：DLL 被锁定无法编译

**解决方案**：
1. 完全关闭 Godot 和 Visual Studio
2. 等待 10 秒
3. 重新打开

---

## 📊 **技术细节**

### Directory.Build.props 的作用

新创建的 `engine/Directory.Build.props` 文件会：
- 对所有子目录生效（包括 addons/gd_cubism）
- 全局启用 unsafe 代码支持
- 设置统一的 C# 语言版本
- 自动被 MSBuild 加载

### GDCubism 插件 Unsafe 代码

GDCubism 插件使用了 unsafe 指针操作：
```csharp
// addons/gd_cubism/cs/gd_cubism_effect_custom_cs.cs
public unsafe event CubismEpilogueEventHandler CubismEpilogue
{
    add => this.InternalObject.Connect(..., &CubismEpilogueTrampoline);
    //                                      ^ unsafe 指针
}
```

这需要编译时启用 `/unsafe` 标志，现在通过 `Directory.Build.props` 全局启用。

---

## ✅ **最终检查清单**

重启后检查：

- [ ] Godot 编辑器完全加载（无错误）
- [ ] 输出面板显示正确的初始化日志
- [ ] 没有 "Failed to create an autoload" 错误
- [ ] 没有 CS0227 编译错误
- [ ] 运行项目（F5）成功
- [ ] 点击透明区域不触发动画
- [ ] 点击人物模型触发动画
- [ ] 中键拖动正常工作
- [ ] 眼动追踪正常工作

---

**现在，请立即关闭 Godot，等待 10 秒，然后重新打开！** 🚀

所有问题都已修复，只需要重启 Godot 即可！

