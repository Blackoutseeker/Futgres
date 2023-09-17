import 'package:firebase_database/firebase_database.dart';

import 'package:futgres/models/database/user.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<bool> checkIfUserAlreadyExists(String uid) async {
    return await _database
        .ref()
        .child('users/$uid')
        .get()
        .then((snapshot) => snapshot.exists);
  }

  Future<void> createUserInDatabase(UserModel user) async {
    await _database
        .ref()
        .child('users/${user.uid}')
        .set(user.convertToDatabase());
    final bool isPlayer = user.isOrganizer != null
        ? user.isOrganizer!
            ? false
            : true
        : true;
    if (isPlayer) {
      await _database
          .ref()
          .child('players/${user.uid}')
          .set(user.convertToDatabase());
    }
  }

  Future<UserModel?> getUserFromDatabase(String uid) async {
    final DataSnapshot data = await _database.ref().child('users/$uid').get();
    if (!data.exists) return null;

    final UserModel userModel = UserModel.convertFromDatabase(
        Map<String, dynamic>.from(data.value as Map));

    return userModel;
  }

  Future<void> updateUserInDatabase(UserModel userModel) async {
    await _database
        .ref()
        .child('users/${userModel.uid}')
        .update(userModel.convertToDatabase());

    await _database
        .ref()
        .child('players/${userModel.uid}')
        .update(userModel.convertToDatabase());

    if (userModel.teamId != null) {
      await _database
          .ref()
          .child('teams/${userModel.teamId}/players/${userModel.uid}')
          .update(userModel.convertToDatabase());
    }
  }
}
