import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// 安全验证对话框
/// 支持多种验证方式：交易密码、短信验证码、生物识别
class SecurityVerificationDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<VerificationType> verificationTypes;
  final Function(Map<String, String> verificationData) onVerified;
  final VoidCallback? onCancel;
  final bool showTransactionDetails;
  final Map<String, dynamic>? transactionData;

  const SecurityVerificationDialog({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.verificationTypes,
    required this.onVerified,
    this.onCancel,
    this.showTransactionDetails = false,
    this.transactionData,
  }) : super(key: key);

  @override
  State<SecurityVerificationDialog> createState() => _SecurityVerificationDialogState();
}

enum VerificationType {
  paymentPassword, // 交易密码
  smsCode,         // 短信验证码
  biometric,       // 生物识别
}

class _SecurityVerificationDialogState extends State<SecurityVerificationDialog>
    with TickerProviderStateMixin {
  final Map<VerificationType, TextEditingController> _controllers = {};
  final Map<VerificationType, String?> _errors = {};
  bool _isLoading = false;
  int _smsCountdown = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // 初始化控制器
    for (var type in widget.verificationTypes) {
      _controllers[type] = TextEditingController();
    }
    
    // 动画初始化
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              if (widget.showTransactionDetails && widget.transactionData != null)
                _buildTransactionDetails(),
              Flexible(child: _buildVerificationBody()),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.info],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.security,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '交易详情',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.transactionData!.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${entry.key}:',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVerificationBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.verificationTypes.map((type) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildVerificationField(type),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVerificationField(VerificationType type) {
    switch (type) {
      case VerificationType.paymentPassword:
        return _buildPaymentPasswordField();
      case VerificationType.smsCode:
        return _buildSmsCodeField();
      case VerificationType.biometric:
        return _buildBiometricField();
    }
  }

  Widget _buildPaymentPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.lock, color: Colors.red, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              '交易密码',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controllers[VerificationType.paymentPassword],
          obscureText: true,
          maxLength: 6,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '请输入6位交易密码',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            prefixIcon: const Icon(Icons.security, color: Colors.grey),
            counterText: '',
            errorText: _errors[VerificationType.paymentPassword],
          ),
        ),
      ],
    );
  }

  Widget _buildSmsCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.message, color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              '短信验证码',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers[VerificationType.smsCode],
                maxLength: 6,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '请输入验证码',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.sms, color: Colors.grey),
                  counterText: '',
                  errorText: _errors[VerificationType.smsCode],
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              height: 50,
              child: ElevatedButton(
                onPressed: _smsCountdown > 0 ? null : _sendSmsCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _smsCountdown > 0 ? '${_smsCountdown}s' : '发送',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBiometricField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fingerprint, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '生物识别验证',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _performBiometricAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('启用生物识别'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () {
                widget.onCancel?.call();
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '取消',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '确认',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendSmsCode() async {
    setState(() => _smsCountdown = 60);
    
    // 倒计时
    for (int i = 60; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _smsCountdown = i - 1);
      }
    }
  }

  void _performBiometricAuth() async {
    // TODO: 实现生物识别认证
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('生物识别功能待实现'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleVerification() async {
    if (_isLoading) return;

    // 清除之前的错误
    _errors.clear();
    bool hasError = false;

    // 验证各个字段
    for (var type in widget.verificationTypes) {
      final controller = _controllers[type]!;
      final value = controller.text.trim();

      switch (type) {
        case VerificationType.paymentPassword:
          if (value.isEmpty) {
            _errors[type] = '请输入交易密码';
            hasError = true;
          } else if (value.length != 6) {
            _errors[type] = '交易密码必须为6位数字';
            hasError = true;
          } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
            _errors[type] = '交易密码只能包含数字';
            hasError = true;
          }
          break;
        case VerificationType.smsCode:
          if (value.isEmpty) {
            _errors[type] = '请输入验证码';
            hasError = true;
          } else if (value.length != 6) {
            _errors[type] = '验证码必须为6位数字';
            hasError = true;
          }
          break;
        case VerificationType.biometric:
          // 生物识别验证逻辑
          break;
      }
    }

    setState(() {});

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      // 准备验证数据
      final verificationData = <String, String>{};
      for (var entry in _controllers.entries) {
        final type = entry.key;
        final controller = entry.value;
        
        switch (type) {
          case VerificationType.paymentPassword:
            verificationData['payment_password'] = controller.text.trim();
            break;
          case VerificationType.smsCode:
            verificationData['sms_code'] = controller.text.trim();
            break;
          case VerificationType.biometric:
            verificationData['biometric'] = 'verified';
            break;
        }
      }

      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));

      // 回调验证成功
      widget.onVerified(verificationData);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('验证失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// 显示安全验证对话框的工具方法
Future<void> showSecurityVerificationDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
  required List<VerificationType> verificationTypes,
  required Function(Map<String, String> verificationData) onVerified,
  VoidCallback? onCancel,
  bool showTransactionDetails = false,
  Map<String, dynamic>? transactionData,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return SecurityVerificationDialog(
        title: title,
        subtitle: subtitle,
        verificationTypes: verificationTypes,
        onVerified: onVerified,
        onCancel: onCancel,
        showTransactionDetails: showTransactionDetails,
        transactionData: transactionData,
      );
    },
  );
}
