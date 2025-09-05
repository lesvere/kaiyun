import 'package:flutter/material.dart';

/// 页面切换动画类型
enum PageTransitionType {
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
  fade,
  scale,
  rotateScale,
  slideRightFade,
  slideLeftFade,
}

/// 自定义页面路由
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final PageTransitionType transitionType;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final Curve curve;
  
  CustomPageRoute({
    required this.page,
    this.transitionType = PageTransitionType.slideRight,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              context,
              animation,
              secondaryAnimation,
              child,
              transitionType,
              curve,
            );
          },
        );
  
  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionType type,
    Curve curve,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );
    
    switch (type) {
      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
        
      case PageTransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
        
      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
        
      case PageTransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
        
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
        
      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
        
      case PageTransitionType.rotateScale:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
        
      case PageTransitionType.slideRightFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
        
      case PageTransitionType.slideLeftFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
    }
  }
}

/// GetX页面切换动画
class GetPageTransitions {
  static Widget slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }
  
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
  
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
