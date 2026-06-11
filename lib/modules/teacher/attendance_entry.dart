// lib/modules/teacher/attendance_entry.dart
import 'package:flutter/material.dart';

class AttendanceEntryScreen extends StatefulWidget {
  const AttendanceEntryScreen({super.key});

  @override
  State<AttendanceEntryScreen> createState() => _AttendanceEntryScreenState();
}

class _AttendanceEntryScreenState extends State<AttendanceEntryScreen> {
  // Mock data representing a parsed class roster structure
  final List<Map<String, dynamic>> _studentRoster = [
    {'id': 'S1', 'name': 'Alex Mercer', 'isPresent': true},
    {'id': 'S2', 'name': 'Sarah Connor', 'isPresent': true},
    {'id': 'S3', 'name': 'Bruce Wayne', 'isPresent': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roster Ledger Entry')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subject: Data Structures', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Hour Block: #03'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _studentRoster.length,
              itemBuilder: (context, index) {
                return SwitchListTile(
                  title: Text(_studentRoster[index]['name']),
                  subtitle: Text('Registration Ref ID: ${_studentRoster[index]['id']}'),
                  value: _studentRoster[index]['isPresent'],
                  secondary: CircleAvatar(
                    backgroundColor: _studentRoster[index]['isPresent'] ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(
                      _studentRoster[index]['isPresent'] ? Icons.check : Icons.close,
                      color: _studentRoster[index]['isPresent'] ? Colors.green : Colors.red,
                    ),
                  ),
                  onChanged: (bool modernStatusValue) {
                    setState(() {
                      _studentRoster[index]['isPresent'] = modernStatusValue;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () {
                // Trigger backend bulk insert operation payload via AcademicProvider
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Submitting attendance session payload...')),
                );
              },
              child: const Text('Commit Current Log Entry'),
            ),
          )
        ],
      ),
    );
  }
}