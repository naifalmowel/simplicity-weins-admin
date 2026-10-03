import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/supabase_config.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../providers/categories_provider.dart';
import '../widgets/image_uploader_box.dart';
import '../widgets/custom_snack_bar.dart';

class ProductFormDialog extends StatefulWidget {
  final ProductModel? product;

  const ProductFormDialog({super.key, this.product});

  static Future<void> show(BuildContext context, {ProductModel? product}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ProductFormDialog(product: product),
    );
  }

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameArController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionArController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _oldPriceController;

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  List<String> _imageUrls = [];
  List<String> _selectedSizes = [];
  List<String> _selectedColors = [];
  List<String> _availableColorsList = [];
  List<String> _availableBadgesList = [];
  String? _selectedBadge;

  bool _isAvailable = true;
  bool _isFeatured = false;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameArController = TextEditingController(text: p?.nameAr ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionArController = TextEditingController(text: p?.descriptionAr ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _oldPriceController = TextEditingController(text: p?.oldPrice != null ? p!.oldPrice!.toStringAsFixed(0) : '');

    _selectedCategoryId = p?.categoryId;
    _selectedCategoryName = p?.categoryName;
    _imageUrls = p != null ? List<String>.from(p.imageUrls) : [];
    _selectedSizes = p != null ? List<String>.from(p.sizes) : ['S', 'M', 'L', 'XL'];
    _selectedColors = p != null ? List<String>.from(p.colors) : ['أسود', 'بيج'];

    _availableColorsList = List.from(AppConstants.availableColors);
    for (final c in _selectedColors) {
      if (!_availableColorsList.contains(c)) {
        _availableColorsList.add(c);
      }
    }

    _availableBadgesList = List.from(AppConstants.availableBadges);
    _selectedBadge = p?.badge;
    if (_selectedBadge != null && !_availableBadgesList.contains(_selectedBadge!)) {
      _availableBadgesList.add(_selectedBadge!);
    }

    _isAvailable = p?.isAvailable ?? true;
    _isFeatured = p?.isFeatured ?? false;
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameController.dispose();
    _descriptionArController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _oldPriceController.dispose();
    super.dispose();
  }

  void _addCustomColorDialog() {
    final customColorController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة لون جديد'),
        content: TextField(
          controller: customColorController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'اسم اللون (مثال: تيراكوتا، أوف وايت)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final newColor = customColorController.text.trim();
              if (newColor.isNotEmpty) {
                setState(() {
                  if (!_availableColorsList.contains(newColor)) {
                    _availableColorsList.add(newColor);
                  }
                  if (!_selectedColors.contains(newColor)) {
                    _selectedColors.add(newColor);
                  }
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('إضافة اللون'),
          ),
        ],
      ),
    );
  }

  void _addCustomBadgeDialog() {
    final customBadgeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة شارة منتج جديدة'),
        content: TextField(
          controller: customBadgeController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'اسم الشارة (مثال: حسم 30%، تصميم خاص)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final newBadge = customBadgeController.text.trim();
              if (newBadge.isNotEmpty) {
                setState(() {
                  if (!_availableBadgesList.contains(newBadge)) {
                    _availableBadgesList.add(newBadge);
                  }
                  _selectedBadge = newBadge;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('إضافة الشارة'),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    final categoriesProv = Provider.of<CategoriesProvider>(context, listen: false);
    if (categoriesProv.categories.isEmpty) {
      CustomSnackBar.showError(
        context,
        'عذراً! لا يمكن إضافة منتج بدون وجود أقسام في المتجر. الرجاء إدخال قسم جديد من تبويب التصنيفات أولاً.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      CustomSnackBar.showError(context, 'الرجاء اختيار قسم المنتج');
      return;
    }

    if (_imageUrls.isEmpty) {
      CustomSnackBar.showError(context, 'الرجاء إضافة صورة واحدة على الأقل للمنتج');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final price = double.parse(_priceController.text.trim());
      final oldPrice = _oldPriceController.text.trim().isNotEmpty
          ? double.tryParse(_oldPriceController.text.trim())
          : null;

      final now = DateTime.now();

      final newProduct = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim().isEmpty ? _nameArController.text.trim() : _nameController.text.trim(),
        nameAr: _nameArController.text.trim(),
        description: _descriptionController.text.trim(),
        descriptionAr: _descriptionArController.text.trim(),
        price: price,
        oldPrice: oldPrice,
        categoryId: _selectedCategoryId!,
        categoryName: _selectedCategoryName ?? '',
        imageUrls: _imageUrls,
        sizes: _selectedSizes,
        colors: _selectedColors,
        badge: _selectedBadge,
        isFeatured: _isFeatured,
        isAvailable: _isAvailable,
        isActive: _isActive,
        displayOrder: widget.product?.displayOrder ?? 0,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
      );

      final productsProv = Provider.of<ProductsProvider>(context, listen: false);
      await productsProv.saveProduct(newProduct);

      if (mounted) {
        Navigator.of(context).pop();
        CustomSnackBar.showSuccess(
          context,
          widget.product == null ? 'تمت إضافة المنتج بنجاح!' : 'تم تعديل المنتج بنجاح!',
        );
      }
    } catch (e) {
      debugPrint("Error saving product: $e");
      if (mounted) {
        setState(() => _isSaving = false);
        CustomSnackBar.showError(context, 'حدث خطأ أثناء حفظ المنتج: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProv = Provider.of<CategoriesProvider>(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 760,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Dialog Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: AppColors.ink, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      widget.product == null ? 'إضافة منتج جديد' : 'تعديل بيانات المنتج',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Form Body
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (categoriesProv.categories.isEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'تنبيه: لا توجد أقسام/تصنيفات مضافة في المتجر حالياً. يجب إضافة قسم واحد على الأقل من تبويب "التصنيفات" قبل إمكانية إضافة منتج.',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Names Section
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmall = constraints.maxWidth < 550;

                          final nameArField = TextFormField(
                            controller: _nameArController,
                            decoration: const InputDecoration(
                              labelText: 'اسم المنتج بالعربية *',
                              hintText: 'مثال: هوديز أوفرسايز أنيق',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                          );

                          final nameEnField = TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم المنتج بالإنكليزية (اختياري)',
                              hintText: 'e.g. Oversized Hoodie',
                            ),
                          );

                          if (isSmall) {
                            return Column(
                              children: [
                                nameArField,
                                const SizedBox(height: 16),
                                nameEnField,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: nameArField),
                              const SizedBox(width: 16),
                              Expanded(child: nameEnField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown & Price Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmall = constraints.maxWidth < 600;

                          final categoryDropdown = DropdownButtonFormField<String>(
                            initialValue: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'تصنيف المنتج *',
                            ),
                            items: categoriesProv.categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.nameAr),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCategoryId = val;
                                _selectedCategoryName = categoriesProv.categories
                                    .firstWhere((c) => c.id == val,
                                        orElse: () => CategoryModel(
                                              id: '',
                                              name: '',
                                              nameAr: '',
                                              imageUrl: '',
                                              displayOrder: 0,
                                              isActive: true,
                                            ))
                                    .nameAr;
                              });
                            },
                            validator: (v) => v == null ? 'الرجاء اختيار قسم' : null,
                          );

                          final priceField = TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'السعر (ل.س) *',
                              hintText: '185000',
                              suffixText: 'ل.س',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
                              if (double.tryParse(v.trim()) == null) return 'رقم غير صحيح';
                              return null;
                            },
                          );

                          final oldPriceField = TextFormField(
                            controller: _oldPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'السعر القديم (قبل الخصم)',
                              hintText: '220000',
                              suffixText: 'ل.س',
                            ),
                          );

                          if (isSmall) {
                            return Column(
                              children: [
                                categoryDropdown,
                                const SizedBox(height: 16),
                                priceField,
                                const SizedBox(height: 16),
                                oldPriceField,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: categoryDropdown),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: priceField),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: oldPriceField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Descriptions
                      TextFormField(
                        controller: _descriptionArController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'وصف المنتج بالعربية',
                          hintText: 'تفاصيل الخامة، القصّة، والجودة...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Supabase Storage Image Uploader
                      ImageUploaderBox(
                        bucketName: SupabaseConfig.mainBucket,
                        currentImageUrls: _imageUrls,
                        label: 'صور المنتج (Supabase Storage)',
                        onImagesUpdated: (urls) {
                          setState(() {
                            _imageUrls = urls;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Sizes Selection Chips
                      const Text(
                        'المقاسات المتاحة Sizes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.availableSizes.map((size) {
                          final isSelected = _selectedSizes.contains(size);
                          return FilterChip(
                            label: Text(size),
                            selected: isSelected,
                            selectedColor: AppColors.ink,
                            checkmarkColor: AppColors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSizes.add(size);
                                } else {
                                  _selectedSizes.remove(size);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Colors Selection Chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الألوان المتاحة Colors',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextButton.icon(
                            onPressed: _addCustomColorDialog,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('إضافة لون جديد'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableColorsList.map((color) {
                          final isSelected = _selectedColors.contains(color);
                          return FilterChip(
                            label: Text(color),
                            selected: isSelected,
                            selectedColor: AppColors.bronze,
                            checkmarkColor: AppColors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedColors.add(color);
                                } else {
                                  _selectedColors.remove(color);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Badge Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'شارة المنتج Badge (اختياري)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextButton.icon(
                            onPressed: _addCustomBadgeDialog,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('إضافة شارة جديدة'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('بدون شارة'),
                            selected: _selectedBadge == null,
                            onSelected: (_) => setState(() => _selectedBadge = null),
                          ),
                          ..._availableBadgesList.map((badge) {
                            return ChoiceChip(
                              label: Text(badge),
                              selected: _selectedBadge == badge,
                              selectedColor: AppColors.olive,
                              labelStyle: TextStyle(
                                color: _selectedBadge == badge ? AppColors.white : AppColors.textPrimary,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedBadge = selected ? badge : null;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Switches Wrap Container
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.lines),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceAround,
                          runSpacing: 12,
                          spacing: 16,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: _isAvailable,
                                  activeThumbColor: AppColors.success,
                                  onChanged: (v) => setState(() => _isAvailable = v),
                                ),
                                const Text('متوفر في المخزون'),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: _isFeatured,
                                  activeThumbColor: AppColors.bronze,
                                  onChanged: (v) => setState(() => _isFeatured = v),
                                ),
                                const Text('منتج مميز الرئيسية'),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: _isActive,
                                  activeThumbColor: AppColors.ink,
                                  onChanged: (v) => setState(() => _isActive = v),
                                ),
                                const Text('نشط ومفعل'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Dialog Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: (categoriesProv.categories.isEmpty || _isSaving) ? null : _submitForm,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Icon(Icons.save, size: 18),
                  label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ المنتج'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
