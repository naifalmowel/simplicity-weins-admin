import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/supabase_config.dart';
import '../../models/offer_model.dart';
import '../../providers/offers_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/custom_snack_bar.dart';
import '../widgets/image_uploader_box.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  void _showOfferDialog(BuildContext context, {OfferModel? offer}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _OfferFormModal(offer: offer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offersProv = Provider.of<OffersProvider>(context);

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
                          'إدارة العروض',
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
                            '${offersProv.activeOffersCount} نشط',
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
                      onPressed: () => _showOfferDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة عرض جديد', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Offers Cards Grid
          Expanded(
            child: offersProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : offersProv.offers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_offer_outlined, size: 56, color: AppColors.textMuted),
                            const SizedBox(height: 10),
                            const Text(
                              'لا توجد عروض ترويجية حالياً',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: offersProv.offers.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 14),
                        itemBuilder: (ctx, index) {
                          final offer = offersProv.offers[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isSmall = constraints.maxWidth < 600;

                                if (isSmall) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        height: 160,
                                        child: Image.network(
                                          offer.imageUrl.isNotEmpty
                                              ? offer.imageUrl
                                              : 'https://via.placeholder.com/400x200',
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            color: AppColors.lines,
                                            child: const Icon(Icons.local_offer, color: AppColors.textMuted),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    offer.titleAr,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: offer.isActive ? AppColors.successBg : AppColors.dangerBg,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    offer.isActive ? 'نشط' : 'غير نشط',
                                                    style: TextStyle(
                                                      color: offer.isActive ? AppColors.success : AppColors.danger,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              offer.descriptionAr,
                                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                            ),
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 6,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.ink,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    'زر التفاعل: ${offer.buttonText}',
                                                    style: const TextStyle(color: AppColors.white, fontSize: 11),
                                                  ),
                                                ),
                                                Text(
                                                  'رابط: ${offer.buttonLink}',
                                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                                  onPressed: () => _showOfferDialog(context, offer: offer),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                                                  onPressed: () {
                                                    ConfirmDialog.show(
                                                      context,
                                                      title: 'حذف العرض',
                                                      message: 'هل أنت تأكد من أنك تريد حذف هذا العرض الترويجي؟',
                                                      onConfirm: () async {
                                                        await offersProv.deleteOffer(offer);
                                                        if (context.mounted) {
                                                          CustomSnackBar.showSuccess(context, 'تم حذف العرض بنجاح');
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
                                  );
                                }

                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      height: 120,
                                      child: Image.network(
                                        offer.imageUrl.isNotEmpty
                                            ? offer.imageUrl
                                            : 'https://via.placeholder.com/400x200',
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          color: AppColors.lines,
                                          child: const Icon(Icons.local_offer, color: AppColors.textMuted),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    offer.titleAr,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: offer.isActive ? AppColors.successBg : AppColors.dangerBg,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    offer.isActive ? 'نشط' : 'غير نشط',
                                                    style: TextStyle(
                                                      color: offer.isActive ? AppColors.success : AppColors.danger,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              offer.descriptionAr,
                                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 6,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.ink,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    'زر التفاعل: ${offer.buttonText}',
                                                    style: const TextStyle(color: AppColors.white, fontSize: 11),
                                                  ),
                                                ),
                                                Text(
                                                  'رابط: ${offer.buttonLink}',
                                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18),
                                            onPressed: () => _showOfferDialog(context, offer: offer),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                                            onPressed: () {
                                              ConfirmDialog.show(
                                                context,
                                                title: 'حذف العرض',
                                                message: 'هل أنت تأكد من أنك تريد حذف هذا العرض الترويجي؟',
                                                onConfirm: () async {
                                                  await offersProv.deleteOffer(offer);
                                                  if (context.mounted) {
                                                    CustomSnackBar.showSuccess(context, 'تم حذف العرض بنجاح');
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
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

class _OfferFormModal extends StatefulWidget {
  final OfferModel? offer;

  const _OfferFormModal({this.offer});

  @override
  State<_OfferFormModal> createState() => _OfferFormModalState();
}

class _OfferFormModalState extends State<_OfferFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleArController;
  late TextEditingController _titleEnController;
  late TextEditingController _descArController;
  late TextEditingController _descEnController;
  late TextEditingController _btnTextController;
  late TextEditingController _btnLinkController;

  List<String> _imageUrls = [];
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final o = widget.offer;
    _titleArController = TextEditingController(text: o?.titleAr ?? '');
    _titleEnController = TextEditingController(text: o?.title ?? '');
    _descArController = TextEditingController(text: o?.descriptionAr ?? '');
    _descEnController = TextEditingController(text: o?.description ?? '');
    _btnTextController = TextEditingController(text: o?.buttonText ?? 'تسوق الآن');
    _btnLinkController = TextEditingController(text: o?.buttonLink ?? '/products');
    _imageUrls = o != null && o.imageUrl.isNotEmpty ? [o.imageUrl] : [];
    _isActive = o?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _btnTextController.dispose();
    _btnLinkController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrls.isEmpty) {
      CustomSnackBar.showError(context, 'الرجاء رفع صورة بانر للعرض');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newOffer = OfferModel(
        id: widget.offer?.id ?? '',
        titleAr: _titleArController.text.trim(),
        title: _titleEnController.text.trim(),
        descriptionAr: _descArController.text.trim(),
        description: _descEnController.text.trim(),
        imageUrl: _imageUrls.first,
        buttonText: _btnTextController.text.trim(),
        buttonLink: _btnLinkController.text.trim(),
        isActive: _isActive,
        displayOrder: widget.offer?.displayOrder ?? 1,
      );

      final offersProv = Provider.of<OffersProvider>(context, listen: false);
      await offersProv.saveOffer(newOffer);

      if (mounted) {
        Navigator.of(context).pop();
        CustomSnackBar.showSuccess(
          context,
          widget.offer == null ? 'تمت إضافة العرض بنجاح' : 'تم تعديل العرض بنجاح',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        CustomSnackBar.showError(context, 'حدث خطأ أثناء حفظ العرض');
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
        width: 620,
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
              // Modal Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.offer == null ? 'إضافة عرض ترويجي جديد' : 'تعديل بيانات العرض',
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

              // Modal Form Content (Scrollable)
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 500;
                          if (isCompact) {
                            return Column(
                              children: [
                                TextFormField(
                                  controller: _titleArController,
                                  decoration: const InputDecoration(labelText: 'عنوان العرض بالعربية *'),
                                  validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _titleEnController,
                                  decoration: const InputDecoration(labelText: 'العنوان بالإنكليزية'),
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _titleArController,
                                  decoration: const InputDecoration(labelText: 'عنوان العرض بالعربية *'),
                                  validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _titleEnController,
                                  decoration: const InputDecoration(labelText: 'العنوان بالإنكليزية'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descArController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'وصف العرض بالعربية',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 500;
                          if (isCompact) {
                            return Column(
                              children: [
                                TextFormField(
                                  controller: _btnTextController,
                                  decoration: const InputDecoration(labelText: 'نص الزر CTA (مثال: تسوق الآن)'),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _btnLinkController,
                                  decoration: const InputDecoration(labelText: 'رابط الزر (مثل: /products)'),
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _btnTextController,
                                  decoration: const InputDecoration(labelText: 'نص الزر CTA (مثال: تسوق الآن)'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _btnLinkController,
                                  decoration: const InputDecoration(labelText: 'رابط الزر (مثل: /products)'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ImageUploaderBox(
                        bucketName: SupabaseConfig.mainBucket,
                        currentImageUrls: _imageUrls,
                        isMultiple: false,
                        label: 'صورة بانر العرض Banner Image',
                        onImagesUpdated: (urls) {
                          setState(() => _imageUrls = urls);
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.lines),
                        ),
                        child: Row(
                          children: [
                            Switch(
                              value: _isActive,
                              activeThumbColor: AppColors.success,
                              onChanged: (v) => setState(() => _isActive = v),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'تفعيل العرض في المتجر',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Modal Footer Buttons
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
                        : const Text('حفظ العرض', style: TextStyle(fontWeight: FontWeight.bold)),
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
