import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:matches/match_event.dart';
import 'package:sqlite3/wasm.dart' as sqlite;

Future<sqlite.WasmSqlite3> _sqlite3 = sqlite.WasmSqlite3.loadFromUrl(
    Uri.parse('sqlite3.wasm')); // assume existing web/sqlite3.wasm

final MapController _mapController = MapController();
final PopupController _popupLayerController = PopupController();

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<sqlite.CommonDatabase> db;

  void _loadDatabase(final sqlite.WasmSqlite3 sqlite3, final String path,
      final Uint8List databaseBinary) {
    final fs = sqlite.InMemoryFileSystem();
    sqlite3.registerVirtualFileSystem(fs, makeDefault: true);

    // borrowed by
    // https://github.com/tekartik/sqflite/blob/v2.3.0/packages_web/sqflite_common_ffi_web/lib/src/database_file_system_web.dart#L72-L88
    final file = fs
        .xOpen(
            sqlite.Sqlite3Filename(fs.xFullPathName(path)),
            sqlite.SqlFlag.SQLITE_OPEN_READWRITE |
                sqlite.SqlFlag.SQLITE_OPEN_CREATE)
        .file;
    try {
      file.xTruncate(0);
      file.xWrite(databaseBinary, 0);
    } finally {
      file.xClose();
    }
  }

  @override
  void initState() {
    super.initState();
    db = Future(() async {
      final sqlite3 = await _sqlite3;
      const path = 'my-original-data';
      final databaseBinary = await http
          .readBytes(Uri.parse('main.db')); // assume existing web/main.db
      _loadDatabase(sqlite3, path, databaseBinary);
      return sqlite3.open(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Matches'),
      ),
      body: Center(
        child: FutureBuilder<sqlite.CommonDatabase>(
          future: db,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return MyMap(
                database: snapshot.data!,
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class MyMap extends StatefulWidget {
  MyMap({super.key, required this.database});

  final defaultCenter = const LatLng(35.676, 139.650);
  final double defaultZoom = 6;
  final defaultMaxBounds =
      LatLngBounds(const LatLng(20.0, 122.0), const LatLng(50.0, 154.0));
  final sqlite.CommonDatabase database;

  @override
  State<StatefulWidget> createState() {
    return _MyMapState();
  }
}

class _MyMapState extends State<MyMap> {
  List<VenueMarker> _venueMarkers() {
    final resultSet =
        widget.database.select('SELECT name, latitude, longitude FROM venues;');
    return resultSet.map((row) {
      final name = row.columnAt(0) as String;
      final latitude = row.columnAt(1) as double;
      final longitude = row.columnAt(2) as double;
      final marker = VenueMarker(
        name: name,
        point: LatLng(latitude, longitude),
        child: const Icon(Icons.location_on),
      );
      return marker;
    }).toList();
  }

  List<MatchEvent> _matches(final String venue) {
    final resultSet = widget.database.select(
        'SELECT year, tournaments, sec, date, kickoff, home, score, away, venue, att, broadcast, homeTeamUrl, matchUrl, awayTeamUrl FROM matches WHERE venue = ?;',
        [venue]);
    return resultSet.map((row) {
      final year = row.columnAt(0);
      final tournaments = row.columnAt(1);
      final sec = row.columnAt(2);
      final date = row.columnAt(3);
      final kickoff = row.columnAt(4);
      final home = row.columnAt(5);
      final score = row.columnAt(6);
      final away = row.columnAt(7);
      final venue = row.columnAt(8);
      final att = row.columnAt(9);
      final broadcast = row.columnAt(10);
      final homeTeamUrl = row.columnAt(11);
      final matchUrl = row.columnAt(12);
      final awayTeamUrl = row.columnAt(13);
      return MatchEvent(
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
          awayTeamUrl: awayTeamUrl);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.defaultCenter,
        initialZoom: widget.defaultZoom,
        cameraConstraint:
            CameraConstraint.contain(bounds: widget.defaultMaxBounds),
        onTap: (_, __) => _popupLayerController
            .hideAllPopups(), // Hide popup when the map is tapped.
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        PopupMarkerLayer(
          options: PopupMarkerLayerOptions(
            popupController: _popupLayerController,
            markers: _venueMarkers(),
            popupDisplayOptions: PopupDisplayOptions(
              builder: (BuildContext context, Marker marker) {
                marker as VenueMarker;
                final name = marker.name;
                return Popup(marker, _matches(name));
              },
            ),
          ),
        ),
      ],
    );
  }
}

class VenueMarker extends Marker {
  const VenueMarker(
      {required this.name, required super.point, required super.child});

  final String name;
}

class Popup extends StatelessWidget {
  final VenueMarker marker;
  final List<MatchEvent> matches;

  const Popup(this.marker, this.matches, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(marker.name),
          DataTable(
            columns: const [
              DataColumn(label: Text('日程')),
              DataColumn(label: Text('HOME')),
              DataColumn(label: Text('AWAY')),
            ],
            rows: matches
                .map((match) => DataRow(
                      cells: [
                        DataCell(Text(match.date)),
                        DataCell(Text(match.home)),
                        DataCell(Text(match.away)),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
