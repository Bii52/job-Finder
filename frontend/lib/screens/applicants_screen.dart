import 'package:flutter/material.dart';
import 'package:frontend/models/job.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/job_provider.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class ApplicantsScreen extends StatefulWidget {
  final Job job;
  const ApplicantsScreen({super.key, required this.job});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  late Future<List<dynamic>> _applicantsFuture;

  @override
  void initState() {
    super.initState();
    _applicantsFuture = Provider.of<JobProvider>(context, listen: false)
        .getApplicants(widget.job.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Applicants for ${widget.job.title}'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _applicantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text('No applicants to show yet.'),
                ],
              ),
            );
          }

          final applicants = snapshot.data!;

          return ListView.builder(
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              // Backend trả về một object có chứa 'user'
              final applicantData = applicants[index]['user'];
              if (applicantData == null) return const SizedBox.shrink();

              final applicant = User.fromJson(applicantData);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(applicant.name.isNotEmpty ? applicant.name[0].toUpperCase() : 'U'),
                  ),
                  title: Text(applicant.name),
                  subtitle: Text(applicant.email),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userToShow: applicant),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}