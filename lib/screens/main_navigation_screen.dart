import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';
import 'coin_list_screen.dart';
import 'market_stats_screen.dart';
import 'watchlist_screen.dart';
import 'info_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = Provider.of<WatchlistProvider>(context);
    final watchlistCount = watchlistProvider.watchlistIds.length;

    final screens = [
      const CoinListScreen(),
      const MarketStatsScreen(),
      WatchlistScreen(onExplore: () => _switchTab(0)),
      const InfoScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.border.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _switchTab,
          selectedItemColor: AppTheme.green,
          unselectedItemColor: AppTheme.textMuted,
          backgroundColor: AppTheme.surface,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.candlestick_chart_rounded),
              label: 'Markets',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded),
              label: 'Research',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: watchlistCount > 0,
                label: Text(watchlistCount.toString()),
                backgroundColor: AppTheme.starGold,
                textColor: Colors.black,
                child: const Icon(Icons.star_rounded),
              ),
              label: 'Watchlist',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.info_outline_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
