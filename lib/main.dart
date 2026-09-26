import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/crypto_provider.dart';
import 'providers/watchlist_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CryptoGeckoApp());
}

class CryptoGeckoApp extends StatelessWidget {
  const CryptoGeckoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CryptoProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
      ],
      child: MaterialApp(
        title: 'CryptoGecko',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        // Support mouse and touch dragging across mobile, desktop and web
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          scrollbars: false,
        ),
        home: const MainNavigationScreen(),
      ),
    );
  }
}
