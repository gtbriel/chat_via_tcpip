import 'package:chat_sg/chatscreen.dart';
import 'package:chat_sg/server/connectionscreen_server.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

class ConnectionSplashScreenServer extends StatefulWidget {
  final String encryptor;
  const ConnectionSplashScreenServer(this.encryptor, {Key? key})
      : super(key: key);

  @override
  State<ConnectionSplashScreenServer> createState() =>
      _ConnectionSplashScreenServerState();
}

class _ConnectionSplashScreenServerState
    extends State<ConnectionSplashScreenServer> {
  late FToast fToast;
  late Socket socket;
  late ServerSocket server;
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    connect();
  }

  connect() async {
    Map<String, int> dict = {
      'P': 97,
      'G': 5,
      'private_key': 15,
    };
    try {
      ServerSocket server =
          await ServerSocket.bind(InternetAddress.anyIPv4, 3000);
      print("Server connected");
      server.listen((client) {
        print('Connection from '
            '${client.remoteAddress.address}:${client.remotePort}');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(server, client, dict, "RC4")));
      });
    } on SocketException catch (_) {
      _showToast(_.message);
      //server.close();
      await Future.delayed(Duration(seconds: 1));
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ConnectionScreenServer()));
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
                      child: Text("Waiting connection from client...",
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
