import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  /// Format angka integer atau num menjadi "Rp150.000" (tanpa spasi setelah Rp sesuai UI)
  static String format(num amount) {
    return _formatter.format(amount).replaceAll(' ', '');
  }

  /// Format angka ribuan dengan titik saat mengetik, misal 150000 -> 150.000
  static String formatDigits(String digits) {
    final clean = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return '';
    final val = int.tryParse(clean);
    if (val == null) return clean;
    final dotFormat = NumberFormat('#,###', 'id_ID');
    return dotFormat.format(val);
  }

  /// Parse string berformat ribuan (contoh: "150.000" atau "Rp150.000") menjadi integer murni
  static int parseClean(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }
}
