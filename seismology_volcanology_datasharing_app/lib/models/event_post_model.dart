library event;

// import 'package:littlefish_feature_models/shared/country';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

part 'anthropogenic_model.dart';
part 'atmospheric_model.dart';
part 'cryoseismic_model.dart';
part 'geodetic_model.dart';
part 'hydrothermal_model.dart';
part 'mass_movement_model.dart';
part 'seismic_model.dart';
part 'volcanic_models.dart';

enum EventType {  // default
  unspecified_anomalous,
  seismic_tectonic,
  volcanicEruptive_surfaceProcess,
  volcanicNonEruptive,
  massMovement_surfaceInstability,
  cryoseismic_glacial,
  hydrothermal_fluidDriven,
  atmospheric_coupledSignals,
  anthropogenic,
  geodetic_deformation,
  multiSensor,
  false_test,
}

enum EventSubtype {  // default
  unspecified,  // default
}

// enum Country {
//   unspecified, Afghanistan, Albania, Algeria, Andorra, Angola, AntiguaAndBarbuda, 
//   Argentina, Armenia, Australia, Austria, Azerbaijan, Bahamas, Bahrain, Bangladesh,
//   Barbados, Belarus, Belgium, Belize, Benin, Bhutan, Bolivia,
//   BosniaAndHerzegovina, Botswana, Brazil, Brunei, Bulgaria, BurkinaFaso, Burma,
//   Burundi, CaboVerde, Cambodia, Cameroon, Canada, CentralAfricanRepublic, Chad,
//   Chile, China, Colombia, Comoros, CongoBrazzaville, CongoKinshasa, CostaRica,
//   CoteDIvoire, Croatia, Cuba, Cyprus, Czechia, Denmark, Djibouti, Dominica,
//   DominicanRepublic, Ecuador, Egypt, ElSalvador, EquatorialGuinea, Eritrea,
//   Estonia, Eswatini, Ethiopia, Fiji, Finland, France, Gabon, Gambia, Georgia,
//   Germany, Ghana, Greece, Grenada, Guatemala, Guinea, GuineaBissau, Guyana,
//   Haiti, HolySee, Honduras, Hungary, Iceland, India, Indonesia, Iran, Iraq,
//   Ireland, Israel, Italy, Jamaica, Japan, Jordan, Kazakhstan, Kenya,
//   Kiribati, NorthKorea, SouthKorea, Kosovo, Kuwait, Kyrgyzstan, Laos, Latvia,
//   Lebanon, Lesotho, Liberia, Libya, Liechtenstein, Lithuania, Luxembourg,
//   Madagascar, Malawi, Malaysia, Maldives, Mali, Malta, MarshallIslands,
//   Mauritania, Mauritius, Mexico, Micronesia, Moldova, Monaco, Mongolia,
//   Montenegro, Morocco, Mozambique, Myanmar, Namibia, Nauru, Nepal, Netherlands,
//   NewZealand, Nicaragua, Niger, Nigeria, NorthMacedonia, Norway, Oman,
//   Pakistan, Palau, Palestine, Panama, PapuaNewGuinea, Paraguay, Peru,
//   Philippines, Poland, Portugal, Qatar, Romania, Russia, Rwanda,
//   SaintKittsAndNevis, SaintLucia, SaintVincentAndTheGrenadines, Samoa, SanMarino,
//   SaoTomeAndPrincipe, SaudiArabia, Senegal, Serbia, Seychelles, SierraLeone,
//   Singapore, Slovakia, Slovenia, SolomonIslands, Somalia, SouthAfrica,
//   SouthSudan, Spain, SriLanka, Sudan, Suriname, Sweden, Switzerland, Syria,
//   Taiwan, Tajikistan, Tanzania, Thailand, TimorLeste, Togo, Tonga,
//   TrinidadAndTobago, Tunisia, Turkey, Turkmenistan, Tuvalu, Uganda, Ukraine,
//   UnitedArabEmirates, UnitedKingdom, UnitedStatesOfAmerica, Uruguay, Uzbekistan,
//   Vanuatu, Venezuela, Vietnam, Yemen, Zambia, Zimbabwe,
// }


enum Country {
  unspecified, afghanistan, albania, algeria, andorra, angola, antiguaAndBarbuda, 
  argentina, armenia, australia, austria, azerbaijan, bahamas, bahrain, bangladesh,
  barbados, belarus, belgium, belize, benin, bhutan, bolivia,
  bosniaAndHerzegovina, botswana, brazil, brunei, bulgaria, burkinaFaso, burma,
  burundi, caboVerde, cambodia, cameroon, canada, centralAfricanRepublic, chad,
  chile, china, colombia, comoros, congoBrazzaville, congoKinshasa, costaRica,
  coteDIvoire, croatia, cuba, cyprus, czechia, denmark, djibouti, dominica,
  dominicanRepublic, ecuador, egypt, elSalvador, equatorialGuinea, eritrea,
  estonia, eswatini, ethiopia, fiji, finland, france, gabon, gambia, georgia,
  germany, ghana, greece, grenada, guatemala, guinea, guineaBissau, guyana,
  haiti, holySee, honduras, hungary, iceland, india, indonesia, iran, iraq,
  ireland, israel, italy, jamaica, japan, jordan, kazakhstan, kenya,
  kiribati, northKorea, southKorea, kosovo, kuwait, kyrgyzstan, laos, latvia,
  lebanon, lesotho, liberia, libya, liechtenstein, lithuania, luxembourg,
  madagascar, malawi, malaysia, maldives, mali, malta, marshallIslands,
  mauritania, mauritius, mexico, micronesia, moldova, monaco, mongolia,
  montenegro, morocco, mozambique, myanmar, namibia, nauru, nepal, netherlands,
  newZealand, nicaragua, niger, nigeria, northMacedonia, norway, oman,
  pakistan, palau, palestine, panama, papuaNewGuinea, paraguay, peru,
  philippines, poland, portugal, qatar, romania, russia, rwanda,
  saintKittsAndNevis, saintLucia, saintVincentAndTheGrenadines, samoa, sanMarino,
  saoTomeAndPrincipe, saudiArabia, senegal, serbia, seychelles, sierraLeone,
  singapore, slovakia, slovenia, solomonIslands, somalia, southAfrica,
  southSudan, spain, sriLanka, sudan, suriname, sweden, switzerland, syria,
  taiwan, tajikistan, tanzania, thailand, timorLeste, togo, tonga,
  trinidadAndTobago, tunisia, turkey, turkmenistan, tuvalu, uganda, ukraine,
  unitedArabEmirates, unitedKingdom, unitedStatesOfAmerica, uruguay, uzbekistan,
  vanuatu, venezuela, vietnam, yemen, zambia, zimbabwe,
}

enum EventPostStatus {
  unspecified, automatic, manual,
}


// String generateRandomString(int len) {
//   var r = Random();
//   return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
// }

var r = Random();
const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890-';
sealed class Event{
  final String id;
  final EventType eventType;
  // EventType eventType = EventType.unspecified_anomalous;
  // EventSubtype eventSubtype = EventSubtype.unspecified;
  
  Country country = Country.unspecified;
  String stateProvince = "";
  String townCity = "";
  double? longitude;
  double? latitude;

  Duration duration = Duration();
  DateTime? startTime;
  DateTimeRange? timeRange;
 
  String source = "";  // or recording station
  EventPostStatus status = EventPostStatus.unspecified;
  String description = "";

  // Event({String? id}) : id = id ?? const Uuid().v4();
  Event({String? id, required this.eventType}) 
    : id = id ?? _generateManualId();

  static String _generateManualId() {
    return String.fromCharCodes(
      Iterable.generate(36, (_) => _chars.codeUnitAt(r.nextInt(_chars.length)))
    );
  }
}

// class EventSeismic extends Event {
//   double? magnitude;
//   double? magnitudeType;
//   double? depth;
//   double? depthUncertainty;
//   String focalMechanism = "";

//   EventSeismic({required String id}) : super(id: id);
// }
