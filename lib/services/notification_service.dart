import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/product.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: iOS);

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
    );
  }

  Future<void> showLowStockNotification(List<Product> products) async {
    if (products.isEmpty) return;

    final titles = products.map((p) => p.name).join(', ');
    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Low Stock Alerts',
      channelDescription: 'Notifications for low stock products',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails();

    final platformDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Low stock alert',
      'Products low in stock: $titles',
      platformDetails,
    );
  }

  void checkAndNotifyLowStock(List<Product> products, {int threshold = 5}) {
    final low = products.where((p) => p.stock <= threshold).toList();
    if (low.isNotEmpty) {
      showLowStockNotification(low);
    }
  }
}
