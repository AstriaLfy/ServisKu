import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/app/config/router.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/features/auth/bloc/auth_bloc.dart';
import 'package:servis_ku/features/auth/data/auth_repository.dart';
import 'package:servis_ku/ui/features/provider/profile/bloc/shop_profile_bloc.dart';
import 'package:servis_ku/ui/features/provider/profile/data/shop_profile_repository.dart';
import 'package:servis_ku/ui/features/provider/services/bloc/services_bloc.dart';
import 'package:servis_ku/ui/features/provider/services/data/services_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          create: (context) => AuthBloc(
            authRepository: AuthRepository(),
          )..add(const AuthCheckRequested()),
        ),
        BlocProvider<ShopProfileBloc>(
          create: (context) => ShopProfileBloc(
            repository: ShopProfileRepository(),
            authBloc: context.read<AuthBloc>(),
          )..add(const ShopProfileStarted()),
        ),
        BlocProvider<ServicesBloc>(
          create: (context) => ServicesBloc(
            repository: ServicesRepository(),
          )..add(const ServicesStarted()),
        ),
      ],
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
    );
  }
}
