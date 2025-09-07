import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// 动画按钮组件
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final ButtonStyle? buttonStyle;
  final Duration animationDuration;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  
  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.borderRadius = 8,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.buttonStyle,
    this.animationDuration = const Duration(milliseconds: 200),
    this.elevation = 2,
    this.padding,
  });
  
  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _scaleController.forward();
      
      // 触觉反馈
      HapticFeedback.lightImpact();
    }
  }
  
  void _onTapUp(TapUpDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.reverse();
      _rippleController.forward().then((_) {
        _rippleController.reset();
      });
      
      setState(() {
        _isPressed = false;
      });
      
      if (widget.onPressed != null) {
        widget.onPressed!();
      }
    }
  }
  
  void _onTapCancel() {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.reverse();
      setState(() {
        _isPressed = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? AppColors.primary;
    final textColor = widget.textColor ?? Colors.white;
    final isDisabled = !widget.isEnabled || widget.isLoading;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _rippleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(isDisabled ? 0.1 : 0.3),
                    blurRadius: widget.elevation * (_isPressed ? 0.5 : 1),
                    offset: Offset(0, widget.elevation * (_isPressed ? 0.5 : 1)),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 按钮背景
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDisabled 
                          ? backgroundColor.withOpacity(0.5)
                          : backgroundColor,
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                      ),
                    ),
                  ),
                  
                  // 涟漪效果
                  if (_rippleAnimation.value > 0)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                        ),
                        child: CustomPaint(
                          painter: _RipplePainter(
                            animation: _rippleAnimation,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  
                  // 按钮内容
                  Positioned.fill(
                    child: Padding(
                      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(textColor),
                              ),
                            )
                          else if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: isDisabled ? textColor.withOpacity(0.5) : textColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                          ],
                          
                          if (!widget.isLoading)
                            Text(
                              widget.text,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDisabled ? textColor.withOpacity(0.5) : textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 涟漪效果画笔
class _RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  
  _RipplePainter({
    required this.animation,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final radius = size.width * 0.5 * animation.value;
    final center = Offset(size.width * 0.5, size.height * 0.5);
    
    canvas.drawCircle(center, radius, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
