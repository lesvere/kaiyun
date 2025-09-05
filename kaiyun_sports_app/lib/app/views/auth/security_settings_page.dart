import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import 'biometric_setup_page.dart';
import 'pin_setup_page.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('安全设置'),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // 登录安全区域
                _buildSectionCard(
                  title: '登录安全',
                  children: [
                    _buildMenuItem(
                      icon: Icons.fingerprint,
                      title: '生物认证',
                      subtitle: '指纹、面部识别等',
                      trailing: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Text(
                            authProvider.biometricEnabled ? '已启用' : '未启用',
                            style: TextStyle(
                              color: authProvider.biometricEnabled 
                                  ? Colors.green 
                                  : Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                      onTap: () => _goToBiometricSetup(),
                    ),
                    
                    _buildDivider(),
                    
                    _buildMenuItem(
                      icon: Icons.pin,
                      title: 'PIN码登录',
                      subtitle: '6位数字快速登录',
                      onTap: () => _goToPinSetup(),
                    ),
                    
                    _buildDivider(),
                    
                    _buildMenuItem(
                      icon: Icons.vpn_key,
                      title: '修改密码',
                      subtitle: '更改登录密码',
                      onTap: () => _goToChangePassword(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 账户安全区域
                _buildSectionCard(
                  title: '账户安全',
                  children: [
                    _buildMenuItem(
                      icon: Icons.device_hub,
                      title: '设备管理',
                      subtitle: '管理受信任设备',
                      onTap: () => _goToDeviceManagement(),
                    ),
                    
                    _buildDivider(),
                    
                    _buildMenuItem(
                      icon: Icons.history,
                      title: '登录记录',
                      subtitle: '查看最近登录活动',
                      onTap: () => _goToLoginHistory(),
                    ),
                    
                    _buildDivider(),
                    
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: '安全问题',
                      subtitle: '设置安全问题以找回密码',
                      onTap: () => _goToSecurityQuestions(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 高级安全区域
                _buildSectionCard(
                  title: '高级安全',
                  children: [
                    _buildMenuItem(
                      icon: Icons.security,
                      title: '两步验证',
                      subtitle: '增强账户安全性',
                      onTap: () => _goToTwoFactorAuth(),
                    ),
                    
                    _buildDivider(),
                    
                    _buildMenuItem(
                      icon: Icons.notifications_active,
                      title: '安全通知',
                      subtitle: '接收安全相关提醒',
                      trailing: Switch(
                        value: true, // TODO: 从状态管理获取
                        onChanged: (value) {
                          // TODO: 更新状态
                        },
                        activeColor: AppColors.primary,
                      ),
                      onTap: null,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 安全状态概览
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final securityStatus = authProvider.getSecurityStatus();
                    return _buildSecurityOverview(securityStatus);
                  },
                ),
                
                const SizedBox(height: 24),
                
                // 安全提示
                _buildSecurityTips(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
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
            
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Colors.grey[200],
    );
  }
  
  Widget _buildSecurityOverview(Map<String, dynamic> securityStatus) {
    int securityScore = 0;
    if (securityStatus['biometric_enabled'] == true) securityScore += 25;
    if (securityStatus['device_id'] != null) securityScore += 25;
    if (securityStatus['account_locked'] != true) securityScore += 25;
    securityScore += 25; // 基础安全分
    
    String securityLevel;
    Color levelColor;
    
    if (securityScore >= 75) {
      securityLevel = '高';
      levelColor = Colors.green;
    } else if (securityScore >= 50) {
      securityLevel = '中';
      levelColor = Colors.orange;
    } else {
      securityLevel = '低';
      levelColor = Colors.red;
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '安全状态概览',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '安全等级',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: levelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              securityLevel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: levelColor,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          Text(
                            '$securityScore%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: levelColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.security,
                      color: levelColor,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 安全状态条
            LinearProgressIndicator(
              value: securityScore / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecurityTips() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
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
                  Icons.lightbulb_outline,
                  color: Colors.blue,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '安全建议',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '• 使用强密码，包含大小写字母、数字和特殊字符\n• 启用生物认证可提高安全性\n• 定期检查登录记录，及时发现异常\n• 不要在公共场所进行敏感操作',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _goToBiometricSetup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BiometricSetupPage(),
      ),
    );
  }
  
  void _goToPinSetup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PinSetupPage(),
      ),
    );
  }
  
  void _goToChangePassword() {
    // TODO: 实现修改密码页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('修改密码功能正在开发中'),
      ),
    );
  }
  
  void _goToDeviceManagement() {
    // TODO: 实现设备管理页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('设备管理功能正在开发中'),
      ),
    );
  }
  
  void _goToLoginHistory() {
    // TODO: 实现登录记录页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('登录记录功能正在开发中'),
      ),
    );
  }
  
  void _goToSecurityQuestions() {
    // TODO: 实现安全问题设置页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('安全问题功能正在开发中'),
      ),
    );
  }
  
  void _goToTwoFactorAuth() {
    // TODO: 实现两步验证设置页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('两步验证功能正在开发中'),
      ),
    );
  }
}
