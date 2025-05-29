class BenefitData {
  final int id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final int ownerId;
  final bool private;
  final List<String> categories;
  final int? channelId;
  final String? image;
  final String? link;
  final double? latitude;
  final double? longitude;
  final int likes;

  BenefitData({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.ownerId,
    this.private = false,
    this.categories = const [],
    this.channelId,
    this.image,
    this.link,
    this.latitude,
    this.longitude,
    this.likes = 0,
  });

  

  factory BenefitData.fromJson(Map<String, dynamic> json) {
    return BenefitData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      description: json['description'] ?? '',
      ownerId: json['owner_id'] ?? 0,
      private: json['private'] ?? false,
      categories: List<String>.from(json['categories'] ?? []),
      channelId: json['channel_id'],
      image: json['image'],
      link: json['link'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      likes: json['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'description': description,
      'owner_id': ownerId,
      'private': private,
      'categories': categories,
      'channel_id': channelId,
      'image': image,
      'link': link,
      'latitude': latitude,
      'longitude': longitude,
      'likes': likes,
    };
  }

  BenefitData copyWith({
    int? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    int? ownerId,
    bool? private,
    List<String>? categories,
    int? channelId,
    String? image,
    String? link,
    double? latitude,
    double? longitude,
    int? likes,
  }) {
    return BenefitData(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      private: private ?? this.private,
      categories: categories ?? this.categories,
      channelId: channelId ?? this.channelId,
      image: image ?? this.image,
      link: link ?? this.link,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      likes: likes ?? this.likes,
    );
  }
}
