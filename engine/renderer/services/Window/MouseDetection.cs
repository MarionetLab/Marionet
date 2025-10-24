// MouseDetection.cs
// 鼠标检测服务 - 负责检测鼠标下的像素透明度，控制窗口点击穿透
using Godot;
using System;

public partial class MouseDetectionService : Node
{
    // ========== 依赖服务 ==========
    private WindowService _windowService;

    // ========== 状态变量 ==========
    private bool isEnabled = true;  // 控制是否启用穿透检测

    // ========== 性能优化 ==========
    private Vector2 _lastMousePosition = new Vector2(-1, -1);  // 上次检测的鼠标位置
    private int _frameCounter = 0;  // 帧计数器

    // 性能配置（可根据需要调整）
    // 检测间隔：1=60fps, 2=30fps, 3=20fps, 4=15fps
    // 推荐：2-3 （30-20fps已经足够流畅）
    private const int CHECK_INTERVAL = 3;  // 每N帧检测一次

    // 鼠标移动阈值：像素数，小于此值认为没有移动
    // 推荐：1.0-2.0（避免微小抖动触发检测）
    private const float MOUSE_MOVE_THRESHOLD = 1.5f;

    // ========== 初始化 ==========
    public override void _Ready()
    {
        // 尝试获取 WindowService
        _windowService = GetNode<WindowService>("/root/WindowService");

        if (_windowService == null)
        {
            GD.PrintErr("[MouseDetection] 无法找到 WindowService，点击穿透功能将不可用");
            return;
        }

        // 初始化为穿透状态
        _windowService.SetClickThrough(true);

        GD.Print("[MouseDetection] 初始化完成");
        GD.Print("[MouseDetection] 穿透检测已启用，将根据根视口像素透明度动态调整窗口穿透状态");
    }


    // ========== 像素检测（参照 legacy 版本的正确实现） ==========
    // 检测根视口（最终渲染画面）的像素透明度来控制穿透
    // 关键：使用根视口（GetViewport()），而不是 SubViewport

    private bool _clickthrough = true;  // 当前穿透状态（true = 穿透，false = 可点击）

    public override void _PhysicsProcess(double delta)
    {
        if (!isEnabled || _windowService == null)
        {
            return;
        }

        // 性能优化：降低检测频率（每2帧检测一次，30fps而不是60fps）
        _frameCounter++;
        if (_frameCounter < CHECK_INTERVAL)
        {
            return;
        }
        _frameCounter = 0;

        // 获取当前鼠标位置
        Viewport viewport = GetViewport();
        if (viewport == null)
        {
            return;
        }

        Vector2 currentMousePosition = viewport.GetMousePosition();

        // 只在鼠标移动时检测（减少不必要的检测）
        if (currentMousePosition.DistanceTo(_lastMousePosition) < MOUSE_MOVE_THRESHOLD)
        {
            return;  // 鼠标位置没变化，跳过检测
        }

        _lastMousePosition = currentMousePosition;
        DetectPassthrough();
    }

    /// <summary>
    /// 检测鼠标下的像素透明度，控制窗口穿透（参照 legacy 实现）
    /// </summary>
    private void DetectPassthrough()
    {
        Viewport viewport = GetViewport();
        if (viewport == null || viewport.GetTexture() == null)
        {
            return;
        }

        Image img = viewport.GetTexture().GetImage();
        Rect2 rect = viewport.GetVisibleRect();

        // 获取鼠标位置（窗口坐标）
        Vector2 mousePosition = viewport.GetMousePosition();
        int viewX = (int)((int)mousePosition.X + rect.Position.X);
        int viewY = (int)((int)mousePosition.Y + rect.Position.Y);

        // 转换为图像坐标
        int x = (int)(img.GetSize().X * viewX / rect.Size.X);
        int y = (int)(img.GetSize().Y * viewY / rect.Size.Y);

        // 检查边界并获取像素
        if (x >= 0 && x < img.GetSize().X && y >= 0 && y < img.GetSize().Y)
        {
            Color pixel = img.GetPixel(x, y);
            // Alpha > 0.1 表示不透明，可点击（降低阈值以包含边缘区域）
            SetClickability(pixel.A > 0.1f);
        }

        // 重要：释放图像内存
        img.Dispose();
    }

    /// <summary>
    /// 设置窗口可点击性（只在状态改变时调用 Windows API）
    /// </summary>
    /// <param name="clickable">true = 可点击，false = 穿透</param>
    private void SetClickability(bool clickable)
    {
        if (clickable != _clickthrough)
        {
            _clickthrough = clickable;
            // clickthrough 表示"不可点击"，所以需要取反
            _windowService.SetClickThrough(!clickable);
        }
    }

    // ========== 控制接口 ==========
    /// <summary>
    /// 启用或禁用穿透检测
    /// </summary>
    /// <param name="enabled">true = 启用检测，false = 禁用检测</param>
    /// <remarks>
    /// 当需要临时接管穿透控制时（如窗口拖动），应禁用自动检测
    /// </remarks>
    public void SetEnabled(bool enabled)
    {
        isEnabled = enabled;
        GD.Print($"[MouseDetection] 穿透检测已{(enabled ? "启用" : "禁用")}");
    }

    /// <summary>
    /// 公共接口：检查指定位置的像素是否可点击（供外部调用）
    /// </summary>
    /// <param name="position">屏幕位置（窗口内坐标）</param>
    /// <returns>true = 可点击（不透明），false = 不可点击（透明）</returns>
    public bool IsPositionClickable(Vector2 position)
    {
        Viewport viewport = GetViewport();
        if (viewport == null || viewport.GetTexture() == null)
        {
            return false;
        }

        Image img = viewport.GetTexture().GetImage();
        Rect2 rect = viewport.GetVisibleRect();

        int viewX = (int)((int)position.X + rect.Position.X);
        int viewY = (int)((int)position.Y + rect.Position.Y);

        int x = (int)(img.GetSize().X * viewX / rect.Size.X);
        int y = (int)(img.GetSize().Y * viewY / rect.Size.Y);

        bool isClickable = false;

        if (x >= 0 && x < img.GetSize().X && y >= 0 && y < img.GetSize().Y)
        {
            Color pixel = img.GetPixel(x, y);
            // Alpha > 0.1 表示不透明，可点击（降低阈值以包含边缘区域）
            isClickable = pixel.A > 0.1f;
        }

        img.Dispose();
        return isClickable;
    }
}

