import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AccountManagementPage extends StatelessWidget {
  const AccountManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户管理'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('账户管理页面'),
      ),
    );
  }
}