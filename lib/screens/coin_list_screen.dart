import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crypto_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';

class CoinListScreen extends StatefulWidget {
  const CoinListScreen({super.key});

  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortModal(BuildContext context, CryptoProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sort Cryptocurrencies',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSortOption(context, provider, 'Market Cap Rank', 'market_cap_rank'),
                _buildSortOption(context, provider, 'Price', 'price'),
                _buildSortOption(context, provider, '24h Price Change', 'change'),
                _buildSortOption(context, provider, '24h Volume', 'volume'),
                _buildSortOption(context, provider, 'Name', 'name'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(
                          provider.order == 'asc' ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 16,
                          color: AppTheme.green,
                        ),
                        label: Text(
                          provider.order == 'asc' ? 'Ascending' : 'Descending',
                          style: const TextStyle(color: AppTheme.green),
                        ),
                        onPressed: () {
                          provider.setSorting(
                            provider.sortBy,
                            order: provider.order == 'asc' ? 'desc' : 'asc',
                          );
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.green),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    CryptoProvider provider,
    String title,
    String key,
  ) {
    final isSelected = provider.sortBy == key;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.green : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.green, size: 20) : null,
      onTap: () {
        provider.setSorting(key);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cryptoProvider = Provider.of<CryptoProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.currency_bitcoin_rounded, color: AppTheme.green, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'CryptoGecko',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sort coins',
            icon: const Icon(Icons.sort_rounded, color: AppTheme.textPrimary),
            onPressed: () => _showSortModal(context, cryptoProvider),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary),
            onPressed: () => cryptoProvider.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Market Quick Header Banner
          if (cryptoProvider.marketStats != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Market Cap',
                        style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            cryptoProvider.marketStats!.formattedTotalMarketCap,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${cryptoProvider.marketStats!.isMarketCapPositive ? '+' : ''}${cryptoProvider.marketStats!.marketCapChangePercentage24h.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: cryptoProvider.marketStats!.isMarketCapPositive ? AppTheme.green : AppTheme.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(height: 24, width: 1, color: AppTheme.border),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '24h Vol',
                        style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cryptoProvider.marketStats!.formatted24hVolume,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(height: 24, width: 1, color: AppTheme.border),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BTC Dom',
                        style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${cryptoProvider.marketStats!.btcDominance}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.starGold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search coins (e.g. BTC, Solana, ETH)...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.textMuted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            cryptoProvider.setSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) {
                  cryptoProvider.setSearchQuery(val);
                },
              ),
            ),
          ),

          // Category Chips Filter
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: cryptoProvider.categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = cryptoProvider.categories[index];
                final isSelected = cryptoProvider.selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.black : AppTheme.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.green,
                  backgroundColor: AppTheme.surface,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppTheme.green : AppTheme.border,
                    ),
                  ),
                  onSelected: (_) => cryptoProvider.setCategory(cat),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Coin List Header & Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
            child: Row(
              children: [
                Text(
                  '${cryptoProvider.coins.length} Cryptocurrencies',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  'Sorted by ${cryptoProvider.sortBy.replaceAll('_', ' ')} (${cryptoProvider.order})',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Main Coin List View / States
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.green,
              backgroundColor: AppTheme.surface,
              onRefresh: () => cryptoProvider.refresh(),
              child: _buildListContent(cryptoProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(CryptoProvider provider) {
    if (provider.status == MarketStatus.loading && provider.coins.isEmpty) {
      return const LoadingShimmerList();
    }

    if (provider.status == MarketStatus.error && provider.coins.isEmpty) {
      return ErrorView(
        message: provider.errorMessage,
        onRetry: () => provider.refresh(),
      );
    }

    if (provider.coins.isEmpty) {
      return EmptyView(
        title: 'No Cryptocurrencies Found',
        message: 'No coins matched your search or category filter. Try clearing filters.',
        actionLabel: 'Reset Filters',
        onAction: () {
          _searchController.clear();
          provider.setSearchQuery('');
          provider.setCategory('All');
        },
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: provider.coins.length,
      itemBuilder: (context, index) {
        final coin = provider.coins[index];
        return CoinCard(coin: coin);
      },
    );
  }
}
