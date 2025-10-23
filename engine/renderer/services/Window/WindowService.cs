// WindowService.cs
// 窗口服务 - 负责窗口属性管理和点击穿透控制
using Godot;
using System;
using System.Runtime.InteropServices;

public partial class WindowService : Node
{
    // ========== Windows API ==========

    // GetActiveWindow() retrieves the handle of the window
    [DllImport("user32.dll")]
    public static extern IntPtr GetActiveWindow();

    // SetWindowLong() modifies a specific flag value associated with a window
    [DllImport("user32.dll")]
    private static extern int SetWindowLong(IntPtr hWnd, int nIndex, uint dwNewLong);

    // This is the index of the property we want to modify
    private const int GwlExStyle = -20;

    // The flags we want to set
    private const uint WsExLayered = 0x00080000;     // Makes the window "layered"
    private const uint WsExTransparent = 0x00000020;  // Makes the window "clickable through"
                                                      // Reference: https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles

    // ========== 状态变量 ==========
    private IntPtr _hWnd;
    private MouseDetectionService _mouseDetectionService;

    // ========== 初始化 ==========
    public override void _Ready()
    {
        // 延迟获取窗口句柄，确保窗口完全创建
        CallDeferred(nameof(InitializeWindow));

        // 创建 MouseDetectionService（在 C# 中创建 C# 类更可靠）
        _mouseDetectionService = new MouseDetectionService();
        AddChild(_mouseDetectionService);
        _mouseDetectionService.Name = "MouseDetectionService";

        GD.Print("[WindowService] 已初始化");
        GD.Print("[WindowService] MouseDetectionService 已创建");
    }

    private void InitializeWindow()
    {
        // Store the window handle
        _hWnd = GetActiveWindow();

        if (_hWnd != IntPtr.Zero)
        {
            // Set the window as layered and click-through by default
            // 默认设置为穿透，MouseDetectionService 会根据像素透明度动态调整
            SetWindowLong(_hWnd, GwlExStyle, WsExLayered | WsExTransparent);
            GD.Print("[WindowService] 窗口句柄已获取，窗口已设置为 layered + 点击穿透");
        }
        else
        {
            GD.PrintErr("[WindowService] 无法获取窗口句柄");
        }
    }

    // ========== 公共接口 ==========

    /// <summary>
    /// 设置窗口是否可点击穿透
    /// </summary>
    /// <param name="clickthrough">true = 点击穿透，false = 可点击</param>
    public void SetClickThrough(bool clickthrough)
    {
        if (_hWnd == IntPtr.Zero)
        {
            return;
        }

        if (clickthrough)
        {
            // Set the window as layered and click-through
            SetWindowLong(_hWnd, GwlExStyle, WsExLayered | WsExTransparent);
        }
        else
        {
            // Only set the window as layered, so it will be clickable
            SetWindowLong(_hWnd, GwlExStyle, WsExLayered);
        }
    }

    /// <summary>
    /// 获取窗口句柄
    /// </summary>
    public IntPtr GetWindowHandle()
    {
        return _hWnd;
    }

    /// <summary>
    /// 检查窗口句柄是否有效
    /// </summary>
    public bool IsWindowHandleValid()
    {
        return _hWnd != IntPtr.Zero;
    }

    /*
	 * === What is a Layered Window? ===
	 *
	 * In the Windows API, a layered window is a special type of window that offers several
	 * advantages over standard windows:
	 *
	 * - Transparency: Layered windows can be partially transparent, allowing the content of
	 *   underlying windows to show through. This can be achieved using either color keying,
	 *   where a specific color in the window is transparent, or alpha blending, where the
	 *   window's opacity is specified for each pixel.
	 *
	 * - Complex Shapes: Layered windows can have complex shapes that are not limited by
	 *   rectangular regions. This is achieved by defining a custom region, allowing for more
	 *   visually appealing or functional window designs.
	 *
	 * - Animation: Layered windows can be animated smoothly without the visual artifacts
	 *   that can occur with standard windows due to region updates. This is because the system
	 *   automatically manages the composition of layered windows with underlying elements.
	 */
}

