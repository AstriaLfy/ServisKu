import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/widgets/navbar.dart';
import 'package:servis_ku/ui/features/auth/views/login_view.dart';
import 'package:servis_ku/ui/features/auth/views/register_view.dart';
import 'package:servis_ku/ui/features/onboarding/onboarding_page.dart';
import 'package:servis_ku/ui/features/provider/homepage/views/beranda_view.dart';
import 'package:servis_ku/ui/features/provider/order/views/order_view.dart';
import 'package:servis_ku/ui/features/provider/profile/views/account_view.dart';
import 'package:servis_ku/ui/features/provider/profile/views/profile_view.dart';
import 'package:servis_ku/ui/features/provider/report/views/report_details_view.dart';
import 'package:servis_ku/ui/features/provider/report/views/report_result_view.dart';
import 'package:servis_ku/ui/features/provider/report/views/report_view.dart';
import 'package:servis_ku/ui/features/splash/splash_screen.dart';

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

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const AnimatedSplashScreenWidget(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
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
              builder: (context, state) => const OrderView(),
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
