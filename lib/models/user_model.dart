// models/user_model.dart
class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final List<String> interests;
  final bool hasCompletedOnboarding;
  final UserRole role; // Added admin role
  final bool isActive; // For account management
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.interests = const [],
    this.hasCompletedOnboarding = false,
    this.role = UserRole.user, // Default to regular user
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Get full name
  String get fullName => '$firstName $lastName'.trim();

  // Get display name (first name + last initial)
  String get displayName {
    if (lastName.isNotEmpty) {
      return '$firstName ${lastName[0]}.';
    }
    return firstName;
  }

  // Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      dateOfBirth: map['dateOfBirth'],
      gender: map['gender'],
      address: map['address'],
      interests: List<String>.from(map['interests'] ?? []),
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
      role: UserRole.values.firstWhere(
            (role) => role.name == (map['role'] ?? 'user'),
        orElse: () => UserRole.user,
      ),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'interests': interests,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'role': role.name,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? address,
    List<String>? interests,
    bool? hasCompletedOnboarding,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      interests: interests ?? this.interests,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, firstName: $firstName, lastName: $lastName, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

enum UserRole {
  user,
  admin,
}
