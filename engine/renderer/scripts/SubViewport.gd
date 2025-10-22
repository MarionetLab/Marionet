extends SubViewport

func _ready() -> void:
	# 直接设置当前SubViewport的属性（不需要查找自己）
	transparent_bg = true
	disable_3d = true
	
	# 设置渲染模式
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# 禁用HDR以确保透明度正常
	use_hdr_2d = false
	
	print("SubViewport透明背景设置完成")

