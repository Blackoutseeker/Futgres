import 'package:firebase_database/firebase_database.dart';

import 'package:futgres/models/database/match.dart';

class MatchDatabase {
  static final MatchDatabase instance = MatchDatabase();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<List<MatchModel>> getMatchesFromDatabase() async {
    final List<MatchModel> matches = [];

    await _database.ref().child('matches').once().then((snapshot) {
      final Map<String, dynamic> matchesFromDatabase =
          Map<String, dynamic>.from(snapshot.snapshot.value as Map);

      matchesFromDatabase.forEach((_, value) {
        matches.add(
            MatchModel.convertFromDatabase(Map<String, dynamic>.from(value)));
      });
    });

    return matches;
  }

  Future<void> createMatchInDatabase(MatchModel matchModel) async {
    await _database
        .ref()
        .child('matches')
        .child(matchModel.id)
        .set(matchModel.convertToDatabase());
  }
}
