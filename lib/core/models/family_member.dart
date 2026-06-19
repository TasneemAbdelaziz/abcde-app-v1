/// A family member or caregiver with access to the patient's records.
class FamilyMember {
  final String id;
  final String name;
  final String initials;
  final String role; // e.g. 'Son', 'Spouse', 'Caregiver'
  final String relationship; // e.g. 'Account Manager', longer description
  final String status; // 'active', 'pending', 'inactive'
  final String accessLevel; // 'Full Access', 'View Only'
  final String description; // e.g. "Can act on patient's behalf"

  const FamilyMember({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    required this.relationship,
    required this.status,
    required this.accessLevel,
    required this.description,
  });

  FamilyMember copyWith({
    String? id,
    String? name,
    String? initials,
    String? role,
    String? relationship,
    String? status,
    String? accessLevel,
    String? description,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      role: role ?? this.role,
      relationship: relationship ?? this.relationship,
      status: status ?? this.status,
      accessLevel: accessLevel ?? this.accessLevel,
      description: description ?? this.description,
    );
  }
}
