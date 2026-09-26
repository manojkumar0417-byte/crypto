import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/coin_model.dart';
import '../providers/coin_detail_provider.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/price_chart_widget.dart';
import '../widgets/stat_tile.dart';

class CoinDetailScreen extends StatelessWidget {
  final CoinModel coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CoinDetailProvider()..loadCoinDetail(coin),
      child: _CoinDetailContent(initialCoin: coin),
    );
  }
}

class _CoinDetailContent extends StatelessWidget {
  final CoinModel initialCoin;

  const _CoinDetailContent({required this.initialCoin});

  @override
  Widget build(BuildContext context) {
    final detailProvider = Provider.of<CoinDetailProvider>(context);
    final watchlistProvider = Provider.of<WatchlistProvider>(context);
    final coin = detailProvider.coin ?? initialCoin;
    final isFav = watchlistProvider.isFavorite(coin.id);

    final hovered = detailProvider.hoveredPoint;
    final displayPrice = hovered != null ? hovered.price : coin.currentPrice;
    final formattedDisplayPrice = displayPrice >= 1
        ? NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(displayPrice)
        : '\$${displayPrice.toStringAsFixed(6)}';

    final isBullish = detailProvider.isChartPositive;
    final chartChange = detailProvider.chartChangePercentage;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                coin.image,
                width: 26,
                height: 26,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.monetization_on, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              coin.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                coin.symbol,
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFav ? AppTheme.starGold : AppTheme.textPrimary,
              size: 26,
            ),
            onPressed: () {
              watchlistProvider.toggleFavorite(coin.id);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & Rank Badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    'Rank #${coin.marketCapRank}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.cyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    coin.category,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.cyan),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Price & Percentage Header
            Text(
              formattedDisplayPrice,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isBullish ? AppTheme.greenLight : AppTheme.redLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isBullish ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: isBullish ? AppTheme.green : AppTheme.red,
                        size: 16,
                      ),
                      Text(
                        '${isBullish ? '+' : ''}${chartChange.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: isBullish ? AppTheme.green : AppTheme.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  hovered != null
                      ? DateFormat('MMM d, HH:mm').format(hovered.dateTime)
                      : 'Past ${detailProvider.selectedDays == 1 ? '24 Hours' : '${detailProvider.selectedDays} Days'}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Interactive Chart
            Container(
              padding: const EdgeInsets.only(top: 14, right: 8, bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  PriceChartWidget(
                    points: detailProvider.chartPoints,
                    isPositive: isBullish,
                    onTouchPoint: (point) {
                      detailProvider.setHoveredPoint(point);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Timeframe Switcher
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimeframeBtn(context, detailProvider, '24H', 1),
                        _buildTimeframeBtn(context, detailProvider, '7D', 7),
                        _buildTimeframeBtn(context, detailProvider, '30D', 30),
                        _buildTimeframeBtn(context, detailProvider, '90D', 90),
                        _buildTimeframeBtn(context, detailProvider, '1Y', 365),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 24H Price Range Bar
            _buildPriceRangeBar(coin),
            const SizedBox(height: 20),

            // Key Market Statistics Grid
            const Text(
              'Market Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                StatTile(
                  label: 'Market Capitalization',
                  value: coin.formattedMarketCap,
                  subtitle: 'Rank #${coin.marketCapRank}',
                  icon: Icons.pie_chart_outline_rounded,
                ),
                StatTile(
                  label: '24h Trading Volume',
                  value: coin.formattedVolume,
                  icon: Icons.bar_chart_rounded,
                ),
                StatTile(
                  label: 'Circulating Supply',
                  value: CoinModel.formatCompactNumber(coin.circulatingSupply),
                  subtitle: coin.totalSupply > 0
                      ? '${((coin.circulatingSupply / coin.totalSupply) * 100).toStringAsFixed(1)}% of total'
                      : null,
                  icon: Icons.token_rounded,
                ),
                StatTile(
                  label: 'Total Supply',
                  value: coin.totalSupply > 0
                      ? CoinModel.formatCompactNumber(coin.totalSupply)
                      : 'Infinite',
                  icon: Icons.all_inclusive_rounded,
                ),
                StatTile(
                  label: 'All-Time High (ATH)',
                  value: coin.ath >= 1 ? '\$${coin.ath.toStringAsFixed(2)}' : '\$${coin.ath.toStringAsFixed(4)}',
                  subtitle: '${coin.athChangePercentage.toStringAsFixed(1)}%',
                  icon: Icons.trending_up_rounded,
                  highlightColor: AppTheme.red,
                ),
                StatTile(
                  label: 'All-Time Low (ATL)',
                  value: coin.atl >= 1 ? '\$${coin.atl.toStringAsFixed(2)}' : '\$${coin.atl.toStringAsFixed(5)}',
                  icon: Icons.trending_down_rounded,
                  highlightColor: AppTheme.green,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // About / Description Card
            if (coin.description.isNotEmpty) ...[
              const Text(
                'About',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                ),
                child: Text(
                  coin.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Research Links & Resources
            const Text(
              'Research & Community',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildLinkChip(Icons.language_rounded, 'Official Website', () {}),
                _buildLinkChip(Icons.explore_rounded, 'Block Explorer', () {}),
                _buildLinkChip(Icons.forum_rounded, 'Reddit Community', () {}),
                _buildLinkChip(Icons.code_rounded, 'Source Code', () {}),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeBtn(
    BuildContext context,
    CoinDetailProvider provider,
    String label,
    int days,
  ) {
    final isSelected = provider.selectedDays == days;
    return GestureDetector(
      onTap: () => provider.changeTimeframe(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.green : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRangeBar(CoinModel coin) {
    final low = coin.low24h;
    final high = coin.high24h;
    final current = coin.currentPrice;
    final range = (high - low) == 0 ? 1.0 : (high - low);
    final progress = ((current - low) / range).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '24h Price Range',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.green),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low: \$${low.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              Text(
                'High: \$${high.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkChip(IconData icon, String label, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppTheme.cyan),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
      ),
      backgroundColor: AppTheme.surface,
      side: const BorderSide(color: AppTheme.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: onTap,
    );
  }
}
