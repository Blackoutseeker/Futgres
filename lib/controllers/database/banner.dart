import 'package:firebase_database/firebase_database.dart';

import 'package:futgres/models/database/banner.dart';

class BannerDatabase {
  static final BannerDatabase instance = BannerDatabase();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<List<BannerModel>> getBannersFromDatabase() async {
    final List<BannerModel> banners = [];

    await _database.reference().child('banners').once().then((snapshot) {
      final Map<String, dynamic> bannersFromDatabase =
          Map<String, dynamic>.from(snapshot.value);

      bannersFromDatabase.forEach((_, value) {
        banners.add(
          BannerModel.convertFromDatabase(Map<String, dynamic>.from(value)),
        );
      });
    });

    return banners;
  }

  Future<void> createBannerInDatabase(BannerModel bannerModel) async {
    await _database
        .reference()
        .child('banners')
        .child(bannerModel.id)
        .set(bannerModel.convertToDatabase());
  }
}
