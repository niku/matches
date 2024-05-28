import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqlite3/wasm.dart';

Future<WasmSqlite3> _sqlite3 = WasmSqlite3.loadFromUrl(
    Uri.parse('sqlite3.wasm')); // assume existing web/sqlite3.wasm

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
  late Future<CommonDatabase> db;

  void _loadDatabase(final WasmSqlite3 sqlite3, final String path,
      final Uint8List databaseBinary) {
    final fs = InMemoryFileSystem();
    sqlite3.registerVirtualFileSystem(fs, makeDefault: true);

    // borrowed by
    // https://github.com/tekartik/sqflite/blob/v2.3.0/packages_web/sqflite_common_ffi_web/lib/src/database_file_system_web.dart#L72-L88
    final file = fs
        .xOpen(Sqlite3Filename(fs.xFullPathName(path)),
            SqlFlag.SQLITE_OPEN_READWRITE | SqlFlag.SQLITE_OPEN_CREATE)
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
        child: FutureBuilder<CommonDatabase>(
          future: db,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              const sql =
                  'SELECT name, latitude, longitude FROM venues ORDER BY name;';
              final resultSet = snapshot.data!.select(sql);
              return DataTable(
                columns: resultSet.columnNames
                    .map((e) => DataColumn(label: Text(e)))
                    .toList(),
                rows: resultSet.rows.map((row) {
                  return DataRow(
                      cells: row.map((cell) {
                    return DataCell(Text(cell.toString()));
                  }).toList());
                }).toList(),
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
