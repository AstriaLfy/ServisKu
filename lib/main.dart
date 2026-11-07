import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:servis_ku/app/config/router.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/features/auth/bloc/auth_bloc.dart';
import 'package:servis_ku/features/auth/data/auth_repository.dart';
import 'package:servis_ku/features/auth/domain/user_role.dart';
import 'package:servis_ku/ui/features/customer/address/bloc/address_cubit.dart';
import 'package:servis_ku/ui/features/customer/home/bloc/customer_home_cubit.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_cubit.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_cubit.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/cart_cubit.dart';
import 'package:servis_ku/ui/features/provider/homepage/bloc/home_cubit.dart';
import 'package:servis_ku/ui/features/provider/homepage/data/home_repository.dart';
import 'package:servis_ku/ui/features/provider/order/bloc/order_cubit.dart';
import 'package:servis_ku/ui/features/provider/order/data/order_repository.dart';
import 'package:servis_ku/ui/features/provider/profile/bloc/shop_profile_bloc.dart';
import 'package:servis_ku/ui/features/provider/profile/data/shop_profile_repository.dart';
import 'package:servis_ku/ui/features/provider/report/bloc/report_cubit.dart';
import 'package:servis_ku/ui/features/provider/services/bloc/services_bloc.dart';
import 'package:servis_ku/ui/features/provider/services/data/services_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale bahasa Indonesia untuk format tanggal
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Supabase dari environment (--dart-define-from-file=.env)
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: AuthRepository())
                ..add(const AuthCheckRequested()),
        ),
        BlocProvider<HomeCubit>(
          create: (context) =>
              HomeCubit(homeRepository: SupabaseHomeRepository()),
        ),
        BlocProvider<ShopProfileBloc>(
          create: (context) => ShopProfileBloc(
            repository: ShopProfileRepository(),
            authBloc: context.read<AuthBloc>(),
          ),
        ),
        BlocProvider<ServicesBloc>(
          create: (context) => ServicesBloc(repository: ServicesRepository()),
        ),
        BlocProvider<OrderCubit>(
          create: (context) =>
              OrderCubit(orderRepository: SupabaseOrderRepository()),
        ),
        BlocProvider<ReportCubit>(create: (context) => ReportCubit()),
        BlocProvider<CustomerHomeCubit>(
          create: (context) => CustomerHomeCubit(),
        ),
        BlocProvider<CustomerOrderCubit>(
          create: (context) => CustomerOrderCubit(),
        ),
        BlocProvider<CartCubit>(create: (context) => CartCubit()),
        BlocProvider<AddressCubit>(create: (context) => AddressCubit()),
        BlocProvider<CustomerProfileCubit>(
          create: (context) => CustomerProfileCubit(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current is AuthSuccess &&
            (previous is! AuthSuccess || previous.user.id != current.user.id),
        listener: (context, state) {
          if (state is AuthSuccess && state.user.role == UserRole.provider) {
            context.read<ShopProfileBloc>().add(const ShopProfileStarted());
            context.read<ServicesBloc>().add(const ServicesStarted());
          }
        },
        child: MaterialApp.router(
          title: 'ServisKu',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E5EE6),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
