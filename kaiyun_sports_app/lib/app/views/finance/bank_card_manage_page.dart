import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/finance_provider.dart';
import '../../data/models/finance_models.dart';

class BankCardManagePage extends StatefulWidget {
  const BankCardManagePage({super.key});

  @override
  State<BankCardManagePage> createState() => _BankCardManagePageState();
}

class _BankCardManagePageState extends State<BankCardManagePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().getBankCards();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('银行卡管理'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBankCardDialog(),
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: _buildContent(financeProvider),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(FinanceProvider financeProvider) {
    if (financeProvider.isLoading && financeProvider.bankCards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (financeProvider.error != null && financeProvider.bankCards.isEmpty) {
      return _buildErrorView(financeProvider.error!);
    }

    if (financeProvider.bankCards.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await financeProvider.getBankCards();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: financeProvider.bankCards.length,
        itemBuilder: (context, index) {
          final card = financeProvider.bankCards[index];
          return _buildBankCardItem(card, financeProvider);
        },
      ),
    );
  }

  Widget _buildBankCardItem(BankCard card, FinanceProvider financeProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: card.isDefault 
              ? [AppColors.primary.withOpacity(0.8), AppColors.primaryLight.withOpacity(0.8)]
              : [Colors.grey.shade100, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: card.isDefault 
                            ? Colors.white.withOpacity(0.2)
                            : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.credit_card,
                          color: card.isDefault ? Colors.white : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.bankName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: card.isDefault ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.cardType,
                            style: TextStyle(
                              fontSize: 12,
                              color: card.isDefault 
                                ? Colors.white.withOpacity(0.8)
                                : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: card.isDefault ? Colors.white : AppColors.textSecondary,
                    ),
                    onSelected: (value) => _handleCardAction(value, card, financeProvider),
                    itemBuilder: (context) => [
                      if (!card.isDefault)
                        const PopupMenuItem(
                          value: 'set_default',
                          child: Text('设为默认'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('删除', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: card.isDefault 
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '卡号',
                      style: TextStyle(
                        fontSize: 14,
                        color: card.isDefault 
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      card.getDisplayCardNumber(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: card.isDefault ? Colors.white : AppColors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: card.isDefault 
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '持卡人',
                      style: TextStyle(
                        fontSize: 14,
                        color: card.isDefault 
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      card.cardHolder,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: card.isDefault ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (card.isDefault) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '默认卡',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<FinanceProvider>().getBankCards();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无银行卡',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '添加银行卡以便进行取款操作',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddBankCardDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('添加银行卡'),
          ),
        ],
      ),
    );
  }

  void _handleCardAction(String action, BankCard card, FinanceProvider financeProvider) {
    switch (action) {
      case 'set_default':
        // TODO: 实现设为默认卡的逻辑
        _showMessage('设为默认卡功能开发中');
        break;
      case 'delete':
        _showDeleteConfirmDialog(card, financeProvider);
        break;
    }
  }

  void _showDeleteConfirmDialog(BankCard card, FinanceProvider financeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('确认删除'),
        content: Text('确定要删除这张${card.bankName}银行卡吗？\n\n${card.getDisplayCardNumber()}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await financeProvider.deleteBankCard(card.id);
              if (success) {
                _showMessage('银行卡删除成功');
              } else {
                _showMessage(financeProvider.error ?? '删除失败，请重试', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showAddBankCardDialog() {
    final formKey = GlobalKey<FormState>();
    final bankNameController = TextEditingController();
    final cardNumberController = TextEditingController();
    final cardHolderController = TextEditingController();
    String selectedCardType = '储蓄卡';
    
    final cardTypes = ['储蓄卡', '信用卡'];
    final banks = [
      '中国银行', '工商银行', '建设银行', '农业银行', '交通银行',
      '招商银行', '民生银行', '兴业银行', '浦发银行', '中信银行',
      '光大银行', '华夏银行', '广发银行', '平安银行'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('添加银行卡'),
        content: StatefulBuilder(
          builder: (context, setState) => Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: bankNameController.text.isEmpty ? null : bankNameController.text,
                    decoration: const InputDecoration(
                      labelText: '选择银行',
                      border: OutlineInputBorder(),
                    ),
                    items: banks.map((bank) => DropdownMenuItem(
                      value: bank,
                      child: Text(bank),
                    )).toList(),
                    onChanged: (value) {
                      bankNameController.text = value ?? '';
                    },
                    validator: (value) => value == null || value.isEmpty ? '请选择银行' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: cardNumberController,
                    decoration: const InputDecoration(
                      labelText: '银行卡号',
                      hintText: '请输入银行卡号',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入银行卡号';
                      }
                      if (value.length < 16 || value.length > 19) {
                        return '银行卡号长度不正确';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: cardHolderController,
                    decoration: const InputDecoration(
                      labelText: '持卡人姓名',
                      hintText: '请输入持卡人姓名',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入持卡人姓名';
                      }
                      if (value.length < 2) {
                        return '姓名长度不能少于2个字符';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCardType,
                    decoration: const InputDecoration(
                      labelText: '卡类型',
                      border: OutlineInputBorder(),
                    ),
                    items: cardTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCardType = value ?? '储蓄卡';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                
                final cardData = {
                  'bank_name': bankNameController.text,
                  'card_number': cardNumberController.text,
                  'card_holder': cardHolderController.text,
                  'card_type': selectedCardType,
                };
                
                final financeProvider = context.read<FinanceProvider>();
                final success = await financeProvider.addBankCard(cardData);
                
                if (success) {
                  _showMessage('银行卡添加成功');
                } else {
                  _showMessage(financeProvider.error ?? '添加失败，请重试', isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}