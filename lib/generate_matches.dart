import 'package:http/http.dart' as http;

void main() async {
  final competition_years = '2024'; // TODO: take year from command line
  final url = Uri.https('data.j-league.or.jp', '/SFMS01/search',
      {'competition_years': competition_years});
  final body = await http.read(url);
  print(body);
}
