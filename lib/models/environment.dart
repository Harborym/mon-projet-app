import 'package:cloud_firestore/cloud_firestore.dart';

class Environment {
  String id;
  String name;
  List<String> playlists;
  Map<String, dynamic> filters;
  DateTime createdAt;

  Environment({
    required this.id,
    required this.name,
    required this.playlists,
    required this.filters,
    required this.createdAt,
  });

  factory Environment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Environment(
      id: doc.id,
      name: data['name'],
      playlists: List<String>.from(data['playlists'] ?? []),
      filters: data['filters'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'playlists': playlists,
      'filters': filters,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
