import 'package:flutter/material.dart';
import 'package:frontend/models/job.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/job_provider.dart';
import 'package:frontend/screens/applicants_screen.dart';
import 'package:provider/provider.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({super.key});

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  late Future<void> _fetchJobsFuture;

  @override
  void initState() {
    super.initState();
    _fetchJobsFuture = Provider.of<JobProvider>(context, listen: false).fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Job Postings'),
      ),
      body: FutureBuilder(
        future: _fetchJobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('An error occurred!'));
          } else {
            return Consumer<JobProvider>(
              builder: (context, jobProvider, child) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final employerJobs = jobProvider.jobs.where((job) => job.employer.id == authProvider.user?.id).toList();
                if (employerJobs.isEmpty) {
                  return const Center(child: Text('You have not posted any jobs yet.'));
                }
                return RefreshIndicator(
                  onRefresh: () => Provider.of<JobProvider>(context, listen: false).fetchJobs(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: employerJobs.length,
                    itemBuilder: (context, index) {
                      final job = employerJobs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: ListTile(
                          title: Text(job.title),
                          subtitle: Text('${job.company} - ${job.location}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditJobDialog(context, job),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => jobProvider.deleteJob(job.id),
                              ),
                            ],
                          ),
                          onTap: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ApplicantsScreen(job: job)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddJobDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddJobDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String company = '';
    String location = '';
    int? salary;
    String skills = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Job'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                    onSaved: (value) => title = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                    onSaved: (value) => description = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Company'),
                    validator: (value) => value!.isEmpty ? 'Please enter a company name' : null,
                    onSaved: (value) => company = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Location'),
                    validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
                    onSaved: (value) => location = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Salary'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => salary = int.tryParse(value!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Skills (comma separated)'),
                    validator: (value) => value!.isEmpty ? 'Please enter at least one skill' : null,
                    onSaved: (value) => skills = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final skillList = skills.split(',').map((s) => s.trim()).toList();
                  Provider.of<JobProvider>(context, listen: false).addJob(
                    title,
                    description,
                    company,
                    location,
                    salary,
                    skillList,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditJobDialog(BuildContext context, Job job) {
    final _formKey = GlobalKey<FormState>();
    String title = job.title;
    String description = job.description;
    String company = job.company;
    String location = job.location;
    int? salary = job.salary;
    String skills = job.skills.join(', ');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Job'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                    onSaved: (value) => title = value!,
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                    onSaved: (value) => description = value!,
                  ),
                  TextFormField(
                    initialValue: company,
                    decoration: const InputDecoration(labelText: 'Company'),
                    validator: (value) => value!.isEmpty ? 'Please enter a company name' : null,
                    onSaved: (value) => company = value!,
                  ),
                  TextFormField(
                    initialValue: location,
                    decoration: const InputDecoration(labelText: 'Location'),
                    validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
                    onSaved: (value) => location = value!,
                  ),
                  TextFormField(
                    initialValue: salary?.toString(),
                    decoration: const InputDecoration(labelText: 'Salary'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => salary = int.tryParse(value!),
                  ),
                  TextFormField(
                    initialValue: skills,
                    decoration: const InputDecoration(labelText: 'Skills (comma separated)'),
                    validator: (value) => value!.isEmpty ? 'Please enter at least one skill' : null,
                    onSaved: (value) => skills = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final skillList = skills.split(',').map((s) => s.trim()).toList();
                  Provider.of<JobProvider>(context, listen: false).updateJob(
                    job.id,
                    title,
                    description,
                    company,
                    location,
                    salary,
                    skillList,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
