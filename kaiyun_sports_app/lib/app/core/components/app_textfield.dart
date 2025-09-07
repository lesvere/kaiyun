import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// 通用输入框组件 - 提供多种样式和功能的文本输入框
/// 支持密码输入、数字输入、搜索框等多种类型
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? prefixText;
  final String? suffixText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final AppTextFieldType type;
  final bool showClearButton;
  final bool showPasswordToggle;
  final String? initialValue;
  final EdgeInsets? contentPadding;
  final double borderRadius;
  final bool filled;
  final Color? fillColor;
  final BorderSide? enabledBorder;
  final BorderSide? focusedBorder;
  final BorderSide? errorBorder;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixText,
    this.suffixText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.type = AppTextFieldType.standard,
    this.showClearButton = false,
    this.showPasswordToggle = false,
    this.initialValue,
    this.contentPadding,
    this.borderRadius = 12.0,
    this.filled = true,
    this.fillColor,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  late bool _obscureText;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        _buildTextField(context),
        if (widget.helperText != null && widget.errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.helperText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    final decoration = _buildInputDecoration(context);
    
    switch (widget.type) {
      case AppTextFieldType.search:
        return _buildSearchField(decoration);
      case AppTextFieldType.financial:
        return _buildFinancialField(decoration);
      case AppTextFieldType.phone:
        return _buildPhoneField(decoration);
      case AppTextFieldType.email:
        return _buildEmailField(decoration);
      default:
        return _buildStandardField(decoration);
    }
  }

  Widget _buildStandardField(InputDecoration decoration) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _hasFocus = hasFocus;
        });
      },
      child: TextFormField(
        controller: _controller,
        focusNode: widget.focusNode,
        decoration: decoration,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: _obscureText,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: widget.enabled ? AppColors.textPrimary : AppColors.textDisabled,
        ),
      ),
    );
  }

  Widget _buildSearchField(InputDecoration decoration) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _buildStandardField(decoration.copyWith(
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      )),
    );
  }

  Widget _buildFinancialField(InputDecoration decoration) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: _hasFocus ? AppColors.primary : AppColors.border,
          width: _hasFocus ? 2 : 1,
        ),
        boxShadow: [
          if (_hasFocus)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: _buildStandardField(decoration.copyWith(
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      )),
    );
  }

  Widget _buildPhoneField(InputDecoration decoration) {
    return _buildStandardField(decoration.copyWith(
      prefixIcon: const Icon(
        Icons.phone_outlined,
        color: AppColors.iconGray,
      ),
    ));
  }

  Widget _buildEmailField(InputDecoration decoration) {
    return _buildStandardField(decoration.copyWith(
      prefixIcon: const Icon(
        Icons.email_outlined,
        color: AppColors.iconGray,
      ),
    ));
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    return InputDecoration(
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(),
      contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: widget.filled,
      fillColor: widget.fillColor ?? _getFillColor(),
      border: _buildBorder(),
      enabledBorder: _buildEnabledBorder(),
      focusedBorder: _buildFocusedBorder(),
      errorBorder: _buildErrorBorder(),
      focusedErrorBorder: _buildErrorBorder(),
      counterText: '', // 隐藏字符计数器
    );
  }

  Widget? _buildSuffixIcon() {
    List<Widget> icons = [];

    // 清除按钮
    if (widget.showClearButton && _controller.text.isNotEmpty && widget.enabled) {
      icons.add(
        IconButton(
          icon: const Icon(Icons.clear, size: 20),
          onPressed: () {
            _controller.clear();
            if (widget.onChanged != null) {
              widget.onChanged!('');
            }
          },
          color: AppColors.iconGray,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
        ),
      );
    }

    // 密码可见性切换
    if (widget.showPasswordToggle) {
      icons.add(
        IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          color: AppColors.iconGray,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
        ),
      );
    }

    // 自定义后缀图标
    if (widget.suffixIcon != null) {
      icons.add(widget.suffixIcon!);
    }

    if (icons.isEmpty) return null;

    if (icons.length == 1) {
      return icons.first;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );
  }

  Color _getFillColor() {
    if (widget.type == AppTextFieldType.search) {
      return AppColors.sectionBackground;
    }
    return widget.enabled ? Colors.white : AppColors.buttonGray;
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: const BorderSide(
        color: AppColors.border,
        width: 1,
      ),
    );
  }

  OutlineInputBorder _buildEnabledBorder() {
    if (widget.enabledBorder != null) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: widget.enabledBorder!,
      );
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: const BorderSide(
        color: AppColors.border,
        width: 1,
      ),
    );
  }

  OutlineInputBorder _buildFocusedBorder() {
    if (widget.focusedBorder != null) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: widget.focusedBorder!,
      );
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 2,
      ),
    );
  }

  OutlineInputBorder _buildErrorBorder() {
    if (widget.errorBorder != null) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: widget.errorBorder!,
      );
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1,
      ),
    );
  }
}

/// 输入框类型枚举
enum AppTextFieldType {
  standard,   // 标准输入框
  search,     // 搜索框
  financial,  // 金融输入框（高级样式）
  phone,      // 手机号输入框
  email,      // 邮箱输入框
}

/// 预定义的文本输入框样式
class AppTextFieldStyles {
  /// 密码输入框
  static AppTextField password({
    Key? key,
    String? label,
    String? hintText = '请输入密码',
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return AppTextField(
      key: key,
      label: label,
      hintText: hintText,
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      obscureText: true,
      showPasswordToggle: true,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
    );
  }

  /// 手机号输入框
  static AppTextField phone({
    Key? key,
    String? label,
    String? hintText = '请输入手机号',
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return AppTextField(
      key: key,
      label: label,
      hintText: hintText,
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      type: AppTextFieldType.phone,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      maxLength: 11,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  /// 邮箱输入框
  static AppTextField email({
    Key? key,
    String? label,
    String? hintText = '请输入邮箱地址',
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return AppTextField(
      key: key,
      label: label,
      hintText: hintText,
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      type: AppTextFieldType.email,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
  }

  /// 搜索框
  static AppTextField search({
    Key? key,
    String? hintText = '搜索...',
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return AppTextField(
      key: key,
      hintText: hintText,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      type: AppTextFieldType.search,
      prefixIcon: const Icon(Icons.search, color: AppColors.iconGray),
      showClearButton: true,
      textInputAction: TextInputAction.search,
    );
  }

  /// 金额输入框
  static AppTextField amount({
    Key? key,
    String? label,
    String? hintText = '请输入金额',
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return AppTextField(
      key: key,
      label: label,
      hintText: hintText,
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      type: AppTextFieldType.financial,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      prefixText: '¥ ',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
    );
  }
}
