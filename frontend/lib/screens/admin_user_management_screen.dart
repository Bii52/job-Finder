import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  late Future<void> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = Provider.of<UserProvider>(context, listen: false).fetchAllUsers();
  }

  Future<void> _refreshUsers() async {
    await Provider.of<UserProvider>(context, listen: false).fetchAllUsers();
  }

  Future<void> _deleteUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa người dùng này?'),
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
        await Provider.of<UserProvider>(context, listen: false).deleteUser(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Xóa người dùng thành công'),
              backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi khi xóa người dùng: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editUserRole(User user) async {
    String? selectedRole = user.role;
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thay đổi vai trò cho ${user.name}'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                items: ['job_seeker', 'employer', 'admin']
                    .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedRole),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (newRole != null && newRole != user.role) {
      try {
        await Provider.of<UserProvider>(context, listen: false).updateUserRole(user.id, newRole);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Cập nhật vai trò thành công'),
              backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi khi cập nhật vai trò: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Người dùng'),
      ),
      body: FutureBuilder(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error.toString()}'));
          }

          return Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.users.isEmpty) {
                return const Center(child: Text('Không có người dùng nào.'));
              }

              final users = userProvider.users;

              return RefreshIndicator(
                onRefresh: _refreshUsers,
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isCurrentUser = user.id == currentUserId;
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U'),
                        ),
                        title: Text(user.name),
                        subtitle: Text('${user.email}\nRole: ${user.role}'),
                        isThreeLine: true,
                        trailing: isCurrentUser
                            ? const Chip(label: Text('You'))
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                                    onPressed: () => _editUserRole(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _deleteUser(user.id),
                                  ),
                                ],
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