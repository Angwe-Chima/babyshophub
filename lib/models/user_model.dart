class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? address;
  final List<String> interests;
  final bool hasCompletedOnboarding;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.address,
    this.interests = const [],
    this.hasCompletedOnboarding = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      address: map['address'],
      interests: List<String>.from(map['interests'] ?? []),
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'address': address,
      'interests': interests,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? address,
    List<String>? interests,
    bool? hasCompletedOnboarding,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      interests: interests ?? this.interests,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}