class UuidService {
  static const app = "myapp";

  ///Give the utf-16 code for the app constant.
  static String _getAppCode() {
    String base = '';
    String utility = '$app${0}';
    for (int i = 0; i < utility.length; i++) {
      base += utility.codeUnitAt(i).toString();
    }

    return base;
  }

  ///Give the complete service uuid of the current user for the current service.
  static String serviceUuid(int counter,) {
    String base = _getAppCode();

    int numberOfZeros = 32 - base.length - counter.toString().length;

    for (int i = 0; i < numberOfZeros; i++) {
      base += '0';
    }

    base += counter.toString();
    String first = '${base.substring(0, 8)}-';
    String second = '${base.substring(8, 12)}-';
    String third = '${base.substring(12, 16)}-';
    String fourth = '${base.substring(16, 20)}-';
    String fifth = base.substring(20, 32);

    return first + second + third + fourth + fifth;
  }

  ///Give the general app uuid base for the current service.
  ///This is used to check if a device is a device of the current app.
  static String getAppUuid() {
    String base = _getAppCode();

    String first = '${base.substring(0, 8)}-';
    String middle = '${base.substring(8, 12)}-';
    String last = base.substring(12, 16);

    return first + middle + last;
  }
}
