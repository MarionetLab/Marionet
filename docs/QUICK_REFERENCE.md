# 编码规范快速参考

> 一页纸速查手册 | 完整版见 [CODING_STANDARDS.md](./CODING_STANDARDS.md)

---

## 命名约定

### GDScript

| 类型 | 规则 | 示例 |
|------|------|------|
| **文件名** | PascalCase | `PlayerController.gd` |
| **类名** | PascalCase | `class_name PlayerController` |
| **常量** | SCREAMING_SNAKE_CASE | `const MAX_HEALTH: int = 100` |
| **变量** | snake_case | `var player_health: int = 100` |
| **私有变量** | _snake_case | `var _internal_state: int = 0` |
| **函数** | snake_case | `func calculate_damage() -> int:` |
| **私有函数** | _snake_case | `func _update_internal() -> void:` |
| **信号** | snake_case（过去式） | `signal health_changed(value: int)` |
| **枚举类型** | PascalCase | `enum State { IDLE, RUNNING }` |
| **枚举值** | SCREAMING_SNAKE_CASE | `State.IDLE` |

### C#

| 类型 | 规则 | 示例 |
|------|------|------|
| **文件名** | PascalCase | `WindowService.cs` |
| **类名** | PascalCase | `public class WindowService` |
| **接口** | IPascalCase | `public interface IService` |
| **常量** | PascalCase | `private const int MaxHealth = 100;` |
| **字段** | _camelCase | `private int _health;` |
| **属性** | PascalCase | `public int Health { get; set; }` |
| **方法** | PascalCase | `public void TakeDamage(int amount)` |
| **参数** | camelCase | `void Method(int paramName)` |
| **局部变量** | camelCase | `int localVariable = 0;` |
| **枚举** | PascalCase | `public enum PlayerState { Idle }` |

---

## 代码格式

### 缩进和换行

```gdscript
# GDScript - 使用 Tab
func example():
	if condition:
		do_something()
```

```csharp
// C# - 4 个空格
public void Example()
{
    if (condition)
    {
        DoSomething();
    }
}
```

### 行长度

- **代码**: 最多 100 字符
- **注释**: 最多 80 字符

```gdscript
# ✅ 适当换行
var result = some_function(
	first_parameter,
	second_parameter,
	third_parameter
)
```

---

## 类型注解

### GDScript

```gdscript
# ✅ 必须有类型注解
var health: int = 100
var speed: float = 5.0
var items: Array[Item] = []

func calculate(amount: int) -> int:
	return amount * 2

# ❌ 缺少类型
var health = 100  # 错误
func calculate(amount):  # 错误
	return amount * 2
```

### C#

```csharp
// ✅ 使用现代 C# 特性
public Player? CurrentPlayer { get; set; }  // 可空引用

// Null 检查
if (player is null)
{
	return;
}
```

---

## 脚本结构

### GDScript 标准顺序

```gdscript
# 1. @tool 声明
@tool

# 2. class_name 和继承
class_name PlayerController
extends CharacterBody2D

# 3. 信号
signal health_changed(new_health: int)

# 4. 枚举
enum State { IDLE, MOVING }

# 5. 常量
const MAX_HEALTH: int = 100

# 6. @export 变量
@export var speed: float = 200.0

# 7. 公共变量
var current_health: int = 100

# 8. 私有变量
var _velocity: Vector2 = Vector2.ZERO

# 9. @onready 变量
@onready var sprite: Sprite2D = $Sprite2D

# 10. 内置回调
func _ready():
	pass

func _process(delta: float):
	pass

# 11. 公共方法
func take_damage(amount: int) -> void:
	pass

# 12. 私有方法
func _update_state() -> void:
	pass
```

### C# 标准顺序

```csharp
public partial class WindowService : Node
{
	// 1. 常量
	private const int MaxRetries = 3;
	
	// 2. 字段
	private IntPtr _windowHandle;
	
	// 3. 属性
	public bool IsInitialized { get; set; }
	
	// 4. 事件
	public event Action WindowReady;
	
	// 5. 构造函数
	public WindowService() { }
	
	// 6. Godot 生命周期
	public override void _Ready() { }
	
	// 7. 公共方法
	public void SetClickThrough(bool enabled) { }
	
	// 8. 私有方法
	private void InitializeWindow() { }
}
```

---

## 注释规范

### 函数文档

```gdscript
## 对玩家造成伤害
##
## 参数:
##   amount: 伤害数值
##   damage_type: 伤害类型
##
## 返回:
##   实际造成的伤害
func take_damage(amount: int, damage_type: String) -> int:
	pass
```

```csharp
/// <summary>
/// 设置窗口点击穿透状态
/// </summary>
/// <param name="enabled">是否启用穿透</param>
/// <exception cref="InvalidOperationException">
/// 窗口未初始化时抛出
/// </exception>
public void SetClickThrough(bool enabled)
{
}
```

### 代码注释

```gdscript
# ✅ 解释"为什么"
# 使用 lerp 平滑移动，避免抖动
position = position.lerp(target, 0.1)

# ❌ 描述"是什么"（显而易见）
# 设置 position
position = target
```

### TODO 注释

```gdscript
# TODO(username): 添加碰撞检测
# FIXME(username): 修复跳跃 Bug
# HACK(username): 临时方案，需要重构
```

---

## Git 提交

### 提交消息格式

```
<type>(<scope>): <subject>

[body]

[footer]
```

### Type 类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(model): 添加模型预加载` |
| `fix` | Bug修复 | `fix(animation): 修复播放卡顿` |
| `refactor` | 重构 | `refactor(core): 重构服务定位器` |
| `docs` | 文档 | `docs(api): 更新 API 文档` |
| `style` | 格式 | `style: 格式化代码` |
| `test` | 测试 | `test(model): 添加单元测试` |
| `chore` | 构建 | `chore: 更新依赖` |
| `perf` | 性能 | `perf(render): 优化渲染性能` |

### 示例

```bash
# 简单提交
git commit -m "feat(emotion): 添加心情系统"

# 详细提交
git commit -m "feat(emotion): 添加心情系统

实现了基础的心情状态管理：
- 添加 MoodType 枚举
- 实现 MoodModel 类
- 添加心情值衰减机制

Closes #123"
```

### 分支命名

```bash
# 格式: type/description
git checkout -b feat/add-emotion-system
git checkout -b fix/eye-tracking-bug
git checkout -b refactor/renderer-cleanup
git checkout -b docs/update-readme
```

---

## 常见模式

### 信号使用

```gdscript
# ✅ 使用信号解耦
class_name Player

signal health_changed(new_health: int)

var health: int = 100:
	set(value):
		health = value
		health_changed.emit(health)

# 连接信号
func _ready():
	player.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health: int) -> void:
	health_bar.value = new_health
```

### 服务定位器

```gdscript
# ✅ 通过 ServiceLocator 获取依赖
func _ready():
	var model_service = ServiceLocator.get_service("ModelService")
	if model_service:
		model_service.load_model(0)

# ❌ 硬编码路径
var model_service = get_node("/root/Main/ModelService")
```

### 错误处理

```gdscript
# GDScript
func load_file(path: String) -> String:
	if path.is_empty():
		push_error("路径为空")
		return ""
	
	if not FileAccess.file_exists(path):
		push_error("文件不存在: %s" % path)
		return ""
	
	var file = FileAccess.open(path, FileAccess.READ)
	return file.get_as_text()
```

```csharp
// C#
public void LoadConfig(string path)
{
	if (string.IsNullOrEmpty(path))
	{
		throw new ArgumentException("路径不能为空", nameof(path));
	}
	
	if (!FileAccess.FileExists(path))
	{
		throw new FileNotFoundException($"文件不存在: {path}");
	}
	
	// 加载逻辑...
}
```

---

## 性能建议

```gdscript
# ✅ 缓存节点引用
@onready var sprite: Sprite2D = $Sprite2D

func _process(delta: float):
	sprite.position += Vector2(1, 0)  # 快速

# ❌ 每帧查找节点
func _process(delta: float):
	$Sprite2D.position += Vector2(1, 0)  # 慢

# ✅ 使用信号而不是轮询
signal button_pressed()

# ❌ 每帧检查
func _process(delta: float):
	if Input.is_action_just_pressed("jump"):
		jump()
```

---

## 检查清单

提交代码前检查：

- [ ] 代码遵循命名约定
- [ ] 所有函数有类型注解
- [ ] 公共 API 有文档注释
- [ ] 没有调试代码（print 语句）
- [ ] 提交消息符合规范
- [ ] 代码已测试
- [ ] 没有引入警告或错误

---

## 工具配置

### .editorconfig

```ini
[*.gd]
indent_style = tab
indent_size = 4

[*.cs]
indent_style = space
indent_size = 4
```

### VSCode 设置

```json
{
	"editor.tabSize": 4,
	"[gdscript]": {
		"editor.insertSpaces": false
	},
	"[csharp]": {
		"editor.insertSpaces": true
	}
}
```

---

## 快速链接

- 📖 [完整编码规范](./CODING_STANDARDS.md)
- 📖 [贡献指南](./CONTRIBUTING.md)
- 📖 [项目架构](./docs/architecture/architecture.md)
- 📖 [Git 提交规范](https://www.conventionalcommits.org/)

---

<p align="center">
  <sub>打印此页作为速查卡片 📋</sub>
</p>

