# 场景分类算法 - Perception Unit 子模块

> 为 Perception Unit 提供场景类型识别能力

**所属**: Core Furnace → Perception Unit → Scene Classifier  
**输入**: 原始感知数据  
**输出**: `SceneType` 枚举 + 置信度

---

## 目录
- [1. 模块定位](#1-模块定位)
- [2. 数据流与接口](#2-数据流与接口)
- [3. 核心实现](#3-核心实现)
- [4. 配置系统](#4-配置系统)
- [5. 性能优化](#5-性能优化)

---

## 1. 模块定位

### 1.1 在架构中的位置

```
Perception Unit
├── System Monitor         # 键鼠、窗口、音频监控
├── Content Monitor        # 输入、剪贴板监控
├── Visual Recognition     # OCR、VLM（可选）
└── Scene Classifier ⭐    # 场景分类（本模块）
    ├── Feature Extractor  # 特征提取
    └── Rule Engine        # 规则匹配
```

### 1.2 功能职责

**输入**：System Monitor 提供的原始数据
- 键盘事件序列
- 鼠标事件序列
- 窗口信息
- 系统资源状态

**处理**：识别当前场景类型
- Work_Coding（编程）
- Entertainment_Gaming（游戏）
- Entertainment_VideoStreaming（看视频）
- Work_DocumentEditing（文档编辑）
- ...

**输出**：丰富 `PerceptionContext`
```csharp
// 原有的 PerceptionContext 增加字段
class PerceptionContext {
    // ... 原有字段
    
    // 新增：场景识别结果
    SceneType scene_type;          // 场景类型
    string scene_sub_type;         // 子类型（可选）
    float scene_confidence;        // 置信度 0-1
}
```

---

## 2. 数据流与接口

### 2.1 与 Perception Unit 的集成

```csharp
namespace Marionet.Core.Perception;

/// <summary>
/// Perception Unit 主入口
/// </summary>
public sealed class PerceptionUnit
{
    private readonly ISystemMonitor _systemMonitor;
    private readonly ISceneClassifier _sceneClassifier;  // ⭐ 新增
    
    public PerceptionContext CollectContext()
    {
        // 1. 收集原始数据
        var rawData = _systemMonitor.Collect();
        
        // 2. 场景识别（新增）
        var scene = _sceneClassifier.Classify(rawData);
        
        // 3. 构建上下文
        return new PerceptionContext
        {
            // ... 原有字段
            foreground_app = rawData.ProcessName,
            window_title = rawData.WindowTitle,
            keyboard_frequency = rawData.KeyboardFrequency,
            
            // 新增：场景识别结果
            scene_type = scene.Type,
            scene_sub_type = scene.SubType,
            scene_confidence = scene.Confidence
        };
    }
}
```

### 2.2 场景分类器接口

```csharp
namespace Marionet.Core.Perception.Scene;

/// <summary>
/// 场景分类器接口（内部使用）
/// </summary>
internal interface ISceneClassifier
{
    /// <summary>
    /// 分类场景
    /// </summary>
    SceneResult Classify(SystemMonitorData data);
}

/// <summary>
/// 场景识别结果
/// </summary>
public readonly struct SceneResult
{
    public SceneType Type { get; init; }
    public string? SubType { get; init; }
    public float Confidence { get; init; }
    
    // 调试信息（可选）
    public Dictionary<string, object>? DebugInfo { get; init; }
}

/// <summary>
/// 场景类型枚举
/// </summary>
public enum SceneType
{
    Unknown,
    
    // 工作类
    Work_Coding,
    Work_DocumentEditing,
    Work_Spreadsheet,
    Work_EmailCalendar,
    Work_ProjectManagement,
    
    // 开发类
    Dev_Debugging,
    Dev_BuildTest,
    Dev_VersionControl,
    Dev_Database,
    Dev_DevOps,
    
    // 娱乐类
    Entertainment_Gaming,
    Entertainment_VideoStreaming,
    Entertainment_Audio,
    Entertainment_Reading,
    
    // 协作类
    Social_InstantMessaging,
    Social_MediaInteraction,
    Meeting_VideoCall,
    Collab_RealTimeEdit,
    
    // 浏览类
    Browsing_TechResearch,
    Browsing_DeepResearch,
    Browsing_Shopping,
    Browsing_General,
    
    // 学习类
    Learning_OnlineCourse,
    Learning_CodingPractice,
    Learning_Language,
    Learning_StudyNotes,
    
    // 系统类
    System_FileOrganization,
    System_SoftwareSetup,
    System_Archive
}
```

---

## 3. 核心实现

### 3.1 场景分类器实现

```csharp
namespace Marionet.Core.Perception.Scene;

/// <summary>
/// 场景分类器实现
/// </summary>
internal sealed class SceneClassifier : ISceneClassifier
{
    private readonly IFeatureExtractor _featureExtractor;
    private readonly IRuleEngine _ruleEngine;
    private readonly SceneCache _cache;
    private readonly ILogger<SceneClassifier> _logger;

    public SceneClassifier(
        IFeatureExtractor featureExtractor,
        IRuleEngine ruleEngine,
        SceneCache cache,
        ILogger<SceneClassifier> logger)
    {
        _featureExtractor = featureExtractor;
        _ruleEngine = ruleEngine;
        _cache = cache;
        _logger = logger;
    }

    public SceneResult Classify(SystemMonitorData data)
    {
        // 1. 检查缓存（避免重复计算）
        var cacheKey = GenerateCacheKey(data);
        if (_cache.TryGet(cacheKey, out var cached))
        {
            return cached;
        }

        try
        {
            // 2. 提取特征
            var features = _featureExtractor.Extract(data);

            // 3. 强规则检查（P0 优先级）
            var strongRule = CheckStrongRules(data);
            if (strongRule.HasValue)
            {
                var result = strongRule.Value;
                _cache.Set(cacheKey, result);
                return result;
            }

            // 4. 规则引擎匹配
            var matched = _ruleEngine.Match(features, data);
            
            // 5. 兜底分类
            var final = matched ?? GetFallbackScene(data);
            
            _cache.Set(cacheKey, final);
            return final;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Scene classification failed");
            return new SceneResult
            {
                Type = SceneType.Unknown,
                Confidence = 0f
            };
        }
    }

    /// <summary>
    /// 强规则检查（高优先级场景）
    /// </summary>
    private SceneResult? CheckStrongRules(SystemMonitorData data)
    {
        // 会议检测（最高优先级）
        if (data.IsMicrophoneActive && IsMeetingApp(data.ProcessName))
        {
            return new SceneResult
            {
                Type = SceneType.Meeting_VideoCall,
                Confidence = 1.0f
            };
        }

        // 游戏检测
        if (IsGameProcess(data.ProcessName))
        {
            return new SceneResult
            {
                Type = SceneType.Entertainment_Gaming,
                Confidence = 0.95f
            };
        }

        return null;
    }

    /// <summary>
    /// 兜底场景
    /// </summary>
    private SceneResult GetFallbackScene(SystemMonitorData data)
    {
        // 基于应用类别的简单判断
        return data.AppCategory switch
        {
            "Browser" => new SceneResult
            {
                Type = SceneType.Browsing_General,
                Confidence = 0.6f
            },
            "VideoPlayer" => new SceneResult
            {
                Type = SceneType.Entertainment_VideoStreaming,
                Confidence = 0.65f
            },
            _ => new SceneResult
            {
                Type = SceneType.Unknown,
                Confidence = 0.5f
            }
        };
    }

    private string GenerateCacheKey(SystemMonitorData data)
    {
        // 基于进程名和窗口标题生成缓存键
        var hash = HashCode.Combine(
            data.ProcessName,
            data.WindowTitle?.GetHashCode() ?? 0,
            DateTime.UtcNow.Ticks / TimeSpan.TicksPerSecond / 5 // 5秒粒度
        );
        return $"scene_{hash}";
    }

    private bool IsMeetingApp(string processName) =>
        processName?.ToLowerInvariant() is "zoom" or "teams" or "腾讯会议" or "dingtalk";

    private bool IsGameProcess(string processName)
    {
        // 从配置加载游戏列表或使用启发式判断
        return _ruleEngine.IsKnownGame(processName);
    }
}
```

### 3.2 特征提取器

```csharp
namespace Marionet.Core.Perception.Scene;

/// <summary>
/// 特征提取器
/// </summary>
internal interface IFeatureExtractor
{
    FeatureSet Extract(SystemMonitorData data);
}

/// <summary>
/// 特征集合
/// </summary>
internal sealed class FeatureSet
{
    // 键盘特征
    public ActivityLevel KeyboardActivity { get; init; }
    public TypingPattern TypingPattern { get; init; }
    public int CPM { get; init; }  // Characters Per Minute
    
    // 鼠标特征
    public ActivityLevel MouseActivity { get; init; }
    public int ClickCount { get; init; }
    public int DragCount { get; init; }
    public int ScrollCount { get; init; }
    
    // 滚动特征
    public ScrollPattern ScrollPattern { get; init; }
    
    // 窗口特征
    public WindowSwitchingLevel WindowSwitching { get; init; }
    
    // 系统特征
    public float CpuUsage { get; init; }
    public float GpuUsage { get; init; }
}

internal sealed class FeatureExtractor : IFeatureExtractor
{
    private readonly ThresholdConfig _config;

    public FeatureExtractor(ThresholdConfig config)
    {
        _config = config;
    }

    public FeatureSet Extract(SystemMonitorData data)
    {
        return new FeatureSet
        {
            KeyboardActivity = CalculateKeyboardActivity(data.KeyboardEvents),
            TypingPattern = AnalyzeTypingPattern(data.KeyboardEvents),
            CPM = CalculateCPM(data.KeyboardEvents, data.TimeWindowSeconds),
            
            MouseActivity = CalculateMouseActivity(data.MouseEvents),
            ClickCount = data.MouseEvents.Count(e => e.Type == MouseEventType.Click),
            DragCount = data.MouseEvents.Count(e => e.Type == MouseEventType.Drag),
            ScrollCount = data.MouseEvents.Count(e => e.Type == MouseEventType.Scroll),
            
            ScrollPattern = AnalyzeScrollPattern(data.MouseEvents),
            WindowSwitching = CalculateWindowSwitching(data.WindowSwitchCount),
            
            CpuUsage = data.CpuUsage,
            GpuUsage = data.GpuUsage
        };
    }

    private ActivityLevel CalculateKeyboardActivity(
        ReadOnlySpan<KeyboardEvent> events)
    {
        if (events.IsEmpty) return ActivityLevel.VeryLow;

        var cpm = CalculateCPM(events, 60);
        
        return cpm switch
        {
            >= 80 => ActivityLevel.VeryHigh,
            >= 50 => ActivityLevel.High,
            >= 30 => ActivityLevel.Medium,
            >= 10 => ActivityLevel.Low,
            _ => ActivityLevel.VeryLow
        };
    }

    private int CalculateCPM(ReadOnlySpan<KeyboardEvent> events, int timeWindow)
    {
        var validChars = 0;
        foreach (ref readonly var evt in events)
        {
            if (evt.Type == KeyType.Character)
                validChars++;
        }
        
        return (int)(validChars * (60f / timeWindow));
    }

    private TypingPattern AnalyzeTypingPattern(
        ReadOnlySpan<KeyboardEvent> events)
    {
        if (events.IsEmpty) return TypingPattern.Unknown;

        var metrics = CalculateTypingMetrics(events);

        // 简化的决策树
        if (metrics.CodingSymbolRatio > 0.15f && metrics.TabCount > 3)
            return TypingPattern.Coding;
        
        if (metrics.EnterRatio > 0.08f)
            return TypingPattern.Chatting;
        
        if (metrics.SpaceRatio > 0.15f && metrics.EnterRatio < 0.03f)
            return TypingPattern.Writing;
        
        if (metrics.EnterRatio > 0.2f)
            return TypingPattern.Command;

        return TypingPattern.Mixed;
    }

    private TypingMetrics CalculateTypingMetrics(
        ReadOnlySpan<KeyboardEvent> events)
    {
        var total = events.Length;
        var codingSymbols = 0;
        var tabCount = 0;
        var enterCount = 0;
        var spaceCount = 0;

        foreach (ref readonly var evt in events)
        {
            if (IsCodingSymbol(evt.KeyCode)) codingSymbols++;
            
            switch (evt.KeyCode)
            {
                case "Tab": tabCount++; break;
                case "Enter": enterCount++; break;
                case "Space": spaceCount++; break;
            }
        }

        return new TypingMetrics
        {
            CodingSymbolRatio = (float)codingSymbols / total,
            TabCount = tabCount,
            EnterRatio = (float)enterCount / total,
            SpaceRatio = (float)spaceCount / total
        };
    }

    private static bool IsCodingSymbol(string key) =>
        key is "(" or ")" or "[" or "]" or "{" or "}" 
            or ";" or ":" or "=" or "<" or ">";

    private ActivityLevel CalculateMouseActivity(
        ReadOnlySpan<MouseEvent> events)
    {
        // 简化评分
        var score = 0f;
        score += events.Count(e => e.Type == MouseEventType.Click) * 2f;
        score += events.Count(e => e.Type == MouseEventType.Drag) * 5f;
        score += events.Count(e => e.Type == MouseEventType.Scroll) * 0.5f;

        return score switch
        {
            >= 70 => ActivityLevel.VeryHigh,
            >= 45 => ActivityLevel.High,
            >= 25 => ActivityLevel.Medium,
            >= 10 => ActivityLevel.Low,
            _ => ActivityLevel.VeryLow
        };
    }

    private ScrollPattern AnalyzeScrollPattern(
        ReadOnlySpan<MouseEvent> events)
    {
        var scrollEvents = events.ToArray()
            .Where(e => e.Type == MouseEventType.Scroll)
            .ToArray();

        if (scrollEvents.Length < 3)
            return ScrollPattern.None;

        // 简化判断：基于平均间隔
        var avgInterval = CalculateAverageInterval(scrollEvents);

        return avgInterval switch
        {
            < 500 => ScrollPattern.FastEndless,
            < 2000 => ScrollPattern.FastBrowse,
            < 5000 => ScrollPattern.SlowSteady,
            _ => ScrollPattern.Variable
        };
    }

    private int CalculateAverageInterval(MouseEvent[] events)
    {
        if (events.Length < 2) return int.MaxValue;

        var intervals = new List<int>();
        for (int i = 1; i < events.Length; i++)
        {
            var interval = (int)(events[i].Timestamp - events[i - 1].Timestamp)
                .TotalMilliseconds;
            intervals.Add(interval);
        }

        return (int)intervals.Average();
    }

    private WindowSwitchingLevel CalculateWindowSwitching(int switchCount)
    {
        // 每5分钟的切换次数
        return switchCount switch
        {
            >= 10 => WindowSwitchingLevel.VeryHigh,
            >= 5 => WindowSwitchingLevel.High,
            >= 2 => WindowSwitchingLevel.Medium,
            >= 1 => WindowSwitchingLevel.Low,
            _ => WindowSwitchingLevel.VeryLow
        };
    }
}

// 辅助类型
internal readonly struct TypingMetrics
{
    public float CodingSymbolRatio { get; init; }
    public int TabCount { get; init; }
    public float EnterRatio { get; init; }
    public float SpaceRatio { get; init; }
}

internal enum ActivityLevel { VeryLow, Low, Medium, High, VeryHigh }
internal enum TypingPattern { Unknown, Coding, Writing, Chatting, Command, Mixed }
internal enum ScrollPattern { None, FastEndless, FastBrowse, SlowSteady, Variable }
internal enum WindowSwitchingLevel { VeryLow, Low, Medium, High, VeryHigh }
```

### 3.3 规则引擎（简化版）

```csharp
namespace Marionet.Core.Perception.Scene;

/// <summary>
/// 规则引擎接口
/// </summary>
internal interface IRuleEngine
{
    SceneResult? Match(FeatureSet features, SystemMonitorData data);
    bool IsKnownGame(string processName);
}

/// <summary>
/// 基于规则配置的引擎
/// </summary>
internal sealed class ConfigBasedRuleEngine : IRuleEngine
{
    private readonly List<SceneRule> _rules;
    private readonly HashSet<string> _knownGames;

    public ConfigBasedRuleEngine(SceneRuleConfig config)
    {
        _rules = config.Rules.OrderBy(r => r.Priority).ToList();
        _knownGames = config.KnownGames.ToHashSet(StringComparer.OrdinalIgnoreCase);
    }

    public SceneResult? Match(FeatureSet features, SystemMonitorData data)
    {
        foreach (var rule in _rules)
        {
            var score = EvaluateRule(rule, features, data);
            
            if (score >= rule.MinScore)
            {
                return new SceneResult
                {
                    Type = rule.SceneType,
                    SubType = DetermineSubType(rule, features),
                    Confidence = Math.Min(score / 100f, 0.95f)
                };
            }
        }

        return null;
    }

    public bool IsKnownGame(string processName) =>
        _knownGames.Contains(processName);

    private float EvaluateRule(
        SceneRule rule, 
        FeatureSet features, 
        SystemMonitorData data)
    {
        var score = 0f;

        // 应用类别匹配
        if (rule.AppCategories?.Contains(data.AppCategory) == true)
        {
            score += rule.BaseScore;
        }
        else if (rule.AppCategories?.Any() == true)
        {
            return 0f; // 不匹配直接返回
        }

        // 特征评分
        foreach (var (feature, weight) in rule.FeatureWeights)
        {
            if (MatchFeature(feature, weight, features))
            {
                score += weight;
            }
        }

        return score;
    }

    private bool MatchFeature(
        string featureName, 
        float weight,
        FeatureSet features)
    {
        // 简化的特征匹配
        return featureName switch
        {
            "KeyboardActivity.High" => 
                features.KeyboardActivity >= ActivityLevel.High,
            "TypingPattern.Coding" => 
                features.TypingPattern == TypingPattern.Coding,
            "MouseActivity.Low" => 
                features.MouseActivity <= ActivityLevel.Low,
            _ => false
        };
    }

    private string? DetermineSubType(SceneRule rule, FeatureSet features)
    {
        // 子类型判断逻辑
        return null;
    }
}

/// <summary>
/// 场景规则
/// </summary>
internal sealed class SceneRule
{
    public required SceneType SceneType { get; init; }
    public int Priority { get; init; }
    public List<string>? AppCategories { get; init; }
    public float BaseScore { get; init; }
    public float MinScore { get; init; }
    public Dictionary<string, float> FeatureWeights { get; init; } = new();
}
```

---

## 4. 配置系统

### 4.1 配置文件示例

```json
// Configuration/perception/scene-rules.json
{
  "rules": [
    {
      "sceneType": "Work_Coding",
      "priority": 1,
      "appCategories": ["IDE", "TextEditor"],
      "baseScore": 50,
      "minScore": 75,
      "featureWeights": {
        "KeyboardActivity.High": 30,
        "TypingPattern.Coding": 25,
        "MouseActivity.Low": 15
      }
    },
    {
      "sceneType": "Entertainment_VideoStreaming",
      "priority": 1,
      "appCategories": ["Browser", "VideoPlayer"],
      "baseScore": 40,
      "minScore": 70,
      "featureWeights": {
        "MouseActivity.VeryLow": 20,
        "KeyboardActivity.VeryLow": 20,
        "MediaPlaying": 30
      }
    }
  ],
  "knownGames": [
    "league of legends.exe",
    "csgo.exe",
    "valorant.exe"
  ]
}
```

### 4.2 阈值配置

```json
// Configuration/perception/thresholds.json
{
  "keyboardActivity": {
    "veryHigh": 80,
    "high": 50,
    "medium": 30,
    "low": 10
  },
  "mouseActivity": {
    "veryHigh": 70,
    "high": 45,
    "medium": 25,
    "low": 10
  },
  "cache": {
    "ttlSeconds": 5,
    "maxSize": 100
  }
}
```

---

## 5. 性能优化

### 5.1 缓存系统

```csharp
namespace Marionet.Core.Perception.Scene;

/// <summary>
/// 场景缓存（避免重复计算）
/// </summary>
internal sealed class SceneCache
{
    private readonly MemoryCache _cache;

    public SceneCache(IConfiguration config)
    {
        var ttl = config.GetValue("Perception:Cache:TtlSeconds", 5);
        var maxSize = config.GetValue("Perception:Cache:MaxSize", 100);

        _cache = new MemoryCache(new MemoryCacheOptions
        {
            SizeLimit = maxSize
        });
    }

    public bool TryGet(string key, out SceneResult result)
    {
        return _cache.TryGetValue(key, out result);
    }

    public void Set(string key, SceneResult result)
    {
        _cache.Set(key, result, new MemoryCacheEntryOptions
        {
            Size = 1,
            SlidingExpiration = TimeSpan.FromSeconds(5)
        });
    }
}
```

### 5.2 依赖注入配置

```csharp
// Startup.cs 或 ServiceExtensions.cs
public static class PerceptionServiceExtensions
{
    public static IServiceCollection AddPerceptionServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // 配置加载
        services.AddSingleton<ThresholdConfig>(sp =>
        {
            return configuration.GetSection("Perception:Thresholds")
                .Get<ThresholdConfig>() ?? new ThresholdConfig();
        });

        services.AddSingleton<SceneRuleConfig>(sp =>
        {
            var json = File.ReadAllText("Configuration/perception/scene-rules.json");
            return JsonSerializer.Deserialize<SceneRuleConfig>(json)
                ?? throw new InvalidOperationException("Failed to load scene rules");
        });

        // 场景分类模块
        services.AddSingleton<IFeatureExtractor, FeatureExtractor>();
        services.AddSingleton<IRuleEngine, ConfigBasedRuleEngine>();
        services.AddSingleton<SceneCache>();
        services.AddSingleton<ISceneClassifier, SceneClassifier>();

        // Perception Unit
        services.AddSingleton<ISystemMonitor, SystemMonitor>();
        services.AddSingleton<PerceptionUnit>();

        return services;
    }
}
```

---

## 6. 调试与日志

### 6.1 调试输出示例

```csharp
// 在开发模式下输出详细信息
if (_logger.IsEnabled(LogLevel.Debug))
{
    _logger.LogDebug(
        "Scene classified: {Scene} ({Confidence:P0}) - {Features}",
        result.Type,
        result.Confidence,
        JsonSerializer.Serialize(features)
    );
}
```

### 6.2 性能监控

```csharp
// 使用 DiagnosticSource 监控性能
var stopwatch = Stopwatch.StartNew();
var result = Classify(data);
stopwatch.Stop();

if (stopwatch.ElapsedMilliseconds > 50)
{
    _logger.LogWarning(
        "Scene classification slow: {ElapsedMs}ms",
        stopwatch.ElapsedMilliseconds
    );
}
```

---

## 7. 使用示例

### 7.1 在 Perception Unit 中使用

```csharp
public sealed class PerceptionUnit
{
    private readonly ISceneClassifier _sceneClassifier;
    
    public PerceptionContext CollectContext()
    {
        var data = _systemMonitor.Collect();
        var scene = _sceneClassifier.Classify(data);
        
        return new PerceptionContext
        {
            timestamp = DateTime.UtcNow,
            foreground_app = data.ProcessName,
            window_title = data.WindowTitle,
            
            // 场景识别结果
            scene_type = scene.Type,
            scene_sub_type = scene.SubType,
            scene_confidence = scene.Confidence,
            
            // ... 其他字段
        };
    }
}
```

### 7.2 在 Decision Unit 中使用

```csharp
public sealed class DecisionUnit
{
    public bool ShouldInteract(PerceptionContext ctx)
    {
        // 基于场景类型调整决策
        return ctx.scene_type switch
        {
            SceneType.Work_Coding when ctx.focus == FocusLevel.High 
                => false, // 专注编程时保持安静
            
            SceneType.Entertainment_Gaming 
                => true,  // 游戏时可以互动
            
            SceneType.Meeting_VideoCall 
                => false, // 会议中绝不打扰
            
            _ => CalculateInteractionProbability(ctx) > 0.7f
        };
    }
}
```
## 结论
目前这个规则引擎只是初步设计，内容复杂还需验证可行性

- ⚠️ **基于规则** - 不如机器学习灵活
- ⚠️ **需要调优** - 阈值需要实际测试调整
- ⚠️ **边界模糊** - 某些场景难以区分

后续考虑上小模型提高识别的准确性

---

<p align="center">
  <i>Scene Classifier: Part of Perception Unit</i><br>
  <sub>为决策提供场景上下文</sub>
</p>