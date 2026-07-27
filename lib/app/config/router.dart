import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/widgets/navbar.dart';
import 'package:servis_ku/ui/features/auth/views/login_view.dart';
import 'package:servis_ku/ui/features/auth/views/register_view.dart';
import 'package:servis_ku/ui/features/provider/homepage/views/beranda_view.dart';
import 'package:servis_ku/ui/features/provider/profile/views/account_view.dart';
import 'package:servis_ku/ui/features/provider/profile/views/profile_view.dart';
import 'package:servis_ku/ui/features/provider/report/views/report_details_view.dart';
import 'package:servis_ku/ui/features/provider/report/views/report_result_view.dart';
import 'package:servis_ku/ui/features/provider/report/views/report_view.dart';

class MainShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Navbar(
        currentIndex: navigationShell.currentIndex,
        items: Navbar.providerItems,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class OrderPlaceholderView extends StatelessWidget {
  const OrderPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Halaman Order',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/provider/beranda',
              builder: (context, state) => const BerandaView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/provider/order',
              builder: (context, state) => const OrderPlaceholderView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/provider/report',
              builder: (context, state) => const ReportView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/provider/profile',
              builder: (context, state) => const ProfileView(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/provider/account',
      builder: (context, state) => const AccountView(),
    ),
    GoRoute(
      path: '/provider/report/details',
      builder: (context, state) => const ReportDetailsView(),
    ),
    GoRoute(
      path: '/provider/report/result',
      builder: (context, state) => const ReportResultView(),
    ),
  ],
);
