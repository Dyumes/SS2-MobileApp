import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/transport_model.dart';

class TransportService {
  static Future<List<Transport>> fetchTransports(String origin, String destination) async {
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final timeStr = DateFormat('HH:mm').format(DateTime.now());

      final uri = Uri.parse('https://transport.opendata.ch/v1/connections?from=$origin&to=$destination&date=${dateStr}&time=$timeStr&limit=6');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List connections = data['connections'] as List;
        final maxTime = DateTime.now().add(const Duration(hours: 2));

        List<Transport> result = [];
        for (var c in connections) {
          final transport = Transport.fromMap(c as Map<String, dynamic>);
          if (transport.departureTime.isNotEmpty) {
            final depDateTime = DateTime.parse(transport.departureTime);
            if (depDateTime.isBefore(maxTime)) {
              result.add(transport);
            }
          }
        }
        return result;
      }
    return [];
  }

  static String formatTime(String rawTime) {
      return DateFormat('HH:mm').format(DateTime.parse(rawTime));
  }
}