# Live2D 模型目录

此目录用于存放 Live2D Cubism 模型文件。由于模型文件较大，我们不将其上传到 Git 仓库。

## 快速开始：下载示例模型

### 推荐使用：桃濑日和（Hiyori）

1. **访问 Live2D 官方示例下载页**  
    https://www.live2d.com/zh-CHS/learn/sample/

2. **下载"桃濑日和"模型**  
   - 在页面中找到 **"桃濑日和 (Hiyori)"** 示例
   - 下载 PRO 版或 FREE 版（两者都可用，推荐使用PRO）
   - 解压下载的文件

3. **放置模型文件**  
   将解压后的整个文件夹（例如 `hiyori_pro_zh`）复制到此目录下：
   ```
   engine/Live2D/models/hiyori_pro_zh/
   ```

4. **完成！**  
   重启 Godot 编辑器，引擎会自动加载模型。

## 目录结构示例

放置完成后，目录结构应如下所示：

```
models/
├── README.md              ← 本文件
├── .gitignore             ← Git 忽略配置
└── hiyori_pro_zh/         ← 你下载的模型
    ├── ReadMe.txt
    ├── hiyori_pro_t04.can3
    ├── hiyori_pro_t11.cmo3
    └── runtime/           ← 模型运行时文件
        ├── hiyori_pro_t11.moc3
        ├── hiyori_pro_t11.model3.json
        ├── hiyori_pro_t11.physics3.json
        ├── motion/
        └── hiyori_pro_t11.2048/
            ├── texture_00.png
            └── texture_01.png
```

## 其他可用模型

除了桃濑日和，Live2D 官方还提供其他免费示例模型：
- **Mao（茂）** - 可爱的猫耳角色
- **Nito（二头身）** - Q版角色
- **京** - 唇形同步示例角色

下载方式相同，均可从上述官方示例页面获取。

## 使用自己的模型

如果你有自己的 Live2D 模型：

1. 将整个模型文件夹放入此目录
2. 确保包含 `runtime/` 子目录及其中的 `*.model3.json` 文件
3. Godot 会自动检测并加载

## 许可证说明

**重要**：请遵守 Live2D 模型的使用许可。

- **官方示例模型**：可用于学习、测试和小规模商业项目
- **自制模型**：需遵守 Live2D Cubism 使用条款
- **大规模商业使用**：需购买 Live2D Cubism PRO 许可证

详情请参阅：
- [Live2D 示例素材使用授权](https://www.live2d.com/zh-CHS/learn/sample/)
- [Live2D 著作权作品简易许可方案](https://www.live2d.com/zh-CHS/terms/delicate/)

## 常见问题

**Q: 为什么 Git 仓库里没有模型文件？**  
A: 模型文件通常有几十到数百 MB，为了节省仓库空间，我们通常不会直接上传模型文件。

**Q: 模型下载下来放哪里？**  
A: 直接放在 `engine/Live2D/models/` 目录下，保持原文件夹结构。

**Q: 支持哪些模型格式？**  
A: 支持 Live2D Cubism 3.x 及以上版本的模型（`.moc3` 格式）。

---

**文档更新**: 2025-10-25


