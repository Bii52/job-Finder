import 'package:flutter/material.dart';
import 'package:frontend/models/job.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/chat_screen.dart';
import 'package:frontend/services/api_service.dart' as services;
import 'package:frontend/services/job_service.dart';
import 'package:provider/provider.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final apiService = services.ApiService(); // We'll use this to start a chat
    final isFavorite = authProvider.user?.favorites.any((favJob) => favJob.id == widget.job.id) ?? false;
    final isMyJob = authProvider.user?.id == widget.job.employer.id;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red.shade400 : Colors.grey.shade400,
                      ),
                      onPressed: _isApplying ? null : () {
                        authProvider.toggleFavorite(widget.job.id);
                      },
                    ),
                  ],
                ),
              ),

              // Job Details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.business_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.job.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.job.company} • ${widget.job.location}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Job Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.job.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Skills
                      const Text(
                        'Required Skills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: widget.job.skills
                            .map((skill) => Chip(
                                  label: Text(skill),
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isMyJob
          ? null // Không hiển thị FAB nếu đây là công việc của chính nhà tuyển dụng
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  FloatingActionButton(
                    heroTag: 'chat_fab',
                    onPressed: () async {
                      if (_isApplying) return;
                      try {
                        final conversation = await apiService.createConversation(widget.job.employer.id);
                        if (conversation != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                conversationId: conversation.id,
                                recipient: widget.job.employer,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
                          );
                        }
                      }
                    },
                    backgroundColor: Colors.white,
                    child: Icon(Icons.chat_bubble_outline_rounded, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FloatingActionButton.extended(
                      heroTag: 'apply_fab',
                      onPressed: _isApplying ? null : () async {
                        setState(() => _isApplying = true);
                        try {
                          // Giả sử bạn có một JobService instance hoặc thêm applyForJob vào ApiService
                          final jobService = JobService();
                          await jobService.applyForJob(widget.job.id);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Application submitted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to apply: ${e.toString().replaceFirst("Exception: ", "")}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isApplying = false);
                          }
                        }
                      },
                      label: _isApplying ? const Text('Applying...') : const Text('Apply Now'),
                      icon: _isApplying
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}