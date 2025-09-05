import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 通用按钮组件 - 提供多种样式和状态的按钮
/// 支持主要按钮、次要按钮、轮廓按钮、文本按钮等多种样式
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isEnabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final EdgeInsets? padding;
  final bool gradient;
  
  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.padding,
    this.gradient = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !isEnabled || onPressed == null || isLoading;
    
    return Container(
      width: width,
      child: _buildButton(context, isDisabled),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    switch (type) {
      case AppButtonType.primary:
        return _buildPrimaryButton(context, isDisabled);
      case AppButtonType.secondary:
        return _buildSecondaryButton(context, isDisabled);
      case AppButtonType.outline:
        return _buildOutlineButton(context, isDisabled);
      case AppButtonType.text:
        return _buildTextButton(context, isDisabled);
      case AppButtonType.danger:
        return _buildDangerButton(context, isDisabled);
      case AppButtonType.success:
        return _buildSuccessButton(context, isDisabled);
      case AppButtonType.vip:
        return _buildVipButton(context, isDisabled);
    }
  }

  /// 主要按钮 - 蓝色渐变背景
  Widget _buildPrimaryButton(BuildContext context, bool isDisabled) {
    return Container(
      decoration: gradient ? _buildGradientDecoration() : null,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: gradient ? Colors.transparent : AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.buttonGray,
          disabledForegroundColor: AppColors.textDisabled,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isDisabled ? 0 : 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ).copyWith(
          backgroundColor: gradient 
            ? MaterialStateProperty.all(Colors.transparent)
            : null,
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  /// 次要按钮 - 浅蓝色背景
  Widget _buildSecondaryButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryLight,
        foregroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.buttonGray,
        disabledForegroundColor: AppColors.textDisabled,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isDisabled ? 0 : 2,
      ),
      child: _buildButtonContent(),
    );
  }

  /// 轮廓按钮 - 透明背景，蓝色边框
  Widget _buildOutlineButton(BuildContext context, bool isDisabled) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.textDisabled,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: isDisabled ? AppColors.divider : AppColors.primary,
          width: 2,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  /// 文本按钮 - 无背景
  Widget _buildTextButton(BuildContext context, bool isDisabled) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.textDisabled,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  /// 危险按钮 - 红色背景
  Widget _buildDangerButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.buttonGray,
        disabledForegroundColor: AppColors.textDisabled,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isDisabled ? 0 : 4,
        shadowColor: AppColors.error.withOpacity(0.3),
      ),
      child: _buildButtonContent(),
    );
  }

  /// 成功按钮 - 绿色背景
  Widget _buildSuccessButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.buttonGray,
        disabledForegroundColor: AppColors.textDisabled,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isDisabled ? 0 : 4,
        shadowColor: AppColors.success.withOpacity(0.3),
      ),
      child: _buildButtonContent(),
    );
  }

  /// VIP按钮 - 金色渐变背景
  Widget _buildVipButton(BuildContext context, bool isDisabled) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.vipGold,
            AppColors.vipGoldDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.vipGold.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.buttonGray,
          disabledForegroundColor: AppColors.textDisabled,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  /// 构建渐变背景装饰
  BoxDecoration _buildGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.blueGradientStart,
          AppColors.blueGradientEnd,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// 构建按钮内容
  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: _getTextSize(),
        width: _getTextSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == AppButtonType.outline || type == AppButtonType.text
                ? AppColors.primary
                : Colors.white,
          ),
        ),
      );
    }

    List<Widget> children = [];

    if (leadingIcon != null) {
      children.add(
        Icon(
          leadingIcon,
          size: _getIconSize(),
        ),
      );
      children.add(const SizedBox(width: 8));
    }

    children.add(
      Text(
        text,
        style: TextStyle(
          fontSize: _getTextSize(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (trailingIcon != null) {
      children.add(const SizedBox(width: 8));
      children.add(
        Icon(
          trailingIcon,
          size: _getIconSize(),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  /// 获取按钮内边距
  EdgeInsets _getPadding() {
    if (padding != null) return padding!;
    
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal:24, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  /// 获取文字大小
  double _getTextSize() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
    }
  }

  /// 获取图标大小
  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }
}

/// 按钮类型枚举
enum AppButtonType {
  primary,    // 主要按钮
  secondary,  // 次要按钮
  outline,    // 轮廓按钮
  text,       // 文本按钮
  danger,     // 危险按钮
  success,    // 成功按钮
  vip,        // VIP按钮
}

/// 按钮尺寸枚举
enum AppButtonSize {
  small,   // 小尺寸
  medium,  // 中等尺寸
  large,   // 大尺寸
}
