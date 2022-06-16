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

  Map<String, dynamic> convertToDatabase() {
    final Map<String, dynamic> convertedPlayers = {};
    for (var player in players) {
      convertedPlayers.addAll({'${player.uid}': player.convertToDatabase()});
    }

    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'players': convertedPlayers,
      'victories': victories,
      'defeats': defeats,
    };
  }

  factory TeamModel.convertFromDatabase(Map<String, dynamic> data) {
    final List<UserModel> players = [];
    Map<String, dynamic>.from(data['players']).forEach((_, value) {
      players.add(
        UserModel.convertFromDatabase(Map<String, dynamic>.from(value)),
      );
    });

    return TeamModel(
      id: data['id'],
      name: data['name'],
      logoUrl: data['logoUrl'],
      players: players,
      victories: data['victories'],
      defeats: data['defeats'],
    );
  }
}
