

bool isAnyTelemetryActive(
  String? speed,
  String? altitude,
  double? heading,
  double? latitude,
  double? longitude,
) {
  double speedVal = double.tryParse(speed ?? '') ?? 0.0;
  double altVal = double.tryParse(altitude ?? '') ?? 0.0;
  double headVal = heading ?? 0.0;
  double latVal = latitude ?? 0.0;
  double longVal = longitude ?? 0.0;

  return speedVal > 0 || altVal > 0 || headVal > 0 || latVal > 0 || longVal > 0;
}
