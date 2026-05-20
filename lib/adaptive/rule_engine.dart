/// 自适应规则引擎模块
/// 管理CSS适配规则的加载、匹配和动态更新
/// 当视频平台网页格式变化时，自动检测并调整适配规则
/// 被平台适配器和WebView控制器使用
library;

import '../models/adaptation_config.dart';

/// 规则引擎
/// 负责适配规则的加载、缓存、匹配和动态更新
class RuleEngine {
  /// 规则缓存，键为平台ID，值为适配配置
  final Map<String, AdaptationConfig> _configCache = {};

  /// 是否已初始化
  bool _isInitialized = false;

  /// 获取初始化状态
  bool get isInitialized => _isInitialized;

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
        ruleId: 'common_increase_font',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: 'body',
        cssProperty: 'font-size',
        cssValue: '20px',
        priority: 5,
      ),
      const AdaptationRule(
        ruleId: 'common_hide_popup',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.popup, .modal, .dialog-overlay, .ad-layer',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 20,
      ),
      const AdaptationRule(
        ruleId: 'common_enlarge_buttons',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: 'button, a.btn, .btn',
        cssProperty: 'min-height',
        cssValue: '48px',
        priority: 8,
      ),
      const AdaptationRule(
        ruleId: 'common_enlarge_click_area',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: 'a, [role="button"]',
        cssProperty: 'min-width',
        cssValue: '64px',
        priority: 7,
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
        cssSelector: '.sidebar, .side-nav',
        cssProperty: 'display',
        cssValue: 'none',
        priority: 15,
        applicablePlatformIds: ['iqiyi'],
      ),
      const AdaptationRule(
        ruleId: 'iqiyi_resize_nav',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.nav-wrap, .header-nav',
        cssProperty: 'font-size',
        cssValue: '24px',
        priority: 12,
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
        cssSelector: '.sidebar, .side-bar',
        cssProperty: 'display',
        cssValue: 'none',
        priority: 15,
        applicablePlatformIds: ['tencent'],
      ),
      const AdaptationRule(
        ruleId: 'tencent_resize_cards',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.list_item, .figure',
        cssProperty: 'transform',
        cssValue: 'scale(1.2)',
        priority: 10,
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
        cssSelector: '.sidebar, .bili-sidebar',
        cssProperty: 'display',
        cssValue: 'none',
        priority: 15,
        applicablePlatformIds: ['bilibili'],
      ),
      const AdaptationRule(
        ruleId: 'bilibili_resize_video_card',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.feed-card, .video-card',
        cssProperty: 'transform',
        cssValue: 'scale(1.15)',
        priority: 10,
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
        cssSelector: '.sidebar, .yk-sidebar',
        cssProperty: 'display',
        cssValue: 'none',
        priority: 15,
        applicablePlatformIds: ['youku'],
      ),
      const AdaptationRule(
        ruleId: 'youku_resize_nav',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.header, .yk-header',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 12,
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
        cssSelector: '.sidebar, .side-nav',
        cssProperty: 'display',
        cssValue: 'none',
        priority: 15,
        applicablePlatformIds: ['douyin'],
      ),
      const AdaptationRule(
        ruleId: 'douyin_resize_feed',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.feed-card, .video-card',
        cssProperty: 'transform',
        cssValue: 'scale(1.2)',
        priority: 10,
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
