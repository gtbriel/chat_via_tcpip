abstract class Encryptor {
  List<int> encodeBytes(List<int> bytes);
  String decodeBytes(List<int> bytes);
  String encodeString(String message, [bool encodeBase64 = true]);
  String decodeString(String message, [bool encodedBase64 = true]);
}
