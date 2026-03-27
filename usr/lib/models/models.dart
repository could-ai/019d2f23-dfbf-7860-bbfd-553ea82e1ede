enum UserRole { admin, employer, candidate }

enum AppStatus { submitted, interview, accepted, rejected }

extension AppStatusExtension on AppStatus {
  String get displayName {
    switch (this) {
      case AppStatus.submitted: return 'Submitted';
      case AppStatus.interview: return 'Interview';
      case AppStatus.accepted: return 'Accepted';
      case AppStatus.rejected: return 'Rejected';
    }
  }
}

class User {
  final String id;
  final String name;
  final UserRole role;
  final String? companyId;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.companyId,
  });
}

class Company {
  final String id;
  final String name;

  Company({
    required this.id,
    required this.name,
  });
}

class JobPosting {
  final String id;
  final String companyId;
  final String title;
  final double salary;
  final DateTime deadline;

  JobPosting({
    required this.id,
    required this.companyId,
    required this.title,
    required this.salary,
    required this.deadline,
  });
}

class Application {
  final String id;
  final String jobId;
  final String candidateId;
  final String cvFileName;
  AppStatus status;

  Application({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.cvFileName,
    this.status = AppStatus.submitted,
  });
}
