import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Initialize messaging and request permissions
  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token for this device
      String? token = await _fcm.getToken();
      
      // Save the token to the user's document
      if (token != null && _auth.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'fcmToken': token});
      }

      // Handle token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        if (_auth.currentUser != null) {
          _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .update({'fcmToken': newToken});
        }
      });

      // Handle incoming messages when the app is in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      });
    }
  }

  // Send a message to another user
  Future<bool> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    String? propertyId,
  }) async {
    try {
      // Create a conversation ID that is the same regardless of who sends the message
      final List<String> ids = [senderId, receiverId];
      ids.sort(); // Sort to ensure the same conversation ID
      final String conversationId = ids.join('_');

      // Add message to the conversation
      await _firestore.collection('conversations').doc(conversationId).collection('messages').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'propertyId': propertyId,
      });

      // Update the conversation metadata
      await _firestore.collection('conversations').doc(conversationId).set({
        'participants': [senderId, receiverId],
        'lastMessage': message,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'lastMessageSenderId': senderId,
        'propertyId': propertyId,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Get all conversations for a user
  Stream<List<Map<String, dynamic>>> getUserConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  // Get messages for a specific conversation
  Stream<List<Map<String, dynamic>>> getConversationMessages(String userId, String otherUserId) {
    // Create the conversation ID
    final List<String> ids = [userId, otherUserId];
    ids.sort();
    final String conversationId = ids.join('_');

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String userId, String otherUserId) async {
    // Create the conversation ID
    final List<String> ids = [userId, otherUserId];
    ids.sort();
    final String conversationId = ids.join('_');

    // Get unread messages sent by the other user
    final QuerySnapshot unreadMessages = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('senderId', isEqualTo: otherUserId)
        .where('read', isEqualTo: false)
        .get();

    // Mark each message as read
    final WriteBatch batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
  }

  // Delete a conversation
  Future<bool> deleteConversation(String userId, String otherUserId) async {
    try {
      // Create the conversation ID
      final List<String> ids = [userId, otherUserId];
      ids.sort();
      final String conversationId = ids.join('_');

      // Get all messages in the conversation
      final QuerySnapshot messages = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      // Delete all messages
      final WriteBatch batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete the conversation document
      batch.delete(_firestore.collection('conversations').doc(conversationId));

      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
  }
}