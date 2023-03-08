import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_demo/services/google_sign_in.dart';
import 'package:flutter_demo/services/task_model.dart';
import 'package:provider/provider.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter_demo/services/task_model.dart';
import 'package:intl/intl.dart';

class LoggedInPage extends StatefulWidget {
  const LoggedInPage({super.key});

  @override
  State<LoggedInPage> createState() => _LoggedInPageState();
}

class _LoggedInPageState extends State<LoggedInPage> {
  @override
  Widget build(BuildContext context) {
    final _tasks = FirebaseFirestore.instance.collection('tasks');
    final user = FirebaseAuth.instance.currentUser;
    final controllerTask = TextEditingController();
    DateTime controllerDate = DateTime.now();

    Future deleteTask(String id) async {
      await _tasks.doc(id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task deleted succesfully")));
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 13, 2, 69),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(user!.photoURL!),
                      ),
                      Text(
                        user.displayName!,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final provider = Provider.of<GoogleSignInProvider>(
                              context,
                              listen: false);
                          provider.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          elevation: 0,
                        ),
                        child: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(children: [
                    TextField(
                      controller: controllerTask,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Task",
                      ),
                    ),
                    const SizedBox(height: 20),
                    DateTimeField(
                      decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Date and time",
                          hintText: "hello"),
                      onDateSelected: (value) {
                        controllerDate = value;
                      },
                      selectedDate: DateTime.now(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Task(
                                taskName: controllerTask.text,
                                deadline: controllerDate)
                            .addTask();
                        controllerTask.clear();
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 40)),
                      child: Text("Add Task"),
                    ),
                  ]),
                ),
                Container(
                  child: StreamBuilder(
                    stream: _tasks.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            reverse: true,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(5),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final currentDoc = snapshot.data!.docs[index];
                              return Card(
                                child: ListTile(
                                  title: Text(currentDoc['task']),
                                  subtitle: Text(currentDoc['deadline']
                                      .toDate()
                                      .toString()),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      deleteTask(currentDoc.id);
                                    },
                                  ),
                                ),
                              );
                            });
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
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
