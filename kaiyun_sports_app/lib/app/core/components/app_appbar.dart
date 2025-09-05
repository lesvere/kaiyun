import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// 通用应用栏组件 - 提供多种样式和功能的导航栏
/// 支持渐变背景、搜索框、多种操作按钮等
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final VoidCallback? onLeadingPressed;
  final AppAppBarType type;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double elevation;
  final bool centerTitle;
  final double? leadingWidth;
  final double toolbarHeight;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool showBackButton;
  final String? backButtonText;
  final Color? foregroundColor;
  final bool showBorder;
  final bool transparent;

  const AppAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onLeadingPressed,
    this.type = AppAppBarType.standard,
    this.backgroundColor,
    this.gradient,
    this.elevation = 0,
    this.centerTitle = true,
    this.leadingWidth,
    this.toolbarHeight = kToolbarHeight,
    this.systemOverlayStyle,
    this.showBackButton = false,
    this.backButtonText,
    this.foregroundColor,
    this.showBorder = false,
    this.transparent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildDecoration(),
      child: AppBar(
        title: titleWidget ?? (title != null ? _buildTitle(context) : null),
        actions: actions,
        leading: _buildLeading(context),
        automaticallyImplyLeading: automaticallyImplyLeading && leading == null,
        backgroundColor: transparent ? Colors.transparent : _getBackgroundColor(),
        foregroundColor: foregroundColor ?? _getForegroundColor(),
        elevation: elevation,
        scrolledUnderElevation: elevation,
        centerTitle: centerTitle,
        leadingWidth: leadingWidth,
        toolbarHeight: toolbarHeight,
        systemOverlayStyle: systemOverlayStyle ?? _getSystemOverlayStyle(),
        shape: showBorder ? const Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ) : null,
      ),
    );
  }

  BoxDecoration? _buildDecoration() {
    if (transparent) return null;
    
    switch (type) {
      case AppAppBarType.gradient:
        return BoxDecoration(
          gradient: gradient ?? _getDefaultGradient(),
        );
      case AppAppBarType.branded:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case AppAppBarType.financial:
        return BoxDecoration(
          color: backgroundColor ?? Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      default:
        return null;
    }
  }

  Widget _buildTitle(BuildContext context) {
    final textStyle = Theme.of(context).appBarTheme.titleTextStyle ??
        Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: _getForegroundColor(),
        );

    return Text(
      title!,
      style: textStyle,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    
    if (showBackButton || (Navigator.canPop(context) && automaticallyImplyLeading)) {
      return IconButton(
        icon: Icon(
          type == AppAppBarType.financial ? Icons.arrow_back_ios : Icons.arrow_back,
          color: _getForegroundColor(),
        ),
        onPressed: onLeadingPressed ?? () => Navigator.maybePop(context),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      );
    }
    
    return null;
  }

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;
    
    switch (type) {
      case AppAppBarType.standard:
        return AppColors.primary;
      case AppAppBarType.light:
        return Colors.white;
      case AppAppBarType.gradient:
      case AppAppBarType.branded:
        return Colors.transparent;
      case AppAppBarType.financial:
        return Colors.white;
      case AppAppBarType.transparent:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor() {
    if (foregroundColor != null) return foregroundColor!;
    
    switch (type) {
      case AppAppBarType.light:
      case AppAppBarType.financial:
        return AppColors.textPrimary;
      default:
        return Colors.white;
    }
  }

  Gradient _getDefaultGradient() {
    return LinearGradient(
      colors: [
        AppColors.blueGradientStart,
        AppColors.blueGradientEnd,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  SystemUiOverlayStyle _getSystemOverlayStyle() {
    switch (type) {
      case AppAppBarType.light:
      case AppAppBarType.financial:
        return SystemUiOverlayStyle.dark;
      default:
        return SystemUiOverlayStyle.light;
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}

/// 应用栏类型枚举
enum AppAppBarType {
  standard,    // 标准样式
  light,       // 浅色样式
  gradient,    // 渐变样式
  branded,     // 品牌样式
  financial,   // 金融样式
  transparent, // 透明样式
}

/// 预定义的应用栏样式
class AppAppBarStyles {
  /// 主页应用栏 - 品牌logo + 搜索 + 通知
  static AppAppBar home({
    Key? key,
    List<Widget>? actions,
    VoidCallback? onSearchTap,
    VoidCallback? onNotificationTap,
    int notificationCount = 0,
  }) {
    return AppAppBar(
      key: key,
      type: AppAppBarType.branded,
      titleWidget: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'KY',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '开云体育',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: actions ?? [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: onSearchTap,
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: onNotificationTap,
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 99 ? '99+' : notificationCount.toString(),
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
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// 搜索应用栏
  static AppAppBar search({
    Key? key,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onCancel,
    String hintText = '搜索...',
  }) {
    return AppAppBar(
      key: key,
      type: AppAppBarType.light,
      titleWidget: Container(
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.sectionBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.iconGray,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text(
            '取消',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// 详情页应用栏
  static AppAppBar detail({
    Key? key,
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) {
    return AppAppBar(
      key: key,
      title: title,
      type: AppAppBarType.standard,
      showBackButton: true,
      onLeadingPressed: onBackPressed,
      actions: actions,
    );
  }

  /// 金融页面应用栏 - 用于交易、存款等页面
  static AppAppBar financial({
    Key? key,
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showProgress = false,
    int currentStep = 1,
    int totalSteps = 1,
  }) {
    return AppAppBar(
      key: key,
      type: AppAppBarType.financial,
      showBorder: true,
      titleWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 4),
            Text(
              '$currentStep/$totalSteps',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
      showBackButton: true,
      onLeadingPressed: onBackPressed,
      actions: actions,
    );
  }

  /// 透明应用栏 - 用于全屏显示
  static AppAppBar transparent({
    Key? key,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    Color? foregroundColor,
  }) {
    return AppAppBar(
      key: key,
      type: AppAppBarType.transparent,
      transparent: true,
      showBackButton: true,
      onLeadingPressed: onBackPressed,
      foregroundColor: foregroundColor ?? Colors.white,
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }
}

/// 底部应用栏组件
class AppBottomAppBar extends StatelessWidget {
  final List<BottomAppBarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final double elevation;
  final bool showSelectedLabels;
  final bool showUnselectedLabels;

  const AppBottomAppBar({
    Key? key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.elevation = 8.0,
    this.showSelectedLabels = true,
    this.showUnselectedLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;
              
              return Expanded(
                child: InkWell(
                  onTap: () => onTap?.call(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? AppColors.primary : AppColors.iconGray,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        if ((isSelected && showSelectedLabels) || 
                            (!isSelected && showUnselectedLabels))
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// 底部应用栏项目
class BottomAppBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const BottomAppBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}
