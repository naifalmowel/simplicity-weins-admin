import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/supabase_config.dart';
import '../../models/store_settings_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/custom_snack_bar.dart';
import '../widgets/image_uploader_box.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _storeNameController;
  late TextEditingController _storeNameArController;
  late TextEditingController _sloganController;
  late TextEditingController _sloganArController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _instagramController;
  late TextEditingController _addressArController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _googleMapsUrlController;
  late TextEditingController _deliveryTextArController;
  late TextEditingController _openingHoursController;

  bool _isClosed = false;
  bool _isBusy = false;
  bool _whatsappAlwaysActive = true;

  List<String> _storeImageUrls = [];
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final settings = Provider.of<SettingsProvider>(context).settings;
      _initControllers(settings);
      _initialized = true;
    }
  }

  void _initControllers(StoreSettingsModel s) {
    _storeNameController = TextEditingController(text: s.storeName);
    _storeNameArController = TextEditingController(text: s.storeNameAr);
    _sloganController = TextEditingController(text: s.slogan);
    _sloganArController = TextEditingController(text: s.sloganAr);
    _phoneController = TextEditingController(text: s.phone);
    _whatsappController = TextEditingController(text: s.whatsapp);
    _instagramController = TextEditingController(text: s.instagram);
    _addressArController = TextEditingController(text: s.addressAr);
    _latitudeController = TextEditingController(text: s.latitude.toString());
    _longitudeController = TextEditingController(text: s.longitude.toString());
    _googleMapsUrlController = TextEditingController(text: s.googleMapsUrl);
    _deliveryTextArController = TextEditingController(text: s.deliveryTextAr);
    _openingHoursController = TextEditingController(text: s.openingHours);

    _isClosed = s.isClosed;
    _isBusy = s.isBusy;
    _whatsappAlwaysActive = s.whatsappAlwaysActive;

    _storeImageUrls = s.storeImageUrl.isNotEmpty ? [s.storeImageUrl] : [];
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeNameArController.dispose();
    _sloganController.dispose();
    _sloganArController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _addressArController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _googleMapsUrlController.dispose();
    _deliveryTextArController.dispose();
    _openingHoursController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final lat = double.tryParse(_latitudeController.text.trim()) ?? 33.6142;
      final lng = double.tryParse(_longitudeController.text.trim()) ?? 36.3115;

      final updatedSettings = StoreSettingsModel(
        storeName: _storeNameController.text.trim(),
        storeNameAr: _storeNameArController.text.trim(),
        logoUrl: '',
        mobileLogoUrl: '',
        storeImageUrl: _storeImageUrls.isNotEmpty ? _storeImageUrls.first : '',
        phone: _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        instagram: _instagramController.text.trim(),
        addressAr: _addressArController.text.trim(),
        latitude: lat,
        longitude: lng,
        googleMapsUrl: _googleMapsUrlController.text.trim(),
        deliveryTextAr: _deliveryTextArController.text.trim(),
        slogan: _sloganController.text.trim(),
        sloganAr: _sloganArController.text.trim(),
        isClosed: _isClosed,
        isBusy: _isBusy,
        openingHours: _openingHoursController.text.trim(),
        whatsappAlwaysActive: _whatsappAlwaysActive,
      );

      final settingsProv = Provider.of<SettingsProvider>(context, listen: false);
      await settingsProv.saveSettings(updatedSettings);

      if (mounted) {
        setState(() => _isSaving = false);
        CustomSnackBar.showSuccess(context, 'تم حفظ إعدادات وحالة المتجر بنجاح!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        CustomSnackBar.showError(context, 'حدث خطأ أثناء حفظ الإعدادات: $e');
      }
    }
  }

  /// Programmatic Clear All Data function
  // ignore: unused_element
  void _clearAllStoreDataProgrammatically() {
    ConfirmDialog.show(
      context,
      title: 'تصفير وإفراغ كافة البيانات',
      message: 'تحذير: هل أنت تأكد من أنك تريد تصفير وحذف جميع المنتجات، التصنيفات، والعروض الحالية للبدء بإضافة بياناتك الخاصة؟ لا يمكن التراجع عن هذه الخطوة.',
      confirmText: 'تأكيد التصفير',
      cancelText: 'إلغاء',
      isDanger: true,
      onConfirm: () async {
        final firestoreService = Provider.of<FirestoreService>(context, listen: false);
        await firestoreService.clearAllData();
        if (mounted) {
          CustomSnackBar.showSuccess(context, 'تم تصفير وإفراغ كافة البيانات بنجاح!');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProv = Provider.of<SettingsProvider>(context);

    if (settingsProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_storeImageUrls.isEmpty && settingsProv.settings.storeImageUrl.isNotEmpty) {
      _storeImageUrls = [settingsProv.settings.storeImageUrl];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar (Responsive)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 600;

                    final titleWidget = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'إعدادات وتفاصيل المتجر',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'تعديل تفاصيل التواصل، حالة المحل (مغلق/مشغول)، ساعات العمل، وصورة المتجر',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    );

                    final saveButton = ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveSettings,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                            )
                          : const Icon(Icons.save, size: 20),
                      label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ التعديلات'),
                    );

                    if (isSmall) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          titleWidget,
                          const SizedBox(height: 16),
                          saveButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: titleWidget),
                        const SizedBox(width: 12),
                        saveButton,
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // STORE STATUS & OPENING HOURS CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.storefront, color: AppColors.ink, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'حالة المحل وساعات العمل',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Status Switches Row
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lines),
                      ),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 16,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Is Closed Switch
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: _isClosed,
                                activeThumbColor: AppColors.danger,
                                onChanged: (v) {
                                  setState(() {
                                    _isClosed = v;
                                    if (v) _isBusy = false;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'المحل مغلق حالياً',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _isClosed ? AppColors.danger : AppColors.textPrimary,
                                    ),
                                  ),
                                  const Text(
                                    'إظهار التنبيه للزبائن',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Is Busy Switch
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: _isBusy,
                                activeThumbColor: AppColors.warning,
                                onChanged: (v) {
                                  setState(() {
                                    _isBusy = v;
                                    if (v) _isClosed = false;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'المحل مشغول / أوقات ذروة',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _isBusy ? AppColors.warning : AppColors.textPrimary,
                                    ),
                                  ),
                                  const Text(
                                    'تنبيه الزبائن باحتمال تأخر الرد',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // WhatsApp 24/7 Switch
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: _whatsappAlwaysActive,
                                activeThumbColor: AppColors.success,
                                onChanged: (v) {
                                  setState(() => _whatsappAlwaysActive = v);
                                },
                              ),
                              const SizedBox(width: 8),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الواتساب يعمل 24/7',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  Text(
                                    'متاح طوال الوقت',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Opening Hours Field
                    TextFormField(
                      controller: _openingHoursController,
                      decoration: const InputDecoration(
                        labelText: 'ساعات عمل وافتتاح المحل',
                        hintText: 'مثال: يومياً من 10:00 صباحاً حتى 10:00 مساءً',
                        prefixIcon: Icon(Icons.access_time_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Store Identity Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'هوية المتجر والشعار',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _storeNameArController,
                            decoration: const InputDecoration(labelText: 'اسم المتجر بالعربية'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _storeNameController,
                            decoration: const InputDecoration(labelText: 'اسم المتجر بالإنكليزية'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _sloganArController,
                            decoration: const InputDecoration(labelText: 'الشعار العربي'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _sloganController,
                            decoration: const InputDecoration(labelText: 'الشعار الإنكليزي'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ImageUploaderBox(
                      bucketName: SupabaseConfig.mainBucket,
                      currentImageUrls: _storeImageUrls,
                      isMultiple: false,
                      label: 'صورة غلاف المتجر Store Cover Image',
                      onImagesUpdated: (urls) {
                        setState(() => _storeImageUrls = urls);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Contact Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معلومات التواصل والموقع',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                    const Divider(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 650;
                        if (isSmall) {
                          return Column(
                            children: [
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'رقم الهاتف',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _whatsappController,
                                decoration: const InputDecoration(
                                  labelText: 'رقم الواتساب WhatsApp',
                                  prefixIcon: Icon(Icons.chat_bubble_outline),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _instagramController,
                                decoration: const InputDecoration(
                                  labelText: 'حساب الإنستغرام Instagram',
                                  prefixIcon: Icon(Icons.camera_alt_outlined),
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'رقم الهاتف',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _whatsappController,
                                decoration: const InputDecoration(
                                  labelText: 'رقم الواتساب WhatsApp',
                                  prefixIcon: Icon(Icons.chat_bubble_outline),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _instagramController,
                                decoration: const InputDecoration(
                                  labelText: 'حساب الإنستغرام Instagram',
                                  prefixIcon: Icon(Icons.camera_alt_outlined),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressArController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان التفصيلي بالعربية',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latitudeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'خط العرض Latitude'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _longitudeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'خط الطول Longitude'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _googleMapsUrlController,
                      decoration: const InputDecoration(
                        labelText: 'رابط خرائط جوجل Google Maps Link',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deliveryTextArController,
                      decoration: const InputDecoration(
                        labelText: 'نص معلومات الشحن والتوصيل',
                        prefixIcon: Icon(Icons.local_shipping_outlined),
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
