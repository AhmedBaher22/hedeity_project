import 'package:cloud_firestore/cloud_firestore.dart';


import '../database/gift_dao.dart';
import '../models/gift.dart';
import '../models/user.dart';
import 'UserController.dart';

class GiftController {
  final GiftDAO _dao = GiftDAO();

  // Get all gifts
  Future<List<Gift>> getAllGifts() async {
    return await _dao.readAll();
  }

  // Add a new gift
  Future<void> addGift(Gift gift) async {
    await _dao.create(gift);
  }

  // Update an existing gift
  Future<void> updateGift(Gift gift) async {
    await _dao.update(gift);
  }

  // Delete a gift by its ID
  Future<void> deleteGift(int id) async {
    await _dao.delete(id);
  }

  // Get the first 'n' gifts
  Future<List<Gift>> getFirstGifts(int limit) async {
    return await _dao.getFirstGifts(limit);
  }

  Future<List<Gift>> getGiftsByEventId(int eventId) async{
    return await _dao.getGiftsByEventId(eventId);
  }


  Future<void> publishGiftsOnFirebase(String fireBaseEventId) async {
    try {
      // Parse the local event ID from the Firebase event ID
      int localEventId = int.parse(fireBaseEventId.split('_').last);

      // Fetch the gifts related to this event
      List<Gift> gifts = await _dao.getGiftsByEventId(localEventId);

      // Loop through each gift and add it to Firebase
      for (Gift gift in gifts) {
        await _addGiftToEventInFirebase(fireBaseEventId, gift);
      }
      print('All gifts published successfully');
    } catch (e) {
      print('Error publishing event on Firebase: $e');
    }
  }


  Future<void> _addGiftToEventInFirebase(String fireBaseEventId, Gift gift) async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;

      // Check if the gift already exists using the title as a unique identifier
      QuerySnapshot querySnapshot = await db
          .collection('events')
          .doc(fireBaseEventId)
          .collection('gifts')
          .where('title', isEqualTo: gift.title)
          .get();

      // If the gift exists and data is different, update it
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot existingDoc = querySnapshot.docs.first;
        Map<String, dynamic> existingData = existingDoc.data() as Map<String, dynamic>;

        // Compare the existing data with the new gift data and update if different
        bool needsUpdate = false;
        if (existingData['category'] != gift.category ||
            existingData['price'] != gift.price ||
            existingData['isPledged'] != gift.isPledged ||
            existingData['description'] != gift.description) {
          needsUpdate = true;
        }

        if (needsUpdate) {
          await existingDoc.reference.update({
            'category': gift.category,
            'price': gift.price,
            'isPledged': gift.isPledged,
            'description': gift.description,
          });
          print('Gift updated successfully');
        } else {
          print('Gift data is the same, no update required');
        }
      } else {
        // If the gift doesn't exist, add it as a new document
        await db
            .collection('events')
            .doc(fireBaseEventId)
            .collection('gifts')
            .add({
          'title': gift.title,
          'category': gift.category,
          'price': gift.price,
          'isPledged': gift.isPledged,
          'description': gift.description,
        });
        print('Gift added successfully');
      }
    } catch (e) {
      print('Error adding or updating gift: $e');
    }
  }

  Future<List<Gift>> fetchGiftsForEvent(String fireBaseEventId) async {
    try {
      int localEventId = int.parse(fireBaseEventId.split('_').last);
      FirebaseFirestore db = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await db
          .collection('events')
          .doc(fireBaseEventId)
          .collection('gifts')
          .get();

      return snapshot.docs.map((doc) {
        return Gift(
          firebaseId: doc.id,
          title: doc['title'],
          price: doc['price'],
          description: doc['description'],
          category: doc['category'],
          isPledged: doc['isPledged'],
          eventId: localEventId,
        );
      }).toList();
    } catch (e) {
      print('Error fetching gifts: $e');
      return [];
    }
  }


  Future<String> pledgeGift(String eventId, String? giftId) async {
    try {
      UserController userController = UserController();
      UserModel? currentUser = await userController.getCurrentUser();
      String userId = "";
      if(currentUser != null){
        userId = currentUser.uid;
      }
      else{
        return "Connection Error";
      }
      // Get a reference to the Firestore collection for events
      final eventDoc = FirebaseFirestore.instance.collection('events').doc(eventId);

      // Fetch the event document
      final eventSnapshot = await eventDoc.get();
      if (!eventSnapshot.exists) {
        return "Error: Event with ID $eventId does not exist.";
      }

      // Fetch the gifts collection inside the event
      final giftsCollection = eventDoc.collection('gifts');
      final giftDoc = giftsCollection.doc(giftId);

      // Fetch the gift document
      final giftSnapshot = await giftDoc.get();
      if (!giftSnapshot.exists) {
        return "Error: Gift with ID $giftId does not exist in event $eventId.";
      }

      // Check the isPledged attribute
      final giftData = giftSnapshot.data();
      if (giftData == null || giftData['isPledged'] == null) {
        return "Error: Gift with ID $giftId is missing required attributes.";
      }

      if (giftData['isPledged'] == true) {
        return "Error: Gift with ID $giftId is already pledged.";
      }

      // Update the gift to mark it as pledged and add the pledgedBy attribute
      await giftDoc.update({
        'isPledged': true,
        'pledgedBy': userId,
      });

      return "Success: Gift with ID $giftId has been pledged by user $userId.";
    } catch (e) {
      // Handle any errors
      return "Error: ${e.toString()}";
    }
  }


  Future<String> unpledgeGift(String eventId, String? giftId) async {
    try {
      UserController userController = UserController();
      UserModel? currentUser = await userController.getCurrentUser();
      String userId = "";
      if(currentUser != null){
        userId = currentUser.uid;
      }
      else{
        return "Connection Error";
      }
      // Get a reference to the Firestore collection for events
      final eventDoc = FirebaseFirestore.instance.collection('events').doc(eventId);

      // Fetch the event document
      final eventSnapshot = await eventDoc.get();
      if (!eventSnapshot.exists) {
        return "Error: Event with ID $eventId does not exist.";
      }

      // Fetch the gifts collection inside the event
      final giftsCollection = eventDoc.collection('gifts');
      final giftDoc = giftsCollection.doc(giftId);

      // Fetch the gift document
      final giftSnapshot = await giftDoc.get();
      if (!giftSnapshot.exists) {
        return "Error: Gift with ID $giftId does not exist in event $eventId.";
      }

      // Check the isPledged and pledgedBy attributes
      final giftData = giftSnapshot.data();
      if (giftData == null || giftData['isPledged'] == null || giftData['pledgedBy'] == null) {
        return "Error: Gift with ID $giftId is missing required attributes.";
      }

      if (giftData['isPledged'] == false) {
        return "Error: Gift is not currently pledged.";
      }

      if (giftData['pledgedBy'] != userId) {
        return "Error: Gift was not pledged by you.";
      }

      // Update the gift to unpledge it
      await giftDoc.update({
        'isPledged': false,
        'pledgedBy': FieldValue.delete(), // Removes the pledgedBy attribute
      });

      return "Success: Gift has been unpledged.";
    } catch (e) {
      // Handle any errors
      return "Error: ${e.toString()}";
    }
  }


}
