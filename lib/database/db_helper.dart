import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'modern_crud.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Users table
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            full_name TEXT,
            phone TEXT,
            avatar_url TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        // Products table
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            description TEXT NOT NULL,
            price REAL NOT NULL,
            stock INTEGER NOT NULL,
            image_url TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            is_featured INTEGER DEFAULT 0
          )
        ''');

        // Default admin user
        await db.insert('users', {
          'username': 'admin',
          'email': 'admin@example.com',
          'password': 'admin123',
          'full_name': 'Administrator',
          'phone': '+6281234567890',
          'created_at': DateTime.now().toIso8601String(),
        });

        // Sample products
        await _insertSampleProducts(db);
      },
    );
  }

  Future<void> _insertSampleProducts(Database db) async {
    final sampleProducts = [
      Product(
        name: 'iPhone 14 Pro',
        category: 'Electronics',
        description: 'Apple iPhone 14 Pro dengan layar Dynamic Island',
        price: 18999000,
        stock: 15,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFeatured: true,
      ),
      Product(
        name: 'MacBook Air M2',
        category: 'Electronics',
        description: 'Laptop Apple MacBook Air dengan chip M2',
        price: 24999000,
        stock: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFeatured: true,
      ),
      Product(
        name: 'Samsung Galaxy S23',
        category: 'Electronics',
        description: 'Smartphone Android dengan kamera 200MP',
        price: 15999000,
        stock: 25,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        name: 'Nike Air Force 1',
        category: 'Fashion',
        description: 'Sepatu sneakers klasik dari Nike',
        price: 1899000,
        stock: 50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        name: 'Dell XPS 13',
        category: 'Electronics',
        description: 'Laptop premium dengan layar InfinityEdge',
        price: 21999000,
        stock: 12,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        name: 'Sony WH-1000XM5',
        category: 'Electronics',
        description: 'Headphone noise cancelling terbaik',
        price: 5499000,
        stock: 30,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        name: 'Logitech MX Master 3',
        category: 'Electronics',
        description: 'Mouse ergonomis untuk produktivitas',
        price: 1299000,
        stock: 40,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        name: 'Apple Watch Series 8',
        category: 'Electronics',
        description: 'Smartwatch dengan fitur kesehatan lengkap',
        price: 8999000,
        stock: 20,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var product in sampleProducts) {
      await db.insert('products', product.toMap());
    }
  }

  // ========== USER OPERATIONS ==========
  Future<Map<String, dynamic>?> getUser(String username) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> checkLogin(String username, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  Future<int> createUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  // ========== PRODUCT CRUD OPERATIONS ==========
  Future<int> insertProduct(Product product) async {
    Database db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> getFeaturedProducts() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'is_featured = 1',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // Return products whose stock is below [threshold]
  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'stock < ?',
      whereArgs: [threshold],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProduct(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Product.fromMap(maps.first) : null;
  }

  Future<List<Product>> searchProducts(String query) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ? OR category LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<int> updateProduct(Product product) async {
    Database db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    Database db = await database;
    
    final totalProductsRes = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products'
    );
    
    final totalValueRes = await db.rawQuery(
      'SELECT SUM(price * stock) as total FROM products'
    );
    
    final lowStockRes = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE stock < 10'
    );
    
    final featuredCountRes = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE is_featured = 1'
    );

    final int totalProducts = (totalProductsRes.first['count'] is int)
      ? totalProductsRes.first['count'] as int
      : int.tryParse('${totalProductsRes.first['count']}') ?? 0;

    final num? totalValueRaw = totalValueRes.first['total'] is num
      ? totalValueRes.first['total'] as num
      : num.tryParse('${totalValueRes.first['total']}');

    final double totalValue = totalValueRaw?.toDouble() ?? 0.0;

    final int lowStock = (lowStockRes.first['count'] is int)
      ? lowStockRes.first['count'] as int
      : int.tryParse('${lowStockRes.first['count']}') ?? 0;

    final int featuredCount = (featuredCountRes.first['count'] is int)
      ? featuredCountRes.first['count'] as int
      : int.tryParse('${featuredCountRes.first['count']}') ?? 0;

    return {
      'totalProducts': totalProducts,
      'totalValue': totalValue,
      'lowStock': lowStock,
      'featuredCount': featuredCount,
    };
  }
}