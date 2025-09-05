import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 通用渐变背景容器组件 - 提供多种渐变效果的背景容器
/// 支持线性、径向、扫描等多种渐变类型，以及预定义的品牌渐变
class AppGradientContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final AppGradientType type;
  final List<Color>? colors;
  final List<double>? stops;
  final Alignment begin;
  final Alignment end;
  final double? width;
  final double? height;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final bool animate;
  final Duration animationDuration;

  const AppGradientContainer({
    Key? key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius = 0.0,
    this.type = AppGradientType.primary,
    this.colors,
    this.stops,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.width,
    this.height,
    this.border,
    this.boxShadow,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = _buildDecoration();

    if (animate) {
      return AnimatedContainer(
        duration: animationDuration,
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: decoration,
        child: child,
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      gradient: _buildGradient(),
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: boxShadow,
    );
  }

  Gradient _buildGradient() {
    final gradientColors = colors ?? _getDefaultColors();

    switch (type) {
      case AppGradientType.radial:
        return RadialGradient(
          colors: gradientColors,
          stops: stops,
          center: Alignment.center,
          radius: 1.0,
        );
      case AppGradientType.sweep:
        return SweepGradient(
          colors: gradientColors,
          stops: stops,
          center: Alignment.center,
          startAngle: 0.0,
          endAngle: 2 * 3.14159,
        );
      default:
        return LinearGradient(
          colors: gradientColors,
          stops: stops,
          begin: begin,
          end: end,
        );
    }
  }

  List<Color> _getDefaultColors() {
    switch (type) {
      case AppGradientType.primary:
        return [
          AppColors.blueGradientStart,
          AppColors.blueGradientEnd,
        ];
      case AppGradientType.secondary:
        return [
          AppColors.secondary,
          AppColors.secondaryDark,
        ];
      case AppGradientType.success:
        return [
          AppColors.success,
          AppColors.success.withOpacity(0.8),
        ];
      case AppGradientType.warning:
        return [
          AppColors.warning,
          AppColors.warning.withOpacity(0.8),
        ];
      case AppGradientType.error:
        return [
          AppColors.error,
          AppColors.error.withOpacity(0.8),
        ];
      case AppGradientType.vip:
        return [
          AppColors.vipGold,
          AppColors.vipGoldDark,
        ];
      case AppGradientType.benefit:
        return [
          AppColors.benefitBlue,
          AppColors.primary,
        ];
      case AppGradientType.dark:
        return [
          AppColors.primaryDark,
          Colors.black.withOpacity(0.8),
        ];
      case AppGradientType.light:
        return [
          Colors.white,
          AppColors.sectionBackground,
        ];
      case AppGradientType.ocean:
        return [
          const Color(0xFF00C9FF),
          const Color(0xFF92FE9D),
        ];
      case AppGradientType.sunset:
        return [
          const Color(0xFFFF7B7B),
          const Color(0xFFFFB347),
        ];
      case AppGradientType.purple:
        return [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
        ];
      case AppGradientType.pink:
        return [
          const Color(0xFFf093fb),
          const Color(0xFFf5576c),
        ];
      default:
        return [
          AppColors.blueGradientStart,
          AppColors.blueGradientEnd,
        ];
    }
  }
}

/// 渐变类型枚举
enum AppGradientType {
  primary,    // 主要渐变
  secondary,  // 次要渐变
  success,    // 成功渐变
  warning,    // 警告渐变
  error,      // 错误渐变
  vip,        // VIP渐变
  benefit,    // 福利渐变
  dark,       // 深色渐变
  light,      // 浅色渐变
  ocean,      // 海洋渐变
  sunset,     // 日落渐变
  purple,     // 紫色渐变
  pink,       // 粉色渐变
  radial,     // 径向渐变
  sweep,      // 扫描渐变
}

/// 预定义的渐变容器样式
class AppGradientStyles {
  /// 主页横幅背景
  static AppGradientContainer banner({
    Key? key,
    required Widget child,
    double borderRadius = 16.0,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppGradientContainer(
      key: key,
      type: AppGradientType.primary,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
      child: child,
    );
  }

  /// VIP卡片背景
  static AppGradientContainer vipCard({
    Key? key,
    required Widget child,
    double borderRadius = 16.0,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppGradientContainer(
      key: key,
      type: AppGradientType.vip,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      boxShadow: [
        BoxShadow(
          color: AppColors.vipGold.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
      child: child,
    );
  }

  /// 福利中心背景
  static AppGradientContainer benefitCard({
    Key? key,
    required Widget child,
    double borderRadius = 16.0,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppGradientContainer(
      key: key,
      type: AppGradientType.benefit,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      boxShadow: [
        BoxShadow(
          color: AppColors.benefitBlue.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
      child: child,
    );
  }

  /// 促销活动背景
  static AppGradientContainer promotion({
    Key? key,
    required Widget child,
    AppGradientType gradientType = AppGradientType.ocean,
    double borderRadius = 16.0,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppGradientContainer(
      key: key,
      type: gradientType,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      child: child,
    );
  }

  /// 成功状态背景
  static AppGradientContainer success({
    Key? key,
    required Widget child,
    double borderRadius = 12.0,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppGradientContainer(
      key: key,
      type: AppGradientType.success,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      child: child,
    );
  }

  /// 警告状态背景
  static AppGradientContainer warning({
    Key? key,
    required Widget child,
    double borderRadius = 12.0,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppGradientContainer(
      key: key,
      type: AppGradientType.warning,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      child: child,
    );
  }

  /// 错误状态背景
  static AppGradientContainer error({
    Key? key,
    required Widget child,
    double borderRadius = 12.0,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppGradientContainer(
      key: key,
      type: AppGradientType.error,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      child: child,
    );
  }

  /// 页面背景渐变
  static AppGradientContainer pageBackground({
    Key? key,
    required Widget child,
    AppGradientType gradientType = AppGradientType.light,
  }) {
    return AppGradientContainer(
      key: key,
      type: gradientType,
      width: double.infinity,
      height: double.infinity,
      child: child,
    );
  }

  /// 浮动操作按钮背景
  static AppGradientContainer fab({
    Key? key,
    required Widget child,
    AppGradientType gradientType = AppGradientType.primary,
    double size = 56.0,
  }) {
    return AppGradientContainer(
      key: key,
      type: gradientType,
      width: size,
      height: size,
      borderRadius: size / 2,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      child: child,
    );
  }

  /// 顶部状态栏背景
  static AppGradientContainer statusBar({
    Key? key,
    required Widget child,
    double height = 100.0,
  }) {
    return AppGradientContainer(
      key: key,
      type: AppGradientType.primary,
      width: double.infinity,
      height: height,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      child: child,
    );
  }

  /// 底部导航背景
  static AppGradientContainer bottomNav({
    Key? key,
    required Widget child,
    double height = 80.0,
  }) {
    return AppGradientContainer(
      key: key,
      type: AppGradientType.light,
      width: double.infinity,
      height: height,
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
      child: child,
    );
  }
}

/// 动画渐变容器 - 支持渐变动画效果
class AnimatedAppGradientContainer extends StatefulWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final List<AppGradientType> gradientTypes;
  final Duration animationDuration;
  final Duration pauseDuration;
  final bool autoStart;
  final double? width;
  final double? height;

  const AnimatedAppGradientContainer({
    Key? key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius = 0.0,
    required this.gradientTypes,
    this.animationDuration = const Duration(seconds: 3),
    this.pauseDuration = const Duration(seconds: 2),
    this.autoStart = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<AnimatedAppGradientContainer> createState() => _AnimatedAppGradientContainerState();
}

class _AnimatedAppGradientContainerState extends State<AnimatedAppGradientContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(widget.pauseDuration, () {
          if (mounted) {
            setState(() {
              _currentIndex = (_currentIndex + 1) % widget.gradientTypes.length;
            });
            _controller.reset();
            _controller.forward();
          }
        });
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientContainer(
      type: widget.gradientTypes[_currentIndex],
      padding: widget.padding,
      margin: widget.margin,
      borderRadius: widget.borderRadius,
      width: widget.width,
      height: widget.height,
      animate: true,
      animationDuration: widget.animationDuration,
      child: widget.child,
    );
  }
}
