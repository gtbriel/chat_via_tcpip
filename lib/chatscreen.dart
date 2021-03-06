import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:chat_sg/choose_your_path.dart';
import 'package:chat_sg/classes/abstract/encryptor.dart';
import 'package:chat_sg/classes/chat_message.dart';
import 'package:chat_sg/classes/encryptors/sdes.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'classes/encryptors/rc4.dart';

class ChatScreen extends StatefulWidget {
  final dynamic server;
  final Socket chatClient;
  final String encryptor;
  final Map<String, int> keyDict;
  const ChatScreen(this.server, this.chatClient, this.keyDict, this.encryptor,
      {Key? key})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final message_controller = TextEditingController();
  bool gotKey = false;
  final List<ChatMessage> messages = [];
  final ScrollController _scrollController = ScrollController();
  late Encryptor encryptor;
  late FToast fToast;
  late Socket client;
  late String encryptor_key;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    client = widget.chatClient;
    handleListen();
    key_exchange();
  }

  key_exchange() {
    int G = widget.keyDict['G'] as int;
    int private_key = widget.keyDict['private_key'] as int;
    int partialKey = pow(G, private_key) as int;
    partialKey = partialKey % (widget.keyDict['P'] as int);
    client.add(utf8.encode(partialKey.toString()));
  }

  handleListen() {
    void messageHandler(List<int> data) {
      if (gotKey == false) {
        int publicPartialKey = int.parse(utf8.decode(data));
        publicPartialKey =
            pow(publicPartialKey, (widget.keyDict['private_key'] as int))
                as int;
        publicPartialKey = publicPartialKey % (widget.keyDict['P'] as int);
        encryptor_key = publicPartialKey.toString();
        switch (widget.encryptor) {
          case "RC4":
            encryptor = RC4(encryptor_key);
            break;
          case "SDES":
            String key_str =
                (int.parse(encryptor_key) * int.parse(encryptor_key))
                    .toRadixString(2);
            List<int> key = [];
            for (int i = 0; i < 10; i++) {
              if (i < key_str.length) {
                key.add(int.parse(key_str[i]));
              } else {
                key.add(0);
              }
            }
            encryptor = SDES(key);
            break;
          default:
        }
        setState(() {});
        print(encryptor_key);
        _showToast("Key exchange executed successfully!!");
        gotKey = true;
      } else {
        String message = encryptor.decodeBytes(data);
        ChatMessage newMessage =
            ChatMessage(messageContent: message, messageType: "receiver");
        messages.add(newMessage);
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 10), curve: Curves.easeOut);
        setState(() {});
      }
    }

    void errorHandler(error) {
      print(
          '${client.remoteAddress.address}:${client.remotePort} Error: $error');
      if (widget.server == Null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChooseYourPath()));
      } else {
        widget.server.close();
        widget.chatClient.close();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChooseYourPath()));
      }
    }

    void finishedHandler() {
      print(
          '${client.remoteAddress.address}:${client.remotePort} Disconnected');
      if (widget.server == Null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChooseYourPath()));
      } else {
        widget.server.close();
        widget.chatClient.close();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChooseYourPath()));
      }
    }

    client.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
  }

  _showToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey,
      ),
      child: Text(
        msg,
        style: const TextStyle(color: Colors.white),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final msgField = TextFormField(
      autofocus: false,
      style: const TextStyle(color: Colors.black),
      controller: message_controller,
      keyboardType: TextInputType.text,
      onSaved: (value) {
        message_controller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: 'Write your message here',
          hintStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Connected to ${client.remoteAddress.address}:${client.remotePort}',
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (widget.server == Null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChooseYourPath()));
              } else {
                widget.server.close();
                widget.chatClient.close();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChooseYourPath()));
              }
            },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                itemCount: messages.length + 1,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                    return Container(
                      height: 70,
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.only(
                        left: 14, right: 14, top: 10, bottom: 10),
                    child: Align(
                      alignment: (messages[index].messageType == "receiver"
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (messages[index].messageType == "receiver"
                              ? Colors.grey.shade200
                              : Colors.blue[200]),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          messages[index].messageContent,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Expanded(child: msgField),
                    const SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        ChatMessage newMessage = ChatMessage(
                            messageContent: message_controller.text,
                            messageType: "sender");
                        messages.add(newMessage);
                        _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 10),
                            curve: Curves.easeOut);
                        sendMessage(message_controller.text);
                        message_controller.clear();
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: Colors.blue,
                      elevation: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  sendMessage(String text) {
    List<int> bytes = utf8.encode(text);
    List<int> encryptedBytes = encryptor.encodeBytes(bytes);
    client.add(encryptedBytes);
  }
}
