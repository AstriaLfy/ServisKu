class AppConfig {
  /// Membaca konfigurasi Supabase dari environment (--dart-define atau --dart-define-from-file)
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
