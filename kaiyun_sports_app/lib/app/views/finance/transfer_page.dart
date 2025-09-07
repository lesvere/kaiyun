import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/finance_provider.dart';
import '../../data/models/finance_models.dart';
import '../components/security_verification_dialog.dart';
import '../components/transaction_confirm_dialog.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _toUserController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();
  final _passwordController = TextEditingController();
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
      context.read<FinanceProvider>().getAccountBalance();
      _animationController.forward();
    });
  }
  
  @override
  void dispose() {
    _toUserController.dispose();
    _amountController.dispose();
    _remarkController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('转账'),
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
        elevation: 0,
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
                        _buildBalanceCard(financeProvider.accountBalance),
                        const SizedBox(height: 16),
                        
                        // 收款账户
                        _buildReceiverSection(),
                        const SizedBox(height: 16),
                        
                        // 转账金额
                        _buildAmountSection(),
                        const SizedBox(height: 16),
                        
                        // 支付密码
                        _buildPasswordSection(),
                        const SizedBox(height: 16),
                        
                        // 转账备注
                        _buildRemarkSection(),
                        
                        const SizedBox(height: 16),
                        
                        // 转账规则
                        _buildTransferRules(),
                        
                        const SizedBox(height: 24),
                        
                        // 安全提示
                        _buildSecurityTips(),
                        
                        const SizedBox(height: 24),
                        
                        // 确认按钮
                        _buildTransferButton(financeProvider),
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
  
  // 余额卡片
  Widget _buildBalanceCard(AccountBalance? balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.info, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.account_balance_wallet, 
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '当前余额',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  balance != null ? '￥${balance.availableBalance.toStringAsFixed(2)}' : '加载中...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 收款账户输入
  Widget _buildReceiverSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.person,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '收款账户',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _toUserController,
            decoration: InputDecoration(
              hintText: '请输入收款用户名或账号',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              prefixIcon: Icon(Icons.account_circle, 
                  color: Colors.grey.shade400),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入收款账户';
              }
              if (value.length < 3) {
                return '账户名至少3个字符';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // 转账金额输入
  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.attach_money,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '转账金额',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '请输入转账金额',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              prefixIcon: Icon(Icons.currency_yen, 
                  color: Colors.grey.shade400),
              suffixText: '元',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入转账金额';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return '请输入有效的转账金额';
              }
              if (amount < 10) {
                return '转账金额不能低于10元';
              }
              if (amount > 50000) {
                return '单次转账金额不能超过50,000元';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          // 快捷金额选择
          Wrap(
            spacing: 8,
            children: [100, 500, 1000, 5000].map((amount) {
              return InkWell(
                onTap: () => _amountController.text = amount.toString(),
                child: Chip(
                  label: Text('${amount}元'),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.primary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 支付密码输入
  Widget _buildPasswordSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.lock, 
                    color: Colors.red, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '交易密码',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: '请输入6位交易密码',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              prefixIcon: Icon(Icons.security, 
                  color: Colors.grey.shade400),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入交易密码';
              }
              if (value.length != 6) {
                return '交易密码必须为6位数字';
              }
              if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                return '交易密码只能包含数字';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // 备注输入
  Widget _buildRemarkSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.note_add,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '转账备注',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Text(
                '（选填）',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _remarkController,
            maxLines: 3,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: '请输入转账备注信息（可选）',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 转账规则
  Widget _buildTransferRules() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Text(
                '转账规则',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• 单笔转账最低10元，最高50,000元\n'
            '• 每日转账限额100,000元\n'
            '• 转账完成后不可撤销，请仔细核对信息\n'
            '• 转账手续费：免费',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 安全提示
  Widget _buildSecurityTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                '安全提示',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• 请确保收款方信息准确无误\n'
            '• 切勿向陌生人转账\n'
            '• 如遇诈骗请立即联系客服\n'
            '• 交易密码请勿泄露给他人',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 转账按钮
  Widget _buildTransferButton(FinanceProvider financeProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _showTransferConfirmation(financeProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: _isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              '确认转账',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
      ),
    );
  }

  // 显示转账确认流程（分两步：交易确认 + 安全验证）
  void _showTransferConfirmation(FinanceProvider financeProvider) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 第一步：显示交易详情确认
    final transactionData = {
      '收款账户': _toUserController.text.trim(),
      '转账金额': double.parse(_amountController.text),
      '转账备注': _remarkController.text.trim().isEmpty ? '无' : _remarkController.text.trim(),
      '手续费': 0.00,
      '到账时间': '实时到账',
    };

    showTransactionConfirmDialog(
      context: context,
      title: '确认转账信息',
      transactionType: TransactionType.transfer,
      transactionData: transactionData,
      confirmButtonText: '下一步',
      onConfirm: () => _showSecurityVerification(financeProvider, transactionData),
    );
  }

  // 第二步：安全验证
  void _showSecurityVerification(FinanceProvider financeProvider, Map<String, dynamic> transactionData) {
    showSecurityVerificationDialog(
      context: context,
      title: '安全验证',
      subtitle: '为了您的资金安全，请完成以下验证',
      verificationTypes: [
        VerificationType.paymentPassword,
        // 可以根据用户设置添加其他验证方式
        // VerificationType.smsCode,
        // VerificationType.biometric,
      ],
      showTransactionDetails: true,
      transactionData: transactionData,
      onVerified: (verificationData) {
        _executeTransfer(financeProvider, verificationData);
      },
    );
  }

  // 执行转账操作
  void _executeTransfer(FinanceProvider financeProvider, Map<String, String> verificationData) async {
    setState(() => _isLoading = true);

    try {
      final transferData = TransferRequest(
        toUserId: _toUserController.text.trim(),
        amount: double.parse(_amountController.text),
        remark: _remarkController.text.trim(),
        paymentPassword: verificationData['payment_password'],
      );

      final success = await financeProvider.transfer(transferData);

      if (mounted) {
        if (success) {
          // 显示成功消息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '转账成功！向 ${_toUserController.text} 转账 ￥${_amountController.text}',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // 清空表单
          _resetForm();

          // 刷新余额
          financeProvider.getAccountBalance();
        } else {
          // 显示错误信息
          _showErrorMessage(financeProvider.error ?? '转账失败，请稍后重试');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('转账失败: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 显示错误消息
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: '重试',
          textColor: Colors.white,
          onPressed: () {
            _showTransferConfirmation(context.read<FinanceProvider>());
          },
        ),
      ),
    );
  }

  // 重置表单
  void _resetForm() {
    _toUserController.clear();
    _amountController.clear();
    _remarkController.clear();
    _passwordController.clear();
    _formKey.currentState?.reset();
  }
}