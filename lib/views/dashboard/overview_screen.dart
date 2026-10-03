import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/products_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/offers_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/skeleton_loader.dart';
import '../products/product_form_dialog.dart';

class OverviewScreen extends StatelessWidget {
  final Function(int index) onNavigateToTab;

  const OverviewScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final productsProv = Provider.of<ProductsProvider>(context);
    final categoriesProv = Provider.of<CategoriesProvider>(context);
    final offersProv = Provider.of<OffersProvider>(context);

    final isLoadingAny = productsProv.isLoading || categoriesProv.isLoading || offersProv.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Welcome Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 600;

                final textContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مرحباً بك في لوحة تحكم سيمليسيتي وينز',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'تابع إحصائيات المتجر، المنتجات، والعروض الترويجية من مكان واحد بسهولة.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bronze,
                            foregroundColor: AppColors.white,
                          ),
                          onPressed: () {
                            ProductFormDialog.show(context);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('إضافة منتج جديد'),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            side: const BorderSide(
                              color: AppColors.textMuted,
                            ),
                          ),
                          onPressed: () {
                            onNavigateToTab(3); // Offers tab
                          },
                          icon: const Icon(Icons.local_offer, size: 18),
                          label: const Text('إضافة عرض جديد'),
                        ),
                      ],
                    ),
                  ],
                );

                final storeIcon = Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bronze.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.bronze.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: AppColors.bronze,
                    size: 64,
                  ),
                );

                if (isSmall) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textContent,
                      const SizedBox(height: 16),
                      Center(child: storeIcon),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: textContent),
                    const SizedBox(width: 20),
                    storeIcon,
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Stat Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1000
                  ? 4
                  : (constraints.maxWidth > 600 ? 2 : 1);
              final width = (constraints.maxWidth -
                      ((crossAxisCount - 1) * 16)) /
                  crossAxisCount;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: width,
                    child: isLoadingAny
                        ? const Card(child: Padding(padding: EdgeInsets.all(20), child: SkeletonBox(height: 60)))
                        : StatCard(
                            title: 'إجمالي المنتجات',
                            value: '${productsProv.totalProducts}',
                            icon: Icons.inventory_2_outlined,
                            iconBgColor: AppColors.ink.withValues(alpha: 0.1),
                            iconColor: AppColors.ink,
                            subtitle: 'المنتجات المسجلة في القائمة',
                            onTap: () => onNavigateToTab(1),
                          ),
                  ),
                  SizedBox(
                    width: width,
                    child: isLoadingAny
                        ? const Card(child: Padding(padding: EdgeInsets.all(20), child: SkeletonBox(height: 60)))
                        : StatCard(
                            title: 'العروض النشطة',
                            value: '${offersProv.activeOffersCount}',
                            icon: Icons.local_offer_outlined,
                            iconBgColor: AppColors.bronze.withValues(alpha: 0.15),
                            iconColor: AppColors.bronze,
                            subtitle: 'بانرات العروض الحالية',
                            onTap: () => onNavigateToTab(3),
                          ),
                  ),
                  SizedBox(
                    width: width,
                    child: isLoadingAny
                        ? const Card(child: Padding(padding: EdgeInsets.all(20), child: SkeletonBox(height: 60)))
                        : StatCard(
                            title: 'الأقسام والتصنيفات',
                            value: '${categoriesProv.totalCategories}',
                            icon: Icons.category_outlined,
                            iconBgColor: AppColors.olive.withValues(alpha: 0.15),
                            iconColor: AppColors.olive,
                            subtitle: 'تصنيفات الأزياء والموديلات',
                            onTap: () => onNavigateToTab(2),
                          ),
                  ),
                  SizedBox(
                    width: width,
                    child: isLoadingAny
                        ? const Card(child: Padding(padding: EdgeInsets.all(20), child: SkeletonBox(height: 60)))
                        : StatCard(
                            title: 'منتجات نفذت الكمية',
                            value: '${productsProv.outOfStockCount}',
                            icon: Icons.remove_shopping_cart_outlined,
                            iconBgColor: AppColors.dangerBg,
                            iconColor: AppColors.danger,
                            subtitle: 'بحاجة إلى إعادة توفير',
                            onTap: () => onNavigateToTab(1),
                          ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Recent Products Table Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'أحدث المنتجات المضافة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateToTab(1),
                        child: const Row(
                          children: [
                            Text('عرض جميع المنتجات'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (productsProv.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: SkeletonBox(height: 100),
                    )
                  else if (productsProv.products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'لا توجد منتجات مسجلة حالياً',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productsProv.products.take(5).length,
                      separatorBuilder: (ctx, i) => const Divider(),
                      itemBuilder: (ctx, index) {
                        final product = productsProv.products[index];
                        final firstImage = product.imageUrls.isNotEmpty
                            ? product.imageUrls.first
                            : 'https://via.placeholder.com/100';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              firstImage,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 50,
                                height: 50,
                                color: AppColors.lines,
                                child: const Icon(Icons.image,
                                    color: AppColors.textMuted),
                              ),
                            ),
                          ),
                          title: Text(
                            product.nameAr,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${product.categoryName} • ${Formatters.formatCurrency(product.price)}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: product.isAvailable
                                      ? AppColors.successBg
                                      : AppColors.dangerBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  product.isAvailable ? 'متوفر' : 'نفذت الكمية',
                                  style: TextStyle(
                                    color: product.isAvailable
                                        ? AppColors.success
                                        : AppColors.danger,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () {
                                  ProductFormDialog.show(context,
                                      product: product);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
