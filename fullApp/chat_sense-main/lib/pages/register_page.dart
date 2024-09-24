import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  //emailand password text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  //tap to go to register page
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  //register method
  void register(BuildContext context) {
    //get auth service
    final _auth = AuthService();

    //passwords match then create a user
    if (_passController.text == _confirmPassController.text) {
      try {
        _auth.signUpWithEmailPassword(
          _emailController.text,
          _passController.text,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    }
    //passwords don't match then print fix the error
    else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords don't match!"),
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
                "Let's create an account for you!",
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

              const SizedBox(height: 10),

              //confirm password textfield
              MyTextField(
                hintText: "Confirm password",
                obscureText: true,
                controller: _confirmPassController,
              ),

              const SizedBox(height: 25),

              //Register burron
              MyButton(
                text: "Register",
                onTap: () => register(context),
              ),

              const SizedBox(height: 25),

              //login now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Login now",
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
