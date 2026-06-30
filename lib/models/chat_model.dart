class ChatClient {
  final int clientId;
  final int userIdClient;
  final String name;
  final String? photoUrl;
  final int unread;

  ChatClient({
    required this.clientId,
    required this.userIdClient,
    required this.name,
    this.photoUrl,
    required this.unread,
  });

  factory ChatClient.fromJson(Map<String, dynamic> json) {
    return ChatClient(
      clientId: json['client_id'],
      userIdClient: json['user_id'],
      name: json['name'] ?? 'Cliente',
      photoUrl: json['photo_url'],
      unread: json['unread'] ?? 0,
    );
  }
}

class ChatTrainer {
  final int trainerId;
  final int userIdTrainer;
  final String name;
  final String? specialty;
  final String? photoUrl;
  final int unread;

  ChatTrainer({
    required this.trainerId,
    required this.userIdTrainer,
    required this.name,
    this.specialty,
    this.photoUrl,
    required this.unread,
  });

  factory ChatTrainer.fromJson(Map<String, dynamic> json) {
    return ChatTrainer(
      trainerId: json['trainer_id'],
      userIdTrainer: json['user_id'],
      name: json['name'] ?? 'Entrenador',
      specialty: json['specialty'],
      photoUrl: json['photo_url'],
      unread: json['unread'] ?? 0,
    );
  }
}

class ChatMessage {
  final int id;
  final String message;
  final bool isMine;
  final String? readAt;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isMine,
    this.readAt,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      message: json['message'] ?? '',
      isMine: json['is_mine'] == true,
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
