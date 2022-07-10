import 'dart:convert';
import 'dart:io';
import 'package:chat_sg/choose_your_path.dart';
import 'package:chat_sg/classes/abstract/encryptor.dart';
import 'package:chat_sg/classes/chat_message.dart';
import 'package:flutter/material.dart';

import 'classes/encryptors/rc4.dart';

class ChatScreen extends StatefulWidget {
  final dynamic server;
  final Socket chat_client;
  final String encryptor;
  const ChatScreen(this.server, this.chat_client, this.encryptor, {Key? key})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final message_controller = TextEditingController();

  final List<ChatMessage> messages = [];
  final ScrollController _scrollController = ScrollController();
  late Encryptor encryptor;
  late Socket client;

  @override
  void initState() {
    super.initState();
    switch (widget.encryptor) {
      case "RC4":
        encryptor = RC4("teste");
        break;
      default:
    }
    client = widget.chat_client;
    handleListen();
  }

  handleListen() {
    void messageHandler(List<int> data) {
      String message = encryptor.decodeBytes(data);
      ChatMessage new_message =
          ChatMessage(messageContent: message, messageType: "receiver");
      messages.add(new_message);
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 10), curve: Curves.easeOut);
      setState(() {});
    }

    void errorHandler(error) {
      print(
          '${client.remoteAddress.address}:${client.remotePort} Error: $error');
      if (widget.server == Null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChooseYourPath()));
      } else {
        widget.server.close();
        widget.chat_client.close();
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
        widget.chat_client.close();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChooseYourPath()));
      }
    }

    client.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
  }

  @override
  Widget build(BuildContext context) {
    final msg_field = TextFormField(
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
                widget.chat_client.close();
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
                    Expanded(child: msg_field),
                    const SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        ChatMessage new_message = ChatMessage(
                            messageContent: message_controller.text,
                            messageType: "sender");
                        messages.add(new_message);
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
    client.write(encryptedBytes);
  }
}
