class OnboardingData {
  final String image;
  final String title;
  final String description;

  const OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

const List<OnboardingData> onboardingItems = [
  OnboardingData(
    image: 'assets/images/operator.png',
    title: 'Temukan Jasa\nTerpercaya',
    description:
    'Bisa cari penyedia jasa terpercaya atau ganti mode jadi mitra buat cari penghasilan tambahan kapan saja.',
  ),
  OnboardingData(
    image: 'assets/images/savetransaction.png',
    title: 'Transaksi Aman!',
    description:
    'Bisa cari penyedia jasa terpercaya atau ganti mode jadi mitra buat cari penghasilan tambahan kapan saja.',
  ),
  OnboardingData(
    image: 'assets/images/roles.png',
    title: 'Ganti Peran Kapan\nSaja!',
    description:
    'Tinggal pencet satu tombol buat switch dari mode customer ke mode penyedia jasa.',
  ),
];