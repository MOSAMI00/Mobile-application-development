import 'package:flutter/material.dart';
import 'components/any_to_any.dart';
import 'components/usd_to_any.dart';
import 'services/exchange_api.dart';

class CurrencyExchangePage extends StatefulWidget {
  const CurrencyExchangePage({super.key});

  @override
  _CurrencyExchangePageState createState() => _CurrencyExchangePageState();
}

class _CurrencyExchangePageState extends State<CurrencyExchangePage> {
  late Future<Map<String, dynamic>> _exchangeRates;
  late Future<Map<String, String>> _currencies;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _exchangeRates = ExchangeApi.fetchRates();
    _currencies = ExchangeApi.fetchCurrencies();
  }

  void _onRefresh() {
    setState(() {
      _loadData();
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onTabTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحويل العملات'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withOpacity(0.7), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _exchangeRates,
          builder: (context, rateSnapshot) {
            if (rateSnapshot.connectionState == ConnectionState.waiting) {
              return _loadingWidget('جاري تحميل بيانات العملات...');
            }
            if (rateSnapshot.hasError) {
              return _errorWidget('حدث خطأ في تحميل البيانات', _onRefresh);
            }

            return FutureBuilder<Map<String, String>>(
              future: _currencies,
              builder: (context, currSnapshot) {
                if (currSnapshot.connectionState == ConnectionState.waiting) {
                  return _loadingWidget('جاري تحميل العملات...');
                }
                if (currSnapshot.hasError) {
                  return _errorWidget('حدث خطأ في تحميل العملات', _onRefresh);
                }

                final rates = rateSnapshot.data!['rates'] as Map<String, dynamic>;
                final currencies = currSnapshot.data!;

                return Column(
                  children: [
                    _tabSelector(primary),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        children: [
                          UsdToAny(rates: rates, currencies: currencies),
                          AnyToAny(rates: rates, currencies: currencies),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _tabSelector(Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _tabButton('من الدولار', 0, primary),
          const SizedBox(width: 12),
          _tabButton('بين العملات', 1, primary),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index, Color primary) {
    final selected = _currentPage == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onTabTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.white.withOpacity(0.9) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white70),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? primary : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingWidget(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _errorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}