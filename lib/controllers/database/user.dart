import 'package:firebase_database/firebase_database.dart';

import 'package:futgres/models/database/user.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<bool> checkIfUserAlreadyExists(String uid) async {
    return await _database
        .reference()
        .child('users/$uid')
        .get()
        .then((snapshot) => snapshot.exists);
  }

  Future<void> createUserInDatabase(UserModel user) async {
    await _database
        .reference()
        .child('users/${user.uid}')
        .set(user.convertToDatabase());
    final bool isPlayer = user.isOrganizer != null
        ? user.isOrganizer!
            ? false
            : true
        : true;
    if (isPlayer) {
      await _database
          .reference()
          .child('players/${user.uid}')
          .set(user.convertToDatabase());
    }
  }

  Future<UserModel?> getUserFromDatabase(String uid) async {
    final DataSnapshot data =
        await _database.reference().child('users/$uid').once();
    if (!data.exists) return null;

    final UserModel userModel =
        UserModel.convertFromDatabase(Map<String, dynamic>.from(data.value));

    return userModel;
  }
}
