import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:futgres/controllers/stores/user_store.dart';

import 'package:futgres/models/storage/storaged_values.dart';
import 'package:futgres/models/routes/routes.dart';

import 'package:futgres/views/screens/initial.dart';
import 'package:futgres/views/screens/sign_in.dart';
import 'package:futgres/views/screens/sign_up.dart';
import 'package:futgres/views/screens/main.dart';
import 'package:futgres/views/screens/home.dart';
import 'package:futgres/views/screens/create_banner.dart';
import 'package:futgres/views/screens/my_team.dart';
import 'package:futgres/views/screens/create_team.dart';
import 'package:futgres/views/screens/matches.dart';
import 'package:futgres/views/screens/create_match.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final GetIt getIt = GetIt.I;
  getIt.registerLazySingleton<UserStore>(() => UserStore());

  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final String? isLogged = preferences.getString(StoragedValues.uid);
  // await preferences.clear();
  runApp(App(isLogged: isLogged));
}

class App extends StatelessWidget {
  const App({Key? key, required this.isLogged}) : super(key: key);

  final String? isLogged;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return Observer(
      builder: (_) => MaterialApp(
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        title: 'Futgres',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: const MaterialColor(0xFF0FA854, {
            50: Color(0xFFE6F6EB),
            100: Color(0xFFC3E9CE),
            200: Color(0xFF9BDBAF),
            300: Color(0xFF70CE8F),
            400: Color(0xFF4BC376),
            500: Color(0xFF1BB75E),
            600: Color(0xFF0FA854),
            700: Color(0xFF009648),
            800: Color(0xFF00843C),
            900: Color(0xFF006528),
          })).copyWith(
            secondary: const Color(0xFF000000),
          ),
        ),
        home: isLogged == null ? const InitialScreen() : const MainScreen(),
        routes: {
          Routes.initial: (_) => const InitialScreen(),
          Routes.signin: (_) => const SignInScreen(),
          Routes.signup: (_) => const SignUpScreen(),
          Routes.main: (_) => const MainScreen(),
          Routes.home: (_) => const HomeScreen(),
          Routes.createBanner: (_) => const CreateBannerScreen(),
          Routes.myTeam: (_) => const MyTeamScreen(),
          Routes.createTeam: (_) => const CreateTeamScreen(),
          Routes.matches: (_) => const MatchesScreen(),
          Routes.createMatch: (_) => const CreateMatch(),
          Routes.scores: (_) => const HomeScreen(),
        },
      ),
    );
  }
}
