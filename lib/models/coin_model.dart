import 'package:intl/intl.dart';

class CoinModel {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double priceChangePercentage7d;
  final double circulatingSupply;
  final double totalSupply;
  final double ath;
  final double athChangePercentage;
  final double atl;
  final String category;
  final String description;
  final List<double> sparklineIn7d;

  CoinModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.priceChangePercentage7d,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.ath,
    required this.athChangePercentage,
    required this.atl,
    required this.category,
    required this.description,
    required this.sparklineIn7d,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    List<double> parseSparkline(dynamic spark) {
      if (spark is List) {
        return spark.map((e) => (e as num).toDouble()).toList();
      }
      return [];
    }

    double toDoubleSafe(dynamic val, [double defaultVal = 0.0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    int toIntSafe(dynamic val, [int defaultVal = 999]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    return CoinModel(
      id: json['id']?.toString() ?? '',
      symbol: (json['symbol']?.toString() ?? '').toUpperCase(),
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      currentPrice: toDoubleSafe(json['current_price']),
      marketCap: toDoubleSafe(json['market_cap']),
      marketCapRank: toIntSafe(json['market_cap_rank']),
      totalVolume: toDoubleSafe(json['total_volume']),
      high24h: toDoubleSafe(json['high_24h']),
      low24h: toDoubleSafe(json['low_24h']),
      priceChange24h: toDoubleSafe(json['price_change_24h']),
      priceChangePercentage24h: toDoubleSafe(json['price_change_percentage_24h']),
      priceChangePercentage7d: toDoubleSafe(json['price_change_percentage_7d']),
      circulatingSupply: toDoubleSafe(json['circulating_supply']),
      totalSupply: toDoubleSafe(json['total_supply']),
      ath: toDoubleSafe(json['ath']),
      athChangePercentage: toDoubleSafe(json['ath_change_percentage']),
      atl: toDoubleSafe(json['atl']),
      category: json['category']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      sparklineIn7d: parseSparkline(json['sparkline_in_7d']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': image,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'market_cap_rank': marketCapRank,
      'total_volume': totalVolume,
      'high_24h': high24h,
      'low_24h': low24h,
      'price_change_24h': priceChange24h,
      'price_change_percentage_24h': priceChangePercentage24h,
      'price_change_percentage_7d': priceChangePercentage7d,
      'circulating_supply': circulatingSupply,
      'total_supply': totalSupply,
      'ath': ath,
      'ath_change_percentage': athChangePercentage,
      'atl': atl,
      'category': category,
      'description': description,
      'sparkline_in_7d': sparklineIn7d,
    };
  }

  bool get isPositive24h => priceChangePercentage24h >= 0;

  String get formattedPrice {
    if (currentPrice >= 1000) {
      final f = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
      return f.format(currentPrice);
    } else if (currentPrice >= 1) {
      return '\$${currentPrice.toStringAsFixed(2)}';
    } else if (currentPrice >= 0.0001) {
      return '\$${currentPrice.toStringAsFixed(4)}';
    } else {
      return '\$${currentPrice.toStringAsFixed(7)}';
    }
  }

  String get formattedPriceChange24h {
    final prefix = isPositive24h ? '+' : '';
    return '$prefix${priceChangePercentage24h.toStringAsFixed(2)}%';
  }

  String get formattedMarketCap => formatCompactNumber(marketCap);
  String get formattedVolume => formatCompactNumber(totalVolume);

  static String formatCompactNumber(double value) {
    if (value >= 1e12) {
      return '\$${(value / 1e12).toStringAsFixed(2)}T';
    } else if (value >= 1e9) {
      return '\$${(value / 1e9).toStringAsFixed(2)}B';
    } else if (value >= 1e6) {
      return '\$${(value / 1e6).toStringAsFixed(2)}M';
    } else if (value >= 1e3) {
      return '\$${(value / 1e3).toStringAsFixed(2)}K';
    }
    return '\$${value.toStringAsFixed(2)}';
  }
}
