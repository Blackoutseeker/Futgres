class UserModel {
  UserModel({
    this.uid,
    this.email,
    this.name,
    this.birthDate,
    this.avatarUrl,
    this.teamId,
    this.isOrganizer,
  });

  final String? uid;
  final String? email;
  final String? name;
  final String? birthDate;
  String? avatarUrl;
  String? teamId;
  final bool? isOrganizer;

  set setAvatarUrl(String avatarUrl) {
    this.avatarUrl = avatarUrl;
  }

  set setTeamId(String teamId) {
    this.teamId = teamId;
  }

  Map<String, dynamic> convertToDatabase() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'birthDate': birthDate,
      'avatarUrl': avatarUrl,
      'teamId': teamId,
      'isOrganizer': isOrganizer,
    };
  }

  factory UserModel.convertFromDatabase(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      name: data['name'],
      birthDate: data['birthDate'],
      avatarUrl: data['avatarUrl'],
      teamId: data['teamId'],
      isOrganizer: data['isOrganizer'],
    );
  }
}
