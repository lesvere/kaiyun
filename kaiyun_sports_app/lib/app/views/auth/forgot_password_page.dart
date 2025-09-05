import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  int _currentStep = 0; // 0: 输入邮箱/手机, 1: 输入验证码, 2: 设置新密码
  String _selectedType = 'email'; // 'email' 或 'sms'
  String? _resetToken;
  bool _codeSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _countdown = 0;
  
  @override
  void dispose() {
    _identifierController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('找回密码'),
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
                
                // 步骤指示器
                _buildStepIndicator(),
                
                const SizedBox(height: 40),
                
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
                      child: _buildCurrentStep(),
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
  
  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStep(0, '验证身份', _currentStep >= 0),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep >= 1 ? AppColors.primary : Colors.grey[300],
          ),
        ),
        _buildStep(1, '验证码', _currentStep >= 1),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep >= 2 ? AppColors.primary : Colors.grey[300],
          ),
        ),
        _buildStep(2, '新密码', _currentStep >= 2),
      ],
    );
  }
  
  Widget _buildStep(int stepIndex, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${stepIndex + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.primary : Colors.grey[600],
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildIdentifierStep();
      case 1:
        return _buildCodeStep();
      case 2:
        return _buildPasswordStep();
      default:
        return Container();
    }
  }
  
  Widget _buildIdentifierStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '验证身份',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '请输入您的邮箱地址或手机号码',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // 选择验证方式
          Row(
            children: [
              Expanded(
                child: _buildTypeSelector('email', '邮箱验证', Icons.email),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeSelector('sms', '短信验证', Icons.sms),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 输入框
          TextFormField(
            controller: _identifierController,
            decoration: InputDecoration(
              labelText: _selectedType == 'email' ? '邮箱地址' : '手机号码',
              prefixIcon: Icon(
                _selectedType == 'email' ? Icons.email : Icons.phone,
                color: AppColors.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            keyboardType: _selectedType == 'email' 
                ? TextInputType.emailAddress 
                : TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _selectedType == 'email' ? '请输入邮箱地址' : '请输入手机号码';
              }
              if (_selectedType == 'email') {
                if (!GetUtils.isEmail(value)) {
                  return '请输入有效的邮箱地址';
                }
              } else {
                if (!GetUtils.isPhoneNumber(value)) {
                  return '请输入有效的手机号码';
                }
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          // 下一步按钮
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: authProvider.isLoading ? null : _sendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
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
                        '发送验证码',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypeSelector(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey[600],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '验证码',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '验证码已发送至 ${_identifierController.text}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 24),
        
        // 验证码输入框
        TextFormField(
          controller: _codeController,
          decoration: InputDecoration(
            labelText: '验证码',
            prefixIcon: const Icon(
              Icons.security,
              color: AppColors.primary,
            ),
            suffixIcon: _countdown > 0
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '${_countdown}s',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _sendCode,
                    child: const Text(
                      '重新发送',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        
        const SizedBox(height: 24),
        
        // 下一步按钮
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return ElevatedButton(
              onPressed: authProvider.isLoading ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
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
                      '验证',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // 返回上一步
        TextButton(
          onPressed: () {
            setState(() {
              _currentStep = 0;
            });
          },
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
  
  Widget _buildPasswordStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '设置新密码',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '请设置您的新密码',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // 新密码输入框
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '新密码',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入新密码';
              }
              if (value.length < 8) {
                return '密码长度至少8位';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(value)) {
                return '密码必须包含大小写字母、数字和特殊字符';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // 确认密码输入框
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: '确认密码',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请确认密码';
              }
              if (value != _newPasswordController.text) {
                return '两次输入的密码不一致';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          // 完成按钮
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: authProvider.isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
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
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // 返回上一步
          TextButton(
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
            child: const Text(
              '返回上一步',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _sendCode() async {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendResetCode(
      _identifierController.text,
      _selectedType,
    );
    
    if (success) {
      setState(() {
        _currentStep = 1;
        _codeSent = true;
      });
      _startCountdown();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('验证码已发送'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '发送失败'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _verifyCode() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入验证码'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final resetToken = await authProvider.verifyResetCode(
      _identifierController.text,
      _codeController.text,
    );
    
    if (resetToken != null) {
      setState(() {
        _resetToken = resetToken;
        _currentStep = 2;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('验证成功'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '验证失败'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(
      _resetToken!,
      _newPasswordController.text,
      _confirmPasswordController.text,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('密码重置成功'),
          backgroundColor: AppColors.success,
        ),
      );
      
      // 延迟返回登录页面
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '重置失败'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });
    
    Stream.periodic(const Duration(seconds: 1), (count) => count)
        .take(60)
        .listen((count) {
      setState(() {
        _countdown = 59 - count;
      });
    });
  }
}
