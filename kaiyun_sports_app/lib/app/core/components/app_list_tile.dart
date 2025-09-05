import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 通用列表项组件 - 提供多种样式和功能的列表项
/// 支持图标、头像、徽章、开关、箭头等多种元素组合
class AppListTile extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? description;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final AppListTileType type;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final bool enabled;
  final bool selected;
  final bool dense;
  final bool threeLine;
  final Widget? custom;

  const AppListTile({
    Key? key,
    this.title,
    this.subtitle,
    this.description,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.type = AppListTileType.standard,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.enabled = true,
    this.selected = false,
    this.dense = false,
    this.threeLine = false,
    this.custom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (custom != null) {
      return _buildContainer(context, custom!);
    }

    return _buildContainer(context, _buildListTile(context));
  }

  Widget _buildContainer(BuildContext context, Widget child) {
    final containerChild = Container(
      margin: margin ?? _getDefaultMargin(),
      decoration: _buildDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: child,
        ),
      ),
    );

    return containerChild;
  }

  Widget _buildListTile(BuildContext context) {
    switch (type) {
      case AppListTileType.card:
        return _buildCardTile(context);
      case AppListTileType.setting:
        return _buildSettingTile(context);
      case AppListTileType.user:
        return _buildUserTile(context);
      case AppListTileType.financial:
        return _buildFinancialTile(context);
      case AppListTileType.menu:
        return _buildMenuTile(context);
      default:
        return _buildStandardTile(context);
    }
  }

  /// 标准列表项
  Widget _buildStandardTile(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title != null ? _buildTitle(context) : null,
      subtitle: _buildSubtitle(context),
      trailing: trailing,
      contentPadding: padding ?? _getDefaultPadding(),
      enabled: enabled,
      selected: selected,
      dense: dense,
      isThreeLine: threeLine,
    );
  }

  /// 卡片样式列表项
  Widget _buildCardTile(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) _buildTitle(context),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  _buildSubtitle(context),
                ],
                if (description != null) ...[
                  const SizedBox(height: 8),
                  _buildDescription(context),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }

  /// 设置样式列表项
  Widget _buildSettingTile(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (leading != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: leading!,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) _buildTitle(context),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  _buildSubtitle(context, color: AppColors.textSecondary),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ] else ...[
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.iconGray,
            ),
          ],
        ],
      ),
    );
  }

  /// 用户样式列表项
  Widget _buildUserTile(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Row(
        children: [
          if (leading != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: 48,
                height: 48,
                child: leading!,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) 
                  _buildTitle(context, fontWeight: FontWeight.w600),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  _buildSubtitle(context, color: AppColors.textSecondary),
                ],
                if (description != null) ...[
                  const SizedBox(height: 4),
                  _buildDescription(context),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }

  /// 金融样式列表项
  Widget _buildFinancialTile(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: leading!,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) 
                  _buildTitle(context, fontWeight: FontWeight.w600),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  _buildSubtitle(context, color: AppColors.primary),
                ],
                if (description != null) ...[
                  const SizedBox(height: 4),
                  _buildDescription(context, fontSize: 12),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }

  /// 菜单样式列表项
  Widget _buildMenuTile(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: _buildTitle(context, fontSize: 16),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing!,
          ] else ...[
            const SizedBox(width: 16),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.iconGray,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return Text(
      title!,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color ?? (enabled ? AppColors.textPrimary : AppColors.textDisabled),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, {Color? color}) {
    if (subtitle == null) return const SizedBox.shrink();
    
    return Text(
      subtitle!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: color ?? AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDescription(BuildContext context, {double? fontSize}) {
    if (description == null) return const SizedBox.shrink();
    
    return Text(
      description!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: fontSize,
        color: AppColors.textSecondary,
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    Color bgColor;
    
    switch (type) {
      case AppListTileType.card:
        bgColor = backgroundColor ?? AppColors.cardBackground;
        break;
      case AppListTileType.setting:
      case AppListTileType.menu:
        bgColor = backgroundColor ?? Colors.transparent;
        break;
      case AppListTileType.financial:
        bgColor = backgroundColor ?? Colors.white;
        break;
      default:
        bgColor = backgroundColor ?? (selected ? AppColors.primary.withOpacity(0.1) : Colors.transparent);
    }

    List<BoxShadow>? shadows;
    if (type == AppListTileType.card || type == AppListTileType.financial) {
      shadows = [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows,
    );
  }

  EdgeInsets _getDefaultPadding() {
    switch (type) {
      case AppListTileType.card:
        return const EdgeInsets.all(16);
      case AppListTileType.setting:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case AppListTileType.user:
        return const EdgeInsets.all(16);
      case AppListTileType.financial:
        return const EdgeInsets.all(16);
      case AppListTileType.menu:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
      default:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  EdgeInsets _getDefaultMargin() {
    switch (type) {
      case AppListTileType.card:
      case AppListTileType.financial:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 4);
      default:
        return EdgeInsets.zero;
    }
  }
}

/// 列表项类型枚举
enum AppListTileType {
  standard,   // 标准样式
  card,       // 卡片样式
  setting,    // 设置样式
  user,       // 用户样式
  financial,  // 金融样式
  menu,       // 菜单样式
}

/// 预定义的列表项样式
class AppListTileStyles {
  /// 设置项 - 图标 + 标题 + 箭头
  static AppListTile setting({
    Key? key,
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return AppListTile(
      key: key,
      type: AppListTileType.setting,
      title: title,
      subtitle: subtitle,
      leading: icon != null 
        ? Icon(icon, color: AppColors.primary, size: 20)
        : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// 用户信息项 - 头像 + 姓名 + 状态
  static AppListTile user({
    Key? key,
    required String name,
    String? status,
    String? description,
    Widget? avatar,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return AppListTile(
      key: key,
      type: AppListTileType.user,
      title: name,
      subtitle: status,
      description: description,
      leading: avatar ?? CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(Icons.person, color: AppColors.primary),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// 交易记录项 - 图标 + 交易信息 + 金额
  static AppListTile transaction({
    Key? key,
    required String title,
    required String amount,
    String? time,
    IconData? icon,
    Color? amountColor,
    VoidCallback? onTap,
  }) {
    return AppListTile(
      key: key,
      type: AppListTileType.financial,
      title: title,
      subtitle: time,
      leading: icon != null 
        ? Icon(icon, color: AppColors.primary)
        : null,
      trailing: Text(
        amount,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: amountColor ?? AppColors.primary,
        ),
      ),
      onTap: onTap,
    );
  }

  /// 功能菜单项 - 图标 + 标题 + 描述 + 箭头
  static AppListTile menu({
    Key? key,
    required String title,
    String? description,
    IconData? icon,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return AppListTile(
      key: key,
      type: AppListTileType.menu,
      title: title,
      description: description,
      leading: icon != null 
        ? Icon(icon, color: iconColor ?? AppColors.primary)
        : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// 通知项 - 圆点 + 标题 + 时间 + 徽章
  static AppListTile notification({
    Key? key,
    required String title,
    String? content,
    String? time,
    bool isRead = false,
    VoidCallback? onTap,
  }) {
    return AppListTile(
      key: key,
      type: AppListTileType.card,
      title: title,
      subtitle: content,
      description: time,
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: isRead ? AppColors.iconGray : AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
      trailing: !isRead ? Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
      ) : null,
      onTap: onTap,
    );
  }

  /// 开关设置项
  static AppListTile toggle({
    Key? key,
    required String title,
    String? subtitle,
    IconData? icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AppListTile(
      key: key,
      type: AppListTileType.setting,
      title: title,
      subtitle: subtitle,
      leading: icon != null 
        ? Icon(icon, color: AppColors.primary, size: 20)
        : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      onTap: () => onChanged(!value),
    );
  }

  /// 链接项 - 外部链接或内部导航
  static AppListTile link({
    Key? key,
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return AppListTile(
      key: key,
      type: AppListTileType.standard,
      title: title,
      subtitle: subtitle,
      leading: icon != null 
        ? Icon(icon, color: AppColors.textSecondary)
        : null,
      trailing: trailing ?? const Icon(
        Icons.open_in_new,
        size: 16,
        color: AppColors.iconGray,
      ),
      onTap: onTap,
    );
  }
}
