import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../navigation/navigation_controller.dart';

/// 增强版底部导航栏 - 支持动画和交互反馈
class EnhancedBottomNavigation extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool enableAnimation;
  final Duration animationDuration;
  final bool enableHapticFeedback;
  final bool showBadge;
  final Map<int, int>? badgeCounts;
  
  const EnhancedBottomNavigation({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enableHapticFeedback = true,
    this.showBadge = false,
    this.badgeCounts,
  });
  
  @override
  State<EnhancedBottomNavigation> createState() => _EnhancedBottomNavigationState();
}

class _EnhancedBottomNavigationState extends State<EnhancedBottomNavigation> 
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _bounceAnimations;
  
  @override
  void initState() {
    super.initState();
    _initAnimations();
  }
  
  void _initAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );
    
    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();
    
    _bounceAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.bounceOut),
      );
    }).toList();
    
    // 初始化选中项动画
    if (widget.enableAnimation) {
      _animationControllers[widget.currentIndex].forward();
    }
  }
  
  @override
  void didUpdateWidget(EnhancedBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex && widget.enableAnimation) {
      // 重置之前的动画
      _animationControllers[oldWidget.currentIndex].reverse();
      // 开始新的动画
      _animationControllers[widget.currentIndex].forward();
    }
  }
  
  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  void _onItemTap(int index) {
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
    
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
    
    // 播放点击动画
    if (widget.enableAnimation) {
      _animationControllers[index].forward().then((_) {
        _animationControllers[index].reverse();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;
              
              return _buildNavItem(
                item: item,
                index: index,
                isSelected: isSelected,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem({
    required BottomNavItem item,
    required int index,
    required bool isSelected,
  }) {
    final selectedColor = widget.selectedItemColor ?? AppColors.primary;
    final unselectedColor = widget.unselectedItemColor ?? AppColors.iconGray;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTap(index),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimations[index],
            _bounceAnimations[index],
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? 1.0 + (_scaleAnimations[index].value * 0.1) : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 图标和徽章
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 选中背景
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.activeIcon ?? item.icon,
                              color: selectedColor,
                              size: 24,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              item.icon,
                              color: unselectedColor,
                              size: 24,
                            ),
                          ),
                        
                        // 徽章
                        if (widget.showBadge && 
                            widget.badgeCounts != null && 
                            widget.badgeCounts![index] != null &&
                            widget.badgeCounts![index]! > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: AnimatedScale(
                              scale: _bounceAnimations[index].value,
                              duration: widget.animationDuration,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  widget.badgeCounts![index]! > 99
                                      ? '99+'
                                      : widget.badgeCounts![index].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // 标签
                    AnimatedDefaultTextStyle(
                      style: TextStyle(
                        fontSize: isSelected ? 11 : 10,
                        color: isSelected ? selectedColor : unselectedColor,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      duration: widget.animationDuration,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // 选中指示器
                    AnimatedContainer(
                      duration: widget.animationDuration,
                      height: 2,
                      width: isSelected ? 20 : 0,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 底部导航项
class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final VoidCallback? onTap;
  
  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.onTap,
  });
}
