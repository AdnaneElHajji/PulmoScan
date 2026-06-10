/// Offline mode — sync service is a no-op.
/// All data lives in SQLite; nothing is sent to any server.
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  void syncPatient(Map<String, dynamic> body) {}
  void syncExam(Map<String, dynamic> body) {}
  void syncResult(Map<String, dynamic> body) {}
}
