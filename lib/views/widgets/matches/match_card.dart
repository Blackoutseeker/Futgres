import 'package:flutter/material.dart';

import 'package:futgres/models/database/match.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({Key? key, required this.matchModel}) : super(key: key);

  final MatchModel matchModel;

  Widget _renderTeam(SimpleTeamModel team, bool isReverse) {
    if (isReverse) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Text(
              team.name,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF000000),
                fontSize: 20,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
            foregroundImage: team.logoUrl != null
                ? NetworkImage(
                    team.logoUrl!,
                  )
                : null,
            child: const Icon(
              Icons.shield,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
          foregroundImage: team.logoUrl != null
              ? NetworkImage(
                  team.logoUrl!,
                )
              : null,
          child: const Icon(
            Icons.shield,
            color: Color(0xFFFFFFFF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            team.name,
            style: const TextStyle(
              color: Color(0xFF000000),
              fontSize: 20,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderCustomTextWithIcon(IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: const Color(0xFF000000),
          size: 25,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _renderTeam(matchModel.teams[0], false),
                const SizedBox(height: 16),
                const Text(
                  'X',
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                _renderTeam(matchModel.teams[1], true),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(
              color: Color.fromRGBO(0, 0, 0, 0.5),
            ),
            const SizedBox(height: 16),
            matchModel.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      color: const Color.fromRGBO(0, 0, 0, 0.5),
                      width: double.infinity,
                      height: 160,
                      child: Image.network(
                        matchModel.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : const SizedBox(),
            matchModel.imageUrl != null
                ? const SizedBox(height: 16)
                : const SizedBox(),
            _renderCustomTextWithIcon(Icons.location_on, matchModel.place),
            const SizedBox(height: 16),
            _renderCustomTextWithIcon(Icons.calendar_today, matchModel.date),
            const SizedBox(height: 16),
            _renderCustomTextWithIcon(Icons.access_time, matchModel.time),
          ],
        ),
      ),
    );
  }
}
