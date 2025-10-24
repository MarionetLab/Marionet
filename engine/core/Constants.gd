# Constants.gd
# 全局常量定义
# 作为自动加载单例，不需要 class_name 定义
extends Node

# ========== 路径常量 ==========
const MODEL_BASE_PATH = "res://Live2D/models/"
const CONFIG_PATH = "user://engine_config.json"
const SCENE_PATH = "res://scenes/"

# ========== Live2D 设置 ==========
const DEFAULT_IDLE_ANIMATION = "Idle"
const ANIMATION_FADE_TIME = 0.3
const AUTO_RESET_DURATION = 5.0  # 动画自动恢复时间（秒）

# ========== 眼动追踪常量 ==========
const EYE_SMOOTH_FACTOR = 0.08
const EYE_MAX_DISTANCE = 0.8
const EYE_IDLE_THRESHOLD = 2.0  # 空闲阈值（秒）

# ========== 性能常量 ==========
const TARGET_FPS = 60
const MAX_ANIMATION_QUEUE_SIZE = 10

# ========== 优先级枚举 ==========
enum Priority {
	LOW = 0,
	NORMAL = 1,
	HIGH = 2,
	FORCE = 3
}

# ========== 日志级别 ==========
enum LogLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}

# 当前日志级别
var current_log_level: LogLevel = LogLevel.INFO

# 日志函数（作为自动加载单例，使用实例方法）
func log_debug(message: String):
	if current_log_level <= LogLevel.DEBUG:
		print("[DEBUG] %s" % message)

func log_info(message: String):
	if current_log_level <= LogLevel.INFO:
		print("[INFO] %s" % message)

func log_warning(message: String):
	if current_log_level <= LogLevel.WARNING:
		push_warning("[WARNING] %s" % message)

func log_error(message: String):
	if current_log_level <= LogLevel.ERROR:
		push_error("[ERROR] %s" % message)
