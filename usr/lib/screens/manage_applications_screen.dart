import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_backend.dart';

class ManageApplicationsScreen extends StatefulWidget {
  final JobPosting job;
  const ManageApplicationsScreen({super.key, required this.job});

  @override
  State<ManageApplicationsScreen> createState() => _ManageApplicationsScreenState();
}

class _ManageApplicationsScreenState extends State<ManageApplicationsScreen> {
  final backend = MockBackend.instance;

  void _updateStatus(Application app, AppStatus newStatus) {
    try {
      backend.updateApplicationStatus(app.id, newStatus);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final apps = backend.getApplicationsForJob(widget.job.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Applications')),
      body: apps.isEmpty
          ? const Center(child: Text('No applications yet.'))
          : ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                final candidate = backend.users.firstWhere((u) => u.id == app.candidateId);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(candidate.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('CV: ${app.cvFileName}'),
                    trailing: DropdownButton<AppStatus>(
                      value: app.status,
                      onChanged: (AppStatus? newValue) {
                        if (newValue != null) {
                          _updateStatus(app, newValue);
                        }
                      },
                      items: AppStatus.values.map((AppStatus status) {
                        return DropdownMenuItem<AppStatus>(
                          value: status,
                          child: Text(status.displayName),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
