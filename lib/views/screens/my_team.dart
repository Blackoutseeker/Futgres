import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'package:futgres/controllers/database/team.dart';
import 'package:futgres/controllers/stores/user_store.dart';

import 'package:futgres/models/database/team.dart';
import 'package:futgres/models/routes/routes.dart';

class MyTeamScreen extends StatefulWidget {
  const MyTeamScreen({Key? key}) : super(key: key);

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> {
  final TeamDatabase _database = TeamDatabase.instance;
  final UserStore _userStore = GetIt.I.get<UserStore>();

  Future<void> _navigateToCreateTeamScreen(BuildContext context) async {
    await Navigator.of(context).pushNamed(Routes.createTeam);
  }

  Future<TeamModel?> _getTeamFromDatabase() async {
    final String? teamId = _userStore.user.teamId;
    if (teamId != null) {
      return await _database.getTeamFromDatabase(teamId);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Scaffold(
        body: RefreshIndicator(
          onRefresh: _getTeamFromDatabase,
          child: FutureBuilder(
            future: _getTeamFromDatabase(),
            builder: (_, AsyncSnapshot<TeamModel?> teamModel) => SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 32,
                ),
                child: Column(
                  children: <Widget>[
                    _userStore.user.teamId == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Você não está em nenhum time. Peça para que um organizador coloque você em algum.',
                              style: TextStyle(
                                color: Color(0xFF777777),
                                fontSize: 20,
                              ),
                            ),
                          )
                        : teamModel.data != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(70),
                                          child: Container(
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 0.5),
                                            width: 70,
                                            height: 70,
                                            child: teamModel.data!.logoUrl !=
                                                    null
                                                ? Image.network(
                                                    teamModel.data!.logoUrl!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : const Icon(
                                                    Icons.shield,
                                                    color: Color(0xFFFFFFFF),
                                                    size: 40,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 32),
                                        Expanded(
                                          child: Text(
                                            teamModel.data!.name,
                                            style: const TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 24,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(
                                      color: Color.fromRGBO(0, 0, 0, 0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height: 80,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Text>[
                                                const Text(
                                                  'Vitórias',
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 22,
                                                  ),
                                                ),
                                                Text(
                                                  '${teamModel.data!.victories}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF333333),
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Color.fromRGBO(0, 0, 0, 0.5),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Text>[
                                                const Text(
                                                  'Derrotas',
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 22,
                                                  ),
                                                ),
                                                Text(
                                                  '${teamModel.data!.defeats}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF333333),
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(
                                      color: Color.fromRGBO(0, 0, 0, 0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    const Row(
                                      children: <Text>[
                                        Text(
                                          'Jogadores',
                                          style: TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height:
                                          (56 * teamModel.data!.players.length)
                                              .toDouble(),
                                      child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            teamModel.data!.players.length,
                                        itemBuilder: (_, index) => ListTile(
                                          key: UniqueKey(),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 0),
                                          title: Text(teamModel
                                              .data!.players[index].name!),
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    0, 0, 0, 0.5),
                                            foregroundImage: teamModel
                                                        .data!
                                                        .players[index]
                                                        .avatarUrl !=
                                                    null
                                                ? NetworkImage(
                                                    teamModel
                                                        .data!
                                                        .players[index]
                                                        .avatarUrl!,
                                                  )
                                                : null,
                                            child: const Icon(
                                              Icons.person,
                                              color: Color(0xFFFFFFFF),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const Text(
                                'Você não está em nenhum time. Peça para que um organizador coloque você em algum.',
                                style: TextStyle(
                                  color: Color(0xFF777777),
                                  fontSize: 20,
                                ),
                              ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: _userStore.user.isOrganizer == true
            ? FloatingActionButton(
                onPressed: () => _navigateToCreateTeamScreen(context),
                tooltip: 'Criar time',
                heroTag: 'FAB my_team',
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
