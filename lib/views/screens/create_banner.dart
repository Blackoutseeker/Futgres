import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';

import 'package:futgres/controllers/database/banner.dart';

import 'package:futgres/models/database/banner.dart';

class CreateBannerScreen extends StatefulWidget {
  const CreateBannerScreen({Key? key}) : super(key: key);

  @override
  State<CreateBannerScreen> createState() => _CreateBannerScreenState();
}

class _CreateBannerScreenState extends State<CreateBannerScreen> {
  final BannerDatabase _database = BannerDatabase.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();

  File? _bannerImage;

  Future<void> _backToPreviousScreen(BuildContext context) async {
    Navigator.of(context).pop();
  }

  Future<void> _pickBannerImage() async {
    final XFile? bannerImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1200,
    );

    if (bannerImage?.path != null) {
      CroppedFile? croppedBannerImage = await ImageCropper().cropImage(
          sourcePath: bannerImage!.path,
          aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 70,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cortar imagem',
              hideBottomControls: true,
              toolbarColor: const Color(0xFF0FA854),
              toolbarWidgetColor: const Color(0xFFFFFFFF),
            ),
          ]);

      if (croppedBannerImage?.path != null) {
        setState(() {
          _bannerImage = File(croppedBannerImage!.path);
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

  Future<void> _createBannerInDatabase(BuildContext context) async {
    final String description = _descriptionController.text;
    final bool isFormValid = _bannerImage != null && description.isNotEmpty;

    if (isFormValid) {
      final DateTime currentDate = DateTime.now();
      final String id = DateFormat('dd_MM_yyyy_hh_mm_ss').format(currentDate);
      final String imageUrl =
          await _uploadImageToStorage(_bannerImage!, 'banners/$id.jpg');
      final String postDate = DateFormat('dd/MM/yyyy').format(currentDate);

      final BannerModel bannerModel = BannerModel(
        id: id,
        description: description,
        imageUrl: imageUrl,
        postDate: postDate,
      );

      await _database.createBannerInDatabase(bannerModel).then((_) async {
        _backToPreviousScreen(context);
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Criar postagem'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: _pickBannerImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        color: const Color.fromRGBO(0, 0, 0, 0.2),
                        child: _bannerImage != null
                            ? Image.file(
                                _bannerImage!,
                                fit: BoxFit.cover,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const <Widget>[
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Color.fromRGBO(255, 255, 255, 0.7),
                                    size: 80,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Escolher imagem',
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 0.7),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _descriptionController,
                    onEditingComplete: () => _createBannerInDatabase(context),
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Descrição da postagem',
                      labelStyle: TextStyle(),
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _createBannerInDatabase(context),
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF000000),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      'Postar',
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
