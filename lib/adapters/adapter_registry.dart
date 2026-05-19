/// 适配器注册中心模块
/// 管理所有视频平台适配器的注册、查询和生命周期
/// 被应用初始化代码和页面组件使用

import '../core/base/base_adapter.dart';
import 'iqiyi_adapter.dart';
import 'tencent_adapter.dart';
import 'bilibili_adapter.dart';
import 'youku_adapter.dart';
import 'douyin_adapter.dart';

/// 适配器注册中心
/// 单例模式，管理所有平台适配器的注册表
/// 提供按平台ID查询适配器的功能
class AdapterRegistry {
  /// 单例实例
  static final AdapterRegistry _instance = AdapterRegistry._internal();

  /// 获取单例实例
  static AdapterRegistry get instance => _instance;

  /// 适配器注册表，键为平台ID，值为适配器实例
  final Map<String, BasePlatformAdapter> _adapters = {};

  /// 私有构造函数，初始化时注册所有内置平台适配器
  AdapterRegistry._internal() {
    _registerBuiltinAdapters();
  }

  /// 注册内置平台适配器
  /// 副作用：向注册表中添加5个默认平台适配器
  void _registerBuiltinAdapters() {
    registerAdapter(IqiyiAdapter());
    registerAdapter(TencentAdapter());
    registerAdapter(BilibiliAdapter());
    registerAdapter(YoukuAdapter());
    registerAdapter(DouyinAdapter());
  }

  /// 注册一个平台适配器
  /// 参数：adapter - 要注册的适配器实例
  /// 副作用：修改适配器注册表，若平台ID已存在则覆盖
  void registerAdapter(BasePlatformAdapter adapter) {
    _adapters[adapter.platformInfo.id] = adapter;
  }

  /// 注销一个平台适配器
  /// 参数：platformId - 要注销的平台ID
  /// 副作用：从注册表中移除适配器
  void unregisterAdapter(String platformId) {
    _adapters.remove(platformId);
  }

  /// 获取指定平台的适配器
  /// 参数：platformId - 平台ID
  /// 返回：BasePlatformAdapter? - 适配器实例，不存在时返回null
  /// 副作用：无
  BasePlatformAdapter? getAdapter(String platformId) {
    return _adapters[platformId];
  }

  /// 获取所有已注册的平台ID列表
  /// 返回：List<String> - 平台ID列表
  /// 副作用：无
  List<String> getRegisteredPlatformIds() {
    return _adapters.keys.toList();
  }

  /// 获取所有已注册的适配器列表
  /// 返回：List<BasePlatformAdapter> - 适配器列表
  /// 副作用：无
  List<BasePlatformAdapter> getAllAdapters() {
    return _adapters.values.toList();
  }

  /// 检查指定平台是否已注册
  /// 参数：platformId - 平台ID
  /// 返回：bool - 是否已注册
  /// 副作用：无
  bool isPlatformRegistered(String platformId) {
    return _adapters.containsKey(platformId);
  }

  /// 获取已注册平台数量
  /// 返回：int - 已注册平台数量
  /// 副作用：无
  int get adapterCount => _adapters.length;

  /// 清除所有已注册的适配器
  /// 副作用：清空适配器注册表
  void clearAll() {
    _adapters.clear();
  }
}
