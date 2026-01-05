import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/product.dart';
import '../database/db_helper.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  final VoidCallback? onProductAdded;
  final VoidCallback? onProductUpdated;

  const AddProductScreen({
    super.key,
    this.product,
    this.onProductAdded,
    this.onProductUpdated,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFeatured = false;
  
  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home',
    'Sports',
    'Books',
    'Food',
    'Health',
    'Beauty',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _categoryController.text = widget.product!.category;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _imageUrlController.text = widget.product!.imageUrl ?? '';
      _isFeatured = widget.product!.isFeatured;
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final dbHelper = DBHelper();
      
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        imageUrl: _imageUrlController.text.trim().isNotEmpty 
            ? _imageUrlController.text.trim() 
            : null,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isFeatured: _isFeatured,
      );

      if (widget.product == null) {
        await dbHelper.insertProduct(product);
        widget.onProductAdded?.call();
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product added successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        await dbHelper.updateProduct(product);
        widget.onProductUpdated?.call();
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product updated successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct() async {
    if (widget.product == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dbHelper = DBHelper();
      await dbHelper.deleteProduct(widget.product!.id!);
      widget.onProductUpdated?.call();
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Add Product' : 'Edit Product',
        ),
        actions: [
          if (widget.product != null)
            IconButton(
              icon: const Icon(Iconsax.trash),
              onPressed: _deleteProduct,
            ),
          IconButton(
            icon: const Icon(Iconsax.save_2),
            onPressed: _isLoading ? null : _saveProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Product Image Preview
              GestureDetector(
                onTap: () {
                  // Add image picker functionality
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.lightestGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.lighterGrey,
                      width: 2,
                    ),
                  ),
                  child: _imageUrlController.text.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _imageUrlController.text,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.gallery_add,
                              size: 48,
                              color: AppColors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to add product image',
                              style: AppStyles.body2(context).copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Image URL Field
              TextFormField(
                controller: _imageUrlController,
                decoration: AppStyles.inputDecoration(context).copyWith(
                  labelText: 'Image URL (Optional)',
                  prefixIcon: const Icon(Iconsax.link),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              
              const SizedBox(height: 20),
              
              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: AppStyles.inputDecoration(context).copyWith(
                  labelText: 'Product Name',
                  prefixIcon: const Icon(Iconsax.box),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _categoryController.text.isNotEmpty 
                    ? _categoryController.text 
                    : _categories.first,
                decoration: AppStyles.inputDecoration(context).copyWith(
                  labelText: 'Category',
                  prefixIcon: const Icon(Iconsax.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  _categoryController.text = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: AppStyles.inputDecoration(context).copyWith(
                  labelText: 'Description',
                  prefixIcon: const Icon(Iconsax.note_text),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Price and Stock Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: AppStyles.inputDecoration(context).copyWith(
                        labelText: 'Price',
                        prefixIcon: const Icon(Iconsax.dollar_circle),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price is required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: AppStyles.inputDecoration(context).copyWith(
                        labelText: 'Stock',
                        prefixIcon: const Icon(Iconsax.box),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stock is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Featured Switch
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightestGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.star,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Featured Product',
                            style: AppStyles.subtitle1(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Show this product on homepage',
                            style: AppStyles.body2(context),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isFeatured,
                      onChanged: (value) {
                        setState(() {
                          _isFeatured = value;
                        });
                      },
                      activeThumbColor: AppColors.accent,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: AppStyles.primaryButton(context).copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      AppColors.primary,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.save_2, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              widget.product == null 
                                  ? 'Add Product' 
                                  : 'Update Product',
                              style: AppStyles.button(context),
                            ),
                          ],
                        ),
                ),
              ),
              
              if (widget.product != null) ...[
                const SizedBox(height: 16),
                
                // Delete Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _deleteProduct,
                    style: AppStyles.outlineButton(context).copyWith(
                      side: WidgetStateProperty.all(
                        const BorderSide(color: AppColors.danger),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.trash,
                          size: 20,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delete Product',
                          style: AppStyles.button(context).copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}