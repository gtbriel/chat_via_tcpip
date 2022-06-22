import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:chat_sg/classes/abstract/encryptor.dart';
import 'package:chat_sg/classes/chat_message.dart';
import 'package:chat_sg/connectionscreen.dart';
import 'package:flutter/material.dart';

import 'classes/encryptors/rc4.dart';

class ChatScreen extends StatefulWidget {
  final ServerSocket server;
  final Socket socket;
  final String encryptor;
  const ChatScreen(this.server, this.socket, this.encryptor, {Key? key})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final message_controller = TextEditingController();

  final List<ChatMessage> messages = [];
  final ScrollController _scrollController = ScrollController();
  late String encryptor_key;

  @override
  void initState() {
    super.initState();

    encryptor_key = widget.encryptor;

    widget.socket.listen(
      // handle data from the server
      (Uint8List data) {
        final serverResponse = String.fromCharCodes(data);
        print('Server: $serverResponse');
      },

      // handle errors
      onError: (error) {
        print(error);
        widget.socket.destroy();
      },

      // handle server ending connection
      onDone: () {
        print('Server left.');
        widget.socket.destroy();
      },
    );

    widget.server.listen((client) {
      handleConnection(client);
    });
  }

  void handleConnection(Socket client) {
    print('Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}');

    // listen for events from the client
    client.listen(
      // handle data from the client
      (Uint8List data) async {
        await Future.delayed(Duration(seconds: 1));
        RC4 obj = RC4(encryptor_key);
        String data_tmp = obj.decodeBytes((data.toList()));
        ChatMessage new_message =
            ChatMessage(messageContent: data_tmp, messageType: "receiver");
        messages.add(new_message);
        setState(() {});
      },

      // handle errors
      onError: (error) {
        print(error);
        client.close();
      },

      // handle the client closing the connection
      onDone: () {
        print('Client left');
        client.close();
      },
    );
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
            'Connected to'
            ' ${widget.socket.remoteAddress.address}:${widget.socket.remotePort}',
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.socket.destroy();
              widget.server.close();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ConnectionScreen()));
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
                        sendMessage(widget.socket, message_controller.text);
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

  Future<void> sendMessage(Socket socket, String message) async {
    RC4 obj = RC4(encryptor_key);
    List<int> bytes = obj.encodeBytes(utf8.encode(message));
    socket.add(bytes);
    await Future.delayed(Duration(seconds: 2));
  }
}
