import 'package:flutter/foundation.dart';
import '../models/translation_model.dart';
import '../services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _service = HistoryService.instance;

  List<TranslationModel> get history => _service.history;
  List<TranslationModel> get favorites => _service.favorites;
  bool get hasHistory => _service.history.isNotEmpty;

  HistoryProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await _service.loadHistory();
    notifyListeners();
  }

  Future<void> addToHistory(TranslationModel translation) async {
    await _service.addToHistory(translation);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    await _service.toggleFavorite(id);
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    await _service.deleteItem(id);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _service.clearHistory();
    notifyListeners();
  }

  Future<void> clearNonFavorites() async {
    await _service.clearNonFavorites();
    notifyListeners();
  }
}
