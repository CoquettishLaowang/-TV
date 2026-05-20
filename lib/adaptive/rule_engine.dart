/// 自适应规则引擎模块
/// 管理CSS适配规则的加载、匹配和动态更新
/// 当视频平台网页格式变化时，自动检测并调整适配规则
/// 被平台适配器和WebView控制器使用
library;

import '../models/adaptation_config.dart';

/// 规则引擎
/// 负责适配规则的加载、缓存、匹配和动态更新
/// 单例模式，作为所有适配规则的唯一权威来源
class RuleEngine {
  /// 单例实例
  static final RuleEngine _instance = RuleEngine._internal();

  /// 获取单例实例
  static RuleEngine get instance => _instance;

  /// 规则缓存，键为平台ID，值为适配配置
  final Map<String, AdaptationConfig> _configCache = {};

  /// 是否已初始化
  bool _isInitialized = false;

  /// 获取初始化状态
  bool get isInitialized => _isInitialized;

  /// 私有构造函数，自动加载默认规则
  RuleEngine._internal() {
    _loadDefaultRules();
    _isInitialized = true;
  }

  /// 初始化规则引擎
  /// 从本地配置文件加载默认适配规则
  /// 返回：Future<void>
  /// 副作用：填充规则缓存
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    await _loadDefaultRules();
    _isInitialized = true;
  }

  /// 从本地配置文件加载默认适配规则
  /// 副作用：向规则缓存中添加默认规则
  Future<void> _loadDefaultRules() async {
    final List<AdaptationRule> commonRules = _buildCommonRules();
    final Map<String, List<AdaptationRule>> platformRules =
        _buildPlatformSpecificRules();

    for (final String platformId in platformRules.keys) {
      final List<AdaptationRule> allRules = [
        ...commonRules,
        ...platformRules[platformId]!,
      ];
      _configCache[platformId] = AdaptationConfig(
        platformId: platformId,
        rules: allRules,
        lastUpdatedTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  /// 构建通用适配规则（所有平台共用）
  /// 返回：List<AdaptationRule> - 通用规则列表
  /// 副作用：无
  List<AdaptationRule> _buildCommonRules() {
    return [
      const AdaptationRule(
        ruleId: 'common_hide_scrollbar',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '::-webkit-scrollbar',
        cssProperty: 'display',
        cssValue: 'none',
        priority: 10,
      ),
      const AdaptationRule(
        ruleId: 'common_body_font',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: 'body, html',
        cssProperty: 'font-size',
        cssValue: '20px',
        priority: 5,
      ),
      const AdaptationRule(
        ruleId: 'common_body_bg',
        ruleType: AdaptationRuleType.modifyColor,
        cssSelector: 'body',
        cssProperty: 'background',
        cssValue: '#0a0a0a !important',
        priority: 3,
      ),
      const AdaptationRule(
        ruleId: 'common_hide_popup',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.popup, .modal, .dialog-overlay, .ad-layer, .float-ad, .splash-screen',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 20,
      ),
      const AdaptationRule(
        ruleId: 'common_enlarge_buttons',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: 'button, a.btn, .btn, input[type="button"], input[type="submit"]',
        cssProperty: 'min-height',
        cssValue: '48px',
        priority: 8,
      ),
      const AdaptationRule(
        ruleId: 'common_enlarge_button_font',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: 'button, a.btn, .btn, input[type="button"], input[type="submit"]',
        cssProperty: 'font-size',
        cssValue: '20px',
        priority: 8,
      ),
      const AdaptationRule(
        ruleId: 'common_enlarge_click_area',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: 'a, [role="button"], .clickable, [onclick]',
        cssProperty: 'min-width',
        cssValue: '64px',
        priority: 7,
      ),
      const AdaptationRule(
        ruleId: 'common_enlarge_click_padding',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: 'a, [role="button"], .clickable, [onclick]',
        cssProperty: 'padding',
        cssValue: '12px 16px',
        priority: 7,
      ),
      const AdaptationRule(
        ruleId: 'common_link_font',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: 'a',
        cssProperty: 'font-size',
        cssValue: '20px',
        priority: 7,
      ),
      const AdaptationRule(
        ruleId: 'common_full_width_content',
        ruleType: AdaptationRuleType.modifyLayout,
        cssSelector: '.main-content, .content, .main, main, [class*="content-wrapper"], [class*="main-wrap"]',
        cssProperty: 'max-width',
        cssValue: '100vw !important',
        priority: 6,
      ),
      const AdaptationRule(
        ruleId: 'common_content_padding',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.main-content, .content, .main, main, [class*="content-wrapper"], [class*="main-wrap"]',
        cssProperty: 'padding',
        cssValue: '24px 48px',
        priority: 6,
      ),
      const AdaptationRule(
        ruleId: 'common_hide_sidebars',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.sidebar, .side-nav, .side-bar, .left-nav, .right-sidebar, aside, [class*="sidebar"], [class*="side-bar"], [class*="aside"]',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 15,
      ),
      const AdaptationRule(
        ruleId: 'common_adjust_grid',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.grid-view, [class*="grid"], .video-grid, .card-grid, .video-list, [class*="list-wrap"]',
        cssProperty: 'grid-template-columns',
        cssValue: 'repeat(auto-fill, minmax(320px, 1fr))',
        priority: 9,
      ),
      const AdaptationRule(
        ruleId: 'common_grid_gap',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.grid-view, [class*="grid"], .video-grid, .card-grid',
        cssProperty: 'gap',
        cssValue: '20px',
        priority: 9,
      ),
      const AdaptationRule(
        ruleId: 'common_input_enlarge',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: 'input, textarea, select',
        cssProperty: 'font-size',
        cssValue: '20px',
        priority: 8,
      ),
      const AdaptationRule(
        ruleId: 'common_input_height',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: 'input[type="text"], input[type="password"], input[type="search"], input[type="email"]',
        cssProperty: 'min-height',
        cssValue: '44px',
        priority: 8,
      ),
    ];
  }

  /// 构建各平台特定的适配规则
  /// 返回：Map<String, List<AdaptationRule>> - 键为平台ID，值为规则列表
  /// 副作用：无
  Map<String, List<AdaptationRule>> _buildPlatformSpecificRules() {
    return {
      'iqiyi': _buildIqiyiRules(),
      'tencent': _buildTencentRules(),
      'bilibili': _buildBilibiliRules(),
      'youku': _buildYoukuRules(),
      'douyin': _buildDouyinRules(),
    };
  }

  /// 构建爱奇艺平台适配规则
  List<AdaptationRule> _buildIqiyiRules() {
    return [
      const AdaptationRule(
        ruleId: 'iqiyi_hide_sidebar',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.sidebar, .side-nav, .mod-side, .qy-sidebar, .left-menu',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 15,
        applicablePlatformIds: ['iqiyi'],
      ),
      const AdaptationRule(
        ruleId: 'iqiyi_resize_nav',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.nav-wrap, .header-nav, .qy-header, .nav-bar a, .nav-item',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 12,
        applicablePlatformIds: ['iqiyi'],
      ),
      const AdaptationRule(
        ruleId: 'iqiyi_nav_height',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.nav-wrap, .header-nav, .qy-header, .nav-bar',
        cssProperty: 'min-height',
        cssValue: '64px',
        priority: 11,
        applicablePlatformIds: ['iqiyi'],
      ),
      const AdaptationRule(
        ruleId: 'iqiyi_nav_padding',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.nav-wrap a, .header-nav a, .nav-item, .nav-bar a',
        cssProperty: 'padding',
        cssValue: '16px 24px',
        priority: 11,
        applicablePlatformIds: ['iqiyi'],
      ),
      const AdaptationRule(
        ruleId: 'iqiyi_resize_cards',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.site-pic, .qy-mod-link, .video-card, .album-card, .qy-card',
        cssProperty: 'transform',
        cssValue: 'scale(1.1)',
        priority: 10,
        applicablePlatformIds: ['iqiyi'],
      ),
      const AdaptationRule(
        ruleId: 'iqiyi_card_width',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.site-pic, .qy-mod-link, .video-card, .album-card, .qy-card',
        cssProperty: 'min-width',
        cssValue: '280px',
        priority: 9,
        applicablePlatformIds: ['iqiyi'],
      ),
      const AdaptationRule(
        ruleId: 'iqiyi_hide_ad',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.qy-player-side-ad, .mod-ad, .ad-banner, [class*="ad-"], .qy-ad',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 20,
        applicablePlatformIds: ['iqiyi'],
      ),
      const AdaptationRule(
        ruleId: 'iqiyi_full_width',
        ruleType: AdaptationRuleType.modifyLayout,
        cssSelector: '.qy-main, .main-content, .container, .page-container',
        cssProperty: 'width',
        cssValue: '100vw !important',
        priority: 6,
        applicablePlatformIds: ['iqiyi'],
      ),
      const AdaptationRule(
        ruleId: 'iqiyi_category_nav',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.category-nav, .sort-nav, .filter-bar a, .tab-nav a',
        cssProperty: 'font-size',
        cssValue: '20px',
        priority: 11,
        applicablePlatformIds: ['iqiyi'],
      ),
      const AdaptationRule(
        ruleId: 'iqiyi_video_player',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.iqp-player, .player-container, .video-player, .qy-player',
        cssProperty: 'width',
        cssValue: '100vw !important',
        priority: 14,
        applicablePlatformIds: ['iqiyi'],
      ),
      const AdaptationRule(
        ruleId: 'iqiyi_login_form',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.login-form, .login-box, .qy-login input, .login-container input',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 13,
        applicablePlatformIds: ['iqiyi'],
      ),
    ];
  }

  /// 构建腾讯视频平台适配规则
  List<AdaptationRule> _buildTencentRules() {
    return [
      const AdaptationRule(
        ruleId: 'tencent_hide_sidebar',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.sidebar, .side-bar, .mod-side, .left-panel, .right-panel',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 15,
        applicablePlatformIds: ['tencent'],
      ),
      const AdaptationRule(
        ruleId: 'tencent_resize_cards',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.list_item, .figure, .video-card, .item-card',
        cssProperty: 'transform',
        cssValue: 'scale(1.15)',
        priority: 10,
        applicablePlatformIds: ['tencent'],
      ),
      const AdaptationRule(
        ruleId: 'tencent_card_min_width',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.list_item, .figure, .video-card, .item-card',
        cssProperty: 'min-width',
        cssValue: '300px',
        priority: 9,
        applicablePlatformIds: ['tencent'],
      ),
      const AdaptationRule(
        ruleId: 'tencent_hide_ad',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.ad-banner, .mod-ad, .float-ad, [class*="advert"], .tx-ad',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 20,
        applicablePlatformIds: ['tencent'],
      ),
      const AdaptationRule(
        ruleId: 'tencent_resize_nav',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.site-header, .nav_inner, .nav-bar, .nav-list a, .header-nav a, .top-nav a',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 12,
        applicablePlatformIds: ['tencent'],
      ),
      const AdaptationRule(
        ruleId: 'tencent_nav_height',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.site-header, .nav_inner, .nav-bar, .header-nav, .top-nav',
        cssProperty: 'min-height',
        cssValue: '64px',
        priority: 11,
        applicablePlatformIds: ['tencent'],
      ),
      const AdaptationRule(
        ruleId: 'tencent_nav_padding',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.site-header a, .nav_inner a, .nav-bar a, .nav-item',
        cssProperty: 'padding',
        cssValue: '16px 24px',
        priority: 11,
        applicablePlatformIds: ['tencent'],
      ),
      const AdaptationRule(
        ruleId: 'tencent_full_width',
        ruleType: AdaptationRuleType.modifyLayout,
        cssSelector: '.main, .container, .page-container, .content-wrap',
        cssProperty: 'width',
        cssValue: '100vw !important',
        priority: 6,
        applicablePlatformIds: ['tencent'],
      ),
      const AdaptationRule(
        ruleId: 'tencent_player_width',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.player, .txp_player, .video-container, [class*="player-container"]',
        cssProperty: 'width',
        cssValue: '100vw !important',
        priority: 14,
        applicablePlatformIds: ['tencent'],
      ),
      const AdaptationRule(
        ruleId: 'tencent_category_nav',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.tab-nav, .filter-nav, .category-list a, .sort-bar a',
        cssProperty: 'font-size',
        cssValue: '20px',
        priority: 11,
        applicablePlatformIds: ['tencent'],
      ),
      const AdaptationRule(
        ruleId: 'tencent_login_form',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.login-panel, .login-wrap, .login-box input, .login-form input',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 13,
        applicablePlatformIds: ['tencent'],
      ),
    ];
  }

  /// 构建哔哩哔哩平台适配规则
  List<AdaptationRule> _buildBilibiliRules() {
    return [
      const AdaptationRule(
        ruleId: 'bilibili_hide_sidebar',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.sidebar, .bili-sidebar, .left-nav, .right-area, .recommend-right',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 15,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_resize_video_card',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.feed-card, .video-card, .bili-video-card, .recommend-card',
        cssProperty: 'transform',
        cssValue: 'scale(1.1)',
        priority: 10,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_card_size',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.feed-card, .video-card, .bili-video-card, .recommend-card',
        cssProperty: 'min-width',
        cssValue: '320px',
        priority: 9,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_resize_nav',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.header, .bili-header, .nav-menu, .primary-menu a, .nav-link, .top-nav a',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 12,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_nav_height',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.header, .bili-header, .nav-menu, .primary-menu, .top-nav',
        cssProperty: 'min-height',
        cssValue: '64px',
        priority: 11,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_nav_padding',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.nav-menu a, .primary-menu a, .nav-link, .nav-item',
        cssProperty: 'padding',
        cssValue: '16px 24px',
        priority: 11,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_hide_banner',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.banner, .header-banner, .carousel-banner, .recommend-banner, .slide-banner',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 18,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_hide_live_sidebar',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.live-sidebar, .chat-panel, .danmaku-box',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 16,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_full_width_content',
        ruleType: AdaptationRuleType.modifyLayout,
        cssSelector: '.bili-content, .main-content, .video-list-container, .recommend-container',
        cssProperty: 'width',
        cssValue: '100vw !important',
        priority: 6,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_player_width',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.bpx-player, .player-container, .bilibili-player, .video-container',
        cssProperty: 'width',
        cssValue: '100vw !important',
        priority: 14,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_video_title',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.video-title, .card-title, .title, h1, h2, h3',
        cssProperty: 'font-size',
        cssValue: '24px',
        priority: 10,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_login_form',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.login-form, .bili-login, .login-panel input, .login-box input',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 13,
        applicablePlatformIds: ['bilibili'],
      ),
    ];
  }

  /// 构建优酷平台适配规则
  List<AdaptationRule> _buildYoukuRules() {
    return [
      const AdaptationRule(
        ruleId: 'youku_hide_sidebar',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.sidebar, .yk-sidebar, .side-nav, .left-area, .right-panel',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 15,
        applicablePlatformIds: ['youku'],
      ),
      const AdaptationRule(
        ruleId: 'youku_resize_nav',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.header, .yk-header, .nav-bar, .top-nav a, .main-nav a',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 12,
        applicablePlatformIds: ['youku'],
      ),
      const AdaptationRule(
        ruleId: 'youku_nav_height',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.header, .yk-header, .nav-bar, .top-nav, .main-nav',
        cssProperty: 'min-height',
        cssValue: '64px',
        priority: 11,
        applicablePlatformIds: ['youku'],
      ),
      const AdaptationRule(
        ruleId: 'youku_nav_padding',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.nav-bar a, .top-nav a, .main-nav a, .nav-item',
        cssProperty: 'padding',
        cssValue: '16px 24px',
        priority: 11,
        applicablePlatformIds: ['youku'],
      ),
      const AdaptationRule(
        ruleId: 'youku_resize_cards',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.video-card, .yk-video-card, .card-item, .poster-item',
        cssProperty: 'transform',
        cssValue: 'scale(1.1)',
        priority: 10,
        applicablePlatformIds: ['youku'],
      ),
      const AdaptationRule(
        ruleId: 'youku_card_size',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.video-card, .yk-video-card, .card-item, .poster-item',
        cssProperty: 'min-width',
        cssValue: '300px',
        priority: 9,
        applicablePlatformIds: ['youku'],
      ),
      const AdaptationRule(
        ruleId: 'youku_hide_ad',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.ad-banner, .yk-ad, .float-ad, [class*="advert"], .yk-pause-ad',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 20,
        applicablePlatformIds: ['youku'],
      ),
      const AdaptationRule(
        ruleId: 'youku_full_width',
        ruleType: AdaptationRuleType.modifyLayout,
        cssSelector: '.main, .yk-main, .container, .page-content, .content-area',
        cssProperty: 'width',
        cssValue: '100vw !important',
        priority: 6,
        applicablePlatformIds: ['youku'],
      ),
      const AdaptationRule(
        ruleId: 'youku_player_width',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.yk-player, .player-container, .youku-player, .video-player',
        cssProperty: 'width',
        cssValue: '100vw !important',
        priority: 14,
        applicablePlatformIds: ['youku'],
      ),
      const AdaptationRule(
        ruleId: 'youku_category_nav',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.tab-nav, .category-bar, .filter-nav a, .sort-tab a',
        cssProperty: 'font-size',
        cssValue: '20px',
        priority: 11,
        applicablePlatformIds: ['youku'],
      ),
      const AdaptationRule(
        ruleId: 'youku_login_form',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.login-form, .yk-login, .login-container input, .login-panel input',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 13,
        applicablePlatformIds: ['youku'],
      ),
    ];
  }

  /// 构建抖音平台适配规则
  List<AdaptationRule> _buildDouyinRules() {
    return [
      const AdaptationRule(
        ruleId: 'douyin_hide_sidebar',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.sidebar, .side-nav, .left-nav, .right-panel, .recommend-panel',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 15,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_resize_feed',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.feed-card, .video-card, .video-item, .swiper-slide',
        cssProperty: 'transform',
        cssValue: 'scale(1.15)',
        priority: 10,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_feed_size',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.feed-card, .video-card, .video-item, .swiper-slide',
        cssProperty: 'min-width',
        cssValue: '340px',
        priority: 9,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_resize_nav',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.header, .nav-container, .top-nav, .nav-bar a, .main-nav a',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 12,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_nav_height',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.header, .nav-container, .top-nav, .nav-bar, .main-nav',
        cssProperty: 'min-height',
        cssValue: '64px',
        priority: 11,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_nav_padding',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.nav-bar a, .top-nav a, .main-nav a, .nav-item',
        cssProperty: 'padding',
        cssValue: '16px 24px',
        priority: 11,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_hide_recommend',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.recommend-sidebar, .related-panel, .search-hot, .trending-panel',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 15,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_hide_live_sidebar',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.live-chat, .chat-room, .comment-panel',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 16,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_full_width',
        ruleType: AdaptationRuleType.modifyLayout,
        cssSelector: '.main, .content, .feed-container, .video-feed, .page-content',
        cssProperty: 'width',
        cssValue: '100vw !important',
        priority: 6,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_video_player',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.player, .video-player, .dy-player, .xgplayer',
        cssProperty: 'width',
        cssValue: '100vw !important',
        priority: 14,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_feed_grid',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.feed-container, .video-feed, [class*="feed-list"]',
        cssProperty: 'display',
        cssValue: 'grid',
        priority: 9,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_feed_grid_cols',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.feed-container, .video-feed, [class*="feed-list"]',
        cssProperty: 'grid-template-columns',
        cssValue: 'repeat(auto-fill, minmax(320px, 1fr))',
        priority: 9,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_login_form',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.login-form, .dy-login, .login-container input, .login-box input',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 13,
        applicablePlatformIds: ['douyin'],
      ),
    ];
  }

  /// 获取指定平台的适配配置
  /// 参数：platformId - 平台ID
  /// 返回：AdaptationConfig? - 适配配置，不存在时返回null
  /// 副作用：无
  AdaptationConfig? getConfig(String platformId) {
    return _configCache[platformId];
  }

  /// 更新指定平台的适配配置
  /// 参数：platformId - 平台ID / config - 新的适配配置
  /// 副作用：修改规则缓存
  void updateConfig(String platformId, AdaptationConfig config) {
    _configCache[platformId] = config;
  }

  /// 为指定平台添加单条适配规则
  /// 参数：platformId - 平台ID / rule - 新的适配规则
  /// 副作用：修改规则缓存中的规则列表
  void addRule(String platformId, AdaptationRule rule) {
    final AdaptationConfig? existingConfig = _configCache[platformId];
    if (existingConfig == null) {
      _configCache[platformId] = AdaptationConfig(
        platformId: platformId,
        rules: [rule],
      );
      return;
    }
    final List<AdaptationRule> updatedRules =
        List<AdaptationRule>.from(existingConfig.rules)..add(rule);
    _configCache[platformId] = existingConfig.copyWith(rules: updatedRules);
  }

  /// 移除指定平台的某条适配规则
  /// 参数：platformId - 平台ID / ruleId - 要移除的规则ID
  /// 副作用：修改规则缓存中的规则列表
  void removeRule(String platformId, String ruleId) {
    final AdaptationConfig? existingConfig = _configCache[platformId];
    if (existingConfig == null) {
      return;
    }
    final List<AdaptationRule> updatedRules = existingConfig.rules
        .where((AdaptationRule rule) => rule.ruleId != ruleId)
        .toList();
    _configCache[platformId] = existingConfig.copyWith(rules: updatedRules);
  }

  /// 生成指定平台的完整CSS注入字符串
  /// 参数：platformId - 平台ID
  /// 返回：String - CSS代码字符串
  /// 副作用：无
  String generateCssForPlatform(String platformId) {
    final AdaptationConfig? config = _configCache[platformId];
    if (config == null) {
      return '';
    }
    return config.generateCss();
  }

  /// 清除所有缓存
  /// 副作用：清空规则缓存
  void clearCache() {
    _configCache.clear();
    _isInitialized = false;
  }
}
