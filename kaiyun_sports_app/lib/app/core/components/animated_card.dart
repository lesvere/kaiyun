import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// 动画卡片组件
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final bool enableHover;
  final bool enableScale;
  final bool enableShadow;
  final Duration animationDuration;
  final Curve curve;
  final BoxBorder? border;
  final List<BoxShadow>? customShadows;
  
  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.elevation = 2,
    this.enableHover = true,
    this.enableScale = true,
    this.enableShadow = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.border,
    this.customShadows,
  });
  
  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shadowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _shadowController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: widget.curve,
    ));
    
    _shadowAnimation = Tween<double>(
      begin: widget.elevation,
      end: _isHovered ? widget.elevation * 2 : widget.elevation,
    ).animate(CurvedAnimation(
      parent: _shadowController,
      curve: widget.curve,
    ));
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _shadowController.dispose();
    super.dispose();
  }
  
  void _updateAnimations() {
    _scaleAnimation = Tween<double>(
      begin: _scaleAnimation.value,
      end: _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: widget.curve,
    ));
    
    _shadowAnimation = Tween<double>(
      begin: _shadowAnimation.value,
      end: _isHovered ? widget.elevation * 2 : widget.elevation,
    ).animate(CurvedAnimation(
      parent: _shadowController,
      curve: widget.curve,
    ));
    
    _scaleController.reset();
    _scaleController.forward();
    _shadowController.reset();
    _shadowController.forward();
  }
  
  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = true;
      });
      _updateAnimations();
      
      // 触觉反馈
      HapticFeedback.lightImpact();
    }
  }
  
  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
      _updateAnimations();
      
      widget.onTap!();
    }
  }
  
  void _onTapCancel() {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
      _updateAnimations();
    }
  }
  
  void _onHover(bool hovered) {
    if (widget.enableHover && widget.onTap != null) {
      setState(() {
        _isHovered = hovered;
      });
      _updateAnimations();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _shadowAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: widget.enableScale ? _scaleAnimation.value : 1.0,
              child: Container(
                margin: widget.margin,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? AppColors.surface,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: widget.border,
                  boxShadow: widget.enableShadow 
                    ? (widget.customShadows ?? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: _shadowAnimation.value * 2,
                          offset: Offset(0, _shadowAnimation.value),
                        ),
                      ])
                    : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Padding(
                    padding: widget.padding ?? EdgeInsets.zero,
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 动画列表项组件
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final VoidCallback? onTap;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Duration delay;
  final Duration duration;
  
  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.onTap,
    this.showDivider = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.backgroundColor,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
  });
  
  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    // 延迟启动动画
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                Material(
                  color: widget.backgroundColor ?? Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    child: Padding(
                      padding: widget.padding ?? EdgeInsets.zero,
                      child: widget.child,
                    ),
                  ),
                ),
                if (widget.showDivider)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 悬浮动作按钮增强版
class AnimatedFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool mini;
  final String? tooltip;
  final String? heroTag;
  
  const AnimatedFloatingActionButton({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 6.0,
    this.mini = false,
    this.tooltip,
    this.heroTag,
  });
  
  @override
  State<AnimatedFloatingActionButton> createState() => _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState extends State<AnimatedFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }
  
  void _onPressed() {
    if (widget.onPressed != null) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
      _rotateController.forward().then((_) {
        _rotateController.reverse();
      });
      
      HapticFeedback.mediumImpact();
      widget.onPressed!();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotateAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: FloatingActionButton(
              onPressed: _onPressed,
              backgroundColor: widget.backgroundColor,
              foregroundColor: widget.foregroundColor,
              elevation: widget.elevation,
              mini: widget.mini,
              tooltip: widget.tooltip,
              heroTag: widget.heroTag,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
