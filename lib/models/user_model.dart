class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String userType; // 'tenant' or 'landlord'
  final String? profileImageUrl;
  final String? address;
  final Map<String, dynamic>? additionalInfo;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    this.profileImageUrl,
    this.address,
    this.additionalInfo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userType: json['userType'] ?? 'tenant',
      profileImageUrl: json['profileImageUrl'],
      address: json['address'],
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'additionalInfo': additionalInfo,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? userType,
    String? profileImageUrl,
    String? address,
    Map<String, dynamic>? additionalInfo,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}

class PropertyModel {
  final String id;
  final String landlordId;
  final String title;
  final String description;
  final double price;
  final String location;
  final List<String> imageUrls;
  final int bedrooms;
  final int bathrooms;
  final double squareFootage;
  final List<String> amenities;
  final bool isAvailable;
  final DateTime listedDate;

  PropertyModel({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.imageUrls,
    required this.bedrooms,
    required this.bathrooms,
    required this.squareFootage,
    required this.amenities,
    required this.isAvailable,
    required this.listedDate,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? '',
      landlordId: json['landlordId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      squareFootage: (json['squareFootage'] ?? 0).toDouble(),
      amenities: List<String>.from(json['amenities'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      listedDate: json['listedDate'] != null
          ? DateTime.parse(json['listedDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'landlordId': landlordId,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'imageUrls': imageUrls,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'squareFootage': squareFootage,
      'amenities': amenities,
      'isAvailable': isAvailable,
      'listedDate': listedDate.toIso8601String(),
    };
  }
}