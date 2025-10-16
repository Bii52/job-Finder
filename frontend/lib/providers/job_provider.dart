import 'package:flutter/material.dart';
import 'package:frontend/models/job.dart';
import 'package:frontend/services/job_service.dart';

class JobProvider with ChangeNotifier {
  final JobService _jobService = JobService();
  List<Job> _jobs = [];
  bool _isLoading = false;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;

  Future<void> fetchJobs() async {
    _isLoading = true;
    notifyListeners();
    try {
      _jobs = await _jobService.getJobs();
    } catch (e) {
      // Handle error appropriately
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addJob(String title, String description, String company, String location, int? salary, List<String> skills) async {
    try {
      final newJob = await _jobService.createJob(title, description, company, location, salary, skills);
      _jobs.add(newJob);
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateJob(String id, String title, String description, String company, String location, int? salary, List<String> skills) async {
    try {
      final updatedJob = await _jobService.updateJob(id, title, description, company, location, salary, skills);
      final index = _jobs.indexWhere((job) => job.id == id);
      if (index != -1) {
        _jobs[index] = updatedJob;
        notifyListeners();
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteJob(String id) async {
    try {
      await _jobService.deleteJob(id);
      _jobs.removeWhere((job) => job.id == id);
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<dynamic>> getApplicants(String jobId) async {
    try {
      final applicants = await _jobService.getApplicants(jobId);
      return applicants;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}