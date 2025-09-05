import 'package:flutter/material.dart';
import '../data/models/finance_models.dart';
import '../data/services/finance_service.dart';

class FinanceProvider with ChangeNotifier {
  final FinanceService _financeService = FinanceService();
  
  // 状态变量
  AccountBalance? _accountBalance;
  List<TransactionRecord> _transactionRecords = [];
  List<BankCard> _bankCards = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  // 分页相关
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  
  // 筛选条件
  TransactionType? _filterType;
  TransactionStatus? _filterStatus;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  
  // 缓存控制
  DateTime? _lastRefreshTime;
  static const Duration _cacheExpiration = Duration(minutes: 5);
  
  // Getters
  AccountBalance? get accountBalance => _accountBalance;
  List<TransactionRecord> get transactionRecords => List.unmodifiable(_transactionRecords);
  List<BankCard> get bankCards => List.unmodifiable(_bankCards);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  
  TransactionType? get filterType => _filterType;
  TransactionStatus? get filterStatus => _filterStatus;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  
  // 获取当前筛选条件下的记录
  List<TransactionRecord> get filteredTransactionRecords {
    List<TransactionRecord> filtered = _transactionRecords;
    
    if (_filterType != null) {
      filtered = filtered.where((record) => record.type == _filterType).toList();
    }
    
    if (_filterStatus != null) {
      filtered = filtered.where((record) => record.status == _filterStatus).toList();
    }
    
    if (_filterStartDate != null) {
      filtered = filtered.where((record) => 
          record.createdAt.isAfter(_filterStartDate!) || 
          record.createdAt.isAtSameMomentAs(_filterStartDate!)).toList();
    }
    
    if (_filterEndDate != null) {
      final endOfDay = DateTime(_filterEndDate!.year, _filterEndDate!.month, _filterEndDate!.day, 23, 59, 59);
      filtered = filtered.where((record) => 
          record.createdAt.isBefore(endOfDay) || 
          record.createdAt.isAtSameMomentAs(endOfDay)).toList();
    }
    
    return filtered;
  }
  
  // 判断是否需要刷新缓存
  bool get _needsRefresh {
    if (_lastRefreshTime == null) return true;
    return DateTime.now().difference(_lastRefreshTime!) > _cacheExpiration;
  }
  
  // 清除错误
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
  
  // 设置加载状态
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  // 设置错误
  void _setError(String error) {
    _error = error;
    debugPrint('FinanceProvider Error: $error');
    notifyListeners();
  }
  
  // 初始化数据
  Future<void> initialize({bool force = false}) async {
    if (_isInitialized && !force) return;
    
    try {
      _setLoading(true);
      clearError();
      
      await Future.wait([
        _loadAccountBalance(),
        _loadTransactionRecords(),
        _loadBankCards(),
      ]);
      
      _isInitialized = true;
      _lastRefreshTime = DateTime.now();
    } catch (e) {
      _setError('初始化失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 内部加载余额方法
  Future<void> _loadAccountBalance() async {
    final response = await _financeService.getAccountBalance();
    if (response.success && response.data != null) {
      _accountBalance = response.data!;
    } else if (response.message.isNotEmpty) {
      throw Exception(response.message);
    }
  }
  
  // 内部加载交易记录方法
  Future<void> _loadTransactionRecords() async {
    final response = await _financeService.getTransactionRecords(
      page: 1,
      pageSize: 20,
    );
    if (response.success && response.data != null) {
      _transactionRecords = response.data!;
      _currentPage = 1;
      _hasMore = _transactionRecords.length >= 20;
    } else if (response.message.isNotEmpty) {
      throw Exception(response.message);
    }
  }
  
  // 内部加载银行卡方法
  Future<void> _loadBankCards() async {
    final response = await _financeService.getBankCards();
    if (response.success && response.data != null) {
      _bankCards = response.data!;
    } else if (response.message.isNotEmpty) {
      throw Exception(response.message);
    }
  }
  
  // 获取账户余额
  Future<bool> getAccountBalance({bool forceRefresh = false}) async {
    if (!forceRefresh && !_needsRefresh && _accountBalance != null) {
      return true;
    }
    
    try {
      _setLoading(true);
      clearError();
      
      await _loadAccountBalance();
      _lastRefreshTime = DateTime.now();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('获取余额失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 刷新余额（不显示加载状态）
  Future<void> refreshBalance() async {
    try {
      await _loadAccountBalance();
      _lastRefreshTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      // 静默处理错误，不影响UI
      debugPrint('刷新余额失败: $e');
    }
  }
  
  // 存款
  Future<bool> deposit(DepositRequest request) async {
    // 数据验证
    if (!_validateDepositRequest(request)) {
      _setError('存款参数无效');
      return false;
    }
    
    try {
      _setLoading(true);
      clearError();
      
      final response = await _financeService.deposit(request);
      if (response.success) {
        // 成功后刷新相关数据
        await Future.wait([
          refreshBalance(),
          getTransactionRecords(refresh: true),
        ]);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('存款失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 验证存款请求
  bool _validateDepositRequest(DepositRequest request) {
    if (request.amount <= 0) return false;
    if (request.amount < 100 || request.amount > 50000) return false;
    return true;
  }
  
  // 取款
  Future<bool> withdrawal(WithdrawalRequest request) async {
    // 数据验证
    if (!_validateWithdrawalRequest(request)) {
      _setError('取款参数无效');
      return false;
    }
    
    // 余额检查
    if (_accountBalance == null || !_accountBalance!.hasSufficientBalance(request.amount)) {
      _setError('余额不足');
      return false;
    }
    
    try {
      _setLoading(true);
      clearError();
      
      final response = await _financeService.withdrawal(request);
      if (response.success) {
        // 成功后刷新相关数据
        await Future.wait([
          refreshBalance(),
          getTransactionRecords(refresh: true),
        ]);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('取款失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 验证取款请求
  bool _validateWithdrawalRequest(WithdrawalRequest request) {
    if (request.amount <= 0) return false;
    if (request.amount < 100 || request.amount > 100000) return false;
    if (request.bankCardId.isEmpty) return false;
    return true;
  }
  
  // 转账
  Future<bool> transfer(TransferRequest request) async {
    // 数据验证
    if (!_validateTransferRequest(request)) {
      _setError('转账参数无效');
      return false;
    }
    
    // 余额检查
    if (_accountBalance == null || !_accountBalance!.hasSufficientBalance(request.amount)) {
      _setError('余额不足');
      return false;
    }
    
    try {
      _setLoading(true);
      clearError();
      
      final response = await _financeService.transfer(request);
      if (response.success) {
        // 成功后刷新相关数据
        await Future.wait([
          refreshBalance(),
          getTransactionRecords(refresh: true),
        ]);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('转账失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 验证转账请求
  bool _validateTransferRequest(TransferRequest request) {
    if (request.amount <= 0) return false;
    if (request.amount < 1 || request.amount > 100000) return false;
    if (request.toUserId.isEmpty) return false;
    return true;
  }
  
  // 获取交易记录
  Future<bool> getTransactionRecords({
    bool refresh = false,
    bool loadMore = false,
  }) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _transactionRecords.clear();
      } else if (loadMore && (!_hasMore || _isLoadingMore)) {
        return true;
      }
      
      if (loadMore) {
        _isLoadingMore = true;
        _currentPage++;
      } else {
        _setLoading(true);
      }
      
      clearError();
      
      final response = await _financeService.getTransactionRecords(
        page: _currentPage,
        pageSize: 20,
        type: _filterType,
        status: _filterStatus,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      );
      
      if (response.success && response.data != null) {
        final newRecords = response.data!;
        
        // 数据去重和验证
        final validRecords = newRecords.where((record) => 
            record.validate() && 
            !_transactionRecords.any((existing) => existing.id == record.id)
        ).toList();
        
        if (refresh) {
          _transactionRecords = validRecords;
        } else {
          _transactionRecords.addAll(validRecords);
        }
        
        // 检查是否还有更多数据
        _hasMore = newRecords.length >= 20;
        
        // 按时间倒序排序
        _transactionRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        notifyListeners();
        return true;
      } else {
        _setError(response.message.isNotEmpty ? response.message : '获取交易记录失败');
        return false;
      }
    } catch (e) {
      _setError('获取交易记录失败: $e');
      return false;
    } finally {
      _setLoading(false);
      _isLoadingMore = false;
    }
  }
  
  // 设置筛选条件
  void setFilter({
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _filterType = type;
    _filterStatus = status;
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    notifyListeners();
  }
  
  // 清除筛选条件
  void clearFilter() {
    _filterType = null;
    _filterStatus = null;
    _filterStartDate = null;
    _filterEndDate = null;
    notifyListeners();
  }
  
  // 应用筛选
  Future<void> applyFilter() async {
    await getTransactionRecords(refresh: true);
  }
  
  // 获取银行卡列表
  Future<bool> getBankCards({bool forceRefresh = false}) async {
    if (!forceRefresh && _bankCards.isNotEmpty) {
      return true;
    }
    
    try {
      _setLoading(true);
      clearError();
      
      await _loadBankCards();
      
      // 验证银行卡数据
      _bankCards = _bankCards.where((card) => card.validate()).toList();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('获取银行卡失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 添加银行卡
  Future<bool> addBankCard(Map<String, dynamic> cardData) async {
    // 数据验证
    if (!_validateBankCardData(cardData)) {
      _setError('银行卡信息不完整或格式错误');
      return false;
    }
    
    try {
      _setLoading(true);
      clearError();
      
      final response = await _financeService.addBankCard(cardData);
      if (response.success) {
        // 成功后刷新银行卡列表
        await getBankCards(forceRefresh: true);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('添加银行卡失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 验证银行卡数据
  bool _validateBankCardData(Map<String, dynamic> cardData) {
    if (cardData['bank_name']?.toString().isEmpty != false) return false;
    if (cardData['card_number']?.toString().isEmpty != false) return false;
    if (cardData['card_holder']?.toString().isEmpty != false) return false;
    
    // 验证卡号格式
    final cardNumber = cardData['card_number'].toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (cardNumber.length < 16 || cardNumber.length > 19) return false;
    
    return true;
  }
  
  // 删除银行卡
  Future<bool> deleteBankCard(String cardId) async {
    if (cardId.isEmpty) {
      _setError('银行卡ID无效');
      return false;
    }
    
    try {
      _setLoading(true);
      clearError();
      
      final response = await _financeService.deleteBankCard(cardId);
      if (response.success) {
        // 成功后刷新银行卡列表
        await getBankCards(forceRefresh: true);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('删除银行卡失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 验证支付密码
  Future<bool> verifyPaymentPassword(String password) async {
    try {
      final response = await _financeService.verifyPaymentPassword(password);
      if (!response.success) {
        _setError(response.message);
      }
      return response.success;
    } catch (e) {
      _setError('密码验证失败: $e');
      return false;
    }
  }
  
  // 获取交易详情
  Future<TransactionRecord?> getTransactionDetail(String transactionId) async {
    try {
      final response = await _financeService.getTransactionDetail(transactionId);
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.message);
        return null;
      }
    } catch (e) {
      _setError('获取交易详情失败: $e');
      return null;
    }
  }
  
  // 获取默认银行卡
  BankCard? getDefaultBankCard() {
    for (final card in _bankCards) {
      if (card.isDefault && card.isActive) {
        return card;
      }
    }
    return _bankCards.isNotEmpty ? _bankCards.first : null;
  }
  
  // 获取有效银行卡
  List<BankCard> getActiveBankCards() {
    return _bankCards.where((card) => card.isActive).toList();
  }
  
  // 获取统计数据
  Future<Map<String, dynamic>?> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _financeService.getTransactionStatistics(
        startDate: startDate,
        endDate: endDate,
      );
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.message);
        return null;
      }
    } catch (e) {
      _setError('获取统计数据失败: $e');
      return null;
    }
  }
  
  // 格式化金额
  String formatAmount(double amount) {
    return _financeService.formatAmount(amount);
  }
  
  // 获取交易记录统计信息
  Map<String, dynamic> getTransactionSummary() {
    final records = filteredTransactionRecords;
    
    double totalIncome = 0.0;
    double totalOutcome = 0.0;
    int incomeCount = 0;
    int outcomeCount = 0;
    
    for (final record in records) {
      if (record.isIncome) {
        totalIncome += record.amount;
        incomeCount++;
      } else if (record.isOutcome) {
        totalOutcome += record.amount;
        outcomeCount++;
      }
    }
    
    return {
      'total_income': totalIncome,
      'total_outcome': totalOutcome,
      'income_count': incomeCount,
      'outcome_count': outcomeCount,
      'net_amount': totalIncome - totalOutcome,
      'total_records': records.length,
    };
  }
  
  // 获取最近的交易记录
  List<TransactionRecord> getRecentTransactions({int limit = 5}) {
    final sorted = List<TransactionRecord>.from(_transactionRecords);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }
  
  // 重置状态
  void reset() {
    _accountBalance = null;
    _transactionRecords.clear();
    _bankCards.clear();
    _isLoading = false;
    _isInitialized = false;
    _error = null;
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _lastRefreshTime = null;
    clearFilter();
    notifyListeners();
  }
  
  @override
  void dispose() {
    reset();
    super.dispose();
  }
}