import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_todo_screen.dart';
import 'app_todo_controller.dart';


class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {

  final TaskController taskController = Get.put(TaskController());
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx((){
              final taskList = taskController.tasks;
              final length = taskList.length ;
              return Text(
                "Liste des tâches : ${length}",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              );
            }),
            const SizedBox(height: 5.0),
            Obx((){
              final isOnline = taskController.isOnline.value;
              final isSync = taskController.isSyncing.value;
              return Row(
                children: [
                  const Text("Mode de travail ",style: TextStyle(fontStyle: FontStyle.italic,fontSize: 16),),
                  Text(isOnline ?  "En Linge" : "Hors Ligne",style: TextStyle(color: isOnline ? Colors.green : Colors.red,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic,fontSize: 16),),
                  Expanded(child: Container()),
                  if ( isSync != -1 ) Container(width: 20,height: 20,child: CircularProgressIndicator(),)
                ],
              );
            }),
            const SizedBox(height: 15.0),
            Expanded(
              child: Obx(() {
                final taskList = taskController.tasks;
                final isEmpty = taskList.isEmpty ;
                if (isEmpty) {
                   return const Center(
                     child: Text("Aucune donnée , veuillez ajouter une tache")
                   );
                }
                return ListView.builder(
                  itemCount: taskList.length,
                  itemBuilder: (context, index) {
                    var task = taskList[index];
                    return GestureDetector(
                      onDoubleTap: (){
                        Get.to(() => AddTodoScreen(taskUid: task.uid));
                      },
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              offset: Offset(2, 0),
                              color: Color(0xFFFFFFFF).withOpacity(0.25),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2,),
                                    Text(
                                      task.description,
                                      style: TextStyle(fontStyle: FontStyle.italic),
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                taskController.setIsComplete(task.uid, !task.isCompleted);
                              },
                              padding: EdgeInsets.zero,
                              icon: task.isCompleted  ? const Icon(
                                Icons.check_box,
                                color: Colors.blue,
                                size: 20,
                              ) : const Icon(
                                Icons.check_box_outline_blank,
                                color: Colors.grey,
                                size: 20,
                              ),
                              splashRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddTodoScreen());
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
