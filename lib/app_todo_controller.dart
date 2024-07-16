import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/task_entity.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'objectbox.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskController extends GetxController {

  final isInitDB = false.obs;
  final isOnline = false.obs;
  late Timer _timer;
  final supabase = Supabase.instance.client;

  late final Box<TaskEntity> taskBox;

  var tasks = <TaskEntity>[].obs;

  void addTask(String title, String description) async {
    var uuid = const Uuid();
    var task = TaskEntity(
      uid: uuid.v4(),
      title: title,
      description: description,
      isCompleted: false,
      isArchived: false,
      isSync: false,
    );

    taskBox.put(task);

    final kIsOnline = await hasInternetAccess();

    if (kIsOnline) {
      final response = await addTaskOnline(task.toJsonOnLine());
      if (response) {
        task.isSync = true;
        taskBox.put(task);
      }
    }

    updateTasks();
  }

  Future<bool> addTaskOnline(Map<String,dynamic> taskData) async {
    try {
      await supabase.from("Task").insert(taskData);
      return true;
    } catch (e) {
      final context = Get.context;
      if (context != null ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red,content: Text('${e.toString()}')),
        );
      }

      return false;
    }
  }

  void setIsComplete(String uid,bool isComplete) async {
    var task = getTaskByUid(uid);
    if (task != null) {
      task.isCompleted = isComplete;
      task.isSync = false;
      task.updateDate = DateTime.now();
      taskBox.put(task);

      final kIsOnline = await hasInternetAccess();
      if (kIsOnline) {
        final response = await setIsCompleteOnline(uid, isComplete);
        if (response) {
          task.isSync = true;
          taskBox.put(task);
        }
      }

      updateTasks();
    }
  }

  Future<bool> setIsCompleteOnline(String uid, bool isComplete) async {
    try {
      await supabase
          .from("Task")
          .update({"isCompleted": isComplete})
          .eq("uid", uid);
      return true;
    } catch (e) {
      final context = Get.context;
      if (context != null ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red,content: Text('${e.toString()}')),
        );
      }
      return false;
    }
  }

  List<TaskEntity> getAllTask() {
    var query = taskBox.query(TaskEntity_.isArchived.equals(false)).build();
    final allTasks =  query.find();
    tasks.value = allTasks;
    return tasks;
  }

  void archiveTask(String uid) async {
    var task = getTaskByUid(uid);
    if (task != null) {
      task.isArchived = true;
      task.isSync = false;
      task.updateDate = DateTime.now();
      taskBox.put(task);

      final kIsOnline = await hasInternetAccess();
      if (kIsOnline) {
        final response = await archiveTaskOnline(uid);
        if (response) {
          task.isSync = true;
          taskBox.put(task);
        }
      }
      updateTasks();
    }
  }

  Future<bool> archiveTaskOnline(String uid) async {
    try {
      await supabase
          .from("Task")
          .update({"isArchived": true})
          .eq("uid", uid);
      return true;
    } catch (e) {
      final context = Get.context;
      if (context != null ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red,content: Text('${e.toString()}')),
        );
      }
      return false;
    }
  }

  TaskEntity? findTask(String? uid) {
    if (uid == null ) {
      return null;
    }
    var query = taskBox.query(TaskEntity_.uid.equals(uid)).build();
    return query.findFirst();
  }

  TaskEntity? getTaskByUid(String uid) {
    var query = taskBox.query(TaskEntity_.uid.equals(uid)).build();
    return query.findFirst();
  }

  void updateTask(String uid, String title, String description) async {
    var task = getTaskByUid(uid);
    if (task != null) {
      task.title = title;
      task.description = description;
      task.updateDate = DateTime.now();
      task.isSync = false;
      taskBox.put(task);

      final kIsOnline = await hasInternetAccess();
      if (kIsOnline) {
        final response = await updateTaskOnline(uid, title, description);
        if (response) {
          task.isSync = true;
          taskBox.put(task);
        }
      }
      updateTasks();
    }
  }

  Future<bool> updateTaskOnline(String uid, String title, String description) async {
    try {
      await supabase.from("Task")
          .update({"title": title, "description": description,})
          .eq("uid", uid);
      return true;
    } catch (e) {
      final context = Get.context;
      if (context != null ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red,content: Text('${e.toString()}')),
        );
      }
      return false;
    }
  }

  void updateTasks() {
    var query = taskBox.query(TaskEntity_.isArchived.equals(false)).build();
    final allTasks =  query.find();
    tasks.value = allTasks;
  }

  void initialisationLocalDB() {
    final store = objectbox.store;
    taskBox = store.box<TaskEntity>();
    updateTasks();
    isInitDB.value = true;
  }

  Future<void> checkConnection() async {
    _timer = Timer.periodic( const Duration(seconds: 10), (timer) async {
      bool isConnected = await hasInternetAccess();
      isOnline.value = isConnected;
    });
  }

  Future<bool> hasInternetAccess() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  @override
  void onInit() {
    super.onInit();
    initialisationLocalDB();
    checkConnection();
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }

}
