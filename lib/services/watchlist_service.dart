import 'package:shared_preferences/shared_preferences.dart';

class WatchlistService {
  static const String _key = 'cryptogecko_watchlist_ids';

  Future<Set<String>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list == null) {
      // Default initial favorites
      return {'bitcoin', 'ethereum', 'solana'};
    }
    return list.toSet();
  }

  Future<bool> toggleFavorite(String coinId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getWatchlist();
    bool isAdded;
    if (current.contains(coinId)) {
      current.remove(coinId);
      isAdded = false;
    } else {
      current.add(coinId);
      isAdded = true;
    }
    await prefs.setStringList(_key, current.toList());
    return isAdded;
  }

  Future<bool> isFavorite(String coinId) async {
    final list = await getWatchlist();
    return list.contains(coinId);
  }
}
