import 'package:encrypt/encrypt.dart';

class SimpleEncryptionService {
  static final _key =
      Key.fromUtf8("junieldjissuper!"); // Use a 16, 24, or 32 length key
  static final IV _iv = IV.fromLength(16); // AES block size is 16
  static final _encrypter = Encrypter(AES(
    _key,
  ));

  static IV get iv => _iv; // Encrypts the text

  static String encrypt64(String text) {
    final Encrypted encryptedData = _encrypter.encrypt(text, iv: _iv);

    return encryptedData.base64;
  }

  // Decrypts the text
  static String decrypt(String encryptedData, String iv64) {
    IV iv = IV.fromBase64(iv64);

    final String decryptedData = _encrypter.decrypt64(encryptedData, iv: iv);

    return decryptedData;
  }
}
