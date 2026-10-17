import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/supabase_config.dart';
import '../../models/category_model.dart';
import '../../providers/categories_provider.dart';
import '../../providers/products_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/custom_snack_bar.dart';
import '../widgets/image_uploader_box.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CategoryFormModal(category: category),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProv = Provider.of<CategoriesProvider>(context);
    final productsProv = Provider.of<ProductsProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Toolbar Header
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'إدارة التصنيفات',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${categoriesProv.totalCategories}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showCategoryDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة قسم جديد', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Categories Grid
          Expanded(
            child: categoriesProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : categoriesProv.categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category_outlined, size: 56, color: AppColors.textMuted),
                            const SizedBox(height: 10),
                            const Text(
                              'لا توجد تصنيفات مسجلة حالياً',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 1100
                              ? 4
                              : (constraints.maxWidth > 700 ? 3 : (constraints.maxWidth > 480 ? 2 : 1));

                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 1.1,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemCount: categoriesProv.categories.length,
                            itemBuilder: (context, index) {
                              final cat = categoriesProv.categories[index];
                              final linkedProductsCount = productsProv.products
                                  .where((p) => p.categoryId == cat.id)
                                  .length;

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
                                              cat.imageUrl.isNotEmpty
                                                  ? cat.imageUrl
                                                  : 'https://via.placeholder.com/200',
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Container(
                                                color: AppColors.lines,
                                                child: const Icon(Icons.category, color: AppColors.textMuted, size: 36),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.ink.withValues(alpha: 0.8),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '$linkedProductsCount منتجات',
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
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cat.nameAr,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            cat.name.isNotEmpty ? cat.name : 'ترتيب: ${cat.displayOrder}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, size: 18),
                                                onPressed: () => _showCategoryDialog(context, category: cat),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                                                onPressed: () {
                                                  // Check linked products constraint before deleting
                                                  if (linkedProductsCount > 0) {
                                                    CustomSnackBar.showError(
                                                      context,
                                                      'لا يمكن حذف القسم لأنه مرتبط بـ $linkedProductsCount منتجات حقيقية. قم بحذف أو نقل المنتجات أولاً.',
                                                    );
                                                    return;
                                                  }

                                                  ConfirmDialog.show(
                                                    context,
                                                    title: 'حذف القسم',
                                                    message: 'هل أنت تأكد من أنك تريد حذف قسم "${cat.nameAr}"؟',
                                                    onConfirm: () async {
                                                      await categoriesProv.deleteCategory(cat);
                                                      if (context.mounted) {
                                                        CustomSnackBar.showSuccess(context, 'تم حذف القسم بنجاح');
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
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFormModal extends StatefulWidget {
  final CategoryModel? category;

  const _CategoryFormModal({this.category});

  @override
  State<_CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends State<_CategoryFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameArController;
  late TextEditingController _nameController;
  late TextEditingController _orderController;

  List<String> _imageUrls = [];
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameArController = TextEditingController(text: c?.nameAr ?? '');
    _nameController = TextEditingController(text: c?.name ?? '');
    _orderController = TextEditingController(text: c != null ? c.displayOrder.toString() : '1');
    _imageUrls = c != null && c.imageUrl.isNotEmpty ? [c.imageUrl] : [];
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrls.isEmpty) {
      CustomSnackBar.showError(context, 'الرجاء رفع صورة للقسم');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final order = int.tryParse(_orderController.text.trim()) ?? 0;

      final newCat = CategoryModel(
        id: widget.category?.id ?? '',
        nameAr: _nameArController.text.trim(),
        name: _nameController.text.trim(),
        imageUrl: _imageUrls.first,
        displayOrder: order,
        isActive: _isActive,
      );

      final categoriesProv = Provider.of<CategoriesProvider>(context, listen: false);
      await categoriesProv.saveCategory(newCat);

      if (mounted) {
        Navigator.of(context).pop();
        CustomSnackBar.showSuccess(
          context,
          widget.category == null ? 'تمت إضافة القسم بنجاح' : 'تم تعديل القسم بنجاح',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        CustomSnackBar.showError(context, 'حدث خطأ أثناء الحفظ');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.90,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.category == null ? 'إضافة قسم جديد' : 'تعديل بيانات القسم',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Scrollable Form Body
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameArController,
                        decoration: const InputDecoration(labelText: 'اسم القسم بالعربية *'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'اسم القسم بالإنكليزية (اختياري)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _orderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'ترتيب العرض (1, 2, 3...)'),
                      ),
                      const SizedBox(height: 16),
                      ImageUploaderBox(
                        bucketName: SupabaseConfig.mainBucket,
                        currentImageUrls: _imageUrls,
                        isMultiple: false,
                        label: 'صورة غلاف القسم Category Image',
                        onImagesUpdated: (urls) {
                          setState(() => _imageUrls = urls);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 12),
                    ),
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : const Text('حفظ القسم', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
