import 'package:flutter/material.dart';
import 'package:garduino_dashboard/Responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:async';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Instancia de Firebase Auth

  Future<void> _login() async {
    try {
      if (validateEmail(emailController.text) &&
          validatePassword(passwordController.text)) {
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        if (userCredential.user != null) {
          showTimedSnackBar('Iniciado sesión satisfactoriamente');
          Get.toNamed('/dashboard');
        }
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
      showErrorMessage(e.toString());
    }
  }

  void showTimedSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);

    // Cerrar el SnackBar automáticamente después de 3 segundos
    Timer(Duration(seconds: 3), () {
      ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
    });
  }

  void showErrorMessage(String message) {
    Get.snackbar('Error', message);
  }

  bool validateEmail(String val) {
    if (val.isEmpty) {
      showErrorMessage("Email es requerido");
      return false;
    } else if (!EmailValidator.validate(val, true)) {
      showErrorMessage("El email es inválido");
      return false;
    }
    return true;
  }

  bool validatePassword(String val) {
    if (val.isEmpty) {
      showErrorMessage("Contraseña es requerida");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints:
                BoxConstraints(maxWidth: 400), // Ancho máximo del Container
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (Responsive.isDesktop(context))
                  TextField(
                    controller: emailController,
                    decoration:
                        InputDecoration(labelText: 'Correo electrónico'),
                  ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Iniciar Sesión'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 62, 82, 111),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
