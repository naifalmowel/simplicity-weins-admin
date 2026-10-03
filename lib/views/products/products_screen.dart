import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../providers/categories_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/custom_snack_bar.dart';
import '../widgets/skeleton_loader.dart';
import 'product_form_dialog.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsProv = Provider.of<ProductsProvider>(context);
    final categoriesProv = Provider.of<CategoriesProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Search Toolbar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 700;

                  if (isSmall) {
                    return Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'البحث باسم المنتج بالعربية أو الإنكليزية...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: productsProv.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => productsProv.setSearchQuery(''),
                                  )
                                : null,
                          ),
                          onChanged: (val) => productsProv.setSearchQuery(val),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                initialValue: productsProv.selectedCategoryId,
                                decoration: const InputDecoration(
                                  hintText: 'جميع الأقسام',
                                  prefixIcon: Icon(Icons.filter_alt_outlined),
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('جميع الأقسام'),
                                  ),
                                  ...categoriesProv.categories.map((cat) {
                                    return DropdownMenuItem<String?>(
                                      value: cat.id,
                                      child: Text(cat.nameAr),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (val) => productsProv.setSelectedCategory(val),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              onPressed: () {
                                ProductFormDialog.show(context);
                              },
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('إضافة'),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      // Search Bar
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'البحث باسم المنتج بالعربية أو الإنكليزية...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: productsProv.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => productsProv.setSearchQuery(''),
                                  )
                                : null,
                          ),
                          onChanged: (val) => productsProv.setSearchQuery(val),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Category Filter Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: productsProv.selectedCategoryId,
                          decoration: const InputDecoration(
                            hintText: 'جميع الأقسام',
                            prefixIcon: Icon(Icons.filter_alt_outlined),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('جميع الأقسام'),
                            ),
                            ...categoriesProv.categories.map((cat) {
                              return DropdownMenuItem<String?>(
                                value: cat.id,
                                child: Text(cat.nameAr),
                              );
                            }).toList(),
                          ],
                          onChanged: (val) => productsProv.setSelectedCategory(val),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Add New Product Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        onPressed: () {
                          ProductFormDialog.show(context);
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('إضافة منتج جديد'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Products Count Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عرض ${productsProv.filteredProducts.length} من إجمالي ${productsProv.totalProducts} منتج',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Products List Grid
          Expanded(
            child: productsProv.isLoading
                ? const ProductGridSkeleton()
                : productsProv.filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'لم يتم العثور على أي منتجات مطابقة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 1200
                              ? 3
                              : (constraints.maxWidth > 750 ? 2 : 1);

                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 1.35,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: productsProv.filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = productsProv.filteredProducts[index];
                              return _buildProductCard(context, product, productsProv);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    ProductsProvider provider,
  ) {
    final firstImage = product.imageUrls.isNotEmpty
        ? product.imageUrls.first
        : 'https://via.placeholder.com/300';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    firstImage,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: AppColors.lines,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 36),
                      ),
                    ),
                  ),
                ),
                // Badge Tag
                if (product.badge != null && product.badge!.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Availability Tag
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.isAvailable ? AppColors.success : AppColors.danger,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.isAvailable ? 'متوفر' : 'نفذت الكمية',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.nameAr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(product.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.categoryName} • ${product.sizes.join(', ')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // Card Actions
                Row(
                  children: [
                    Switch(
                      value: product.isAvailable,
                      activeThumbColor: AppColors.success,
                      onChanged: (val) {
                        provider.toggleAvailability(product.id, val);
                      },
                    ),
                    const Text('توفر', style: TextStyle(fontSize: 12)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'تعديل',
                      onPressed: () {
                        ProductFormDialog.show(context, product: product);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                      tooltip: 'حذف',
                      onPressed: () {
                        ConfirmDialog.show(
                          context,
                          title: 'حذف المنتج',
                          message: 'هل أنت تأكد من أنك تريد حذف هذا المنتج وحذف صوره من Supabase؟',
                          onConfirm: () async {
                            await provider.deleteProduct(product);
                            if (context.mounted) {
                              CustomSnackBar.showSuccess(context, 'تم حذف المنتج بنجاح');
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
