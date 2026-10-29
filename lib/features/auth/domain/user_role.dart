enum UserRole {
  customer,
  provider;

  /// Konversi string role dari database ('customer' / 'provider') ke enum UserRole
  static UserRole fromString(String? role) {
    if (role == null) return UserRole.customer;
    switch (role.toLowerCase().trim()) {
      case 'provider':
        return UserRole.provider;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  String get label => this == UserRole.provider ? 'Pemilik Jasa' : 'Pengguna Jasa';
}
