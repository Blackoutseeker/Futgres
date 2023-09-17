import 'package:flutter/material.dart';
import 'package:futgres/models/database/user.dart';
import 'package:intl/intl.dart';

import 'package:futgres/controllers/services/authentication.dart';

import 'package:futgres/models/routes/routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final Authentication _authentication = Authentication.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  bool _isOrganizer = false;
  bool _hidePassword = true;
  bool _acceptedPrivacyPolicy = false;

  void _changePasswordVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  void _changePrivacyPolicyState() {
    setState(() {
      _acceptedPrivacyPolicy = !_acceptedPrivacyPolicy;
    });
  }

  Future<void> _navigateToSignInScreen(BuildContext context) async {
    await Navigator.of(context).pushReplacementNamed(Routes.signin);
  }

  Future<void> _handleSignUp(BuildContext context) async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;
    String birthDate = _birthDateController.text;

    bool isFormValid = _acceptedPrivacyPolicy &&
        email.isNotEmpty &&
        password.length >= 6 &&
        name.isNotEmpty &&
        birthDate.isNotEmpty;

    if (isFormValid) {
      UserModel userModel = UserModel(
        email: email,
        name: name,
        birthDate: birthDate,
        isOrganizer: _isOrganizer,
      );

      await _authentication.signUp(
        email: email,
        password: password,
        userModel: userModel,
        context: context,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _birthDateController.dispose();
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
                children: <Widget>[
                  const Text(
                    'Você quer ser um...',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    onTap: () {
                      setState(() {
                        _isOrganizer = false;
                      });
                    },
                    tileColor: const Color(0xFF000000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: const BorderSide(
                        color: Color(0xFF000000),
                        width: 1,
                      ),
                    ),
                    leading: Radio(
                      value: false,
                      groupValue: _isOrganizer,
                      onChanged: (_) {
                        setState(() {
                          _isOrganizer = false;
                        });
                      },
                      activeColor: const Color(0xFFFFFFFF),
                    ),
                    title: const Text(
                      'Jogador',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    onTap: () {
                      setState(() {
                        _isOrganizer = true;
                      });
                    },
                    tileColor: const Color(0xFF000000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: const BorderSide(
                        color: Color(0xFF000000),
                        width: 1,
                      ),
                    ),
                    leading: Radio(
                      value: true,
                      groupValue: _isOrganizer,
                      onChanged: (_) {
                        setState(() {
                          _isOrganizer = true;
                        });
                      },
                      activeColor: const Color(0xFFFFFFFF),
                    ),
                    title: const Text(
                      'Organizador',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: const Color(0xFFFFFFFF),
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: TextStyle(
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
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      hintText: '6 ou mais caracteres',
                      labelStyle: const TextStyle(
                        color: Color(0xFF000000),
                      ),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    cursorColor: const Color(0xFFFFFFFF),
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      labelStyle: TextStyle(
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
                    controller: _birthDateController,
                    readOnly: true,
                    onTap: () => showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime(2077),
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          _birthDateController.text =
                              DateFormat('dd/MM/yyyy').format(date);
                        });
                      }
                    }),
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      labelStyle: TextStyle(
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
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        color: Color(0xFF000000),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    onTap: _changePrivacyPolicyState,
                    title: const Text(
                      'Li e aceito a Política De Privacidade.',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    leading: Radio(
                      value: true,
                      groupValue: _acceptedPrivacyPolicy,
                      onChanged: (_) => _changePasswordVisibility,
                      activeColor: const Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _handleSignUp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000000),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      'Cadastrar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToSignInScreen(context),
                    child: const Text(
                      'Já possui uma conta? Então entre!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
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
