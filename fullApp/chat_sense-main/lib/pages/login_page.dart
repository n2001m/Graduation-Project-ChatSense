import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/components/my_button.dart';
import 'package:flutter_application_1/components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  //emailand password text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  //tap to go to register page
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  //login method
  void login(BuildContext context) async {
    //auth service
    final authService = AuthService();

    //try login
    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _passController.text,
      );
    }

    //catch any errors
    catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Icon(
                Icons.message,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 50),

              //welcome back message
              Text(
                "Welcome back to ChatSense!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 26,
                ),
              ),

              const SizedBox(height: 50),

              //email textfield
              MyTextField(
                hintText: "Email",
                obscureText: false,
                controller: _emailController,
              ),

              const SizedBox(height: 10),

              //password textfield
              MyTextField(
                hintText: "Password",
                obscureText: true,
                controller: _passController,
              ),

              const SizedBox(height: 25),

              //login burron
              MyButton(
                text: "Login",
                onTap: () => login(context),
              ),

              const SizedBox(height: 25),

              //register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member? ",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Register now",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
