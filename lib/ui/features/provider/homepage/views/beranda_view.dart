import 'package:flutter/material.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';

class BerandaView extends StatefulWidget {
  const BerandaView({super.key});

  @override
  State<BerandaView> createState() => _BerandaViewState();
}

class _BerandaViewState extends State<BerandaView> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              const Text(
                'Ringkasan Hari ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryCards(),
              const SizedBox(height: 24),

              _buildOrderMasukHeader(),
              const SizedBox(height: 12),
              if (!_isOnline) _buildEmptyOrderState() else _buildOrderList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Jason',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Mitra Profesional',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const Spacer(),

        GestureDetector(
          onTap: () {
            setState(() {
              _isOnline = !_isOnline;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOnline
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isOnline
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 8),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 20,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _isOnline
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFE5E7EB),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _isOnline
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            assetPath: 'assets/icons/wallet_icon.png',
            title: 'Pendapatan Hari ini',
            value: _isOnline ? 'Rp 320.000' : 'Rp 0',
            subtext: _isOnline ? '12% dari kemarin' : '0% dari kemarin',
            subtextIcon: Icons.trending_up,
            subtextColor: const Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 8),

        Expanded(
          child: _buildSummaryCard(
            assetPath: 'assets/images/clipboard.png',
            title: 'Jumlah Order',
            value: _isOnline ? '8' : '0',
            subtext: _isOnline ? '2 selesai' : '0 selesai',
            subtextIcon: Icons.check_circle,
            subtextColor: const Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 8),

        Expanded(
          child: _buildSummaryCard(
            assetPath: 'assets/images/rating.png',
            title: 'Rating',
            value: _isOnline ? '4.8' : '0',
            subtext: 'Sangat Baik',
            subtextIcon: Icons.star,
            subtextColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String assetPath,
    required String title,
    required String value,
    required String subtext,
    required IconData subtextIcon,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Icon(subtextIcon, size: 12, color: subtextColor),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  subtext,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: subtextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderMasukHeader() {
    return Row(
      children: [
        const Text(
          'Order Masuk',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        if (_isOnline) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '2 Baru',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
        const Spacer(),

        GestureDetector(
          onTap: () {},
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrderState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/cardbox.png',
            height: 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada order hari ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Order baru akan muncul di sini ketika ada yang membutuhkan jasa anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return Column(
      children: [
        _buildOrderCard(
          customerName: 'Rozanea',
          serviceName: 'Pembersihan Rumah',
          timeAgo: '2 menit lalu',
          distance: '2,4 km',
          price: 'Rp 85.000',
          estimatedTime: '90 menit',
        ),
        const SizedBox(height: 16),
        _buildOrderCard(
          customerName: 'Bedul',
          serviceName: 'Perbaikan AC',
          timeAgo: '3 menit lalu',
          distance: '4,1 km',
          price: 'Rp 120.000',
          estimatedTime: '120 menit',
        ),
      ],
    );
  }

  Widget _buildOrderCard({
    required String customerName,
    required String serviceName,
    required String timeAgo,
    required String distance,
    required String price,
    required String estimatedTime,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Baru',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  iconWidget: const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  value: distance,
                  label: 'Jarak',
                ),
              ),
              Expanded(
                child: _buildInfoTile(
                  iconWidget: Image.asset(
                    'assets/icons/wallet_icon.png',
                    width: 14,
                    height: 14,
                  ),
                  value: price,
                  label: 'Estimasi Harga',
                ),
              ),
              Expanded(
                child: _buildInfoTile(
                  iconWidget: const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  value: estimatedTime,
                  label: 'Estimasi Waktu',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Tolak',
                  variant: ButtonVariant.outlined,
                  height: 42,
                  borderRadius: 24,
                  onPressed: () {
                    debugPrint('Tolak order $customerName');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Terima',
                  height: 42,
                  borderRadius: 24,
                  onPressed: () {
                    debugPrint('Terima order $customerName');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required Widget iconWidget,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Center(child: iconWidget),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
