// lib/data/models/user_model.dart
class User {
  final String id;
  final String username;
  final String name;
  final String role;
  final String? branchId;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.branchId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      branchId: json['branchId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role,
      'branchId': branchId,
    };
  }
}

// lib/data/models/branch_model.dart
class Branch {
  final String id;
  final String name;
  final String location;
  final String? contactNumber;
  final Manager? manager;

  Branch({
    required this.id,
    required this.name,
    required this.location,
    this.contactNumber,
    this.manager,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      contactNumber: json['contactNumber'],
      manager: json['manager'] != null ? Manager.fromJson(json['manager']) : null,
    );
  }
}

class Manager {
  final String id;
  final String name;

  Manager({
    required this.id,
    required this.name,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

// lib/data/models/jewelry_model.dart
class Jewelry {
  final String id;
  final String name;
  final String category;
  final String material;
  final double weight;
  final double price;
  final int quantity;
  final String? description;
  final String branchId;
  final Branch? branch;
  final String? imageUrl;

  Jewelry({
    required this.id,
    required this.name,
    required this.category,
    required this.material,
    required this.weight,
    required this.price,
    required this.quantity,
    this.description,
    required this.branchId,
    this.branch,
    this.imageUrl,
  });

  factory Jewelry.fromJson(Map<String, dynamic> json) {
    return Jewelry(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      material: json['material'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      description: json['description'],
      branchId: json['branchId'] ?? '',
      branch: json['branchId'] is Map ? Branch.fromJson(json['branchId']) : null,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'material': material,
      'weight': weight,
      'price': price,
      'quantity': quantity,
      'description': description,
      'branchId': branchId,
      'imageUrl': imageUrl,
    };
  }
}

// lib/data/models/transfer_request_model.dart
class TransferRequest {
  final String id;
  final String jewelryId;
  final String fromBranchId;
  final String toBranchId;
  final int quantity;
  final String status;
  final String requestedBy;
  final DateTime requestedAt;
  final String? respondedBy;
  final DateTime? respondedAt;
  final Jewelry? jewelry;
  final Branch? fromBranch;
  final Branch? toBranch;
  final User? requester;
  final User? responder;

  TransferRequest({
    required this.id,
    required this.jewelryId,
    required this.fromBranchId,
    required this.toBranchId,
    required this.quantity,
    required this.status,
    required this.requestedBy,
    required this.requestedAt,
    this.respondedBy,
    this.respondedAt,
    this.jewelry,
    this.fromBranch,
    this.toBranch,
    this.requester,
    this.responder,
  });

  factory TransferRequest.fromJson(Map<String, dynamic> json) {
    return TransferRequest(
      id: json['_id'] ?? '',
      jewelryId: json['jewelryId'] is String ? json['jewelryId'] : json['jewelryId']['_id'] ?? '',
      fromBranchId: json['fromBranchId'] is String ? json['fromBranchId'] : json['fromBranchId']['_id'] ?? '',
      toBranchId: json['toBranchId'] is String ? json['toBranchId'] : json['toBranchId']['_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      status: json['status'] ?? 'pending',
      requestedBy: json['requestedBy'] is String ? json['requestedBy'] : json['requestedBy']['_id'] ?? '',
      requestedAt: json['requestedAt'] != null ? DateTime.parse(json['requestedAt']) : DateTime.now(),
      respondedBy: json['respondedBy'] is String ? json['respondedBy'] : json['respondedBy']?['_id'],
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
      jewelry: json['jewelryId'] is Map ? Jewelry.fromJson(json['jewelryId']) : null,
      fromBranch: json['fromBranchId'] is Map ? Branch.fromJson(json['fromBranchId']) : null,
      toBranch: json['toBranchId'] is Map ? Branch.fromJson(json['toBranchId']) : null,
      requester: json['requestedBy'] is Map ? User.fromJson(json['requestedBy']) : null,
      responder: json['respondedBy'] is Map ? User.fromJson(json['respondedBy']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jewelryId': jewelryId,
      'toBranchId': toBranchId,
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toResponseJson() {
    return {
      'status': status,
    };
  }
}
