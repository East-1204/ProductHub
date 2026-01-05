import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/product.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../utils/contact_helper.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isGridView;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return isGridView ? _buildGridCard(context) : _buildListCard(context);
  }

  Widget _buildListCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppStyles.cardDecorationWithBorder(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.lightestGrey,
                  image: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.imageUrl == null || product.imageUrl!.isEmpty
                    ? const Center(
                        child: Icon(
                          Iconsax.box,
                          color: AppColors.grey,
                          size: 32,
                        ),
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: AppStyles.subtitle1(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Iconsax.star1,
                                  size: 12,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Featured',
                                  style: AppStyles.caption(context).copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      product.category,
                      style: AppStyles.caption(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      product.description,
                      style: AppStyles.body2(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Text(
                          product.priceFormatted,
                          style: AppStyles.heading3(context).copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.stockStatusColor.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.stockStatus,
                            style: AppStyles.caption(context).copyWith(
                              color: product.stockStatusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${product.stock} items',
                          style: AppStyles.caption(context),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Tooltip(
                            message: 'Edit produk',
                            child: OutlinedButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(
                                Iconsax.edit,
                                size: 16,
                              ),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Tooltip(
                            message: 'Hubungi pemasok',
                            child: OutlinedButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Iconsax.message),
                                        title: const Text('WhatsApp'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          ContactHelper.launchWhatsApp(
                                            text:
                                                'Hi, I have a question about ${product.name}',
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Iconsax.call),
                                        title: const Text('Call'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          ContactHelper.makeCall();
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Iconsax.sms),
                                        title: const Text('Email'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          ContactHelper.sendEmail(
                                            subject: 'Inquiry: ${product.name}',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Iconsax.message,
                                size: 16,
                                color: AppColors.info,
                              ),
                              label: const Text(
                                'Hub',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 36),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Tooltip(
                            message: 'Hapus produk',
                            child: OutlinedButton.icon(
                              onPressed: onDelete,
                              icon: const Icon(
                                Iconsax.trash,
                                size: 16,
                                color: AppColors.danger,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: AppColors.danger),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.danger),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppStyles.cardDecorationWithBorder(context),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: AppColors.lightestGrey,
                    image: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(product.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.imageUrl == null || product.imageUrl!.isEmpty
                      ? const Center(
                          child: Icon(
                            Iconsax.box,
                            color: AppColors.grey,
                            size: 48,
                          ),
                        )
                      : null,
                ),
                
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          style: AppStyles.caption(context).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Product Name
                      Text(
                        product.name,
                        style: AppStyles.subtitle1(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Product Description
                      Text(
                        product.description,
                        style: AppStyles.body2(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Price and Stock
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.priceFormatted,
                              style: AppStyles.heading3(context).copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: product.stockStatusColor.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.stock.toString(),
                              style: AppStyles.caption(context).copyWith(
                                color: product.stockStatusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Featured Badge
            if (product.isFeatured)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.secondaryGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Iconsax.star1,
                        size: 12,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Featured',
                        style: AppStyles.caption(context).copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Action Buttons
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).round()),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'Edit produk',
                      child: IconButton(
                        icon: const Icon(
                          Iconsax.edit,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        onPressed: onEdit,
                      ),
                    ),
                    Tooltip(
                      message: 'Hapus produk',
                      child: IconButton(
                        icon: const Icon(
                          Iconsax.trash,
                          size: 18,
                          color: AppColors.danger,
                        ),
                        onPressed: onDelete,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}