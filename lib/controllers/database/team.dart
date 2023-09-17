import 'package:firebase_database/firebase_database.dart';

import './user.dart';

import 'package:futgres/models/database/team.dart';

class TeamDatabase {
  static final TeamDatabase instance = TeamDatabase();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final UserDatabase _userDatabase = UserDatabase.instance;

  Future<void> createTeamInDatabase(TeamModel teamModel) async {
    await _database
        .ref()
        .child('teams/${teamModel.id}')
        .set(teamModel.convertToDatabase());

    for (var player in teamModel.players) {
      await _userDatabase.updateUserInDatabase(player);
    }
  }

  Future<TeamModel> getTeamFromDatabase(String teamId) async {
    return await _database.ref().child('teams/$teamId').once().then((snapshot) {
      final Map<String, dynamic> teamFromDatabase =
          Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      TeamModel teamModel = TeamModel.convertFromDatabase(teamFromDatabase);
      return teamModel;
    });
  }

  Future<List<TeamModel>> getTeamsFromDatabase() async {
    final List<TeamModel> teams = [];

    await _database.ref().child('teams').once().then((snapshot) {
      final Map<String, dynamic> teamsFromDatabase =
          Map<String, dynamic>.from(snapshot.snapshot.value as Map);

      teamsFromDatabase.forEach((_, value) {
        teams.add(
          TeamModel.convertFromDatabase(Map<String, dynamic>.from(value)),
        );
      });
    });

    return teams;
  }
}
