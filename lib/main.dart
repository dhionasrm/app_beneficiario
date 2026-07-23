import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'screens/carteirinha/carteirinha_detail_screen.dart';
import 'screens/carteirinha/carteirinha_list_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/menu/menu_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UnipoaApp());
}

class UnipoaApp extends StatelessWidget {
  const UnipoaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unipoa Beneficiários',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      // Users who bumped up system font size rely on it working everywhere;
      // clamping only guards against truly extreme values breaking layout.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 2.0,
            ),
          ),
          child: child!,
        );
      },
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.menu: (context) => const MenuScreen(),
        AppRoutes.carteirinhaList: (context) => const CarteirinhaListScreen(),
        AppRoutes.carteirinhaDetail: (context) =>
            const CarteirinhaDetailScreen(),
      },
    );
  }
}
