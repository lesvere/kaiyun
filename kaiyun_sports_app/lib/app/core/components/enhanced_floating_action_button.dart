import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// 增强版悬浮操作按钮 - 支持多种动画和交互效果
class EnhancedFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final String? tooltip;
  final bool mini;
  final String? heroTag;
  final FloatingActionButtonType type;
  final Duration animationDuration;
  final bool enablePulseAnimation;
  final bool enableRotationAnimation;
  final bool enableScaleAnimation;
  final List<FloatingActionButtonAction>? actions;
  final bool isExpanded;
  
  const EnhancedFloatingActionButton({
    super.key,
    this.onPressed,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.tooltip,
    this.mini = false,
    this.heroTag,
    this.type = FloatingActionButtonType.normal,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enablePulseAnimation = false,
    this.enableRotationAnimation = false,
    this.enableScaleAnimation = true,
    this.actions,
    this.isExpanded = false,
  });
  
  @override
  State<EnhancedFloatingActionButton> createState() => _EnhancedFloatingActionButtonState();
}

class _EnhancedFloatingActionButtonState extends State<EnhancedFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _expandController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _expandAnimation;
  
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _initAnimations();
  }
  
  void _initAnimations() {
    // 缩放动画控制器
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    
    // 旋转动画控制器
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    
    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // 展开动画控制器
    _expandController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
    
    // 启动脉冲动画
    if (widget.enablePulseAnimation) {
      _startPulseAnimation();
    }
    
    // 处理展开状态
    if (widget.isExpanded) {
      _expandController.forward();
    }
  }
  
  @override
  void didUpdateWidget(EnhancedFloatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _expandController.dispose();
    super.dispose();
  }
  
  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }
  
  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _isPressed = true;
      });
      
      if (widget.enableScaleAnimation) {
        _scaleController.forward();
      }
      
      if (widget.enableRotationAnimation) {
        _rotationController.forward();
      }
      
      HapticFeedback.mediumImpact();
    }
  }
  
  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _isPressed = false;
      });
      
      if (widget.enableScaleAnimation) {
        _scaleController.reverse();
      }
      
      if (widget.enableRotationAnimation) {
        _rotationController.reverse();
      }
      
      widget.onPressed!();
    }
  }
  
  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    
    if (widget.enableScaleAnimation) {
      _scaleController.reverse();
    }
    
    if (widget.enableRotationAnimation) {
      _rotationController.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case FloatingActionButtonType.expandable:
        return _buildExpandableFAB();
      case FloatingActionButtonType.morphing:
        return _buildMorphingFAB();
      default:
        return _buildNormalFAB();
    }
  }
  
  Widget _buildNormalFAB() {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _rotationAnimation,
          _pulseAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enablePulseAnimation 
                ? _pulseAnimation.value * _scaleAnimation.value
                : _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: FloatingActionButton(
                onPressed: null, // 由GestureDetector处理
                backgroundColor: widget.backgroundColor ?? AppColors.primary,
                foregroundColor: widget.foregroundColor ?? Colors.white,
                elevation: widget.elevation ?? 6,
                mini: widget.mini,
                heroTag: widget.heroTag,
                tooltip: widget.tooltip,
                child: widget.child ?? const Icon(Icons.add),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildExpandableFAB() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // 子按钮
        if (widget.actions != null)
          ...widget.actions!.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                final offset = (index + 1) * 70.0 * _expandAnimation.value;
                return Transform.translate(
                  offset: Offset(0, -offset),
                  child: Transform.scale(
                    scale: _expandAnimation.value,
                    child: Opacity(
                      opacity: _expandAnimation.value,
                      child: FloatingActionButton(
                        onPressed: action.onPressed,
                        backgroundColor: action.backgroundColor ?? AppColors.secondary,
                        foregroundColor: action.foregroundColor ?? Colors.white,
                        mini: true,
                        heroTag: 'fab_${action.label}',
                        tooltip: action.label,
                        child: Icon(action.icon),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        
        // 主按钮
        _buildNormalFAB(),
      ],
    );
  }
  
  Widget _buildMorphingFAB() {
    return AnimatedContainer(
      duration: widget.animationDuration,
      width: widget.isExpanded ? 200 : 56,
      height: 56,
      child: FloatingActionButton.extended(
        onPressed: widget.onPressed,
        backgroundColor: widget.backgroundColor ?? AppColors.primary,
        foregroundColor: widget.foregroundColor ?? Colors.white,
        elevation: widget.elevation ?? 6,
        heroTag: widget.heroTag,
        tooltip: widget.tooltip,
        icon: widget.child ?? const Icon(Icons.add),
        label: widget.isExpanded 
            ? const Text('快速存款')
            : const SizedBox.shrink(),
      ),
    );
  }
}

/// FAB类型枚举
enum FloatingActionButtonType {
  normal,
  expandable,
  morphing,
}

/// FAB操作项
class FloatingActionButtonAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  
  const FloatingActionButtonAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
}

/// 预定义的FAB样式
class EnhancedFABStyles {
  /// 快速存款按钮
  static EnhancedFloatingActionButton quickDeposit({
    required VoidCallback onPressed,
  }) {
    return EnhancedFloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.success,
      child: const Icon(Icons.account_balance_wallet),
      tooltip: '快速存款',
      enableScaleAnimation: true,
      enablePulseAnimation: true,
    );
  }
  
  /// 可展开菜单按钮
  static EnhancedFloatingActionButton expandableMenu({
    required VoidCallback onPressed,
    required bool isExpanded,
    List<FloatingActionButtonAction>? actions,
  }) {
    return EnhancedFloatingActionButton(
      onPressed: onPressed,
      type: FloatingActionButtonType.expandable,
      isExpanded: isExpanded,
      actions: actions ?? [
        FloatingActionButtonAction(
          icon: Icons.account_balance_wallet,
          label: '存款',
          onPressed: () {},
          backgroundColor: AppColors.success,
        ),
        FloatingActionButtonAction(
          icon: Icons.swap_horiz,
          label: '转账',
          onPressed: () {},
          backgroundColor: AppColors.info,
        ),
        FloatingActionButtonAction(
          icon: Icons.money,
          label: '取款',
          onPressed: () {},
          backgroundColor: AppColors.warning,
        ),
      ],
      child: Icon(
        isExpanded ? Icons.close : Icons.menu,
      ),
      enableRotationAnimation: true,
      tooltip: isExpanded ? '关闭菜单' : '打开菜单',
    );
  }
  
  /// 变形按钮
  static EnhancedFloatingActionButton morphing({
    required VoidCallback onPressed,
    required bool isExpanded,
  }) {
    return EnhancedFloatingActionButton(
      onPressed: onPressed,
      type: FloatingActionButtonType.morphing,
      isExpanded: isExpanded,
      child: const Icon(Icons.add),
      tooltip: '快速操作',
    );
  }
}
