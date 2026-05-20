/// 应用基础Widget测试
/// 验证核心Widget组件的基本渲染功能
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tv_video_hub/widgets/tv_loading.dart';

void main() {
  testWidgets('TvLoading加载状态应显示CircularProgressIndicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TvLoading(state: LoadingState.loading),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('加载中...'), findsOneWidget);
  });

  testWidgets('TvLoading空状态应显示提示文字', (WidgetTester tester) async {
    const String testMessage = '暂无内容';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TvLoading(
            state: LoadingState.empty,
          ),
        ),
      ),
    );

    expect(find.text(testMessage), findsOneWidget);
  });

  testWidgets('TvLoading错误状态应显示错误信息和重试按钮',
      (WidgetTester tester) async {
    const String errorMessage = '加载失败';
    bool retryPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TvLoading(
            state: LoadingState.error,
            errorMessage: errorMessage,
            onRetry: () {
              retryPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text(errorMessage), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    expect(retryPressed, true);
  });

  testWidgets('TvLoading已加载状态应不显示任何内容',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TvLoading(state: LoadingState.loaded),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
