class Customer {
  final String id;
  final String name;
  final String phone;
  final String gender;
  final DateTime? dob;
  final DateTime appointmentDate;
  final String? photoPath;
  final String? location;
  final bool completed;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.appointmentDate,
    this.dob,
    this.photoPath,
    this.location,
    this.completed = false,
  });

  String get displayTitle => '$name — $phone';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'gender': gender,
    'dob': dob?.toIso8601String(),
    'appointmentDate': appointmentDate.toIso8601String(),
    'photoPath': photoPath,
    'location': location,
    'completed': completed,
  };

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
    id: j['id'] as String,
    name: j['name'] as String,
    phone: j['phone'] as String,
    gender: j['gender'] as String,
    dob: j['dob'] == null ? null : DateTime.parse(j['dob'] as String),
    appointmentDate: DateTime.parse(j['appointmentDate'] as String),
    photoPath: j['photoPath'] as String?,
    location: j['location'] as String?,
    completed: j['completed'] == null ? false : (j['completed'] as bool),
  );
}
