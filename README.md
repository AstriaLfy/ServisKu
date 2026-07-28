# 🛠️ ServisKu

**ServisKu** adalah aplikasi mobile berbasis **Flutter** yang menghubungkan pencari jasa dengan mitra penyedia jasa profesional secara aman, cepat, dan terpercaya. Aplikasi ini mendukung fitur multi-peran (*Pemilik Jasa / Mitra* & *Pengguna Jasa / Customer*) dengan desain antarmuka (*UI/UX*) modern, responsif, dan intuitif.

---

## 🌟 Fitur Utama

### 📱 1. Splash Screen & Onboarding
- **Animated Splash Screen**: Animasi splash berdurasi interaktif berbasis Lottie.
- **Multi-Slide Onboarding**: Panduan pengguna interaktif dengan *Step Progress Bar* dan tombol *Skip*.
- **Welcome Page**: Pintu masuk awal ke alur *Log In* atau *Register*.

### 🔑 2. Alur Otentikasi Lengkap (Auth Flow)
- **Log In Screen**: Masuk dengan nomor telepon dan kata sandi.
- **Multi-Step Registration**:
  1. **Register Form**: Input Nomor Telepon, Password, & Konfirmasi Password dengan validasi *real-time*.
  2. **Konfirmasi OTP**: Input 6-digit OTP dengan fitur *auto-focus*, countdown timer 60 detik, dan kirim ulang kode.
  3. **Input Nama (`Kenalan dulu yuk!`)**: Form nama lengkap pengguna.
  4. **Pilih Peran (`Peran kamu?`)**: Pemilihan peran interaktif (*Pemilik Jasa* atau *Pengguna Jasa*).
  5. **All Set (`Sudah siap!`)**: Konfirmasi pendaftaran berhasil.

### 💼 3. Dashboard Provider / Mitra Professional
- **Beranda (Homepage)**:
  - Toggle Status **Online / Offline** secara *real-time*.
  - Ringkasan statistik harian (Pendapatan, Jumlah Order, Rating).
  - Daftar **Order Masuk** interaktif (Terima / Tolak order, estimasi jarak, harga, dan waktu).
- **Manajemen Order (`Order`)**:
  - Filter status pesanan (*Masuk*, *Diproses*, *Selesai*).
  - Rincian detail pesanan pelanggan.
- **Laporan Finansial (`Laporan`)**:
  - Ringkasan transaksi, detail laporan, dan cetak hasil laporan.
- **Manajemen Toko & Layanan (`Toko & Profil`)**:
  - Profil Toko Terverifikasi.
  - Pengaturan Area Layanan & Jam Operasional.
  - Manajemen Tambah/Edit Layanan Jasa.

---

## 🛠️ Teknologi & Libary yang Digunakan

- **Framework**: [Flutter](https://flutter.dev) (SDK ^3.12.2)
- **Language**: [Dart](https://dart.dev)
- **State & Navigation**:
  - `go_router`: Navigasi berbasis deklaratif & URL path.
  - `flutter_bloc` & `equatable`: State management scalable.
- **UI Component & Design System**:
  - `animated_splash_screen`: Transisi splash screen.
  - `lottie`: Animasi vektor interaktif.
  - `flutter_svg`: Rendering grafis berbasis SVG.
  - Custom Design Tokens: `AppColors`, `CustomButton`, `CustomTextField`, `StepProgressBar`, `Navbar`.

---

## 📂 Struktur Proyek

```text
servis_ku/
├── assets/
│   ├── images/       # Aset ilustrasi (provider.png, user.png, texture.png, dll)
│   ├── icons/        # Aset ikon visual
│   └── videos/       # Aset animasi Lottie (splashscreen.json)
├── lib/
│   ├── main.dart     # Entry point aplikasi
│   ├── app/
│   │   └── config/   # Konfigurasi rute (router.dart)
│   ├── core/
│   │   ├── theme/    # Color palette (app_colors.dart)
│   │   └── widgets/  # Reusable UI Components (CustomButton, CustomTextField, Navbar, StepProgressBar)
│   └── ui/
│       └── features/
│           ├── splash/       # Animated Splash Screen
│           ├── onboarding/   # Slide Onboarding & Data
│           ├── auth/         # Login, Register, OTP, Name, Role, & All Set Views
│           └── provider/     # Feature modules (Homepage, Order, Report, Profile, Services)
└── pubspec.yaml      # Dependencies & Asset configuration
```

---

## 🚀 Cara Menjalankan Aplikasi secara Lokal

### Prasyarat:
- Flutter SDK telah terinstal (versi `>=3.12.2`)
- Android Studio / VS Code dengan plugin Flutter
- Device Emulator (Android/iOS) atau HP fisik yang terhubung

### Langkah-langkah:

1. **Clone Repositori**:
   ```bash
   git clone https://github.com/AstriaLfy/ServisKu.git
   cd servis_ku
   ```

2. **Install Dependensi**:
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

4. **Verifikasi Kode (Analisis Linter)**:
   ```bash
   flutter analyze
   ```

---

## 👥 Kontributor

Dikembangkan untuk aplikasi **ServisKu** dengan arsitektur bersih, desain presisi, dan performa tinggi.
