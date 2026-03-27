import '../models/models.dart';

class MockBackend {
  // Singleton pattern
  static final MockBackend instance = MockBackend._internal();

  MockBackend._internal() {
    // Seed initial mock data
    companies = [
      Company(id: 'c1', name: 'Tech Corp'),
      Company(id: 'c2', name: 'Innovate LLC'),
    ];

    users = [
      User(id: 'u1', name: 'Admin Alice', role: UserRole.admin),
      User(id: 'u2', name: 'Employer Bob (Tech Corp)', role: UserRole.employer, companyId: 'c1'),
      User(id: 'u3', name: 'Employer Eve (Innovate LLC)', role: UserRole.employer, companyId: 'c2'),
      User(id: 'u4', name: 'Candidate Charlie', role: UserRole.candidate),
    ];

    currentUser = users[0]; // Default logged in user
  }

  List<User> users = [];
  List<Company> companies = [];
  List<JobPosting> jobs = [];
  List<Application> applications = [];

  User? currentUser;

  void login(String userId) {
    currentUser = users.firstWhere((u) => u.id == userId);
  }

  // 1. Post Job Listings (Model & Route Logic)
  void postJob(String title, double salary, DateTime deadline) {
    final user = currentUser;
    
    // Roles: Only 'Employer' or 'Admin' can post.
    if (user == null || (user.role != UserRole.employer && user.role != UserRole.admin)) {
      throw Exception('Unauthorized: Only Employer or Admin can post jobs.');
    }

    // Validation: Title must be >= 10 characters.
    if (title.trim().length < 10) {
      throw Exception('Validation Error: Title must be at least 10 characters.');
    }

    // Validation: Salary must be > 0.
    if (salary <= 0) {
      throw Exception('Validation Error: Salary must be greater than 0.');
    }

    // Validation: Deadline must be > current date.
    if (deadline.isBefore(DateTime.now())) {
      throw Exception('Validation Error: Deadline must be in the future.');
    }

    // Determine company context (Admins might post for a default company in this mock)
    final compId = user.companyId ?? 'c1';

    // Unique constraint: A company cannot have two job postings with the exact same title.
    final exists = jobs.any((j) => j.companyId == compId && j.title.toLowerCase() == title.toLowerCase());
    if (exists) {
      throw Exception('Constraint Error: Your company already has a job posting with this exact title.');
    }

    jobs.add(JobPosting(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyId: compId,
      title: title.trim(),
      salary: salary,
      deadline: deadline,
    ));
  }

  // 2. Submit Application (Model & Route Logic)
  void submitApplication(String jobId, String fileName, double fileSizeMB) {
    final user = currentUser;
    
    // Roles: Candidate must be logged in.
    if (user == null || user.role != UserRole.candidate) {
      throw Exception('Unauthorized: Only Candidates can submit applications.');
    }

    final job = jobs.firstWhere((j) => j.id == jobId, orElse: () => throw Exception('Job not found.'));

    // Time validation: Cannot submit if the current date is past the job posting's deadline.
    if (DateTime.now().isAfter(job.deadline)) {
      throw Exception('Validation Error: Cannot apply past the job deadline.');
    }

    // File validation: The CV must be a PDF.
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      throw Exception('Validation Error: The CV must be a PDF file.');
    }

    // File validation: Strictly <= 10MB.
    if (fileSizeMB > 10.0) {
      throw Exception('Validation Error: The CV must be strictly <= 10MB.');
    }

    // Unique constraint: A candidate can only apply once per job posting.
    final exists = applications.any((a) => a.jobId == jobId && a.candidateId == user.id);
    if (exists) {
      throw Exception('Constraint Error: You have already applied for this job posting.');
    }

    applications.add(Application(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      jobId: jobId,
      candidateId: user.id,
      cvFileName: fileName,
      status: AppStatus.submitted,
    ));
  }

  // 3. View and Update Application Status (Route Logic)
  void updateApplicationStatus(String appId, AppStatus newStatus) {
    final user = currentUser;
    
    // Roles: Only the 'Employer' can update the status.
    if (user == null || user.role != UserRole.employer) {
      throw Exception('Unauthorized: Only Employers can update application status.');
    }

    final app = applications.firstWhere((a) => a.id == appId, orElse: () => throw Exception('Application not found.'));
    final job = jobs.firstWhere((j) => j.id == app.jobId);

    // Roles: Only the Employer (who owns the job posting) can update the status.
    if (job.companyId != user.companyId) {
      throw Exception('Unauthorized: You can only update applications for your own company\\'s job postings.');
    }

    // State Machine Rule: Cannot transition from 'Rejected' to 'Interview'.
    if (app.status == AppStatus.rejected && newStatus == AppStatus.interview) {
      throw Exception('State Machine Error: Cannot transition an application from Rejected to Interview.');
    }

    app.status = newStatus;
  }
  
  // Helper to get applications for a specific job
  List<Application> getApplicationsForJob(String jobId) {
    return applications.where((a) => a.jobId == jobId).toList();
  }
}
