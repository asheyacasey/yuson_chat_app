import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String uid, sentBy, message;
  final List<String> seenBy;
  final Timestamp ts;

  ChatMessage(
      {this.uid = '',
      required this.sentBy,
      this.message = '',
      this.seenBy = const [],
      Timestamp? ts})
      : ts = ts ?? Timestamp.now();

  static ChatMessage fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return ChatMessage(
      uid: snap.id,
      sentBy: json['sentBy'] ?? '',
      seenBy: json['seenBy'] != null
          ? List<String>.from(json['seenBy'])
          : <String>[],
      message: json['message'] ?? '',
      ts: json['ts'] ?? Timestamp.now(),
    );
  }

  bool hasNotSeenMessage(String uid) {
    return !seenBy.contains(uid);
  }

  Future updateSeen(String userUid) {
    return FirebaseFirestore.instance.collection('chats').doc(uid).update({
      'seenBy': FieldValue.arrayUnion([userUid])
    });
  }

  Future updateMessage(String newMessage){
    return FirebaseFirestore.instance.collection('chats').doc(uid).update({
      'message': newMessage
    });
  }

  Future deleteMessage(){
    return updateMessage('message deleted');
  }





  Map<String, dynamic> get json =>
      {'sentBy': sentBy, 'seenBy': seenBy, 'message': message, 'ts': ts};

  static List<ChatMessage> fromQuerySnap(QuerySnapshot snap) {
    try {
      return snap.docs.map(ChatMessage.fromDocumentSnap).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Stream<List<ChatMessage>> currentChats() => FirebaseFirestore.instance
      .collection('chats')
      .orderBy('ts')
      .snapshots()
      .map(ChatMessage.fromQuerySnap);
}
