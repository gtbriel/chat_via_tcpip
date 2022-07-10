import 'package:chat_sg/server/connectionsplashscreen_server.dart';
import 'package:flutter/material.dart';

class ConnectionScreenServer extends StatefulWidget {
  const ConnectionScreenServer({Key? key}) : super(key: key);

  @override
  State<ConnectionScreenServer> createState() => _ConnectionScreenServerState();
}

class _ConnectionScreenServerState extends State<ConnectionScreenServer> {
  final ip_controller = TextEditingController();
  final port_controller = TextEditingController();
  final List<String> encrypts = ['RC4'];
  String? selectedItem = 'RC4';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Column(
                  children: const [
                    Text(
                      "Chat - Segurança Computacional",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Conecte-se a outro usuário pelo protocolo TCP/IP",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
                MaterialButton(
                  minWidth: MediaQuery.of(context).size.height - 200,
                  height: 60,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ConnectionSplashScreenServer(selectedItem!)));
                  },
                  color: Colors.indigoAccent[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: const Text(
                    "Inicie o Servidor",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white70),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButton<String>(
                  value: selectedItem,
                  items: encrypts
                      .map((e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (item) => setState(() {
                    selectedItem = item;
                  }),
                )
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
