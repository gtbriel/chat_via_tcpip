import 'dart:io';
import 'dart:typed_data';

class SDES {
  final List<int> key;

  final List<int> P10 = [3, 5, 2, 7, 4, 10, 1, 9, 8, 6];
  final List<int> P8 = [6, 3, 7, 4, 8, 5, 10, 9];

  final List<int> key1 = [];
  final List<int> key2 = [];

  final List<int> IP = [2, 6, 3, 1, 4, 8, 5, 7];
  final List<int> IP_inv = [4, 1, 3, 5, 7, 2, 8, 6];
  final List<int> EP = [4, 1, 2, 3, 2, 3, 4, 1];
  final List<int> P4 = [2, 4, 3, 1];

  final List<List<int>> S0 = [
    [1, 0, 3, 2],
    [3, 2, 1, 0],
    [0, 2, 1, 3],
    [3, 1, 3, 2]
  ];
  final List<List<int>> S1 = [
    [1, 1, 2, 3],
    [2, 0, 1, 3],
    [3, 0, 1, 0],
    [2, 1, 0, 3]
  ];

  SDES(this.key) {
    key_generation();
  }

  List<int> shift(List<int> ar, int n) {
    while (n > 0) {
      int temp = ar[0];
      for (int i = 0; i < ar.length - 1; i++) {
        ar[i] = ar[i + 1];
      }
      ar[ar.length - 1] = temp;
      n--;
    }
    return ar;
  }

  void key_generation() {
    List<int> key_temp = [];
    List<int> Rs = [];
    List<int> Ls = [];

    for (int i = 0; i < 10; i++) {
      key_temp[i] = key[P10[i] - 1];
    }

    for (int i = 0; i < 5; i++) {
      Ls[i] = key_temp[i];
      Rs[i] = key_temp[i + 5];
    }

    List<int> Ls_1 = shift(Ls, 1);
    List<int> Rs_1 = shift(Rs, 1);

    for (int i = 0; i < 5; i++) {
      key_temp[i] = Ls_1[i];
      key_temp[i + 5] = Rs_1[i];
    }

    for (int i = 0; i < 8; i++) {
      key1[i] = key_temp[P8[i] - 1];
    }

    List<int> Ls_2 = shift(Ls, 2);
    List<int> Rs_2 = shift(Rs, 2);

    for (int i = 0; i < 5; i++) {
      key_temp[i] = Ls_2[i];
      key_temp[i + 5] = Rs_2[i];
    }

    for (int i = 0; i < 8; i++) {
      key2[i] = key_temp[P8[i] - 1];
    }
  }

  String binary_(int val) {
    if (val == 0) {
      return "00";
    } else if (val == 1) {
      return "01";
    } else if (val == 2) {
      return "10";
    } else {
      return "11";
    }
  }

  List<int> funcao_complexa(List<int> ar, List<int> key_) {
    List<int> left = [];
    List<int> right = [];
    int val_left, val_right;
    List<int> ep = [];
    List<int> r_ = [];
    List<int> r_p4 = [];
    List<int> output = [];

    for (int i = 0; i < 4; i++) {
      left[i] = ar[i];
      right[i] = ar[i + 4];
    }

    for (int i = 0; i < 8; i++) {
      ep[i] = right[EP[i] - 1];
    }

    for (int i = 0; i < 8; i++) {
      ar[i] = key_[i] ^ ep[i];
    }

    List<int> left_1 = [];
    List<int> right_1 = [];

    for (int i = 0; i < 4; i++) {
      left_1[i] = ar[i];
      right_1[i] = ar[i + 4];
    }

    val_left = S0[int.parse("" + left_1[0].toString() + left_1[3].toString(),
            radix: 2)]
        [int.parse("" + left_1[1].toString() + left_1[2].toString(), radix: 2)];
    val_right = S1[int.parse("" + right_1[0].toString() + right_1[3].toString(),
            radix: 2)][
        int.parse("" + right_1[1].toString() + right_1[2].toString(),
            radix: 2)];
    String str_left = binary_(val_left);
    String str_right = binary_(val_right);

    for (int i = 0; i < 2; i++) {
      r_[i] = str_left[i].toLowerCase().codeUnitAt(0) - 87;
      r_[i + 2] = str_right[i].toLowerCase().codeUnitAt(0) - 87;
    }

    for (int i = 0; i < 4; i++) {
      r_p4[i] = r_[P4[i] - 1];
    }

    for (int i = 0; i < 4; i++) {
      left[i] = left[i] ^ r_p4[i];
    }

    for (int i = 0; i < 4; i++) {
      output[i] = left[i];
      output[i + 4] = right[i];
    }
    return output;
  }

  List<int> swap(List<int> array, int n) {
    List<int> l = [];
    List<int> r = [];
    List<int> output = [];

    for (int i = 0; i < n; i++) {
      l[i] = array[i];
      r[i] = array[i + n];
    }

    for (int i = 0; i < n; i++) {
      output[i] = r[i];
      output[i + n] = l[i];
    }

    return output;
  }

  List<int> decryption(List<int> ar) {
    List<int> arr = [];
    List<int> decrypted = [];

    for (int i = 0; i < 8; i++) {
      arr[i] = ar[IP[i] - 1];
    }

    List<int> arr1 = funcao_complexa(arr, key2);
    List<int> after_swap = swap(arr1, arr1.length ~/ 2);
    List<int> arr2 = funcao_complexa(after_swap, key1);

    for (int i = 0; i < 8; i++) {
      decrypted[i] = arr2[IP_inv[i] - 1];
    }
    return decrypted;
  }

  List<int> encryption(List<int> plaintext) {
    List<int> arr = [];

    for (int i = 0; i < 8; i++) {
      arr[i] = plaintext[IP[i] - 1];
    }
    List<int> arr1 = funcao_complexa(arr, key1);
    int s_value = arr1.length ~/ 2;
    List<int> after_swap = swap(arr1, s_value);
    List<int> arr2 = funcao_complexa(after_swap, key2);
    List<int> ciphertext = [];

    for (int i = 0; i < 8; i++) {
      ciphertext[i] = arr2[IP_inv[i] - 1];
    }
    return ciphertext;
  }
}
