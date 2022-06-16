import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'package:futgres/models/database/match.dart';
import 'package:futgres/models/routes/routes.dart';

import 'package:futgres/controllers/database/match.dart';
import 'package:futgres/controllers/stores/user_store.dart';

import 'package:futgres/views/widgets/matches/match_card.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final UserStore _userStore = GetIt.I.get<UserStore>();
  final MatchDatabase _database = MatchDatabase.instance;
  List<MatchModel> _matches = [];

  Future<void> _navigateToCreateMatchScreen(BuildContext context) async {
    await Navigator.of(context).pushNamed(Routes.createMatch);
  }

  Future<void> _getMatchesFromDatabase() async {
    await _database.getMatchesFromDatabase().then((matchesFromDatabase) {
      setState(() {
        _matches = matchesFromDatabase;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getMatchesFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Scaffold(
        body: RefreshIndicator(
          onRefresh: _getMatchesFromDatabase,
          child: SizedBox(
            width: double.infinity,
            child: _matches.isEmpty
                ? const SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Nenhuma partida foi agendada até o momento.',
                          style: TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: false,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _matches.length,
                    itemBuilder: (_, index) => MatchCard(
                      key: UniqueKey(),
                      matchModel: _matches[index],
                    ),
                  ),
          ),
        ),
        floatingActionButton: _userStore.user.isOrganizer == true
            ? FloatingActionButton(
                onPressed: () => _navigateToCreateMatchScreen(context),
                tooltip: 'Agendar partida',
                heroTag: 'FAB matches',
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
