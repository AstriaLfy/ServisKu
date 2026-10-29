import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/app/config/router.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/features/auth/bloc/auth_bloc.dart';
import 'package:servis_ku/features/auth/data/auth_repository.dart';

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
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        authRepository: AuthRepository(),
      )..add(const AuthCheckRequested()),
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
