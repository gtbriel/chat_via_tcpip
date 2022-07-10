import 'package:chat_sg/client/connectionscreen_client.dart';
import 'package:chat_sg/server/connectionscreen_server.dart';

import 'package:flutter/material.dart';

class ChooseYourPath extends StatelessWidget {
  const ChooseYourPath({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Chat - Segurança Computacional",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Conecte-se a outro usuário pelo protocolo TCP/IP",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 80,
          ),
          const Text(
            "Escolha seu tipo de conexão:",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                minWidth: MediaQuery.of(context).size.height - 400,
                height: 60,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ConnectionScreenServer()));
                },
                color: Colors.indigoAccent[400],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                child: const Text(
                  "Server Mode",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white70),
                ),
              ),
              const SizedBox(
                width: 40,
              ),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.height - 400,
                height: 60,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ConnectionScreenClient()));
                },
                color: Colors.indigoAccent[400],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                child: const Text(
                  "Client Mode",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
