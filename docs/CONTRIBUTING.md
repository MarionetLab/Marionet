# 贡献指南

欢迎为 Marionet 做出贡献！项目处于早期原型阶段，我们欢迎各种形式的参与。

---

## 如何贡献

### 1️⃣ 报告问题

发现 Bug 或功能问题？[创建 Issue](https://github.com/MarionetLab/Marionet/issues/new/choose)

**重点说明**：
- 清晰描述问题
- 提供重现步骤
- 附上错误日志或截图
- 说明你的环境（操作系统、Godot 版本）

### 2️⃣ 协助测试

帮助测试最新功能：

1. 下载最新的 dev 分支代码
2. 按照 [SETUP_GUIDE.md](./SETUP_GUIDE.md) 配置环境
3. 运行并测试功能
4. 反馈问题或建议

**测试重点**：
- Live2D 模型加载和动画
- 窗口功能（透明、点击穿透、拖拽）
- 控制面板功能
- 性能表现

### 3️⃣ 提交代码

#### 快速流程

```bash
# Fork 并克隆项目
git clone https://github.com/YOUR_USERNAME/Marionet.git
cd Marionet

# 从 dev 分支创建功能分支
git checkout dev
git checkout -b feat/your-feature

# 开发并测试
cd engine
godot project.godot

# 提交代码
git add .
git commit -m "feat(scope): 简短描述"
git push origin feat/your-feature
```

#### 提交规范

**Commit 格式**：`type(scope): description`

常用类型：
- `feat` - 新功能
- `fix` - 修复 Bug
- `docs` - 文档
- `refactor` - 重构

**示例**：
```
feat(animation): 添加表情切换功能
fix(window): 修复拖拽失效问题
docs(api): 更新 ModelService 文档
```

#### 代码要求

提交前确保：
- [ ] 遵循 [编码规范](./CODING_STANDARDS.md)
- [ ] 在 Godot 编辑器运行无错误
- [ ] 公共 API 有类型注释
- [ ] 移除调试代码
- [ ] 同步更新相关文档

---

## 开发环境

### 必需软件

- **Godot 4.3+**（.NET 版本）
- **.NET SDK 8.0+**
- **Git**

### 快速开始

```bash
# 克隆项目
git clone https://github.com/MarionetLab/Marionet.git
cd Marionet

# 打开 Godot 项目
cd engine
godot project.godot

# 在编辑器中 Build → Build Solution
# 运行主场景测试
```

详细配置见 [SETUP_GUIDE.md](./SETUP_GUIDE.md)

---

## 代码风格速查

### GDScript

```gdscript
class_name ServiceName
extends Node

const MAX_VALUE: int = 100
var public_var: String = ""
var _private_var: int = 0

func public_method(param: int) -> void:
	pass

func _private_method() -> void:
	pass
```

### C#

```csharp
public partial class WindowService : Node
{
	private const int MaxRetries = 3;
	private int _fieldName;
	
	public bool PropertyName { get; set; }
	
	public void MethodName()
	{
		// Implementation
	}
}
```

完整规范见 [CODING_STANDARDS.md](./CODING_STANDARDS.md)

---

## 文档贡献

文档同样重要！你可以：

- 改进现有文档的清晰度
- 添加使用示例
- 修正错误或过时内容
- 翻译文档

**文档位置**：
- 项目文档：`docs/`
- 代码注释：GDScript 用 `##`，C# 用 `///`

---

## 寻求帮助

遇到问题？

1. 查看 [文档](https://github.com/MarionetLab/Marionet/tree/main/docs)
2. 搜索 [Issues](https://github.com/MarionetLab/Marionet/issues)
3. 在 [讨论区](https://github.com/orgs/MarionetLab/discussions) 提问

---

## 行为准则

- 保持友好和尊重
- 接受建设性批评
- 关注项目最佳利益
- 礼貌沟通

---

## 许可证

详细请见[License](../LICENSE.md) 

---

**感谢你的参与！每个贡献都让 Marionet 变得更好。**

