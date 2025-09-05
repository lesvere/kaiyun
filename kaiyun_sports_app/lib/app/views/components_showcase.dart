import 'package:flutter/material.dart';
import '../core/components/components.dart';
import '../core/theme/app_colors.dart';

/// UI组件库演示页面 - 展示所有通用组件的使用效果
/// 用于测试和预览组件样式
class ComponentsShowcasePage extends StatefulWidget {
  const ComponentsShowcasePage({Key? key}) : super(key: key);

  @override
  State<ComponentsShowcasePage> createState() => _ComponentsShowcasePageState();
}

class _ComponentsShowcasePageState extends State<ComponentsShowcasePage> {
  bool _switchValue = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBarStyles.detail(
        title: 'UI组件展示',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('按钮组件'),
            _buildButtonSection(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('输入框组件'),
            _buildTextFieldSection(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('卡片组件'),
            _buildCardSection(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('图标按钮组件'),
            _buildIconButtonSection(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('渐变容器组件'),
            _buildGradientSection(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('列表项组件'),
            _buildListTileSection(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('加载指示器组件'),
            _buildLoadingSection(),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildButtonSection() {
    return Column(
      children: [
        // 按钮类型展示
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: '主要按钮',
                type: AppButtonType.primary,
                onPressed: () {},
                gradient: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: '次要按钮',
                type: AppButtonType.secondary,
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: '轮廓按钮',
                type: AppButtonType.outline,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: '文本按钮',
                type: AppButtonType.text,
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'VIP按钮',
                type: AppButtonType.vip,
                onPressed: () {},
                leadingIcon: Icons.diamond,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: '危险按钮',
                type: AppButtonType.danger,
                onPressed: () {},
                trailingIcon: Icons.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 按钮尺寸展示
        Row(
          children: [
            AppButton(
              text: '小按钮',
              size: AppButtonSize.small,
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            AppButton(
              text: '中按钮',
              size: AppButtonSize.medium,
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            AppButton(
              text: '大按钮',
              size: AppButtonSize.large,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFieldSection() {
    return Column(
      children: [
        AppTextField(
          label: '标准输入框',
          hintText: '请输入内容',
          controller: _textController,
          showClearButton: true,
        ),
        const SizedBox(height: 16),
        AppTextFieldStyles.password(
          label: '密码输入框',
          hintText: '请输入密码',
        ),
        const SizedBox(height: 16),
        AppTextFieldStyles.phone(
          label: '手机号输入框',
          hintText: '请输入手机号',
        ),
        const SizedBox(height: 16),
        AppTextFieldStyles.search(
          hintText: '搜索内容...',
        ),
        const SizedBox(height: 16),
        AppTextFieldStyles.amount(
          label: '金额输入框',
          hintText: '请输入金额',
        ),
      ],
    );
  }

  Widget _buildCardSection() {
    return Column(
      children: [
        AppCardStyles.info(
          child: AppCardContent(
            title: '信息卡片',
            subtitle: '这是一个标准的信息展示卡片',
            leading: Icon(Icons.info_outline, color: AppColors.primary),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.iconGray),
          ),
        ),
        AppCardStyles.data(
          child: AppCardContent(
            title: '数据卡片',
            subtitle: '¥12,345.67',
            description: '账户余额',
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.account_balance_wallet, color: AppColors.primary),
            ),
          ),
        ),
        AppCardStyles.vip(
          child: AppCardContent(
            title: 'VIP特权卡片',
            subtitle: '尊享专属服务',
            leading: Icon(Icons.diamond, color: AppColors.textPrimary, size: 24),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButtonSection() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        AppIconButtonStyles.search(),
        AppIconButtonStyles.notification(count: 3),
        AppIconButtonStyles.favorite(isFavorited: true),
        AppIconButtonStyles.share(),
        AppIconButtonStyles.settings(),
        AppIconButtonStyles.add(),
        AppIconButton(
          icon: Icons.star,
          type: AppIconButtonType.circular,
          backgroundColor: AppColors.warning,
        ),
        AppIconButton(
          icon: Icons.bookmark,
          type: AppIconButtonType.rounded,
          backgroundColor: AppColors.success,
        ),
        AppIconButton(
          icon: Icons.message,
          type: AppIconButtonType.outlined,
          borderColor: AppColors.primary,
        ),
        AppIconButton(
          icon: Icons.home,
          type: AppIconButtonType.gradient,
        ),
      ],
    );
  }

  Widget _buildGradientSection() {
    return Column(
      children: [
        AppGradientStyles.banner(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '主页横幅',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '欢迎使用开云体育',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppGradientStyles.vipCard(
                borderRadius: 12,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.diamond, color: AppColors.textPrimary),
                    const SizedBox(height: 8),
                    Text('VIP特权', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppGradientStyles.benefitCard(
                borderRadius: 12,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.white),
                    const SizedBox(height: 8),
                    Text('福利中心', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListTileSection() {
    return Column(
      children: [
        AppListTileStyles.setting(
          title: '账户设置',
          subtitle: '管理您的账户信息',
          icon: Icons.account_circle_outlined,
          onTap: () {},
        ),
        AppListTileStyles.user(
          name: '张三',
          status: 'VIP用户',
          description: '上次登录：2024-01-01',
          avatar: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text('张', style: TextStyle(color: Colors.white)),
          ),
        ),
        AppListTileStyles.transaction(
          title: '存款',
          amount: '+¥1,000.00',
          time: '2024-01-01 10:30',
          icon: Icons.add_circle_outline,
          amountColor: AppColors.success,
        ),
        AppListTileStyles.menu(
          title: '帮助中心',
          description: '常见问题和客服支持',
          icon: Icons.help_outline,
          onTap: () {},
        ),
        AppListTileStyles.toggle(
          title: '推送通知',
          subtitle: '接收重要消息推送',
          icon: Icons.notifications_outlined,
          value: _switchValue,
          onChanged: (value) {
            setState(() {
              _switchValue = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                AppLoadingIndicator(
                  type: AppLoadingType.circular,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text('圆形加载', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: [
                AppLoadingIndicator(
                  type: AppLoadingType.dots,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text('点状加载', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: [
                AppLoadingIndicator(
                  type: AppLoadingType.pulse,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text('脉冲加载', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: [
                AppLoadingIndicator(
                  type: AppLoadingType.wave,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text('波浪加载', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppLoadingIndicator(
          type: AppLoadingType.linear,
          size: 200,
        ),
        const SizedBox(height: 12),
        Text('线性加载进度条'),
        const SizedBox(height: 20),
        AppLoadingIndicator(
          type: AppLoadingType.skeleton,
          size: 300,
        ),
        const SizedBox(height: 12),
        Text('骨架屏加载'),
      ],
    );
  }
}
