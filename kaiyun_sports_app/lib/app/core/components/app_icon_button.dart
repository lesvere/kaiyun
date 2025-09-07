import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 通用图标按钮组件 - 提供多种样式和功能的图标按钮
/// 支持圆形、方形、圆角方形等多种形状和样式
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonType type;
  final AppIconButtonSize size;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final bool enabled;
  final String? tooltip;
  final EdgeInsets? padding;
  final double? iconSize;
  final bool badge;
  final int badgeCount;
  final Color? badgeColor;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.type = AppIconButtonType.standard,
    this.size = AppIconButtonSize.medium,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.enabled = true,
    this.tooltip,
    this.padding,
    this.iconSize,
    this.badge = false,
    this.badgeCount = 0,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = _buildButton(context);

    if (badge) {
      button = _buildBadgeButton(button);
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButton(BuildContext context) {
    final buttonSize = _getButtonSize();
    final iconSize = this.iconSize ?? _getIconSize();
    final padding = this.padding ?? _getPadding();

    switch (type) {
      case AppIconButtonType.circular:
        return _buildCircularButton(buttonSize, iconSize, padding);
      case AppIconButtonType.square:
        return _buildSquareButton(buttonSize, iconSize, padding);
      case AppIconButtonType.rounded:
        return _buildRoundedButton(buttonSize, iconSize, padding);
      case AppIconButtonType.outlined:
        return _buildOutlinedButton(buttonSize, iconSize, padding);
      case AppIconButtonType.filled:
        return _buildFilledButton(buttonSize, iconSize, padding);
      case AppIconButtonType.elevated:
        return _buildElevatedButton(buttonSize, iconSize, padding);
      case AppIconButtonType.gradient:
        return _buildGradientButton(buttonSize, iconSize, padding);
      default:
        return _buildStandardButton(iconSize, padding);
    }
  }

  /// 标准图标按钮 - 无背景
  Widget _buildStandardButton(double iconSize, EdgeInsets padding) {
    return IconButton(
      icon: Icon(icon),
      onPressed: enabled ? onPressed : null,
      color: color ?? AppColors.primary,
      disabledColor: AppColors.textDisabled,
      iconSize: iconSize,
      padding: padding,
    );
  }

  /// 圆形图标按钮
  Widget _buildCircularButton(double buttonSize, double iconSize, EdgeInsets padding) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth ?? 1,
              )
            : null,
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
        color: color ?? Colors.white,
        disabledColor: AppColors.textDisabled,
        iconSize: iconSize,
        padding: padding,
      ),
    );
  }

  /// 方形图标按钮
  Widget _buildSquareButton(double buttonSize, double iconSize, EdgeInsets padding) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth ?? 1,
              )
            : null,
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
        color: color ?? Colors.white,
        disabledColor: AppColors.textDisabled,
        iconSize: iconSize,
        padding: padding,
      ),
    );
  }

  /// 圆角方形图标按钮
  Widget _buildRoundedButton(double buttonSize, double iconSize, EdgeInsets padding) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth ?? 1,
              )
            : null,
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
        color: color ?? Colors.white,
        disabledColor: AppColors.textDisabled,
        iconSize: iconSize,
        padding: padding,
      ),
    );
  }

  /// 轮廓图标按钮
  Widget _buildOutlinedButton(double buttonSize, double iconSize, EdgeInsets padding) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? AppColors.primary,
          width: borderWidth ?? 2,
        ),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
        color: color ?? AppColors.primary,
        disabledColor: AppColors.textDisabled,
        iconSize: iconSize,
        padding: padding,
      ),
    );
  }

  /// 填充图标按钮
  Widget _buildFilledButton(double buttonSize, double iconSize, EdgeInsets padding) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth ?? 1,
              )
            : null,
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
        color: color ?? AppColors.textPrimary,
        disabledColor: AppColors.textDisabled,
        iconSize: iconSize,
        padding: padding,
      ),
    );
  }

  /// 浮动图标按钮
  Widget _buildElevatedButton(double buttonSize, double iconSize, EdgeInsets padding) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth ?? 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppColors.primary).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
        color: color ?? Colors.white,
        disabledColor: AppColors.textDisabled,
        iconSize: iconSize,
        padding: padding,
      ),
    );
  }

  /// 渐变图标按钮
  Widget _buildGradientButton(double buttonSize, double iconSize, EdgeInsets padding) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.blueGradientStart,
            AppColors.blueGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(24, 144, 255, 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
        color: color ?? Colors.white,
        disabledColor: AppColors.textDisabled,
        iconSize: iconSize,
        padding: padding,
      ),
    );
  }

  /// 构建带徽章的按钮
  Widget _buildBadgeButton(Widget button) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        if (badgeCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  /// 获取按钮尺寸
  double _getButtonSize() {
    switch (size) {
      case AppIconButtonSize.small:
        return 32;
      case AppIconButtonSize.medium:
        return 48;
      case AppIconButtonSize.large:
        return 56;
    }
  }

  /// 获取图标尺寸
  double _getIconSize() {
    switch (size) {
      case AppIconButtonSize.small:
        return 16;
      case AppIconButtonSize.medium:
        return 24;
      case AppIconButtonSize.large:
        return 28;
    }
  }

  /// 获取内边距
  EdgeInsets _getPadding() {
    switch (size) {
      case AppIconButtonSize.small:
        return const EdgeInsets.all(6);
      case AppIconButtonSize.medium:
        return const EdgeInsets.all(12);
      case AppIconButtonSize.large:
        return const EdgeInsets.all(14);
    }
  }
}

/// 图标按钮类型枚举
enum AppIconButtonType {
  standard,  // 标准样式
  circular,  // 圆形
  square,    // 方形
  rounded,   // 圆角方形
  outlined,  // 轮廓
  filled,    // 填充
  elevated,  // 浮动
  gradient,  // 渐变
}

/// 图标按钮尺寸枚举
enum AppIconButtonSize {
  small,   // 小尺寸
  medium,  // 中等尺寸
  large,   // 大尺寸
}

/// 预定义的图标按钮样式
class AppIconButtonStyles {
  /// 通知按钮 - 带徽章
  static AppIconButton notification({
    Key? key,
    VoidCallback? onPressed,
    int count = 0,
    Color? color,
  }) {
    return AppIconButton(
      key: key,
      icon: Icons.notifications_outlined,
      onPressed: onPressed,
      type: AppIconButtonType.standard,
      color: color ?? Colors.white,
      badge: count > 0,
      badgeCount: count,
    );
  }

  /// 搜索按钮
  static AppIconButton search({
    Key? key,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return AppIconButton(
      key: key,
      icon: Icons.search,
      onPressed: onPressed,
      type: AppIconButtonType.standard,
      color: color ?? Colors.white,
    );
  }

  /// 返回按钮
  static AppIconButton back({
    Key? key,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return AppIconButton(
      key: key,
      icon: Icons.arrow_back_ios,
      onPressed: onPressed,
      type: AppIconButtonType.standard,
      color: color ?? AppColors.textPrimary,
    );
  }

  /// 更多按钮
  static AppIconButton more({
    Key? key,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return AppIconButton(
      key: key,
      icon: Icons.more_vert,
      onPressed: onPressed,
      type: AppIconButtonType.standard,
      color: color ?? AppColors.textPrimary,
    );
  }

  /// 关闭按钮
  static AppIconButton close({
    Key? key,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return AppIconButton(
      key: key,
      icon: Icons.close,
      onPressed: onPressed,
      type: AppIconButtonType.circular,
      size: AppIconButtonSize.small,
      backgroundColor: AppColors.buttonGray,
      color: color ?? AppColors.textPrimary,
    );
  }

  /// 添加按钮 - 浮动样式
  static AppIconButton add({
    Key? key,
    VoidCallback? onPressed,
    Color? backgroundColor,
  }) {
    return AppIconButton(
      key: key,
      icon: Icons.add,
      onPressed: onPressed,
      type: AppIconButtonType.circular,
      size: AppIconButtonSize.large,
      backgroundColor: backgroundColor ?? AppColors.primary,
      color: Colors.white,
    );
  }

  /// 收藏按钮 - 可切换状态
  static AppIconButton favorite({
    Key? key,
    VoidCallback? onPressed,
    bool isFavorited = false,
    Color? color,
  }) {
    return AppIconButton(
      key: key,
      icon: isFavorited ? Icons.favorite : Icons.favorite_border,
      onPressed: onPressed,
      type: AppIconButtonType.standard,
      color: isFavorited ? AppColors.error : (color ?? AppColors.textSecondary),
    );
  }

  /// 分享按钮
  static AppIconButton share({
    Key? key,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return AppIconButton(
      key: key,
      icon: Icons.share_outlined,
      onPressed: onPressed,
      type: AppIconButtonType.outlined,
      borderColor: color ?? AppColors.primary,
      color: color ?? AppColors.primary,
    );
  }

  /// 设置按钮
  static AppIconButton settings({
    Key? key,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return AppIconButton(
      key: key,
      icon: Icons.settings_outlined,
      onPressed: onPressed,
      type: AppIconButtonType.filled,
      color: color ?? AppColors.textPrimary,
    );
  }

  /// 刷新按钮
  static AppIconButton refresh({
    Key? key,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return AppIconButton(
      key: key,
      icon: Icons.refresh,
      onPressed: onPressed,
      type: AppIconButtonType.standard,
      color: color ?? AppColors.primary,
    );
  }

  /// 编辑按钮
  static AppIconButton edit({
    Key? key,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return AppIconButton(
      key: key,
      icon: Icons.edit_outlined,
      onPressed: onPressed,
      type: AppIconButtonType.rounded,
      backgroundColor: AppColors.sectionBackground,
      color: color ?? AppColors.textPrimary,
    );
  }

  /// 删除按钮
  static AppIconButton delete({
    Key? key,
    VoidCallback? onPressed,
  }) {
    return AppIconButton(
      key: key,
      icon: Icons.delete_outline,
      onPressed: onPressed,
      type: AppIconButtonType.rounded,
      backgroundColor: AppColors.error.withOpacity(0.1),
      color: AppColors.error,
    );
  }
}
