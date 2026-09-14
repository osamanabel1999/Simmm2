

String createLicenseKey() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  int seed = DateTime.now().microsecondsSinceEpoch;
  String result = '';

  for (int i = 0; i < 10; i++) {
    seed = (seed * 31 + i) % 1000000;
    result += chars[seed % chars.length];
  }

  return result;
}
