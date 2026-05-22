/// 视频平台常量定义模块
/// 定义各视频平台的标识、URL、CSS选择器等常量
/// 被适配器模块和注册中心引用
library;

/// 爱奇艺平台标识
const String kPlatformIqiyi = 'iqiyi';

/// 腾讯视频平台标识
const String kPlatformTencent = 'tencent';

/// 哔哩哔哩平台标识
const String kPlatformBilibili = 'bilibili';

/// 优酷平台标识
const String kPlatformYouku = 'youku';

/// 抖音平台标识
const String kPlatformDouyin = 'douyin';

/// 爱奇艺网站基础URL
const String kIqiyiBaseUrl = 'https://www.iqiyi.com';

/// 腾讯视频网站基础URL
const String kTencentBaseUrl = 'https://v.qq.com';

/// 哔哩哔哩网站基础URL
const String kBilibiliBaseUrl = 'https://www.bilibili.com';

/// 优酷网站基础URL
const String kYoukuBaseUrl = 'https://www.youku.com';

/// 抖音网站基础URL
const String kDouyinBaseUrl = 'https://www.douyin.com';

/// 爱奇艺品牌主色（十六进制）
const int kIqiyiBrandColor = 0xFF00BE06;

/// 腾讯视频品牌主色（十六进制）
const int kTencentBrandColor = 0xFFFF6A00;

/// 哔哩哔哩品牌主色（十六进制）
const int kBilibiliBrandColor = 0xFF00A1D6;

/// 优酷品牌主色（十六进制）
const int kYoukuBrandColor = 0xFF1A91FF;

/// 抖音品牌主色（十六进制）
const int kDouyinBrandColor = 0xFF161823;

/// 平台列表，包含所有支持的平台ID
const List<String> kSupportedPlatforms = [
  kPlatformIqiyi,
  kPlatformTencent,
  kPlatformBilibili,
  kPlatformYouku,
  kPlatformDouyin,
];

/// 爱奇艺TV适配CSS选择器 - 导航栏
const String kIqiyiNavSelector = '.nav-wrap, .header-nav';

/// 爱奇艺TV适配CSS选择器 - 视频卡片
const String kIqiyiVideoCardSelector = '.site-pic, .qy-mod-link';

/// 腾讯视频TV适配CSS选择器 - 导航栏
const String kTencentNavSelector = '.site-header, .nav_inner';

/// 腾讯视频TV适配CSS选择器 - 视频卡片
const String kTencentVideoCardSelector = '.list_item, .figure';

/// 哔哩哔哩TV适配CSS选择器 - 导航栏
const String kBilibiliNavSelector = '.header, .bili-header';

/// 哔哩哔哩TV适配CSS选择器 - 视频卡片
const String kBilibiliVideoCardSelector = '.feed-card, .video-card';

/// 优酷TV适配CSS选择器 - 导航栏
const String kYoukuNavSelector = '.header, .yk-header';

/// 优酷TV适配CSS选择器 - 视频卡片
const String kYoukuVideoCardSelector = '.video-card, .yk-video-card';

/// 抖音TV适配CSS选择器 - 导航栏
const String kDouyinNavSelector = '.header, .nav-container';

/// 抖音TV适配CSS选择器 - 视频卡片
const String kDouyinVideoCardSelector = '.video-card, .feed-card';

/// WebView User-Agent后缀，标识TV端请求
const String kTvUserAgentSuffix = 'TVVideoHub/1.0 (TV; LargeScreen)';

/// 桌面端 Chrome User-Agent，确保视频网站返回PC网页版（非手机版）
/// 设计说明：使用固定Chrome 125版本的UA字符串
///   - 优点：避免移动端UA触发视频网站的简化/移动版页面，确保TV大屏获得完整PC布局
///   - 权衡：硬编码版本号可能在Chrome 125过时后触发部分网站的安全提示（"浏览器版本过旧"）
///   - 后续改进方向：支持远程配置最新的桌面端UA字符串，通过Firebase Remote Config或自建配置服务下发
///   - 当前版本通过 Object.defineProperty 在页面加载前注入，优先级高于服务端UA检测
const String kDesktopUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36 TVVideoHub/1.0';
