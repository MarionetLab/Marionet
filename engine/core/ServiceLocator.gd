# ServiceLocator.gd
# 服务定位器 - 用于解耦服务之间的依赖关系
# 作为自动加载单例，使用实例方法
extends Node

var _services: Dictionary = {}

# 注册服务
func register(service_name: String, service: Node):
	_services[service_name] = service
	print("[ServiceLocator] 已注册服务: %s" % service_name)

# 获取服务
func get_service(service_name: String) -> Node:
	if not _services.has(service_name):
		push_error("[ServiceLocator] 服务未注册: %s" % service_name)
		return null
	return _services[service_name]

# 检查服务是否存在
func has_service(service_name: String) -> bool:
	return _services.has(service_name)

# 注销服务
func unregister(service_name: String):
	if _services.has(service_name):
		_services.erase(service_name)
		print("[ServiceLocator] 已注销服务: %s" % service_name)

# 清空所有服务
func clear_all():
	_services.clear()
	print("[ServiceLocator] 已清空所有服务")
