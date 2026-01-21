import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'subscription_service.dart';

class SubscriptionPaywall extends StatefulWidget {
  final Widget child;
  const SubscriptionPaywall({super.key, required this.child});

  @override
  State<SubscriptionPaywall> createState() => _SubscriptionPaywallState();
}

class _SubscriptionPaywallState extends State<SubscriptionPaywall> {
  bool _loading = false;
  List<ProductDetails> _products = [];
  bool _subscribed = SubscriptionService.isSubscribed;

  @override
  void initState() {
    super.initState();
    SubscriptionService.init().then((_) => _loadProducts());
    _refreshStatus();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final products = await SubscriptionService.getAvailableProducts();
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  void _refreshStatus() {
    setState(() {
      _subscribed = SubscriptionService.isSubscribed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_subscribed) {
      return widget.child;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock Premium Features')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.workspace_premium, size: 44, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text(
                    "Subscribe to unlock full access to Digital Home Manager.\nIncludes all advanced features, cloud sync, and provider booking.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 32),
                  for (final p in _products)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(p.title),
                        subtitle: Text(p.description),
                        trailing: TextButton(
                          onPressed: () async {
                            setState(() => _loading = true);
                            await SubscriptionService.buy(p);
                            await _loadProducts();
                            _refreshStatus();
                          },
                          child: Text('Subscribe', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.restore),
                    label: const Text("Restore Purchases"),
                    onPressed: () async {
                      setState(() => _loading = true);
                      await InAppPurchase.instance.restorePurchases();
                      await _loadProducts();
                      _refreshStatus();
                    },
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "After purchase, your access will be activated immediately.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
