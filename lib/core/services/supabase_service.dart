import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/core/config/app_config.dart';

class SupabaseService {
  /// Inisialisasi Supabase client dengan kredensial dari AppConfig
  static Future<void> initialize() async {
    assert(
      AppConfig.supabaseUrl.isNotEmpty,
      'SUPABASE_URL belum diset. Jalankan dengan --dart-define-from-file=.env',
    );
    assert(
      AppConfig.supabaseAnonKey.isNotEmpty,
      'SUPABASE_ANON_KEY belum diset. Jalankan dengan --dart-define-from-file=.env',
    );

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  /// Akses instance SupabaseClient
  static SupabaseClient get client => Supabase.instance.client;
}
