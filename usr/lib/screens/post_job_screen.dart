import 'package:flutter/material.dart';
import '../services/mock_backend.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _salaryController = TextEditingController();
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 7));

  void _submit() {
    if (_formKey.currentState!.validate()) {
      try {
        final salary = double.tryParse(_salaryController.text) ?? 0;
        MockBackend.instance.postJob(
          _titleController.text,
          salary,
          _selectedDeadline,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Job')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title (min 10 chars)'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: 'Salary (must be > 0)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Deadline: '),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDeadline,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)), // Allow past dates to test validation
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _selectedDeadline = date);
                      }
                    },
                    child: Text(_selectedDeadline.toString().split(' ')[0]),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit Job Posting'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
