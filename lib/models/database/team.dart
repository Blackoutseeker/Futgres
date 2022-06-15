import './user.dart';

class TeamModel {
  const TeamModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.players,
    required this.victories,
    required this.defeats,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final List<UserModel> players;
  final int victories;
  final int defeats;
}
