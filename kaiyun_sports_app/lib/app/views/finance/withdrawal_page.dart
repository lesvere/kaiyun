import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/finance_provider.dart';
import '../../data/models/finance_models.dart';
import 'bank_card_manage_page.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _passwordController = TextEditingController();
  BankCard? _selectedBankCard;
  bool _isLoading = false;
  
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
      final financeProvider = context.read<FinanceProvider>();
      financeProvider.getAccountBalance();
      financeProvider.getBankCards().then((_) {
        if (financeProvider.bankCards.isNotEmpty) {
          setState(() {
            _selectedBankCard = financeProvider.getDefaultBankCard();
          });
        }
      });
      _animationController.forward();
    });
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('取款'),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card),
            onPressed: () => _navigateToBankCardManage(),
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
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 余额信息
                        _buildBalanceInfo(financeProvider.accountBalance),
                        const SizedBox(height: 16),
                        
                        // 银行卡选择
                        _buildBankCardSelection(financeProvider),
                        const SizedBox(height: 16),
                        
                        // 取款金额
                        _buildAmountInput(),
                        const SizedBox(height: 16),
                        
                        // 支付密码
                        _buildPasswordInput(),
                        
                        const SizedBox(height: 16),
                        
                        // 取款规则
                        _buildWithdrawalRules(),
                        
                        const SizedBox(height: 24),
                        
                        // 安全提示
                        _buildSecurityTips(),
                        
                        const SizedBox(height: 24),
                        
                        // 确认按钮
                        _buildWithdrawalButton(financeProvider),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildBalanceInfo(AccountBalance? balance) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.warning.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppColors.warning.withOpacity(0.8), AppColors.warning.withOpacity(0.6)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '可用余额',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¥${balance?.availableBalance.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (balance?.frozenBalance != null && balance!.frozenBalance > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '冻结余额: ¥${balance.frozenBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                onPressed: () {
                  context.read<FinanceProvider>().refreshBalance();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBankCardSelection(FinanceProvider financeProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '选择银行卡',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _navigateToBankCardManage(),
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text(
                    '管理',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (financeProvider.bankCards.isEmpty)
              _buildNoBankCardWidget()
            else
              _buildBankCardDropdown(financeProvider.bankCards),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoBankCardWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.credit_card_off,
            color: AppColors.warning,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            '暂无银行卡',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '请先添加银行卡才能进行取款',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _navigateToBankCardManage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              '添加银行卡',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBankCardDropdown(List<BankCard> bankCards) {
    return DropdownButtonFormField<BankCard>(
      value: _selectedBankCard,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(
          Icons.credit_card,
          color: AppColors.warning,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: bankCards.map((card) {
        return DropdownMenuItem<BankCard>(
          value: card,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.bankName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      card.getDisplayCardNumber(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (card.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '默认',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (card) {
        setState(() {
          _selectedBankCard = card;
        });
      },
      validator: (value) {
        if (value == null) {
          return '请选择银行卡';
        }
        return null;
      },
    );
  }
  
  Widget _buildAmountInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '取款金额',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '取款金额',
                prefixIcon: const Icon(
                  Icons.monetization_on,
                  color: AppColors.warning,
                ),
                suffixText: '￥',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.warning,
                    width: 2,
                  ),
                ),
                helperText: '最小取款金额为100元，最大取款金额为100,000元',
                helperStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入取款金额';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return '请输入有效金额';
                }
                if (amount < 100) {
                  return '最小取款金额为100元';
                }
                if (amount > 100000) {
                  return '最大取款金额为100,000元';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPasswordInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '支付密码',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '支付密码',
                prefixIcon: const Icon(
                  Icons.lock,
                  color: AppColors.warning,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.warning,
                    width: 2,
                  ),
                ),
                helperText: '请输入6位数字支付密码',
                helperStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              maxLength: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入支付密码';
                }
                if (value.length != 6) {
                  return '支付密码必须为6位数字';
                }
                if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                  return '支付密码只能包含数字';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWithdrawalRules() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '取款规则',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildRuleItem(
              icon: Icons.schedule,
              title: '处理时间',
              description: '工作日24小时内处理，节假日可能延迟',
            ),
            _buildRuleItem(
              icon: Icons.account_balance,
              title: '到账方式',
              description: '转账至绑定银行卡，请确保卡片状态正常',
            ),
            _buildRuleItem(
              icon: Icons.receipt,
              title: '手续费用',
              description: '每日前3笔免费，超出部分收取2元/笔',
            ),
            _buildRuleItem(
              icon: Icons.security,
              title: '安全验证',
              description: '需要输入支付密码进行身份验证',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRuleItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: AppColors.warning,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
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
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSecurityTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                size: 20,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              const Text(
                '安全提示',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• 请确认银行卡信息正确，错误信息可能导致取款失败\n'
            '• 取款申请提交后无法撤销，请谨慎操作\n'
            '• 如遇异常情况，请及时联系客服处理\n'
            '• 保护好您的支付密码，不要泄露给他人',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWithdrawalButton(FinanceProvider financeProvider) {
    final isLoading = _isLoading || financeProvider.isLoading;
    final canWithdraw = _selectedBankCard != null && financeProvider.bankCards.isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (isLoading || !canWithdraw) ? null : () => _handleWithdrawal(financeProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                canWithdraw ? '确认取款' : '请先添加银行卡',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
  
  Future<void> _handleWithdrawal(FinanceProvider financeProvider) async {
    if (!_formKey.currentState!.validate() || _selectedBankCard == null) {
      return;
    }
    
    final amount = double.parse(_amountController.text);
    
    // 检查余额
    if (financeProvider.accountBalance == null ||
        financeProvider.accountBalance!.availableBalance < amount) {
      _showMessage('余额不足，无法取款', isError: true);
      return;
    }
    
    // 显示确认对话框
    final confirmed = await _showWithdrawalConfirmDialog(amount);
    if (!confirmed) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 先验证支付密码
      final passwordValid = await financeProvider.verifyPaymentPassword(_passwordController.text);
      if (!passwordValid) {
        _showMessage('支付密码错误，请重新输入', isError: true);
        return;
      }
      
      final request = WithdrawalRequest(
        amount: amount,
        bankCardId: _selectedBankCard!.id,
        paymentPassword: _passwordController.text,
        remark: '取款操作',
      );
      
      final success = await financeProvider.withdrawal(request);
      
      if (success) {
        _showMessage('取款申请已提交，请等待处理');
        _amountController.clear();
        _passwordController.clear();
        // 延迟返回，让用户看到成功消息
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showMessage(financeProvider.error ?? '取款失败，请重试', isError: true);
      }
    } catch (e) {
      _showMessage('取款失败: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<bool> _showWithdrawalConfirmDialog(double amount) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('确认取款'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('取款金额: ￥${amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('银行卡: ${_selectedBankCard?.bankName} ${_selectedBankCard?.getDisplayCardNumber()}'),
            const SizedBox(height: 8),
            Text('持卡人: ${_selectedBankCard?.cardHolder}'),
            const SizedBox(height: 12),
            const Text(
              '请确认信息无误，取款申请提交后无法撤销',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  void _navigateToBankCardManage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BankCardManagePage(),
      ),
    );
    
    // 返回后刷新银行卡列表
    if (result == true) {
      context.read<FinanceProvider>().getBankCards();
    }
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