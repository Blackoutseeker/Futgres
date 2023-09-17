import 'package:flutter/material.dart';

import 'package:futgres/controllers/services/authentication.dart';

import 'package:futgres/models/routes/routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final Authentication _authentication = Authentication.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;

  void _changePasswordVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  Future<void> _navigateToSignUpScreen(BuildContext context) async {
    await Navigator.of(context).pushReplacementNamed(Routes.signup);
  }

  Future<void> _signIn(BuildContext context) async {
    await _authentication.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
      context: context,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFF0FA854),
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'images/logotype.png',
                      width: 200,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: const Color(0xFFFFFFFF),
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'E-mail',
                      hintStyle: TextStyle(
                        color: Color(0xFF000000),
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF000000),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF000000),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    cursorColor: const Color(0xFFFFFFFF),
                    obscureText: _hidePassword,
                    onEditingComplete: () => _signIn(context),
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      hintStyle: const TextStyle(
                        color: Color(0xFF000000),
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF000000),
                          width: 2,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF000000),
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        highlightColor: Colors.transparent,
                        onPressed: _changePasswordVisibility,
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF000000),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _authentication.resetPassword(
                      _emailController.text,
                      context,
                    ),
                    child: const Text(
                      'Esqueceu sua senha?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _signIn(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000000),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _authentication.signInWithGoogle(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB4437),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      'Entrar com Google',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => _navigateToSignUpScreen(context),
                      child: const Text(
                        'Não possui uma conta? Faça agora!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
