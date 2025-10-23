// MouseDetection.cs
// 鼠标检测服务 - 负责检测鼠标下的像素透明度，控制窗口点击穿透
using Godot;
using System;

public partial class MouseDetectionService : Node
{
    // ========== 依赖服务 ==========
    private WindowService _windowService;
    private SubViewport _targetViewport;  // Live2D 渲染的 SubViewport

    // ========== 状态变量 ==========
    private bool lastClickableState = false;  // 上一次的可点击状态（false = 穿透，true = 可点击）
    private bool isEnabled = true;  // 控制是否启用穿透检测
    private int frameCounter = 0;  // 帧计数器，用于降低检测频率

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

        // 尝试获取 SubViewport（延迟获取，因为 Main 场景可能还没加载完）
        CallDeferred(nameof(FindSubViewport));

        GD.Print("[MouseDetection] 已找到 WindowService");
        GD.Print("[MouseDetection] 穿透检测已启用，将根据像素透明度动态调整窗口穿透状态");
    }

    /// <summary>
    /// 延迟查找 SubViewport 节点
    /// </summary>
    private void FindSubViewport()
    {
        // 尝试从主场景获取 SubViewport
        var mainScene = GetTree().Root.GetNode<Node>("Main");
        if (mainScene != null)
        {
            _targetViewport = mainScene.GetNodeOrNull<SubViewport>("Sprite2D/SubViewport");
            if (_targetViewport != null)
            {
                GD.Print("[MouseDetection] 已找到 SubViewport，将使用它进行像素检测");
            }
            else
            {
                GD.PrintErr("[MouseDetection] 无法找到 SubViewport，穿透检测可能不正常工作");
            }
        }
        else
        {
            GD.PrintErr("[MouseDetection] 无法找到主场景节点");
        }
    }

    // ========== 混合检测：轻量级主动检测 + 被动检测 ==========
    // 主动检测：只检测鼠标是否在人物上（用于接收中键拖动事件）
    // 被动检测：点击时的精确透明度检测

    private bool _lastHoverState = false;  // 上次鼠标悬停状态（false = 不在人物上，true = 在人物上）

    public override void _PhysicsProcess(double delta)
    {
        if (!isEnabled || _windowService == null || GetViewport() == null)
        {
            return;
        }

        // 性能优化：每 60 帧检测一次（约 1 次/秒）
        // 极低频率检测，最大化性能
        frameCounter++;
        if (frameCounter < 60)
        {
            return;
        }
        frameCounter = 0;

        // 获取鼠标位置
        Vector2 mousePosition = GetViewport().GetMousePosition();

        // 检查是否在人物上
        bool isOnCharacter = IsPositionClickable(mousePosition, _targetViewport);

        // 只在状态改变时调用 Windows API
        if (isOnCharacter != _lastHoverState)
        {
            _lastHoverState = isOnCharacter;

            if (isOnCharacter)
            {
                // 鼠标移到人物上，禁用穿透（允许接收中键事件）
                _windowService.SetClickThrough(false);
                GD.Print($"[MouseDetection] 鼠标移到人物上，禁用穿透");
            }
            else
            {
                // 鼠标移出人物，启用穿透
                _windowService.SetClickThrough(true);
                GD.Print($"[MouseDetection] 鼠标移出人物，启用穿透");
            }
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
    /// 检查指定位置的像素是否可点击（不透明）
    /// </summary>
    /// <param name="position">屏幕位置（窗口内坐标）</param>
    /// <param name="targetViewport">可选的目标视口（如果不提供，使用根视口）</param>
    /// <returns>true = 可点击（不透明），false = 不可点击（透明）</returns>
    public bool IsPositionClickable(Vector2 position, Viewport targetViewport = null)
    {
        // 使用传入的视口，如果没有则使用根视口
        Viewport viewport = targetViewport ?? GetViewport();

        // 检查视口是否有效
        if (viewport == null || viewport.GetTexture() == null)
        {
            return false;
        }

        Image img = viewport.GetTexture().GetImage();

        // 直接使用窗口坐标，SubViewport 的纹理会被缩放到窗口大小
        int x = (int)position.X;
        int y = (int)position.Y;

        // 将窗口坐标转换为纹理坐标
        Rect2 visibleRect = GetViewport().GetVisibleRect();
        x = (int)(img.GetSize().X * x / visibleRect.Size.X);
        y = (int)(img.GetSize().Y * y / visibleRect.Size.Y);

        bool isClickable = false;

        // 检查边界并获取像素
        if (x >= 0 && x < img.GetSize().X && y >= 0 && y < img.GetSize().Y)
        {
            Color pixel = img.GetPixel(x, y);
            isClickable = pixel.A > 0.5f;  // Alpha > 0.5 表示不透明，可点击
        }

        // 重要：释放图像内存
        img.Dispose();

        return isClickable;
    }

    /// <summary>
    /// 处理鼠标按下事件（被动检测）
    /// </summary>
    /// <param name="position">鼠标位置</param>
    /// <param name="buttonIndex">鼠标按钮</param>
    public void OnMouseButtonPressed(Vector2 position, MouseButton buttonIndex)
    {
        // 鼠标按下时，主动检测已经处理了穿透状态
        // 这里只需要记录点击位置，供动画系统使用
    }

    /// <summary>
    /// 处理鼠标释放事件（被动检测）
    /// </summary>
    public void OnMouseButtonReleased()
    {
        // 鼠标释放后，主动检测会在下一帧自动调整穿透状态
        // 这里不需要做任何事
    }

    // ========== 像素检测 ==========
    // ========== 已移除主动检测逻辑 ==========
    // DetectPassthrough() 和 SetClickability() 已移除
    // 改为被动检测：只在鼠标按下/释放时检测
}

