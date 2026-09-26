import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crypto_provider.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_card.dart';
import '../widgets/empty_view.dart';
import '../widgets/stat_tile.dart';

class WatchlistScreen extends StatelessWidget {
  final VoidCallback onExplore;

  const WatchlistScreen({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final cryptoProvider = Provider.of<CryptoProvider>(context);
    final watchlistProvider = Provider.of<WatchlistProvider>(context);

    final favoriteCoins = watchlistProvider.filterWatchlistCoins(cryptoProvider.coins);

    double avgChange = 0.0;
    if (favoriteCoins.isNotEmpty) {
      final sum = favoriteCoins.fold<double>(0.0, (acc, c) => acc + c.priceChangePercentage24h);
      avgChange = sum / favoriteCoins.length;
    }
    final isAvgPositive = avgChange >= 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'My Watchlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: favoriteCoins.isEmpty
          ? EmptyView(
              icon: Icons.star_border_rounded,
              title: 'Your Watchlist is Empty',
              message:
                  'Star any coin from the Market list to track its live price, sparkline, and market stats in one place.',
              actionLabel: 'Explore Markets',
              onAction: onExplore,
            )
          : Column(
              children: [
                // Portfolio / Watchlist Highlights
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          label: 'Tracked Assets',
                          value: '${favoriteCoins.length} Coins',
                          icon: Icons.star_rounded,
                          highlightColor: AppTheme.starGold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatTile(
                          label: 'Avg 24h Performance',
                          value: '${isAvgPositive ? '+' : ''}${avgChange.toStringAsFixed(2)}%',
                          highlightColor: isAvgPositive ? AppTheme.green : AppTheme.red,
                          icon: isAvgPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        'Watchlist Coins',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted.withValues(alpha: 0.9),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Tap star to unpin',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: favoriteCoins.length,
                    itemBuilder: (context, index) {
                      return CoinCard(coin: favoriteCoins[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
