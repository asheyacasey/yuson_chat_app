import 'package:simple_moment/simple_moment.dart';
import 'package:yuson_chat_app/src/controller/chat_controller.dart';
import 'package:yuson_chat_app/src/models/chat_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yuson_chat_app/src/services/image_service.dart';
import 'package:yuson_chat_app/src/widgets/avatars.dart';
import '../../service_locators.dart';
import 'package:yuson_chat_app/src/controller/auth_controller.dart';
import '../../models/chat_message_model.dart';

class HomeScreen extends StatefulWidget {
  static const String route = 'home-screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _auth = locator<AuthController>();
  final ChatController _chatController = ChatController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFN = FocusNode();
  final ScrollController _scrollController = ScrollController();

  ChatUser? user;

  @override
  void initState() {
    ChatUser.fromUid(uid: FirebaseAuth.instance.currentUser!.uid).then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });
    _chatController.addListener(scrollToBottom);
    super.initState();
  }

  scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 250));
    print('scrolling to bottom');
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        curve: Curves.easeIn, duration: const Duration(milliseconds: 250));
  }

  @override
  void dispose() {
    _chatController.removeListener(scrollToBottom);
    _messageFN.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user != null ? user!.username : '. . .'),
        actions: [
          Builder(builder: (context) {
            return IconButton(
              onPressed: () async {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.menu),
            );
          }),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Row(
                children: [
                  InkWell(
                    onTap: () {ImageService.updateProfileImage();},
                    child: AvatarImage(
                        uid: FirebaseAuth.instance.currentUser!.uid),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  UserNameFromDB(uid: FirebaseAuth.instance.currentUser!.uid)
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: const [
                  Text('Content'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout_sharp),
              title: const Text('Log out'),
              onTap: () async {
                _auth.logout();
              },
            )
          ],
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: AnimatedBuilder(
                  animation: _chatController,
                  builder: (context, Widget? w) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      controller: _scrollController,
                      child: Column(
                        children: [
                          for (ChatMessage chat in _chatController.chats)
                            ChatCard(chat: chat)
                        ],
                      ),
                    );
                  }),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onFieldSubmitted: (String text) {
                        send();
                      },
                      focusNode: _messageFN,
                      controller: _messageController,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.redAccent,
                    ),
                    onPressed: send,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  send() {
    _messageFN.unfocus();
    if (_messageController.text.isNotEmpty) {
      _chatController.sendMessage(message: _messageController.text.trim());
      _messageController.text = '';
    }
  }
}

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.chat,
  }) : super(key: key);

  final ChatMessage chat;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Moment.fromDateTime(chat.ts.toDate()).format('MMMM dd,yyyy hh:mm aa'),
          style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
        ),
        Row(
          children: [
            if (chat.sentBy == FirebaseAuth.instance.currentUser!.uid)
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment:
                      chat.sentBy != FirebaseAuth.instance.currentUser!.uid
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        if (chat.sentBy !=
                            FirebaseAuth.instance.currentUser?.uid)
                          AvatarImage(uid: chat.sentBy, radius: 12,),
                        if (chat.sentBy !=
                            FirebaseAuth.instance.currentUser?.uid)
                          const SizedBox(
                            width: 8,
                          ),
                        if (chat.sentBy ==
                            FirebaseAuth.instance.currentUser?.uid)
                          const Text('You')
                        else
                          UserNameFromDB(uid: chat.sentBy),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      color:
                      chat.sentBy == FirebaseAuth.instance.currentUser!.uid
                          ? Colors.green
                          : Colors.grey[400],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                          const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                      chat.sentBy == FirebaseAuth.instance.currentUser!.uid
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(chat.message),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          'Seen by',
                          style: TextStyle(fontSize: 10),
                        ), const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: chat.sentBy ==
                              FirebaseAuth.instance.currentUser!.uid
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            for(String user in chat.seenBy)
                              Container(margin: const EdgeInsets.symmetric(horizontal: 2),child: AvatarImage(uid: user, radius: 8,))
                            // for (int i = 0; i < chat.seenBy.length; i++)
                            //   if (chat.seenBy[i] ==
                            //       FirebaseAuth.instance.currentUser!.uid)
                            //     Text(
                            //       'You${i != chat.seenBy.length - 1 ? ', ' : ''}',
                            //       style: const TextStyle(fontSize: 10),
                            //     )
                            //   else
                            //     FutureBuilder(
                            //         future:
                            //             ChatUser.fromUid(uid: chat.seenBy[i]),
                            //         builder: (context,
                            //             AsyncSnapshot<ChatUser> snap) {
                            //           if (snap.hasData) {
                            //             return Text(
                            //               '${snap.data?.username}${i != chat.seenBy.length - 1 ? ', ' : ''}',
                            //               style: const TextStyle(fontSize: 10),
                            //             );
                            //           }
                            //           return const Text('');
                            //         }),
                          ],
                        ),
                        if (chat.sentBy ==
                            FirebaseAuth.instance.currentUser!.uid)
                          const SizedBox(
                            height: 8,
                          ),
                        if (chat.sentBy ==
                            FirebaseAuth.instance.currentUser!.uid &&
                            chat.message != 'message deleted')
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 4,
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (dCon) {
                                        return ChatEditingDialog(chat: chat);
                                      });
                                },
                                child: const Icon(
                                  Icons.edit,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              InkWell(
                                onTap: () {
                                  chat.deleteMessage();
                                },
                                child: const Icon(
                                  Icons.delete,
                                  size: 12,
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (chat.sentBy != FirebaseAuth.instance.currentUser!.uid)
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
              ),
          ],
        ),
      ],
    );
  }
}

class ChatEditingDialog extends StatefulWidget {
  final ChatMessage chat;
  const ChatEditingDialog({required this.chat, Key? key}) : super(key: key);

  @override
  State<ChatEditingDialog> createState() => _ChatEditingDialogState();
}

class _ChatEditingDialogState extends State<ChatEditingDialog> {
  late TextEditingController tCon;
  @override
  initState() {
    tCon = TextEditingController(text: widget.chat.message);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit message'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    maxLines: 5,
                    onFieldSubmitted: (String text) {
                      widget.chat.updateMessage('[edited message] ' + text);
                      Navigator.of(context).pop();
                    },
                    controller: tCon,
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    widget.chat.updateMessage('[edited message] ' + tCon.text);
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}