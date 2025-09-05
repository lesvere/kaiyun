import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // 注册标题
                const Text(
                  '创建账户',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  '加入开云体育大家庭',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 注册表单
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // 用户名输入框
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: '用户名',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                              helperText: '用户名不少于3位，只能包含字母、数字和下划线',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入用户名';
                              }
                              if (value.length < 3) {
                                return '用户名不少于3位';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                return '用户名只能包含字母、数字和下划线';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 邮箱输入框
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: '邮箱地址',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入邮箱地址';
                              }
                              if (!GetUtils.isEmail(value)) {
                                return '请输入正确的邮箱地址';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 密码输入框
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: '密码',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(),
                              helperText: '密码长度不少于8位，包含字母、数字和特殊字符',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入密码';
                              }
                              if (value.length < 8) {
                                return '密码长度不少于8位';
                              }
                              // 检查密码强度
                              if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
                                return '密码必须包含字母和数字';
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
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请再次输入密码';
                              }
                              if (value != _passwordController.text) {
                                return '两次输入的密码不一致';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 同意条款
                          CheckboxListTile(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                            title: const Text.rich(
                              TextSpan(
                                text: '我已阅读并同意',
                                children: [
                                  TextSpan(
                                    text: '《用户协议》',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(text: '和'),
                                  TextSpan(
                                    text: '《隐私政策》',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                              style: TextStyle(fontSize: 14),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 注册按钮
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading || !_agreeToTerms
                                      ? null
                                      : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          '注册',
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
                          
                          // 登录链接
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('已有账户？'),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('立即登录'),
                              ),
                            ],
                          ),
                        ],
                      ),
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
  
  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请先同意用户协议和隐私政策'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        _usernameController.text.trim(),
        _passwordController.text,
        _emailController.text.trim(),
      );
      
      if (success) {
        // 注册成功，跳转到登录页
        Get.offNamed(AppRoutes.login);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('注册成功，请登录'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // 显示错误信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? '注册失败'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}