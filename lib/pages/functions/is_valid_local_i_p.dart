

bool? isValidLocalIP(String ipAddress) {
  bool isValidLocalIP(String ipAddress) {
    // الكود ده بيفلتر الأرقام ويتأكد إنها على صيغة شبكة واي فاي محلية
    RegExp regExp = RegExp(
        r'^(192\.168|10|172\.(1[6-9]|2[0-9]|3[0-1]))\.\d{1,3}\.\d{1,3}$');
    return regExp.hasMatch(ipAddress);
  }
  return null;
}
