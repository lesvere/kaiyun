import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/finance_models.dart';
import '../api/api_service.dart';

class FinanceService {
  static final FinanceService _instance = FinanceService._internal();
  factory FinanceService() => _instance;
  FinanceService._internal();
  
  final ApiService _apiService = ApiService();
  
  // 获取账户余额
  Future<ApiResponse<AccountBalance>> getAccountBalance() async {
    try {
      final response = await _apiService.get('/finance/balance');
      final data = _apiService.handleResponse(response);
      
      return ApiResponse<AccountBalance>(
        success: data['success'] ?? true,
        message: data['message'] ?? '获取成功',
        data: AccountBalance.fromJson(data['data'] ?? {}),
      );
    } catch (e) {
      return ApiResponse<AccountBalance>(
        success: false,
        message: _apiService.handleError(e),
      );
    }
  }
  
  // 存款
  Future<ApiResponse<TransactionRecord>> deposit(DepositRequest request) async {
    try {
      // 金额校验
      if (!_validateAmount(request.amount, minAmount: 100, maxAmount: 50000)) {
        return ApiResponse<TransactionRecord>(
          success: false,
          message: '存款金额不合法，请输入100-50,000元之间的金额',
        );
      }
      
      final response = await _apiService.post('/finance/deposit', data: request.toJson());
      final data = _apiService.handleResponse(response);
      
      return ApiResponse<TransactionRecord>(
        success: data['success'] ?? true,
        message: data['message'] ?? '存款请求已提交',
        data: data['data'] != null ? TransactionRecord.fromJson(data['data']) : null,
      );
    } catch (e) {
      return ApiResponse<TransactionRecord>(
        success: false,
        message: _apiService.handleError(e),
      );
    }
  }
  
  // 取款
  Future<ApiResponse<TransactionRecord>> withdrawal(WithdrawalRequest request) async {
    try {
      // 金额校验
      if (!_validateAmount(request.amount, minAmount: 100, maxAmount: 100000)) {
        return ApiResponse<TransactionRecord>(
          success: false,
          message: '取款金额不合法，请输入100-100,000元之间的金额',
        );
      }
      
      // 检查余额
      final balanceResponse = await getAccountBalance();
      if (!balanceResponse.success) {
        return ApiResponse<TransactionRecord>(
          success: false,
          message: '无法获取账户余额',
        );
      }
      
      final balance = balanceResponse.data!;
      if (balance.availableBalance < request.amount) {
        return ApiResponse<TransactionRecord>(
          success: false,
          message: '余额不足，可用余额￥${balance.availableBalance.toStringAsFixed(2)}',
        );
      }
      
      final response = await _apiService.post('/finance/withdrawal', data: request.toJson());
      final data = _apiService.handleResponse(response);
      
      return ApiResponse<TransactionRecord>(
        success: data['success'] ?? true,
        message: data['message'] ?? '取款请求已提交',
        data: data['data'] != null ? TransactionRecord.fromJson(data['data']) : null,
      );
    } catch (e) {
      return ApiResponse<TransactionRecord>(
        success: false,
        message: _apiService.handleError(e),
      );
    }
  }
  
  // 转账
  Future<ApiResponse<TransactionRecord>> transfer(TransferRequest request) async {
    try {
      // 金额校验
      if (!_validateAmount(request.amount, minAmount: 1, maxAmount: 100000)) {
        return ApiResponse<TransactionRecord>(
          success: false,
          message: '转账金额不合法，请输入1-100,000元之间的金额',
        );
      }
      
      // 检查余额
      final balanceResponse = await getAccountBalance();
      if (!balanceResponse.success) {
        return ApiResponse<TransactionRecord>(
          success: false,
          message: '无法获取账户余额',
        );
      }
      
      final balance = balanceResponse.data!;
      if (balance.availableBalance < request.amount) {
        return ApiResponse<TransactionRecord>(
          success: false,
          message: '余额不足，可用余额￥${balance.availableBalance.toStringAsFixed(2)}',
        );
      }
      
      final response = await _apiService.post('/finance/transfer', data: request.toJson());
      final data = _apiService.handleResponse(response);
      
      return ApiResponse<TransactionRecord>(
        success: data['success'] ?? true,
        message: data['message'] ?? '转账请求已提交',
        data: data['data'] != null ? TransactionRecord.fromJson(data['data']) : null,
      );
    } catch (e) {
      return ApiResponse<TransactionRecord>(
        success: false,
        message: _apiService.handleError(e),
      );
    }
  }
  
  // 获取交易记录
  Future<ApiResponse<List<TransactionRecord>>> getTransactionRecords({
    int page = 1,
    int pageSize = 20,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (type != null) queryParams['type'] = type.name;
      if (status != null) queryParams['status'] = status.name;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      
      final response = await _apiService.get(
        '/finance/transactions',
        queryParameters: queryParams,
      );
      final data = _apiService.handleResponse(response);
      
      final records = (data['data']['records'] as List? ?? [])
          .map((json) => TransactionRecord.fromJson(json))
          .toList();
      
      return ApiResponse<List<TransactionRecord>>(
        success: data['success'] ?? true,
        message: data['message'] ?? '获取成功',
        data: records,
      );
    } catch (e) {
      return ApiResponse<List<TransactionRecord>>(
        success: false,
        message: _apiService.handleError(e),
      );
    }
  }
  
  // 获取银行卡列表
  Future<ApiResponse<List<BankCard>>> getBankCards() async {
    try {
      final response = await _apiService.get('/finance/bank-cards');
      final data = _apiService.handleResponse(response);
      
      final cards = (data['data'] as List? ?? [])
          .map((json) => BankCard.fromJson(json))
          .toList();
      
      return ApiResponse<List<BankCard>>(
        success: data['success'] ?? true,
        message: data['message'] ?? '获取成功',
        data: cards,
      );
    } catch (e) {
      return ApiResponse<List<BankCard>>(
        success: false,
        message: _apiService.handleError(e),
      );
    }
  }
  
  // 添加银行卡
  Future<ApiResponse<BankCard>> addBankCard(Map<String, dynamic> cardData) async {
    try {
      // 验证必要字段
      final requiredFields = ['bank_name', 'card_number', 'card_holder'];
      for (final field in requiredFields) {
        if (!cardData.containsKey(field) || cardData[field]?.toString().isEmpty == true) {
          return ApiResponse<BankCard>(
            success: false,
            message: '请填写完整的银行卡信息',
          );
        }
      }
      
      final response = await _apiService.post('/finance/bank-cards', data: cardData);
      final data = _apiService.handleResponse(response);
      
      return ApiResponse<BankCard>(
        success: data['success'] ?? true,
        message: data['message'] ?? '添加成功',
        data: data['data'] != null ? BankCard.fromJson(data['data']) : null,
      );
    } catch (e) {
      return ApiResponse<BankCard>(
        success: false,
        message: _apiService.handleError(e),
      );
    }
  }
  
  // 删除银行卡
  Future<ApiResponse<bool>> deleteBankCard(String cardId) async {
    try {
      final response = await _apiService.delete('/finance/bank-cards/$cardId');
      final data = _apiService.handleResponse(response);
      
      return ApiResponse<bool>(
        success: data['success'] ?? true,
        message: data['message'] ?? '删除成功',
        data: true,
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: _apiService.handleError(e),
      );
    }
  }
  
  // 获取支付方式配置
  Future<ApiResponse<List<Map<String, dynamic>>>> getPaymentMethods() async {
    try {
      final response = await _apiService.get('/finance/payment-methods');
      final data = _apiService.handleResponse(response);
      
      return ApiResponse<List<Map<String, dynamic>>>(
        success: data['success'] ?? true,
        message: data['message'] ?? '获取成功',
        data: List<Map<String, dynamic>>.from(data['data'] ?? []),
      );
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: _apiService.handleError(e),
      );
    }
  }
  
  // 获取交易详情
  Future<ApiResponse<TransactionRecord>> getTransactionDetail(String transactionId) async {
    try {
      final response = await _apiService.get('/finance/transactions/$transactionId');
      final data = _apiService.handleResponse(response);
      
      return ApiResponse<TransactionRecord>(
        success: data['success'] ?? true,
        message: data['message'] ?? '获取成功',
        data: data['data'] != null ? TransactionRecord.fromJson(data['data']) : null,
      );
    } catch (e) {
      return ApiResponse<TransactionRecord>(
        success: false,
        message: _apiService.handleError(e),
      );
    }
  }
  
  // 验证支付密码
  Future<ApiResponse<bool>> verifyPaymentPassword(String password) async {
    try {
      final response = await _apiService.post(
        '/finance/verify-payment-password',
        data: {'password': password},
      );
      final data = _apiService.handleResponse(response);
      
      return ApiResponse<bool>(
        success: data['success'] ?? false,
        message: data['message'] ?? '',
        data: data['success'] ?? false,
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: _apiService.handleError(e),
        data: false,
      );
    }
  }
  
  // 获取交易统计
  Future<ApiResponse<Map<String, dynamic>>> getTransactionStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      
      final response = await _apiService.get(
        '/finance/statistics',
        queryParameters: queryParams,
      );
      final data = _apiService.handleResponse(response);
      
      return ApiResponse<Map<String, dynamic>>(
        success: data['success'] ?? true,
        message: data['message'] ?? '获取成功',
        data: data['data'] ?? {},
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: _apiService.handleError(e),
      );
    }
  }
  
  // 私有方法 - 金额校验
  bool _validateAmount(double amount, {double minAmount = 0, double maxAmount = double.infinity}) {
    return amount >= minAmount && amount <= maxAmount && amount > 0;
  }
  
  // 私有方法 - 格式化金额
  String formatAmount(double amount, {String currency = 'CNY'}) {
    final symbol = currency == 'CNY' ? '￥' : '\$';
    return '$symbol${amount.toStringAsFixed(2)}';
  }
  
  // 私有方法 - 生成订单号
  String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'KY$timestamp$random';
  }
  
  // 获取支付方式图标色彩
  static Map<PaymentMethod, Map<String, dynamic>> getPaymentMethodStyles() {
    return {
      PaymentMethod.bankCard: {
        'color': const Color(0xFF1976D2),
        'icon': Icons.credit_card,
        'name': '银行卡',
        'subtitle': '支持各大银行储蓄卡',
      },
      PaymentMethod.alipay: {
        'color': const Color(0xFF1890FF),
        'icon': Icons.payment,
        'name': '支付宝',
        'subtitle': '安全快捷，实时到账',
      },
      PaymentMethod.wechat: {
        'color': const Color(0xFF07C160),
        'icon': Icons.chat,
        'name': '微信支付',
        'subtitle': '微信钱包，便民支付',
      },
      PaymentMethod.usdt: {
        'color': const Color(0xFF26A17B),
        'icon': Icons.currency_bitcoin,
        'name': 'USDT',
        'subtitle': '数字货币，全球通用',
      },
      PaymentMethod.paypal: {
        'color': const Color(0xFF003087),
        'icon': Icons.account_balance,
        'name': 'PayPal',
        'subtitle': '国际支付，安全便捷',
      },
      PaymentMethod.applePay: {
        'color': const Color(0xFF000000),
        'icon': Icons.phone_iphone,
        'name': 'Apple Pay',
        'subtitle': '生物识别，一触支付',
      },
    };
  }
}