// services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';

  // Create user document
  static Future<void> createUser(UserModel user) async {
    try {
      final now = DateTime.now();
      final userWithTimestamps = user.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      // Convert to map and ensure all fields are included, even if null
      final userMap = userWithTimestamps.toMap();

      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .set(userMap, SetOptions(merge: false)); // Don't merge, create new document
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Create user with registration data
  static Future<void> createUserWithRegistrationData({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final now = DateTime.now();
      final user = UserModel(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        interests: [],
        hasCompletedOnboarding: false,
        createdAt: now,
        updatedAt: now,
      );

      // Create the document with all fields explicitly
      final userMap = user.toMap();

      await _firestore
          .collection(_collection)
          .doc(uid)
          .set(userMap, SetOptions(merge: false));
    } catch (e) {
      throw Exception('Failed to create user with registration data: $e');
    }
  }

  // Get user data
  static Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updatedAt': DateTime.now(),
      };

      // Only add fields that are provided (not null)
      if (firstName != null && firstName.isNotEmpty) {
        updateData['firstName'] = firstName;
      }
      if (lastName != null) {
        updateData['lastName'] = lastName.isEmpty ? null : lastName;
      }
      if (phone != null) {
        updateData['phone'] = phone.isEmpty ? null : phone;
      }
      if (dateOfBirth != null) {
        updateData['dateOfBirth'] = dateOfBirth.isEmpty ? null : dateOfBirth;
      }
      if (gender != null) {
        updateData['gender'] = gender.isEmpty ? null : gender;
      }
      if (address != null) {
        updateData['address'] = address.isEmpty ? null : address;
      }

      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update user interests
  static Future<void> updateUserInterests(String uid, List<String> interests) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'interests': interests,
        'hasCompletedOnboarding': true,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update interests: $e');
    }
  }

  // Update user data
  static Future<void> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .update(updatedUser.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Mark onboarding as completed
  static Future<void> markOnboardingCompleted(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'hasCompletedOnboarding': true,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to mark onboarding as completed: $e');
    }
  }

  // Check if user exists
  static Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Stream user data
  static Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>, uid);
      }
      return null;
    });
  }

  // Delete user
  static Future<void> deleteUser(String uid) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Search users by name or email
  static Future<List<UserModel>> searchUsers(String query) async {
    try {
      // Note: This is a basic implementation. For better search,
      // consider using Algolia or similar search service
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThan: query + 'z')
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}