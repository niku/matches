import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:matches/match_event.dart';

void main() async {
  final competition_years = '2024'; // TODO: take year from command line
  final url = Uri.https('data.j-league.or.jp', '/SFMS01/search',
      {'competition_years': competition_years});
  final body = await http.read(url);
  final document = parse(body);
  final matchEvents = extractMatchEvents(document);
  print(matchEvents);
}

List<MatchEvent> extractMatchEvents(final Document document) {
  final rows = document.querySelectorAll('table.search-table tbody tr');
  final List<MatchEvent> result = [];
  for (final row in rows) {
    final columns = row.querySelectorAll('td');

    assert(columns.length == 11,
        'assume 11 columns, but get ${columns.length} columns');
    final year = columns[0].text.trim();
    final tournaments = columns[1].text.trim();
    final sec = columns[2].text.trim();
    final date = columns[3].text.trim();
    final kickoff = columns[4].text.trim();
    final home = columns[5].text.trim();
    final score = columns[6].text.trim();
    final away = columns[7].text.trim();
    final venue = columns[8].text.trim();
    final att = columns[9].text.trim();
    final broadcast = columns[10].text.trim();

    final homeTeamUrl =
        columns[5].querySelector('a')?.attributes['href']?.trim() ?? '';
    final matchUrl =
        columns[6].querySelector('a')?.attributes['href']?.trim() ?? '';
    final awayTeamUrl =
        columns[7].querySelector('a')?.attributes['href']?.trim() ?? '';

    final matchEvent = MatchEvent(
      year: year,
      tournaments: tournaments,
      sec: sec,
      date: date,
      kickoff: kickoff,
      home: home,
      score: score,
      away: away,
      venue: venue,
      att: att,
      broadcast: broadcast,
      homeTeamUrl: homeTeamUrl,
      matchUrl: matchUrl,
      awayTeamUrl: awayTeamUrl,
    );

    result.add(matchEvent);
  }
  return List.unmodifiable(result);
}
