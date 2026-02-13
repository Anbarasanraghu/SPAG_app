import 'package:flutter/foundation.dart';
import '../models/purifier_model.dart';
import '../api/purifier_service.dart';

class PurifierModelCache {
  static final PurifierModelCache _instance = PurifierModelCache._internal();
  
  List<PurifierModel>? _cachedModels;
  
  factory PurifierModelCache() {
    return _instance;
  }
  
  PurifierModelCache._internal();
  
  Future<List<PurifierModel>> _getModels() async {
    if (_cachedModels != null) {
      debugPrint('[PurifierModelCache] Returning cached models');
      return _cachedModels!;
    }
    
    try {
      debugPrint('[PurifierModelCache] Fetching models from API');
      _cachedModels = await PurifierService.listModels();
      debugPrint('[PurifierModelCache] Cached ${_cachedModels!.length} models');
      return _cachedModels!;
    } catch (e) {
      debugPrint('[PurifierModelCache] Error fetching models: $e');
      rethrow;
    }
  }
  
  /// Get model name by ID
  Future<String> getModelName(int modelId) async {
    final models = await _getModels();
    for (final model in models) {
      if (model.id == modelId) {
        debugPrint('[PurifierModelCache] Found model $modelId: ${model.name}');
        return model.name;
      }
    }
    debugPrint('[PurifierModelCache] Model $modelId not found');
    return 'Unknown Model';
  }
  
  /// Get full model by ID
  Future<PurifierModel?> getModel(int modelId) async {
    final models = await _getModels();
    try {
      return models.firstWhere((m) => m.id == modelId);
    } catch (e) {
      return null;
    }
  }
  
  /// Clear cache if needed
  void clearCache() {
    debugPrint('[PurifierModelCache] Clearing cache');
    _cachedModels = null;
  }
}
