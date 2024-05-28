class MatchEvent {
  /// 年度
  final String year;

  /// 大会
  final String tournaments;

  /// 節
  final String sec;

  /// 試合日
  final String date;

  /// K/O時刻
  final String kickoff;

  /// ホーム
  final String home;

  /// スコア
  final String score;

  /// アウェイ
  final String away;

  /// スタジアム
  final String venue;

  /// 入場者数
  final String att;

  /// インターネット中継・TV放送
  final String broadcast;

  /// ホームURL
  final String homeTeamUrl; // ホームのリンクとして表現されている

  /// マッチ URL
  final String matchUrl; // スコアのリンクとして表現されている

  /// アウェイ URL
  final String awayTeamUrl; // アウェイのリンクとして表現されている

  const MatchEvent({
    required this.year,
    required this.tournaments,
    required this.sec,
    required this.date,
    required this.kickoff,
    required this.home,
    required this.score,
    required this.away,
    required this.venue,
    required this.att,
    required this.broadcast,
    required this.homeTeamUrl,
    required this.matchUrl,
    required this.awayTeamUrl,
  });

  @override
  int get hashCode {
    return year.hashCode ^
        tournaments.hashCode ^
        sec.hashCode ^
        date.hashCode ^
        kickoff.hashCode ^
        home.hashCode ^
        score.hashCode ^
        away.hashCode ^
        venue.hashCode ^
        att.hashCode ^
        broadcast.hashCode ^
        homeTeamUrl.hashCode ^
        matchUrl.hashCode ^
        awayTeamUrl.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchEvent &&
        other.year == year &&
        other.tournaments == tournaments &&
        other.sec == sec &&
        other.date == date &&
        other.kickoff == kickoff &&
        other.home == home &&
        other.score == score &&
        other.away == away &&
        other.venue == venue &&
        other.att == att &&
        other.broadcast == broadcast &&
        other.homeTeamUrl == homeTeamUrl &&
        other.matchUrl == matchUrl &&
        other.awayTeamUrl == awayTeamUrl;
  }

  @override
  String toString() {
    return '{year: $year, tournaments: $tournaments, sec: $sec, date: $date, kickoff: $kickoff, home: $home, score: $score, away: $away, venue: $venue, att: $att, broadcast: $broadcast, homeTeamUrl: $homeTeamUrl, matchUrl: $matchUrl, awayTeamUrl: $awayTeamUrl}';
  }

  Map<String, String> toMap() {
    // Map.of generates new LinkedHashMap that ensures the order of insertion.
    return Map.unmodifiable(Map<String, String>.of({
      'year': year,
      'tournaments': tournaments,
      'sec': sec,
      'date': date,
      'kickoff': kickoff,
      'home': home,
      'score': score,
      'away': away,
      'venue': venue,
      'att': att,
      'broadcast': broadcast,
      'homeTeamUrl': homeTeamUrl,
      'matchUrl': matchUrl,
      'awayTeamUrl': awayTeamUrl,
    }));
  }

  List<String> toList() {
    return toMap().values.toList();
  }
}
