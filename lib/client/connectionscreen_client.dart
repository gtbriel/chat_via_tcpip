import 'package:chat_sg/client/connectionsplashscreen_client.dart';
import 'package:flutter/material.dart';

class ConnectionScreenClient extends StatefulWidget {
  const ConnectionScreenClient({Key? key}) : super(key: key);

  @override
  State<ConnectionScreenClient> createState() => _ConnectionScreenClientState();
}

class _ConnectionScreenClientState extends State<ConnectionScreenClient> {
  final ip_controller = TextEditingController();
  final port_controller = TextEditingController();
  final List<String> encrypts = ['RC4', 'SDES'];
  String? selectedItem = 'RC4';

  @override
  Widget build(BuildContext context) {
    final ip_field = TextFormField(
      autofocus: false,
      controller: ip_controller,
      keyboardType: TextInputType.text,
      onSaved: (value) {
        ip_controller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: 'IPv4',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );

    final port_field = TextFormField(
      autofocus: false,
      controller: port_controller,
      keyboardType: TextInputType.number,
      onSaved: (value) {
        port_controller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: 'Port',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      ip_field,
                      const SizedBox(
                        height: 30,
                      ),
                      port_field,
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  minWidth: MediaQuery.of(context).size.height - 200,
                  height: 60,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConnectionSplashScreenClient(
                                ip_controller.text,
                                port_controller.text,
                                selectedItem!)));
                  },
                  color: Colors.indigoAccent[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: const Text(
                    "Conecte-se",
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
