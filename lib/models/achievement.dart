/// Model class for achievements
/// Defines available achievements that users can unlock
class Achievement {
  final int? id;
  final String name;
  final String description;
  final String iconName;
  final int pointsAwarded;
  final String category; // e.g., 'beach_cleanup', 'forest_guardian', 'ocean_savior', 'general'
  final String unlockCriteria; // JSON string describing unlock criteria
  final int requiredValue; // Value needed to unlock (e.g., score, games played)
  final DateTime createdAt;

  Achievement({
    this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.pointsAwarded,
    required this.category,
    required this.unlockCriteria,
    required this.requiredValue,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Achievement to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'pointsAwarded': pointsAwarded,
      'category': category,
      'unlockCriteria': unlockCriteria,
      'requiredValue': requiredValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create Achievement from Map (database query result)
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      iconName: map['iconName'] as String,
      pointsAwarded: map['pointsAwarded'] as int,
      category: map['category'] as String,
      unlockCriteria: map['unlockCriteria'] as String,
      requiredValue: map['requiredValue'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Create a copy of Achievement with updated fields
  Achievement copyWith({
    int? id,
    String? name,
    String? description,
    String? iconName,
    int? pointsAwarded,
    String? category,
    String? unlockCriteria,
    int? requiredValue,
    DateTime? createdAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      category: category ?? this.category,
      unlockCriteria: unlockCriteria ?? this.unlockCriteria,
      requiredValue: requiredValue ?? this.requiredValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, name: $name, category: $category, '
        'pointsAwarded: $pointsAwarded)';
  }
}

