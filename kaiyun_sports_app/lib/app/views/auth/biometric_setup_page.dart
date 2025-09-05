import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class BiometricSetupPage extends StatefulWidget {
  const BiometricSetupPage({super.key});

  @override
  State<BiometricSetupPage> createState() => _BiometricSetupPageState();
}

class _BiometricSetupPageState extends State<BiometricSetupPage> {
  bool _isEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }
  
  void _loadBiometricStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isEnabled = authProvider.biometricEnabled;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('生物认证设置'),
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
                
                // 生物认证图标
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
                    Icons.fingerprint,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '生物认证',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            '使用指纹或面部识别快速安全地登录您的账户',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 生物认证开关
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return _buildSettingItem(
                                icon: Icons.fingerprint,
                                title: '启用生物认证',
                                subtitle: authProvider.biometricSupported
                                    ? '使用指纹或面部识别登录'
                                    : '您的设备不支持生物认证',
                                value: _isEnabled && authProvider.biometricSupported,
                                enabled: authProvider.biometricSupported,
                                onChanged: authProvider.biometricSupported
                                    ? _toggleBiometric
                                    : null,
                              );
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 安全提示
                          _buildSecurityInfo(),
                          
                          const SizedBox(height: 24),
                          
                          // 测试按钮
                          if (_isEnabled)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _testBiometric,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  '测试生物认证',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
  
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: enabled ? AppColors.primary.withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? AppColors.primary : Colors.grey[500],
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: enabled ? AppColors.textPrimary : Colors.grey[500],
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '安全提示',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '• 生物认证数据仅存储在您的设备上\n• 我们不会收集或存储您的生物特征信息\n• 如果您更换设备，需要重新设置生物认证',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
  
  void _toggleBiometric(bool enabled) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      final success = await authProvider.toggleBiometric(enabled);
      
      if (success) {
        setState(() {
          _isEnabled = enabled;
        });
        
        HapticFeedback.lightImpact();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled ? '生物认证已启用' : '生物认证已禁用',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? '设置失败',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('操作失败，请稍后再试'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _testBiometric() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      final success = await authProvider.biometricLogin();
      
      if (success) {
        HapticFeedback.lightImpact();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('生物认证测试成功'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? '生物认证失败',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('测试失败，请稍后再试'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
