import 'dart:async';
import 'dart:math';
import '../persistence/app_database.dart';

class OpportunityScoutService {
  final AppDatabase _db;
  Timer? _timer;

  OpportunityScoutService(this._db);

  void startScouting() {
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _scout());
  }

  Future<void> _scout() async {
    // 1. Get current readiness (average of all skills)
    final scores = await _db.select(_db.readinessScores).get();
    if (scores.isEmpty) return;

    final avgReadiness = scores.map((e) => e.score).reduce((a, b) => a + b) / scores.length;

    // 2. Mock opportunities
    final mockOpps = [
      {'title': 'Flutter Intern', 'company': 'Google', 'minLevel': 30},
      {'title': 'Junior Mobile Dev', 'company': 'StartupX', 'minLevel': 50},
      {'title': 'Open Source Contributor', 'company': 'Flutter Project', 'minLevel': 20},
    ];

    // 3. Find matches
    for (var opp in mockOpps) {
      if (avgReadiness >= (opp['minLevel'] as int)) {
        // Check if already found
        final existing = await (_db.select(_db.opportunityLog)
              ..where((t) => t.title.equals(opp['title'] as String)))
            .getSingleOrNull();

        if (existing == null) {
          await _db.into(_db.opportunityLog).insert(OpportunityLogCompanion.insert(
                title: opp['title'] as String,
                company: opp['company'] as String,
                type: 'Job',
                url: 'https://example.com/apply',
                minReadinessLevel: drift.Value(opp['minLevel'] as int),
              ));

          // In a real app, trigger a local notification here
        }
      }
    }
  }

  void stopScouting() {
    _timer?.cancel();
  }
}
