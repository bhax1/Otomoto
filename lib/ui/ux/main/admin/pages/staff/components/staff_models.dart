class StaffMember {
  final String id;
  final String firstname;
  final String lastname;
  final String contact;
  final String email;
  final String status;
  final String jobPosition;

  StaffMember({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.contact,
    required this.email,
    required this.status,
    required this.jobPosition,
  });

  factory StaffMember.fromMap(Map<String, dynamic> map) {
    return StaffMember(
      id: map['id'] ?? '',
      firstname: map['firstname'] ?? '',
      lastname: map['lastname'] ?? '',
      contact: map['contact'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? '',
      jobPosition: map['job_position'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'contact': contact,
      'email': email,
      'status': status,
      'job_position': jobPosition,
    };
  }
}
