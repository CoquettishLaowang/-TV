/// PlatformInfo模型单元测试
/// 验证平台信息数据类的创建、序列化和相等性比较
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:tv_video_hub/models/platform_info.dart';

void main() {
  group('PlatformInfo', () {
    test('应正确创建PlatformInfo实例', () {
      const PlatformInfo info = PlatformInfo(
        id: 'bilibili',
        name: '哔哩哔哩',
        baseUrl: 'https://www.bilibili.com',
        iconPath: 'assets/icons/bilibili.png',
        brandColor: 0xFF00A1D6,
      );

      expect(info.id, 'bilibili');
      expect(info.name, '哔哩哔哩');
      expect(info.baseUrl, 'https://www.bilibili.com');
      expect(info.iconPath, 'assets/icons/bilibili.png');
      expect(info.brandColor, 0xFF00A1D6);
      expect(info.isAvailable, true);
    });

    test('fromJson应正确解析JSON映射', () {
      final Map<String, dynamic> jsonMap = {
        'id': 'iqiyi',
        'name': '爱奇艺',
        'baseUrl': 'https://www.iqiyi.com',
        'icon': 'assets/icons/iqiyi.png',
        'color': '#FF6A00',
      };

      final PlatformInfo info = PlatformInfo.fromJson(jsonMap);

      expect(info.id, 'iqiyi');
      expect(info.name, '爱奇艺');
      expect(info.baseUrl, 'https://www.iqiyi.com');
      expect(info.iconPath, 'assets/icons/iqiyi.png');
      expect(info.brandColor, 0xFFFF6A00);
    });

    test('copyWith应正确创建副本并修改指定字段', () {
      const PlatformInfo original = PlatformInfo(
        id: 'tencent',
        name: '腾讯视频',
        baseUrl: 'https://v.qq.com',
        iconPath: 'assets/icons/tencent.png',
        brandColor: 0xFFFF6A00,
      );

      final PlatformInfo copied = original.copyWith(
        name: '腾讯视频HD',
        isAvailable: false,
      );

      expect(copied.id, 'tencent');
      expect(copied.name, '腾讯视频HD');
      expect(copied.isAvailable, false);
      expect(copied.baseUrl, original.baseUrl);
    });

    test('相等性比较应基于id和baseUrl', () {
      const PlatformInfo infoA = PlatformInfo(
        id: 'youku',
        name: '优酷',
        baseUrl: 'https://www.youku.com',
        iconPath: 'assets/icons/youku.png',
        brandColor: 0xFF00AAE7,
      );
      const PlatformInfo infoB = PlatformInfo(
        id: 'youku',
        name: '优酷视频',
        baseUrl: 'https://www.youku.com',
        iconPath: 'assets/icons/youku_v2.png',
        brandColor: 0xFF00AAE8,
      );

      expect(infoA == infoB, true);
      expect(infoA.hashCode == infoB.hashCode, true);
    });

    test('不同id的平台应不相等', () {
      const PlatformInfo infoA = PlatformInfo(
        id: 'youku',
        name: '优酷',
        baseUrl: 'https://www.youku.com',
        iconPath: 'assets/icons/youku.png',
        brandColor: 0xFF00AAE7,
      );
      const PlatformInfo infoB = PlatformInfo(
        id: 'douyin',
        name: '抖音',
        baseUrl: 'https://www.douyin.com',
        iconPath: 'assets/icons/douyin.png',
        brandColor: 0xFF000000,
      );

      expect(infoA == infoB, false);
    });

    test('toString应包含id和name', () {
      const PlatformInfo info = PlatformInfo(
        id: 'bilibili',
        name: '哔哩哔哩',
        baseUrl: 'https://www.bilibili.com',
        iconPath: 'assets/icons/bilibili.png',
        brandColor: 0xFF00A1D6,
      );

      expect(info.toString(), contains('bilibili'));
      expect(info.toString(), contains('哔哩哔哩'));
    });
  });
}
