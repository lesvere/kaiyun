import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// 动画扩展方法
extension AnimationExtensions on Widget {
  /// 添加淡入动画
  Widget fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
  }) {
    return AnimationConfiguration.synchronized(
      duration: duration,
      delay: delay,
      child: FadeInAnimation(
        curve: curve,
        child: this,
      ),
    );
  }
  
  /// 添加滑入动画
  Widget slideIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
    SlideDirection direction = SlideDirection.fromBottom,
  }) {
    return AnimationConfiguration.synchronized(
      duration: duration,
      delay: delay,
      child: SlideAnimation(
        curve: curve,
        horizontalOffset: direction == SlideDirection.fromLeft ? -50.0 : 
                           direction == SlideDirection.fromRight ? 50.0 : 0.0,
        verticalOffset: direction == SlideDirection.fromBottom ? 50.0 :
                       direction == SlideDirection.fromTop ? -50.0 : 0.0,
        child: FadeInAnimation(
          curve: curve,
          child: this,
        ),
      ),
    );
  }
  
  /// 添加缩放动画
  Widget scaleIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
    Curve curve = Curves.elasticOut,
    double scale = 0.3,
  }) {
    return AnimationConfiguration.synchronized(
      duration: duration,
      delay: delay,
      child: ScaleAnimation(
        curve: curve,
        scale: scale,
        child: this,
      ),
    );
  }
  
  /// 添加弹跳动画
  Widget bounce({
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
  }) {
    return AnimationConfiguration.synchronized(
      duration: duration,
      delay: delay,
      child: ScaleAnimation(
        curve: Curves.elasticOut,
        child: this,
      ),
    );
  }
  
  /// 添加震动效果
  Widget shake({
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value < 0.5 ? -5 * (1 - value * 2) : 5 * (value * 2 - 1), 0),
          child: this,
        );
      },
    );
  }
  
  /// 为列表项添加错位动画
  Widget staggeredAnimation(int index, {
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = const Duration(milliseconds: 50),
  }) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: duration,
      delay: delay,
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: this,
        ),
      ),
    );
  }
  
  /// 添加点击动画
  Widget clickAnimation({
    VoidCallback? onTap,
    double scaleDown = 0.95,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return _ClickableWidget(
      onTap: onTap,
      scaleDown: scaleDown,
      duration: duration,
      child: this,
    );
  }
}

/// 滑入方向
enum SlideDirection {
  fromTop,
  fromBottom,
  fromLeft,
  fromRight,
}

/// 可点击的动画Widget
class _ClickableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;
  
  const _ClickableWidget({
    required this.child,
    this.onTap,
    this.scaleDown = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });
  
  @override
  State<_ClickableWidget> createState() => _ClickableWidgetState();
}

class _ClickableWidgetState extends State<_ClickableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
