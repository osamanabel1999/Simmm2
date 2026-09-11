// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<dynamic> getOfflineNavaidData(String? navaidIdent) async {
  if (navaidIdent == null || navaidIdent.trim().isEmpty) return null;

  final navaid = NavaidData.getNavaidData(navaidIdent);
  if (navaid != null) {
    return navaid.toMap();
  }
  return null;
}

class NavaidModel {
  const NavaidModel({
    required this.name,
    required this.type,
    required this.freq,
    required this.lat,
    required this.lon,
    required this.elev,
    required this.country,
    required this.airport,
  });

  final String name;
  final String type;
  final double freq;
  final double lat;
  final double lon;
  final double elev;
  final String country;
  final String airport;

  factory NavaidModel.fromMap(Map<String, dynamic> map) {
    return NavaidModel(
      name: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      freq: double.tryParse(map['freq']?.toString() ?? '0.0') ?? 0.0,
      lat: double.tryParse(map['lat']?.toString() ?? '0.0') ?? 0.0,
      lon: double.tryParse(map['lon']?.toString() ?? '0.0') ?? 0.0,
      elev: double.tryParse(map['elev']?.toString() ?? '0.0') ?? 0.0,
      country: map['country']?.toString() ?? '',
      airport: map['airport']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        'type': type,
        'freq': freq,
        'lat': lat,
        'lon': lon,
        'elev': elev,
        'country': country,
        'airport': airport,
      };
}

class NavaidData {
  NavaidData._();

  static final Map<String, NavaidModel> _cache = <String, NavaidModel>{};

  static NavaidModel? getNavaidData(String ident) {
    final String key = ident.trim().toUpperCase();
    if (key.isEmpty) return null;

    final Map<String, dynamic>? data = _navaids[key];
    if (data == null) return null;

    return _cache.putIfAbsent(key, () => NavaidModel.fromMap(data));
  }

  static bool containsNavaid(String ident) =>
      _navaids.containsKey(ident.trim().toUpperCase());

  static int get count => _navaids.length;

  static const Map<String, Map<String, dynamic>> _navaids =
      <String, Map<String, dynamic>>{
    "1A": {
      "name": "Williams Harbour",
      "type": "NDB",
      "freq": 373.0,
      "lat": 52.55889892578125,
      "lon": -55.78219985961914,
      "elev": 70.0,
      "country": "CA",
      "airport": "CCA6"
    },
    "1B": {
      "name": "Sable Island",
      "type": "NDB",
      "freq": 277.0,
      "lat": 43.93059921264648,
      "lon": -60.02289962768555,
      "elev": 0.0,
      "country": "CA",
      "airport": ""
    },
    "1CD": {
      "name": "Nanaimo",
      "type": "DME",
      "freq": 111450.0,
      "lat": 49.05720138549805,
      "lon": -123.87200164794922,
      "elev": 83.0,
      "country": "CA",
      "airport": "CYCD"
    },
    "1D": {
      "name": "Charlottetown",
      "type": "NDB",
      "freq": 346.0,
      "lat": 52.775001525878906,
      "lon": -56.124000549316406,
      "elev": 209.0,
      "country": "CA",
      "airport": "CCH4"
    },
    "1E": {
      "name": "Black Tickle",
      "type": "NDB",
      "freq": 349.0,
      "lat": 53.46670150756836,
      "lon": -55.78739929199219,
      "elev": 0.0,
      "country": "CA",
      "airport": "CCE4"
    },
    "1F": {
      "name": "Manta",
      "type": "NDB",
      "freq": 363.0,
      "lat": 47.63059997558594,
      "lon": -65.74469757080078,
      "elev": 193.0,
      "country": "CA",
      "airport": "CZBF"
    },
    "1K": {
      "name": "Zama Lake",
      "type": "NDB",
      "freq": 227.0,
      "lat": 59.02330017089844,
      "lon": -118.84300231933594,
      "elev": 0.0,
      "country": "CA",
      "airport": "CA-1043"
    },
    "1S": {
      "name": "North Of Sixty",
      "type": "NDB",
      "freq": 350.0,
      "lat": 60.31890106201172,
      "lon": -103.12899780273438,
      "elev": 0.0,
      "country": "CA",
      "airport": "CKV4"
    },
    "1T": {
      "name": "Lloydminster",
      "type": "DME",
      "freq": 110700.0,
      "lat": 53.31330108642578,
      "lon": -110.08000183105467,
      "elev": 2210.0,
      "country": "CA",
      "airport": "CYLL"
    },
    "1U": {
      "name": "Masset",
      "type": "NDB",
      "freq": 278.0,
      "lat": 54.031700134277344,
      "lon": -132.1269989013672,
      "elev": 25.0,
      "country": "CA",
      "airport": "CZMT"
    },
    "1W": {
      "name": "Sandy Bay",
      "type": "NDB",
      "freq": 412.0,
      "lat": 55.54330062866211,
      "lon": -102.2760009765625,
      "elev": 1000.0,
      "country": "CA",
      "airport": "CJY4"
    },
    "2A": {
      "name": "South Indian Lake",
      "type": "NDB",
      "freq": 300.0,
      "lat": 56.79389953613281,
      "lon": -98.904296875,
      "elev": 974.0,
      "country": "CA",
      "airport": "CZSN"
    },
    "2B": {
      "name": "Springdale",
      "type": "NDB",
      "freq": 364.0,
      "lat": 49.4900016784668,
      "lon": -56.18470001220703,
      "elev": 250.0,
      "country": "CA",
      "airport": "CCD2"
    },
    "2F": {
      "name": "Bathurst",
      "type": "DME",
      "freq": 114400.0,
      "lat": 47.63140106201172,
      "lon": -65.74440002441406,
      "elev": 191.0,
      "country": "CA",
      "airport": "CZBF"
    },
    "2H": {
      "name": "Lebel-sur-Quevillon",
      "type": "NDB",
      "freq": 261.0,
      "lat": 49.0372009277,
      "lon": -77.0207977295,
      "elev": 0.0,
      "country": "CA",
      "airport": "CSH4"
    },
    "2J": {
      "name": "Grand Forks",
      "type": "NDB-DME",
      "freq": 250.0,
      "lat": 49.01750183105469,
      "lon": -118.42400360107422,
      "elev": 1720.0,
      "country": "CA",
      "airport": "CZGF"
    },
    "2K": {
      "name": "Camrose",
      "type": "NDB",
      "freq": 405.0,
      "lat": 53.03219985961914,
      "lon": -112.81300354003906,
      "elev": 2426.0,
      "country": "CA",
      "airport": "CEQ3"
    },
    "2M": {
      "name": "Opapimiskan Lake",
      "type": "NDB",
      "freq": 393.0,
      "lat": 52.60309982299805,
      "lon": -90.37439727783205,
      "elev": 934.0,
      "country": "CA",
      "airport": "CKM8"
    },
    "2Q": {
      "name": "Mont-Laurier",
      "type": "NDB",
      "freq": 373.0,
      "lat": 46.602500915527344,
      "lon": -75.47059631347656,
      "elev": 0.0,
      "country": "CA",
      "airport": "CSD4"
    },
    "2S": {
      "name": "High Prairie",
      "type": "NDB-DME",
      "freq": 406.0,
      "lat": 55.395599365234375,
      "lon": -116.48400115966795,
      "elev": 2005.0,
      "country": "CA",
      "airport": "CZHP"
    },
    "2T": {
      "name": "Pokemouche",
      "type": "NDB",
      "freq": 329.0,
      "lat": 47.71500015258789,
      "lon": -64.88580322265625,
      "elev": 68.0,
      "country": "CA",
      "airport": "CDA4"
    },
    "2U": {
      "name": "Mackenzie Bc",
      "type": "NDB-DME",
      "freq": 284.0,
      "lat": 55.3036003112793,
      "lon": -123.13700103759766,
      "elev": 2303.0,
      "country": "CA",
      "airport": "CYZY"
    },
    "2Z": {
      "name": "Diavik",
      "type": "NDB",
      "freq": 382.0,
      "lat": 64.51000213623047,
      "lon": -110.30699920654295,
      "elev": 0.0,
      "country": "CA",
      "airport": "CDK2"
    },
    "3D": {
      "name": "Cumberland House",
      "type": "NDB",
      "freq": 398.0,
      "lat": 53.95719909667969,
      "lon": -102.2969970703125,
      "elev": 877.0,
      "country": "CA",
      "airport": "CJT4"
    },
    "3F": {
      "name": "Ile-A-La-Crosse",
      "type": "NDB",
      "freq": 384.0,
      "lat": 55.4838981628418,
      "lon": -107.93099975585938,
      "elev": 1394.0,
      "country": "CA",
      "airport": "CJF3"
    },
    "3H": {
      "name": "Consort",
      "type": "NDB",
      "freq": 276.0,
      "lat": 52.02280044555664,
      "lon": -110.74600219726562,
      "elev": 2499.0,
      "country": "CA",
      "airport": "CFG3"
    },
    "3I": {
      "name": "Mobil Sierra",
      "type": "NDB",
      "freq": 397.0,
      "lat": 58.798301696777344,
      "lon": -121.34500122070312,
      "elev": 0.0,
      "country": "CA",
      "airport": ""
    },
    "3M": {
      "name": "Drayton Valley Industrial",
      "type": "NDB-DME",
      "freq": 385.0,
      "lat": 53.26639938354492,
      "lon": -114.95500183105467,
      "elev": 2785.0,
      "country": "CA",
      "airport": "CER3"
    },
    "3N": {
      "name": "Weyburn",
      "type": "NDB",
      "freq": 298.0,
      "lat": 49.6963996887207,
      "lon": -103.8040008544922,
      "elev": 1963.0,
      "country": "CA",
      "airport": "CJE3"
    },
    "3P": {
      "name": "Muddy Lake",
      "type": "NDB",
      "freq": 242.0,
      "lat": 58.23690032958984,
      "lon": -132.1959991455078,
      "elev": 0.0,
      "country": "CA",
      "airport": ""
    },
    "3R": {
      "name": "Postville",
      "type": "NDB",
      "freq": 366.0,
      "lat": 54.907501220703125,
      "lon": -59.79690170288086,
      "elev": 193.0,
      "country": "CA",
      "airport": "CCD4"
    },
    "3X": {
      "name": "Cluff Lake",
      "type": "NDB",
      "freq": 243.0,
      "lat": 58.36029815673828,
      "lon": -109.5250015258789,
      "elev": 0.0,
      "country": "CA",
      "airport": "CJS3"
    },
    "3Y": {
      "name": "Donnelly",
      "type": "NDB-DME",
      "freq": 234.0,
      "lat": 55.71060180664063,
      "lon": -117.0999984741211,
      "elev": 1949.0,
      "country": "CA",
      "airport": "CFM4"
    },
    "3Z": {
      "name": "Russell",
      "type": "NDB",
      "freq": 263.0,
      "lat": 50.764198303222656,
      "lon": -101.2959976196289,
      "elev": 1825.0,
      "country": "CA",
      "airport": "CJW5"
    },
    "4A": {
      "name": "Koala",
      "type": "NDB-DME",
      "freq": 350.0,
      "lat": 64.6980972290039,
      "lon": -110.60900115966795,
      "elev": 1540.0,
      "country": "CA",
      "airport": "CYOA"
    },
    "4B": {
      "name": "Little Grand Rapids",
      "type": "NDB",
      "freq": 280.0,
      "lat": 52.0442008972168,
      "lon": -95.46189880371094,
      "elev": 1005.0,
      "country": "CA",
      "airport": "CZGR"
    },
    "4D": {
      "name": "Helmet",
      "type": "NDB",
      "freq": 364.0,
      "lat": 59.4213981628418,
      "lon": -120.78900146484376,
      "elev": 2025.0,
      "country": "CA",
      "airport": "CBH2"
    },
    "4G": {
      "name": "Cross Lake",
      "type": "NDB",
      "freq": 353.0,
      "lat": 54.610801696777344,
      "lon": -97.7664031982422,
      "elev": 709.0,
      "country": "CA",
      "airport": "CYCR"
    },
    "4H": {
      "name": "Points North Landing",
      "type": "NDB",
      "freq": 368.0,
      "lat": 58.26919937133789,
      "lon": -104.08000183105467,
      "elev": 1620.0,
      "country": "CA",
      "airport": "CYNL"
    },
    "4J": {
      "name": "Knee Lake",
      "type": "NDB",
      "freq": 314.0,
      "lat": 54.88330078125,
      "lon": -94.8000030517578,
      "elev": 0.0,
      "country": "CA",
      "airport": "CJT3"
    },
    "4K": {
      "name": "St Theresa Point",
      "type": "NDB",
      "freq": 362.0,
      "lat": 53.845001220703125,
      "lon": -94.84940338134766,
      "elev": 773.0,
      "country": "CA",
      "airport": "CYST"
    },
    "4L": {
      "name": "Chatham",
      "type": "NDB",
      "freq": 236.0,
      "lat": 42.31230163574219,
      "lon": -82.07769775390625,
      "elev": 650.0,
      "country": "CA",
      "airport": "CYCK"
    },
    "4M": {
      "name": "Red Sucker Lake",
      "type": "NDB",
      "freq": 399.0,
      "lat": 54.16889953613281,
      "lon": -93.56320190429688,
      "elev": 729.0,
      "country": "CA",
      "airport": "CYRS"
    },
    "4N": {
      "name": "Oxford House",
      "type": "NDB",
      "freq": 386.0,
      "lat": 54.9286003112793,
      "lon": -95.28250122070312,
      "elev": 688.0,
      "country": "CA",
      "airport": "CYOH"
    },
    "4O": {
      "name": "Swan Hills",
      "type": "NDB",
      "freq": 251.0,
      "lat": 54.67499923706055,
      "lon": -115.42400360107422,
      "elev": 3473.0,
      "country": "CA",
      "airport": "CEM5"
    },
    "4Q": {
      "name": "Brochet",
      "type": "NDB",
      "freq": 347.0,
      "lat": 57.88610076904297,
      "lon": -101.677001953125,
      "elev": 1136.0,
      "country": "CA",
      "airport": "CYBT"
    },
    "4T": {
      "name": "Shamattawa",
      "type": "NDB",
      "freq": 280.0,
      "lat": 55.85929870605469,
      "lon": -92.08599853515624,
      "elev": 289.0,
      "country": "CA",
      "airport": "CZTM"
    },
    "4V": {
      "name": "Lac Brochet",
      "type": "NDB",
      "freq": 371.0,
      "lat": 58.61830139160156,
      "lon": -101.47000122070312,
      "elev": 1257.0,
      "country": "CA",
      "airport": "CZWH"
    },
    "4W": {
      "name": "Kelsey",
      "type": "NDB",
      "freq": 391.0,
      "lat": 56.03749847412109,
      "lon": -96.51280212402344,
      "elev": 600.0,
      "country": "CA",
      "airport": "CZEE"
    },
    "4X": {
      "name": "Lac Du Bonnet",
      "type": "NDB",
      "freq": 386.0,
      "lat": 50.29029846191406,
      "lon": -96.01419830322266,
      "elev": 850.0,
      "country": "CA",
      "airport": "CYAX"
    },
    "4Y": {
      "name": "Key Lake",
      "type": "NDB",
      "freq": 376.0,
      "lat": 57.25419998168945,
      "lon": -105.62200164794922,
      "elev": 1670.0,
      "country": "CA",
      "airport": "CYKJ"
    },
    "5B": {
      "name": "Summerside",
      "type": "NDB",
      "freq": 254.0,
      "lat": 46.39690017700195,
      "lon": -63.88169860839844,
      "elev": 0.0,
      "country": "CA",
      "airport": "CYSU"
    },
    "5F": {
      "name": "Fox Creek",
      "type": "NDB-DME",
      "freq": 353.0,
      "lat": 54.37939834594727,
      "lon": -116.76000213623048,
      "elev": 2841.0,
      "country": "CA",
      "airport": "CED4"
    },
    "5J": {
      "name": "Coronation",
      "type": "NDB",
      "freq": 328.0,
      "lat": 52.07440185546875,
      "lon": -111.447998046875,
      "elev": 2595.0,
      "country": "CA",
      "airport": "CYCT"
    },
    "5L": {
      "name": "Donaldson",
      "type": "NDB",
      "freq": 233.0,
      "lat": 61.66469955444336,
      "lon": -73.29190063476562,
      "elev": 1888.0,
      "country": "CA",
      "airport": "CTP9"
    },
    "5M": {
      "name": "Sparwood",
      "type": "NDB",
      "freq": 200.0,
      "lat": 49.8372001648,
      "lon": -114.884002686,
      "elev": 3800.0,
      "country": "CA",
      "airport": "CYSW"
    },
    "5O": {
      "name": "Gods River",
      "type": "NDB",
      "freq": 350.0,
      "lat": 54.84189987182617,
      "lon": -94.06909942626952,
      "elev": 676.0,
      "country": "CA",
      "airport": "CJT3"
    },
    "5Q": {
      "name": "Fontanges",
      "type": "NDB",
      "freq": 239.0,
      "lat": 54.560001373291016,
      "lon": -71.17109680175781,
      "elev": 1552.0,
      "country": "CA",
      "airport": "CTU2"
    },
    "5U": {
      "name": "Fort Vermilion",
      "type": "NDB-DME",
      "freq": 261.0,
      "lat": 58.40250015258789,
      "lon": -115.95099639892578,
      "elev": 836.0,
      "country": "CA",
      "airport": "CEZ4"
    },
    "5V": {
      "name": "Drumheller",
      "type": "NDB-DME",
      "freq": 395.0,
      "lat": 51.50249862670898,
      "lon": -112.7509994506836,
      "elev": 2625.0,
      "country": "CA",
      "airport": "CEG4"
    },
    "5W": {
      "name": "Leaf Rapids",
      "type": "NDB",
      "freq": 226.0,
      "lat": 56.51169967651367,
      "lon": -99.98390197753906,
      "elev": 959.0,
      "country": "CA",
      "airport": "CYLR"
    },
    "5Y": {
      "name": "Trenton",
      "type": "NDB",
      "freq": 361.0,
      "lat": 45.61180114746094,
      "lon": -62.625099182128906,
      "elev": 317.0,
      "country": "CA",
      "airport": "CYTN"
    },
    "6E": {
      "name": "Grand Manan",
      "type": "NDB",
      "freq": 387.0,
      "lat": 44.715599060058594,
      "lon": -66.80220031738281,
      "elev": 238.0,
      "country": "CA",
      "airport": "CCN2"
    },
    "6F": {
      "name": "Port Hope Simpson",
      "type": "NDB",
      "freq": 367.0,
      "lat": 52.520301818847656,
      "lon": -56.29520034790039,
      "elev": 347.0,
      "country": "CA",
      "airport": "CCP4"
    },
    "6G": {
      "name": "Red Deer",
      "type": "DME",
      "freq": 111600.0,
      "lat": 52.18119812011719,
      "lon": -113.88300323486328,
      "elev": 2985.0,
      "country": "CA",
      "airport": "CYQF"
    },
    "6K": {
      "name": "Vernon Bc",
      "type": "NDB",
      "freq": 302.0,
      "lat": 50.34999847412109,
      "lon": -119.26000213623048,
      "elev": 0.0,
      "country": "CA",
      "airport": "CYVK"
    },
    "6M": {
      "name": "Belleville",
      "type": "NDB",
      "freq": 283.0,
      "lat": 44.19499969482422,
      "lon": -77.30829620361328,
      "elev": 320.0,
      "country": "CA",
      "airport": "CNU4"
    },
    "6Q": {
      "name": "Cigar Lake",
      "type": "NDB",
      "freq": 222.0,
      "lat": 58.06969833374024,
      "lon": -104.53900146484376,
      "elev": 0.0,
      "country": "CA",
      "airport": "CJW7"
    },
    "6X": {
      "name": "York Landing",
      "type": "NDB",
      "freq": 339.0,
      "lat": 56.08829879760742,
      "lon": -96.0969009399414,
      "elev": 609.0,
      "country": "CA",
      "airport": "CZAC"
    },
    "6Z": {
      "name": "La Loche",
      "type": "NDB",
      "freq": 410.0,
      "lat": 56.47829818725586,
      "lon": -109.4010009765625,
      "elev": 1500.0,
      "country": "CA",
      "airport": "CJL4"
    },
    "7B": {
      "name": "St Thomas",
      "type": "NDB",
      "freq": 375.0,
      "lat": 42.77090072631836,
      "lon": -81.10569763183594,
      "elev": 776.0,
      "country": "CA",
      "airport": "CYQS"
    },
    "7C": {
      "name": "Fogo",
      "type": "NDB",
      "freq": 237.0,
      "lat": 49.661598205566406,
      "lon": -54.24509811401367,
      "elev": 97.0,
      "country": "CA",
      "airport": "CDY3"
    },
    "7D": {
      "name": "Hudson Bay",
      "type": "NDB",
      "freq": 337.0,
      "lat": 52.847801208496094,
      "lon": -102.18699645996094,
      "elev": 0.0,
      "country": "CA",
      "airport": "CYHB"
    },
    "7F": {
      "name": "Collins Bay",
      "type": "NDB",
      "freq": 400.0,
      "lat": 58.22829818725586,
      "lon": -103.68299865722656,
      "elev": 1340.0,
      "country": "CA",
      "airport": "CYKC"
    },
    "7H": {
      "name": "Marystown",
      "type": "NDB",
      "freq": 234.0,
      "lat": 47.138301849365234,
      "lon": -55.32500076293945,
      "elev": 96.0,
      "country": "CA",
      "airport": "CCC2"
    },
    "7J": {
      "name": "Forestburg",
      "type": "NDB",
      "freq": 261.0,
      "lat": 52.57640075683594,
      "lon": -112.08599853515624,
      "elev": 2352.0,
      "country": "CA",
      "airport": "CA-1023"
    },
    "7L": {
      "name": "La Sarre",
      "type": "NDB",
      "freq": 405.0,
      "lat": 48.91059875488281,
      "lon": -79.17890167236328,
      "elev": 1048.0,
      "country": "CA",
      "airport": "CSR8"
    },
    "7P": {
      "name": "Iroquois Falls",
      "type": "NDB",
      "freq": 382.0,
      "lat": 48.70840072631836,
      "lon": -80.73590087890625,
      "elev": 0.0,
      "country": "CA",
      "airport": "CNE4"
    },
    "7V": {
      "name": "Jasper-Hinton",
      "type": "NDB",
      "freq": 233.0,
      "lat": 53.32109832763672,
      "lon": -117.75499725341795,
      "elev": 4026.0,
      "country": "CA",
      "airport": "CEC4"
    },
    "8A": {
      "name": "Carlyle",
      "type": "NDB",
      "freq": 310.0,
      "lat": 49.645599365234375,
      "lon": -102.28099822998048,
      "elev": 2074.0,
      "country": "CA",
      "airport": "CJQ3"
    },
    "8C": {
      "name": "Fairview",
      "type": "NDB-DME",
      "freq": 295.0,
      "lat": 56.07559967041016,
      "lon": -118.44100189208984,
      "elev": 2190.0,
      "country": "CA",
      "airport": "CEB5"
    },
    "8F": {
      "name": "Debert",
      "type": "NDB",
      "freq": 239.0,
      "lat": 45.422000885009766,
      "lon": -63.459598541259766,
      "elev": 142.0,
      "country": "CA",
      "airport": "CCQ3"
    },
    "8G": {
      "name": "Stettler",
      "type": "NDB-DME",
      "freq": 286.0,
      "lat": 52.30830001831055,
      "lon": -112.75399780273438,
      "elev": 2700.0,
      "country": "CA",
      "airport": "CEJ3"
    },
    "8H": {
      "name": "St Paul",
      "type": "NDB",
      "freq": 375.0,
      "lat": 53.99190139770508,
      "lon": -111.39099884033205,
      "elev": 2147.0,
      "country": "CA",
      "airport": "CEW3"
    },
    "8J": {
      "name": "Provost",
      "type": "NDB",
      "freq": 208.0,
      "lat": 52.332801818847656,
      "lon": -110.27300262451172,
      "elev": 2216.0,
      "country": "CA",
      "airport": "CEH6"
    },
    "8K": {
      "name": "Valleyview",
      "type": "NDB",
      "freq": 229.0,
      "lat": 55.034400939941406,
      "lon": -117.28900146484376,
      "elev": 2450.0,
      "country": "CA",
      "airport": "CEL5"
    },
    "8M": {
      "name": "Elk Point",
      "type": "NDB-DME",
      "freq": 414.0,
      "lat": 53.89030075073242,
      "lon": -110.76799774169922,
      "elev": 1999.0,
      "country": "CA",
      "airport": "CEJ6"
    },
    "8N": {
      "name": "Edson",
      "type": "NDB-DME",
      "freq": 393.0,
      "lat": 53.5807991027832,
      "lon": -116.45500183105467,
      "elev": 3066.0,
      "country": "CA",
      "airport": "CYET"
    },
    "9A": {
      "name": "Hanna",
      "type": "NDB",
      "freq": 221.0,
      "lat": 51.62779998779297,
      "lon": -111.9010009765625,
      "elev": 2738.0,
      "country": "CA",
      "airport": "CEL4"
    },
    "9G": {
      "name": "Sundre",
      "type": "NDB",
      "freq": 405.0,
      "lat": 51.77999877929688,
      "lon": -114.68299865722656,
      "elev": 3656.0,
      "country": "CA",
      "airport": "CFN7"
    },
    "9H": {
      "name": "La Grande 3",
      "type": "NDB",
      "freq": 235.0,
      "lat": 53.57379913330078,
      "lon": -76.20079803466797,
      "elev": 774.0,
      "country": "CA",
      "airport": "CYAD"
    },
    "9Q": {
      "name": "Amos",
      "type": "NDB",
      "freq": 291.0,
      "lat": 48.55759811401367,
      "lon": -78.24310302734375,
      "elev": 1068.0,
      "country": "CA",
      "airport": "CYEY"
    },
    "9S": {
      "name": "Powell River Bc",
      "type": "DME",
      "freq": 109300.0,
      "lat": 49.83560180664063,
      "lon": -124.4990005493164,
      "elev": 425.0,
      "country": "CA",
      "airport": "CYPW"
    },
    "9X": {
      "name": "Brooks",
      "type": "NDB-DME",
      "freq": 227.0,
      "lat": 50.63219833374024,
      "lon": -111.9219970703125,
      "elev": 2499.0,
      "country": "CA",
      "airport": "CYBP"
    },
    "9Y": {
      "name": "Pincher Creek",
      "type": "NDB",
      "freq": 311.0,
      "lat": 49.52330017089844,
      "lon": -113.9990005493164,
      "elev": 0.0,
      "country": "CA",
      "airport": "CZPC"
    },
    "9Z": {
      "name": "Westlock",
      "type": "NDB-DME",
      "freq": 236.0,
      "lat": 54.14310073852539,
      "lon": -113.7480010986328,
      "elev": 2230.0,
      "country": "CA",
      "airport": "CES4"
    },
    "A": {
      "name": "Baku/Bina",
      "type": "NDB",
      "freq": 113.0,
      "lat": 40.44499969482422,
      "lon": 50.06330108642578,
      "elev": 19.0,
      "country": "AZ",
      "airport": ""
    },
    "A1": {
      "name": "Taltheilei Narrows",
      "type": "NDB",
      "freq": 264.0,
      "lat": 62.59469985961914,
      "lon": -111.5189971923828,
      "elev": 570.0,
      "country": "CA",
      "airport": "CFA7"
    },
    "A5": {
      "name": "Chinchaga",
      "type": "NDB",
      "freq": 317.0,
      "lat": 57.54499816894531,
      "lon": -119.11100006103516,
      "elev": 2280.0,
      "country": "CA",
      "airport": "CA-1022"
    },
    "A9": {
      "name": "Liverpool",
      "type": "NDB",
      "freq": 330.0,
      "lat": 44.22700119018555,
      "lon": -64.8584976196289,
      "elev": 314.0,
      "country": "CA",
      "airport": "CYAU"
    },
    "AA": {
      "name": "Auckland",
      "type": "VOR-DME",
      "freq": 114800.0,
      "lat": -37.00460052490234,
      "lon": 174.81399536132812,
      "elev": 13.0,
      "country": "NZ",
      "airport": "NZAA"
    },
    "AAA": {
      "name": "Abraham",
      "type": "NDB",
      "freq": 329.0,
      "lat": 40.160099029541016,
      "lon": -89.33779907226562,
      "elev": 593.0,
      "country": "US",
      "airport": ""
    },
    "AAE": {
      "name": "Ahmedabad",
      "type": "VOR-DME",
      "freq": 113100.0,
      "lat": 23.072200775146484,
      "lon": 72.625,
      "elev": 184.0,
      "country": "IN",
      "airport": "VAAH"
    },
    "AAF": {
      "name": "Apalachicola",
      "type": "NDB",
      "freq": 349.0,
      "lat": 29.72330093383789,
      "lon": -85.0280990600586,
      "elev": 19.0,
      "country": "US",
      "airport": ""
    },
    "AAL": {
      "name": "Aalborg",
      "type": "TACAN",
      "freq": 116700.0,
      "lat": 57.10390090942383,
      "lon": 9.992810249328612,
      "elev": 57.0,
      "country": "DK",
      "airport": "EKYT"
    },
    "AAQ": {
      "name": "Araraquara",
      "type": "NDB",
      "freq": 205.0,
      "lat": -21.8129997253418,
      "lon": -48.13949966430664,
      "elev": 2514.0,
      "country": "BR",
      "airport": "SBAQ"
    },
    "AAR": {
      "name": "Arar",
      "type": "VORTAC",
      "freq": 113300.0,
      "lat": 30.90800094604492,
      "lon": 41.1422004699707,
      "elev": 1811.0,
      "country": "SA",
      "airport": "OERR"
    },
    "AAT": {
      "name": "Agartala",
      "type": "VOR-DME",
      "freq": 116100.0,
      "lat": 23.88960075378418,
      "lon": 91.2397003173828,
      "elev": 47.0,
      "country": "IN",
      "airport": "VEAT"
    },
    "AAU": {
      "name": "Aurangabad",
      "type": "VOR-DME",
      "freq": 116300.0,
      "lat": 19.86470031738281,
      "lon": 75.39409637451172,
      "elev": 1908.0,
      "country": "IN",
      "airport": "VAAU"
    },
    "AB": {
      "name": "Addis Abeba",
      "type": "NDB",
      "freq": 333.0,
      "lat": 8.997369766235352,
      "lon": 38.8202018737793,
      "elev": 0.0,
      "country": "ET",
      "airport": "HAAB"
    },
    "ABA": {
      "name": "Aruba",
      "type": "VOR-DME",
      "freq": 112500.0,
      "lat": 12.50979995727539,
      "lon": -69.9406967163086,
      "elev": 59.0,
      "country": "AW",
      "airport": "TNCA"
    },
    "ABB": {
      "name": "Nabb",
      "type": "VORTAC",
      "freq": 112400.0,
      "lat": 38.58879852294922,
      "lon": -85.63600158691406,
      "elev": 710.0,
      "country": "US",
      "airport": ""
    },
    "ABC": {
      "name": "Abuja",
      "type": "VOR-DME",
      "freq": 116300.0,
      "lat": 9.037799835205078,
      "lon": 7.285099983215332,
      "elev": 1240.0,
      "country": "NG",
      "airport": "DNAA"
    },
    "ABD": {
      "name": "Abadan",
      "type": "VOR-DME",
      "freq": 114500.0,
      "lat": 30.386999130249023,
      "lon": 48.21760177612305,
      "elev": 10.0,
      "country": "IR",
      "airport": "OIAA"
    },
    "ABG": {
      "name": "Ambassador",
      "type": "NDB",
      "freq": 404.0,
      "lat": 32.58539962768555,
      "lon": -95.11299896240234,
      "elev": 420.0,
      "country": "US",
      "airport": "1TX9"
    },
    "ABH": {
      "name": "Abha",
      "type": "VORTAC",
      "freq": 112900.0,
      "lat": 18.241899490356445,
      "lon": 42.65689849853516,
      "elev": 6862.0,
      "country": "SA",
      "airport": "OEAB"
    },
    "ABI": {
      "name": "Abilene",
      "type": "VORTAC",
      "freq": 113700.0,
      "lat": 32.481300354003906,
      "lon": -99.8635025024414,
      "elev": 1810.0,
      "country": "US",
      "airport": "KDYS"
    },
    "ABK": {
      "name": "Abakan",
      "type": "VOR-DME",
      "freq": 113300.0,
      "lat": 53.744998931884766,
      "lon": 91.38500213623048,
      "elev": 830.0,
      "country": "RU",
      "airport": "UNAA"
    },
    "ABL": {
      "name": "Ambalema",
      "type": "NDB",
      "freq": 300.0,
      "lat": 4.7838897705078125,
      "lon": -74.76750183105469,
      "elev": 0.0,
      "country": "CO",
      "airport": ""
    },
    "ABM": {
      "name": "Abumusa Island",
      "type": "NDB",
      "freq": 285.0,
      "lat": 25.87779998779297,
      "lon": 55.02289962768555,
      "elev": 23.0,
      "country": "IR",
      "airport": "OIBA"
    },
    "ABN": {
      "name": "Albenga",
      "type": "NDB",
      "freq": 420.0,
      "lat": 44.05580139160156,
      "lon": 8.221110343933105,
      "elev": 0.0,
      "country": "IT",
      "airport": "LIMG"
    },
    "ABQ": {
      "name": "Albuquerque",
      "type": "VORTAC",
      "freq": 113200.0,
      "lat": 35.043800354003906,
      "lon": -106.81600189208984,
      "elev": 5743.0,
      "country": "US",
      "airport": ""
    },
    "ABR": {
      "name": "Aberdeen",
      "type": "VOR-DME",
      "freq": 113000.0,
      "lat": 45.41740036010742,
      "lon": -98.3686981201172,
      "elev": 1301.0,
      "country": "US",
      "airport": ""
    },
    "ABT": {
      "name": "Albacete",
      "type": "NDB",
      "freq": 321.0,
      "lat": 38.94409942626953,
      "lon": -1.99767005443573,
      "elev": 0.0,
      "country": "ES",
      "airport": "LEAB"
    },
    "ABU": {
      "name": "Abu Argub",
      "type": "VOR-DME",
      "freq": 115100.0,
      "lat": 32.462799072265625,
      "lon": 13.169400215148926,
      "elev": 470.0,
      "country": "LY",
      "airport": "LY-0019"
    },
    "ABV": {
      "name": "Alexander Bay",
      "type": "VOR-DME",
      "freq": 112100.0,
      "lat": -28.57069969177246,
      "lon": 16.533899307250977,
      "elev": 98.0,
      "country": "ZA",
      "airport": "FAAB"
    },
    "AC": {
      "name": "Pleasant Lake",
      "type": "NDB",
      "freq": 230.0,
      "lat": 43.86090087890625,
      "lon": -66.0436019897461,
      "elev": 141.0,
      "country": "CA",
      "airport": "CYQI"
    },
    "ACA": {
      "name": "Acapulco",
      "type": "VOR-DME",
      "freq": 115900.0,
      "lat": 16.758499145507812,
      "lon": -99.75399780273438,
      "elev": 13.0,
      "country": "MX",
      "airport": "MMAA"
    },
    "ACC": {
      "name": "Accra",
      "type": "VOR-DME",
      "freq": 113100.0,
      "lat": 5.634109973907471,
      "lon": -0.1553439944982528,
      "elev": 205.0,
      "country": "GH",
      "airport": "DGAA"
    },
    "ACD": {
      "name": "Alcobendas",
      "type": "NDB",
      "freq": 417.0,
      "lat": 40.58570098876953,
      "lon": -3.6765100955963135,
      "elev": 0.0,
      "country": "ES",
      "airport": "LEMD"
    },
    "ACE": {
      "name": "Kachemak",
      "type": "NDB",
      "freq": 277.0,
      "lat": 59.641300201416016,
      "lon": -151.5,
      "elev": 78.0,
      "country": "US",
      "airport": "PAHO"
    },
    "ACH": {
      "name": "Anton Chico",
      "type": "VORTAC",
      "freq": 117800.0,
      "lat": 35.111698150634766,
      "lon": -105.04000091552734,
      "elev": 5450.0,
      "country": "US",
      "airport": "US-11921"
    },
    "ACJ": {
      "name": "Aracaju",
      "type": "VOR-DME",
      "freq": 112000.0,
      "lat": -10.984000205993652,
      "lon": -37.0713996887207,
      "elev": 26.0,
      "country": "BR",
      "airport": "SBAR"
    },
    "ACK": {
      "name": "Nantucket",
      "type": "VOR-DME",
      "freq": 116200.0,
      "lat": 41.28179931640625,
      "lon": -70.02670288085938,
      "elev": 100.0,
      "country": "US",
      "airport": "KACK"
    },
    "ACO": {
      "name": "Akron",
      "type": "VOR-DME",
      "freq": 114400.0,
      "lat": 41.1078987121582,
      "lon": -81.20149993896484,
      "elev": 1200.0,
      "country": "US",
      "airport": ""
    },
    "ACQ": {
      "name": "Waseca",
      "type": "NDB",
      "freq": 371.0,
      "lat": 44.0702018737793,
      "lon": -93.55239868164062,
      "elev": 1120.0,
      "country": "US",
      "airport": ""
    },
    "ACT": {
      "name": "Waco",
      "type": "VORTAC",
      "freq": 115300.0,
      "lat": 31.66230010986328,
      "lon": -97.2689971923828,
      "elev": 510.0,
      "country": "US",
      "airport": ""
    },
    "ACV": {
      "name": "Arcata",
      "type": "VOR-DME",
      "freq": 110200.0,
      "lat": 40.98139953613281,
      "lon": -124.10800170898438,
      "elev": 193.0,
      "country": "US",
      "airport": "KACV"
    },
    "ACY": {
      "name": "Atlantic City",
      "type": "VORTAC",
      "freq": 108600.0,
      "lat": 39.45589828491211,
      "lon": -74.57630157470703,
      "elev": 70.0,
      "country": "US",
      "airport": "KACY"
    },
    "ACZ": {
      "name": "Pendy",
      "type": "NDB",
      "freq": 379.0,
      "lat": 34.71630096435547,
      "lon": -78.00360107421875,
      "elev": 30.0,
      "country": "US",
      "airport": ""
    },
    "AD": {
      "name": "Adelaide",
      "type": "VOR-DME",
      "freq": 116400.0,
      "lat": -34.9468994140625,
      "lon": 138.5240020751953,
      "elev": 32.0,
      "country": "AU",
      "airport": "YPAD"
    },
    "ADA": {
      "name": "Aldeia",
      "type": "VOR-DME",
      "freq": 112100.0,
      "lat": -22.81279945373535,
      "lon": -42.09529876708984,
      "elev": 61.0,
      "country": "BR",
      "airport": "SBES"
    },
    "ADF": {
      "name": "Arkadelphia",
      "type": "NDB",
      "freq": 275.0,
      "lat": 34.05540084838867,
      "lon": -93.10489654541016,
      "elev": 181.0,
      "country": "US",
      "airport": ""
    },
    "ADG": {
      "name": "Adrian",
      "type": "NDB",
      "freq": 278.0,
      "lat": 41.869998931884766,
      "lon": -84.07749938964844,
      "elev": 862.0,
      "country": "US",
      "airport": ""
    },
    "ADH": {
      "name": "Ada",
      "type": "VOR-DME",
      "freq": 117800.0,
      "lat": 34.8026008605957,
      "lon": -96.67009735107422,
      "elev": 987.0,
      "country": "US",
      "airport": ""
    },
    "ADK": {
      "name": "Mount Moffett",
      "type": "NDB-DME",
      "freq": 530.0,
      "lat": 51.87189865112305,
      "lon": -176.67599487304688,
      "elev": 332.0,
      "country": "US",
      "airport": "PADK"
    },
    "ADL": {
      "name": "Sochi",
      "type": "VOR-DME",
      "freq": 112700.0,
      "lat": 43.40330123901367,
      "lon": 39.94829940795898,
      "elev": 36.0,
      "country": "RU",
      "airport": "URSS"
    },
    "ADM": {
      "name": "Ardmore",
      "type": "VORTAC",
      "freq": 116700.0,
      "lat": 34.21160125732422,
      "lon": -97.16829681396484,
      "elev": 925.0,
      "country": "US",
      "airport": ""
    },
    "ADN": {
      "name": "Roberto",
      "type": "VOR-DME",
      "freq": 115400.0,
      "lat": 25.86540031433105,
      "lon": -100.23899841308594,
      "elev": 1476.0,
      "country": "MX",
      "airport": "MMAN"
    },
    "ADO": {
      "name": "Puerto Deseado",
      "type": "NDB",
      "freq": 210.0,
      "lat": -47.73329925537109,
      "lon": -65.9094009399414,
      "elev": 266.0,
      "country": "AR",
      "airport": "SAWD"
    },
    "ADR": {
      "name": "Adrar",
      "type": "VOR-DME",
      "freq": 112600.0,
      "lat": 27.816999435424805,
      "lon": -0.2058670073747635,
      "elev": 920.0,
      "country": "DZ",
      "airport": "DAUA"
    },
    "ADS": {
      "name": "Addis Abeba",
      "type": "VOR-DME",
      "freq": 112900.0,
      "lat": 8.975040435791016,
      "lon": 38.79940032958984,
      "elev": 7656.0,
      "country": "ET",
      "airport": "HAAB"
    },
    "ADT": {
      "name": "Atwood",
      "type": "NDB",
      "freq": 365.0,
      "lat": 39.838600158691406,
      "lon": -101.04499816894533,
      "elev": 2936.0,
      "country": "US",
      "airport": ""
    },
    "ADU": {
      "name": "Audubon",
      "type": "NDB",
      "freq": 266.0,
      "lat": 41.69029998779297,
      "lon": -94.91000366210938,
      "elev": 1278.0,
      "country": "US",
      "airport": ""
    },
    "ADW": {
      "name": "Andrews",
      "type": "VORTAC",
      "freq": 113100.0,
      "lat": 38.80720138549805,
      "lon": -76.86620330810547,
      "elev": 260.0,
      "country": "US",
      "airport": "KADW"
    },
    "ADX": {
      "name": "Andraitx",
      "type": "NDB",
      "freq": 384.0,
      "lat": 39.54940032958984,
      "lon": 2.395859956741333,
      "elev": 0.0,
      "country": "ES",
      "airport": ""
    },
    "AE": {
      "name": "Abeche",
      "type": "VOR",
      "freq": 114500.0,
      "lat": 13.845100402832031,
      "lon": 20.84499931335449,
      "elev": 1804.0,
      "country": "TD",
      "airport": "FTTC"
    },
    "AEA": {
      "name": "Jones",
      "type": "NDB",
      "freq": 373.0,
      "lat": 36.61449813842773,
      "lon": -78.0531997680664,
      "elev": 270.0,
      "country": "US",
      "airport": ""
    },
    "AEE": {
      "name": "Antlers",
      "type": "NDB",
      "freq": 391.0,
      "lat": 34.19179916381836,
      "lon": -95.6519012451172,
      "elev": 569.0,
      "country": "US",
      "airport": ""
    },
    "AEL": {
      "name": "Albert Lea",
      "type": "VOR-DME",
      "freq": 109800.0,
      "lat": 43.68180084228516,
      "lon": -93.37079620361328,
      "elev": 1265.0,
      "country": "US",
      "airport": ""
    },
    "AES": {
      "name": "Nabesna",
      "type": "NDB",
      "freq": 390.0,
      "lat": 62.96580123901367,
      "lon": -141.88800048828125,
      "elev": 0.0,
      "country": "US",
      "airport": "PAOR"
    },
    "AEX": {
      "name": "Alexandria",
      "type": "VORTAC",
      "freq": 116100.0,
      "lat": 31.25670051574707,
      "lon": -92.5009994506836,
      "elev": 80.0,
      "country": "US",
      "airport": ""
    },
    "AEY": {
      "name": "Waverly",
      "type": "NDB",
      "freq": 329.0,
      "lat": 36.1161994934082,
      "lon": -87.74130249023438,
      "elev": 708.0,
      "country": "US",
      "airport": ""
    },
    "AF": {
      "name": "Archerfield",
      "type": "NDB",
      "freq": 419.0,
      "lat": -27.57029914855957,
      "lon": 153.01600646972656,
      "elev": 63.0,
      "country": "AU",
      "airport": "YBAF"
    },
    "AFD": {
      "name": "Watford City",
      "type": "NDB",
      "freq": 400.0,
      "lat": 47.81510162353516,
      "lon": -103.25800323486328,
      "elev": 2066.0,
      "country": "US",
      "airport": ""
    },
    "AFE": {
      "name": "Kake",
      "type": "NDB-DME",
      "freq": 223.0,
      "lat": 56.96390151977539,
      "lon": -133.91200256347656,
      "elev": 170.0,
      "country": "US",
      "airport": "PAFE"
    },
    "AFI": {
      "name": "Affligem",
      "type": "VOR-DME",
      "freq": 114900.0,
      "lat": 50.90779876708984,
      "lon": 4.138889789581299,
      "elev": 284.0,
      "country": "BE",
      "airport": "EBBR"
    },
    "AFK": {
      "name": "Nebraska City",
      "type": "NDB",
      "freq": 347.0,
      "lat": 40.60559844970703,
      "lon": -95.86080169677734,
      "elev": 1160.0,
      "country": "US",
      "airport": ""
    },
    "AFM": {
      "name": "Manas",
      "type": "TACAN",
      "freq": 134000.0,
      "lat": 43.062198638916016,
      "lon": 74.470703125,
      "elev": 2091.0,
      "country": "KG",
      "airport": "UAFM"
    },
    "AFO": {
      "name": "Afienou",
      "type": "NDB",
      "freq": 393.0,
      "lat": 5.411139965057373,
      "lon": -2.916470050811768,
      "elev": 0.0,
      "country": "CI",
      "airport": ""
    },
    "AFP": {
      "name": "Anson Co",
      "type": "NDB",
      "freq": 283.0,
      "lat": 35.02399826049805,
      "lon": -80.08300018310547,
      "elev": 302.0,
      "country": "US",
      "airport": ""
    },
    "AFS": {
      "name": "Afonsos",
      "type": "NDB",
      "freq": 270.0,
      "lat": -22.867000579833984,
      "lon": -43.36690139770508,
      "elev": 112.0,
      "country": "BR",
      "airport": "SBAF"
    },
    "AG": {
      "name": "Aek Godang",
      "type": "NDB",
      "freq": 233.0,
      "lat": 1.3983399868011477,
      "lon": 99.4290008544922,
      "elev": 935.0,
      "country": "ID",
      "airport": "WIME"
    },
    "AGB": {
      "name": "Augsburg",
      "type": "NDB",
      "freq": 318.0,
      "lat": 48.42430114746094,
      "lon": 10.933099746704102,
      "elev": 1542.0,
      "country": "DE",
      "airport": "EDMA"
    },
    "AGC": {
      "name": "Allegheny",
      "type": "VOR-DME",
      "freq": 110000.0,
      "lat": 40.27870178222656,
      "lon": -80.04090118408203,
      "elev": 1290.0,
      "country": "US",
      "airport": ""
    },
    "AGD": {
      "name": "Altenburg",
      "type": "DME",
      "freq": 115300.0,
      "lat": 50.98270034790039,
      "lon": 12.512299537658691,
      "elev": 624.0,
      "country": "DE",
      "airport": "EDAC"
    },
    "AGG": {
      "name": "Agra",
      "type": "VOR-DME",
      "freq": 112000.0,
      "lat": 27.15069961547852,
      "lon": 77.94750213623047,
      "elev": 551.0,
      "country": "IN",
      "airport": "VIAG"
    },
    "AGH": {
      "name": "Anchialos",
      "type": "VOR-DME",
      "freq": 110400.0,
      "lat": 39.21620178222656,
      "lon": 22.791900634765625,
      "elev": 65.0,
      "country": "GR",
      "airport": "LGBL"
    },
    "AGI": {
      "name": "Araguaina",
      "type": "NDB",
      "freq": 205.0,
      "lat": -7.233500003814697,
      "lon": -48.23899841308594,
      "elev": 771.0,
      "country": "BR",
      "airport": "SWGN"
    },
    "AGJ": {
      "name": "Gooch Springs",
      "type": "VORTAC",
      "freq": 112500.0,
      "lat": 31.185,
      "lon": -98.141,
      "elev": 1191.0,
      "country": "US",
      "airport": ""
    },
    "AGN": {
      "name": "Agen",
      "type": "VOR-DME",
      "freq": 114800.0,
      "lat": 43.88800048828125,
      "lon": 0.8728610277175903,
      "elev": 868.0,
      "country": "FR",
      "airport": ""
    },
    "AGU": {
      "name": "Aguascalientes",
      "type": "VOR-DME",
      "freq": 113600.0,
      "lat": 21.71139907836914,
      "lon": -102.31900024414062,
      "elev": 6112.0,
      "country": "MX",
      "airport": "MMAS"
    },
    "AGV": {
      "name": "Aggeneys",
      "type": "VOR-DME",
      "freq": 116700.0,
      "lat": -29.48110008239746,
      "lon": 18.5625,
      "elev": 3356.0,
      "country": "ZA",
      "airport": ""
    },
    "AGZ": {
      "name": "Ayaguz",
      "type": "VOR",
      "freq": 113600.0,
      "lat": 47.93109893798828,
      "lon": 80.44969940185547,
      "elev": 0.0,
      "country": "KZ",
      "airport": ""
    },
    "AH": {
      "name": "Ahmedabad",
      "type": "NDB",
      "freq": 215.0,
      "lat": 23.14139938354492,
      "lon": 72.69969940185547,
      "elev": 0.0,
      "country": "IN",
      "airport": "VAAH"
    },
    "AHC": {
      "name": "Amedee",
      "type": "VOR-DME",
      "freq": 109000.0,
      "lat": 40.26789855957031,
      "lon": -120.1520004272461,
      "elev": 4028.0,
      "country": "US",
      "airport": ""
    },
    "AHH": {
      "name": "Ameron",
      "type": "NDB",
      "freq": 278.0,
      "lat": 45.28139877319336,
      "lon": -92.37129974365234,
      "elev": 1080.0,
      "country": "US",
      "airport": ""
    },
    "AHN": {
      "name": "Athens",
      "type": "VORTAC",
      "freq": 109600.0,
      "lat": 33.947601318359375,
      "lon": -83.32479858398438,
      "elev": 790.0,
      "country": "US",
      "airport": "KAHN"
    },
    "AHO": {
      "name": "Alghero",
      "type": "TACAN",
      "freq": 109300.0,
      "lat": 40.63610076904297,
      "lon": 8.289440155029297,
      "elev": 88.0,
      "country": "IT",
      "airport": "LIEA"
    },
    "AHQ": {
      "name": "Wahoo",
      "type": "NDB",
      "freq": 400.0,
      "lat": 41.239200592041016,
      "lon": -96.59839630126952,
      "elev": 1221.0,
      "country": "US",
      "airport": ""
    },
    "AHT": {
      "name": "Ashiya",
      "type": "TACAN",
      "freq": 108600.0,
      "lat": 33.888301849365234,
      "lon": 130.64999389648438,
      "elev": 84.0,
      "country": "JP",
      "airport": "RJFA"
    },
    "AHX": {
      "name": "Athens",
      "type": "NDB",
      "freq": 269.0,
      "lat": 32.1593017578125,
      "lon": -95.8302001953125,
      "elev": 440.0,
      "country": "US",
      "airport": ""
    },
    "AI": {
      "name": "Sao Joao",
      "type": "NDB",
      "freq": 320.0,
      "lat": -1.2813299894332886,
      "lon": -44.90330123901367,
      "elev": 0.0,
      "country": "BR",
      "airport": ""
    },
    "AIA": {
      "name": "Alliance",
      "type": "VOR-DME",
      "freq": 111800.0,
      "lat": 42.05559921264648,
      "lon": -102.8040008544922,
      "elev": 3925.0,
      "country": "US",
      "airport": ""
    },
    "AIG": {
      "name": "Antigo",
      "type": "NDB",
      "freq": 347.0,
      "lat": 45.158599853515625,
      "lon": -89.11380004882812,
      "elev": 1518.0,
      "country": "US",
      "airport": ""
    },
    "AIK": {
      "name": "Aiken",
      "type": "NDB",
      "freq": 347.0,
      "lat": 33.651798248291016,
      "lon": -81.6771011352539,
      "elev": 530.0,
      "country": "US",
      "airport": ""
    },
    "AIN": {
      "name": "Al Ain",
      "type": "NDB",
      "freq": 399.0,
      "lat": 24.24860000610352,
      "lon": 55.60430145263672,
      "elev": 0.0,
      "country": "AE",
      "airport": "OMAL"
    },
    "AIO": {
      "name": "Atlantic",
      "type": "NDB",
      "freq": 365.0,
      "lat": 41.40399932861328,
      "lon": -95.04630279541016,
      "elev": 1153.0,
      "country": "US",
      "airport": ""
    },
    "AIR": {
      "name": "Bellaire",
      "type": "VOR-DME",
      "freq": 117100.0,
      "lat": 40.016998291015625,
      "lon": -80.81729888916016,
      "elev": 1290.0,
      "country": "US",
      "airport": ""
    },
    "AIT": {
      "name": "Aitkin",
      "type": "NDB",
      "freq": 397.0,
      "lat": 46.54750061035156,
      "lon": -93.67520141601562,
      "elev": 1207.0,
      "country": "US",
      "airport": ""
    },
    "AIV": {
      "name": "Aliceville",
      "type": "NDB",
      "freq": 254.0,
      "lat": 33.11399841308594,
      "lon": -88.18560028076172,
      "elev": 0.0,
      "country": "US",
      "airport": "KAIV"
    },
    "AIX": {
      "name": "Nanwak",
      "type": "NDB-DME",
      "freq": 323.0,
      "lat": 60.3849983215332,
      "lon": -166.21499633789062,
      "elev": 33.0,
      "country": "US",
      "airport": "PAMY"
    },
    "AIZ": {
      "name": "Kaiser",
      "type": "NDB",
      "freq": 377.0,
      "lat": 38.09659957885742,
      "lon": -92.5531005859375,
      "elev": 863.0,
      "country": "US",
      "airport": ""
    },
    "AJ": {
      "name": "Ouani",
      "type": "NDB",
      "freq": 369.0,
      "lat": -12.131999969482422,
      "lon": 44.4286003112793,
      "elev": 0.0,
      "country": "KM",
      "airport": "FMCV"
    },
    "AJA": {
      "name": "Mt Macajna",
      "type": "NDB",
      "freq": 385.0,
      "lat": 13.454899787902832,
      "lon": 144.73699951171875,
      "elev": 660.0,
      "country": "GU",
      "airport": "PGUM"
    },
    "AJE": {
      "name": "Awaji",
      "type": "VOR-DME",
      "freq": 115600.0,
      "lat": 34.270301818847656,
      "lon": 134.71299743652344,
      "elev": 884.0,
      "country": "JP",
      "airport": ""
    },
    "AJF": {
      "name": "Al Jouf",
      "type": "VORTAC",
      "freq": 117800.0,
      "lat": 29.78899955749512,
      "lon": 40.07419967651367,
      "elev": 2261.0,
      "country": "SA",
      "airport": "OESK"
    },
    "AJG": {
      "name": "Mt Carmel",
      "type": "NDB",
      "freq": 524.0,
      "lat": 38.61199951171875,
      "lon": -87.7260971069336,
      "elev": 430.0,
      "country": "US",
      "airport": ""
    },
    "AJO": {
      "name": "Ajaccio",
      "type": "VOR-DME",
      "freq": 114800.0,
      "lat": 41.77050018310547,
      "lon": 8.774669647216797,
      "elev": 2142.0,
      "country": "FR",
      "airport": ""
    },
    "AJR": {
      "name": "Habersham",
      "type": "NDB",
      "freq": 347.0,
      "lat": 34.50149917602539,
      "lon": -83.54989624023438,
      "elev": 1462.0,
      "country": "US",
      "airport": ""
    },
    "AJW": {
      "name": "Andri",
      "type": "NDB",
      "freq": 281.0,
      "lat": 45.79169845581055,
      "lon": -95.30549621582033,
      "elev": 1404.0,
      "country": "US",
      "airport": ""
    },
    "AJX": {
      "name": "Ash Flat",
      "type": "NDB",
      "freq": 344.0,
      "lat": 36.18059921264648,
      "lon": -91.60659790039062,
      "elev": 815.0,
      "country": "US",
      "airport": ""
    },
    "AK": {
      "name": "Astra Kesetra",
      "type": "NDB",
      "freq": 221.0,
      "lat": -4.612420082092285,
      "lon": 105.2310028076172,
      "elev": 63.0,
      "country": "ID",
      "airport": "WIAG"
    },
    "AKB": {
      "name": "Aktyubinsk",
      "type": "VOR-DME",
      "freq": 113400.0,
      "lat": 50.26309967041016,
      "lon": 57.18389892578125,
      "elev": 735.0,
      "country": "KZ",
      "airport": "UATT"
    },
    "AKC": {
      "name": "Trabzon",
      "type": "NDB",
      "freq": 392.0,
      "lat": 41.08940124511719,
      "lon": 39.469200134277344,
      "elev": 104.0,
      "country": "TR",
      "airport": "LTCG"
    },
    "AKE": {
      "name": "Amakusa",
      "type": "VOR-DME",
      "freq": 113450.0,
      "lat": 32.48099899291992,
      "lon": 130.16000366210938,
      "elev": 354.0,
      "country": "JP",
      "airport": "RJDA"
    },
    "AKI": {
      "name": "Akhisar",
      "type": "TACAN",
      "freq": 110200.0,
      "lat": 38.81949996948242,
      "lon": 27.82719993591309,
      "elev": 285.0,
      "country": "TR",
      "airport": "LTBT"
    },
    "AKJ": {
      "name": "Al Kharj",
      "type": "VORTAC",
      "freq": 117300.0,
      "lat": 24.068199157714844,
      "lon": 47.40760040283203,
      "elev": 1479.0,
      "country": "SA",
      "airport": ""
    },
    "AKL": {
      "name": "Haskell",
      "type": "NDB",
      "freq": 407.0,
      "lat": 33.19110107421875,
      "lon": -99.72000122070312,
      "elev": 1622.0,
      "country": "US",
      "airport": ""
    },
    "AKN": {
      "name": "King Salmon",
      "type": "VORTAC",
      "freq": 112800.0,
      "lat": 58.724700927734375,
      "lon": -156.7519989013672,
      "elev": 89.0,
      "country": "US",
      "airport": "PAKN"
    },
    "AKO": {
      "name": "Akron",
      "type": "VOR-DME",
      "freq": 114400.0,
      "lat": 40.15560150146485,
      "lon": -103.18000030517578,
      "elev": 4620.0,
      "country": "US",
      "airport": ""
    },
    "AKP": {
      "name": "Anaktuvuk Pass",
      "type": "NDB",
      "freq": 348.0,
      "lat": 68.1365966796875,
      "lon": -151.74400329589844,
      "elev": 2085.0,
      "country": "US",
      "airport": "PAKP"
    },
    "AKQ": {
      "name": "Wakefield",
      "type": "NDB",
      "freq": 274.0,
      "lat": 36.98320007324219,
      "lon": -77.0010986328125,
      "elev": 115.0,
      "country": "US",
      "airport": ""
    },
    "AKR": {
      "name": "Akrotiri",
      "type": "TACAN",
      "freq": 116000.0,
      "lat": 34.57939910888672,
      "lon": 32.962799072265625,
      "elev": 237.0,
      "country": "CY",
      "airport": "LCRA"
    },
    "AKT": {
      "name": "Akeno",
      "type": "TACAN",
      "freq": 112050.0,
      "lat": 34.528499603271484,
      "lon": 136.6750030517578,
      "elev": 20.0,
      "country": "JP",
      "airport": "RJOE"
    },
    "AKU": {
      "name": "Akujarvi",
      "type": "NDB",
      "freq": 432.0,
      "lat": 68.67839813232422,
      "lon": 27.614599227905277,
      "elev": 0.0,
      "country": "FI",
      "airport": "EFIV"
    },
    "AKW": {
      "name": "Klawock",
      "type": "NDB-DME",
      "freq": 229.0,
      "lat": 55.56859970092773,
      "lon": -133.07899475097656,
      "elev": 30.0,
      "country": "US",
      "airport": "PAKW"
    },
    "AL": {
      "name": "Malolo",
      "type": "NDB",
      "freq": 385.0,
      "lat": -17.825599670410156,
      "lon": 177.38699340820312,
      "elev": 0.0,
      "country": "FJ",
      "airport": "NFFN"
    },
    "ALA": {
      "name": "Alta",
      "type": "NDB",
      "freq": 358.0,
      "lat": 69.99230194091797,
      "lon": 23.29319953918457,
      "elev": 44.0,
      "country": "NO",
      "airport": "ENAT"
    },
    "ALB": {
      "name": "Albany",
      "type": "VORTAC",
      "freq": 115300.0,
      "lat": 42.74720001220703,
      "lon": -73.8031997680664,
      "elev": 275.0,
      "country": "US",
      "airport": "KALB"
    },
    "ALC": {
      "name": "Amami",
      "type": "VORTAC",
      "freq": 115500.0,
      "lat": 28.443700790405277,
      "lon": 129.58399963378906,
      "elev": 996.0,
      "country": "JP",
      "airport": "RJKA"
    },
    "ALD": {
      "name": "Allendale",
      "type": "VOR",
      "freq": 116700.0,
      "lat": 33.01250076293945,
      "lon": -81.29219818115234,
      "elev": 190.0,
      "country": "US",
      "airport": ""
    },
    "ALE": {
      "name": "Aleppo",
      "type": "VOR-DME",
      "freq": 114500.0,
      "lat": 36.17919921875,
      "lon": 37.209598541259766,
      "elev": 1276.0,
      "country": "SY",
      "airport": "OSAP"
    },
    "ALF": {
      "name": "Alster",
      "type": "DME",
      "freq": 115800.0,
      "lat": 53.63529968261719,
      "lon": 9.994139671325684,
      "elev": 66.0,
      "country": "DE",
      "airport": "EDDH"
    },
    "ALG": {
      "name": "Alghero",
      "type": "VORTAC",
      "freq": 113800.0,
      "lat": 40.62810134887695,
      "lon": 8.243889808654785,
      "elev": 1447.0,
      "country": "IT",
      "airport": "LIEA"
    },
    "ALI": {
      "name": "Alice",
      "type": "VOR",
      "freq": 114500.0,
      "lat": 27.73979949951172,
      "lon": -98.02130126953124,
      "elev": 170.0,
      "country": "US",
      "airport": "KALI"
    },
    "ALJ": {
      "name": "Orca Bay",
      "type": "NDB",
      "freq": 233.0,
      "lat": 60.47980117797852,
      "lon": -146.58700561523438,
      "elev": 31.0,
      "country": "US",
      "airport": "PANC"
    },
    "ALM": {
      "name": "Alma",
      "type": "VOR",
      "freq": 116400.0,
      "lat": 55.41130065917969,
      "lon": 13.557499885559082,
      "elev": 0.0,
      "country": "SE",
      "airport": ""
    },
    "ALN": {
      "name": "Al Ain",
      "type": "VOR-DME",
      "freq": 112600.0,
      "lat": 24.25979995727539,
      "lon": 55.60639953613281,
      "elev": 842.0,
      "country": "AE",
      "airport": "OMAL"
    },
    "ALO": {
      "name": "Waterloo",
      "type": "VORTAC",
      "freq": 112200.0,
      "lat": 42.55649948120117,
      "lon": -92.3989028930664,
      "elev": 865.0,
      "country": "US",
      "airport": "KALO"
    },
    "ALP": {
      "name": "Alexandroupolis",
      "type": "NDB",
      "freq": 351.0,
      "lat": 40.85749816894531,
      "lon": 25.94420051574707,
      "elev": 0.0,
      "country": "GR",
      "airport": "LGAL"
    },
    "ALR": {
      "name": "Alger",
      "type": "VOR-DME",
      "freq": 112500.0,
      "lat": 36.69110107421875,
      "lon": 3.215559959411621,
      "elev": 82.0,
      "country": "DZ",
      "airport": "DAAG"
    },
    "ALS": {
      "name": "Alsie",
      "type": "VOR",
      "freq": 114700.0,
      "lat": 54.905399322509766,
      "lon": 9.993379592895508,
      "elev": 0.0,
      "country": "DK",
      "airport": ""
    },
    "ALT": {
      "name": "Alicante",
      "type": "VOR-DME",
      "freq": 113800.0,
      "lat": 38.2682991027832,
      "lon": -0.570114016532898,
      "elev": 166.0,
      "country": "ES",
      "airport": "LEAL"
    },
    "ALU": {
      "name": "Al Hoceima",
      "type": "NDB",
      "freq": 401.0,
      "lat": 35.18119812011719,
      "lon": -3.844559907913208,
      "elev": 0.0,
      "country": "MA",
      "airport": "GMTA"
    },
    "ALW": {
      "name": "Walla Walla",
      "type": "VOR-DME",
      "freq": 116400.0,
      "lat": 46.08700180053711,
      "lon": -118.29299926757812,
      "elev": 1150.0,
      "country": "US",
      "airport": "KALW"
    },
    "ALX": {
      "name": "Alexandroupolis",
      "type": "VOR-DME",
      "freq": 113800.0,
      "lat": 40.85499954223633,
      "lon": 25.957199096679688,
      "elev": 26.0,
      "country": "GR",
      "airport": "LGAL"
    },
    "AM": {
      "name": "Ambriz",
      "type": "NDB",
      "freq": 395.0,
      "lat": -7.833330154418945,
      "lon": 13.100000381469728,
      "elev": 0.0,
      "country": "AO",
      "airport": "FNAM"
    },
    "AMB": {
      "name": "Amberley",
      "type": "TACAN",
      "freq": 114700.0,
      "lat": -27.641700744628903,
      "lon": 152.71600341796875,
      "elev": 91.0,
      "country": "AU",
      "airport": "YAMB"
    },
    "AME": {
      "name": "Kasari",
      "type": "VOR-DME",
      "freq": 113950.0,
      "lat": 28.43470001220703,
      "lon": 129.71099853515625,
      "elev": 47.0,
      "country": "JP",
      "airport": "RJKA"
    },
    "AMF": {
      "name": "Ambler",
      "type": "NDB-DME",
      "freq": 403.0,
      "lat": 67.10679626464844,
      "lon": -157.85800170898438,
      "elev": 282.0,
      "country": "US",
      "airport": "PAFM"
    },
    "AMG": {
      "name": "Alma",
      "type": "VORTAC",
      "freq": 115100.0,
      "lat": 31.536500930786133,
      "lon": -82.50810241699219,
      "elev": 200.0,
      "country": "US",
      "airport": ""
    },
    "AMK": {
      "name": "Andamooka",
      "type": "NDB",
      "freq": 206.0,
      "lat": -30.453500747680664,
      "lon": 137.16700744628906,
      "elev": 0.0,
      "country": "AU",
      "airport": "YAMK"
    },
    "AML": {
      "name": "Armel",
      "type": "VORTAC",
      "freq": 113500.0,
      "lat": 38.934600830078125,
      "lon": -77.4666976928711,
      "elev": 297.0,
      "country": "US",
      "airport": "KIAD"
    },
    "AMN": {
      "name": "Ambon",
      "type": "VOR-DME",
      "freq": 115500.0,
      "lat": -3.614919900894165,
      "lon": 128.18600463867188,
      "elev": 33.0,
      "country": "ID",
      "airport": "WAPP"
    },
    "AMP": {
      "name": "Amapa",
      "type": "NDB",
      "freq": 275.0,
      "lat": 2.0688300132751465,
      "lon": -50.86050033569336,
      "elev": 184.0,
      "country": "BR",
      "airport": "SBAM"
    },
    "AMR": {
      "name": "Almeria",
      "type": "VOR-DME",
      "freq": 114100.0,
      "lat": 36.83319854736328,
      "lon": -2.2594199180603027,
      "elev": 233.0,
      "country": "ES",
      "airport": "LEAM"
    },
    "AMS": {
      "name": "Amsterdam",
      "type": "VOR-DME",
      "freq": 113950.0,
      "lat": 52.332801818847656,
      "lon": 4.705560207366943,
      "elev": -7.0,
      "country": "NL",
      "airport": ""
    },
    "AMT": {
      "name": "West Union",
      "type": "NDB",
      "freq": 359.0,
      "lat": 38.855899810791016,
      "lon": -83.56379699707031,
      "elev": 886.0,
      "country": "US",
      "airport": ""
    },
    "AMU": {
      "name": "Amberieu",
      "type": "TACAN",
      "freq": 116300.0,
      "lat": 45.98860168457031,
      "lon": 5.331250190734863,
      "elev": 801.0,
      "country": "FR",
      "airport": "LFXA"
    },
    "AMV": {
      "name": "Ambato",
      "type": "VOR-DME",
      "freq": 112700.0,
      "lat": -1.285889983177185,
      "lon": -78.54630279541016,
      "elev": 9978.0,
      "country": "EC",
      "airport": "SEAM"
    },
    "AN": {
      "name": "Ann",
      "type": "NDB",
      "freq": 385.0,
      "lat": 19.770299911499023,
      "lon": 94.04019927978516,
      "elev": 74.0,
      "country": "MM",
      "airport": "VYTD"
    },
    "ANA": {
      "name": "Santa Ana",
      "type": "NDB",
      "freq": 345.0,
      "lat": -13.762999534606934,
      "lon": -65.43229675292969,
      "elev": 0.0,
      "country": "BO",
      "airport": "SLSA"
    },
    "ANB": {
      "name": "Annaba",
      "type": "VOR-DME",
      "freq": 113500.0,
      "lat": 36.81669998168945,
      "lon": 7.800000190734863,
      "elev": 16.0,
      "country": "DZ",
      "airport": "DABB"
    },
    "ANC": {
      "name": "Ancona",
      "type": "VOR-DME",
      "freq": 110650.0,
      "lat": 43.58639907836914,
      "lon": 13.471099853515623,
      "elev": 842.0,
      "country": "IT",
      "airport": "LIPY"
    },
    "AND": {
      "name": "Andong",
      "type": "VOR-DME",
      "freq": 114800.0,
      "lat": 30.25329971313477,
      "lon": 121.21800231933594,
      "elev": 17.0,
      "country": "CN",
      "airport": ""
    },
    "ANE": {
      "name": "Arlanda",
      "type": "DME",
      "freq": 113300.0,
      "lat": 59.69400024414063,
      "lon": 18.05990028381348,
      "elev": 108.0,
      "country": "SE",
      "airport": ""
    },
    "ANG": {
      "name": "Angers",
      "type": "VOR",
      "freq": 113000.0,
      "lat": 47.53689956665039,
      "lon": -0.8518329858779907,
      "elev": 283.0,
      "country": "FR",
      "airport": ""
    },
    "ANI": {
      "name": "Aniak",
      "type": "NDB",
      "freq": 359.0,
      "lat": 61.5901985168457,
      "lon": -159.59800720214844,
      "elev": 0.0,
      "country": "US",
      "airport": "PANI"
    },
    "ANK": {
      "name": "Anarak",
      "type": "VOR-DME",
      "freq": 112700.0,
      "lat": 33.537498474121094,
      "lon": 53.72969818115234,
      "elev": 3348.0,
      "country": "IR",
      "airport": ""
    },
    "ANL": {
      "name": "Nea Anchialos",
      "type": "TACAN",
      "freq": 115600.0,
      "lat": 39.21390151977539,
      "lon": 22.744199752807617,
      "elev": 313.0,
      "country": "GR",
      "airport": "LGBL"
    },
    "ANN": {
      "name": "Annette Island",
      "type": "VOR-DME",
      "freq": 117100.0,
      "lat": 55.06039810180664,
      "lon": -131.5780029296875,
      "elev": 174.0,
      "country": "US",
      "airport": "PANT"
    },
    "ANP": {
      "name": "Anapolis",
      "type": "VOR-DME",
      "freq": 115400.0,
      "lat": -16.260700225830078,
      "lon": -48.992000579833984,
      "elev": 2960.0,
      "country": "BR",
      "airport": "SBAN"
    },
    "ANQ": {
      "name": "Angola",
      "type": "NDB",
      "freq": 347.0,
      "lat": 41.63980102539063,
      "lon": -85.08689880371094,
      "elev": 982.0,
      "country": "US",
      "airport": ""
    },
    "ANR": {
      "name": "Andrews",
      "type": "NDB",
      "freq": 245.0,
      "lat": 32.34859848022461,
      "lon": -102.53600311279295,
      "elev": 3170.0,
      "country": "US",
      "airport": ""
    },
    "ANS": {
      "name": "Ansbach",
      "type": "NDB",
      "freq": 452.0,
      "lat": 49.30970001220703,
      "lon": 10.632800102233888,
      "elev": 1526.0,
      "country": "DE",
      "airport": "ETEB"
    },
    "ANT": {
      "name": "Antwerpen",
      "type": "VOR-DME",
      "freq": 113500.0,
      "lat": 51.19060134887695,
      "lon": 4.472499847412109,
      "elev": 78.0,
      "country": "BE",
      "airport": "EBAW"
    },
    "ANU": {
      "name": "V C Bird",
      "type": "VOR-DME",
      "freq": 114500.0,
      "lat": 17.125900268554688,
      "lon": -61.800201416015625,
      "elev": 400.0,
      "country": "AG",
      "airport": "TAPA"
    },
    "ANV": {
      "name": "Anvik",
      "type": "NDB-DME",
      "freq": 365.0,
      "lat": 62.64139938354492,
      "lon": -160.19000244140625,
      "elev": 358.0,
      "country": "US",
      "airport": "PANV"
    },
    "ANW": {
      "name": "Ainsworth",
      "type": "VOR-DME",
      "freq": 112700.0,
      "lat": 42.56909942626953,
      "lon": -99.9897003173828,
      "elev": 2582.0,
      "country": "US",
      "airport": ""
    },
    "ANX": {
      "name": "Napoleon",
      "type": "VORTAC",
      "freq": 114000.0,
      "lat": 39.095401763916016,
      "lon": -94.12879943847656,
      "elev": 878.0,
      "country": "US",
      "airport": ""
    },
    "ANY": {
      "name": "Anthony",
      "type": "VORTAC",
      "freq": 112900.0,
      "lat": 37.15890121459961,
      "lon": -98.1707000732422,
      "elev": 1390.0,
      "country": "US",
      "airport": ""
    },
    "AO": {
      "name": "Hao",
      "type": "NDB",
      "freq": 370.0,
      "lat": -18.06329917907715,
      "lon": -140.96200561523438,
      "elev": 0.0,
      "country": "PF",
      "airport": "NTTO"
    },
    "AOC": {
      "name": "Arco",
      "type": "NDB",
      "freq": 200.0,
      "lat": 43.5989990234375,
      "lon": -113.34200286865234,
      "elev": 5327.0,
      "country": "US",
      "airport": ""
    },
    "AOG": {
      "name": "Rota",
      "type": "TACAN",
      "freq": 108600.0,
      "lat": 36.64789962768555,
      "lon": -6.34906005859375,
      "elev": 86.0,
      "country": "ES",
      "airport": "LERT"
    },
    "AOH": {
      "name": "Allen Co",
      "type": "VOR",
      "freq": 108400.0,
      "lat": 40.70709991455078,
      "lon": -83.96820068359375,
      "elev": 980.0,
      "country": "US",
      "airport": ""
    },
    "AOO": {
      "name": "Altoona",
      "type": "VOR",
      "freq": 108800.0,
      "lat": 40.32540130615234,
      "lon": -78.30370330810547,
      "elev": 1630.0,
      "country": "US",
      "airport": "KAOO"
    },
    "AOP": {
      "name": "Antelope",
      "type": "NDB",
      "freq": 290.0,
      "lat": 41.60419845581055,
      "lon": -109.0019989013672,
      "elev": 0.0,
      "country": "US",
      "airport": "KRKS"
    },
    "AOV": {
      "name": "Bilmart",
      "type": "NDB",
      "freq": 341.0,
      "lat": 36.96979904174805,
      "lon": -92.67739868164062,
      "elev": 1302.0,
      "country": "US",
      "airport": ""
    },
    "AP": {
      "name": "Active Pass",
      "type": "NDB",
      "freq": 378.0,
      "lat": 48.8739013671875,
      "lon": -123.29000091552734,
      "elev": 0.0,
      "country": "CA",
      "airport": ""
    },
    "APB": {
      "name": "Apolo",
      "type": "NDB",
      "freq": 240.0,
      "lat": -14.685400009155272,
      "lon": -68.4166030883789,
      "elev": 0.0,
      "country": "BO",
      "airport": "SLAP"
    },
    "APE": {
      "name": "Appleton",
      "type": "VORTAC",
      "freq": 116700.0,
      "lat": 40.151100158691406,
      "lon": -82.58830261230469,
      "elev": 1350.0,
      "country": "US",
      "airport": "KLCK"
    },
    "APF": {
      "name": "Naples",
      "type": "NDB",
      "freq": 201.0,
      "lat": 26.15570068359375,
      "lon": -81.77439880371094,
      "elev": 35.0,
      "country": "US",
      "airport": ""
    },
    "APG": {
      "name": "Aberdeen",
      "type": "NDB",
      "freq": 349.0,
      "lat": 39.535099029541016,
      "lon": -76.1063003540039,
      "elev": 45.0,
      "country": "US",
      "airport": "KAPG"
    },
    "APH": {
      "name": "A P Hill",
      "type": "NDB",
      "freq": 396.0,
      "lat": 38.087799072265625,
      "lon": -77.32489776611328,
      "elev": 284.0,
      "country": "US",
      "airport": ""
    },
    "APN": {
      "name": "Alpena",
      "type": "VORTAC",
      "freq": 108800.0,
      "lat": 45.082801818847656,
      "lon": -83.55699920654297,
      "elev": 680.0,
      "country": "US",
      "airport": "KAPN"
    },
    "APT": {
      "name": "Jasper",
      "type": "NDB",
      "freq": 382.0,
      "lat": 35.059600830078125,
      "lon": -85.58390045166016,
      "elev": 643.0,
      "country": "US",
      "airport": ""
    },
    "APU": {
      "name": "Anpu",
      "type": "VOR-DME",
      "freq": 112500.0,
      "lat": 25.17690086364746,
      "lon": 121.52200317382812,
      "elev": 3546.0,
      "country": "TW",
      "airport": "RCSS"
    },
    "AQ": {
      "name": "Barranquilla",
      "type": "NDB",
      "freq": 264.0,
      "lat": 10.871800422668455,
      "lon": -74.79620361328125,
      "elev": 295.0,
      "country": "CO",
      "airport": "SKBQ"
    },
    "AQA": {
      "name": "Aqaba",
      "type": "NDB",
      "freq": 418.0,
      "lat": 30.22649955749512,
      "lon": 35.22140121459961,
      "elev": 856.0,
      "country": "JO",
      "airport": "OJAQ"
    },
    "AQB": {
      "name": "Aqaba",
      "type": "VOR-DME",
      "freq": 113100.0,
      "lat": 29.583499908447266,
      "lon": 35.008201599121094,
      "elev": 175.0,
      "country": "JO",
      "airport": "OJAQ"
    },
    "AQC": {
      "name": "Aqaba",
      "type": "NDB",
      "freq": 326.0,
      "lat": 29.902299880981445,
      "lon": 35.11899948120117,
      "elev": 312.0,
      "country": "JO",
      "airport": "OJAQ"
    },
    "AQE": {
      "name": "Alwood",
      "type": "NDB",
      "freq": 230.0,
      "lat": 35.70690155029297,
      "lon": -77.37190246582031,
      "elev": 0.0,
      "country": "US",
      "airport": ""
    },
    "AQP": {
      "name": "Appleton",
      "type": "NDB",
      "freq": 356.0,
      "lat": 45.22850036621094,
      "lon": -96.0094985961914,
      "elev": 1018.0,
      "country": "US",
      "airport": ""
    },
    "AR": {
      "name": "Le Raizet",
      "type": "NDB",
      "freq": 402.0,
      "lat": 16.286699295043945,
      "lon": -61.63100051879883,
      "elev": 0.0,
      "country": "GP",
      "airport": ""
    },
    "ARA": {
      "name": "Araxos",
      "type": "VOR-DME",
      "freq": 112700.0,
      "lat": 38.10969924926758,
      "lon": 21.42530059814453,
      "elev": 56.0,
      "country": "GR",
      "airport": "LGRX"
    },
    "ARB": {
      "name": "Ardabil",
      "type": "VOR-DME",
      "freq": 115700.0,
      "lat": 38.3031005859375,
      "lon": 48.44100189208984,
      "elev": 4315.0,
      "country": "IR",
      "airport": "OITL"
    },
    "ARD": {
      "name": "Arad",
      "type": "VOR-DME",
      "freq": 109000.0,
      "lat": 46.18410110473633,
      "lon": 21.143600463867188,
      "elev": 341.0,
      "country": "RO",
      "airport": "LRAR"
    },
    "ARE": {
      "name": "Monts D Arree",
      "type": "VOR",
      "freq": 112500.0,
      "lat": 48.33259963989258,
      "lon": -3.6024699211120605,
      "elev": 588.0,
      "country": "FR",
      "airport": ""
    },
    "ARF": {
      "name": "Topel",
      "type": "TACAN",
      "freq": 113900.0,
      "lat": 40.732200622558594,
      "lon": 30.064699172973636,
      "elev": 174.0,
      "country": "TR",
      "airport": "LTBQ"
    },
    "ARG": {
      "name": "Walnut Ridge",
      "type": "VORTAC",
      "freq": 114500.0,
      "lat": 36.11000061035156,
      "lon": -90.95369720458984,
      "elev": 260.0,
      "country": "US",
      "airport": ""
    },
    "ARH": {
      "name": "Libby",
      "type": "TACAN",
      "freq": 111600.0,
      "lat": 31.585599899291992,
      "lon": -110.33899688720705,
      "elev": 4659.0,
      "country": "US",
      "airport": "KFHU"
    },
    "ARI": {
      "name": "Arica",
      "type": "VOR-DME",
      "freq": 116500.0,
      "lat": -18.369400024414062,
      "lon": -70.34639739990234,
      "elev": 88.0,
      "country": "CL",
      "airport": "SCAR"
    },
    "ARK": {
      "name": "Arak",
      "type": "NDB",
      "freq": 280.0,
      "lat": 34.134498596191406,
      "lon": 49.84870147705078,
      "elev": 5440.0,
      "country": "IR",
      "airport": "OIHR"
    },
    "ARL": {
      "name": "Arlanda",
      "type": "VOR-DME",
      "freq": 116000.0,
      "lat": 59.65340042114258,
      "lon": 17.914400100708008,
      "elev": 141.0,
      "country": "SE",
      "airport": "ESSA"
    },
    "ARM": {
      "name": "Armilla",
      "type": "NDB",
      "freq": 344.0,
      "lat": 37.07350158691406,
      "lon": -3.802079916000366,
      "elev": 0.0,
      "country": "ES",
      "airport": "LEGA"
    },
    "ARN": {
      "name": "Arbancon",
      "type": "NDB",
      "freq": 291.0,
      "lat": 40.96390151977539,
      "lon": -3.122459888458252,
      "elev": 0.0,
      "country": "ES",
      "airport": ""
    },
    "ARS": {
      "name": "Ardrossan",
      "type": "VOR",
      "freq": 115800.0,
      "lat": -34.416528,
      "lon": 137.893347,
      "elev": 291.0,
      "country": "AU",
      "airport": ""
    },
    "ART": {
      "name": "Watertown",
      "type": "VORTAC",
      "freq": 109800.0,
      "lat": 43.95199966430664,
      "lon": -76.0645980834961,
      "elev": 370.0,
      "country": "US",
      "airport": "KGTB"
    },
    "ARV": {
      "name": "Arbor Vitae",
      "type": "NDB",
      "freq": 221.0,
      "lat": 45.92679977416992,
      "lon": -89.72850036621094,
      "elev": 1627.0,
      "country": "US",
      "airport": ""
    },
    "ARW": {
      "name": "El Aroui",
      "type": "NDB",
      "freq": 355.0,
      "lat": 34.98970031738281,
      "lon": -3.0441699028015137,
      "elev": 588.0,
      "country": "MA",
      "airport": "GMMW"
    },
    "ARX": {
      "name": "Araxos",
      "type": "TACAN",
      "freq": 112400.0,
      "lat": 38.10820007324219,
      "lon": 21.422700881958008,
      "elev": 55.0,
      "country": "GR",
      "airport": "LGRX"
    },
    "AS": {
      "name": "Agades",
      "type": "VOR",
      "freq": 113500.0,
      "lat": 16.975000381469727,
      "lon": 8.02322006225586,
      "elev": 1673.0,
      "country": "NE",
      "airport": "DRZA"
    },
    "ASB": {
      "name": "Ali Al Salem",
      "type": "VORTAC",
      "freq": 116000.0,
      "lat": 29.3439998626709,
      "lon": 47.51890182495117,
      "elev": 455.0,
      "country": "KW",
      "airport": "OKAS"
    },
    "ASG": {
      "name": "Ascencion De Guarayos",
      "type": "NDB",
      "freq": 390.0,
      "lat": -15.771300315856934,
      "lon": -63.06639862060547,
      "elev": 0.0,
      "country": "BO",
      "airport": "SLAS"
    },
    "ASH": {
      "name": "Al-Shigar",
      "type": "VOR-DME",
      "freq": 112300.0,
      "lat": 30.122800827026367,
      "lon": 38.798099517822266,
      "elev": 1810.0,
      "country": "SA",
      "airport": ""
    },
    "ASI": {
      "name": "Ascension Aux Af",
      "type": "VORTAC",
      "freq": 112200.0,
      "lat": -7.969880104064941,
      "lon": -14.397299766540527,
      "elev": 495.0,
      "country": "SH",
      "airport": "FHAW"
    },
    "ASJ": {
      "name": "Ahoskie",
      "type": "NDB",
      "freq": 415.0,
      "lat": 36.29930114746094,
      "lon": -77.17549896240234,
      "elev": 218.0,
      "country": "US",
      "airport": ""
    },
    "ASK": {
      "name": "Askoy",
      "type": "NDB",
      "freq": 360.0,
      "lat": 60.422000885009766,
      "lon": 5.18025016784668,
      "elev": 187.0,
      "country": "NO",
      "airport": "ENBR"
    },
    "ASL": {
      "name": "Asaloyeh",
      "type": "NDB",
      "freq": 447.0,
      "lat": 27.48189926147461,
      "lon": 52.6161003112793,
      "elev": 15.0,
      "country": "IR",
      "airport": "IR-0174"
    },
    "ASM": {
      "name": "Asmara",
      "type": "VOR-DME",
      "freq": 113700.0,
      "lat": 15.284000396728516,
      "lon": 38.9009017944336,
      "elev": 7661.0,
      "country": "ER",
      "airport": "HHAS"
    },
    "ASN": {
      "name": "Aswan",
      "type": "VOR-DME",
      "freq": 112300.0,
      "lat": 23.971799850463867,
      "lon": 32.81700134277344,
      "elev": 668.0,
      "country": "EG",
      "airport": "HESN"
    },
    "ASP": {
      "name": "Au Sable",
      "type": "VOR-DME",
      "freq": 116100.0,
      "lat": 44.449100494384766,
      "lon": -83.39430236816406,
      "elev": 627.0,
      "country": "US",
      "airport": ""
    },
    "ASS": {
      "name": "Assis",
      "type": "NDB",
      "freq": 275.0,
      "lat": -22.644800186157227,
      "lon": -50.45299911499024,
      "elev": 1850.0,
      "country": "BR",
      "airport": "SNAX"
    },
    "AST": {
      "name": "Asyut",
      "type": "VOR-DME",
      "freq": 117700.0,
      "lat": 27.031200408935547,
      "lon": 31.03249931335449,
      "elev": 850.0,
      "country": "EG",
      "airport": "HEAT"
    },
    "ASU": {
      "name": "Asuncion",
      "type": "NDB",
      "freq": 360.0,
      "lat": -25.23579978942871,
      "lon": -57.51309967041016,
      "elev": 401.0,
      "country": "PY",
      "airport": "SGAS"
    },
    "ASW": {
      "name": "Arlanda",
      "type": "DME",
      "freq": 113750.0,
      "lat": 59.58769989013672,
      "lon": 17.819700241088867,
      "elev": 233.0,
      "country": "SE",
      "airport": ""
    },
    "ASX": {
      "name": "Ashland",
      "type": "VOR-DME",
      "freq": 110200.0,
      "lat": 46.54940032958984,
      "lon": -90.91719818115234,
      "elev": 820.0,
      "country": "US",
      "airport": ""
    },
    "AT": {
      "name": "Atiu",
      "type": "NDB",
      "freq": 388.0,
      "lat": -20.00329971313477,
      "lon": -158.10699462890625,
      "elev": 0.0,
      "country": "CK",
      "airport": "NCAT"
    },
    "ATA": {
      "name": "Alta",
      "type": "VOR-DME",
      "freq": 117400.0,
      "lat": 69.97760009765625,
      "lon": 23.37179946899414,
      "elev": 32.0,
      "country": "NO",
      "airport": "ENAT"
    },
    "ATB": {
      "name": "Atbara",
      "type": "NDB",
      "freq": 273.0,
      "lat": 17.713899612426758,
      "lon": 34.0536994934082,
      "elev": 0.0,
      "country": "SD",
      "airport": "HSAT"
    },
    "ATE": {
      "name": "Akita",
      "type": "VOR-DME",
      "freq": 116100.0,
      "lat": 39.71160125732422,
      "lon": 140.06199645996094,
      "elev": 54.0,
      "country": "JP",
      "airport": "RJSK"
    },
    "ATF": {
      "name": "Alta Floresta",
      "type": "VOR-DME",
      "freq": 113400.0,
      "lat": -9.868359565734863,
      "lon": -56.10490036010742,
      "elev": 947.0,
      "country": "BR",
      "airport": "SBAT"
    },
    "ATK": {
      "name": "Atqasuk",
      "type": "NDB",
      "freq": 350.0,
      "lat": 70.46910095214844,
      "lon": -157.427001953125,
      "elev": 93.0,
      "country": "US",
      "airport": "PATQ"
    },
    "ATL": {
      "name": "Atlanta",
      "type": "VORTAC",
      "freq": 116900.0,
      "lat": 33.62910079956055,
      "lon": -84.43509674072266,
      "elev": 1000.0,
      "country": "US",
      "airport": "KATL"
    },
    "ATM": {
      "name": "Altamira",
      "type": "VOR",
      "freq": 113200.0,
      "lat": -3.2493300437927246,
      "lon": -52.24769973754883,
      "elev": 367.0,
      "country": "BR",
      "airport": "SBHT"
    },
    "ATN": {
      "name": "Autun",
      "type": "VOR-DME",
      "freq": 114900.0,
      "lat": 46.80590057373047,
      "lon": 4.2591400146484375,
      "elev": 2244.0,
      "country": "FR",
      "airport": ""
    },
    "ATR": {
      "name": "Atyrau",
      "type": "VOR-DME",
      "freq": 112300.0,
      "lat": 47.14390182495117,
      "lon": 51.80279922485352,
      "elev": -82.0,
      "country": "KZ",
      "airport": "UATG"
    },
    "ATS": {
      "name": "Artesia",
      "type": "NDB",
      "freq": 414.0,
      "lat": 32.85260009765625,
      "lon": -104.46199798583984,
      "elev": 3503.0,
      "country": "US",
      "airport": ""
    },
    "ATU": {
      "name": "Attu",
      "type": "NDB",
      "freq": 375.0,
      "lat": 52.82889938354492,
      "lon": 173.17999267578125,
      "elev": 40.0,
      "country": "US",
      "airport": ""
    },
    "ATV": {
      "name": "Athinai",
      "type": "VOR-DME",
      "freq": 114400.0,
      "lat": 37.88859939575195,
      "lon": 23.81439971923828,
      "elev": 1535.0,
      "country": "GR",
      "airport": ""
    },
    "ATY": {
      "name": "Watertown",
      "type": "VORTAC",
      "freq": 116600.0,
      "lat": 44.97969818115234,
      "lon": -97.1417007446289,
      "elev": 1750.0,
      "country": "US",
      "airport": "KATY"
    },
    "AU": {
      "name": "Akhsu",
      "type": "NDB",
      "freq": 420.0,
      "lat": 40.56669998168945,
      "lon": 48.38330078125,
      "elev": 0.0,
      "country": "AZ",
      "airport": ""
    },
    "AUC": {
      "name": "Arauca",
      "type": "VOR-DME",
      "freq": 114000.0,
      "lat": 7.067150115966797,
      "lon": -70.7322006225586,
      "elev": 424.0,
      "country": "CO",
      "airport": "SKUC"
    },
    "AUG": {
      "name": "Augusta",
      "type": "VOR-DME",
      "freq": 111400.0,
      "lat": 44.31999969482422,
      "lon": -69.79660034179688,
      "elev": 349.0,
      "country": "US",
      "airport": ""
    },
    "AUH": {
      "name": "Abu Dhabi",
      "type": "VOR-DME",
      "freq": 113000.0,
      "lat": 24.443199157714844,
      "lon": 54.64649963378906,
      "elev": 68.0,
      "country": "AE",
      "airport": "OMAA"
    },
    "AUR": {
      "name": "La Aurora",
      "type": "VOR-DME",
      "freq": 114500.0,
      "lat": 14.590999603271484,
      "lon": -90.5260009765625,
      "elev": 4952.0,
      "country": "GT",
      "airport": "MGGT"
    },
    "AUW": {
      "name": "Wausau",
      "type": "VORTAC",
      "freq": 111600.0,
      "lat": 44.8468017578125,
      "lon": -89.58660125732422,
      "elev": 1210.0,
      "country": "US",
      "airport": ""
    },
    "AV": {
      "name": "Avalon",
      "type": "VOR-DME",
      "freq": 116100.0,
      "lat": -38.04890060424805,
      "lon": 144.45899963378906,
      "elev": 35.0,
      "country": "AU",
      "airport": "YMAV"
    },
    "AVD": {
      "name": "Avord",
      "type": "TACAN",
      "freq": 110600.0,
      "lat": 47.058101654052734,
      "lon": 2.6298599243164062,
      "elev": 554.0,
      "country": "FR",
      "airport": "LFOA"
    },
    "AVE": {
      "name": "Avenal",
      "type": "VORTAC",
      "freq": 117100.0,
      "lat": 35.64699935913086,
      "lon": -119.97899627685548,
      "elev": 710.0,
      "country": "US",
      "airport": ""
    },
    "AVI": {
      "name": "Aviano",
      "type": "TACAN",
      "freq": 116400.0,
      "lat": 46.02790069580078,
      "lon": 12.586899757385254,
      "elev": 413.0,
      "country": "IT",
      "airport": "LIPA"
    },
    "AVK": {
      "name": "Alva",
      "type": "NDB",
      "freq": 203.0,
      "lat": 36.77920150756836,
      "lon": -98.67120361328124,
      "elev": 1474.0,
      "country": "US",
      "airport": ""
    },
    "AVN": {
      "name": "Avignon",
      "type": "VOR",
      "freq": 112300.0,
      "lat": 43.995399475097656,
      "lon": 4.746389865875244,
      "elev": 0.0,
      "country": "FR",
      "airport": ""
    },
    "AVQ": {
      "name": "Marana",
      "type": "NDB",
      "freq": 245.0,
      "lat": 32.411800384521484,
      "lon": -111.21600341796876,
      "elev": 2021.0,
      "country": "US",
      "airport": ""
    },
    "AVZ": {
      "name": "Travis",
      "type": "NDB",
      "freq": 260.0,
      "lat": 32.760101318359375,
      "lon": -96.24909973144533,
      "elev": 491.0,
      "country": "US",
      "airport": ""
    },
    "AW": {
      "name": "Waton",
      "type": "NDB",
      "freq": 382.0,
      "lat": 48.07609939575195,
      "lon": -122.15399932861328,
      "elev": 61.0,
      "country": "US",
      "airport": ""
    },
    "AWE": {
      "name": "Asahikawa",
      "type": "VOR-DME",
      "freq": 113500.0,
      "lat": 43.66730117797852,
      "lon": 142.45700073242188,
      "elev": 769.0,
      "country": "JP",
      "airport": "RJEC"
    },
    "AWG": {
      "name": "Washington",
      "type": "NDB",
      "freq": 219.0,
      "lat": 41.27980041503906,
      "lon": -91.67259979248048,
      "elev": 770.0,
      "country": "US",
      "airport": ""
    },
    "AWK": {
      "name": "Wake Island",
      "type": "VORTAC",
      "freq": 113500.0,
      "lat": 19.28499984741211,
      "lon": 166.6280059814453,
      "elev": 10.0,
      "country": "UM",
      "airport": "PWAK"
    },
    "AWM": {
      "name": "West Memphis",
      "type": "NDB",
      "freq": 362.0,
      "lat": 35.139400482177734,
      "lon": -90.23259735107422,
      "elev": 212.0,
      "country": "US",
      "airport": ""
    },
    "AWS": {
      "name": "Lawson",
      "type": "NDB",
      "freq": 335.0,
      "lat": 32.2932014465332,
      "lon": -85.02330017089844,
      "elev": 407.0,
      "country": "US",
      "airport": "KLSF"
    },
    "AWZ": {
      "name": "Ahwaz",
      "type": "VOR-DME",
      "freq": 114000.0,
      "lat": 31.33760070800781,
      "lon": 48.76430130004883,
      "elev": 66.0,
      "country": "IR",
      "airport": "OIAW"
    },
    "AX": {
      "name": "Axum",
      "type": "NDB",
      "freq": 440.0,
      "lat": 14.145999908447266,
      "lon": 38.77629852294922,
      "elev": 6319.0,
      "country": "ET",
      "airport": "HAAX"
    },
    "AXA": {
      "name": "Algona",
      "type": "NDB",
      "freq": 403.0,
      "lat": 43.08140182495117,
      "lon": -94.27249908447266,
      "elev": 1210.0,
      "country": "US",
      "airport": ""
    },
    "AXC": {
      "name": "Decatur",
      "type": "VORTAC",
      "freq": 117200.0,
      "lat": 39.7375214,
      "lon": -88.8564314,
      "elev": 708.0,
      "country": "US",
      "airport": "KDEC"
    },
    "AXD": {
      "name": "Alexandria",
      "type": "NDB",
      "freq": 403.0,
      "lat": 31.194900512695312,
      "lon": 29.95249938964844,
      "elev": 60.0,
      "country": "EG",
      "airport": "EG-0078"
    },
    "AXM": {
      "name": "Armenia",
      "type": "NDB",
      "freq": 315.0,
      "lat": 4.451350212097168,
      "lon": -75.77290344238281,
      "elev": 3960.0,
      "country": "CO",
      "airport": "SKAR"
    },
    "AXN": {
      "name": "Alexandria",
      "type": "VOR-DME",
      "freq": 112800.0,
      "lat": 45.95840072631836,
      "lon": -95.23259735107422,
      "elev": 1380.0,
      "country": "US",
      "airport": "KAXN"
    },
    "AY": {
      "name": "Albury",
      "type": "VOR-DME",
      "freq": 115600.0,
      "lat": -36.06809997558594,
      "lon": 146.96600341796875,
      "elev": 550.0,
      "country": "AU",
      "airport": "YMAY"
    },
    "AYA": {
      "name": "Ayacucho",
      "type": "NDB",
      "freq": 370.0,
      "lat": -13.151900291442873,
      "lon": -74.2052993774414,
      "elev": 8994.0,
      "country": "PE",
      "airport": "SPHO"
    },
    "AYE": {
      "name": "Ayers Rock",
      "type": "NDB-DME",
      "freq": 233.0,
      "lat": -25.172800064086918,
      "lon": 130.97500610351562,
      "elev": 1636.0,
      "country": "AU",
      "airport": "YAYE"
    },
    "AYS": {
      "name": "Waycross",
      "type": "VORTAC",
      "freq": 110200.0,
      "lat": 31.269399642944336,
      "lon": -82.556396484375,
      "elev": 150.0,
      "country": "US",
      "airport": ""
    },
    "AYT": {
      "name": "Antalya",
      "type": "TACAN",
      "freq": 115500.0,
      "lat": 36.91559982299805,
      "lon": 30.78280067443848,
      "elev": 177.0,
      "country": "TR",
      "airport": "LTAI"
    },
    "AZ": {
      "name": "Aizawl",
      "type": "NDB",
      "freq": 366.0,
      "lat": 23.742900848388672,
      "lon": 92.80290222167967,
      "elev": 0.0,
      "country": "IN",
      "airport": "VEAZ"
    },
    "AZC": {
      "name": "Colorado City",
      "type": "NDB",
      "freq": 403.0,
      "lat": 36.95989990234375,
      "lon": -113.00900268554688,
      "elev": 4860.0,
      "country": "US",
      "airport": ""
    },
    "AZE": {
      "name": "Hazlehurst",
      "type": "NDB",
      "freq": 414.0,
      "lat": 31.880199432373047,
      "lon": -82.64739990234375,
      "elev": 240.0,
      "country": "US",
      "airport": ""
    },
    "AZN": {
      "name": "Amazon",
      "type": "NDB",
      "freq": 233.0,
      "lat": 39.88399887084961,
      "lon": -94.908203125,
      "elev": 823.0,
      "country": "US",
      "airport": "KSTJ"
    },
    "AZO": {
      "name": "Kalamazoo",
      "type": "VOR-DME",
      "freq": 109000.0,
      "lat": 42.23699951171875,
      "lon": -85.5531997680664,
      "elev": 870.0,
      "country": "US",
      "airport": "KAZO"
    },
    "AZQ": {
      "name": "Hazard",
      "type": "VOR-DME",
      "freq": 111200.0,
      "lat": 37.391300201416016,
      "lon": -83.26300048828125,
      "elev": 1247.0,
      "country": "US",
      "airport": ""
    },
    "AZR": {
      "name": "Nice Cote D Azur",
      "type": "VOR-DME",
      "freq": 109650.0,
      "lat": 43.659698486328125,
      "lon": 7.224420070648193,
      "elev": 12.0,
      "country": "FR",
      "airport": "LFMN"
    },
    "AZS": {
      "name": "Azalea Park",
      "type": "NDB",
      "freq": 336.0,
      "lat": 38.01020050048828,
      "lon": -78.51809692382812,
      "elev": 378.0,
      "country": "US",
      "airport": "KCHO"
    },
    "AZW": {
      "name": "Mt  iAy",
      "type": "NDB",
      "freq": 223.0,
      "lat": 36.38100051879883,
      "lon": -80.54019927978516,
      "elev": 1037.0,
      "country": "US",
      "airport": ""
    },
  };
}
