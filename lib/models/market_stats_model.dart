class MarketStatsModel {
  final double totalMarketCapUsd;
  final double totalVolume24hUsd;
  final double marketCapChangePercentage24h;
  final double btcDominance;
  final double ethDominance;
  final double solDominance;
  final int activeCryptocurrencies;
  final int markets;
  final int sentimentIndex;
  final String sentimentLabel;

  MarketStatsModel({
    required this.totalMarketCapUsd,
    required this.totalVolume24hUsd,
    required this.marketCapChangePercentage24h,
    required this.btcDominance,
    required this.ethDominance,
    required this.solDominance,
    required this.activeCryptocurrencies,
    required this.markets,
    required this.sentimentIndex,
    required this.sentimentLabel,
  });

  factory MarketStatsModel.fromJson(Map<String, dynamic> json) {
    double toDoubleSafe(dynamic val, [double defaultVal = 0.0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    int toIntSafe(dynamic val, [int defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    return MarketStatsModel(
      totalMarketCapUsd: toDoubleSafe(json['total_market_cap_usd']),
      totalVolume24hUsd: toDoubleSafe(json['total_volume_24h_usd']),
      marketCapChangePercentage24h: toDoubleSafe(json['market_cap_change_percentage_24h_usd']),
      btcDominance: toDoubleSafe(json['btc_dominance'], 58.0),
      ethDominance: toDoubleSafe(json['eth_dominance'], 13.0),
      solDominance: toDoubleSafe(json['sol_dominance'], 3.5),
      activeCryptocurrencies: toIntSafe(json['active_cryptocurrencies'], 15000),
      markets: toIntSafe(json['markets'], 1200),
      sentimentIndex: toIntSafe(json['sentiment_index'], 75),
      sentimentLabel: json['sentiment_label']?.toString() ?? 'Greed',
    );
  }

  bool get isMarketCapPositive => marketCapChangePercentage24h >= 0;

  String get formattedTotalMarketCap {
    if (totalMarketCapUsd >= 1e12) {
      return '\$${(totalMarketCapUsd / 1e12).toStringAsFixed(2)}T';
    } else if (totalMarketCapUsd >= 1e9) {
      return '\$${(totalMarketCapUsd / 1e9).toStringAsFixed(2)}B';
    }
    return '\$${totalMarketCapUsd.toStringAsFixed(0)}';
  }

  String get formatted24hVolume {
    if (totalVolume24hUsd >= 1e9) {
      return '\$${(totalVolume24hUsd / 1e9).toStringAsFixed(2)}B';
    } else if (totalVolume24hUsd >= 1e6) {
      return '\$${(totalVolume24hUsd / 1e6).toStringAsFixed(2)}M';
    }
    return '\$${totalVolume24hUsd.toStringAsFixed(0)}';
  }
}
