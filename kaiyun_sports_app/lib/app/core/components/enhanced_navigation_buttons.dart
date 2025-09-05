import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// 增强版返回按钮 - 支持多种样式和动画
class EnhancedBackButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;
  final BackButtonStyle style;
  final bool enableAnimation;
  final Duration animationDuration;
  final bool enableHapticFeedback;
  
  const EnhancedBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
    this.style = BackButtonStyle.arrow,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableHapticFeedback = true,
  });
  
  @override
  State<EnhancedBackButton> createState() => _EnhancedBackButtonState();
}

class _EnhancedBackButtonState extends State<EnhancedBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: -0.1,
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
  
  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    
    if (widget.enableAnimation) {
      _controller.forward();
    }
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }
  
  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    
    if (widget.enableAnimation) {
      _controller.reverse();
    }
    
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      Navigator.maybePop(context);
    }
  }
  
  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    
    if (widget.enableAnimation) {
      _controller.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isPressed
                      ? (widget.color ?? AppColors.primary).withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(
                  _getIconData(),
                  size: widget.size ?? 24,
                  color: widget.color ?? AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  IconData _getIconData() {
    switch (widget.style) {
      case BackButtonStyle.arrow:
        return Icons.arrow_back;
      case BackButtonStyle.arrowIOS:
        return Icons.arrow_back_ios;
      case BackButtonStyle.close:
        return Icons.close;
      case BackButtonStyle.chevron:
        return Icons.chevron_left;
    }
  }
}

/// 返回按钮样式枚举
enum BackButtonStyle {
  arrow,
  arrowIOS,
  close,
  chevron,
}

/// 增强版菜单按钮 - 支持动画和交互效果
class EnhancedMenuButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;
  final MenuButtonStyle style;
  final bool isActive;
  final bool enableAnimation;
  final Duration animationDuration;
  
  const EnhancedMenuButton({
    super.key,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
    this.style = MenuButtonStyle.hamburger,
    this.isActive = false,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });
  
  @override
  State<EnhancedMenuButton> createState() => _EnhancedMenuButtonState();
}

class _EnhancedMenuButtonState extends State<EnhancedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isActive) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(EnhancedMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTap() {
    HapticFeedback.lightImpact();
    
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 3.14159,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isActive
                      ? (widget.color ?? AppColors.primary).withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: widget.enableAnimation && widget.style == MenuButtonStyle.hamburger
                    ? _buildAnimatedHamburger()
                    : Icon(
                        _getIconData(),
                        size: widget.size ?? 24,
                        color: widget.color ?? AppColors.primary,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAnimatedHamburger() {
    return CustomPaint(
      size: Size(widget.size ?? 24, widget.size ?? 24),
      painter: _AnimatedHamburgerPainter(
        animation: _rotationAnimation,
        color: widget.color ?? AppColors.primary,
      ),
    );
  }
  
  IconData _getIconData() {
    switch (widget.style) {
      case MenuButtonStyle.hamburger:
        return widget.isActive ? Icons.close : Icons.menu;
      case MenuButtonStyle.dots:
        return Icons.more_vert;
      case MenuButtonStyle.grid:
        return Icons.grid_view;
    }
  }
}

/// 菜单按钮样式枚举
enum MenuButtonStyle {
  hamburger,
  dots,
  grid,
}

/// 动画汉堡包菜单画家
class _AnimatedHamburgerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  
  _AnimatedHamburgerPainter({
    required this.animation,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;
    
    // 上线
    final topStart = Offset(width * 0.2, centerY - width * 0.25);
    final topEnd = Offset(width * 0.8, centerY - width * 0.25);
    final topRotated = _rotateLine(topStart, topEnd, centerY, animation.value * 45);
    
    // 中线
    final middleStart = Offset(width * 0.2, centerY);
    final middleEnd = Offset(width * 0.8, centerY);
    final middleOpacity = 1.0 - animation.value;
    
    // 下线
    final bottomStart = Offset(width * 0.2, centerY + width * 0.25);
    final bottomEnd = Offset(width * 0.8, centerY + width * 0.25);
    final bottomRotated = _rotateLine(bottomStart, bottomEnd, centerY, -animation.value * 45);
    
    // 绘制线条
    canvas.drawLine(topRotated.start, topRotated.end, paint);
    
    if (middleOpacity > 0) {
      paint.color = color.withOpacity(middleOpacity);
      canvas.drawLine(middleStart, middleEnd, paint);
      paint.color = color;
    }
    
    canvas.drawLine(bottomRotated.start, bottomRotated.end, paint);
  }
  
  _RotatedLine _rotateLine(Offset start, Offset end, double centerY, double degrees) {
    final radians = degrees * 3.14159 / 180;
    final cos = math.cos(radians);
    final sin = math.sin(radians);
    
    final centerX = (start.dx + end.dx) / 2;
    
    // 旋转起点
    final startX = centerX + (start.dx - centerX) * cos - (start.dy - centerY) * sin;
    final startY = centerY + (start.dx - centerX) * sin + (start.dy - centerY) * cos;
    
    // 旋转终点
    final endX = centerX + (end.dx - centerX) * cos - (end.dy - centerY) * sin;
    final endY = centerY + (end.dx - centerX) * sin + (end.dy - centerY) * cos;
    
    return _RotatedLine(
      start: Offset(startX, startY),
      end: Offset(endX, endY),
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _RotatedLine {
  final Offset start;
  final Offset end;
  
  _RotatedLine({required this.start, required this.end});
}

import 'dart:math' as math;
