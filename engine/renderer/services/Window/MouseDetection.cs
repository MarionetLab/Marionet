// MouseDetection.cs
// 鼠标检测服务 - 负责检测鼠标下的像素透明度，控制窗口点击穿透
using Godot;
using System;

public partial class MouseDetectionService : Node
{
	// ========== 依赖服务 ==========
	private WindowService _windowService;
	
	// ========== 状态变量 ==========
	private bool clickthrough = true;

	// ========== 初始化 ==========
	public override void _Ready()
	{
		// 尝试获取 WindowService
		// 注意：这里先尝试从自动加载获取，如果没有则从 ServiceLocator 获取
		_windowService = GetNode<WindowService>("/root/WindowService");
		
		if (_windowService == null)
		{
			GD.PrintErr("[MouseDetection] 无法找到 WindowService，点击穿透功能将不可用");
			return;
		}
		
		// 初始化为穿透模式，后续会根据像素检测动态调整
		_windowService.SetClickThrough(true);
		
		GD.Print("[MouseDetection] 已初始化");
	}
	
	// ========== 物理帧更新 ==========
	// It is better to detect the pixels only when rendered, so PhysicsProcess is recommended
	// Also can throttle the detection every few frames if needed
	public override void _PhysicsProcess(double delta)
	{
		DetectPassthrough();
	}

	// ========== 像素检测 ==========
	/// <summary>
	/// 检测鼠标下的像素是否透明，动态控制窗口点击穿透
	/// </summary>
	/// <remarks>
	/// This can become expensive if done every frame in more complex scenes.
	/// We will use this to determine whether the window should be clickable or not.
	/// </remarks>
	private void DetectPassthrough()
	{
		if (_windowService == null) return;
		
		Viewport viewport = GetViewport();
		
		// 检查视口是否有效
		if (viewport == null || viewport.GetTexture() == null)
		{
			return;
		}
		
		Image img = viewport.GetTexture().GetImage();
		Rect2 rect = viewport.GetVisibleRect();
		
		// Getting the mouse position in the viewport
		Vector2 mousePosition = viewport.GetMousePosition();
		int viewX = (int)((int)mousePosition.X + rect.Position.X);
		int viewY = (int)((int)mousePosition.Y + rect.Position.Y);

		// Getting the mouse position relative to the image (image will be the size of the window)
		int x = (int)(img.GetSize().X * viewX / rect.Size.X);
		int y = (int)(img.GetSize().Y * viewY / rect.Size.Y);

		// Getting the pixel at the mouse position coordinates
		if (x < img.GetSize().X && x >= 0 && y < img.GetSize().Y && y >= 0)
		{
			Color pixel = img.GetPixel(x, y);
			bool shouldBeClickable = pixel.A > 0.5f;
			SetClickability(shouldBeClickable);
		}

		// Very important to dispose the rendered image or will bloat memory !!!!!
		img.Dispose();
	}
	
	/// <summary>
	/// 设置窗口可点击性
	/// </summary>
	/// <param name="clickable">true = 可点击，false = 点击穿透</param>
	/// <remarks>
	/// Instead of calling the API every frame, we check if the state is changed 
	/// and then call it if necessary
	/// </remarks>
	private void SetClickability(bool clickable)
	{
		if (clickable != clickthrough)
		{
			clickthrough = clickable;
			// clickthrough means NOT clickable
			_windowService.SetClickThrough(!clickable);
		}
	}
}

