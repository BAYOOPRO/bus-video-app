// ✅ lib/models/video_model.dart

class VideoModel {
  final int id;
  final String url;
  final String createdAt;

  VideoModel({required this.id, required this.url, required this.createdAt});

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: int.parse(json['id'].toString()),
      url: json['video_url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_url': url,
      'created_at': createdAt,
    };
  }
}
