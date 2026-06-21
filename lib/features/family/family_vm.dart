import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/models/family_member.dart';

/// ViewModel for the Family screen.
class FamilyVm extends ChangeNotifier {
  List<FamilyMember> members = [];
  bool loading = false;

  // Privacy controls state
  bool showVitals = true;
  bool showMedications = true;
  bool showLabResults = true;
  bool showCareJourney = true;

  FamilyVm() {
    load();
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();

    // Mock family members data
    members = const [
      FamilyMember(
        id: 'fm-001',
        name: 'Mahmoud Ibrahim',
        initials: 'MI',
        role: 'Son',
        relationship: 'Account Manager',
        status: 'active',
        accessLevel: 'Full Access',
        description: "Can act on patient's behalf",
      ),
      FamilyMember(
        id: 'fm-002',
        name: 'Samia Ibrahim',
        initials: 'SI',
        role: 'Spouse',
        relationship: 'Spouse',
        status: 'active',
        accessLevel: 'View Only',
        description: 'View status & receive alerts',
      ),
    ];

    loading = false;
    notifyListeners();
  }

  void toggleVitals(bool value) {
    showVitals = value;
    notifyListeners();
  }

  void toggleMedications(bool value) {
    showMedications = value;
    notifyListeners();
  }

  void toggleLabResults(bool value) {
    showLabResults = value;
    notifyListeners();
  }

  void toggleCareJourney(bool value) {
    showCareJourney = value;
    notifyListeners();
  }

  Future<void> scanQRCode(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        if (!context.mounted) return;
        _showDialog(
          context,
          title: 'QR Code Scanned',
          content:
              'Image captured successfully. QR code processing will be implemented next.',
          buttonText: 'OK',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showDialog(
        context,
        title: 'Camera Error',
        content: 'Failed to open camera: ${e.toString()}',
        buttonText: 'OK',
      );
    }
  }

  Future<void> addManually(BuildContext context) async {
    // Show a dialog with form fields for manual member addition
    String name = '';
    String relationship = '';
    String accessLevel = 'View Only';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Family Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Relationship'),
                onChanged: (value) => relationship = value,
              ),
              SizedBox(height: 16),
              DropdownButton<String>(
                value: accessLevel,
                onChanged: (value) => accessLevel = value ?? 'View Only',
                items: ['Full Access', 'View Only']
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (name.isNotEmpty && relationship.isNotEmpty) {
                _addMember(name, relationship, accessLevel);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addMember(String name, String relationship, String accessLevel) {
    final initials = _getInitials(name);
    final newMember = FamilyMember(
      id: 'fm-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      initials: initials,
      role: relationship,
      relationship: relationship,
      status: 'pending',
      accessLevel: accessLevel,
      description: accessLevel == 'Full Access'
          ? "Can act on patient's behalf"
          : 'View status & receive alerts',
    );
    members.add(newMember);
    notifyListeners();
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _showDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String buttonText,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  void removeMember(String memberId) {
    members.removeWhere((m) => m.id == memberId);
    notifyListeners();
  }
}
