import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:futgres/controllers/database/team.dart';
import 'package:futgres/controllers/database/match.dart';

import 'package:futgres/models/database/team.dart';
import 'package:futgres/models/database/match.dart';

class CreateMatch extends StatefulWidget {
  const CreateMatch({Key? key}) : super(key: key);

  @override
  State<CreateMatch> createState() => _CreateMatchState();
}

class _CreateMatchState extends State<CreateMatch> {
  final TeamDatabase _teamDatabase = TeamDatabase.instance;
  final MatchDatabase _matchDatabase = MatchDatabase.instance;
  final TextEditingController _firstTeamController = TextEditingController();
  final TextEditingController _secondTeamController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  List<TeamModel> _teams = [];
  final List<TeamModel> _selectedTeams = [];
  final TimeOfDay _initialTime = const TimeOfDay(hour: 10, minute: 00);

  void _backToPreviousScreen(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _showTeamsList(
    TextEditingController textController,
    int teamIndex,
  ) async {
    await showDialog(
      context: context,
      useSafeArea: true,
      builder: (_) => AlertDialog(
        title: const Text('Escolha um time'),
        content: SizedBox(
          height: 360,
          child: ListView.builder(
            itemCount: _teams.length,
            itemBuilder: (_, index) => ListTile(
              onTap: () {
                Navigator.of(context).pop();
                textController.text = _teams[index].name;
                setState(() {
                  if (_selectedTeams.isEmpty || _selectedTeams.length == 1) {
                    _selectedTeams.add(_teams[index]);
                  } else {
                    _selectedTeams[teamIndex] = _teams[index];
                  }
                });
              },
              title: Text(_teams[index].name),
              leading: CircleAvatar(
                backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
                foregroundImage: _teams[index].logoUrl != null
                    ? NetworkImage(
                        _teams[index].logoUrl!,
                      )
                    : null,
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createMatchInDatabase() async {
    final String place = _placeController.text;
    final String date = _dateController.text;
    final String time = _timeController.text;
    final bool isFormValid = place.isNotEmpty &&
        date.isNotEmpty &&
        time.isNotEmpty &&
        _selectedTeams.length == 2;

    if (isFormValid) {
      final DateTime currentDate = DateTime.now();
      final String id = DateFormat('dd_MM_yyyy_hh_mm_ss').format(currentDate);

      final MatchModel matchModel = MatchModel(
        id: id,
        teams: [
          SimpleTeamModel(
            id: _selectedTeams[0].id,
            name: _selectedTeams[0].name,
            logoUrl: _selectedTeams[0].logoUrl,
          ),
          SimpleTeamModel(
            id: _selectedTeams[1].id,
            name: _selectedTeams[1].name,
            logoUrl: _selectedTeams[1].logoUrl,
          ),
        ],
        place: place,
        date: date,
        time: time,
      );

      await _matchDatabase.createMatchInDatabase(matchModel).then((_) {
        _backToPreviousScreen(context);
      });
    }
  }

  Future<void> _getTeamsFromDatabase() async {
    await _teamDatabase.getTeamsFromDatabase().then((teams) {
      setState(() {
        _teams = teams;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getTeamsFromDatabase();
  }

  @override
  void dispose() {
    _firstTeamController.dispose();
    _secondTeamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Agendar partida'),
          ),
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _firstTeamController,
                    readOnly: true,
                    onTap: () => _showTeamsList(_firstTeamController, 0),
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Escolher time',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'X',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _secondTeamController,
                    readOnly: true,
                    onTap: () => _showTeamsList(_secondTeamController, 1),
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Escolher time adversário',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _placeController,
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Informe o local',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                      ),
                      suffixIcon: Icon(
                        Icons.location_on,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime(2077),
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          _dateController.text =
                              DateFormat('dd/MM/yyyy').format(date);
                        });
                      }
                    }),
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Escolher data',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _timeController,
                    readOnly: true,
                    onTap: () => showTimePicker(
                      context: context,
                      initialTime: _initialTime,
                    ).then((time) {
                      if (time != null) {
                        setState(() {
                          _timeController.text = time.format(context);
                        });
                      }
                    }),
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Escolher horário',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2),
                      ),
                      suffixIcon: Icon(
                        Icons.access_time,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _createMatchInDatabase(),
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF000000),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      'Agendar partida',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
