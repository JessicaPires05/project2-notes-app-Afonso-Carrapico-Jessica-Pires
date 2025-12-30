import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'providers/settings_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProxyProvider<AuthProvider, DataProvider>(
          create: (_) => DataProvider(),
          update: (_, auth, data) => data!..setUser(auth.user),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (!settings.loaded) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Notas',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: settings.seedColor,
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: settings.seedColor,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
            home: Consumer<AuthProvider>(
              builder: (_, auth, __) {
                return StreamBuilder(
                  stream: auth.authStateChanges,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snap.hasData) return const HomeScreen();
                    return const LoginScreen();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
