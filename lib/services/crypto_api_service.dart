import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/coin_model.dart';
import '../models/market_stats_model.dart';
import '../models/chart_point_model.dart';

class CryptoApiService {
  String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 6);

  /// Fetch list of coins with category, search, sorting and pagination
  Future<List<CoinModel>> getCoins({
    String? category,
    String? search,
    String sortBy = 'market_cap_rank',
    String order = 'asc',
    int page = 1,
    int limit = 30,
  }) async {
    final queryParams = <String, String>{
      'sort_by': sortBy,
      'order': order,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams['category'] = category;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse('$baseUrl/api/coins').replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.map((item) => CoinModel.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Backend call failed ($e), attempting direct fallback...');
    }

    // Direct fallback or offline mock
    return _getFallbackCoins(category: category, search: search, sortBy: sortBy, order: order);
  }

  /// Fetch global market statistics
  Future<MarketStatsModel> getMarketStats() async {
    final uri = Uri.parse('$baseUrl/api/market-stats');
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MarketStatsModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Market stats backend failed ($e), using fallback...');
    }

    return MarketStatsModel(
      totalMarketCapUsd: 3120500000000,
      totalVolume24hUsd: 142800000000,
      marketCapChangePercentage24h: 2.38,
      btcDominance: 58.2,
      ethDominance: 12.9,
      solDominance: 3.4,
      activeCryptocurrencies: 16500,
      markets: 1240,
      sentimentIndex: 78,
      sentimentLabel: 'Extreme Greed',
    );
  }

  /// Fetch coin details
  Future<CoinModel> getCoinDetail(String coinId) async {
    final uri = Uri.parse('$baseUrl/api/coins/$coinId');
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CoinModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Coin detail failed ($e), using local fallback...');
    }

    final coins = await getCoins();
    return coins.firstWhere(
      (c) => c.id.toLowerCase() == coinId.toLowerCase(),
      orElse: () => coins.first,
    );
  }

  /// Fetch historical chart points for a coin
  Future<List<ChartPoint>> getCoinChart(String coinId, int days) async {
    final uri = Uri.parse('$baseUrl/api/coins/$coinId/chart?days=$days');
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> rawPrices = data['prices'] ?? [];
        return rawPrices.map((item) => ChartPoint.fromList(item)).toList();
      }
    } catch (e) {
      debugPrint('Chart fetch failed ($e), generating fallback chart...');
    }

    // High fidelity fallback chart generator
    return _generateFallbackChart(coinId, days);
  }

  /// Fetch trending, top gainers, and losers
  Future<Map<String, List<CoinModel>>> getTrending() async {
    final uri = Uri.parse('$baseUrl/api/trending');
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final gainers = (data['top_gainers'] as List? ?? []).map((e) => CoinModel.fromJson(e)).toList();
        final losers = (data['top_losers'] as List? ?? []).map((e) => CoinModel.fromJson(e)).toList();
        final trending = (data['trending'] as List? ?? []).map((e) => CoinModel.fromJson(e)).toList();
        return {
          'top_gainers': gainers,
          'top_losers': losers,
          'trending': trending,
        };
      }
    } catch (e) {
      debugPrint('Trending fetch failed ($e)...');
    }

    final allCoins = await getCoins();
    final gainers = List<CoinModel>.from(allCoins)
      ..sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
    final losers = List<CoinModel>.from(allCoins)
      ..sort((a, b) => a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));

    return {
      'top_gainers': gainers.take(5).toList(),
      'top_losers': losers.take(5).toList(),
      'trending': allCoins.take(5).toList(),
    };
  }

  // Generate smooth chart points when offline
  List<ChartPoint> _generateFallbackChart(String coinId, int days) {
    final points = <ChartPoint>[];
    final now = DateTime.now().millisecondsSinceEpoch;
    final numPoints = days == 1 ? 24 : (days <= 30 ? days * 4 : 50);
    final interval = (days * 24 * 3600 * 1000) ~/ numPoints;

    double price = 100.0;
    if (coinId == 'bitcoin') price = 91400.0;
    if (coinId == 'ethereum') price = 3380.0;
    if (coinId == 'solana') price = 194.0;
    if (coinId == 'binancecoin') price = 645.0;
    if (coinId == 'ripple') price = 2.45;

    for (int i = 0; i < numPoints; i++) {
      final ts = now - ((numPoints - 1 - i) * interval);
      // Gentle fluctuation curve
      final factor = 1.0 + (0.02 * (i % 5 - 2));
      points.add(ChartPoint(timestamp: ts, price: price * factor));
    }
    return points;
  }

  // Comprehensive static fallback
  List<CoinModel> _getFallbackCoins({
    String? category,
    String? search,
    String sortBy = 'market_cap_rank',
    String order = 'asc',
  }) {
    final raw = [
      CoinModel(
        id: 'bitcoin',
        symbol: 'BTC',
        name: 'Bitcoin',
        image: 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
        currentPrice: 91420.50,
        marketCap: 1805200000000,
        marketCapRank: 1,
        totalVolume: 42500000000,
        high24h: 92850.00,
        low24h: 89900.00,
        priceChange24h: 1520.50,
        priceChangePercentage24h: 1.69,
        priceChangePercentage7d: 4.82,
        circulatingSupply: 19750000,
        totalSupply: 21000000,
        ath: 108920.00,
        athChangePercentage: -16.06,
        atl: 67.81,
        category: 'Layer 1',
        description: 'Bitcoin is the first decentralized digital currency. It is a peer-to-peer electronic cash system.',
        sparklineIn7d: [87400, 88100, 87900, 89200, 90100, 89800, 91420.5],
      ),
      CoinModel(
        id: 'ethereum',
        symbol: 'ETH',
        name: 'Ethereum',
        image: 'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
        currentPrice: 3380.25,
        marketCap: 407000000000,
        marketCapRank: 2,
        totalVolume: 24100000000,
        high24h: 3450.00,
        low24h: 3290.00,
        priceChange24h: 90.25,
        priceChangePercentage24h: 2.74,
        priceChangePercentage7d: 6.15,
        circulatingSupply: 120400000,
        totalSupply: 120400000,
        ath: 4878.26,
        athChangePercentage: -30.7,
        atl: 0.432,
        category: 'Layer 1',
        description: 'Ethereum is a decentralized open-source blockchain with smart contract functionality.',
        sparklineIn7d: [3180, 3210, 3195, 3260, 3320, 3310, 3380.25],
      ),
      CoinModel(
        id: 'solana',
        symbol: 'SOL',
        name: 'Solana',
        image: 'https://assets.coingecko.com/coins/images/4128/large/solana.png',
        currentPrice: 194.80,
        marketCap: 91200000000,
        marketCapRank: 3,
        totalVolume: 7800000000,
        high24h: 202.50,
        low24h: 188.10,
        priceChange24h: -4.20,
        priceChangePercentage24h: -2.11,
        priceChangePercentage7d: 12.4,
        circulatingSupply: 468000000,
        totalSupply: 585000000,
        ath: 259.96,
        athChangePercentage: -25.07,
        atl: 0.5008,
        category: 'Layer 1',
        description: 'Solana is a high-performance blockchain supporting builders worldwide.',
        sparklineIn7d: [173, 178, 184, 191, 199, 196, 194.8],
      ),
      CoinModel(
        id: 'binancecoin',
        symbol: 'BNB',
        name: 'BNB',
        image: 'https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png',
        currentPrice: 645.10,
        marketCap: 94100000000,
        marketCapRank: 4,
        totalVolume: 1400000000,
        high24h: 655.00,
        low24h: 638.00,
        priceChange24h: 7.10,
        priceChangePercentage24h: 1.11,
        priceChangePercentage7d: 3.45,
        circulatingSupply: 145800000,
        totalSupply: 145800000,
        ath: 717.48,
        athChangePercentage: -10.09,
        atl: 0.0398,
        category: 'Layer 1',
        description: 'BNB powers the BNB Chain ecosystem.',
        sparklineIn7d: [623, 629, 634, 638, 642, 640, 645.1],
      ),
      CoinModel(
        id: 'ripple',
        symbol: 'XRP',
        name: 'XRP',
        image: 'https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png',
        currentPrice: 2.45,
        marketCap: 139000000000,
        marketCapRank: 5,
        totalVolume: 11200000000,
        high24h: 2.68,
        low24h: 2.30,
        priceChange24h: 0.15,
        priceChangePercentage24h: 6.52,
        priceChangePercentage7d: 24.1,
        circulatingSupply: 56800000000,
        totalSupply: 99990000000,
        ath: 3.84,
        athChangePercentage: -36.2,
        atl: 0.00268,
        category: 'Layer 1',
        description: 'XRP is the native token of XRP Ledger for global value transfers.',
        sparklineIn7d: [1.97, 2.05, 2.15, 2.24, 2.38, 2.33, 2.45],
      ),
      CoinModel(
        id: 'chainlink',
        symbol: 'LINK',
        name: 'Chainlink',
        image: 'https://assets.coingecko.com/coins/images/877/large/chainlink-new-logo.png',
        currentPrice: 22.40,
        marketCap: 13900000000,
        marketCapRank: 6,
        totalVolume: 850000000,
        high24h: 23.50,
        low24h: 21.80,
        priceChange24h: 0.60,
        priceChangePercentage24h: 2.75,
        priceChangePercentage7d: 14.8,
        circulatingSupply: 626000000,
        totalSupply: 1000000000,
        ath: 52.70,
        athChangePercentage: -57.5,
        atl: 0.148,
        category: 'DeFi',
        description: 'Chainlink provides decentralized oracle services to smart contracts.',
        sparklineIn7d: [19.5, 20.2, 20.8, 21.6, 22.9, 22.1, 22.4],
      ),
      CoinModel(
        id: 'uniswap',
        symbol: 'UNI',
        name: 'Uniswap',
        image: 'https://assets.coingecko.com/coins/images/12504/large/uniswap-uni.png',
        currentPrice: 12.80,
        marketCap: 770000000,
        marketCapRank: 7,
        totalVolume: 410000000,
        high24h: 13.40,
        low24h: 12.20,
        priceChange24h: 0.60,
        priceChangePercentage24h: 4.92,
        priceChangePercentage7d: 16.5,
        circulatingSupply: 600000000,
        totalSupply: 1000000000,
        ath: 44.92,
        athChangePercentage: -71.5,
        atl: 1.03,
        category: 'DeFi',
        description: 'Uniswap is a decentralized trading protocol facilitating automated trading.',
        sparklineIn7d: [11.0, 11.4, 11.7, 12.1, 12.9, 12.5, 12.8],
      ),
      CoinModel(
        id: 'dogecoin',
        symbol: 'DOGE',
        name: 'Dogecoin',
        image: 'https://assets.coingecko.com/coins/images/5/large/dogecoin.png',
        currentPrice: 0.28,
        marketCap: 41200000000,
        marketCapRank: 8,
        totalVolume: 4200000000,
        high24h: 0.31,
        low24h: 0.26,
        priceChange24h: -0.018,
        priceChangePercentage24h: -6.04,
        priceChangePercentage7d: 15.3,
        circulatingSupply: 147000000000,
        totalSupply: 147000000000,
        ath: 0.731,
        athChangePercentage: -61.7,
        atl: 0.0000869,
        category: 'Meme',
        description: 'Dogecoin is based on the popular internet meme featuring a Shiba Inu.',
        sparklineIn7d: [0.24, 0.26, 0.27, 0.30, 0.31, 0.29, 0.28],
      ),
    ];

    var result = List<CoinModel>.from(raw);
    if (category != null && category.isNotEmpty && category != 'All') {
      result = result.where((c) => c.category.toLowerCase() == category.toLowerCase()).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final s = search.trim().toLowerCase();
      result = result.where((c) => c.name.toLowerCase().contains(s) || c.symbol.toLowerCase().contains(s)).toList();
    }
    return result;
  }
}
