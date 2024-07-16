import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_todo_controller.dart';

class AddTodoScreen extends StatefulWidget {
  final String? taskUid;
  const AddTodoScreen({super.key, this.taskUid});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final TaskController taskController = Get.find();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isDeleting = false;

  @override
  initState() {
    super.initState();
    final task = taskController.findTask(widget.taskUid);
    if (task != null ) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
    }
  }


  @override
  Widget build(BuildContext context) {

    final taskId = widget.taskUid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 5 ) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
        
                      await Future.delayed(Duration(seconds: 1));

                      if (taskId == null ) {
                        taskController.addTask(
                          _titleController.text.trim(),
                          _descriptionController.text.trim(),
                        );
                      } else {
                        taskController.updateTask(
                          taskId,
                          _titleController.text.trim(),
                          _descriptionController.text.trim(),
                        );

                      }

                      _titleController.clear();
                      _descriptionController.clear();
        
                      Get.back();
        
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: isLoading
                        ? const Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(),
                      ),
                    ) : Center(child: Text(taskId == null ? 'Add Task' : "Update")),
                  ),
                ),
                SizedBox(height: 70.0),
                if ( taskId != null ) ElevatedButton(
                  onPressed: isDeleting ? null : () async {
                    setState(() {
                      isDeleting = true;
                    });
        
                    await Future.delayed(Duration(seconds: 1));
        
                    taskController.archiveTask(taskId);

                    Get.back();
        
                    setState(() {
                      isDeleting = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red
                  ),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: isDeleting
                        ? const Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(color: Colors.red,),
                      ),
                    ) : const Center(child: Text('Delete')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
