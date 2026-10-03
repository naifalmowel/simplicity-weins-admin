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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إدارة تصنيفات الأزياء Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'إجمالي التصنيفات: ${categoriesProv.totalCategories}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(context),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('إضافة قسم جديد'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Categories Grid
          Expanded(
            child: categoriesProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : categoriesProv.categories.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد تصنيفات مضافة حالياً',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          mainAxisExtent: 260,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: categoriesProv.categories.length,
                        itemBuilder: (ctx, index) {
                          final category = categoriesProv.categories[index];
                          final linkedProductsCount = productsProv.products
                              .where((p) => p.categoryId == category.id)
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
                                          category.imageUrl.isNotEmpty
                                              ? category.imageUrl
                                              : 'https://via.placeholder.com/300',
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            color: AppColors.lines,
                                            child: const Center(
                                              child: Icon(Icons.category, color: AppColors.textMuted, size: 36),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.ink.withValues(alpha: 0.85),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '$linkedProductsCount منتج',
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
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              category.nameAr,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (category.name.isNotEmpty)
                                              Text(
                                                category.name,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 20),
                                            onPressed: () => _showCategoryDialog(context, category: category),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                            onPressed: () {
                                              if (linkedProductsCount > 0) {
                                                CustomSnackBar.showError(
                                                  context,
                                                  'عذراً! لا يمكن حذف قسم "${category.nameAr}" لأنه يحتوي على $linkedProductsCount منتج مرتبط به. الرجاء نقل أو حذف المنتجات المرتبطة به أولاً.',
                                                );
                                                return;
                                              }

                                              ConfirmDialog.show(
                                                context,
                                                title: 'حذف القسم',
                                                message: 'هل أنت تأكد من أنك تريد حذف قسم "${category.nameAr}"؟',
                                                onConfirm: () async {
                                                  await categoriesProv.deleteCategory(category);
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
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.category == null ? 'إضافة قسم جديد' : 'تعديل بيانات القسم',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
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
                label: 'صورة غلاف القسم',
                onImagesUpdated: (urls) {
                  setState(() => _imageUrls = urls);
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    child: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ القسم'),
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
