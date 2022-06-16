class SimpleTeamModel {
  const SimpleTeamModel({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String? logoUrl;

  Map<String, dynamic> convertToDatabase() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
    };
  }

  factory SimpleTeamModel.convertFromDatabase(Map<String, dynamic> data) {
    return SimpleTeamModel(
      id: data['id'],
      name: data['name'],
      logoUrl: data['logoUrl'],
    );
  }
}

class MatchModel {
  MatchModel({
    required this.id,
    this.imageUrl,
    required this.teams,
    required this.place,
    required this.date,
    required this.time,
  });

  final String id;
  String? imageUrl;
  final List<SimpleTeamModel> teams;
  final String place;
  final String date;
  final String time;

  set setImageUrl(String imageUrl) {
    this.imageUrl = imageUrl;
  }

  Map<String, dynamic> convertToDatabase() {
    final Map<String, dynamic> convertedTeams = {};
    for (var team in teams) {
      convertedTeams.addAll({team.id: team.convertToDatabase()});
    }

    return {
      'id': id,
      'imageUrl': imageUrl,
      'teams': convertedTeams,
      'place': place,
      'date': date,
      'time': time,
    };
  }

  factory MatchModel.convertFromDatabase(Map<String, dynamic> data) {
    final List<SimpleTeamModel> teams = [];
    Map<String, dynamic>.from(data['teams']).forEach((_, value) {
      teams.add(
        SimpleTeamModel.convertFromDatabase(Map<String, dynamic>.from(value)),
      );
    });

    return MatchModel(
      id: data['id'],
      imageUrl: data['imageUrl'],
      teams: teams,
      place: data['place'],
      date: data['date'],
      time: data['time'],
    );
  }
}
