import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 统一导航控制器 - 管理所有导航操作
class NavigationController extends GetxController {
  // 当前页面索引
  final RxInt currentIndex = 0.obs;
  
  // 导航历史栈
  final RxList<String> navigationHistory = <String>[].obs;
  
  // 是否可以返回
  final RxBool canGoBack = false.obs;
  
  // 侧边菜单状态
  final RxBool isDrawerOpen = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // 监听路由变化
    ever(Get.routing, _handleRouteChange);
  }
  
  /// 处理路由变化
  void _handleRouteChange(Routing? routing) {
    if (routing != null && routing.current != null) {
      final currentRoute = routing.current!;
      
      // 更新导航历史
      if (navigationHistory.isEmpty || navigationHistory.last != currentRoute) {
        navigationHistory.add(currentRoute);
      }
      
      // 更新返回状态
      canGoBack.value = navigationHistory.length > 1;
    }
  }
  
  /// 导航到指定页面
  Future<void> navigateTo(String route, {
    Map<String, dynamic>? arguments,
    bool replace = false,
    NavigationType type = NavigationType.push,
    Duration? animationDuration,
  }) async {
    // 触觉反馈
    HapticFeedback.lightImpact();
    
    try {
      switch (type) {
        case NavigationType.push:
          if (replace) {
            await Get.offNamed(route, arguments: arguments);
          } else {
            await Get.toNamed(route, arguments: arguments);
          }
          break;
        case NavigationType.pushAndClearStack:
          await Get.offAllNamed(route, arguments: arguments);
          break;
        case NavigationType.replace:
          await Get.offNamed(route, arguments: arguments);
          break;
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }
  
  /// 返回上一页
  void goBack({
    dynamic result,
    bool animated = true,
  }) {
    HapticFeedback.lightImpact();
    
    if (Get.canPop()) {
      Get.back(result: result);
      
      // 更新历史栈
      if (navigationHistory.isNotEmpty) {
        navigationHistory.removeLast();
      }
      
      canGoBack.value = navigationHistory.length > 1;
    }
  }
  
  /// 切换底部导航
  void changeTab(int index) {
    if (currentIndex.value != index) {
      HapticFeedback.selectionClick();
      currentIndex.value = index;
    }
  }
  
  /// 切换侧边菜单
  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
    HapticFeedback.lightImpact();
  }
  
  /// 清空导航历史
  void clearHistory() {
    navigationHistory.clear();
    canGoBack.value = false;
  }
  
  /// 获取当前路由
  String get currentRoute {
    return Get.currentRoute;
  }
  
  /// 检查是否在指定路由
  bool isCurrentRoute(String route) {
    return Get.currentRoute == route;
  }
}

/// 导航类型枚举
enum NavigationType {
  push,
  replace,
  pushAndClearStack,
}

/// 导航动画类型
enum NavigationAnimation {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  fadeIn,
  scale,
  rotation,
}

/// 自定义页面转场动画
class CustomPageTransition {
  /// 右滑入动画
  static GetPageRoute slideFromRight<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return GetPageRoute<T>(
      page: () => page,
      transition: Transition.rightToLeft,
      transitionDuration: duration,
    );
  }
  
  /// 左滑入动画
  static GetPageRoute slideFromLeft<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return GetPageRoute<T>(
      page: () => page,
      transition: Transition.leftToRight,
      transitionDuration: duration,
    );
  }
  
  /// 底部滑入动画
  static GetPageRoute slideFromBottom<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return GetPageRoute<T>(
      page: () => page,
      transition: Transition.downToUp,
      transitionDuration: duration,
    );
  }
  
  /// 渐变动画
  static GetPageRoute fadeIn<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return GetPageRoute<T>(
      page: () => page,
      transition: Transition.fade,
      transitionDuration: duration,
    );
  }
  
  /// 缩放动画
  static GetPageRoute scale<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return GetPageRoute<T>(
      page: () => page,
      transition: Transition.zoom,
      transitionDuration: duration,
    );
  }
}
