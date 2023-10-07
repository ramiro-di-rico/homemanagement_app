import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class CryptographyService{

  String cryptoValue = '9126486423168794';

  Future<String> encryptToAES(String value) async {
    final key = Key.fromUtf8('9126486423168794');
    final iv = IV.fromUtf8('9126486423168794');

    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));

    final encrypted = encrypter.encrypt(value, iv: iv);
    final result = encrypted.base64;
    return result;
  }
}