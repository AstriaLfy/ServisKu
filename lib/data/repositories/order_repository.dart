import 'package:servis_ku/data/models/order_model.dart';

class OrderRepository {
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const [
      OrderModel(
        id: 'ORDER-250512-0012',
        customerName: 'Bedul',
        serviceName: 'Perbaikan AC',
        timeAgo: '2 menit lalu',
        distance: '2,4 km',
        price: 'Rp 120.000',
        estimatedTime: '90 menit',
        status: OrderStatus.aktif,
        customerRating: 4.7,
        customerRatingCount: 18,
        serviceAddress: 'Jl. MT. Haryono No.45, Klojen, Malang',
        customerNote: 'AC tidak dingin, freon mungkin habis',
        statusHistory: [
          StatusHistoryItem(
            label: 'Order Dibuat',
            dateTime: '12 Mei 2025 | 08.45',
            isDone: true,
          ),
          StatusHistoryItem(
            label: 'Order Diterima',
            dateTime: '12 Mei 2025 | 09.00',
            isDone: true,
          ),
          StatusHistoryItem(
            label: 'Sedang Dikerjakan',
            dateTime: '12 Mei 2025 | 09.35',
            isDone: true,
          ),
          StatusHistoryItem(
            label: 'Order Selesai',
            dateTime: '-',
            isDone: false,
          ),
        ],
      ),
      OrderModel(
        id: 'ORDER-250512-0013',
        customerName: 'Rozanea',
        serviceName: 'Pembersihan Rumah',
        timeAgo: '2 menit lalu',
        distance: '2,4 km',
        price: 'Rp 85.000',
        estimatedTime: '90 menit',
        status: OrderStatus.baru,
        customerRating: 4.8,
        customerRatingCount: 24,
        serviceAddress: 'Jl. Soekarno Hatta No. 12, Lowokwaru, Malang',
        customerNote: 'Mohon bawa peralatan sendiri ya. Rumah 2 lantai.',
        statusHistory: [
          StatusHistoryItem(
            label: 'Order Dibuat',
            dateTime: '12 Mei 2025 | 10.24',
            isDone: true,
          ),
          StatusHistoryItem(
            label: 'Order Diterima',
            dateTime: '-',
            isDone: false,
          ),
          StatusHistoryItem(
            label: 'Sedang Dikerjakan',
            dateTime: '-',
            isDone: false,
          ),
          StatusHistoryItem(
            label: 'Order Selesai',
            dateTime: '-',
            isDone: false,
          ),
        ],
      ),
      OrderModel(
        id: 'ORDER-250512-0014',
        customerName: 'Dewi Lestari',
        serviceName: 'Cuci Sofa',
        timeAgo: '2 menit lalu',
        distance: '2,4 km',
        price: 'Rp 70.000',
        estimatedTime: '90 menit',
        status: OrderStatus.selesai,
        customerRating: 5.0,
        customerRatingCount: 15,
        serviceAddress: 'Jl. Danau Toba No.8, Sukun, Malang',
        customerNote: 'Sofa di ruang tamu',
        statusHistory: [
          StatusHistoryItem(
            label: 'Order Dibuat',
            dateTime: '12 Mei 2025 | 10.24',
            isDone: true,
          ),
          StatusHistoryItem(
            label: 'Order Diterima',
            dateTime: '12 Mei 2025 | 09.00',
            isDone: true,
          ),
          StatusHistoryItem(
            label: 'Sedang Dikerjakan',
            dateTime: '12 Mei 2025 | 09.35',
            isDone: true,
          ),
          StatusHistoryItem(
            label: 'Order Selesai',
            dateTime: '12 Mei 2025 | 11.00',
            isDone: true,
          ),
        ],
        orderRating: 5.0,
        reviewText: 'Sangat memuaskan! Pelayanan ramah dan cepat.',
      ),
      OrderModel(
        id: 'ORDER-250512-0015',
        customerName: 'Habibi',
        serviceName: 'Pemasangan Lampu',
        timeAgo: '2 menit lalu',
        distance: '2,4 km',
        price: 'Rp 35.000',
        estimatedTime: '90 menit',
        status: OrderStatus.dibatalkan,
        customerRating: 5.0,
        customerRatingCount: 9,
        serviceAddress: 'Jl. Dandung No. 77, Blimbing, Malang',
        customerNote: null,
        statusHistory: [
          StatusHistoryItem(
            label: 'Order Dibuat',
            dateTime: '10 Mei 2025 | 14.12',
            isDone: true,
          ),
          StatusHistoryItem(
            label: 'Dibatalkan',
            dateTime: '10 Mei 2025 | 14.30',
            isDone: true,
            isCancelled: true,
          ),
        ],
        cancellationReason: 'Pelanggan membatalkan order',
      ),
    ];
  }

  Future<void> acceptOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> rejectOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> completeOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
