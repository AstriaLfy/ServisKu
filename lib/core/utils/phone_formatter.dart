class PhoneFormatter {
  /// Melakukan normalisasi nomor telepon ke format E.164 Indonesia (+628...).
  /// Mengembalikan [null] jika format nomor tidak valid (hanya angka, panjang 9-13 digit setelah +62).
  static String? format(String input) {
    // Hilangkan spasi, strip (termasuk en-dash dan em-dash), dan kurung
    var clean = input.replaceAll(RegExp(r'[\s\-\–\—\−\(\)]'), '');

    if (clean.isEmpty) return null;

    // Normalisasi awalan nomor ke format +62
    if (clean.startsWith('+62')) {
      // Tetap +62
    } else if (clean.startsWith('62')) {
      clean = '+$clean';
    } else if (clean.startsWith('0')) {
      clean = '+62${clean.substring(1)}';
    } else if (clean.startsWith('8')) {
      // Menangani input langsung angka 8 (biasanya jika prefix +62 terpisah di UI)
      clean = '+62$clean';
    } else {
      return null;
    }

    // Ambil bagian nomor setelah +62
    final digitsAfterPrefix = clean.substring(3);

    // Validasi: hanya digit angka
    if (!RegExp(r'^\d+$').hasMatch(digitsAfterPrefix)) {
      return null;
    }

    // Validasi panjang wajar: nomor ponsel Indonesia memiliki 9-13 digit setelah kode negara (+62)
    if (digitsAfterPrefix.length < 9 || digitsAfterPrefix.length > 13) {
      return null;
    }

    return clean;
  }
}
