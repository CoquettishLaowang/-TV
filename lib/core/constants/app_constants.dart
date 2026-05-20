/// 应用全局常量定义模块
/// 定义应用级别的常量，包括应用名称、版本、超时时间、缓存键名等
/// 被所有模块引用，是应用配置的基础
library;

/// 应用名称，显示在标题栏和关于页面
const String kAppName = 'TV Video Hub';

/// 应用版本号，与pubspec.yaml保持同步
const String kAppVersion = '1.0.0';

/// 冷启动超时阈值（毫秒），超过此时间视为启动异常
/// 来源：性能需求文档 - 冷启动时间<3秒
const int kColdStartThresholdMs = 3000;

/// 内存占用警告阈值（MB），超过此值触发内存优化
/// 来源：性能需求文档 - 正常使用时内存占用<200MB
const int kMemoryWarningThresholdMb = 200;

/// 目标帧率（fps），TV端需稳定在此帧率
/// 来源：性能需求文档 - 帧率稳定在60fps
const int kTargetFrameRate = 60;

/// 帧率低于此值视为卡顿，需要性能优化介入
/// 目标帧率60fps，50fps作为预警阈值，30fps作为最低底线
/// 来源：性能需求 - 稳定帧率≥50fps（TV端标准）
const int kFrameDropThreshold = 50;

/// WebView页面加载超时时间（秒）
const int kPageLoadTimeoutSeconds = 30;

/// CSS适配规则缓存有效期（小时），过期后重新从远程拉取
const int kAdaptationCacheDurationHours = 24;

/// 焦点动画持续时间（毫秒），控制TV遥控器导航时的视觉反馈速度
const int kFocusAnimationDurationMs = 200;

/// 页面切换动画持续时间（毫秒）
const int kPageTransitionDurationMs = 300;

/// 遥控器按键防抖间隔（毫秒），防止快速重复按键
const int kKeyDebounceIntervalMs = 150;

/// 网络连接检测间隔（秒）
const int kConnectivityCheckIntervalSeconds = 10;

/// SharedPreferences存储键名：上次选择的平台ID
const String kPrefKeyLastPlatform = 'last_platform_id';

/// SharedPreferences存储键名：用户设置的主题模式
const String kPrefKeyThemeMode = 'theme_mode';

/// SharedPreferences存储键名：是否首次启动应用
const String kPrefKeyFirstLaunch = 'is_first_launch';

/// SharedPreferences存储键名：适配规则缓存时间戳
const String kPrefKeyAdaptationTimestamp = 'adaptation_cache_timestamp';

/// 默认平台ID，应用启动时默认选中的视频平台
const String kDefaultPlatformId = 'bilibili';

/// TV标准横向分辨率（1080p）
const int kTvStandardWidth = 1920;

/// TV标准纵向分辨率（1080p）
const int kTvStandardHeight = 1080;

/// TV安全区域边距比例，确保内容不被电视边框裁切
/// 来源：TV UI设计规范 - 过扫描安全区域通常为5%
const double kTvSafeAreaRatio = 0.05;

/// 网格布局列数，首页平台选择使用
const int kHomeGridColumns = 5;

/// 卡片圆角半径（逻辑像素）
const double kCardBorderRadius = 12.0;

/// 焦点边框宽度（逻辑像素）
const double kFocusBorderWidth = 3.0;

/// 焦点边框缩放比例
const double kFocusScaleFactor = 1.05;
