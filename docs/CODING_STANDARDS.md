# Marionet 编码规范

> 版本: 1.0 | 更新日期: 2025-01-22

---

## 目录

- [概述](#概述)
- [通用规范](#通用规范)
- [GDScript 规范](#gdscript-规范)
- [C# 规范](#c-规范)
- [项目结构规范](#项目结构规范)
- [Git 提交规范](#git-提交规范)
- [文档规范](#文档规范)
- [性能规范](#性能规范)

---

## 概述

### 目的

本文档定义了 Marionet 项目的编码标准和最佳实践。遵循这些规范可以：

1. **提高代码可读性** - 统一的风格让代码更易理解
2. **减少错误** - 明确的规则减少常见错误
3. **便于协作** - 一致的代码风格降低沟通成本
4. **提升质量** - 系统化的规范保证代码质量

### 适用范围

- ✅ 所有新代码必须遵循本规范
- ✅ 修改现有代码时应逐步向本规范靠拢
- ⚠️ 对于第三方代码和生成代码可以例外

### 强制等级

- **MUST** / **必须** - 强制要求，必须遵守
- **SHOULD** / **应该** - 强烈建议，除非有充分理由
- **MAY** / **可以** - 可选，根据具体情况决定

---

## 通用规范

### 1. 文件编码

**MUST**:
- 所有文本文件必须使用 **UTF-8** 编码
- 文件必须以换行符结尾（LF，不是 CRLF）
- 不使用 BOM（Byte Order Mark）

```bash
# 检查和转换编码
file -bi filename.gd
dos2unix filename.gd  # 转换 CRLF → LF
```

### 2. 缩进和空格

**MUST**:
- GDScript: 使用 **Tab** 缩进（Godot 默认）
- C#: 使用 **4 个空格** 缩进
- 不混用 Tab 和空格
- 行尾不允许有多余空格

```gdscript
# ✅ 正确 - GDScript 使用 Tab
func example():
	if condition:
		do_something()
```

```csharp
// ✅ 正确 - C# 使用 4 空格
public void Example()
{
    if (condition)
    {
        DoSomething();
    }
}
```

### 3. 行长度

**SHOULD**:
- 每行代码不超过 **100 个字符**
- 注释和文档字符串不超过 **80 个字符**

**例外**:
- 长字符串字面量
- 长 URL 或路径
- Import 语句

```gdscript
# ✅ 正确 - 适当换行
var long_variable_name = some_function(
	first_parameter,
	second_parameter,
	third_parameter
)

# ❌ 错误 - 过长
var long_variable_name = some_function(first_parameter, second_parameter, third_parameter, fourth_parameter)
```

### 4. 命名约定

#### 通用原则

**MUST**:
- 使用英文命名，禁止拼音或中文
- 名称应该具有描述性，避免缩写
- 避免单字母变量（除非是循环计数器）

```gdscript
# ✅ 正确
var player_health: int = 100
var animation_duration: float = 1.5

# ❌ 错误
var ph: int = 100  # 不清晰
var donghua_shijian: float = 1.5  # 使用拼音
```

#### 特殊缩写

**MAY** 使用的常见缩写:

| 缩写 | 全称 | 使用场景 |
|------|------|---------|
| `id` | identifier | 标识符 |
| `num` | number | 数量 |
| `max` / `min` | maximum / minimum | 最大/最小值 |
| `pos` | position | 位置（简单上下文） |
| `vel` | velocity | 速度（物理计算） |
| `idx` | index | 索引（循环中） |

---

## GDScript 规范

### 1. 命名约定

#### 1.1 文件名

**MUST**:
- 使用 **PascalCase**（大驼峰）
- 文件名应该与主类名一致
- 后缀必须是 `.gd`

```
✅ 正确:
ModelService.gd
PlayerController.gd
ConfigManager.gd

❌ 错误:
model_service.gd
player-controller.gd
configmanager.gd
```

#### 1.2 类名

**MUST**:
- 使用 **PascalCase**
- 使用 `class_name` 声明

```gdscript
# ✅ 正确
class_name PlayerController
extends Node

class_name ModelService
extends Node

# ❌ 错误
class_name player_controller  # 应该用 PascalCase
class_name modelService       # 不一致
```

#### 1.3 变量和函数名

**MUST**:
- 使用 **snake_case**（小写+下划线）
- 私有变量以 `_` 开头
- 常量使用 **SCREAMING_SNAKE_CASE**

```gdscript
# ✅ 正确 - 变量
var player_health: int = 100
var animation_speed: float = 1.0
var _internal_state: Dictionary = {}  # 私有

# ✅ 正确 - 常量
const MAX_HEALTH: int = 100
const DEFAULT_SPEED: float = 5.0
const MODEL_BASE_PATH: String = "res://models/"

# ✅ 正确 - 函数
func calculate_damage(attacker: Node, defender: Node) -> int:
	return 10

func _internal_helper() -> void:  # 私有函数
	pass

# ❌ 错误
var playerHealth: int = 100       # 应该用 snake_case
var PlayerHealth: int = 100       # 应该用 snake_case
const max_health: int = 100       # 常量应该全大写
func CalculateDamage() -> int:    # 函数应该用 snake_case
```

#### 1.4 信号名

**MUST**:
- 使用 **snake_case**
- 使用过去式（表示已发生的事件）

```gdscript
# ✅ 正确
signal health_changed(new_health: int)
signal player_died()
signal animation_finished(animation_name: String)
signal model_loaded(model_name: String)

# ❌ 错误
signal HealthChanged(new_health: int)  # 应该用 snake_case
signal player_die()                    # 应该用过去式
signal on_animation_finish()           # 不要用 "on_" 前缀
```

#### 1.5 枚举

**MUST**:
- 枚举类型名使用 **PascalCase**（可选）
- 枚举值使用 **SCREAMING_SNAKE_CASE**

```gdscript
# ✅ 正确
enum State {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING
}

enum MoodType {
	HAPPY,
	SAD,
	ANGRY,
	NEUTRAL
}

# ❌ 错误
enum State {
	idle,      # 应该全大写
	Running,   # 应该全大写
	JUMPING    # 正确
}
```

### 2. 代码组织

#### 2.1 脚本结构

**MUST** 按以下顺序组织代码:

```gdscript
# 1. 工具声明（如果需要）
@tool

# 2. 类名和继承
class_name PlayerController
extends CharacterBody2D

# 3. 信号
signal health_changed(new_health: int)
signal died()

# 4. 枚举
enum State {
	IDLE,
	MOVING,
	ATTACKING
}

# 5. 常量
const MAX_HEALTH: int = 100
const MOVE_SPEED: float = 200.0

# 6. 导出变量
@export var max_health: int = 100
@export var speed: float = 200.0

# 7. 公共变量
var current_health: int = 100
var current_state: State = State.IDLE

# 8. 私有变量
var _velocity: Vector2 = Vector2.ZERO
var _internal_timer: float = 0.0

# 9. @onready 变量
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# 10. 内置回调（按生命周期顺序）
func _init():
	pass

func _ready():
	pass

func _process(delta: float):
	pass

func _physics_process(delta: float):
	pass

func _input(event: InputEvent):
	pass

# 11. 公共方法
func take_damage(amount: int) -> void:
	current_health -= amount
	health_changed.emit(current_health)

# 12. 私有方法
func _update_animation() -> void:
	pass

# 13. 内部类（如果需要）
class InternalHelper:
	var data: int = 0
```

#### 2.2 分组和注释

**SHOULD** 使用注释分隔不同功能区域:

```gdscript
# ========== 初始化 ==========

func _ready():
	_initialize_components()
	_connect_signals()

# ========== 输入处理 ==========

func _input(event: InputEvent):
	if event is InputEventKey:
		_handle_key_input(event)

# ========== 物理更新 ==========

func _physics_process(delta: float):
	_update_movement(delta)
	_apply_gravity(delta)

# ========== 公共接口 ==========

func take_damage(amount: int) -> void:
	pass

# ========== 私有方法 ==========

func _update_animation() -> void:
	pass
```

### 3. 类型注解

**MUST**:
- 所有函数参数必须有类型注解
- 所有函数返回值必须有类型注解
- 公共变量必须有类型注解

**SHOULD**:
- 局部变量应该有类型注解（当类型不明显时）

```gdscript
# ✅ 正确 - 完整的类型注解
var player_health: int = 100
var movement_speed: float = 5.0
var player_name: String = "Hero"
var inventory: Array[Item] = []
var config: Dictionary = {}

func calculate_damage(attacker: Node, defender: Node) -> int:
	var base_damage: int = 10
	var multiplier: float = 1.5
	return int(base_damage * multiplier)

func get_player_position() -> Vector2:
	return position

func initialize() -> void:
	pass

# ❌ 错误 - 缺少类型注解
var player_health = 100  # 应该标注类型
func calculate_damage(attacker, defender):  # 缺少参数类型
	return 10

func get_player_position():  # 缺少返回类型
	return position
```

### 4. 控制结构

#### 4.1 条件语句

**MUST**:
- 总是使用花括号（即使只有一行）
- 运算符两侧加空格

```gdscript
# ✅ 正确
if health <= 0:
	die()

if health > 50:
	play_animation("healthy")
elif health > 20:
	play_animation("wounded")
else:
	play_animation("critical")

# ✅ 正确 - 复杂条件换行
if (player.is_alive() and 
	player.has_item("key") and 
	door.is_locked()):
	door.unlock()

# ❌ 错误 - 缺少缩进
if health <= 0:
die()  # 应该缩进

# ❌ 错误 - 条件过于复杂，不换行
if player.is_alive() and player.has_item("key") and door.is_locked() and not door.is_broken():
	door.unlock()
```

#### 4.2 循环

```gdscript
# ✅ 正确 - for 循环
for i in range(10):
	print(i)

for item in inventory:
	item.update()

for key in dictionary:
	print(key, dictionary[key])

# ✅ 正确 - while 循环
while is_running:
	update()

# ✅ 正确 - 循环控制
for enemy in enemies:
	if enemy.is_dead():
		continue
	
	if player.is_far_from(enemy):
		break
	
	enemy.attack(player)

# ❌ 错误 - 单字母变量（除了简单的索引）
for e in enemies:  # 应该用 enemy
	e.update()
```

### 5. 函数设计

#### 5.1 函数长度

**SHOULD**:
- 函数长度不超过 **50 行**
- 如果超过，考虑拆分为多个小函数

```gdscript
# ✅ 正确 - 拆分为多个小函数
func initialize():
	_setup_components()
	_load_resources()
	_connect_signals()

func _setup_components() -> void:
	sprite = $Sprite2D
	animation_player = $AnimationPlayer

func _load_resources() -> void:
	texture = load("res://textures/player.png")

func _connect_signals() -> void:
	health_changed.connect(_on_health_changed)

# ❌ 错误 - 函数过长
func initialize():
	# 100+ 行代码...
```

#### 5.2 函数参数

**SHOULD**:
- 参数数量不超过 **5 个**
- 超过 5 个考虑使用 Dictionary 或创建配置对象

```gdscript
# ✅ 正确
func create_character(name: String, health: int, speed: float) -> Character:
	pass

# ✅ 正确 - 使用配置对象
func create_character(config: Dictionary) -> Character:
	var name = config.get("name", "Unknown")
	var health = config.get("health", 100)
	var speed = config.get("speed", 5.0)
	# ...

# ❌ 错误 - 参数过多
func create_character(name: String, health: int, speed: float, 
					 strength: int, agility: int, intelligence: int,
					 texture: Texture2D, position: Vector2) -> Character:
	pass
```

#### 5.3 返回值

**SHOULD**:
- 函数应该只有一个明确的职责
- 避免在一个函数中返回多种不同类型

```gdscript
# ✅ 正确
func get_player_health() -> int:
	return current_health

func find_player() -> Player:
	return get_node("/root/Player")

# ✅ 正确 - 可能失败的操作返回 null
func find_enemy_by_id(id: int) -> Enemy:
	for enemy in enemies:
		if enemy.id == id:
			return enemy
	return null

# ❌ 错误 - 返回类型不一致
func get_value():  # 有时返回 int，有时返回 String
	if condition:
		return 100
	else:
		return "error"
```

### 6. 信号使用

**MUST**:
- 使用信号而不是直接调用父节点或其他节点的方法
- 信号名使用过去式

```gdscript
# ✅ 正确 - 使用信号
class_name Player
extends CharacterBody2D

signal health_changed(new_health: int)
signal died()

var health: int = 100:
	set(value):
		health = value
		health_changed.emit(health)
		if health <= 0:
			died.emit()

# ❌ 错误 - 直接调用父节点
func take_damage(amount: int) -> void:
	health -= amount
	get_parent().update_health_bar(health)  # 耦合度过高
```

**SHOULD**:
- 连接信号时使用类型安全的方式

```gdscript
# ✅ 正确
func _ready():
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)

func _on_player_health_changed(new_health: int) -> void:
	health_bar.value = new_health

func _on_player_died() -> void:
	game_over()

# ❌ 错误 - 使用字符串连接（Godot 3 风格）
func _ready():
	player.connect("health_changed", self, "_on_player_health_changed")
```

### 7. 注释规范

#### 7.1 文件头注释

**SHOULD** 在每个文件开头添加简要说明:

```gdscript
# PlayerController.gd
# 玩家控制器 - 处理玩家输入和移动
# 负责：
# - 键盘/手柄输入处理
# - 移动和跳跃逻辑
# - 动画状态控制
extends CharacterBody2D
class_name PlayerController
```

#### 7.2 函数注释

**MUST** 为公共函数添加文档注释:

```gdscript
# ✅ 正确 - 完整的函数文档
## 对玩家造成伤害
##
## 参数:
##   amount: 伤害数值
##   damage_type: 伤害类型（"physical", "magic", "fire"）
##   attacker: 攻击者节点
##
## 返回:
##   实际造成的伤害（考虑护甲减免后）
func take_damage(amount: int, damage_type: String, attacker: Node) -> int:
	var actual_damage = _calculate_damage(amount, damage_type)
	current_health -= actual_damage
	health_changed.emit(current_health)
	return actual_damage
```

#### 7.3 行内注释

**SHOULD**:
- 解释 **为什么** 而不是 **是什么**
- 注释在代码上方，而不是行尾（除非很短）

```gdscript
# ✅ 正确 - 解释原因
# 使用 lerp 平滑移动，避免抖动
position = position.lerp(target_position, 0.1)

# 等待一帧确保节点完全加载
await get_tree().process_frame

# ✅ 正确 - 简短注释可以在行尾
var speed: float = 200.0  # 单位：像素/秒

# ❌ 错误 - 只描述了代码做了什么（显而易见）
# 设置 position 为 lerp 的结果
position = position.lerp(target_position, 0.1)
```

#### 7.4 TODO 注释

**MUST** 使用统一格式:

```gdscript
# TODO(username): 添加敌人 AI 逻辑
# TODO(zhangsan): 优化碰撞检测性能
# FIXME(lisi): 修复跳跃高度不一致的问题
# HACK(wangwu): 临时解决方案，需要重构
# XXX(zhaoliu): 这段代码有问题，需要仔细检查
```

---

## C# 规范

### 1. 命名约定

#### 1.1 文件名

**MUST**:
- 使用 **PascalCase**
- 文件名与类名一致
- 后缀必须是 `.cs`

```
✅ 正确:
WindowService.cs
PlayerController.cs
ConfigManager.cs

❌ 错误:
windowService.cs
player_controller.cs
```

#### 1.2 类和接口

**MUST**:
- 类名使用 **PascalCase**
- 接口名以 `I` 开头
- 抽象类可以以 `Base` 或 `Abstract` 开头

```csharp
// ✅ 正确
public class WindowService : Node
{
}

public interface IMemoryService
{
}

public abstract class BaseService
{
}

// ❌ 错误
public class windowService  // 应该用 PascalCase
public class Window_Service // 不使用下划线
public interface MemoryService  // 接口应该以 I 开头
```

#### 1.3 方法和属性

**MUST**:
- 公共方法使用 **PascalCase**
- 私有方法使用 **PascalCase**（C# 约定）
- 参数使用 **camelCase**
- 局部变量使用 **camelCase**

```csharp
// ✅ 正确
public class PlayerController : Node
{
	// 公共属性 - PascalCase
	public int MaxHealth { get; set; } = 100;
	public float Speed { get; private set; } = 5.0f;
	
	// 私有字段 - _camelCase
	private int _currentHealth;
	private float _moveSpeed;
	
	// 公共方法 - PascalCase
	public void TakeDamage(int amount)
	{
		// 参数 - camelCase
		// 局部变量 - camelCase
		int actualDamage = CalculateDamage(amount);
		_currentHealth -= actualDamage;
	}
	
	// 私有方法 - PascalCase
	private int CalculateDamage(int baseDamage)
	{
		return baseDamage * 2;
	}
}

// ❌ 错误
public class PlayerController
{
	public int maxHealth;  // 应该用属性而不是字段
	private int CurrentHealth;  // 私有字段不应该 PascalCase
	
	public void take_damage(int Amount)  // 方法应该 PascalCase
	{
		int ActualDamage = 0;  // 局部变量应该 camelCase
	}
}
```

#### 1.4 常量和枚举

**MUST**:
- 常量使用 **PascalCase**
- 枚举类型使用 **PascalCase**
- 枚举值使用 **PascalCase**

```csharp
// ✅ 正确
public class Constants
{
	public const int MaxHealth = 100;
	public const float DefaultSpeed = 5.0f;
	public const string ModelBasePath = "res://models/";
}

public enum PlayerState
{
	Idle,
	Running,
	Jumping,
	Falling
}

public enum MoodType
{
	Happy,
	Sad,
	Angry,
	Neutral
}

// ❌ 错误
public const int MAX_HEALTH = 100;  // C# 中常量用 PascalCase
public enum PlayerState
{
	IDLE,  // 应该用 PascalCase
	running,  // 应该用 PascalCase
}
```

### 2. 代码组织

#### 2.1 类结构

**MUST** 按以下顺序组织代码:

```csharp
using System;
using System.Collections.Generic;
using Godot;

/// <summary>
/// 窗口服务 - 负责窗口管理和属性控制
/// </summary>
public partial class WindowService : Node
{
	// 1. 常量
	private const int GwlExStyle = -20;
	private const uint WsExLayered = 0x00080000;
	
	// 2. 字段（按访问级别分组）
	// 2.1 私有字段
	private IntPtr _hWnd;
	private bool _isInitialized;
	
	// 3. 属性（按访问级别分组）
	// 3.1 公共属性
	public bool IsInitialized => _isInitialized;
	
	// 3.2 私有属性
	private string InternalState { get; set; }
	
	// 4. 事件
	public event Action WindowInitialized;
	
	// 5. 构造函数
	public WindowService()
	{
		_isInitialized = false;
	}
	
	// 6. Godot 生命周期方法
	public override void _Ready()
	{
		CallDeferred(nameof(InitializeWindow));
	}
	
	public override void _Process(double delta)
	{
		// 更新逻辑
	}
	
	// 7. 公共方法
	public void SetClickThrough(bool clickthrough)
	{
		// 实现
	}
	
	public IntPtr GetWindowHandle()
	{
		return _hWnd;
	}
	
	// 8. 私有方法
	private void InitializeWindow()
	{
		// 实现
	}
	
	private void UpdateState()
	{
		// 实现
	}
	
	// 9. 嵌套类型
	private class InternalHelper
	{
		public int Data { get; set; }
	}
}
```

### 3. 类型和 Null 处理

**SHOULD** 使用 C# 的现代特性:

```csharp
// ✅ 正确 - 使用可空引用类型（C# 8.0+）
public class PlayerService : Node
{
	// 可空属性
	public Player? CurrentPlayer { get; private set; }
	
	// 非空属性
	public string PlayerName { get; set; } = string.Empty;
	
	// Null 检查
	public void UpdatePlayer(Player? player)
	{
		if (player is null)
		{
			GD.PrintErr("Player is null");
			return;
		}
		
		CurrentPlayer = player;
	}
	
	// 模式匹配
	public void ProcessInput(InputEvent inputEvent)
	{
		switch (inputEvent)
		{
			case InputEventKey keyEvent when keyEvent.Pressed:
				HandleKeyPress(keyEvent);
				break;
			case InputEventMouseButton mouseEvent:
				HandleMouseClick(mouseEvent);
				break;
			default:
				break;
		}
	}
}

// ❌ 错误 - 不进行 Null 检查
public void UpdatePlayer(Player player)
{
	CurrentPlayer = player;  // 可能为 null
	player.Update();  // 可能抛出 NullReferenceException
}
```

### 4. 异常处理

**MUST**:
- 使用具体的异常类型
- 提供有意义的错误消息
- 记录异常到日志

```csharp
// ✅ 正确
public class ConfigService : Node
{
	public void LoadConfig(string path)
	{
		if (string.IsNullOrEmpty(path))
		{
			throw new ArgumentException("配置文件路径不能为空", nameof(path));
		}
		
		if (!FileAccess.FileExists(path))
		{
			throw new FileNotFoundException($"配置文件不存在: {path}");
		}
		
		try
		{
			var content = FileAccess.Open(path, FileAccess.ModeFlags.Read);
			// 处理文件
		}
		catch (Exception ex)
		{
			GD.PrintErr($"加载配置失败: {ex.Message}");
			throw new InvalidOperationException($"无法加载配置文件: {path}", ex);
		}
	}
}

// ❌ 错误
public void LoadConfig(string path)
{
	try
	{
		var content = FileAccess.Open(path, FileAccess.ModeFlags.Read);
	}
	catch (Exception)
	{
		// 吞掉异常，不记录也不处理
	}
}
```

### 5. LINQ 使用

**SHOULD** 使用 LINQ 进行集合操作:

```csharp
// ✅ 正确 - 使用 LINQ
var aliveEnemies = enemies
	.Where(e => e.IsAlive)
	.OrderBy(e => e.Distance)
	.Take(5)
	.ToList();

var totalDamage = attacks
	.Where(a => a.IsSuccessful)
	.Sum(a => a.Damage);

// ✅ 正确 - 复杂查询换行
var result = database.Users
	.Where(u => u.IsActive)
	.Where(u => u.Age > 18)
	.OrderByDescending(u => u.CreatedAt)
	.Select(u => new
	{
		u.Id,
		u.Name,
		u.Email
	})
	.ToList();

// ❌ 错误 - 不必要的循环
var aliveEnemies = new List<Enemy>();
foreach (var enemy in enemies)
{
	if (enemy.IsAlive)
	{
		aliveEnemies.Add(enemy);
	}
}
```

### 6. 异步编程

**SHOULD** 使用 async/await:

```csharp
// ✅ 正确
public class LLMService : Node
{
	public async Task<string> GenerateResponseAsync(string prompt)
	{
		try
		{
			var response = await _httpClient.PostAsync(_apiUrl, CreateContent(prompt));
			response.EnsureSuccessStatusCode();
			return await response.Content.ReadAsStringAsync();
		}
		catch (HttpRequestException ex)
		{
			GD.PrintErr($"LLM 请求失败: {ex.Message}");
			throw;
		}
	}
	
	// 异步方法调用
	public async void ProcessUserInput(string input)
	{
		var response = await GenerateResponseAsync(input);
		DisplayResponse(response);
	}
}

// ❌ 错误 - 阻塞调用
public string GenerateResponse(string prompt)
{
	var response = _httpClient.PostAsync(_apiUrl, CreateContent(prompt)).Result;  // 阻塞！
	return response.Content.ReadAsStringAsync().Result;  // 阻塞！
}
```

### 7. XML 文档注释

**MUST** 为公共 API 添加 XML 文档:

```csharp
/// <summary>
/// 窗口服务 - 负责管理应用程序窗口的属性和行为
/// </summary>
/// <remarks>
/// 此服务提供了窗口穿透、置顶等功能的控制接口
/// </remarks>
public partial class WindowService : Node
{
	/// <summary>
	/// 设置窗口是否可以点击穿透
	/// </summary>
	/// <param name="clickthrough">
	/// true 表示启用点击穿透（鼠标事件穿过窗口）；
	/// false 表示禁用点击穿透（窗口可以接收鼠标事件）
	/// </param>
	/// <exception cref="InvalidOperationException">
	/// 当窗口句柄未初始化时抛出
	/// </exception>
	/// <example>
	/// <code>
	/// var windowService = GetNode&lt;WindowService&gt;("/root/WindowService");
	/// windowService.SetClickThrough(true);  // 启用穿透
	/// </code>
	/// </example>
	public void SetClickThrough(bool clickthrough)
	{
		if (_hWnd == IntPtr.Zero)
		{
			throw new InvalidOperationException("窗口句柄未初始化");
		}
		
		// 实现逻辑...
	}
	
	/// <summary>
	/// 获取当前窗口的句柄
	/// </summary>
	/// <returns>
	/// 窗口句柄（IntPtr），如果窗口未初始化则返回 IntPtr.Zero
	/// </returns>
	public IntPtr GetWindowHandle()
	{
		return _hWnd;
	}
}
```

---

## 项目结构规范

### 1. 目录命名

**MUST**:
- 使用 **lowercase**（小写）或 **PascalCase**
- 保持简短和描述性

```
✅ 正确:
engine/
├── core/
├── renderer/
├── services/
└── scenes/

❌ 错误:
Engine/
├── Core_Modules/
├── Renderer-System/
└── All_Scenes/
```

### 2. 文件组织

**MUST**:
- 相关文件放在同一目录
- 按功能而不是类型分组

```
✅ 正确 - 按功能分组:
services/
├── Live2D/
│   ├── ModelService.gd
│   ├── AnimationService.gd
│   └── EyeTrackingService.gd
└── Config/
    ├── ConfigService.gd
    └── ConfigModel.gd

❌ 错误 - 按类型分组:
scripts/
├── services/
│   ├── ModelService.gd
│   ├── AnimationService.gd
│   └── ConfigService.gd
└── models/
    └── ConfigModel.gd
```

### 3. 资源命名

**SHOULD**:
- 使用 snake_case
- 包含资源类型后缀

```
✅ 正确:
textures/
├── player_idle.png
├── player_run_01.png
└── enemy_attack_sprite.png

sounds/
├── bgm_main_theme.ogg
├── sfx_jump.wav
└── sfx_explosion.wav

scenes/
├── main_menu.tscn
├── game_level_01.tscn
└── player_character.tscn

❌ 错误:
Textures/
├── PlayerIdle.png
├── player.png  # 不清楚是哪个状态
└── 1.png  # 无意义的名称
```

---

## Git 提交规范

### 1. 提交消息格式

**MUST** 使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式:

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### 1.1 Type（类型）

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(animation): 添加表情切换动画` |
| `fix` | 修复 Bug | `fix(eye-tracking): 修复眼动追踪偏移问题` |
| `refactor` | 重构 | `refactor(model): 重构模型加载逻辑` |
| `docs` | 文档 | `docs(readme): 更新安装说明` |
| `style` | 代码格式 | `style(core): 格式化代码符合规范` |
| `test` | 测试 | `test(config): 添加配置服务单元测试` |
| `chore` | 构建/工具 | `chore(deps): 更新 Godot 到 4.3` |
| `perf` | 性能优化 | `perf(render): 优化 Live2D 渲染性能` |

#### 1.2 Scope（范围）

**SHOULD** 指定影响的模块:

```
feat(model): 添加模型预加载功能
fix(animation): 修复动画播放卡顿
refactor(config): 重构配置管理系统
docs(api): 更新 API 文档
```

#### 1.3 Subject（主题）

**MUST**:
- 使用祈使句（"添加"而不是"添加了"）
- 不要大写首字母
- 不要句号结尾
- 不超过 50 个字符

```
✅ 正确:
feat(model): 添加模型切换动画
fix(config): 修复配置加载失败的问题
refactor(core): 简化服务定位器实现

❌ 错误:
feat(model): 添加了模型切换动画。  # 过去式+句号
Fix(config): 修复配置  # 首字母大写
refactor(core): 对核心模块进行了全面的重构并优化了性能表现  # 太长
```

#### 1.4 Body（正文）

**SHOULD** 包含:
- 详细说明改动的原因
- 与之前行为的对比

```
feat(memory): 添加图数据库支持

之前使用 SQLite 存储记忆，查询关联记忆时性能较差。
现在使用 Neo4j 图数据库，支持：
- 快速关联查询
- 复杂关系建模
- 记忆网络可视化

相关 Issue: #123
```

#### 1.5 Footer（页脚）

**SHOULD** 包含:
- 关联的 Issue
- Breaking Changes

```
fix(api): 修改 API 接口返回格式

BREAKING CHANGE: API 返回格式从 Array 改为 Dictionary

Migration guide:
- 旧: `var items = api.get_items()  # Array`
- 新: `var result = api.get_items()  # Dictionary with 'items' key`

Closes #456
```

### 2. 提交粒度

**SHOULD**:
- 每个提交只做一件事
- 提交应该是原子性的（可以独立回滚）

```bash
# ✅ 正确 - 分开提交
git commit -m "feat(model): 添加模型加载进度显示"
git commit -m "fix(model): 修复模型加载失败时的崩溃"
git commit -m "docs(model): 更新模型 API 文档"

# ❌ 错误 - 一次提交太多
git commit -m "feat: 添加模型功能、修复 Bug、更新文档"
```

### 3. 分支命名

**MUST**:
- 使用 `type/description` 格式
- 使用 kebab-case

```bash
# ✅ 正确
git checkout -b feat/add-emotion-system
git checkout -b fix/eye-tracking-offset
git checkout -b refactor/renderer-to-engine
git checkout -b docs/update-coding-standards

# ❌ 错误
git checkout -b AddEmotionSystem  # 应该用 kebab-case
git checkout -b fix_bug  # 不清晰
git checkout -b my-feature  # 缺少类型前缀
```

---

## 文档规范

### 1. Markdown 格式

**MUST**:
- 使用标准 Markdown 语法
- 文件名使用 SCREAMING_SNAKE_CASE 或 kebab-case

```
✅ 正确:
README.md
CONTRIBUTING.md
CODING_STANDARDS.md
api-reference.md
getting-started.md

❌ 错误:
readme.MD
Contributing.markdown
coding standards.md
```

### 2. 文档结构

**SHOULD** 包含:

```markdown
# 标题

> 简短描述 | 版本信息

---

## 目录

- [概述](#概述)
- [主要内容](#主要内容)
...

---

## 概述

...

## 主要内容

...

---

<p align="center">
  <i>页脚信息</i><br>
  <sub>最后更新: YYYY-MM-DD</sub>
</p>
```

### 3. 代码示例

**MUST**:
- 使用语法高亮
- 添加注释说明

````markdown
✅ 正确:

```gdscript
# 创建玩家实例
var player = Player.new()
player.position = Vector2(100, 100)
add_child(player)
```

❌ 错误:

```
var player = Player.new()
player.position = Vector2(100, 100)
add_child(player)
```
````

---

## 性能规范

### 1. 内存管理

**MUST**:
- 避免内存泄漏
- 及时释放不再使用的资源

```gdscript
# ✅ 正确 - 及时释放
func load_texture() -> Texture2D:
	var image = Image.new()
	image.load("res://texture.png")
	var texture = ImageTexture.create_from_image(image)
	return texture

func _exit_tree():
	# 清理资源
	if texture:
		texture = null

# ❌ 错误 - 忘记清理
var cached_textures: Array[Texture2D] = []

func load_all_textures():
	for i in range(1000):
		var tex = load("res://texture_%d.png" % i)
		cached_textures.append(tex)  # 可能导致内存占用过高
```

### 2. 避免过早优化

**SHOULD**:
- 先保证正确性，再考虑优化
- 使用 Profiler 找到性能瓶颈

```gdscript
# ✅ 正确 - 清晰的逻辑
func update_enemies(delta: float) -> void:
	for enemy in enemies:
		if enemy.is_alive():
			enemy.update(delta)

# ❌ 错误 - 过早优化，牺牲可读性
func update_enemies(delta: float) -> void:
	var i = 0
	while i < enemies.size():
		if enemies[i].alive_flag & 0x01:
			enemies[i].tick(delta)
		i += 1
```

### 3. 性能注释

**SHOULD** 标注性能敏感的代码:

```gdscript
# PERFORMANCE: 此函数每帧调用，需要保持高效
func _process(delta: float) -> void:
	update_position(delta)

# PERFORMANCE: 避免在此函数中进行 I/O 操作
func _physics_process(delta: float) -> void:
	handle_collision()
```

---

## 附录

### A. 工具配置

#### EditorConfig

创建 `.editorconfig`:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.gd]
indent_style = tab
indent_size = 4

[*.cs]
indent_style = space
indent_size = 4

[*.{json,yml,yaml}]
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false
```

#### Git Hooks

创建 `.git/hooks/pre-commit`:

```bash
#!/bin/sh
# 检查代码规范

echo "检查代码规范..."

# 检查 Tab/空格混用
if git diff --cached --check; then
    echo "✅ 代码格式检查通过"
else
    echo "❌ 发现格式问题，请修复后再提交"
    exit 1
fi
```

### B. 参考资源

- [Godot GDScript 风格指南](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Google C# 风格指南](https://google.github.io/styleguide/csharp-style.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)

---

## 版本历史

| 版本 | 日期 | 变更说明 |
|------|------|---------|
| 1.0 | 2025-01-22 | 初始版本 |

---

<p align="center">
  <strong>一致性创造价值</strong><br>
  <i>良好的规范是高质量代码的基础</i><br>
  <sub>Marionet Project | 版本 1.0</sub>
</p>

