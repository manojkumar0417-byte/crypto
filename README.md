# 🪙 CryptoGecko - Crypto Market & Research App

A modern, high-performance Flutter cryptocurrency research mobile application modeled after CoinGecko and CoinMarketCap. Built with a sleek dark aesthetic, dynamic animations, interactive price charting, live/mock market data, category filtering, search, and watchlist persistence.

---

## 🚀 Key Features

### 1. 📊 Coin List & Market Overview
- **Real-Time Tickers**: Prices, 24h highs/lows, total volume, circulating supply, market capitalization, and 24h percentage change pills.
- **7-Day Trend Sparklines**: Custom-painted mini sparklines displaying 7-day trajectories directly in the coin list.
- **Instant Search**: Search across coin names, symbols (e.g. `BTC`, `SOL`, `ETH`), and identifiers with live updates.
- **Category Filtering**: Filter by crypto sectors including `All`, `Layer 1`, `DeFi`, `Layer 2`, `AI & Big Data`, and `Meme`.
- **Comprehensive Sorting**: Sort by `Market Cap Rank`, `Price`, `24h Price Change`, `24h Volume`, or `Name` in ascending or descending order.

### 2. 📈 Interactive Coin Detail & Price Charts
- **Interactive Line Chart**: Powered by `fl_chart` with touch-and-drag tooltips showing exact price and timestamps.
- **Dynamic Timeframe Switcher**: Seamlessly toggle between `24H`, `7D`, `30D`, `90D`, and `1Y` historical charts.
- **Bullish / Bearish Gradient**: Neon green glowing fill for positive periods and crimson red fill for dips.
- **24h Price Range Bar**: Visual indicator showing current price position between 24h low and high.
- **Deep Market Metrics**: Market Cap rank, 24h Volume, Circulating Supply vs Total Supply (with % minted progress), All-Time High (ATH) drop %, and All-Time Low (ATL) multiples.
- **Project Overview & Links**: Curated description with quick chips to official website, block explorer, reddit community, and source code.

### 3. 🔬 Market Statistics & Sentiment Research
- **Global Crypto Metrics**: Total crypto market cap ($3.1T+), 24h global volume, active cryptocurrencies count, and tracked exchanges.
- **Fear & Greed Index Meter**: Dynamic visual meter indicating market sentiment (`Extreme Fear` to `Extreme Greed`).
- **Market Dominance Breakdown**: Multi-color proportional visualizer for Bitcoin (BTC), Ethereum (ETH), Solana (SOL), and Altcoins.
- **Top 24h Gainers & Losers**: Fast discovery of biggest movers.

### 4. ⭐ Persistent Watchlist
- **Local Storage Sync**: Uses `SharedPreferences` to persist favorite coins across app launches.
- **Quick Bookmark Toggle**: Star or unstar coins with a single tap from anywhere.
- **Portfolio Summary**: Displays total tracked coins and average 24h percentage return.
- **Empty States**: Encourages exploration with a direct action button to browse markets.

### 5. 🔌 Backend Architecture (Node.js & Express.js)
- **Express.js REST Service** located in `backend/server.js`.
- **Endpoints**:
  - `GET /health` - Service health status.
  - `GET /api/market-stats` - Global market cap, volume, dominance, and sentiment.
  - `GET /api/coins` - Filtered, sorted, and paginated coin market data.
  - `GET /api/coins/:coinId` - Comprehensive individual coin details.
  - `GET /api/coins/:coinId/chart?days={days}` - Historical timestamp/price points.
  - `GET /api/trending` - Top gainers, losers, and trending coins.
- **Resilient Fallback Mode**: If the backend is offline or CoinGecko rate-limits, the Flutter app automatically serves high-fidelity realistic data with zero downtime.

---

## 🛠️ Project Structure

```
d:/flutterapp1/
├── backend/
│   ├── package.json         # Node.js dependencies (express, cors)
│   ├── server.js            # Express.js REST API with caching & CoinGecko proxy
│   └── run_backend.bat      # 1-click script to launch backend
├── lib/
│   ├── models/
│   │   ├── coin_model.dart          # Coin schema and currency formatters
│   │   ├── market_stats_model.dart  # Global statistics and sentiment
│   │   └── chart_point_model.dart   # Price-time data points
│   ├── providers/
│   │   ├── crypto_provider.dart      # Market list, filters, search & sort state
│   │   ├── coin_detail_provider.dart # Interactive chart and timeframe state
│   │   └── watchlist_provider.dart   # Favorites persistence state
│   ├── services/
│   │   ├── crypto_api_service.dart   # REST client with backend & direct fallbacks
│   │   └── watchlist_service.dart    # SharedPreferences local storage
│   ├── screens/
│   │   ├── main_navigation_screen.dart # Bottom navigation bar with badge
│   │   ├── coin_list_screen.dart       # Markets screen with search & filter chips
│   │   ├── coin_detail_screen.dart     # Interactive charts & key statistics
│   │   ├── market_stats_screen.dart    # Fear & Greed, Dominance & Top Gainers
│   │   ├── watchlist_screen.dart       # Saved favorites screen
│   │   └── info_screen.dart            # Diagnostics and backend status
│   ├── widgets/
│   │   ├── coin_card.dart          # Coin list card with sparkline & 24h pill
│   │   ├── price_chart_widget.dart # fl_chart touch tooltip line chart
│   │   ├── sparkline_widget.dart   # CustomPainter 7d sparkline
│   │   ├── stat_tile.dart          # Metric key-value card
│   │   ├── loading_shimmer.dart    # Skeleton loading animation
│   │   ├── error_view.dart         # Error state with retry action
│   │   └── empty_view.dart         # Empty search / watchlist state
│   ├── theme/
│   │   └── app_theme.dart          # Obsidian & Emerald modern crypto theme
│   └── main.dart                   # MultiProvider root
└── test/
    └── widget_test.dart            # Smoke tests
```

---

## 🏃 Quick Start Guide

### Step 1: Start the Backend Service
In a terminal window:
```bash
cd backend
npm start
```
*(Or double click `backend/run_backend.bat`)*

Verify backend health at: [http://127.0.0.1:8000/health](http://127.0.0.1:8000/health)

### Step 2: Run the Flutter App
In another terminal window:
```bash
# Run on Web (Chrome):
flutter run -d chrome

# Or run on Android Emulator:
flutter run -d emulator-5554

# Or run on Windows Desktop:
flutter run -d windows
```
*(Or double click `run_app.bat`)*
