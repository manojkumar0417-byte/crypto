import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crypto_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_tile.dart';
import '../widgets/coin_card.dart';
import '../widgets/loading_shimmer.dart';

class MarketStatsScreen extends StatelessWidget {
  const MarketStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CryptoProvider>(context);
    final stats = provider.marketStats;

    if (stats == null) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: LoadingShimmerList(count: 4)),
      );
    }

    final gainers = provider.trendingData['top_gainers'] ?? [];
    final losers = provider.trendingData['top_losers'] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Market Statistics & Research',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.green,
        backgroundColor: AppTheme.surface,
        onRefresh: () => provider.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Global Market Highlights
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  StatTile(
                    label: 'Global Market Cap',
                    value: stats.formattedTotalMarketCap,
                    subtitle: '${stats.isMarketCapPositive ? '+' : ''}${stats.marketCapChangePercentage24h.toStringAsFixed(2)}% in 24h',
                    highlightColor: stats.isMarketCapPositive ? AppTheme.green : AppTheme.red,
                    icon: Icons.public_rounded,
                  ),
                  StatTile(
                    label: '24h Total Volume',
                    value: stats.formatted24hVolume,
                    icon: Icons.swap_horiz_rounded,
                  ),
                  StatTile(
                    label: 'Active Cryptos',
                    value: stats.activeCryptocurrencies.toString(),
                    icon: Icons.toll_rounded,
                  ),
                  StatTile(
                    label: 'Tracked Exchanges',
                    value: stats.markets.toString(),
                    icon: Icons.storefront_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Fear & Greed Sentiment Meter
              const Text(
                'Market Sentiment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fear & Greed Index',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stats.sentimentLabel,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: stats.sentimentIndex >= 55
                                    ? AppTheme.green
                                    : (stats.sentimentIndex >= 45 ? AppTheme.starGold : AppTheme.red),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            '${stats.sentimentIndex} / 100',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Visual meter bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 10,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.red,
                              AppTheme.starGold,
                              AppTheme.green,
                            ],
                          ),
                        ),
                        child: Align(
                          alignment: Alignment((stats.sentimentIndex / 50.0) - 1.0, 0),
                          child: Container(
                            width: 6,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black45, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Extreme Fear (0)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                        Text('Neutral (50)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                        Text('Extreme Greed (100)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Dominance Breakdown
              const Text(
                'Market Dominance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Multi-color segmented dominance bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: (stats.btcDominance * 10).toInt(),
                            child: Container(height: 10, color: AppTheme.starGold),
                          ),
                          Expanded(
                            flex: (stats.ethDominance * 10).toInt(),
                            child: Container(height: 10, color: AppTheme.cyan),
                          ),
                          Expanded(
                            flex: (stats.solDominance * 10).toInt(),
                            child: Container(height: 10, color: const Color(0xFF9945FF)),
                          ),
                          Expanded(
                            flex: ((100.0 - stats.btcDominance - stats.ethDominance - stats.solDominance) * 10).toInt(),
                            child: Container(height: 10, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDomBadge('BTC', '${stats.btcDominance}%', AppTheme.starGold),
                        _buildDomBadge('ETH', '${stats.ethDominance}%', AppTheme.cyan),
                        _buildDomBadge('SOL', '${stats.solDominance}%', const Color(0xFF9945FF)),
                        _buildDomBadge(
                          'Others',
                          '${(100.0 - stats.btcDominance - stats.ethDominance - stats.solDominance).toStringAsFixed(1)}%',
                          AppTheme.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Top 24h Gainers Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.greenLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.trending_up, color: AppTheme.green, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Top 24h Gainers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (gainers.isNotEmpty)
                Column(
                  children: gainers.take(3).map((coin) => CoinCard(coin: coin)).toList(),
                ),
              const SizedBox(height: 18),

              // Top 24h Losers Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.redLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.trending_down, color: AppTheme.red, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Top 24h Losers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (losers.isNotEmpty)
                Column(
                  children: losers.take(3).map((coin) => CoinCard(coin: coin)).toList(),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDomBadge(String label, String value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }
}
