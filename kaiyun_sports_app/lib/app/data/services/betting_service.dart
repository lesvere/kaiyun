import '../api/api_service.dart';
import '../api/api_config.dart';
import '../models/betting_models.dart';
import '../models/sports_models.dart';

class BettingService {
  final ApiService _apiService = ApiService();
  
  // 下注
  Future<Map<String, dynamic>> placeBet(BetRequest betRequest) async {
    try {
      final response = await _apiService.post(
        ApiConfig.placeBet,
        data: betRequest.toJson(),
      );
      
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'betId': result['betId'] ?? '',
        'message': result['message'] ?? '投注成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  // 获取投注记录
  Future<List<BetRecord>> getBetRecords(String userId, {int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.betRecords}?userId=$userId&page=$page&pageSize=$pageSize',
      );
      
      final result = _apiService.handleResponse(response);
      final records = result['records'] as List<dynamic>? ?? [];
      
      return records.map((record) => BetRecord.fromJson(record)).toList();
    } catch (e) {
      throw Exception('获取投注记录失败: $e');
    }
  }
  
  // 获取可用投注选项
  Future<List<BetOption>> getAvailableOptions(String matchId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.betSlip}?matchId=$matchId',
      );
      
      final result = _apiService.handleResponse(response);
      final options = result['options'] as List<dynamic>? ?? [];
      
      return options.map((option) => BetOption.fromJson(option)).toList();
    } catch (e) {
      throw Exception('获取投注选项失败: $e');
    }
  }
  
  // 取消投注
  Future<Map<String, dynamic>> cancelBet(String betId) async {
    try {
      final response = await _apiService.post(
        ApiConfig.betCancel,
        data: {'betId': betId},
      );
      
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'message': result['message'] ?? '取消成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }

  Future<List<MatchInfo>> getLiveMatches() async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  Future<List<MatchInfo>> getUpcomingMatches() async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  Future<List<MatchInfo>> getPopularMatches() async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}