import 'package:flutter/foundation.dart';
import '../models/coin_model.dart';
import '../models/chart_point_model.dart';
import '../services/crypto_api_service.dart';

enum DetailStatus { initial, loading, loaded, error }

class CoinDetailProvider with ChangeNotifier {
  final CryptoApiService _apiService = CryptoApiService();

  DetailStatus _status = DetailStatus.initial;
  DetailStatus get status => _status;

  CoinModel? _coin;
  CoinModel? get coin => _coin;

  List<ChartPoint> _chartPoints = [];
  List<ChartPoint> get chartPoints => _chartPoints;

  int _selectedDays = 7;
  int get selectedDays => _selectedDays;

  ChartPoint? _hoveredPoint;
  ChartPoint? get hoveredPoint => _hoveredPoint;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> loadCoinDetail(CoinModel initialCoin) async {
    _coin = initialCoin;
    _status = DetailStatus.loading;
    _errorMessage = '';
    _hoveredPoint = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getCoinDetail(initialCoin.id),
        _apiService.getCoinChart(initialCoin.id, _selectedDays),
      ]);

      _coin = results[0] as CoinModel;
      _chartPoints = results[1] as List<ChartPoint>;
      _status = DetailStatus.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load details: $e';
      _status = DetailStatus.error;
    }

    notifyListeners();
  }

  Future<void> changeTimeframe(int days) async {
    if (_selectedDays == days || _coin == null) return;
    _selectedDays = days;
    _hoveredPoint = null;
    notifyListeners();

    try {
      _chartPoints = await _apiService.getCoinChart(_coin!.id, days);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating timeframe: $e');
    }
  }

  void setHoveredPoint(ChartPoint? point) {
    if (_hoveredPoint != point) {
      _hoveredPoint = point;
      notifyListeners();
    }
  }

  double get chartChangePercentage {
    if (_chartPoints.isEmpty) return 0.0;
    final first = _chartPoints.first.price;
    final current = _hoveredPoint?.price ?? _chartPoints.last.price;
    if (first == 0) return 0.0;
    return ((current - first) / first) * 100;
  }

  bool get isChartPositive => chartChangePercentage >= 0;
}
