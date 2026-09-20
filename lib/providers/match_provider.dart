import 'package:flutter/foundation.dart';
import '../models/match_request.dart';
import '../services/firestore_service.dart';

class MatchProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<MatchRequest> _sentRequests = [];
  List<MatchRequest> _receivedRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MatchRequest> get sentRequests => _sentRequests;
  List<MatchRequest> get receivedRequests => _receivedRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<MatchRequest> get pendingReceivedRequests =>
      _receivedRequests.where((r) => r.status == MatchStatus.pending).toList();

  void listenToSentRequests(String userId) {
    _firestoreService.getSentMatchRequests(userId).listen(
      (requests) {
        _sentRequests = requests;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void listenToReceivedRequests(String userId) {
    _firestoreService.getReceivedMatchRequests(userId).listen(
      (requests) {
        _receivedRequests = requests;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> sendMatchRequest(MatchRequest matchRequest) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.createMatchRequest(matchRequest);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMatchRequestStatus(
    MatchRequest matchRequest,
    MatchStatus newStatus,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedRequest = matchRequest.copyWith(
        status: newStatus,
        respondedAt: newStatus == MatchStatus.accepted || newStatus == MatchStatus.rejected
            ? DateTime.now()
            : matchRequest.respondedAt,
        completedAt: newStatus == MatchStatus.completed
            ? DateTime.now()
            : matchRequest.completedAt,
      );

      await _firestoreService.updateMatchRequest(updatedRequest);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
