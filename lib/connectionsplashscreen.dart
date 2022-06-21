import 'package:chat_sg/chatscreen.dart';
import 'package:chat_sg/classes/abstract/encryptor.dart';
import 'package:chat_sg/connectionscreen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_rc4/simple_rc4.dart';

class ConnectionSplashScreen extends StatefulWidget {
  final String ip;
  final String port;
  final String encryptor;
  const ConnectionSplashScreen(this.ip, this.port, this.encryptor, {Key? key})
      : super(key: key);

  @override
  State<ConnectionSplashScreen> createState() => _ConnectionSplashScreenState();
}

class _ConnectionSplashScreenState extends State<ConnectionSplashScreen> {
  late FToast fToast;

  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    connect();
  }

  late Socket socket;
  late ServerSocket server;

  connect() async {
    try {
      server = await ServerSocket.bind(
          InternetAddress.anyIPv4, int.parse(widget.port));
      socket = await Socket.connect(widget.ip, int.parse(widget.port));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(server, socket, widget.encryptor)));
    } on SocketException catch (_) {
      _showToast(_.message);
      server.close();
      await Future.delayed(Duration(seconds: 1));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ConnectionScreen()));
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
                      child: Text("Connecting to client...",
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
