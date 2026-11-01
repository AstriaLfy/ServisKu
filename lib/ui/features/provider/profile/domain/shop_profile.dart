import 'package:equatable/equatable.dart';

enum VerificationStatus {
  pending,
  verified,
  rejected;

  static VerificationStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'pending':
      default:
        return VerificationStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case VerificationStatus.verified:
        return 'Terverifikasi';
      case VerificationStatus.rejected:
        return 'Ditolak';
      case VerificationStatus.pending:
        return 'Menunggu Verifikasi';
    }
  }
}

class OperatingHour extends Equatable {
  final int dayOfWeek; // 1 = Senin, ..., 7 = Minggu
  final String? openTime; // "08:00:00" or "08:00"
  final String? closeTime; // "17:00:00" or "17:00"
  final bool isClosed;

  const OperatingHour({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.isClosed,
  });

  factory OperatingHour.fromMap(Map<String, dynamic> map) {
    return OperatingHour(
      dayOfWeek: map['day_of_week'] as int,
      openTime: map['open_time'] as String?,
      closeTime: map['close_time'] as String?,
      isClosed: map['is_closed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day_of_week': dayOfWeek,
      'open_time': openTime,
      'close_time': closeTime,
      'is_closed': isClosed,
    };
  }

  OperatingHour copyWith({
    int? dayOfWeek,
    String? openTime,
    String? closeTime,
    bool? isClosed,
  }) {
    return OperatingHour(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  static String dayName(int day) {
    switch (day) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return 'Hari $day';
    }
  }

  @override
  List<Object?> get props => [dayOfWeek, openTime, closeTime, isClosed];
}

class ShopProfile extends Equatable {
  final String id;
  final String name;
  final String? tagline;
  final String? photoUrl;
  final String? serviceArea;
  final VerificationStatus verificationStatus;
  final List<OperatingHour> hours;

  const ShopProfile({
    required this.id,
    required this.name,
    this.tagline,
    this.photoUrl,
    this.serviceArea,
    required this.verificationStatus,
    required this.hours,
  });

  factory ShopProfile.fromMap(
    Map<String, dynamic> map, {
    String? photoUrl,
    List<OperatingHour>? hours,
  }) {
    return ShopProfile(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      tagline: map['tagline'] as String?,
      photoUrl: photoUrl,
      serviceArea: map['service_area'] as String?,
      verificationStatus: VerificationStatus.fromString(
        map['verification_status'] as String?,
      ),
      hours: hours ?? const [],
    );
  }

  ShopProfile copyWith({
    String? id,
    String? name,
    String? tagline,
    String? photoUrl,
    String? serviceArea,
    VerificationStatus? verificationStatus,
    List<OperatingHour>? hours,
  }) {
    return ShopProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      photoUrl: photoUrl ?? this.photoUrl,
      serviceArea: serviceArea ?? this.serviceArea,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      hours: hours ?? this.hours,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        tagline,
        photoUrl,
        serviceArea,
        verificationStatus,
        hours,
      ];
}
