/// 应用入口模块
/// Flutter应用的主入口点，负责初始化和启动应用
/// 执行启动优化、绑定初始化等操作

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

  runApp(TvVideoHubApp(startupOptimizer: startupOptimizer));

  startupOptimizer.markPhaseCompleted(StartupPhase.uiRender);
  startupOptimizer.markPhaseCompleted(StartupPhase.completed);
}
