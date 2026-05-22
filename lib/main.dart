/// 应用入口模块
/// Flutter应用的主入口点，负责初始化和启动应用
/// 执行启动优化、绑定初始化等操作
library;

import 'package:flutter/material.dart';

import 'app.dart';
import 'core/performance/cache_manager.dart';
import 'core/performance/startup_optimizer.dart';

/// 全局启动优化器实例
final StartupOptimizer startupOptimizer = StartupOptimizer();

/// 应用主入口函数
/// 执行顺序：标记启动开始 → 绑定初始化 → 标记预初始化完成 → 启动Flutter应用
void main() {
  startupOptimizer.markStartupBegin();

  WidgetsFlutterBinding.ensureInitialized();

  // 初始化图片缓存策略：TV端限制80张/50MB，防止缓存膨胀
  CacheManager.initializeCachePolicy();

  startupOptimizer.markPhaseCompleted(StartupPhase.preInit);

  startupOptimizer.registerLazyInitTask(() {
    debugPrint('延迟初始化任务执行完毕');
  });

  startupOptimizer.markPhaseCompleted(StartupPhase.coreInit);

  // runApp()触发Flutter框架开始构建Widget树，但首帧渲染在下一个vsync信号时刻才完成
  // 以下两行标记了uiRender和completed阶段，其时间戳对应"runApp调用完毕时刻"
  // 而非"首帧渲染到屏幕时刻"
  // 设计决策：使用runApp()结束时刻而非首帧时刻作为启动计时终点
  //    优势：计时不受首次页面复杂度影响（各平台首页加载时间不同）
  //    局限：若首帧渲染耗时过长（如WebView初始化），实际用户感知启动时间会超过此记录
  //    改进：如需精确测量用户感知启动时间，可将completed标记移至
  //          WidgetsBinding.instance.addPostFrameCallback 回调中
  runApp(TvVideoHubApp(startupOptimizer: startupOptimizer));

  startupOptimizer.markPhaseCompleted(StartupPhase.uiRender);
  startupOptimizer.markPhaseCompleted(StartupPhase.completed);
}
