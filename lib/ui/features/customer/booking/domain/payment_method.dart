import 'package:flutter/material.dart';

enum PaymentMethod {
  transferBank('Transfer Bank', Icons.account_balance_outlined),
  qris('QRIS', Icons.qr_code_2_rounded),
  eWallet('E-Wallet', Icons.account_balance_wallet_outlined),
  cash('Tunai', Icons.payments_outlined);

  final String label;
  final IconData icon;

  const PaymentMethod(this.label, this.icon);
}
