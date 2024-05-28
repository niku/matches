import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;

void main() async {
  final venues = getVenues();
  final List<List<String>> result = [];
  result.add(['venue', 'latitude', 'longitude']);
  for (final venue in venues) {
    final normalizedName = normalizedNameMap[venue];
    final url = Uri.https('ja.wikipedia.org', '/w/api.php', {
      'action': 'query',
      'format': 'json',
      'formatversion': '2',
      'prop': 'coordinates',
      'titles': normalizedName,
    });
    try {
      final body = await http.read(url);
      final json = Map<String, dynamic>.from(jsonDecode(body));
      final coordinate = json['query']['pages'][0]['coordinates'][0];
      final latitude = coordinate['lat'];
      final longitude = coordinate['lon'];
      result.add([venue, latitude.toString(), longitude.toString()]);
      await Future.delayed(const Duration(seconds: 1));
      print('$venue,$normalizedName,$latitude,$longitude');
    } catch (e) {
      print('$venue,$normalizedName,$e');
    }
  }
  final file = await File('./data/venues.csv').create(recursive: true);
  await file.writeAsString(const ListToCsvConverter().convert(result));
}

List<String> getVenues() {
  final csvFile = File('./data/matches_2024.csv');
  final csvData = csvFile.readAsStringSync();
  final matchEvents = const CsvToListConverter().convert(csvData);
  final venues = matchEvents
      .where((row) {
        return row[1] == 'Ｊ１' || row[1] == 'Ｊ２' || row[1] == 'Ｊ３';
      })
      .map((row) {
        return row[8]; // row[8] is venue
      })
      .where((val) => val != '●未定●' && val != 'ピースタ')
      .toSet() // make unique
      .toList();
  venues.sort();
  return List.unmodifiable(venues);
}

const normalizedNameMap = {
  'あいづ': 'あいづ陸上競技場',
  'いちご': 'いちご宮崎新富サッカー場',
  'いわスタ': '盛岡南公園球技場',
  'えがおＳ': '熊本県民総合運動公園陸上競技場',
  'とうスタ': '福島県営あづま陸上競技場',
  'みらスタ': '維新百年記念公園陸上競技場',
  'アイスタ': '静岡市清水日本平運動公園球技場',
  'アシさと': '今治里山スタジアム',
  'エコパ': '小笠山総合運動公園',
  'カシマ': '茨城県立カシマサッカースタジアム',
  'カンセキ': 'カンセキスタジアムとちぎ',
  'ギオンス': '相模原麻溝公園競技場',
  'ゴースタ': '金沢スタジアム',
  'サンアル': '長野県松本平広域公園総合球技場',
  'サンガＳ': 'サンガスタジアム_by_KYOCERA',
  'ソユスタ': '秋田市八橋運動公園陸上競技場',
  'タピスタ': '沖縄県総合運動公園陸上競技場',
  'デンカＳ': '新潟スタジアム',
  'トラスタ': '長崎県立総合運動公園陸上競技場',
  'ニッパツ': '三ツ沢公園球技場',
  'ニンスタ': '愛媛県総合運動公園陸上競技場',
  'ノエスタ': '御崎公園球技場',
  'ハワスタ': 'いわきグリーンフィールド',
  'パナスタ': '市立吹田サッカースタジアム',
  'ピカスタ': '香川県立丸亀競技場',
  'フクアリ': 'フクダ電子アリーナ',
  'プラスタ': '八戸市多賀多目的運動場',
  'ベススタ': '東平尾公園博多の森球技場',
  'ミクスタ': 'ミクニワールドスタジアム北九州',
  'ヤジン': 'オールガイナーレYAJINスタジアム',
  'ヤマハ': 'ヤマハスタジアム',
  'ユアスタ': '仙台スタジアム',
  'ヨドコウ': '長居球技場',
  'レゾド': '大分スポーツ公園総合競技場',
  'レモンＳ': '平塚競技場',
  'ロートＦ': '奈良市鴻ノ池陸上競技場',
  '三協Ｆ柏': '日立柏サッカー場',
  '味スタ': '東京スタジアム_(多目的スタジアム)',
  '国立': '国立競技場',
  '埼玉': '埼玉スタジアム2002',
  '富山': '富山県総合運動公園陸上競技場',
  '愛鷹': '愛鷹広域公園多目的競技場',
  '日産ス': '横浜国際総合競技場',
  '札幌ド': '札幌ドーム',
  '栃木グ': '栃木県グリーンスタジアム',
  '正田スタ': '群馬県立敷島公園県営陸上競技場',
  '浦和駒場': 'さいたま市駒場スタジアム',
  '白波スタ': '鹿児島県立鴨池陸上競技場',
  '紀三井寺': '紀三井寺運動公園陸上競技場',
  '花園': '東大阪市花園ラグビー場',
  '藤枝サ': '藤枝総合運動公園サッカー場',
  '豊田ス': '豊田スタジアム',
  '里山Ｓ': '今治里山スタジアム',
  '長良川': '岐阜メモリアルセンター長良川競技場',
  '長野Ｕ': '南長野運動公園総合球技場',
  '駅スタ': '鳥栖スタジアム',
  '鳴門大塚': '徳島県鳴門総合運動公園陸上競技場',
  'Ａｘｉｓ': '鳥取市営サッカー場',
  'Ｃスタ': '岡山県総合グラウンド陸上競技場',
  'Ｅピース': 'エディオンピースウイング広島',
  'Ｇスタ': '町田市立陸上競技場',
  'ＪＩＴス': '山梨県小瀬スポーツ公園陸上競技場',
  'Ｋｓスタ': '水戸市立競技場',
  'ＮＡＣＫ': 'さいたま市大宮公園サッカー場',
  'ＮＤスタ': '山形県総合運動公園',
  'ＳＶ下関': '下関市営下関陸上競技場',
  'Ｕ等々力': '等々力陸上競技場',
};
