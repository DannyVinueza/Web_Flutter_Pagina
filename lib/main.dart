import 'package:flutter/material.dart';
import 'package:garduino_dashboard/const.dart';
import 'package:garduino_dashboard/login.dart';
import 'package:garduino_dashboard/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(GetMaterialApp(
    title: 'Garduino',
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    initialBinding: AuthBinding(),
    theme: ThemeData(
      primaryColor: MaterialColor(
        primaryColorCode,
        <int, Color>{
          50: const Color(primaryColorCode).withOpacity(0.1),
          100: const Color(primaryColorCode).withOpacity(0.2),
          200: const Color(primaryColorCode).withOpacity(0.3),
          300: const Color(primaryColorCode).withOpacity(0.4),
          400: const Color(primaryColorCode).withOpacity(0.5),
          500: const Color(primaryColorCode).withOpacity(0.6),
          600: const Color(primaryColorCode).withOpacity(0.7),
          700: const Color(primaryColorCode).withOpacity(0.8),
          800: const Color(primaryColorCode).withOpacity(0.9),
          900: const Color(primaryColorCode).withOpacity(1.0),
        },
      ),
      scaffoldBackgroundColor: const Color(0xFF171821),
      fontFamily: 'IBMPlexSans',
      brightness: Brightness.dark,
    ),
    //home: const MyApp(),
    getPages: [
      GetPage(name: '/', page: () => const MyApp()),
      GetPage(
          name: '/dashboard',
          page: () => DashBoard(),
          middlewares: [AuthMiddleware()]),
    ],
  ));
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (!authController.isAuthenticated.value) {
      return RouteSettings(name: '/');
    }
    return null; // Si el usuario está autenticado, no redirigimos
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
  }
}

class AuthController extends GetxController {
  RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    // Lógica para verificar si el usuario está autenticado con Firebase
    FirebaseAuth.instance.authStateChanges().listen((user) {
      isAuthenticated.value = user != null;
    });

    ever(isAuthenticated, handleAuthChange);

    super.onInit();
  }

  void handleAuthChange(bool loggedIn) {
    if (!loggedIn) {
      Get.offAllNamed('/');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginScreen();
  }
}
//add connection page in this code
//add UI in different page..
