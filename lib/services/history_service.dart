import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation_model.dart';
import '../core/app_constants.dart';

class HistoryService {
  HistoryService._();
  static final HistoryService instance = HistoryService._();

  List<TranslationModel> _history = [];
  bool _loaded = false;

  List<TranslationModel> get history => List.unmodifiable(_history);
  List<TranslationModel> get favorites =>
      _history.where((t) => t.isFavorite).toList();

  Future<void> _ensureLoaded() async {
    if (!_loaded) await loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(AppConstants.historyKey) ?? [];
      _history = jsonList
          .map((s) {
            try {
              return TranslationModel.fromJsonString(s);
            } catch (_) {
              return null;
            }
          })
          .whereType<TranslationModel>()
          .toList();
      _loaded = true;
    } catch (e) {
      debugPrint('Error loading history: $e');
      _history = [];
      _loaded = true;
    }
  }

  Future<void> addToHistory(TranslationModel translation) async {
    await _ensureLoaded();

    // Avoid duplicate consecutive entries
    if (_history.isNotEmpty &&
        _history.first.sourceText == translation.sourceText &&
        _history.first.sourceLang == translation.sourceLang &&
        _history.first.targetLang == translation.targetLang) {
      return;
    }

    _history.insert(0, translation);

    // Trim to max
    if (_history.length > AppConstants.maxHistoryItems) {
      _history = _history.sublist(0, AppConstants.maxHistoryItems);
    }

    await _saveHistory();
  }

  Future<void> toggleFavorite(String id) async {
    await _ensureLoaded();
    final index = _history.indexWhere((t) => t.id == id);
    if (index != -1) {
      _history[index] = _history[index].copyWith(
        isFavorite: !_history[index].isFavorite,
      );
      await _saveHistory();
    }
  }

  Future<void> deleteItem(String id) async {
    await _ensureLoaded();
    _history.removeWhere((t) => t.id == id);
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    _history = [];
    await _saveHistory();
  }

  Future<void> clearNonFavorites() async {
    await _ensureLoaded();
    _history = _history.where((t) => t.isFavorite).toList();
    await _saveHistory();
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _history.map((t) => t.toJsonString()).toList();
      await prefs.setStringList(AppConstants.historyKey, jsonList);
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }
}
