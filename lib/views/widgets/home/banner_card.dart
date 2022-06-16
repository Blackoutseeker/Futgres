import 'package:flutter/material.dart';

import 'package:futgres/models/database/banner.dart';

class BannerCard extends StatelessWidget {
  const BannerCard({Key? key, required this.bannerModel}) : super(key: key);

  final BannerModel bannerModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  bannerModel.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              bannerModel.description,
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              bannerModel.postDate,
              style: const TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
