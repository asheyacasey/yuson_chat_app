import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String uid, sentBy, message;
  final Timestamp ts;

  ChatMessage(
      {this.uid = '',
        required this.sentBy,
        this.message = '',
        Timestamp? ts})
      : ts = ts ?? Timestamp.now();

  static ChatMessage fromDocumentSnap(DocumentSnapshot snap) {
    Map<String, dynamic> json = snap.data() as Map<String, dynamic>;
    return ChatMessage(
      uid: snap.id,
      sentBy: json['sentBy'] ?? '',
      message: json['message'] ?? '',
      ts: json['ts'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> get json =>
      {'sentBy': sentBy, 'message': message, 'ts': ts};



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
