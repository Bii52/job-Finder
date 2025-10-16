import 'package:flutter/material.dart';
import 'package:frontend/models/job.dart';
import 'package:frontend/providers/job_provider.dart';
import 'package:provider/provider.dart';

class AdminJobManagementScreen extends StatefulWidget {
  const AdminJobManagementScreen({super.key});

  @override
  State<AdminJobManagementScreen> createState() => _AdminJobManagementScreenState();
}

class _AdminJobManagementScreenState extends State<AdminJobManagementScreen> {
  late Future<void> _jobsFuture;

  @override
  void initState() {
    super.initState();
    // Không gọi listen: false ở đây vì chúng ta muốn UI cập nhật khi job được xóa
    _jobsFuture = Provider.of<JobProvider>(context, listen: false).fetchJobs();
  }

  Future<void> _refreshJobs() async {
    await Provider.of<JobProvider>(context, listen: false).fetchJobs();
  }


  Future<void> _deleteJob(String jobId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa tin đăng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Sử dụng JobProvider để xóa
        await Provider.of<JobProvider>(context, listen: false).deleteJob(jobId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Xóa tin đăng thành công'),
              backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi khi xóa tin đăng: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tin đăng'),
      ),
      body: FutureBuilder(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error.toString()}'));
          }

          return Consumer<JobProvider>(
            builder: (context, jobProvider, child) {
              if (jobProvider.jobs.isEmpty) {
                return const Center(child: Text('Không có tin đăng nào.'));
              }

              return RefreshIndicator(
                onRefresh: _refreshJobs,
                child: ListView.builder(
                  itemCount: jobProvider.jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobProvider.jobs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(job.title),
                        subtitle: Text('${job.company} - Đăng bởi: ${job.employer.name}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                          onPressed: () => _deleteJob(job.id),
                        ),
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