import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/widgets/navbar.dart';
import 'package:servis_ku/ui/features/auth/views/login_view.dart';
import 'package:servis_ku/ui/features/auth/views/register_view.dart';
import 'package:servis_ku/ui/features/customer/address/domain/customer_address.dart';
import 'package:servis_ku/ui/features/customer/address/views/address_form_view.dart';
import 'package:servis_ku/ui/features/customer/address/views/address_list_view.dart';
import 'package:servis_ku/ui/features/customer/booking/bloc/booking_cubit.dart';
import 'package:servis_ku/ui/features/customer/booking/views/order_confirmation_view.dart';
import 'package:servis_ku/ui/features/customer/home/views/customer_home_view.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_detail_cubit.dart';
import 'package:servis_ku/ui/features/customer/order/views/customer_order_detail_view.dart';
import 'package:servis_ku/ui/features/customer/order/views/order_history_view.dart';
import 'package:servis_ku/ui/features/customer/order/views/order_review_view.dart';
import 'package:servis_ku/ui/features/customer/profile/domain/customer_profile.dart';
import 'package:servis_ku/ui/features/customer/profile/views/change_password_view.dart';
import 'package:servis_ku/ui/features/customer/profile/views/customer_profile_view.dart';
import 'package:servis_ku/ui/features/customer/profile/views/edit_profile_field_view.dart';
import 'package:servis_ku/ui/features/customer/profile/views/edit_profile_view.dart';
import 'package:servis_ku/ui/features/customer/profile/views/phone_verification_view.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/shop_detail_cubit.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_summary.dart';
import 'package:servis_ku/ui/features/customer/shop/views/shop_detail_view.dart';
import 'package:servis_ku/ui/features/customer/shop/views/shop_review_view.dart';
import 'package:servis_ku/ui/features/onboarding/onboarding_page.dart';
import 'package:servis_ku/ui/features/provider/homepage/views/beranda_view.dart';
import 'package:servis_ku/ui/features/provider/order/views/order_view.dart';
import 'package:servis_ku/ui/features/provider/profile/views/account_view.dart';
import 'package:servis_ku/ui/features/provider/profile/views/profile_view.dart';
import 'package:servis_ku/ui/features/provider/report/domain/report_models.dart';
import 'package:servis_ku/ui/features/provider/report/views/report_details_view.dart';
import 'package:servis_ku/ui/features/provider/report/views/report_result_view.dart';
import 'package:servis_ku/ui/features/provider/report/views/report_view.dart';
import 'package:servis_ku/ui/features/provider/services/domain/service_item.dart';
import 'package:servis_ku/ui/features/provider/services/views/service_add_view.dart';
import 'package:servis_ku/ui/features/provider/services/views/service_detail_view.dart';
import 'package:servis_ku/ui/features/provider/services/views/service_view.dart';
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

class CustomerShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomerShellScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Navbar(
        currentIndex: navigationShell.currentIndex,
        items: Navbar.customerItems,
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
        return CustomerShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customer/home',
              builder: (context, state) => const CustomerHomeView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customer/riwayat',
              builder: (context, state) => const OrderHistoryView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customer/akun',
              builder: (context, state) => const CustomerProfileView(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/customer/shop/:id/reviews',
      builder: (context, state) {
        final shopId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => ShopDetailCubit(
            shopId: shopId,
            initialShop: state.extra as ShopSummary?,
          )..load(),
          child: const ShopReviewView(),
        );
      },
    ),
    GoRoute(
      path: '/customer/shop/:id',
      builder: (context, state) {
        final shopId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => ShopDetailCubit(
            shopId: shopId,
            initialShop: state.extra as ShopSummary?,
          )..load(),
          child: const ShopDetailView(),
        );
      },
    ),
    GoRoute(
      path: '/customer/checkout',
      builder: (context, state) => BlocProvider(
        create: (_) => BookingCubit(),
        child: const OrderConfirmationView(),
      ),
    ),
    GoRoute(
      path: '/customer/order/:id/review',
      builder: (context, state) {
        final cubit = state.extra as CustomerOrderDetailCubit?;
        if (cubit != null) {
          return BlocProvider.value(value: cubit, child: const OrderReviewView());
        }
        return BlocProvider(
          create: (_) => CustomerOrderDetailCubit(
            orderId: state.pathParameters['id']!,
          )..load(),
          child: const OrderReviewView(),
        );
      },
    ),
    GoRoute(
      path: '/customer/order/:id',
      builder: (context, state) => BlocProvider(
        create: (_) => CustomerOrderDetailCubit(
          orderId: state.pathParameters['id']!,
        )..load(),
        child: const CustomerOrderDetailView(),
      ),
    ),
    GoRoute(
      path: '/customer/address/form',
      builder: (context, state) => AddressFormView(
        address: state.extra as CustomerAddress?,
      ),
    ),
    GoRoute(
      path: '/customer/address',
      builder: (context, state) => const AddressListView(),
    ),
    GoRoute(
      path: '/customer/profile/edit/:field',
      builder: (context, state) => EditProfileFieldView(
        field: ProfileField.fromPath(state.pathParameters['field']),
      ),
    ),
    GoRoute(
      path: '/customer/profile/edit',
      builder: (context, state) => const EditProfileView(),
    ),
    GoRoute(
      path: '/customer/profile/verify-phone',
      builder: (context, state) => PhoneVerificationView(
        phone: state.extra as String? ?? '',
      ),
    ),
    GoRoute(
      path: '/customer/profile/password',
      builder: (context, state) => const ChangePasswordView(),
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
      builder: (context, state) => ReportResultView(
        withdrawal: state.extra as Withdrawal?,
      ),
    ),
    GoRoute(
      path: '/provider/services',
      builder: (context, state) => const ServiceView(),
    ),
    GoRoute(
      path: '/provider/services/detail',
      builder: (context, state) {
        final item = state.extra as ServiceItem?;
        return ServiceDetailView(service: item);
      },
    ),
    GoRoute(
      path: '/provider/services/add',
      builder: (context, state) {
        final item = state.extra as ServiceItem?;
        return ServiceAddView(editItem: item);
      },
    ),
  ],
);
