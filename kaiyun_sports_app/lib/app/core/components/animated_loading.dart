import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../theme/app_colors.dart';

/// 加载状态类型
enum LoadingType {
  circular,
  dots,
  wave,
  bounce,
  fadingCircle,
  pulse,
  rotating,
  custom,
}

/// 动画加载组件
class AnimatedLoading extends StatelessWidget {
  final LoadingType type;
  final double size;
  final Color? color;
  final String? message;
  final bool showMessage;
  final TextStyle? messageStyle;
  final Duration duration;
  final Widget? customWidget;
  
  const AnimatedLoading({
    super.key,
    this.type = LoadingType.circular,
    this.size = 50.0,
    this.color,
    this.message,
    this.showMessage = false,
    this.messageStyle,
    this.duration = const Duration(milliseconds: 1200),
    this.customWidget,
  });
  
  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? AppColors.primary;
    
    Widget loadingWidget;
    
    switch (type) {
      case LoadingType.circular:
        loadingWidget = SpinKitCircle(
          color: loadingColor,
          size: size,
          duration: duration,
        );
        break;
        
      case LoadingType.dots:
        loadingWidget = SpinKitThreeBounce(
          color: loadingColor,
          size: size * 0.6,
          duration: duration,
        );
        break;
        
      case LoadingType.wave:
        loadingWidget = SpinKitWave(
          color: loadingColor,
          size: size,
          duration: duration,
        );
        break;
        
      case LoadingType.bounce:
        loadingWidget = SpinKitBounce(
          color: loadingColor,
          size: size,
          duration: duration,
        );
        break;
        
      case LoadingType.fadingCircle:
        loadingWidget = SpinKitFadingCircle(
          color: loadingColor,
          size: size,
          duration: duration,
        );
        break;
        
      case LoadingType.pulse:
        loadingWidget = SpinKitPulse(
          color: loadingColor,
          size: size,
          duration: duration,
        );
        break;
        
      case LoadingType.rotating:
        loadingWidget = SpinKitRotatingPlain(
          color: loadingColor,
          size: size,
          duration: duration,
        );
        break;
        
      case LoadingType.custom:
        loadingWidget = customWidget ?? SpinKitCircle(
          color: loadingColor,
          size: size,
        );
        break;
    }
    
    if (showMessage && message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingWidget,
          const SizedBox(height: 16),
          Text(
            message!,
            style: messageStyle ?? TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }
    
    return loadingWidget;
  }
}

/// 加载覆盖层
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final LoadingType loadingType;
  final Color? backgroundColor;
  final Color? loadingColor;
  
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.loadingType = LoadingType.circular,
    this.backgroundColor,
    this.loadingColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: AnimatedLoading(
                type: loadingType,
                color: loadingColor,
                message: message,
                showMessage: message != null,
              ),
            ),
          ),
      ],
    );
  }
}

/// 状态加载组件
class StateLoadingWidget extends StatefulWidget {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? loadingMessage;
  
  const StateLoadingWidget({
    super.key,
    required this.isLoading,
    required this.child,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.loadingWidget,
    this.errorWidget,
    this.loadingMessage,
  });
  
  @override
  State<StateLoadingWidget> createState() => _StateLoadingWidgetState();
}

class _StateLoadingWidgetState extends State<StateLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    if (!widget.isLoading && !widget.hasError) {
      _fadeController.forward();
    }
  }
  
  @override
  void didUpdateWidget(StateLoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading && !widget.hasError && 
        (oldWidget.isLoading || oldWidget.hasError)) {
      _fadeController.forward();
    } else if ((widget.isLoading || widget.hasError) && 
               (!oldWidget.isLoading && !oldWidget.hasError)) {
      _fadeController.reset();
    }
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Center(
        child: widget.loadingWidget ?? AnimatedLoading(
          message: widget.loadingMessage,
          showMessage: widget.loadingMessage != null,
        ),
      );
    }
    
    if (widget.hasError) {
      return Center(
        child: widget.errorWidget ?? _buildErrorWidget(),
      );
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
  
  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: AppColors.error,
        ),
        const SizedBox(height: 16),
        Text(
          widget.errorMessage ?? '加载失败',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onRetry,
            child: const Text('重试'),
          ),
        ],
      ],
    );
  }
}

/// 下拉刷新加载指示器
class CustomRefreshIndicator extends StatefulWidget {
  final Widget child;
  final RefreshCallback onRefresh;
  final Color? backgroundColor;
  final Color? color;
  
  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor,
    this.color,
  });
  
  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      backgroundColor: widget.backgroundColor ?? AppColors.surface,
      color: widget.color ?? AppColors.primary,
      strokeWidth: 2,
      child: widget.child,
    );
  }
}
