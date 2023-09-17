import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:futgres/controllers/database/team.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';

import 'package:futgres/controllers/database/player.dart';

import 'package:futgres/models/database/user.dart';
import 'package:futgres/models/database/team.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({Key? key}) : super(key: key);

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final PlayerDatabase _playerDatabase = PlayerDatabase.instance;
  final TeamDatabase _teamDatabase = TeamDatabase.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _players = [];
  List<UserModel> _playersHolder = [];
  List<UserModel> _searchedPlayers = [];
  File? _teamLogo;

  void _backToPreviousScreen(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _filterPlayersBySearch(String search) {
    setState(() {
      _searchedPlayers = _playersHolder.where((player) {
        return player.name!.toLowerCase().contains(search.toLowerCase());
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchedPlayers = [];
    });
  }

  Future<void> _pickTeamLogoImage() async {
    final XFile? teamLogoImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1200,
    );

    if (teamLogoImage?.path != null) {
      CroppedFile? croppedTeamLogoImage = await ImageCropper().cropImage(
          sourcePath: teamLogoImage!.path,
          compressFormat: ImageCompressFormat.jpg,
          cropStyle: CropStyle.circle,
          compressQuality: 70,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cortar imagem',
              hideBottomControls: true,
              toolbarColor: const Color(0xFF0FA854),
              toolbarWidgetColor: const Color(0xFFFFFFFF),
            ),
          ]);

      if (croppedTeamLogoImage?.path != null) {
        setState(() {
          _teamLogo = File(croppedTeamLogoImage!.path);
        });
      }
    }
  }

  Future<String> _uploadImageToStorage(File image, String storagePath) async {
    final TaskSnapshot snapshot = await _firebaseStorage
        .ref()
        .child(storagePath)
        .putFile(image)
        .whenComplete(() {});

    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _createTeamInDatabase(BuildContext context) async {
    final name = _teamNameController.text;
    final bool isFormValid = name.isNotEmpty && _players.isNotEmpty;

    if (isFormValid) {
      final DateTime currentDate = DateTime.now();
      final String id = DateFormat('dd_MM_yyyy_hh_mm_ss').format(currentDate);
      String? logoUrl;

      if (_teamLogo != null) {
        logoUrl = await _uploadImageToStorage(_teamLogo!, 'teamsLogo/$id.jpg');
      }

      final List<UserModel> players = [];
      for (var player in _players) {
        player.setTeamId = id;
        players.add(player);
      }

      final TeamModel teamModel = TeamModel(
        id: id,
        name: name,
        logoUrl: logoUrl,
        players: players,
        victories: 0,
        defeats: 0,
      );

      await _teamDatabase.createTeamInDatabase(teamModel).then((_) {
        _backToPreviousScreen(context);
      });
    }
  }

  Future<void> _getPlayersFromDatabase() async {
    final List<UserModel> players =
        await _playerDatabase.getPlayersFromDatabase();
    setState(() {
      _playersHolder = players;
    });
  }

  @override
  void initState() {
    super.initState();
    _getPlayersFromDatabase();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Criar time'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      InkWell(
                        onTap: _pickTeamLogoImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: const Color.fromRGBO(0, 0, 0, 0.5),
                            child: _teamLogo != null
                                ? Image.file(
                                    _teamLogo!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Color.fromRGBO(255, 255, 255, 0.8),
                                    size: 30,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Símbolo do time',
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _teamNameController,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nome do time',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: _filterPlayersBySearch,
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Procurar jogadores',
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  (_searchedPlayers.isNotEmpty &&
                          _searchController.text.isNotEmpty)
                      ? SizedBox(
                          height: (56 * _searchedPlayers.length).toDouble(),
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _searchedPlayers.length,
                            itemBuilder: (_, index) => ListTile(
                              key: UniqueKey(),
                              title: Text(_searchedPlayers[index].name!),
                              onTap: () {
                                setState(() {
                                  _players.add(_searchedPlayers[index]);
                                  _players = _players.toSet().toList();
                                  _clearSearch();
                                });
                              },
                              leading: CircleAvatar(
                                backgroundColor:
                                    const Color.fromRGBO(0, 0, 0, 0.5),
                                foregroundImage:
                                    _searchedPlayers[index].avatarUrl != null
                                        ? NetworkImage(
                                            _searchedPlayers[index].avatarUrl!,
                                          )
                                        : null,
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        )
                      : _players.isEmpty
                          ? const Text(
                              'Nenhum jogador selecionado',
                              style: TextStyle(
                                color: Color(0xFF777777),
                                fontSize: 20,
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Jogadores selecionados',
                                    style: TextStyle(
                                      color: Color(0xFF777777),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: (56 * _players.length).toDouble(),
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _players.length,
                                    itemBuilder: (_, index) => ListTile(
                                      key: UniqueKey(),
                                      title: Text(_players[index].name!),
                                      trailing: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _players.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: Color(0xFF777777),
                                        ),
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            const Color.fromRGBO(0, 0, 0, 0.5),
                                        foregroundImage:
                                            _players[index].avatarUrl != null
                                                ? NetworkImage(
                                                    _players[index].avatarUrl!,
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
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () =>
                                      _createTeamInDatabase(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF000000),
                                    minimumSize: const Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: const Text(
                                    'Criar',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
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
