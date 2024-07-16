import 'package:objectbox/objectbox.dart';

@Entity()
class TaskEntity {
  @Id()
  int id = 0;

  @Unique()
  String uid;

  String title;
  String description;
  bool isCompleted;
  bool isArchived;
  bool isSync;

  @Property(type: PropertyType.date)
  DateTime dateCreated;

  @Property(type: PropertyType.date)
  DateTime updateDate;

  TaskEntity({
    required this.uid,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.isArchived = false,
    this.isSync = false,
    DateTime? dateCreated,
    DateTime? updateDate,
  })  : dateCreated = dateCreated ?? DateTime.now(),
        updateDate = updateDate ?? DateTime.now();

  Map<String, dynamic> toJsonOnLine() {
    return {
      'uid': uid,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'isArchived': isArchived,
      'isSync': isSync,
      'dateCreated': dateCreated.toIso8601String(),
      'updateDate': updateDate.toIso8601String(),
    };
  }
}

class TaskModel {
  final String uid;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isArchived;
  final DateTime dateCreated;
  final DateTime updateDate;
  final bool isSync;

  TaskModel({
    required this.uid,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isArchived,
    required this.isSync,
    required this.dateCreated,
    required this.updateDate,
  });

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      uid: entity.uid,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      isArchived: entity.isArchived,
      isSync: entity.isSync,
      dateCreated: entity.dateCreated,
      updateDate: entity.updateDate,
    );
  }

}
