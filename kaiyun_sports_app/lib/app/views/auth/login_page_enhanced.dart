import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/animation_extensions.dart';
import '../../core/components/animated_button.dart';
import '../../core/components/animated_card.dart';
import '../../core/components/micro_interactions.dart';
import '../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoAnimation;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
    
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    // 启动logo动画
    Future.delayed(const Duration(milliseconds: 500), () {
      _logoController.forward();
    });
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 模拟登录请求
      await Future.delayed(const Duration(seconds: 2));
      
      // 模拟登录逻辑
      if (_usernameController.text == 'admin' && _passwordController.text == '123456') {
        HapticFeedback.heavyImpact();
        Get.offNamed(AppRoutes.home);
      } else {
        setState(() {
          _errorMessage = '用户名或密码错误';
        });
        HapticFeedback.heavyImpact();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 动态背景
          _buildAnimatedBackground(),
          
          // 主要内容
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimationLimiter(
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: widget,
                      ),
                    ),
                    children: [
                      const SizedBox(height: 60),
                      
                      // Logo和标题
                      _buildHeader(),
                      
                      const SizedBox(height: 60),
                      
                      // 登录表单
                      _buildLoginForm(),
                      
                      const SizedBox(height: 32),
                      
                      // 其他登录选项
                      _buildOtherOptions(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0 + _backgroundAnimation.value * 0.1,
                0.3 + _backgroundAnimation.value * 0.2,
                0.7 + _backgroundAnimation.value * 0.1,
                1.0,
              ],
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.primaryLight.withOpacity(0.9),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        AnimatedBuilder(
          animation: _logoAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _logoAnimation.value,
              child: Transform.rotate(
                angle: _logoAnimation.value * 0.1,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // 标题
        const Text(
          '开云体育',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ).slideIn(
          delay: const Duration(milliseconds: 800),
          direction: SlideDirection.fromBottom,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '欢迎回来',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ).fadeIn(delay: const Duration(milliseconds: 1000)),
      ],
    );
  }
  
  Widget _buildLoginForm() {
    return AnimatedCard(
      backgroundColor: Colors.white.withOpacity(0.95),
      borderRadius: 16,
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 错误信息
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ).shake(),
            
            // 用户名输入框
            RippleEffect(
              child: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '用户名/手机号',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名或手机号';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 密码输入框
            RippleEffect(
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: RippleEffect(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                      HapticFeedback.lightImpact();
                    },
                    borderRadius: 20,
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  if (value.length < 6) {
                    return '密码至少6位';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 记住我 & 忘记密码
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RippleEffect(
                  onTap: () {
                    setState(() {
                      _rememberMe = !_rememberMe;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _rememberMe ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: _rememberMe ? AppColors.primary : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _rememberMe
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '记住我',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                RippleEffect(
                  onTap: () {
                    // TODO: 忘记密码
                  },
                  child: const Text(
                    '忘记密码？',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 登录按钮
            AnimatedButton(
              text: '登录',
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
              width: double.infinity,
              height: 50,
              backgroundColor: AppColors.primary,
              borderRadius: 12,
            ),
            
            const SizedBox(height: 16),
            
            // 注册提示
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '还没有账号？',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                RippleEffect(
                  onTap: () {
                    Get.toNamed(AppRoutes.register);
                  },
                  child: const Text(
                    '立即注册',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOtherOptions() {
    return Column(
      children: [
        const Text(
          '提示：用户名admin，密码123456',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '其他登录方式',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialLoginButton(
              icon: Icons.fingerprint,
              label: '指纹登录',
              onTap: () {
                // TODO: 指纹登录
              },
            ),
            _buildSocialLoginButton(
              icon: Icons.face,
              label: '面部识别',
              onTap: () {
                // TODO: 面部识别
              },
            ),
            _buildSocialLoginButton(
              icon: Icons.qr_code,
              label: '扫码登录',
              onTap: () {
                // TODO: 扫码登录
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSocialLoginButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return AnimatedCard(
      onTap: onTap,
      backgroundColor: Colors.white.withOpacity(0.2),
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
