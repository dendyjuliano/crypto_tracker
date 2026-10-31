// Tugas 3 - Pemrograman Berbasis Perangkat Bergerak (MSIM4401)
// Aplikasi mobile sederhana (Flutter) untuk menampilkan data cryptocurrency
// Sumber data: Coinlore API (https://api.coinlore.net/api/tickers/)
//
// Field yang ditampilkan: rank, name, symbol, price_usd

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CryptoTrackerApp());
}

class CryptoTrackerApp extends StatelessWidget {
  const CryptoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CryptoListPage(),
    );
  }
}

// Model data untuk satu coin, hasil parsing dari JSON API
class Coin {
  final int rank;
  final String name;
  final String symbol;
  final String priceUsd;

  Coin({
    required this.rank,
    required this.name,
    required this.symbol,
    required this.priceUsd,
  });

  // Factory constructor untuk membuat objek Coin dari Map hasil decode JSON
  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      rank: json['rank'] is int
          ? json['rank']
          : int.tryParse(json['rank'].toString()) ?? 0,
      name: json['name'] ?? '-',
      symbol: json['symbol'] ?? '-',
      priceUsd: json['price_usd'] ?? '0',
    );
  }
}

class CryptoListPage extends StatefulWidget {
  const CryptoListPage({super.key});

  @override
  State<CryptoListPage> createState() => _CryptoListPageState();
}

class _CryptoListPageState extends State<CryptoListPage> {
  static const String apiUrl = 'https://api.coinlore.net/api/tickers/';

  late Future<List<Coin>> _futureCoins;

  @override
  void initState() {
    super.initState();
    _futureCoins = fetchCoins();
  }

  // Mengambil data dari API Coinlore dan mengubahnya menjadi List<Coin>
  Future<List<Coin>> fetchCoins() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((item) => Coin.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data cryptocurrency dari API');
    }
  }

  // Dipanggil saat tombol Refresh ditekan
  void _refreshData() {
    setState(() {
      _futureCoins = fetchCoins();
    });
  }

  String _formatPrice(String priceUsd) {
    final value = double.tryParse(priceUsd) ?? 0;
    if (value >= 1) {
      return value.toStringAsFixed(2);
    }
    return value.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crypto Tracker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Refresh'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Coin>>(
              future: _futureCoins,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'),
                  );
                }

                final coins = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: coins.length,
                  itemBuilder: (context, index) {
                    final coin = coins[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEEC0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Kolom Rank
                          SizedBox(
                            width: 55,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rank',
                                  style: TextStyle(fontSize: 11, color: Colors.black54),
                                ),
                                Text(
                                  '${coin.rank}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Kolom Name & Symbol
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coin.name,
                                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  coin.symbol,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Kolom Price USD
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'USD',
                                style: TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                              Text(
                                _formatPrice(coin.priceUsd),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
