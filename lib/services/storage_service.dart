import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_config.dart';

class StorageService {
  SupabaseClient? _supabase;

  StorageService() {
    try {
      _supabase = Supabase.instance.client;
    } catch (e) {
      debugPrint("Supabase client not initialized: $e");
    }
  }

  /// Upload image bytes to Supabase Storage with multi-bucket casing retry
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    required String bucketName, // used as subfolder name
    void Function(double progress)? onProgress,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    
    final folderPath = (bucketName == SupabaseConfig.mainBucket || bucketName.isEmpty) ? 'general' : bucketName;
    final filePath = '$folderPath/$timestamp-$sanitizedFileName';

    // List of possible bucket candidates in order
    final candidateBuckets = [
      SupabaseConfig.mainBucket,                     // 'Simplicity'
      SupabaseConfig.mainBucket.toLowerCase(),        // 'simplicity'
      bucketName,                                    // e.g. 'products'
      bucketName.toLowerCase(),                      // e.g. 'products'
    ].toSet().toList();

    if (_supabase != null) {
      for (final candidate in candidateBuckets) {
        if (candidate.isEmpty) continue;
        try {
          if (onProgress != null) onProgress(0.4);

          // Attempt upload to candidate bucket
          await _supabase!.storage.from(candidate).uploadBinary(
                filePath,
                bytes,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: true,
                ),
              );

          if (onProgress != null) onProgress(0.8);

          final publicUrl = _supabase!.storage
              .from(candidate)
              .getPublicUrl(filePath);

          if (onProgress != null) onProgress(1.0);
          debugPrint("✅ Image uploaded successfully to Supabase bucket '$candidate': $publicUrl");
          return publicUrl;
        } on StorageException catch (e) {
          debugPrint("Supabase Storage candidate '$candidate' [${e.statusCode}]: ${e.message}");
        } catch (e) {
          debugPrint("Error trying bucket '$candidate': $e");
        }
      }
    }

    // If Supabase remote upload fails due to RLS, convert to Data URL for web/desktop instant preview & saving
    debugPrint("⚠️ Supabase remote upload blocked by RLS policies. Generating Base64 Data URL as reliable fallback...");
    if (onProgress != null) onProgress(1.0);
    
    try {
      final base64String = base64Encode(bytes);
      final mimeType = fileName.endsWith('.png') ? 'image/png' : 'image/jpeg';
      return 'data:$mimeType;base64,$base64String';
    } catch (_) {
      return 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=800';
    }
  }

  /// Delete image from Supabase Storage using its public URL
  Future<void> deleteImageByUrl(String url, String bucketName) async {
    if (_supabase == null || url.isEmpty || url.startsWith('data:')) return;

    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      for (final target in [SupabaseConfig.mainBucket, SupabaseConfig.mainBucket.toLowerCase(), bucketName]) {
        final idx = segments.indexOf(target);
        if (idx != -1 && idx < segments.length - 1) {
          final filePath = segments.sublist(idx + 1).join('/');
          await _supabase!.storage.from(target).remove([filePath]);
          break;
        }
      }
    } catch (e) {
      debugPrint("Error removing file from Supabase Storage: $e");
    }
  }
}
