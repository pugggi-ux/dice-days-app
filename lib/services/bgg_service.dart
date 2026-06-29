import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class BggSearchResult {
  final String bggId;
  final String name;
  final String? yearPublished;

  const BggSearchResult({
    required this.bggId,
    required this.name,
    this.yearPublished,
  });
}

class BggGameDetails {
  final String bggId;
  final String name;
  final String? imageUrl;
  final int? minPlayers;
  final int? maxPlayers;
  final int? playingTimeMinutes;
  final double? weight;
  final String? description;

  const BggGameDetails({
    required this.bggId,
    required this.name,
    this.imageUrl,
    this.minPlayers,
    this.maxPlayers,
    this.playingTimeMinutes,
    this.weight,
    this.description,
  });
}

class BggService {
  static const _baseUrl = 'https://boardgamegeek.com/xmlapi2';

  Future<List<BggSearchResult>> search(String query) async {
    final uri = Uri.parse('$_baseUrl/search?query=${Uri.encodeComponent(query)}&type=boardgame');
    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final doc = XmlDocument.parse(response.body);
    return doc.findAllElements('item').map((item) {
      return BggSearchResult(
        bggId: item.getAttribute('id') ?? '',
        name: item.findElements('name').firstOrNull?.getAttribute('value') ?? '',
        yearPublished: item.findElements('yearpublished').firstOrNull?.getAttribute('value'),
      );
    }).toList();
  }

  Future<BggGameDetails?> getDetails(String bggId) async {
    final uri = Uri.parse('$_baseUrl/thing?id=$bggId&stats=1');
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final doc = XmlDocument.parse(response.body);
    final item = doc.findAllElements('item').firstOrNull;
    if (item == null) return null;

    final primaryName = item.findAllElements('name')
        .where((n) => n.getAttribute('type') == 'primary')
        .firstOrNull
        ?.getAttribute('value');

    final weight = item.findAllElements('averageweight').firstOrNull?.getAttribute('value');

    return BggGameDetails(
      bggId: bggId,
      name: primaryName ?? '',
      imageUrl: item.findAllElements('image').firstOrNull?.innerText,
      minPlayers: int.tryParse(item.findAllElements('minplayers').firstOrNull?.getAttribute('value') ?? ''),
      maxPlayers: int.tryParse(item.findAllElements('maxplayers').firstOrNull?.getAttribute('value') ?? ''),
      playingTimeMinutes: int.tryParse(item.findAllElements('playingtime').firstOrNull?.getAttribute('value') ?? ''),
      weight: weight != null ? double.tryParse(weight) : null,
      description: item.findAllElements('description').firstOrNull?.innerText,
    );
  }
}
