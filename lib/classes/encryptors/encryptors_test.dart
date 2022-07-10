import 'dart:convert';
import 'dart:typed_data';
import 'rc4.dart';

void main() {
  RC4 obj = RC4("teste");
  List<int> bytes = obj.encodeBytes(utf8.encode("vish deu ruim"));
  Uint8List bytes_corrected = Uint8List.fromList(bytes);
  String data_tmp = obj.decodeBytes((bytes_corrected.toList()));
  print(data_tmp);
}
