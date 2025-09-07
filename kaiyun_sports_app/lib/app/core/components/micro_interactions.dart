import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// 点击波纹效果组件
class RippleEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? rippleColor;
  final double? borderRadius;
  final Duration rippleDuration;
  
  const RippleEffect({
    super.key,
    required this.child,
    this.onTap,
    this.rippleColor,
    this.borderRadius,
    this.rippleDuration = const Duration(milliseconds: 300),
  });
  
  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Offset? _tapPosition;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.rippleDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
    _controller.forward().then((_) {
      _controller.reset();
    });
    
    HapticFeedback.lightImpact();
    
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
        child: Stack(
          children: [
            widget.child,
            if (_tapPosition != null)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _RipplePainter(
                        position: _tapPosition!,
                        animation: _animation,
                        color: widget.rippleColor ?? AppColors.primary.withOpacity(0.2),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Offset position;
  final Animation<double> animation;
  final Color color;
  
  _RipplePainter({
    required this.position,
    required this.animation,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final radius = size.width * animation.value;
    canvas.drawCircle(position, radius, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// 悬停效果组件
class HoverEffect extends StatefulWidget {
  final Widget child;
  final Color? hoverColor;
  final double? elevation;
  final double borderRadius;
  final Duration duration;
  final Curve curve;
  
  const HoverEffect({
    super.key,
    required this.child,
    this.hoverColor,
    this.elevation,
    this.borderRadius = 8,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });
  
  @override
  State<HoverEffect> createState() => _HoverEffectState();
}

class _HoverEffectState extends State<HoverEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2,
      end: (widget.elevation ?? 2) * 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.hoverColor ?? AppColors.primary.withOpacity(0.05),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onHover(bool hovered) {
    setState(() {
      _isHovered = hovered;
    });
    
    if (hovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.elevation != null ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
              ] : null,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// 长按效果组件
class LongPressEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLongPress;
  final Duration longPressDuration;
  final Color? pressColor;
  final double borderRadius;
  
  const LongPressEffect({
    super.key,
    required this.child,
    this.onLongPress,
    this.longPressDuration = const Duration(milliseconds: 800),
    this.pressColor,
    this.borderRadius = 8,
  });
  
  @override
  State<LongPressEffect> createState() => _LongPressEffectState();
}

class _LongPressEffectState extends State<LongPressEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.longPressDuration,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isPressed) {
        HapticFeedback.heavyImpact();
        if (widget.onLongPress != null) {
          widget.onLongPress!();
        }
        _reset();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }
  
  void _onPanEnd(DragEndDetails details) {
    _reset();
  }
  
  void _onPanCancel() {
    _reset();
  }
  
  void _reset() {
    setState(() {
      _isPressed = false;
    });
    _controller.reset();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      child: Stack(
        children: [
          widget.child,
          if (_isPressed)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: (widget.pressColor ?? AppColors.primary)
                          .withOpacity(0.1 * _progressAnimation.value),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: widget.pressColor ?? AppColors.primary,
                        width: 2 * _progressAnimation.value,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// 滑动效果组件
class SwipeEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final double threshold;
  final Duration animationDuration;
  
  const SwipeEffect({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.threshold = 50.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });
  
  @override
  State<SwipeEffect> createState() => _SwipeEffectState();
}

class _SwipeEffectState extends State<SwipeEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  
  Offset _startPosition = Offset.zero;
  Offset _currentOffset = Offset.zero;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onPanStart(DragStartDetails details) {
    _startPosition = details.localPosition;
    _controller.stop();
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentOffset = details.localPosition - _startPosition;
    });
  }
  
  void _onPanEnd(DragEndDetails details) {
    final delta = _currentOffset;
    
    if (delta.dx.abs() > widget.threshold) {
      if (delta.dx > 0 && widget.onSwipeRight != null) {
        widget.onSwipeRight!();
      } else if (delta.dx < 0 && widget.onSwipeLeft != null) {
        widget.onSwipeLeft!();
      }
    }
    
    if (delta.dy.abs() > widget.threshold) {
      if (delta.dy > 0 && widget.onSwipeDown != null) {
        widget.onSwipeDown!();
      } else if (delta.dy < 0 && widget.onSwipeUp != null) {
        widget.onSwipeUp!();
      }
    }
    
    _resetPosition();
  }
  
  void _resetPosition() {
    _offsetAnimation = Tween<Offset>(
      begin: _currentOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.reset();
    _controller.forward().then((_) {
      setState(() {
        _currentOffset = Offset.zero;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _offsetAnimation,
        builder: (context, child) {
          final offset = _controller.isAnimating 
              ? _offsetAnimation.value 
              : _currentOffset;
          
          return Transform.translate(
            offset: offset,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// 摇摆动画组件
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shouldShake;
  final Duration duration;
  final double offset;
  
  const ShakeWidget({
    super.key,
    required this.child,
    this.shouldShake = false,
    this.duration = const Duration(milliseconds: 500),
    this.offset = 5.0,
  });
  
  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));
  }
  
  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _startShake();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _startShake() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(widget.offset * _animation.value, 0),
          child: widget.child,
        );
      },
    );
  }
}
