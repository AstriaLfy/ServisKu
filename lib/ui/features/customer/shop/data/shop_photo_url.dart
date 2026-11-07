import 'package:supabase_flutter/supabase_flutter.dart';

String? resolveShopPhotoUrl(SupabaseClient client, Map<String, dynamic> row) {
  final photoPath = row['photo_path'] as String?;
  if (photoPath == null || photoPath.isEmpty) return null;
  final rawUrl = client.storage.from('shop-photos').getPublicUrl(photoPath);
  final updatedAt = row['updated_at'] != null
      ? DateTime.tryParse(row['updated_at'].toString())?.millisecondsSinceEpoch
      : null;
  return updatedAt == null ? rawUrl : '$rawUrl?v=$updatedAt';
}
