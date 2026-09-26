import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/crypto_api_service.dart';
import '../theme/app_theme.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final CryptoApiService _apiService = CryptoApiService();
  String _backendStatus = 'Checking...';
  bool _isBackendHealthy = false;
  bool _isPinging = false;

  @override
  void initState() {
    super.initState();
    _checkBackend();
  }

  Future<void> _checkBackend() async {
    setState(() {
      _isPinging = true;
    });

    try {
      final uri = Uri.parse('${_apiService.baseUrl}/health');
      final resp = await http.get(uri).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _backendStatus = 'Connected (${data['service'] ?? 'Express.js'})';
          _isBackendHealthy = true;
          _isPinging = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _backendStatus = 'Using Resilient Local Mock Fallback';
      _isBackendHealthy = false;
      _isPinging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('System & Backend Info', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backend Connection Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isBackendHealthy ? AppTheme.green : AppTheme.starGold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Backend Service Connection',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Target URL: ${_apiService.baseUrl}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: $_backendStatus',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isBackendHealthy ? AppTheme.green : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isPinging ? null : _checkBackend,
                      icon: _isPinging
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.green),
                            )
                          : const Icon(Icons.sync_rounded, size: 16, color: AppTheme.green),
                      label: const Text('Ping Health Endpoint', style: TextStyle(color: AppTheme.green)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.green),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // App Architecture Card
            const Text('App Architecture & Features', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Column(
                children: [
                  _FeatureRow(
                    icon: Icons.candlestick_chart,
                    title: 'Live Market & Ticker',
                    desc: 'Real-time prices, 24h highs/lows, supply, and volume.',
                  ),
                  Divider(color: AppTheme.border, height: 20),
                  _FeatureRow(
                    icon: Icons.timeline,
                    title: 'Interactive Price Charts',
                    desc: 'fl_chart with 24H, 7D, 30D, 90D, 1Y timeframes and touch tooltips.',
                  ),
                  Divider(color: AppTheme.border, height: 20),
                  _FeatureRow(
                    icon: Icons.filter_alt,
                    title: 'Search, Filter & Sorting',
                    desc: 'Instant symbol search, category tags (Layer 1, DeFi, Meme), and multi-field sorting.',
                  ),
                  Divider(color: AppTheme.border, height: 20),
                  _FeatureRow(
                    icon: Icons.star,
                    title: 'Persistent Watchlist',
                    desc: 'Local storage caching with SharedPreferences.',
                  ),
                  Divider(color: AppTheme.border, height: 20),
                  _FeatureRow(
                    icon: Icons.speed,
                    title: 'Market Statistics & Sentiment',
                    desc: 'Fear & Greed Index visual meter and BTC/ETH dominance breakdown.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.cyan),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
