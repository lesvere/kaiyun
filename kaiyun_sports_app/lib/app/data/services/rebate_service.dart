import 'dart:async';
import '../models/rebate_models.dart';
import '../api/api_service.dart';

/// 返水服务类
class RebateService {
  final ApiService _apiService;
  late Timer _autoRebateTimer;
  
  RebateService(this._apiService) {
    _startAutoRebateTimer();
  }
  
  /// 启动自动返水定时器
  void _startAutoRebateTimer() {
    _autoRebateTimer = Timer.periodic(
      const Duration(minutes: 30), // 每30分钟检查一次
      (timer) => _processAutoRebate(),
    );
  }
  
  /// 停止自动返水定时器
  void dispose() {
    _autoRebateTimer.cancel();
  }
  
  /// 获取返水统计
  Future<RebateStatistics> getRebateStatistics() async {
    try {
      final response = await _apiService.get('/rebate/statistics');
      return RebateStatistics.fromJson(response.data);
    } catch (e) {
      // 模拟数据
      return RebateStatistics(
        todayRebate: 158.50,
        weekRebate: 1205.80,
        monthRebate: 4890.20,
        totalRebate: 28500.00,
        todayCount: 5,
        totalCount: 156,
        avgRebateRate: 0.008,
        categoryRebates: {
          '体育投注': 18500.00,
          '真人娱乐': 7800.00,
          '电子游戏': 2200.00,
        },
      );
    }
  }
  
  /// 获取返水记录
  Future<List<RebateRecord>> getRebateRecords({
    int page = 1,
    int pageSize = 20,
    RebateType? type,
    RebateStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiService.get('/rebate/records', queryParameters: {
        'page': page,
        'page_size': pageSize,
        'type': type?.toString().split('.').last,
        'status': status?.toString().split('.').last,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      });
      return (response.data['records'] as List)
          .map((json) => RebateRecord.fromJson(json))
          .toList();
    } catch (e) {
      return _getMockRebateRecords();
    }
  }
  
  /// 获取返水配置
  Future<List<RebateConfig>> getRebateConfigs() async {
    try {
      final response = await _apiService.get('/rebate/configs');
      return (response.data['configs'] as List)
          .map((json) => RebateConfig.fromJson(json))
          .toList();
    } catch (e) {
      return _getMockRebateConfigs();
    }
  }
  
  /// 申请返水
  Future<bool> applyRebate({
    required String category,
    required double betAmount,
    required String period,
  }) async {
    try {
      final response = await _apiService.post('/rebate/apply', data: {
        'category': category,
        'bet_amount': betAmount,
        'period': period,
      });
      return response.data['success'] ?? false;
    } catch (e) {
      // 模拟成功
      return true;
    }
  }
  
  /// 自动返水处理
  Future<void> _processAutoRebate() async {
    try {
      await _apiService.post('/rebate/auto-process');
    } catch (e) {
      // 静默处理错误
    }
  }
  
  /// 计算返水金额
  double calculateRebateAmount({
    required double betAmount,
    required double rebateRate,
    required double maxRebateAmount,
  }) {
    final rebateAmount = betAmount * rebateRate;
    return rebateAmount > maxRebateAmount ? maxRebateAmount : rebateAmount;
  }
  
  /// 检查是否符合返水条件
  bool isEligibleForRebate({
    required double betAmount,
    required double minBetAmount,
    required int vipLevel,
    required int vipLevelRequired,
  }) {
    return betAmount >= minBetAmount && vipLevel >= vipLevelRequired;
  }
  
  List<RebateRecord> _getMockRebateRecords() {
    return [
      RebateRecord(
        id: 'R20240905001',
        userId: 'U001',
        amount: 68.50,
        betAmount: 8562.50,
        rebateRate: 0.008,
        type: RebateType.betting,
        status: RebateStatus.processed,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        processedAt: DateTime.now().subtract(const Duration(hours: 1)),
        category: '体育投注',
        period: 'daily',
      ),
      RebateRecord(
        id: 'R20240905002',
        userId: 'U001',
        amount: 25.80,
        betAmount: 5160.00,
        rebateRate: 0.005,
        type: RebateType.betting,
        status: RebateStatus.processed,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        processedAt: DateTime.now().subtract(const Duration(days: 1)),
        category: '真人娱乐',
        period: 'daily',
      ),
      RebateRecord(
        id: 'R20240905003',
        userId: 'U001',
        amount: 45.20,
        betAmount: 9040.00,
        rebateRate: 0.005,
        type: RebateType.betting,
        status: RebateStatus.pending,
        createdAt: DateTime.now(),
        category: '体育投注',
        period: 'daily',
      ),
    ];
  }
  
  List<RebateConfig> _getMockRebateConfigs() {
    return [
      RebateConfig(
        category: '体育投注',
        minBetAmount: 100.0,
        maxRebateAmount: 500.0,
        rebateRate: 0.008,
        period: 'daily',
        vipLevelRequired: 0,
      ),
      RebateConfig(
        category: '真人娱乐',
        minBetAmount: 200.0,
        maxRebateAmount: 300.0,
        rebateRate: 0.005,
        period: 'daily',
        vipLevelRequired: 1,
      ),
      RebateConfig(
        category: '电子游戏',
        minBetAmount: 500.0,
        maxRebateAmount: 800.0,
        rebateRate: 0.012,
        period: 'weekly',
        vipLevelRequired: 2,
      ),
    ];
  }
}
