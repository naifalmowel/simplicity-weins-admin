import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/offers_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/skeleton_loader.dart';
import '../products/product_form_dialog.dart';

class OverviewScreen extends StatefulWidget {
  final Function(int index) onNavigateToTab;

  const OverviewScreen({super.key, required this.onNavigateToTab});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int _activeFilterIndex = 0; // 0: Latest, 1: Featured, 2: Out of Stock

  @override
  Widget build(BuildContext context) {
    final productsProv = Provider.of<ProductsProvider>(context);
    final categoriesProv = Provider.of<CategoriesProvider>(context);
    final offersProv = Provider.of<OffersProvider>(context);
    final settingsProv = Provider.of<SettingsProvider>(context);

    final isLoadingAny = productsProv.isLoading || categoriesProv.isLoading || offersProv.isLoading;
    final isMobile = Responsive.isMobile(context);
    final settings = settingsProv.settings;

    // Filter products based on selected tab
    List<ProductModel> displayedProducts = productsProv.products;
    if (_activeFilterIndex == 1) {
      displayedProducts = productsProv.products.where((p) => p.isFeatured).toList();
    } else if (_activeFilterIndex == 2) {
      displayedProducts = productsProv.products.where((p) => !p.isAvailable).toList();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Executive Banner Header
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 28),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 650;

                // Live Store Status Badge
                Widget storeStatusBadge;
                if (settings.isClosed) {
                  storeStatusBadge = _buildStatusChip('المحل مغلق حالياً', AppColors.danger, AppColors.dangerBg);
                } else if (settings.isBusy) {
                  storeStatusBadge = _buildStatusChip('المحل مشغول / ذروة', AppColors.warning, AppColors.warningBg);
                } else {
                  storeStatusBadge = _buildStatusChip('المحل مفتوح للزوار', AppColors.success, AppColors.successBg);
                }

                final textContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'سيمليسيتي وينز',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: isMobile ? 20 : 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        storeStatusBadge,
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'لوحة الإدارة التنفيذية والتحكم المباشر بالمنتجات، التصنيفات، والموقع',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bronze,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            ProductFormDialog.show(context);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('إضافة منتج جديد', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            side: const BorderSide(color: AppColors.textMuted),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            widget.onNavigateToTab(3); // Offers tab
                          },
                          icon: const Icon(Icons.local_offer, size: 18),
                          label: const Text('إضافة عرض جديد'),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            side: const BorderSide(color: AppColors.textMuted),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            widget.onNavigateToTab(4); // Settings tab
                          },
                          icon: const Icon(Icons.settings_outlined, size: 18),
                          label: const Text('إعدادات وحالة المحل'),
                        ),
                      ],
                    ),
                  ],
                );

                final storeIcon = Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bronze.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.bronze.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: AppColors.bronze,
                    size: 56,
                  ),
                );

                if (isSmall) {
                  return textContent;
                }

                return Row(
                  children: [
                    Expanded(child: textContent),
                    const SizedBox(width: 24),
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
              final gap = isMobile ? 12.0 : 16.0;
              final width = (constraints.maxWidth - ((crossAxisCount - 1) * gap)) / crossAxisCount;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: width,
                    child: isLoadingAny
                        ? const Card(child: Padding(padding: EdgeInsets.all(16), child: SkeletonBox(height: 70)))
                        : StatCard(
                            title: 'إجمالي المنتجات',
                            value: '${productsProv.totalProducts}',
                            icon: Icons.inventory_2_outlined,
                            iconBgColor: AppColors.ink.withValues(alpha: 0.1),
                            iconColor: AppColors.ink,
                            subtitle: '${productsProv.activeProductsCount} منتج مفعل في المتجر',
                            onTap: () => widget.onNavigateToTab(1),
                          ),
                  ),
                  SizedBox(
                    width: width,
                    child: isLoadingAny
                        ? const Card(child: Padding(padding: EdgeInsets.all(16), child: SkeletonBox(height: 70)))
                        : StatCard(
                            title: 'العروض الترويجية',
                            value: '${offersProv.activeOffersCount}',
                            icon: Icons.local_offer_outlined,
                            iconBgColor: AppColors.bronze.withValues(alpha: 0.15),
                            iconColor: AppColors.bronze,
                            subtitle: 'بانرات عروض نشطة حالياً',
                            onTap: () => widget.onNavigateToTab(3),
                          ),
                  ),
                  SizedBox(
                    width: width,
                    child: isLoadingAny
                        ? const Card(child: Padding(padding: EdgeInsets.all(16), child: SkeletonBox(height: 70)))
                        : StatCard(
                            title: 'الأقسام والتصنيفات',
                            value: '${categoriesProv.totalCategories}',
                            icon: Icons.category_outlined,
                            iconBgColor: AppColors.olive.withValues(alpha: 0.15),
                            iconColor: AppColors.olive,
                            subtitle: 'تصنيفات ومجموعات الأزياء',
                            onTap: () => widget.onNavigateToTab(2),
                          ),
                  ),
                  SizedBox(
                    width: width,
                    child: isLoadingAny
                        ? const Card(child: Padding(padding: EdgeInsets.all(16), child: SkeletonBox(height: 70)))
                        : StatCard(
                            title: 'منتجات نفذت الكمية',
                            value: '${productsProv.outOfStockCount}',
                            icon: Icons.remove_shopping_cart_outlined,
                            iconBgColor: AppColors.dangerBg,
                            iconColor: AppColors.danger,
                            subtitle: 'تتطلب إتاحة أو توفير',
                            onTap: () => widget.onNavigateToTab(1),
                          ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Interactive Products Control Table Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Tab Header Bar
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmall = constraints.maxWidth < 600;

                      final tabs = Wrap(
                        children: [
                          _buildFilterTab(0, 'الأحدث مضافة (${productsProv.products.length})'),
                          _buildFilterTab(1, 'المميزة بالرئيسية (${productsProv.products.where((p) => p.isFeatured).length})'),
                          _buildFilterTab(2, 'نفذت الكمية (${productsProv.outOfStockCount})'),
                        ],
                      );

                      final viewAllBtn = TextButton.icon(
                        onPressed: () => widget.onNavigateToTab(1),
                        icon: const Icon(Icons.arrow_forward_ios, size: 12),
                        label: const Text('إدارة جميع المنتجات'),
                      );

                      if (isSmall) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            tabs,
                            const SizedBox(height: 12),
                            Align(alignment: Alignment.centerLeft, child: viewAllBtn),
                          ],
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: tabs),
                          viewAllBtn,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  if (productsProv.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: SkeletonBox(height: 120),
                    )
                  else if (displayedProducts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 8),
                            const Text(
                              'لا توجد منتجات مطابقة لهذا الفلتر حالياً',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedProducts.take(6).length,
                      separatorBuilder: (ctx, i) => const Divider(),
                      itemBuilder: (ctx, index) {
                        final product = displayedProducts[index];
                        final firstImage = product.imageUrls.isNotEmpty
                            ? product.imageUrls.first
                            : 'https://via.placeholder.com/100';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              firstImage,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 52,
                                height: 52,
                                color: AppColors.lines,
                                child: const Icon(Icons.image, color: AppColors.textMuted),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.nameAr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (product.badge != null && product.badge!.isNotEmpty) ...[
                                const SizedBox(width: 8),
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
                          subtitle: Text(
                            '${product.categoryName} • ${Formatters.formatCurrency(product.price)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: product.isAvailable,
                                activeThumbColor: AppColors.success,
                                onChanged: (val) {
                                  productsProv.toggleAvailability(product.id, val);
                                },
                              ),
                              if (!isMobile) ...[
                                const SizedBox(width: 4),
                                Text(
                                  product.isAvailable ? 'متوفر' : 'نفذت',
                                  style: TextStyle(
                                    color: product.isAvailable ? AppColors.success : AppColors.danger,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () {
                                  ProductFormDialog.show(context, product: product);
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

          const SizedBox(height: 24),

          // Operational Summary Footer Card
          Card(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.olive, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${settings.storeNameAr} • ${settings.addressAr}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'الهاتف: ${settings.phone} | الواتساب: ${settings.whatsapp} | ساعات العمل: ${settings.openingHours}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateToTab(4),
                    child: const Text('تعديل التفاصيل'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(int index, String label) {
    final isSelected = _activeFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.ink,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (_) {
          setState(() {
            _activeFilterIndex = index;
          });
        },
      ),
    );
  }
}
