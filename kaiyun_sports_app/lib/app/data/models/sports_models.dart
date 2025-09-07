class MatchInfo {
  final String id;
  final String category;
  final MatchStatus status;
  final String teamA;
  final String teamB;
  final int scoreA;
  final int scoreB;
  final String time;
  final bool isLive;
  final bool hasAnimation;

  MatchInfo({
    required this.id,
    required this.category,
    required this.status,
    required this.teamA,
    required this.teamB,
    required this.scoreA,
    required this.scoreB,
    required this.time,
    required this.isLive,
    required this.hasAnimation,
  });
}

enum MatchStatus {
  live,
  upcoming,
  finished,
  cancelled,
}

class BettingOption {
  final String id;
  final String name;
  final double odds;

  BettingOption({
    required this.id,
    required this.name,
    required this.odds,
  });
}
