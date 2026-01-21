import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionService {
  static final InAppPurchase _iap = InAppPurchase.instance;

  static const List<String> _kProductIds = <String>[
    // These should match your IDs in Play/App Store: replace with live IDs as needed
    'digital_home_manager_monthly',
    'digital_home_manager_yearly',
  ];

  // Exposed paid access
  static bool _isSubscribed = false;
  static bool get isSubscribed => _isSubscribed;

  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  static Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    // Listen for purchase updates
    _subscription ??= _iap.purchaseStream.listen((purchases) {
      for (final pd in purchases) {
        // Only validate state for subscriptions, NOT consumable purchases
        if (_kProductIds.contains(pd.productID) && pd.status == PurchaseStatus.purchased) {
          _isSubscribed = true;
        } else if (_kProductIds.contains(pd.productID) && pd.status == PurchaseStatus.canceled) {
          _isSubscribed = false;
        }
      }
    });
  }

  static Future<List<ProductDetails>> getAvailableProducts() async {
    final resp = await _iap.queryProductDetails(_kProductIds.toSet());
    return resp.productDetails;
  }

  static Future<void> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
