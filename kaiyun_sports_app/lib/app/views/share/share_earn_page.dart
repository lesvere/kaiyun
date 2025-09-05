import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ShareEarnPage extends StatelessWidget {
  const ShareEarnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分享赚钱'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('分享赚钱页面'),
      ),
    );
  }
}