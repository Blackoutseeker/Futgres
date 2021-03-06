import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'package:futgres/models/database/banner.dart';
import 'package:futgres/models/routes/routes.dart';

import 'package:futgres/controllers/database/banner.dart';
import 'package:futgres/controllers/stores/user_store.dart';

import 'package:futgres/views/widgets/home/banner_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserStore _userStore = GetIt.I.get<UserStore>();
  final BannerDatabase _database = BannerDatabase.instance;
  List<BannerModel> _banners = [];

  Future<void> _navigateToCreateBannerScreen(BuildContext context) async {
    await Navigator.of(context).pushNamed(Routes.createBanner);
  }

  Future<void> _getBannersFromDatabase() async {
    await _database.getBannersFromDatabase().then((bannersFromDatabase) {
      setState(() {
        _banners = bannersFromDatabase;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getBannersFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Scaffold(
        body: RefreshIndicator(
          onRefresh: _getBannersFromDatabase,
          child: SizedBox(
            width: double.infinity,
            child: _banners.isEmpty
                ? const SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Nenhuma postagem foi feita até o momento.',
                          style: TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: false,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _banners.length,
                    itemBuilder: (_, index) => BannerCard(
                      key: UniqueKey(),
                      bannerModel: _banners[index],
                    ),
                  ),
          ),
        ),
        floatingActionButton: _userStore.user.isOrganizer == true
            ? FloatingActionButton(
                onPressed: () => _navigateToCreateBannerScreen(context),
                tooltip: 'Criar postagem',
                heroTag: 'FAB home',
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
