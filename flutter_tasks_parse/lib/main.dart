import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

const TaskDatabaseName = "Task";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const keyApplicationId = 'w42kSAR3oIfeYoOH51Gf8D62QGTgUZXzDZTf0zWN';
  const keyClientKey = 'HALjrhHs1lzzN1PswYA2AwqO6GgQ5WRQKtguj0C7';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  void addTask() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Empty title"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Empty description"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveTask(titleController.text, descriptionController.text);
    setState(() {
      titleController.clear();
      descriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parse Task List"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(
                  16.0), //const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Column(
                children: <Widget>[
                  const Text(
                    "New Task",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    autocorrect: true,
                    textCapitalization: TextCapitalization.sentences,
                    controller: titleController,
                    decoration: const InputDecoration(
                        labelText: "Title",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                  TextFormField(
                    autocorrect: true,
                    textCapitalization: TextCapitalization.sentences,
                    controller: descriptionController,
                    decoration: const InputDecoration(
                        labelText: "Description",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        onPrimary: Colors.white,
                        primary: Colors.lightGreen,
                      ),
                      onPressed: addTask,
                      child: const Text("Create Task")),
                ],
              )),
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: getTasks(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                              width: 100,
                              height: 100,
                              child: const CircularProgressIndicator()),
                        );
                      default:
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text("Error..."),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text("No Data..."),
                          );
                        } else {
                          return ListView.builder(
                              padding: const EdgeInsets.only(top: 10.0),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                //*************************************
                                //Get Parse Object Values
                                final varTask = snapshot.data![index];
                                final varTitle = varTask.get<String>('title')!;
                                final varDescription =
                                    varTask.get<String>('description')!;
                                //*************************************

                                return ListTile(
                                  title: Text('Title: ${varTitle}'),
                                  subtitle:
                                      Text('Description: ${varDescription}'),
                                  onTap: () {
                                    // When a task is tapped, navigate to the details screen.
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TaskDetailsScreen(
                                            varTask), // Pass the task data.
                                      ),
                                    );
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        // onPressed: EditTaskScreen(varTask),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditTaskScreen(
                                                  varTask), // Pass the task data.
                                            ),
                                          ).then((value) => setState(() {}));
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_rounded,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          await deleteTask(varTask.objectId!);
                                          setState(() {
                                            const snackBar = SnackBar(
                                              content: Text("Task deleted!"),
                                              duration: Duration(seconds: 2),
                                            );
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(snackBar);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                );
                              });
                        }
                    }
                  }))
        ],
      ),
    );
  }

  Future<void> saveTask(String title, String description) async {
    final task = ParseObject(TaskDatabaseName)
      ..set('title', title)
      ..set('description', description);
    await task.save();
  }

  Future<List<ParseObject>> getTasks() async {
    QueryBuilder<ParseObject> queryTask =
        QueryBuilder<ParseObject>(ParseObject(TaskDatabaseName))
          ..orderByDescending('updatedAt');
    final ParseResponse apiResponse = await queryTask.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> deleteTask(String id) async {
    var task = ParseObject(TaskDatabaseName)..objectId = id;
    await task.delete();
  }
}

class TaskDetailsScreen extends StatelessWidget {
  final ParseObject task;

  TaskDetailsScreen(this.task);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${task['title']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Description: ${task['description']}'),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final ParseObject task;

  EditTaskScreen(this.task);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  Future<void> updateTask() async {
    String updatedTitle, updatedDescription;
    updatedTitle = widget.task['title'];
    updatedDescription = widget.task['description'];

    if (titleController.text.trim().isEmpty &&
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Empty fields to update"),
        duration: Duration(seconds: 2),
      ));
      // return;
    }

    if (titleController.text.isNotEmpty) {
      updatedTitle = titleController.text.trim();
    }
    if (descriptionController.text.isNotEmpty) {
      updatedDescription = descriptionController.text.trim();
    }
    final updatedTask = ParseObject(TaskDatabaseName)
      ..objectId = widget.task['objectId']
      ..set('title', updatedTitle)
      ..set('description', updatedDescription);
    await updatedTask.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Column(children: <Widget>[
        Container(
            padding: const EdgeInsets.all(
                16.0), //const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Column(
              children: <Widget>[
                const Text(
                  "Edit fields",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  autocorrect: true,
                  textCapitalization: TextCapitalization.sentences,
                  controller: titleController,
                  decoration: const InputDecoration(
                      labelText: "Title",
                      labelStyle: TextStyle(color: Colors.blueAccent)),
                ),
                TextFormField(
                  autocorrect: true,
                  textCapitalization: TextCapitalization.sentences,
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      labelText: "Description",
                      labelStyle: TextStyle(color: Colors.blueAccent)),
                ),
                Padding(padding: EdgeInsets.all(5)),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      primary: Colors.lightGreen,
                    ),
                    onPressed: () async {
                      updateTask();
                      setState(() {
                        titleController.clear();
                        descriptionController.clear();
                        const snackBar = SnackBar(
                          content: Text("Task edited!"),
                          duration: Duration(seconds: 3),
                        );
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(snackBar);
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text("Update Task")),
              ],
            )),
      ]),
    );
  }
}
