class Transport {
  final String departureTime;
  final String arrivalTime;
  final List<Map<String, String>> sections;

  Transport({
    required this.departureTime,
    required this.arrivalTime,
    required this.sections,
  });

  factory Transport.fromMap(Map<String, dynamic> map) {
    final sectionsRaw = (map['sections'] as List?) ?? [];

    return Transport(
      departureTime: map['from']?['departure']?.toString() ?? '',
      arrivalTime: map['to']?['arrival']?.toString() ?? '',
      sections: sectionsRaw.map<Map<String, String>>((s) {
        final dep = s['departure'] ?? {};
        final arr = s['arrival'] ?? {};
        final journey = s['journey'];
        final cat = journey?['category'] ?? '';
        final num = journey?['number'] ?? '';
        final type = s['walk'] != null ? 'Walk': '$cat $num'.trim().replaceAll('B ', 'Bus ');

        return {
          'departureStation': dep['station']?['name']?.toString() ?? '',
          'departureTime': dep['departure']?.toString() ?? '',
          'departurePlatform': dep['platform']?.toString() ?? '',
          'arrivalStation': arr['station']?['name']?.toString() ?? '',
          'arrivalTime': arr['arrival']?.toString() ?? '',
          'arrivalPlatform': arr['platform']?.toString() ?? '',
          'type': type.isNotEmpty ? type : 'Transit',
        };
      }).toList(),
    );
  }
}