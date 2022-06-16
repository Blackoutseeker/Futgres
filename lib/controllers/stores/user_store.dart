import 'package:mobx/mobx.dart';

import 'package:futgres/models/database/user.dart';

part 'user_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  @observable
  UserModel user = UserModel(isOrganizer: false);

  @action
  void setUser({
    required String? uid,
    required String? email,
    required String? name,
    required String? birthDate,
    String? avatarUrl,
    String? teamId,
    bool? isOrganizer = false,
  }) {
    user = UserModel(
      uid: uid,
      email: email,
      name: name,
      birthDate: birthDate,
      avatarUrl: avatarUrl,
      teamId: teamId,
      isOrganizer: isOrganizer,
    );
  }
}
