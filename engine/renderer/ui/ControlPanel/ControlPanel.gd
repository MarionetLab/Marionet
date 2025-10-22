extends Control

# ControlPanel.gd
# 控制面板UI脚本（简化版，逐步完善）

func _ready():
	EngineConstants.log_info("控制面板初始化")
	visible = false

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE and visible:
			visible = false

