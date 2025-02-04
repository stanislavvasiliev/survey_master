class FacultyDetails {
  final String name;
  final List<String> groups;

  FacultyDetails({required this.name, required this.groups});

  factory FacultyDetails.fromJson(Map<String, dynamic> json) {
    return FacultyDetails(
      name: json['name'],
      groups: List<String>.from(json['groups']),
    );
  }
}

Future<FacultyDetails> getFacultyDetails(String hashId) async {
  // Mock data for faculties and their groups
  const mockData = [
    {
      "name": "Faculty of Computer Science",
      "groups": [
        "CS-101",
        "CS-102",
        "CS-103",
        "CS-201",
        "CS-202",
        "CS-301",
        "CS-302",
        "CS-303",
        "CS-401",
        "CS-501",
        "CS-502",
        "CS-503",
        "CS-504",
        "CS-601",
        "CS-602"
      ],
      "hash_id": 'def456uvw1237890mnopqrstuvabcxyz',
    },
    {
      "name": "Faculty of Engineering",
      "groups": [
        "ENG-101",
        "ENG-102",
        "ENG-103",
        "ENG-201",
        "ENG-301",
        "ENG-302",
        "ENG-303",
        "ENG-304",
        "ENG-401",
        "ENG-402",
        "ENG-501",
        "ENG-502",
        "ENG-601",
        "ENG-602",
        "ENG-603"
      ],
      "hash_id": 'abc123xyz4567890defghijklmnopqrstuv',
    },
    {
      "name": "Faculty of Business",
      "groups": [
        "BUS-101",
        "BUS-102",
        "BUS-201",
        "BUS-301",
        "BUS-302",
        "BUS-303",
        "BUS-401",
        "BUS-402",
        "BUS-403",
        "BUS-404",
        "BUS-501",
        "BUS-601",
        "BUS-602"
      ],
      "hash_id": 'xyz789def1234567ghijklmnopqrstuvabc',
    }
  ];

  // Find faculty by hashId
  final facultyData = mockData.firstWhere(
    (data) => data['hash_id'] == hashId,
    orElse: () => throw Exception("Faculty not found"),
  );

  return FacultyDetails.fromJson(facultyData);
}
