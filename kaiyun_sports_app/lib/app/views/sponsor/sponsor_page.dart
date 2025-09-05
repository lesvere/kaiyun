import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SponsorPage extends StatelessWidget {
  const SponsorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('赞助伙伴'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 合作促乐部
            _buildSponsorCard(
              title: '皇家马德里',
              description: '官方赞助商',
              imageUrl: 'https://example.com/real_madrid.png',
            ),
            const SizedBox(height: 16),
            _buildSponsorCard(
              title: '国际米兰',
              description: '官方赞助商',
              imageUrl: 'https://example.com/inter_milan.png',
            ),
            const SizedBox(height: 16),
            _buildSponsorCard(
              title: 'AC米兰',
              description: '官方赞助商',
              imageUrl: 'https://example.com/ac_milan.png',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSponsorCard({
    required String title,
    required String description,
    required String imageUrl,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: AppColors.primary,
                size: 32,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}