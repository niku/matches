import 'dart:io';

import 'package:sqlite3/sqlite3.dart';
import 'package:csv/csv.dart';

void main() async {
  final db = sqlite3.open('./web/main.db', mode: OpenMode.readWriteCreate);
  db
    ..execute('''
DROP TABLE IF EXISTS matches;
''')
    ..execute('''
CREATE TABLE IF NOT EXISTS matches (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  year TEXT NOT NULL,
  tournaments TEXT NOT NULL,
  sec TEXT NOT NULL,
  date TEXT NOT NULL,
  kickoff TEXT NOT NULL,
  home TEXT NOT NULL,
  score TEXT NOT NULL,
  away TEXT NOT NULL,
  venue TEXT NOT NULL,
  att TEXT NOT NULL,
  broadcast TEXT NOT NULL,
  homeTeamUrl TEXT NOT NULL,
  matchUrl TEXT NOT NULL,
  awayTeamUrl TEXT NOT NULL
);
''');
  final matchesStmt = db.prepare('''
INSERT INTO matches (year, tournaments, sec, date, kickoff, home, score, away, venue, att, broadcast, homeTeamUrl, matchUrl, awayTeamUrl) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''');
  final matchesFile = File('./data/matches_2024.csv');
  final matchesCsvData =
      const CsvToListConverter().convert(matchesFile.readAsStringSync());
  for (final row in matchesCsvData) {
    matchesStmt.execute(row);
  }
  db.execute('''
CREATE INDEX IF NOT EXISTS idx_matches_venue ON matches (venue);
''');

  db
    ..execute('''
DROP TABLE IF EXISTS venues;
''')
    ..execute('''
CREATE TABLE IF NOT EXISTS venues (
  name TEXT PRIMARY KEY,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL
);
''');
  final venuesStmt = db.prepare(
      'INSERT INTO venues (name, latitude, longitude) VALUES (?, ?, ?)');
  final venuesFile = File('./data/venues.csv');
  final venuesCsvData =
      const CsvToListConverter().convert(venuesFile.readAsStringSync());
  for (final row in venuesCsvData) {
    venuesStmt.execute(row);
  }

  db
    ..execute('VACUUM;') // shrink the database size
    ..dispose();
}
