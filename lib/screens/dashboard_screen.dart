import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/stat_card.dart';
import 'products_screen.dart';
import 'add_product_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import '../database/db_helper.dart';
import '../services/notification_service.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../models/product.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const ProductsScreen(),
    const AddProductScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  List<Product> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadAllProducts();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final dbHelper = DBHelper();
    _stats = await dbHelper.getDashboardStats();
    setState(() => _isLoading = false);
  }

  Future<void> _loadAllProducts() async {
    final dbHelper = DBHelper();
    _allProducts = await dbHelper.getAllProducts();
    // Notify if any product has low stock
    NotificationService().checkAndNotifyLowStock(_allProducts);
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _searchResults.clear();
      } else {
        _isSearching = true;
        _searchResults = _allProducts
            .where((product) {
              final name = product.name.toLowerCase();
              final category = product.category.toLowerCase();
              final description = product.description.toLowerCase();
              final searchQuery = query.toLowerCase();
              return name.contains(searchQuery) ||
                  category.contains(searchQuery) ||
                  description.contains(searchQuery);
            })
            .toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _isSearching
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Iconsax.arrow_left, color: AppColors.darkGrey),
                onPressed: _clearSearch,
              ),
              title: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search products by name, category...',
                  hintStyle: AppStyles.body1(context).copyWith(color: AppColors.grey),
                  border: InputBorder.none,
                ),
                style: AppStyles.body1(context),
                onChanged: _performSearch,
              ),
              actions: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, color: AppColors.darkGrey),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  ),
              ],
            )
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning 👋',
                    style: AppStyles.caption(context).copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  Text(
                    'Admin User',
                    style: AppStyles.subtitle1(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                Builder(
                  builder: (context) {
                    final lowCount = _allProducts.where((p) => p.stock < 10).length;
                    return IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Iconsax.notification, color: AppColors.darkGrey),
                          if (lowCount > 0)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$lowCount',
                                  style: AppStyles.caption(context).copyWith(color: AppColors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Iconsax.search_normal, color: AppColors.darkGrey),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              ],
            ),
      body: _isSearching
          ? _buildSearchResults()
          : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadStats,
            backgroundColor: Colors.white,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Section
                  Text(
                    'Overview',
                    style: AppStyles.heading2(context),
                  ),

                  const SizedBox(height: 20),

                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      // Total Products
                      StatCard(
                        title: 'Total Products',
                        value: (_stats['totalProducts'] ?? 0).toString(),
                        icon: Iconsax.box,
                        color: AppColors.primary,
                        valueColor: AppColors.primary,
                      ),

                      // Total Value
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.05 * 255).round()),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withAlpha((0.1 * 255).round()),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Iconsax.dollar_circle,
                                    color: AppColors.success,
                                    size: 24,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            Text(
                              _formatCurrency(_stats['totalValue'] ?? 0),
                              style: AppStyles.heading2(context).copyWith(
                                color: AppColors.success,
                                fontSize: 20,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Total Value',
                              style: AppStyles.body2(context).copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Low Stock
                      StatCard(
                        title: 'Low Stock',
                        value: (_stats['lowStock'] ?? 0).toString(),
                        icon: Iconsax.warning_2,
                        color: AppColors.warning,
                        valueColor: AppColors.warning,
                      ),

                      // Featured
                      StatCard(
                        title: 'Featured',
                        value: (_stats['featuredCount'] ?? 0).toString(),
                        icon: Iconsax.star,
                        color: AppColors.accent,
                        valueColor: AppColors.accent,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Quick Actions Section
                  Text(
                    'Quick Actions',
                    style: AppStyles.heading2(context),
                  ),

                  const SizedBox(height: 20),

                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      // Add Product
                      _buildActionButton(
                        Iconsax.add,
                        'Add Product',
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddProductScreen(),
                            ),
                          );
                        },
                      ),

                      // View All
                      _buildActionButton(
                        Iconsax.box,
                        'View All',
                        AppColors.success,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProductsScreen(),
                            ),
                          );
                        },
                      ),

                      // Reports
                      _buildActionButton(
                        Iconsax.chart,
                        'Reports',
                        AppColors.warning,
                        () {
                          // TODO: Navigate to Reports Screen
                        },
                      ),

                      // Settings
                      _buildActionButton(
                        Iconsax.setting,
                        'Settings',
                        AppColors.info,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),

                      // Profile
                      _buildActionButton(
                        Iconsax.profile,
                        'Profile',
                        AppColors.accent,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),

                      // Logout
                      _buildActionButton(
                        Iconsax.logout,
                        'Logout',
                        AppColors.danger,
                        () {
                          _showLogoutDialog();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Recent Activity Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.05 * 255).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Recent Activity',
                              style: AppStyles.heading3(context),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'View All',
                                style: AppStyles.body2(context).copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Activity Items
                        _buildActivityItem(
                          'Added new product: iPhone 14 Pro',
                          '2 min ago',
                          Iconsax.add_circle,
                          AppColors.success,
                        ),
                        _buildActivityItem(
                          'Updated stock for MacBook Air',
                          '1 hour ago',
                          Iconsax.edit,
                          AppColors.info,
                        ),
                        _buildActivityItem(
                          'Deleted product: Old Model',
                          '3 hours ago',
                          Iconsax.trash,
                          AppColors.danger,
                        ),
                        _buildActivityItem(
                          'Created monthly report',
                          '1 day ago',
                          Iconsax.document,
                          AppColors.warning,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty && _searchController.text.isNotEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.search_normal,
                  size: 60,
                  color: AppColors.grey.withAlpha((0.5 * 255).round()),
                ),
                const SizedBox(height: 16),
                Text(
                  'No products found',
                  style: AppStyles.heading3(context).copyWith(color: AppColors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: AppStyles.body1(context).copyWith(color: AppColors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withAlpha((0.1 * 255).round()),
                    child: Icon(
                      Iconsax.box,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: AppStyles.body1(context).copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${product.category}',
                        style: AppStyles.caption(context),
                      ),
                      Text(
                        'Stock: ${product.stock}',
                        style: AppStyles.caption(context).copyWith(
                          color: product.stock <= 5
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    _formatCurrency(product.price),
                    style: AppStyles.body2(context).copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProductScreen(
                          product: product,
                          onProductUpdated: () {
                            // Refresh data when product is updated or deleted
                            _loadAllProducts();
                            _loadStats();
                            if (_isSearching) _performSearch(_searchController.text);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Product updated'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }

  // Format currency function
  String _formatCurrency(dynamic value) {
    if (value == null || value == 0) return 'Rp 0';

    final num numericValue = value is num ? value : 0;
    
    if (numericValue == 5000) {
      return 'Rp 5.000';
    }
    
    final String stringValue = numericValue.toInt().toString();
    String result = '';
    int count = 0;
    
    for (int i = stringValue.length - 1; i >= 0; i--) {
      result = stringValue[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = '.$result';
        count = 0;
      }
    }
    
    return 'Rp $result';
  }

  // Build Action Button
  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppStyles.caption(context).copyWith(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Build Activity Item
  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.body1(context).copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                    style: AppStyles.caption(context).copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show Logout Dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}