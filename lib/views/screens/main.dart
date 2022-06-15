import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import 'package:futgres/models/storage/storaged_values.dart';
import 'package:futgres/models/database/user.dart';

import 'package:futgres/controllers/database/user.dart';
import 'package:futgres/controllers/stores/user_store.dart';

import 'package:futgres/views/screens/home.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
  ];

  int _currentNavigationIndex = 0;

  void _handleNavigationIndexChange(int currentIndex) {
    setState(() {
      _currentNavigationIndex = currentIndex;
    });
  }

  Future<void> _loadUser() async {
    final UserDatabase database = UserDatabase.instance;

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? uid = preferences.getString(StoragedValues.uid);

    if (uid != null) {
      final UserStore userStore = GetIt.I.get<UserStore>();
      UserModel? userModel = await database.getUserFromDatabase(uid);

      userStore.setUser(
        uid: userModel?.uid,
        email: userModel?.email,
        name: userModel?.name,
        birthDate: userModel?.birthDate,
        avatarUrl: userModel?.avatarUrl,
        teamId: userModel?.teamId,
        isOrganizer: userModel?.isOrganizer,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: _currentNavigationIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentNavigationIndex,
          onTap: _handleNavigationIndexChange,
          backgroundColor: const Color(0xFF0FA854),
          unselectedItemColor: const Color(0xFFFFFFFF),
          selectedItemColor: const Color(0xFF000000),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield),
              label: 'Meu time',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Agenda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: 'Tabelas',
            ),
          ],
        ),
      ),
    );
  }
}
