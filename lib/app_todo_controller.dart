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
  Rx<bool?> isSyncing = null.obs;
  late Timer _timerIsOnline;
  late Timer _timerSync;
  final supabase = Supabase.instance.client;

  late final Box<TaskEntity> taskBox;

  var tasks = <TaskEntity>[].obs;

  Future addTask(String title, String description,BuildContext context) async {
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
      final response = await addTaskOnline(task.toJsonOnLineInsert(),context);
      if (response) {
        task.isSync = true;
        taskBox.put(task);
      }
    }

    updateTasks();
  }

  Future<bool> addTaskOnline(Map<String,dynamic> taskData,BuildContext? context) async {
    try {
      await supabase.from("Task").insert(taskData);
      return true;
    } catch (e) {

      if (context != null ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red,content: Text('${e.toString()}')),
        );
      } else {
        print("${e.toString()}");
      }

      return false;
    }
  }

  Future<bool> updateTaskTaskOnline(String uid,Map<String,dynamic> taskData,BuildContext? context) async {
    try {

      await supabase
          .from("Task")
          .update(taskData)
          .eq("uid", uid);

      return true;
    } catch (e) {

      if (context != null ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red,content: Text('${e.toString()}')),
        );
      } else {
        print("${e.toString()}");
      }

      return false;
    }
  }

  Future setIsComplete(String uid,bool isComplete) async {
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

  Future archiveTask(String uid) async {
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
    final allData = query.findFirst();
    query.close();
    return allData;
  }

  TaskEntity? getTaskByUid(String uid) {
    var query = taskBox.query(TaskEntity_.uid.equals(uid)).build();
    final data = query.findFirst();
    query.close();
    return data;
  }

  Future updateTask(String uid, String title, String description) async {
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
    query.close();
    tasks.value = allTasks;
  }

  void initialisationLocalDB() async {
    final store = objectbox.store;
    taskBox = store.box<TaskEntity>();
    updateTasks();
    bool isConnected = await hasInternetAccess();
    isOnline.value = isConnected;
    await synchronisation();
    isInitDB.value = true;
  }

  Future<bool> syncToServerUpdate() async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> syncToServerInsert() async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isTaskExistOnServer(String uid) async {
    try {
      final response = await supabase.from("Task").select("uid").eq("uid", uid).limit(1);
      if (response.length == 1 ) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> syncToServer() async {
    final unsyncedTasksQuery = taskBox.query(TaskEntity_.isSync.equals(false)).build();
    final unsyncedTasks = unsyncedTasksQuery.find();
    unsyncedTasksQuery.close();

    for (var task in unsyncedTasks) {
      bool success = false ;
      bool isTaskExistOnline = await isTaskExistOnServer(task.uid);
      final String uid = task.uid;
      final dateNow = DateTime.now();

      if (isTaskExistOnline ) {
        success = await updateTaskTaskOnline(uid,task.toJsonOnLineSyncUpdate(),null);

      } else {
        success = await addTaskOnline(task.toJsonOnLineInsert(),null);
      }

      if (success) {
        task.isSync = true;
        task.updateDate =dateNow;
        taskBox.put(task);
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }

    updateTasks();
  }

  Future<void> syncFromServer() async {
    final unsyncedTasksQuery = taskBox.query(TaskEntity_.isSync.equals(false)).build();
    final unsyncedTasks = unsyncedTasksQuery.find();

    if (unsyncedTasks.isEmpty ) {
      try {

        final allServerTask = await supabase.from("Task").select();

        if (allServerTask.isNotEmpty) {

          for (var serverTask in allServerTask) {
            final String uid = serverTask['uid'];
            final task = getTaskByUid(uid);

            if (task == null) {
              taskBox.put(TaskEntity(
                uid: serverTask['uid'],
                title: serverTask['title'],
                description: serverTask['description'],
                isCompleted: serverTask['isCompleted'],
                isArchived: serverTask['isArchived'],
                isSync: true,
                updateDate: DateTime.parse(serverTask['updateDate']),
              ));
            } else {
              // Update existing task
              task.title = serverTask['title'];
              task.description = serverTask['description'];
              task.isCompleted = serverTask['isCompleted'];
              task.isArchived = serverTask['isArchived'];
              task.isSync = true; // Mark as synced since it's from server
              task.updateDate = DateTime.parse(serverTask['updateDate']);
              taskBox.put(task);
            }
          }

          updateTasks();
        }
      } catch (e) {
        print("Exception during sync from server: $e");
      }
    }

  }

  Future<void> checkConnection() async {
    _timerIsOnline = Timer.periodic( const Duration(seconds: 5), (timer) async {
      bool isConnected = await hasInternetAccess();
      isOnline.value = isConnected;
    });
  }

  Future synchronisation() async {
    isSyncing.value = true;
    bool isConnected = await hasInternetAccess();
    if (isConnected) {
      await syncToServer();
      await Future.delayed(const Duration(seconds: 1));
      await syncFromServer();
    }
    isSyncing.value = false;
  }

  Future triggerSync() async {
    _timerSync = Timer.periodic( const Duration(minutes: 1), (timer) async {
      if (isOnline.value) {
        await syncToServer();
        await syncFromServer();
      }
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
    triggerSync();
  }

  @override
  void onClose() {
    _timerIsOnline.cancel();
    _timerSync.cancel();
    super.onClose();
  }

}
