import 'package:flutter/material.dart';

class Product {
  int? id;
  String name;
  String category;
  String description;
  double price;
  int stock;
  String? imageUrl;
  DateTime createdAt;
  DateTime updatedAt;
  bool isFeatured;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isFeatured = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl ?? '',
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_featured': isFeatured ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
      price: map['price'],
      stock: map['stock'],
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isFeatured: map['is_featured'] == 1,
    );
  }

  // Formatted price
  String get priceFormatted {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  // Stock status
  String get stockStatus {
    if (stock <= 0) return 'Habis';
    if (stock < 10) return 'Sedikit';
    return 'Tersedia';
  }

  // FIX: Tambah import material.dart di atas
  Color get stockStatusColor {
    if (stock <= 0) return Colors.red; // Sekarang tidak error
    if (stock < 10) return Colors.orange;
    return Colors.green;
  }

  // Atau pakai AppColors jika mau
  Color get stockStatusColorCustom {
    if (stock <= 0) return const Color(0xFFEF4444); // Red
    if (stock < 10) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFF10B981); // Green
  }

  // Rating stars (simulated)
  double get rating => 4.5;
}