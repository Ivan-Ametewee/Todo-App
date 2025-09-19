import 'tag_enum.dart';

class Task {
  final int? id;
  final String name;
  final String description;
  final Tag tag;
  final DateTime deadline;
  final Duration notifyBefore;
  final bool isDone;
  final String? imagePath;

  const Task({
    this.id,
    required this.name,
    required this.description,
    required this.tag,
    required this.deadline,
    required this.notifyBefore,
    this.isDone = false,
    this.imagePath,
  });

  Task copyWith({
    int? id,
    String? name,
    String? description,
    Tag? tag,
    DateTime? deadline,
    Duration? notifyBefore,
    bool? isDone,
    String? imagePath,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      deadline: deadline ?? this.deadline,
      notifyBefore: notifyBefore ?? this.notifyBefore,
      isDone: isDone ?? this.isDone,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tag': tag.name,
      'deadline': deadline.millisecondsSinceEpoch,
      'notifyBefore': notifyBefore.inMinutes,
      'isDone': isDone ? 1 : 0,
      'imagePath': imagePath,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      tag: Tag.fromString(map['tag'] ?? 'other'),
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline']),
      notifyBefore: Duration(minutes: map['notifyBefore']?.toInt() ?? 0),
      isDone: (map['isDone'] ?? 0) == 1,
      imagePath: map['imagePath'],
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, name: $name, description: $description, tag: $tag, deadline: $deadline, notifyBefore: $notifyBefore, isDone: $isDone, imagePath: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Task &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.tag == tag &&
        other.deadline == deadline &&
        other.notifyBefore == notifyBefore &&
        other.isDone == isDone &&
        other.imagePath == imagePath;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        tag.hashCode ^
        deadline.hashCode ^
        notifyBefore.hashCode ^
        isDone.hashCode ^
        imagePath.hashCode;
  }
}