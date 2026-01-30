import 'package:latlong2/latlong.dart';
import '../models/event_post_model.dart';

class GeocodingHelper {
  // Basic country center coordinates (approximate)
  static final Map<Country, LatLng> _countryCoordinates = {
    Country.afghanistan: LatLng(33.9391, 67.7100),
    Country.albania: LatLng(41.1533, 20.1683),
    Country.algeria: LatLng(28.0339, 1.6596),
    Country.andorra: LatLng(42.5063, 1.5218),
    Country.angola: LatLng(-11.2027, 17.8739),
    Country.argentina: LatLng(-38.4161, -63.6167),
    Country.armenia: LatLng(40.0691, 45.0382),
    Country.australia: LatLng(-25.2744, 133.7751),
    Country.austria: LatLng(47.5162, 14.5501),
    Country.azerbaijan: LatLng(40.1431, 47.5769),
    Country.bahamas: LatLng(25.0343, -77.3963),
    Country.bahrain: LatLng(26.0667, 50.5577),
    Country.bangladesh: LatLng(23.6850, 90.3563),
    Country.barbados: LatLng(13.1939, -59.5432),
    Country.belarus: LatLng(53.7098, 27.9534),
    Country.belgium: LatLng(50.5039, 4.4699),
    Country.belize: LatLng(17.1899, -88.4976),
    Country.benin: LatLng(9.3077, 2.3158),
    Country.bhutan: LatLng(27.5142, 90.4336),
    Country.bolivia: LatLng(-16.2902, -63.5887),
    Country.bosniaAndHerzegovina: LatLng(43.9159, 17.6791),
    Country.botswana: LatLng(-22.3285, 24.6849),
    Country.brazil: LatLng(-14.2350, -51.9253),
    Country.brunei: LatLng(4.5353, 114.7277),
    Country.bulgaria: LatLng(42.7339, 25.4858),
    Country.burkinaFaso: LatLng(12.2383, -1.5616),
    Country.burma: LatLng(21.9162, 95.9560),
    Country.burundi: LatLng(-3.3731, 29.9189),
    Country.cambodia: LatLng(12.5657, 104.9910),
    Country.cameroon: LatLng(7.3697, 12.3547),
    Country.canada: LatLng(56.1304, -106.3468),
    Country.chile: LatLng(-35.6751, -71.5430),
    Country.china: LatLng(35.8617, 104.1954),
    Country.colombia: LatLng(4.5709, -74.2973),
    // Country.: LatLng(-4.0383, 21.7587),
    Country.costaRica: LatLng(9.7489, -83.7534),
    Country.croatia: LatLng(45.1, 15.2),
    Country.cuba: LatLng(21.5218, -77.7812),
    Country.cyprus: LatLng(35.1264, 33.4299),
    Country.czechia: LatLng(49.8175, 15.4730),
    Country.denmark: LatLng(56.2639, 9.5018),
    Country.ecuador: LatLng(-1.8312, -78.1834),
    Country.egypt: LatLng(26.8206, 30.8025),
    Country.finland: LatLng(61.9241, 25.7482),
    Country.france: LatLng(46.2276, 2.2137),
    Country.germany: LatLng(51.1657, 10.4515),
    Country.greece: LatLng(39.0742, 21.8243),
    Country.guatemala: LatLng(15.7835, -90.2308),
    Country.iceland: LatLng(64.9631, -19.0208),
    Country.india: LatLng(20.5937, 78.9629),
    Country.indonesia: LatLng(-0.7893, 113.9213),
    Country.iran: LatLng(32.4279, 53.6880),
    Country.iraq: LatLng(33.2232, 43.6793),
    Country.ireland: LatLng(53.4129, -8.2439),
    Country.israel: LatLng(31.0461, 34.8516),
    Country.italy: LatLng(41.8719, 12.5674),
    Country.japan: LatLng(36.2048, 138.2529),
    Country.mexico: LatLng(23.6345, -102.5528),
    Country.netherlands: LatLng(52.1326, 5.2913),
    Country.newZealand: LatLng(-40.9006, 174.8860),
    Country.norway: LatLng(60.4720, 8.4689),
    Country.pakistan: LatLng(30.3753, 69.3451),
    Country.peru: LatLng(-9.1900, -75.0152),
    Country.philippines: LatLng(12.8797, 121.7740),
    Country.poland: LatLng(51.9194, 19.1451),
    Country.portugal: LatLng(39.3999, -8.2245),
    Country.romania: LatLng(45.9432, 24.9668),
    Country.russia: LatLng(61.5240, 105.3188),
    Country.saudiArabia: LatLng(23.8859, 45.0792),
    Country.southAfrica: LatLng(-30.5595, 22.9375),
    Country.southKorea: LatLng(35.9078, 127.7669),
    Country.spain: LatLng(40.4637, -3.7492),
    Country.sweden: LatLng(60.1282, 18.6435),
    Country.switzerland: LatLng(46.8182, 8.2275),
    Country.syria: LatLng(34.8021, 38.9968),
    Country.taiwan: LatLng(23.6978, 120.9605),
    Country.thailand: LatLng(15.8700, 100.9925),
    Country.turkey: LatLng(38.9637, 35.2433),
    Country.ukraine: LatLng(48.3794, 31.1656),
    Country.unitedArabEmirates: LatLng(23.4241, 53.8478),
    Country.unitedKingdom: LatLng(55.3781, -3.4360),
    Country.unitedStatesOfAmerica: LatLng(37.0902, -95.7129),
    Country.venezuela: LatLng(6.4238, -66.5897),
    Country.vietnam: LatLng(14.0583, 108.2772),
    // Add more as needed
  };

  static LatLng? getCoordinatesForEvent(Event event) {
    // If event already has coordinates, use them
    if (event.latitude != null && event.longitude != null) {
      return LatLng(event.latitude!, event.longitude!);
    }

    // Otherwise, use country center as fallback
    if (event.country != Country.unspecified) {
      return _countryCoordinates[event.country];
    }

    return null;
  }
}