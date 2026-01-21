import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.workspace_premium, size: 44, color: Colors.amber),
                  const SizedBox(height: 16),
                  if (_subscribed)
                    const Text(
                      "You are a premium subscriber! Thank you for supporting Digital Home Manager.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.green),
                    )
                  else ...[
                    const Text(
                      "Subscribe to unlock full access to Digital Home Manager premium features.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 32),
                    if (_products.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _products
                            .map((p) => Expanded(
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            p.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            p.price,
                                            style: const TextStyle(
                                              color: Colors.deepPurple,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            p.description,
                                            style: const TextStyle(fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () async {
                                              setState(() => _loading = true);
                                              await SubscriptionService.buy(p);
                                              await _loadProducts();
                                              _refreshStatus();
                                            },
                                            child: const Text('Choose', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    if (_products.length == 1)
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _products[0].title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _products[0].price,
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _products[0].description,
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() => _loading = true);
                                  await SubscriptionService.buy(_products[0]);
                                  await _loadProducts();
                                  _refreshStatus();
                                },
                                child: const Text('Subscribe', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
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
                  ],
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
