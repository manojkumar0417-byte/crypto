import 'package:flutter/foundation.dart';
import '../models/coin_model.dart';
import '../models/market_stats_model.dart';
import '../services/crypto_api_service.dart';

enum MarketStatus { initial, loading, loaded, error }

class CryptoProvider with ChangeNotifier {
  final CryptoApiService _apiService = CryptoApiService();

  MarketStatus _status = MarketStatus.initial;
  MarketStatus get status => _status;

  List<CoinModel> _coins = [];
  List<CoinModel> get coins => _coins;

  MarketStatsModel? _marketStats;
  MarketStatsModel? get marketStats => _marketStats;

  Map<String, List<CoinModel>> _trendingData = {};
  Map<String, List<CoinModel>> get trendingData => _trendingData;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _sortBy = 'market_cap_rank';
  String get sortBy => _sortBy;

  String _order = 'asc';
  String get order => _order;

  final List<String> categories = [
    'All',
    'Layer 1',
    'DeFi',
    'Layer 2',
    'AI & Big Data',
    'Meme',
  ];

  CryptoProvider() {
    loadMarketData();
  }

  Future<void> loadMarketData() async {
    _status = MarketStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getCoins(
          category: _selectedCategory == 'All' ? null : _selectedCategory,
          search: _searchQuery,
          sortBy: _sortBy,
          order: _order,
        ),
        _apiService.getMarketStats(),
        _apiService.getTrending(),
      ]);

      _coins = results[0] as List<CoinModel>;
      _marketStats = results[1] as MarketStatsModel;
      _trendingData = results[2] as Map<String, List<CoinModel>>;
      _status = MarketStatus.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load crypto market data: $e';
      _status = MarketStatus.error;
    }

    notifyListeners();
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    loadMarketData();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadMarketData();
  }

  void setSorting(String sortBy, {String? order}) {
    _sortBy = sortBy;
    if (order != null) {
      _order = order;
    } else {
      // Toggle order if clicking same sort
      _order = (_order == 'asc') ? 'desc' : 'asc';
    }
    loadMarketData();
  }

  Future<void> refresh() async {
    await loadMarketData();
  }
}
