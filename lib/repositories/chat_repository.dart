import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class ChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<ChatMessage>> getMessages(String roomId) {
    return _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
          final messages = <ChatMessage>[];

          for (final doc in snapshot.docs) {
            final messageData = doc.data();
            final message = ChatMessage.fromMap(messageData, doc.id);
            messages.add(message);
          }

          return messages;
        });
  }

  Future<void> sendMessage(String roomId, ChatMessage message) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final userDoc = await _db.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();

      final messageWithSender = message.copyWith(
        senderName: userData?['name'] ?? 'Unknown User',
        senderPhoto: userData?['file_url'] ?? '',
        readBy: [currentUser.uid],
      );

      final messageRef = _db
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .doc();

      final data = messageWithSender.toMap();

      if (message.pollData != null) {
        data['pollData'] = {
          'question': message.pollData!['question'],
          'options': message.pollData!['options'],
          'allowMultiple': message.pollData!['allowMultiple'] ?? false,
          'votes': {},
        };
      }

      await messageRef.set(data);

      await _db.collection('chatRooms').doc(roomId).update({
        'lastMessage': _getLastMessageText(message),
        'lastMediaType': message.mediaType,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  String _getLastMessageText(ChatMessage message) {
    if (message.text.isNotEmpty) return message.text;
    if (message.mediaType == "image") return "[Image]";
    if (message.mediaType == "video") return "[Video]";
    if (message.mediaType == "gif") return "[GIF]";
    if (message.mediaType == "poll") return "[Poll]";
    return "[Attachment]";
  }

  Future<void> updateMessage(
    String roomId,
    String messageId,
    String newText,
  ) async {
    final msgRef = _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId);

    await msgRef.update({
      'text': newText,
      'isEdited': true,
      'editedAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('chatRooms').doc(roomId).update({
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': newText,
    });
  }

  Future<void> deleteMessage(String roomId, String messageId) async {
    final msgRef = _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId);

    final doc = await msgRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      final mediaUrl = data['mediaUrl'] as String?;
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(mediaUrl);
          await ref.delete();
        } catch (e) {
          debugPrint("⚠️ Failed to delete media: $e");
        }
      }
    }

    await msgRef.delete();

    await _db.collection('chatRooms').doc(roomId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ChatRoom>> getChatRooms(String userId) {
    return _db
        .collection('chatRooms')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatRoom.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<String> getOrCreateChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final existing = await _db
        .collection('chatRooms')
        .where('participantIds', arrayContains: currentUserId)
        .get();

    for (final doc in existing.docs) {
      final ids = List<String>.from(doc['participantIds']);
      if (ids.contains(otherUserId) && doc['isGroup'] != true) {
        return doc.id;
      }
    }

    final newRoom = await _db.collection('chatRooms').add({
      'participantIds': [currentUserId, otherUserId],
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
      'isGroup': false,
    });

    return newRoom.id;
  }

  Future<void> updateGroupDescription(
    String roomId,
    String description,
    String updatedByUserId,
  ) async {
    await _db.collection('chatRooms').doc(roomId).update({
      'groupDescription': description,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final userDoc = await _db.collection('users').doc(updatedByUserId).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown User';

    final systemMessage = ChatMessage(
      id: '',
      senderId: 'system',
      senderName: 'System',
      senderPhoto: '',
      text: '$userName updated the group description',
      timestamp: DateTime.now(),
      isSystemMessage: true,
    );

    await sendMessage(roomId, systemMessage);
  }

  Future<void> updateGroupInfo({
    required String roomId,
    required String newName,
    required String updatedByUserId,
    String? newDescription,
    String? newPhotoUrl,
  }) async {
    final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
    if (!roomDoc.exists) throw Exception('Group not found');

    final currentData = roomDoc.data()!;
    final currentName = currentData['groupName'] as String? ?? '';
    final currentDescription = currentData['groupDescription'] as String? ?? '';
    final currentPhotoUrl = currentData['groupPhotoUrl'] as String? ?? '';

    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final changes = <String>[];

    if (newName != currentName) {
      updateData['groupName'] = newName;
      changes.add('name');
    }

    if (newDescription != currentDescription) {
      updateData['groupDescription'] = newDescription ?? '';
      changes.add('description');
    }

    if (newPhotoUrl != currentPhotoUrl && newPhotoUrl != null) {
      updateData['groupPhotoUrl'] = newPhotoUrl;
      changes.add('photo');
    }

    if (changes.isEmpty) return;

    await _db.collection('chatRooms').doc(roomId).update(updateData);

    final userDoc = await _db.collection('users').doc(updatedByUserId).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown User';

    String actionText;
    if (changes.length == 1) {
      switch (changes[0]) {
        case 'name':
          actionText = '$userName updated the group name';
          break;
        case 'description':
          actionText = '$userName updated the group description';
          break;
        case 'photo':
          actionText = '$userName updated the group photo';
          break;
        default:
          actionText = '$userName updated the group';
      }
    } else if (changes.length == 2) {
      if (changes.contains('name') && changes.contains('description')) {
        actionText = '$userName updated the group name and description';
      } else if (changes.contains('name') && changes.contains('photo')) {
        actionText = '$userName updated the group name and photo';
      } else {
        actionText = '$userName updated the group description and photo';
      }
    } else {
      actionText = '$userName updated the group name, description, and photo';
    }

    final systemMessage = ChatMessage(
      id: '',
      senderId: 'system',
      senderName: 'System',
      senderPhoto: '',
      text: actionText,
      timestamp: DateTime.now(),
      isSystemMessage: true,
    );

    await sendMessage(roomId, systemMessage);
  }

  Future<String> createGroupChat({
    required String creatorId,
    required String groupName,
    required List<String> memberIds,
    String? groupDescription,
    String? groupPhotoUrl,
  }) async {
    final allParticipants = {...memberIds, creatorId}.toList();

    final newRoom = await _db.collection('chatRooms').add({
      'participantIds': allParticipants,
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
      'isGroup': true,
      'groupName': groupName,
      'groupDescription': groupDescription ?? '',
      'groupPhotoUrl': groupPhotoUrl ?? '',
      'createdBy': creatorId,
      'admins': [creatorId],
    });

    final userDoc = await _db.collection('users').doc(creatorId).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown User';

    final systemMessage = ChatMessage(
      id: '',
      senderId: 'system',
      senderName: 'System',
      senderPhoto: '',
      text: '$userName created the group "$groupName"',
      timestamp: DateTime.now(),
      isSystemMessage: true,
    );

    await sendMessage(newRoom.id, systemMessage);

    return newRoom.id;
  }

  Future<void> addMembersToGroup(
    String roomId,
    List<String> newMemberIds,
    String addedByUserId,
  ) async {
    final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
    if (!roomDoc.exists) throw Exception('Group not found');

    final currentMembers = List<String>.from(
      roomDoc.data()!['participantIds'] ?? [],
    );
    final updatedMembers = [
      ...currentMembers,
      ...newMemberIds,
    ].toSet().toList();

    await _db.collection('chatRooms').doc(roomId).update({
      'participantIds': updatedMembers,
    });

    final userDoc = await _db.collection('users').doc(addedByUserId).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown User';

    final systemMessage = ChatMessage(
      id: '',
      senderId: 'system',
      senderName: 'System',
      senderPhoto: '',
      text: '$userName added ${newMemberIds.length} member(s) to the group',
      timestamp: DateTime.now(),
      isSystemMessage: true,
    );

    await sendMessage(roomId, systemMessage);
  }

  Future<void> removeMemberFromGroup(String roomId, String memberId) async {
    final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
    if (!roomDoc.exists) throw Exception('Group not found');

    final currentMembers = List<String>.from(
      roomDoc.data()!['participantIds'] ?? [],
    );
    final updatedMembers = currentMembers
        .where((id) => id != memberId)
        .toList();

    await _db.collection('chatRooms').doc(roomId).update({
      'participantIds': updatedMembers,
    });
  }

  Future<void> deleteGroup(String roomId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
      if (!roomDoc.exists) throw Exception('Group not found');

      final createdBy = roomDoc.data()?['createdBy'] as String?;
      if (createdBy != currentUser.uid) {
        throw Exception('Only the group creator can delete the group');
      }

      final messagesSnapshot = await _db
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .get();

      final storage = FirebaseStorage.instance;
      for (final messageDoc in messagesSnapshot.docs) {
        final messageData = messageDoc.data();
        final mediaUrl = messageData['mediaUrl'] as String?;

        if (mediaUrl != null && mediaUrl.isNotEmpty) {
          try {
            final ref = storage.refFromURL(mediaUrl);
            await ref.delete();
          } catch (e) {
            debugPrint("⚠️ Failed to delete media: $e");
          }
        }
      }

      final batch = _db.batch();
      for (final messageDoc in messagesSnapshot.docs) {
        batch.delete(messageDoc.reference);
      }
      await batch.commit();

      await _db.collection('chatRooms').doc(roomId).delete();
    } catch (e) {
      debugPrint('Error deleting group: $e');
      rethrow;
    }
  }

  Future<void> leaveGroup(String roomId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
      if (!roomDoc.exists) throw Exception('Group not found');

      final currentMembers = List<String>.from(
        roomDoc.data()!['participantIds'] ?? [],
      );
      final updatedMembers = currentMembers
          .where((id) => id != currentUser.uid)
          .toList();

      if (updatedMembers.isEmpty) {
        await _db.collection('chatRooms').doc(roomId).delete();
      } else {
        await _db.collection('chatRooms').doc(roomId).update({
          'participantIds': updatedMembers,
        });

        final userDoc = await _db
            .collection('users')
            .doc(currentUser.uid)
            .get();
        final userName = userDoc.data()?['name'] ?? 'Unknown User';

        final systemMessage = ChatMessage(
          id: '',
          senderId: 'system',
          senderName: 'System',
          senderPhoto: '',
          text: '$userName left the group',
          timestamp: DateTime.now(),
          isSystemMessage: true,
        );

        await sendMessage(roomId, systemMessage);
      }
    } catch (e) {
      debugPrint('Error leaving group: $e');
      rethrow;
    }
  }

  Future<void> updatePollVote({
    required String roomId,
    required String messageId,
    required List<int> selectedIndexes,
    required bool allowMultiple,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId);

    try {
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final pollData = data['pollData'] ?? {};
        final rawOptions = pollData['options'] as List?;
        final options =
            rawOptions
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];

        final votes = Map<String, dynamic>.from(pollData['votes'] ?? {});
        final previousVotes = (votes[user.uid] as List?)?.cast<int>() ?? [];

        if (!allowMultiple &&
            previousVotes.isNotEmpty &&
            !selectedIndexes.contains(previousVotes.first)) {
          final prevIndex = previousVotes.first;
          if (prevIndex < options.length &&
              (options[prevIndex]['votes'] as int) > 0) {
            options[prevIndex]['votes'] =
                (options[prevIndex]['votes'] as int) - 1;
          }
        }

        for (final index in selectedIndexes) {
          if (index < options.length && !previousVotes.contains(index)) {
            options[index]['votes'] = (options[index]['votes'] as int) + 1;
          }
        }

        if (allowMultiple) {
          for (final prevIndex in previousVotes) {
            if (!selectedIndexes.contains(prevIndex) &&
                prevIndex < options.length &&
                (options[prevIndex]['votes'] as int) > 0) {
              options[prevIndex]['votes'] =
                  (options[prevIndex]['votes'] as int) - 1;
            }
          }
        }

        votes[user.uid] = selectedIndexes;

        transaction.update(docRef, {
          'pollData.options': options,
          'pollData.votes': votes,
        });
      });
    } catch (e, st) {
      debugPrint("⚠️ updatePollVote crashed: $e\n$st");
    }
  }

  Future<Map<String, dynamic>?> getChatRoomInfo(String roomId) async {
    try {
      final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
      if (!roomDoc.exists) return null;
      return roomDoc.data();
    } catch (e) {
      debugPrint('Error getting chat room info: $e');
      return null;
    }
  }

  Future<bool> isGroupChat(String roomId) async {
    try {
      final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
      if (!roomDoc.exists) return false;
      return roomDoc.data()?['isGroup'] == true;
    } catch (e) {
      debugPrint('Error checking if group chat: $e');
      return false;
    }
  }

  Future<List<String>> getChatRoomMembers(String roomId) async {
    try {
      final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
      if (!roomDoc.exists) return [];
      final participantIds = roomDoc.data()?['participantIds'] as List?;
      return participantIds?.cast<String>() ?? [];
    } catch (e) {
      debugPrint('Error getting chat room members: $e');
      return [];
    }
  }

  Future<bool> isGroupAdmin(String roomId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
      if (!roomDoc.exists) return false;

      final admins = List<String>.from(roomDoc.data()?['admins'] ?? []);
      return admins.contains(currentUser.uid);
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  Future<void> markMessageAsRead(
    String roomId,
    String messageId,
    String userId,
  ) async {
    try {
      final messageRef = _db
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .doc(messageId);

      await messageRef.update({
        'readBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      debugPrint('Error marking message as read: $e');
      rethrow;
    }
  }

  Future<void> markAllMessagesAsRead(String roomId, String userId) async {
    try {
      final unreadMessages = await _db
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .where('readBy', arrayContains: userId)
          .get();

      final batch = _db.batch();

      for (final doc in unreadMessages.docs) {
        final messageRef = _db
            .collection('chatRooms')
            .doc(roomId)
            .collection('messages')
            .doc(doc.id);
        batch.update(messageRef, {
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all messages as read: $e');
      rethrow;
    }
  }

  Stream<int> getUnreadMessageCount(String roomId, String userId) {
    return _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('readBy', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<DateTime?> getLastReadTimestamp(String roomId, String userId) async {
    try {
      final lastReadMessage = await _db
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .where('readBy', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (lastReadMessage.docs.isNotEmpty) {
        return (lastReadMessage.docs.first.data()['timestamp'] as Timestamp)
            .toDate();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting last read timestamp: $e');
      return null;
    }
  }

  Stream<List<ChatMessage>> getMediaMessages(
    String roomId, {
    List<String> mediaTypes = const ['image', 'video', 'gif'],
  }) {
    return _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .where('mediaType', whereIn: mediaTypes)
        .where('mediaUrl', isNotEqualTo: null)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final messages = <ChatMessage>[];

          for (final doc in snapshot.docs) {
            final messageData = doc.data();
            final message = ChatMessage.fromMap(messageData, doc.id);
            messages.add(message);
          }

          return messages;
        });
  }

  Future<List<ChatMessage>> getMediaMessagesOnce(
    String roomId, {
    List<String> mediaTypes = const ['image', 'video', 'gif'],
  }) async {
    try {
      final snapshot = await _db
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .where('mediaType', whereIn: mediaTypes)
          .where('mediaUrl', isNotEqualTo: null)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final messageData = doc.data();
        return ChatMessage.fromMap(messageData, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting media messages: $e');
      return [];
    }
  }

  Future<List<String>> getGroupAdmins(String roomId) async {
    try {
      final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
      if (!roomDoc.exists) return [];
      final admins = roomDoc.data()?['admins'] as List?;
      return admins?.cast<String>() ?? [];
    } catch (e) {
      debugPrint('Error getting group admins: $e');
      return [];
    }
  }

  Future<void> makeMembersAsAdmin(
    String roomId,
    List<String> memberIds,
    String updatedByUserId,
  ) async {
    final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
    if (!roomDoc.exists) throw Exception('Group not found');

    final currentAdmins = List<String>.from(roomDoc.data()?['admins'] ?? []);
    final updatedAdmins = {...currentAdmins, ...memberIds}.toList();

    await _db.collection('chatRooms').doc(roomId).update({
      'admins': updatedAdmins,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final userDoc = await _db.collection('users').doc(updatedByUserId).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown User';

    final promotedUsers = await Future.wait(
      memberIds.map((id) => _db.collection('users').doc(id).get()),
    );
    final promotedUserNames = promotedUsers
        .map((doc) => doc.data()?['name'] ?? 'Unknown User')
        .join(', ');

    final systemMessage = ChatMessage(
      id: '',
      senderId: 'system',
      senderName: 'System',
      senderPhoto: '',
      text: '$userName promoted $promotedUserNames to admin',
      timestamp: DateTime.now(),
      isSystemMessage: true,
    );

    await sendMessage(roomId, systemMessage);
  }

  Future<void> removeMembersFromAdmin(
    String roomId,
    List<String> memberIds,
    String updatedByUserId,
  ) async {
    final roomDoc = await _db.collection('chatRooms').doc(roomId).get();
    if (!roomDoc.exists) throw Exception('Group not found');

    final currentAdmins = List<String>.from(roomDoc.data()?['admins'] ?? []);
    final updatedAdmins = currentAdmins
        .where((id) => !memberIds.contains(id))
        .toList();

    await _db.collection('chatRooms').doc(roomId).update({
      'admins': updatedAdmins,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final userDoc = await _db.collection('users').doc(updatedByUserId).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown User';

    final demotedUsers = await Future.wait(
      memberIds.map((id) => _db.collection('users').doc(id).get()),
    );
    final demotedUserNames = demotedUsers
        .map((doc) => doc.data()?['name'] ?? 'Unknown User')
        .join(', ');

    final systemMessage = ChatMessage(
      id: '',
      senderId: 'system',
      senderName: 'System',
      senderPhoto: '',
      text: '$userName removed admin privileges from $demotedUserNames',
      timestamp: DateTime.now(),
      isSystemMessage: true,
    );

    await sendMessage(roomId, systemMessage);
  }
}
