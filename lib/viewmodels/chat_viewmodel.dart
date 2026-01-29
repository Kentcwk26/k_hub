import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatMessage>> getMessages(String roomId) {
    return _chatRepository.getMessages(roomId);
  }

  Future<void> sendMessage(String roomId, ChatMessage message) async {
    await _chatRepository.sendMessage(roomId, message);
  }

  Future<void> updateMessage(String roomId, String messageId, String newText) async {
    await _chatRepository.updateMessage(roomId, messageId, newText);
    notifyListeners();
  }

  Future<void> deleteMessage(String roomId, String messageId) async {
    await _chatRepository.deleteMessage(roomId, messageId);
    notifyListeners();
  }

  Future<void> updatePollVote({
    required String roomId,
    required String messageId,
    required List<int> selectedIndexes,
    required bool allowMultiple,
  }) async {
    await _chatRepository.updatePollVote(
      roomId: roomId,
      messageId: messageId,
      selectedIndexes: selectedIndexes,
      allowMultiple: allowMultiple,
    );
    notifyListeners();
  }

  Stream<List<ChatRoom>> getChatRooms(String userId) {
    return _chatRepository.getChatRooms(userId);
  }

  Future<String> createOrGetChatRoom(String currentUserId, String otherUserId) {
    return _chatRepository.getOrCreateChatRoom(currentUserId, otherUserId);
  }

  Future<String> createGroupChat({
    required String creatorId,
    required String groupName,
    required List<String> memberIds,
    String? groupDescription,
    String? groupPhotoUrl,
  }) {
    return _chatRepository.createGroupChat(
      creatorId: creatorId,
      groupName: groupName,
      memberIds: memberIds,
      groupDescription: groupDescription,
      groupPhotoUrl: groupPhotoUrl,
    );
  }

  Future<void> updateGroupDescription(String roomId, String description, String updatedByUserId) async {
    await _chatRepository.updateGroupDescription(roomId, description, updatedByUserId);
    notifyListeners();
  }

  Future<void> updateGroupInfo({
    required String roomId,
    required String newName,
    required String updatedByUserId,
    String? newDescription,
    String? newPhotoUrl,
  }) async {
    await _chatRepository.updateGroupInfo(
      roomId: roomId,
      newName: newName,
      updatedByUserId: updatedByUserId,
      newDescription: newDescription,
      newPhotoUrl: newPhotoUrl,
    );
    notifyListeners();
  }

  Future<void> addMembersToGroup(String roomId, List<String> newMemberIds, String addedByUserId) async {
    await _chatRepository.addMembersToGroup(roomId, newMemberIds, addedByUserId);
    notifyListeners();
  }

  Future<void> removeMemberFromGroup(String roomId, String memberId) async {
    await _chatRepository.removeMemberFromGroup(roomId, memberId);
    notifyListeners();
  }

  Future<void> leaveGroup(String roomId) async {
    await _chatRepository.leaveGroup(roomId);
    notifyListeners();
  }

  Future<bool> isGroupCreator(String roomId) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      if (currentUser == null) return false;

      final roomDoc = await _firestore.collection('chatRooms').doc(roomId).get();
      if (!roomDoc.exists) return false;

      final createdBy = roomDoc.data()?['createdBy'] as String?;
      return createdBy == currentUser.uid;
    } catch (e) {
      debugPrint('Error checking group creator status: $e');
      return false;
    }
  }

  Future<void> deleteGroup(String roomId) async {
    await _chatRepository.deleteGroup(roomId);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getChatRoomInfo(String roomId) async {
    return _chatRepository.getChatRoomInfo(roomId);
  }

  Future<bool> isGroupChat(String roomId) async {
    return _chatRepository.isGroupChat(roomId);
  }

  Future<List<String>> getChatRoomMembers(String roomId) async {
    return _chatRepository.getChatRoomMembers(roomId);
  }

  Future<bool> isGroupAdmin(String roomId) async {
    return _chatRepository.isGroupAdmin(roomId);
  }

  Stream<List<ChatRoom>> getUserGroups(String userId) {
    return _firestore
      .collection('chatRooms')
      .where('participantIds', arrayContains: userId)
      .where('isGroup', isEqualTo: true)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => ChatRoom.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> markMessageAsRead(String roomId, String messageId, String userId) async {
    await _chatRepository.markMessageAsRead(roomId, messageId, userId);
    notifyListeners();
  }

  Future<void> markAllMessagesAsRead(String roomId, String userId) async {
    await _chatRepository.markAllMessagesAsRead(roomId, userId);
    notifyListeners();
  }

  Stream<int> getUnreadMessageCount(String roomId, String userId) {
    return _chatRepository.getUnreadMessageCount(roomId, userId);
  }

  Future<DateTime?> getLastReadTimestamp(String roomId, String userId) async {
    return _chatRepository.getLastReadTimestamp(roomId, userId);
  }

  bool isMessageReadByUser(ChatMessage message, String userId) {
    return message.readBy.contains(userId);
  }

  String getReadStatus(ChatMessage message, List<String> participantIds) {
    final readCount = message.readBy.length;
    final totalParticipants = participantIds.length;
    
    if (readCount == totalParticipants) {
      return 'Seen by all';
    } else if (readCount > 1) {
      return 'Seen by $readCount people';
    } else if (readCount == 1 && message.readBy.contains(message.senderId)) {
      return 'Sent';
    } else {
      return 'Delivered';
    }
  }

  Stream<List<ChatMessage>> getMediaMessages(String roomId) {
    return _chatRepository.getMediaMessages(roomId);
  }

  Future<List<ChatMessage>> getMediaMessagesOnce(String roomId) async {
    return _chatRepository.getMediaMessagesOnce(roomId);
  }

  Future<List<String>> getGroupAdmins(String roomId) async {
    return _chatRepository.getGroupAdmins(roomId);
  }

  Future<void> makeMembersAsAdmin(String roomId, List<String> memberIds) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');
    
    await _chatRepository.makeMembersAsAdmin(roomId, memberIds, currentUser.uid);
    notifyListeners();
  }

  Future<void> removeMembersFromAdmin(String roomId, List<String> memberIds) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');
    
    await _chatRepository.removeMembersFromAdmin(roomId, memberIds, currentUser.uid);
    notifyListeners();
  }

}