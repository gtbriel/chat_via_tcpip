import 'package:chat_sg/chatscreen.dart';
import 'package:chat_sg/client/connectionscreen_client.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

class ConnectionSplashScreenClient extends StatefulWidget {
  final String ip;
  final String port;
  final String encryptor;
  const ConnectionSplashScreenClient(this.ip, this.port, this.encryptor,
      {Key? key})
      : super(key: key);

  @override
  State<ConnectionSplashScreenClient> createState() =>
      _ConnectionSplashScreenClientState();
}

class _ConnectionSplashScreenClientState
    extends State<ConnectionSplashScreenClient> {
  late Socket socket;
  late ServerSocket server;
  late FToast fToast;

  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    connect();
  }

  connect() async {
    Map<String, int> dict = {
      'P': 941,
      'G': 627,
      'private_key': 347,
    };
    try {
      Socket.connect(widget.ip, int.parse(widget.port)).then((Socket sock) {
        socket = sock;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(Null, socket, dict, widget.encryptor)));
      });
    } on SocketException catch (_) {
      _showToast(_.message);
      //server.close();
      await Future.delayed(Duration(seconds: 1));
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ConnectionScreenClient()));
    }
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
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text("Connecting to...",
                          style:
                              TextStyle(fontFamily: 'Mate_SC', fontSize: 24)),
                    ),
                    CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                    Padding(padding: EdgeInsets.only(top: 20))
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
