import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  int _currentStep = 0; // 0: 设置pin, 1: 确认pin
  String _enteredPin = '';
  
  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PIN码设置'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // PIN码图标
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.pin,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 主要内容卡片
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _currentStep == 0 
                          ? _buildSetPinStep()
                          : _buildConfirmPinStep(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSetPinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '设置PIN码',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '请设置一个6位数字PIN码，用于快速登录',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // PIN码显示
        _buildPinDisplay(_pinController.text),
        
        const SizedBox(height: 32),
        
        // 数字键盘
        _buildNumberKeyboard(_pinController),
        
        const SizedBox(height: 24),
        
        // 下一步按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _pinController.text.length == 6 ? _proceedToConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text(
              '下一步',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildConfirmPinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '确认PIN码',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '请再次输入PIN码以确认',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // PIN码显示
        _buildPinDisplay(_confirmPinController.text),
        
        const SizedBox(height: 32),
        
        // 数字键盘
        _buildNumberKeyboard(_confirmPinController),
        
        const SizedBox(height: 24),
        
        // 完成按钮
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmPinController.text.length == 6 && !authProvider.isLoading
                    ? _confirmPin
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        '完成',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // 返回上一步
        TextButton(
          onPressed: _goBackToSetPin,
          child: const Text(
            '返回上一步',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPinDisplay(String pin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: index < pin.length ? AppColors.primary : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
  
  Widget _buildNumberKeyboard(TextEditingController controller) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        ...List.generate(9, (index) {
          final number = index + 1;
          return _buildKeyboardButton(
            text: number.toString(),
            onTap: () => _addDigit(controller, number.toString()),
          );
        }),
        Container(), // 空置
        _buildKeyboardButton(
          text: '0',
          onTap: () => _addDigit(controller, '0'),
        ),
        _buildKeyboardButton(
          icon: Icons.backspace_outlined,
          onTap: () => _removeDigit(controller),
        ),
      ],
    );
  }
  
  Widget _buildKeyboardButton({
    String? text,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: text != null
              ? Text(
                  text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                )
              : Icon(
                  icon,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
        ),
      ),
    );
  }
  
  void _addDigit(TextEditingController controller, String digit) {
    if (controller.text.length < 6) {
      setState(() {
        controller.text = controller.text + digit;
      });
      
      HapticFeedback.lightImpact();
    }
  }
  
  void _removeDigit(TextEditingController controller) {
    if (controller.text.isNotEmpty) {
      setState(() {
        controller.text = controller.text.substring(0, controller.text.length - 1);
      });
      
      HapticFeedback.lightImpact();
    }
  }
  
  void _proceedToConfirm() {
    setState(() {
      _enteredPin = _pinController.text;
      _currentStep = 1;
    });
    
    HapticFeedback.mediumImpact();
  }
  
  void _goBackToSetPin() {
    setState(() {
      _currentStep = 0;
      _confirmPinController.clear();
    });
  }
  
  void _confirmPin() async {
    if (_confirmPinController.text != _enteredPin) {
      // PIN码不匹配
      HapticFeedback.heavyImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN码不一致，请重新输入'),
          backgroundColor: AppColors.error,
        ),
      );
      
      // 清空确认PIN码
      setState(() {
        _confirmPinController.clear();
      });
      
      return;
    }
    
    // PIN码匹配，保存PIN码
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.setPinCode(_confirmPinController.text);
    
    if (success) {
      HapticFeedback.lightImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN码设置成功'),
          backgroundColor: AppColors.success,
        ),
      );
      
      // 延迟返回
      Future.delayed(const Duration(seconds: 1), () {
        Get.back(result: true);
      });
    } else {
      HapticFeedback.heavyImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'PIN码设置失败'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
