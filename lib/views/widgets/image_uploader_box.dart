import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/storage_service.dart';

class ImageUploaderBox extends StatefulWidget {
  final String bucketName;
  final List<String> currentImageUrls;
  final Function(List<String> newUrls) onImagesUpdated;
  final bool isMultiple;
  final String label;

  const ImageUploaderBox({
    super.key,
    required this.bucketName,
    required this.currentImageUrls,
    required this.onImagesUpdated,
    this.isMultiple = true,
    this.label = 'رفع صور للمنتج إلى Supabase Storage',
  });

  @override
  State<ImageUploaderBox> createState() => _ImageUploaderBoxState();
}

class _ImageUploaderBoxState extends State<ImageUploaderBox> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _statusText = '';

  Future<void> _pickAndUploadImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: widget.isMultiple,
        withData: true, // Guarantees Uint8List bytes for cross-platform
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.1;
        _statusText = 'جاري تحضير الصور...';
      });

      if (!mounted) return;
      final storageService = Provider.of<StorageService>(context, listen: false);
      final List<String> uploadedUrls = List.from(widget.currentImageUrls);

      int totalFiles = result.files.length;
      int processedCount = 0;

      for (var file in result.files) {
        if (file.bytes != null) {
          final fileName = file.name;
          final url = await storageService.uploadImageBytes(
            bytes: file.bytes!,
            fileName: fileName,
            bucketName: widget.bucketName,
            onProgress: (progress) {
              if (mounted) {
                setState(() {
                  _uploadProgress = ((processedCount + progress) / totalFiles).clamp(0.0, 1.0);
                  _statusText = 'جاري رفع $fileName (${(_uploadProgress * 100).toInt()}%)';
                });
              }
            },
          );

          if (!widget.isMultiple) {
            uploadedUrls.clear();
          }
          uploadedUrls.add(url);
        }
        processedCount++;
      }

      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 1.0;
          _statusText = 'تم الرفع بنجاح';
        });
      }

      widget.onImagesUpdated(uploadedUrls);
    } catch (e) {
      debugPrint("Error picking/uploading images: $e");
      if (mounted) {
        setState(() {
          _isUploading = false;
          _statusText = 'حدث خطأ أثناء الرفع';
        });
      }
    }
  }

  void _removeImage(int index) {
    final updatedList = List<String>.from(widget.currentImageUrls);
    updatedList.removeAt(index);
    widget.onImagesUpdated(updatedList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (widget.currentImageUrls.isNotEmpty)
              Text(
                '${widget.currentImageUrls.length} صور مضافة',
                style: const TextStyle(fontSize: 12, color: AppColors.olive),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Image Preview Grid + Upload Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lines),
          ),
          child: Column(
            children: [
              if (widget.currentImageUrls.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.currentImageUrls.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              width: 85,
                              height: 85,
                              color: AppColors.lines,
                              child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),

              if (widget.currentImageUrls.isNotEmpty) const SizedBox(height: 12),

              // Upload Action Button
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadImages,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                      )
                    : const Icon(Icons.cloud_upload_outlined, color: AppColors.ink),
                label: Text(
                  _isUploading ? _statusText : 'اختيار صورة من الجهاز',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              if (_isUploading) ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: AppColors.lines,
                  color: AppColors.olive,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
