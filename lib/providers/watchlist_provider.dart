import 'package:flutter/foundation.dart';
import '../models/coin_model.dart';
import '../services/watchlist_service.dart';

class WatchlistProvider with ChangeNotifier {
  final WatchlistService _watchlistService = WatchlistService();
  Set<String> _watchlistIds = {};

  Set<String> get watchlistIds => _watchlistIds;

  WatchlistProvider() {
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    _watchlistIds = await _watchlistService.getWatchlist();
    notifyListeners();
  }

  bool isFavorite(String coinId) {
    return _watchlistIds.contains(coinId.toLowerCase());
  }

  Future<void> toggleFavorite(String coinId) async {
    final lowerId = coinId.toLowerCase();
    await _watchlistService.toggleFavorite(lowerId);
    if (_watchlistIds.contains(lowerId)) {
      _watchlistIds.remove(lowerId);
    } else {
      _watchlistIds.add(lowerId);
    }
    notifyListeners();
  }

  List<CoinModel> filterWatchlistCoins(List<CoinModel> allCoins) {
    return allCoins.where((c) => _watchlistIds.contains(c.id.toLowerCase())).toList();
  }
}
