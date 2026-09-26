import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coin_model.dart';
import '../providers/watchlist_provider.dart';
import '../screens/coin_detail_screen.dart';
import '../theme/app_theme.dart';
import 'sparkline_widget.dart';

class CoinCard extends StatelessWidget {
  final CoinModel coin;

  const CoinCard({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = Provider.of<WatchlistProvider>(context);
    final isFav = watchlistProvider.isFavorite(coin.id);
    final isPositive = coin.isPositive24h;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CoinDetailScreen(coin: coin),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            // Favorite Button
            GestureDetector(
              onTap: () {
                watchlistProvider.toggleFavorite(coin.id);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  isFav ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFav ? AppTheme.starGold : AppTheme.textMuted,
                  size: 22,
                ),
              ),
            ),

            // Rank Badge
            Container(
              width: 22,
              alignment: Alignment.center,
              child: Text(
                '${coin.marketCapRank}',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Coin Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                coin.image,
                width: 36,
                height: 36,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      coin.symbol.isNotEmpty ? coin.symbol[0] : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Name & Symbol
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        coin.symbol,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cap ${coin.formattedMarketCap}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Mini Sparkline
            if (coin.sparklineIn7d.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: SparklineWidget(
                  data: coin.sparklineIn7d,
                  isPositive: isPositive,
                  width: 55,
                  height: 26,
                ),
              ),

            // Price & 24h Change %
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    coin.formattedPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPositive ? AppTheme.greenLight : AppTheme.redLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: isPositive ? AppTheme.green : AppTheme.red,
                          size: 14,
                        ),
                        Text(
                          coin.formattedPriceChange24h,
                          style: TextStyle(
                            color: isPositive ? AppTheme.green : AppTheme.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
