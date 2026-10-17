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

enum ProductViewMode { gridLarge, gridCompact, list }

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  ProductViewMode _viewMode = ProductViewMode.gridCompact;

  @override
  Widget build(BuildContext context) {
    final productsProv = Provider.of<ProductsProvider>(context);
    final categoriesProv = Provider.of<CategoriesProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Header & Search Toolbar
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 700;

                  final searchField = SizedBox(
                    height: 42,
                    child: TextField(
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        hintText: 'البحث باسم المنتج بالعربية أو الإنكليزية...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: productsProv.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () => productsProv.setSearchQuery(''),
                              )
                            : null,
                      ),
                      onChanged: (val) => productsProv.setSearchQuery(val),
                    ),
                  );

                  final categoryDropdown = SizedBox(
                    height: 42,
                    child: DropdownButtonFormField<String?>(
                      initialValue: productsProv.selectedCategoryId,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        hintText: 'جميع الأقسام',
                        prefixIcon: Icon(Icons.filter_alt_outlined, size: 18),
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
                        }),
                      ],
                      onChanged: (val) => productsProv.setSelectedCategory(val),
                    ),
                  );

                  final addProductButton = SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ProductFormDialog.show(context);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة منتج جديد', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  );

                  if (isSmall) {
                    return Column(
                      children: [
                        searchField,
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: categoryDropdown),
                            const SizedBox(width: 8),
                            Expanded(child: addProductButton),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(flex: 2, child: searchField),
                      const SizedBox(width: 10),
                      Expanded(flex: 2, child: categoryDropdown),
                      const SizedBox(width: 10),
                      Expanded(flex: 1, child: addProductButton),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Count Indicator & Layout Switcher Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عرض ${productsProv.filteredProducts.length} من إجمالي ${productsProv.totalProducts} منتج',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),

              // View Mode Toggle Switches
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lines),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    _buildViewModeIconButton(
                      mode: ProductViewMode.gridLarge,
                      icon: Icons.grid_view_rounded,
                      tooltip: 'شبكة كروت كبيرة',
                    ),
                    _buildViewModeIconButton(
                      mode: ProductViewMode.gridCompact,
                      icon: Icons.grid_on_rounded,
                      tooltip: 'شبكة مصغرة',
                    ),
                    _buildViewModeIconButton(
                      mode: ProductViewMode.list,
                      icon: Icons.format_list_bulleted_rounded,
                      tooltip: 'عرض القائمة',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Products Content View
          Expanded(
            child: productsProv.isLoading
                ? const ProductGridSkeleton()
                : productsProv.filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 56, color: AppColors.textMuted),
                            const SizedBox(height: 10),
                            const Text(
                              'لم يتم العثور على أي منتجات مطابقة',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildProductsView(context, productsProv),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeIconButton({
    required ProductViewMode mode,
    required IconData icon,
    required String tooltip,
  }) {
    final isSelected = _viewMode == mode;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => setState(() => _viewMode = mode),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildProductsView(BuildContext context, ProductsProvider productsProv) {
    if (_viewMode == ProductViewMode.list) {
      return ListView.separated(
        itemCount: productsProv.filteredProducts.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final product = productsProv.filteredProducts[index];
          return _buildProductListItem(context, product, productsProv);
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (_viewMode == ProductViewMode.gridLarge) {
          // Portrait ratio 0.72 - perfect for showing full vertical clothing items
          crossAxisCount = constraints.maxWidth > 1200
              ? 3
              : (constraints.maxWidth > 750 ? 2 : 1);
          childAspectRatio = constraints.maxWidth < 600 ? 0.72 : 0.75;
        } else {
          // Compact Grid mode
          crossAxisCount = constraints.maxWidth > 1200
              ? 4
              : (constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1));
          childAspectRatio = 0.85;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: productsProv.filteredProducts.length,
          itemBuilder: (context, index) {
            final product = productsProv.filteredProducts[index];
            return _buildProductCard(context, product, productsProv);
          },
        );
      },
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
          // Vertical Fashion Image Container with full-contain / full-cover fitting
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.4),
                    child: Image.network(
                      firstImage,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: AppColors.lines,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 36),
                        ),
                      ),
                    ),
                  ),
                ),
                // Badge Tag
                if (product.badge != null && product.badge!.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Availability Tag
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: product.isAvailable ? AppColors.success : AppColors.danger,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.isAvailable ? 'متوفر' : 'نفذت الكمية',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card Info Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                                fontSize: 14,
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
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${product.categoryName} • المقاسات: ${product.sizes.join(', ')}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Card Actions Footer Bar
                  Row(
                    children: [
                      Switch(
                        value: product.isAvailable,
                        activeThumbColor: AppColors.success,
                        onChanged: (val) {
                          provider.toggleAvailability(product.id, val);
                        },
                      ),
                      const Text('توفر', style: TextStyle(fontSize: 11)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'تعديل',
                        onPressed: () {
                          ProductFormDialog.show(context, product: product);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
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
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(
    BuildContext context,
    ProductModel product,
    ProductsProvider provider,
  ) {
    final firstImage = product.imageUrls.isNotEmpty
        ? product.imageUrls.first
        : 'https://via.placeholder.com/300';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Fashion Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                firstImage,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (ctx, err, stack) => Container(
                  width: 65,
                  height: 65,
                  color: AppColors.lines,
                  child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.nameAr,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Availability Tag Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.isAvailable ? AppColors.successBg : AppColors.dangerBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.isAvailable ? 'متوفر' : 'نفذت',
                          style: TextStyle(
                            color: product.isAvailable ? AppColors.success : AppColors.danger,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (product.badge != null && product.badge!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.badge!,
                            style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${product.categoryName} • السعر: ${Formatters.formatCurrency(product.price)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'المقاسات: ${product.sizes.join(', ')}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Action Buttons (No switch on list view as requested)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'تعديل',
                  onPressed: () {
                    ProductFormDialog.show(context, product: product);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
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
    );
  }
}
