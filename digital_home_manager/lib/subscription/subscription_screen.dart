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
          : Container(
              color: Colors.grey[100],
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.workspace_premium, size: 52, color: Colors.amber),
                      const SizedBox(height: 22),
                      if (_subscribed)
                        const Card(
                          color: Colors.greenAccent,
                          margin: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "You are a premium subscriber! Thank you for supporting Digital Home Manager.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ),
                        )
                      else ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            "Unlock the full value of Digital Home Manager with a premium subscription!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "• Unlimited document upload\n• Deadline reminders\n• Home health analytics\n• Premium support and features\n• Priority for new upgrades",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black87, fontSize: 15),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _products.map((p) => Expanded(
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                                        const SizedBox(height: 6),
                                        Text(
                                          p.price,
                                          style: const TextStyle(
                                            color: Colors.deepPurple,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          p.description,
                                          style: const TextStyle(fontSize: 13),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: () async {
                                            setState(() => _loading = true);
                                            await SubscriptionService.buy(p);
                                            await _loadProducts();
                                            _refreshStatus();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.amber,
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          child: const Text('Choose', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )).toList(),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "All premium features activate instantly after purchase.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
