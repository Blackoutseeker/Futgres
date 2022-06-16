import 'package:firebase_database/firebase_database.dart';

import 'package:futgres/models/database/user.dart';

class PlayerDatabase {
  static final PlayerDatabase instance = PlayerDatabase();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<List<UserModel>> getPlayersFromDatabase() async {
    final List<UserModel> players = [];

    await _database.reference().child('players').once().then((snapshot) {
      final Map<String, dynamic> playersFromDatabase =
          Map<String, dynamic>.from(snapshot.value);
      playersFromDatabase.forEach((_, value) {
        players.add(
            UserModel.convertFromDatabase(Map<String, dynamic>.from(value)));
      });
    });

    return players;
  }
}
