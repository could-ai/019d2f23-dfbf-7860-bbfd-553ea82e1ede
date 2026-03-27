import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_backend.dart';
import 'post_job_screen.dart';
import 'apply_screen.dart';
import 'manage_applications_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final backend = MockBackend.instance;

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = backend.currentUser!;
    final canPost = user.role == UserRole.admin || user.role == UserRole.employer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Listings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(child: Text('Logged in: ${user.name}')),
          ),
        ],
      ),
      body: backend.jobs.isEmpty
          ? const Center(child: Text('No job postings available.'))
          : ListView.builder(
              itemCount: backend.jobs.length,
              itemBuilder: (context, index) {
                final job = backend.jobs[index];
                final company = backend.companies.firstWhere((c) => c.id == job.companyId);
                final isExpired = DateTime.now().isAfter(job.deadline);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${company.name} • \$${job.salary.toStringAsFixed(2)}\nDeadline: ${job.deadline.toString().split(' ')[0]} ${isExpired ? "(Expired)" : ""}'),
                    isThreeLine: true,
                    trailing: _buildActionButtons(job, user),
                  ),
                );
              },
            ),
      floatingActionButton: canPost
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostJobScreen()),
                );
                _refresh();
              },
              icon: const Icon(Icons.add),
              label: const Text('Post Job'),
            )
          : null,
    );
  }

  Widget? _buildActionButtons(JobPosting job, User user) {
    if (user.role == UserRole.candidate) {
      return ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ApplyScreen(job: job)),
          );
          _refresh();
        },
        child: const Text('Apply'),
      );
    } else if (user.role == UserRole.employer && user.companyId == job.companyId) {
      return ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManageApplicationsScreen(job: job)),
          );
          _refresh();
        },
        child: const Text('View Apps'),
      );
    }
    return null;
  }
}
