import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ChatTrainer> _trainers = [];
  List<ChatClient>  _clients  = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  List<ChatTrainer> get trainers => _trainers;
  List<ChatClient>  get clients  => _clients;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  Future<void> fetchTrainers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get(ApiConstants.chatTrainers);
      if (response.data['success'] == true) {
        _trainers = (response.data['data'] as List)
            .map((e) => ChatTrainer.fromJson(e))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(int trainerUserId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.get(
        '${ApiConstants.chatMessages}?trainer_user_id=$trainerUserId',
      );
      if (response.data['success'] == true) {
        _messages = (response.data['data'] as List)
            .map((e) => ChatMessage.fromJson(e))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(int trainerUserId, String message) async {
    if (message.trim().isEmpty) return false;
    try {
      _isSending = true;
      notifyListeners();

      final response = await _apiService.post(ApiConstants.chatMessages, data: {
        'trainer_user_id': trainerUserId,
        'message': message.trim(),
      });

      if (response.data['success'] == true) {
        _messages.add(ChatMessage.fromJson(response.data['data']));
        _isSending = false;
        notifyListeners();
        return true;
      }

      _isSending = false;
      notifyListeners();
      return false;
    } catch (_) {
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  // ── Trainer-side methods ─────────────────────────────────────────────────

  Future<void> fetchClients() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get(ApiConstants.trainerChatClients);
      if (response.data['success'] == true) {
        _clients = (response.data['data'] as List)
            .map((e) => ChatClient.fromJson(e))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessagesAsTrainer(int clientUserId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.get(
        '${ApiConstants.trainerChatMessages}?client_user_id=$clientUserId',
      );
      if (response.data['success'] == true) {
        _messages = (response.data['data'] as List)
            .map((e) => ChatMessage.fromJson(e))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessageAsTrainer(int clientUserId, String message) async {
    if (message.trim().isEmpty) return false;
    try {
      _isSending = true;
      notifyListeners();

      final response = await _apiService.post(ApiConstants.trainerChatMessages, data: {
        'client_user_id': clientUserId,
        'message': message.trim(),
      });

      if (response.data['success'] == true) {
        _messages.add(ChatMessage.fromJson(response.data['data']));
        _isSending = false;
        notifyListeners();
        return true;
      }

      _isSending = false;
      notifyListeners();
      return false;
    } catch (_) {
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
