import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AgentPage extends StatelessWidget {
  const AgentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('加入我们'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('代理加入页面'),
      ),
    );
  }
}