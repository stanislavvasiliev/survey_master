class EduInstitution {
  final String name;
  final List<String> groups;
  final String hashId;

  EduInstitution({
    required this.name,
    required this.groups,
    required this.hashId,
  });

  factory EduInstitution.fromJson(Map<String, dynamic> json) {
    return EduInstitution(
      name: json['name'],
      groups: List<String>.from(json['groups']),
      hashId: json['hash_id'],
    );
  }
}
