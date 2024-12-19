import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/User.dart';

class UserDAO {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch a user by UserModelId
  Future<UserModel?> getUserByUserModelId(String UserModelId) async {
    final doc = await _firestore.collection('users').doc(UserModelId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc.data()!);
    }
    return null;
  }

  // Check if phone number exists
  Future<bool> isPhoneNumberUnique(String phoneNumber) async {
    final query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    return query.docs.isEmpty; // True if no documents match
  }

  Future<bool> isEmailUnique(String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isEmpty; // Returns true if no matching email is found
    } catch (e) {
      print('Error checking email uniqueness: $e');
      return false;
    }
  }

  // Add a new user
  Future<void> addUser(UserModel user) async {
    await _firestore.collection('users').doc(user.UserModelId).set(user.toFirestore());
  }

  Future<bool> setName(String UserModelId, String name) async{
    try {
      if (name.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(UserModelId)
            .update({'name': name});
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<bool> setPhoneNumber(String UserModelId, String phone) async {
    try {
      if (phone.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(UserModelId)
            .update({'phone': phone});
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}
