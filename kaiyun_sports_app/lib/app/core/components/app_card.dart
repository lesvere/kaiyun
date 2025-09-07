import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 通用卡片组件 - 提供多种样式和功能的卡片容器
/// 支持阴影、渐变、边框等多种视觉效果
class AppCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final AppCardType type;
  final bool enabled;
  final double elevation;

  const AppCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.gradient,
    this.boxShadow,
    this.border,
    this.width,
    this.height,
    this.onTap,
    this.type = AppCardType.standard,
    this.enabled = true,
    this.elevation = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? _getDefaultMargin(),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final decoration = _buildDecoration();
    final cardChild = Container(
      padding: padding ?? _getDefaultPadding(),
      decoration: decoration,
      child: child,
    );

    if (onTap != null && enabled) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardChild,
        ),
      );
    }

    return cardChild;
  }

  BoxDecoration _buildDecoration() {
    switch (type) {
      case AppCardType.elevated:
        return _buildElevatedDecoration();
      case AppCardType.outlined:
        return _buildOutlinedDecoration();
      case AppCardType.filled:
        return _buildFilledDecoration();
      case AppCardType.gradient:
        return _buildGradientDecoration();
      case AppCardType.financial:
        return _buildFinancialDecoration();
      case AppCardType.vip:
        return _buildVipDecoration();
      case AppCardType.benefit:
        return _buildBenefitDecoration();
      default:
        return _buildStandardDecoration();
    }
  }

  /// 标准卡片样式
  BoxDecoration _buildStandardDecoration() {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: boxShadow ?? _getDefaultShadow(),
    );
  }

  /// 浮动卡片样式 - 更明显的阴影
  BoxDecoration _buildElevatedDecoration() {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: boxShadow ?? _getElevatedShadow(),
    );
  }

  /// 轮廓卡片样式 - 边框，无阴影
  BoxDecoration _buildOutlinedDecoration() {
    return BoxDecoration(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(
        color: AppColors.border,
        width: 1.5,
      ),
    );
  }

  /// 填充卡片样式 - 背景色，无阴影
  BoxDecoration _buildFilledDecoration() {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.sectionBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
    );
  }

  /// 渐变卡片样式
  BoxDecoration _buildGradientDecoration() {
    return BoxDecoration(
      gradient: gradient ?? _getDefaultGradient(),
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: boxShadow ?? _getDefaultShadow(),
    );
  }

  /// 金融卡片样式 - 专业的金融应用风格
  BoxDecoration _buildFinancialDecoration() {
    return BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(
        color: AppColors.primary.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: boxShadow ?? const [
        BoxShadow(
          color: Color.fromRGBO(24, 144, 255, 0.08),
          blurRadius: 16,
          offset: Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.04),
          blurRadius: 4,
          offset: Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// VIP卡片样式 - 金色渐变
  BoxDecoration _buildVipDecoration() {
    return BoxDecoration(
      gradient: gradient ?? const LinearGradient(
        colors: [
          AppColors.vipGold,
          AppColors.vipGoldDark,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: boxShadow ?? const [
        BoxShadow(
          color: Color.fromRGBO(212, 175, 55, 0.3),
          blurRadius: 16,
          offset: Offset(0, 8),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// 福利中心卡片样式 - 蓝色渐变
  BoxDecoration _buildBenefitDecoration() {
    return BoxDecoration(
      gradient: gradient ?? const LinearGradient(
        colors: [
          AppColors.benefitBlue,
          AppColors.primary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: boxShadow ?? const [
        BoxShadow(
          color: Color.fromRGBO(77, 182, 248, 0.3),
          blurRadius: 16,
          offset: Offset(0, 8),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// 获取默认内边距
  EdgeInsets _getDefaultPadding() {
    switch (type) {
      case AppCardType.financial:
        return const EdgeInsets.all(20);
      case AppCardType.vip:
      case AppCardType.benefit:
        return const EdgeInsets.all(16);
      default:
        return const EdgeInsets.all(16);
    }
  }

  /// 获取默认外边距
  EdgeInsets _getDefaultMargin() {
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }

  /// 获取默认阴影
  List<BoxShadow> _getDefaultShadow() {
    return const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.08),
        blurRadius: 8,
        offset: Offset(0, 2),
        spreadRadius: 0,
      ),
    ];
  }

  /// 获取浮动阴影
  List<BoxShadow> _getElevatedShadow() {
    return const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.12),
        blurRadius: 16,
        offset: Offset(0, 4),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.08),
        blurRadius: 8,
        offset: Offset(0, 2),
        spreadRadius: 0,
      ),
    ];
  }

  /// 获取默认渐变
  Gradient _getDefaultGradient() {
    return const LinearGradient(
      colors: [
        AppColors.blueGradientStart,
        AppColors.blueGradientEnd,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

/// 卡片类型枚举
enum AppCardType {
  standard,   // 标准卡片
  elevated,   // 浮动卡片
  outlined,   // 轮廓卡片
  filled,     // 填充卡片
  gradient,   // 渐变卡片
  financial,  // 金融卡片
  vip,        // VIP卡片
  benefit,    // 福利中心卡片
}

/// 预定义的卡片样式
class AppCardStyles {
  /// 信息卡片 - 显示重要信息
  static AppCard info({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppCard(
      key: key,
      type: AppCardType.standard,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// 功能卡片 - 用于功能入口
  static AppCard feature({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppCard(
      key: key,
      type: AppCardType.elevated,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// 数据卡片 - 显示数据统计
  static AppCard data({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppCard(
      key: key,
      type: AppCardType.financial,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// 促销卡片 - 用于活动推广
  static AppCard promotion({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool isBenefit = false,
  }) {
    return AppCard(
      key: key,
      type: isBenefit ? AppCardType.benefit : AppCardType.gradient,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// VIP卡片 - 用于VIP功能
  static AppCard vip({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppCard(
      key: key,
      type: AppCardType.vip,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// 列表项卡片 - 用于列表项
  static AppCard listItem({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppCard(
      key: key,
      type: AppCardType.filled,
      padding: padding ?? const EdgeInsets.all(12),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      child: child,
    );
  }

  /// 设置项卡片 - 用于设置页面
  static AppCard setting({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppCard(
      key: key,
      type: AppCardType.outlined,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }
}

/// 卡片内容组件 - 用于构建标准化的卡片内容
class AppCardContent extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? description;
  final Widget? leading;
  final Widget? trailing;
  final Widget? custom;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const AppCardContent({
    super.key,
    this.title,
    this.subtitle,
    this.description,
    this.leading,
    this.trailing,
    this.custom,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (custom != null) return custom!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}
