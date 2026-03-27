import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_backend.dart';

class ApplyScreen extends StatefulWidget {
  final JobPosting job;
  const ApplyScreen({super.key, required this.job});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fileNameController = TextEditingController(text: 'resume.pdf');
  final _fileSizeController = TextEditingController(text: '2.5');

  void _submit() {
    if (_formKey.currentState!.validate()) {
      try {
        final size = double.tryParse(_fileSizeController.text) ?? 0;
        MockBackend.instance.submitApplication(
          widget.job.id,
          _fileNameController.text,
          size,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!'), backgroundColor: Colors.green),
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
      appBar: AppBar(title: const Text('Submit Application')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Applying for: ${widget.job.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('Mock File Upload:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _fileNameController,
                decoration: const InputDecoration(labelText: 'File Name (must be .pdf)'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fileSizeController,
                decoration: const InputDecoration(labelText: 'File Size in MB (must be <= 10)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit Application'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
