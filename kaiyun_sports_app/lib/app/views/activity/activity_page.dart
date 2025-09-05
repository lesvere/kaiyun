import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('优惠活动'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 热门活动
            _buildActivityCard(
              title: '新手礼包',
              description: '最高888元新手奖金，立即领取',
              image: 'assets/images/activity_1.jpg',
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            _buildActivityCard(
              title: 'VIP专享礼包',
              description: 'VIP用户专属优惠，无限面对面',
              image: 'assets/images/vip_activity.jpg',
              color: AppColors.vipGold,
            ),
            const SizedBox(height: 16),
            _buildActivityCard(
              title: '每日签到',
              description: '连续签到送奖金，最高288元',
              image: 'assets/images/activity_small_1.jpg',
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityCard({
    required String title,
    required String description,
    required String image,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: color,
                      ),
                      child: const Text('立即参与'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.white.withOpacity(0.3),
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}