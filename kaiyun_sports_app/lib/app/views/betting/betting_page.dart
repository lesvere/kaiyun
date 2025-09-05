import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/betting_models.dart';
import '../../data/services/betting_service.dart';

class BettingPage extends StatefulWidget {
  const BettingPage({super.key});

  @override
  State<BettingPage> createState() => _BettingPageState();
}

class _BettingPageState extends State<BettingPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final BettingService _bettingService = BettingService();
  
  bool _isLoading = false;
  BetType _selectedBetType = BetType.single;
  List<BetOption> _selectedOptions = [];
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投注'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 投注选项显示
              _buildBetOptions(),
              
              const SizedBox(height: 16),
              
              // 投注金额输入
              _buildAmountInput(),
              
              const SizedBox(height: 16),
              
              // 预计收益显示
              _buildPotentialWinnings(),
              
              const SizedBox(height: 24),
              
              // 确认投注按钮
              _buildBetButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBetOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '投注选项',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedOptions.isEmpty)
              const Text(
                '请选择投注项目',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              )
            else
              ..._selectedOptions.map((option) => ListTile(
                title: Text(option.title),
                subtitle: Text('赔率: ${option.odds}'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeOption(option),
                ),
              )),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _showBetOptionsDialog,
              icon: const Icon(Icons.add),
              label: const Text('添加投注项'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAmountInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '投注金额',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '请输入投注金额',
                prefixText: '¥ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入投注金额';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return '请输入有效的投注金额';
                }
                if (amount < 10) {
                  return '最小投注金额为¥10';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            // 快速金额选择
            Wrap(
              spacing: 8,
              children: [10, 50, 100, 500, 1000].map((amount) => 
                ChoiceChip(
                  label: Text('¥$amount'),
                  selected: false,
                  onSelected: (selected) {
                    if (selected) {
                      _amountController.text = amount.toString();
                    }
                  },
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPotentialWinnings() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final totalOdds = _calculateTotalOdds();
    final potentialWinnings = amount * totalOdds;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '预计收益',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '¥${potentialWinnings.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBetButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final canBet = _selectedOptions.isNotEmpty && 
                      !_isLoading && 
                      authProvider.isLoggedIn;
        
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canBet ? _handleBet : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                : Text(
                    canBet ? '确认投注' : _getBetButtonText(authProvider),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }
  
  String _getBetButtonText(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      return '请先登录';
    }
    if (_selectedOptions.isEmpty) {
      return '请选择投注项';
    }
    return '确认投注';
  }
  
  void _removeOption(BetOption option) {
    setState(() {
      _selectedOptions.remove(option);
    });
  }
  
  void _showBetOptionsDialog() {
    // 显示可选投注项的对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择投注项'),
        content: const Text('投注选项对话框内容...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // 添加选中的投注项
              Navigator.pop(context);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
  
  double _calculateTotalOdds() {
    if (_selectedOptions.isEmpty) return 0;
    
    if (_selectedBetType == BetType.single) {
      return _selectedOptions.first.odds;
    } else {
      // 串关投注，赔率相乘
      return _selectedOptions.fold(1.0, (odds, option) => odds * option.odds);
    }
  }
  
  Future<void> _handleBet() async {
    if (!_formKey.currentState!.validate() || _selectedOptions.isEmpty) {
      return;
    }
    
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      Get.snackbar(
        '提示',
        '请先登录后再进行投注',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }
    
    final amount = double.parse(_amountController.text);
    
    // 显示确认对话框
    final confirmed = await _showBetConfirmDialog(amount);
    if (!confirmed) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final betRequest = BetRequest(
        options: _selectedOptions,
        amount: amount,
        betType: _selectedBetType,
        userId: authProvider.user?.id ?? '',
      );
      
      final result = await _bettingService.placeBet(betRequest);
      
      if (result['success']) {
        _showMessage('投注成功！');
        _clearForm();
        // 可以导航到投注记录页面
      } else {
        _showMessage(result['message'] ?? '投注失败，请重试', isError: true);
      }
    } catch (e) {
      _showMessage('投注失败: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<bool> _showBetConfirmDialog(double amount) async {
    final totalOdds = _calculateTotalOdds();
    final potentialWinnings = amount * totalOdds;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认投注'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('投注金额: ¥${amount.toStringAsFixed(2)}'),
            Text('总赔率: ${totalOdds.toStringAsFixed(2)}'),
            Text('预计收益: ¥${potentialWinnings.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            const Text(
              '请确认投注信息，提交后无法撤销',
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
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认投注'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  void _clearForm() {
    _amountController.clear();
    setState(() {
      _selectedOptions.clear();
    });
  }
  
  void _showMessage(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? '投注失败' : '投注成功',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? AppColors.error : AppColors.success,
      colorText: Colors.white,
      duration: Duration(seconds: isError ? 3 : 2),
    );
  }
}