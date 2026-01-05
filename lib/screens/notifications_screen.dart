import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import '../database/db_helper.dart';
import '../models/product.dart';
import '../utils/styles.dart';
import '../utils/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Future<List<Product>>? _lowFuture;

  @override
  void initState() {
    super.initState();
    _loadLow();
  }

  void _loadLow() {
    _lowFuture = DBHelper().getLowStockProducts();
  }

  Future<void> _openEdit(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(product: product, onProductUpdated: () {}),
      ),
    );
    // Refresh list after returning from edit
    setState(() {
      _loadLow();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Notifications', style: AppStyles.heading2(context)),
      ),
      body: FutureBuilder<List<Product>>(
        future: _lowFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final low = snapshot.data ?? [];
          if (low.isEmpty) {
            return Center(
              child: Text('No notifications', style: AppStyles.body1(context)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: low.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final p = low[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.lightestGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag, size: 20, color: AppColors.grey),
                ),
                title: Text(p.name, style: AppStyles.subtitle1(context)),
                subtitle: Text('Stock: ${p.stock} — consider reorder', style: AppStyles.body2(context)),
                trailing: TextButton(
                  onPressed: () => _openEdit(p),
                  child: Text('View', style: AppStyles.button(context).copyWith(color: AppColors.primary)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
