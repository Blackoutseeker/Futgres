import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:futgres/controllers/stores/user_store.dart';
import 'package:futgres/controllers/database/user.dart';

import 'package:futgres/models/storage/storaged_values.dart';
import 'package:futgres/models/routes/routes.dart';
import 'package:futgres/models/database/user.dart';

class Authentication {
  static final Authentication instance = Authentication();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserDatabase _userDatabase = UserDatabase.instance;

  Future<void> _navigateToMainScreen(BuildContext context) async {
    await Navigator.of(context).pushReplacementNamed(Routes.main);
  }

  Future<void> _navigateToSignInScreen(BuildContext context) async {
    await Navigator.of(context).pushReplacementNamed(Routes.signin);
  }

  Future<Widget> _presentDialog(
    String title,
    String content,
    BuildContext context,
  ) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <TextButton>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUserSession(
    UserModel userModel,
    BuildContext context,
  ) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final UserStore userStore = GetIt.I.get<UserStore>();

    userStore.setUser(
      uid: userModel.uid,
      email: userModel.email,
      name: userModel.name,
      birthDate: userModel.birthDate,
      isOrganizer: userModel.isOrganizer,
    );

    await preferences.setString(StoragedValues.uid, userModel.uid!);
    await preferences
        .setBool(StoragedValues.isOrganizer, userModel.isOrganizer ?? false)
        .then((_) async {
      await _navigateToMainScreen(context);
    });
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (email.isNotEmpty && password.length >= 6) {
      await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((userCredential) async {
        final user = userCredential.user;
        if (user != null) {
          final bool userNotHaveEmailVerified = !user.emailVerified;
          if (userNotHaveEmailVerified) {
            user.sendEmailVerification();
            await _presentDialog(
              'Veja sua caixa de entrada!',
              'Um e-mail lhe foi enviado para verificar sua conta.',
              context,
            );
          } else {
            UserModel? userModel =
                await _userDatabase.getUserFromDatabase(user.uid);

            if (userModel != null) {
              await _saveUserSession(userModel, context);
            }
          }
        }
      }).catchError((error) async {
        final String? errorMessage = error.message;
        if (errorMessage != null) {
          if (errorMessage.contains('badly formatted')) {
            await _presentDialog(
              'Ocorreu um erro!',
              'Seu endereço de e-mail está mal formatado.',
              context,
            );
          } else if (errorMessage.contains('is no user record')) {
            await _presentDialog(
              'Ocorreu um erro!',
              'Seu e-mail não está no nosso banco de dados, logo, você ainda não possui uma conta registrada.',
              context,
            );
          } else if (errorMessage.contains('password is invalid')) {
            await _presentDialog(
              'Ocorreu um erro!',
              'Sua senha está incorreta.',
              context,
            );
          } else if (errorMessage.contains('blocked all requests')) {
            await _presentDialog(
              'Bloqueio temporário',
              'Nós bloqueamos todas as requisições deste dispositivo por atividades suspeitas. Tente mais tarde.',
              context,
            );
          }
        }
      });
    }
  }

  Future<void> signInWithGoogle(
    BuildContext context,
  ) async {
    final googleAccount = await _googleSignIn.signIn();
    if (googleAccount == null) return;

    final googleAuthentication = await googleAccount.authentication;
    final googleAuthenticationProviderCredential =
        GoogleAuthProvider.credential(
      accessToken: googleAuthentication.accessToken,
      idToken: googleAuthentication.idToken,
    );

    await FirebaseAuth.instance
        .signInWithCredential(googleAuthenticationProviderCredential)
        .then((userCredential) async {
      final user = userCredential.user;
      if (user == null) return;

      final bool userAlreadyExists =
          await _userDatabase.checkIfUserAlreadyExists(user.uid);
      if (userAlreadyExists) {
        UserModel? userFromDatabase =
            await _userDatabase.getUserFromDatabase(user.uid);
        if (userFromDatabase != null) {
          await _saveUserSession(userFromDatabase, context);
        }
      } else {
        if (user.email != null) {
          await _presentDialog(
            'Ocorreu um erro!',
            'Você ainda não possui uma conta. Faça seu cadastro e garanta seu lugar no nosso aplicativo!',
            context,
          );
        }
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required UserModel userModel,
    required BuildContext context,
  }) async {
    if (email.isNotEmpty && password.length >= 6) {
      await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userCredential) async {
        final User? user = userCredential.user;
        if (user != null) {
          String? uid = user.uid;
          UserModel userToDatabase = UserModel(
            uid: uid,
            email: userModel.email,
            name: userModel.name,
            birthDate: userModel.birthDate,
            isOrganizer: userModel.isOrganizer,
          );
          await _userDatabase.createUserInDatabase(userToDatabase);
          await user.sendEmailVerification();
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Veja sua caixa de entrada!'),
              content: const Text(
                'Um e-mail lhe foi enviado para verificar sua conta.',
              ),
              actions: <TextButton>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () async => await _navigateToSignInScreen(context),
                ),
              ],
            ),
          );
        }
      }).catchError((error) async {
        final String? errorMessage = error.message;
        if (errorMessage != null) {
          if (errorMessage.contains('badly formatted')) {
            await _presentDialog(
              'Ocorreu um erro!',
              'Seu endereço de e-mail está mal formatado.',
              context,
            );
          } else if (errorMessage.contains('is already in use')) {
            await _presentDialog(
              'Ocorreu um erro!',
              'O endereço de e-mail fornecido já se encontra em uso por outra conta.',
              context,
            );
          }
        } else {
          await _presentDialog(
            'Ocorreu um erro!',
            'Houve algum problema ao tentar criar sua conta. Verifique se seu e-mail está correto, e tente novamente.',
            context,
          );
        }
      });
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
    await _firebaseAuth.signOut();

    final UserStore userStore = GetIt.I.get<UserStore>();
    userStore.setUser(
      uid: null,
      email: null,
      name: null,
      birthDate: null,
    );

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.clear();
    await Navigator.of(context).pushReplacementNamed(Routes.initial);
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    if (email.isNotEmpty) {
      await _firebaseAuth.sendPasswordResetEmail(email: email).then((_) async {
        await _presentDialog(
          'Veja sua caixa de entrada!',
          'Um e-mail lhe foi enviado para que possa redefinir sua senha.',
          context,
        );
      }).catchError((error) async {
        if (error.message != null) {
          await _presentDialog(
            'Erro!',
            'Ocorreu algum erro ao tentar requisitar uma nova senha.',
            context,
          );
        }
      });
    } else {
      await _presentDialog(
        'Informe seu e-mail!',
        'É necessário que você informe seu e-mail para redefinir sua senha.',
        context,
      );
    }
  }
}
