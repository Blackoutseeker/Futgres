class BannerModel {
  const BannerModel({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.postDate,
  });

  final String id;
  final String imageUrl;
  final String description;
  final String postDate;

  Map<String, dynamic> convertToDatabase() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'description': description,
      'postDate': postDate,
    };
  }

  factory BannerModel.convertFromDatabase(Map<String, dynamic> data) {
    return BannerModel(
      id: data['id'],
      imageUrl: data['imageUrl'],
      description: data['description'],
      postDate: data['postDate'],
    );
  }
}
