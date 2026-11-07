class PriceLine {
  final String label;
  final int amount;

  const PriceLine(this.label, this.amount);
}

class BookingPricing {
  BookingPricing._();

  static const int serviceFee = 1500;

  static int subtotal(List<PriceLine> lines) =>
      lines.fold<int>(0, (sum, line) => sum + line.amount);

  static int total(int subtotal) => subtotal + serviceFee;
}
