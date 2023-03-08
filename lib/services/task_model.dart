import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';

class Task {
  String taskName;
  DateTime deadline;

  Task({required this.taskName, required this.deadline});

  Future addTask() async {
    return FirebaseFirestore.instance.collection('tasks').add({
      "task": taskName,
      "deadline": deadline,
    });
  }
}
