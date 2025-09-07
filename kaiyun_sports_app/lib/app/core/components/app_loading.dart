import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 通用加载指示器组件 - 提供多种样式的加载动画
/// 支持圆形、线性、点状、骨架屏等多种加载样式
class AppLoadingIndicator extends StatelessWidget {
  final AppLoadingType type;
  final Color? color;
  final double size;
  final double strokeWidth;
  final String? message;
  final bool overlay;
  final Color? backgroundColor;
  final double? value;

  const AppLoadingIndicator({
    super.key,
    this.type = AppLoadingType.circular,
    this.color,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.message,
    this.overlay = false,
    this.backgroundColor,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final Widget indicator = _buildIndicator(context);

    if (overlay) {
      return Container(
        color: backgroundColor ?? Colors.black.withOpacity(0.5),
        child: Center(child: indicator),
      );
    }

    return indicator;
  }

  Widget _buildIndicator(BuildContext context) {
    switch (type) {
      case AppLoadingType.circular:
        return _buildCircularIndicator();
      case AppLoadingType.linear:
        return _buildLinearIndicator();
      case AppLoadingType.dots:
        return _buildDotsIndicator();
      case AppLoadingType.pulse:
        return _buildPulseIndicator();
      case AppLoadingType.wave:
        return _buildWaveIndicator();
      case AppLoadingType.skeleton:
        return _buildSkeletonIndicator();
    }
  }

  /// 圆形加载指示器
  Widget _buildCircularIndicator() {
    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
        backgroundColor: Colors.grey.withOpacity(0.2),
      ),
    );

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              color: color ?? AppColors.primary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return indicator;
  }

  /// 线性加载指示器
  Widget _buildLinearIndicator() {
    final indicator = SizedBox(
      width: size,
      height: 4,
      child: LinearProgressIndicator(
        value: value,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
        backgroundColor: Colors.grey.withOpacity(0.2),
      ),
    );

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 8),
          Text(
            message!,
            style: TextStyle(
              color: color ?? AppColors.primary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return indicator;
  }

  /// 点状加载指示器
  Widget _buildDotsIndicator() {
    return _DotsLoadingIndicator(
      color: color ?? AppColors.primary,
      size: size / 8,
    );
  }

  /// 脉冲加载指示器
  Widget _buildPulseIndicator() {
    return _PulseLoadingIndicator(
      color: color ?? AppColors.primary,
      size: size,
    );
  }

  /// 波浪加载指示器
  Widget _buildWaveIndicator() {
    return _WaveLoadingIndicator(
      color: color ?? AppColors.primary,
      size: size,
    );
  }

  /// 骨架屏加载指示器
  Widget _buildSkeletonIndicator() {
    return _SkeletonLoadingIndicator(
      width: size,
      height: size / 2,
    );
  }
}

/// 加载类型枚举
enum AppLoadingType {
  circular,  // 圆形
  linear,    // 线性
  dots,      // 点状
  pulse,     // 脉冲
  wave,      // 波浪
  skeleton,  // 骨架屏
}

/// 点状加载动画
class _DotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsLoadingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers
        .map((controller) => Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.3 + _animations[index].value * 0.7),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// 脉冲加载动画
class _PulseLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseLoadingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// 波浪加载动画
class _WaveLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _WaveLoadingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_WaveLoadingIndicator> createState() => _WaveLoadingIndicatorState();
}

class _WaveLoadingIndicatorState extends State<_WaveLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      ),
    );

    _animations = _controllers
        .map((controller) => Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = widget.size / 10;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: barWidth,
              height: widget.size * (0.3 + _animations[index].value * 0.7),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(barWidth / 2),
              ),
            );
          },
        );
      }),
    );
  }
}

/// 骨架屏加载动画
class _SkeletonLoadingIndicator extends StatefulWidget {
  final double width;
  final double height;

  const _SkeletonLoadingIndicator({
    required this.width,
    required this.height,
  });

  @override
  State<_SkeletonLoadingIndicator> createState() => _SkeletonLoadingIndicatorState();
}

class _SkeletonLoadingIndicatorState extends State<_SkeletonLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: const [
                0.0,
                0.5,
                1.0,
              ],
              transform: _SlidingGradientTransform(_animation.value),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// 预定义的加载指示器样式
class AppLoadingStyles {
  /// 页面加载 - 全屏遮罩
  static Widget page({
    String? message = '加载中...',
    Color? backgroundColor,
  }) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AppLoadingIndicator(
            type: AppLoadingType.circular,
            message: message,
            size: 48,
          ),
        ),
      ),
    );
  }

  /// 按钮加载 - 小尺寸
  static Widget button({
    Color? color,
  }) {
    return AppLoadingIndicator(
      type: AppLoadingType.circular,
      color: color ?? Colors.white,
      size: 20,
      strokeWidth: 2,
    );
  }

  /// 列表加载 - 底部显示
  static Widget list() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const AppLoadingIndicator(
        type: AppLoadingType.dots,
        size: 32,
      ),
    );
  }

  /// 刷新加载 - 顶部显示
  static Widget refresh() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: const AppLoadingIndicator(
        type: AppLoadingType.circular,
        size: 24,
        strokeWidth: 2,
      ),
    );
  }

  /// 内容加载 - 骨架屏
  static Widget content({
    double width = double.infinity,
    double height = 200,
  }) {
    return AppLoadingIndicator(
      type: AppLoadingType.skeleton,
      size: width,
    );
  }
}
