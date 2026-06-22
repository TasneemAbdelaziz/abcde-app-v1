import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/models/family_member.dart';
import '../../core/repositories/patient_api_repository.dart';
import '../home/home_vm.dart';

/// ViewModel for the Family screen.
class FamilyVm extends ChangeNotifier {
  final PatientApiRepository? _api;
  final HomeVm? _home;

  List<FamilyMember> members = [];
  bool loading = false;

  // Privacy controls state
  bool showVitals = true;
  bool showMedications = true;
  bool showLabResults = true;
  bool showCareJourney = true;

  FamilyVm([this._api, this._home]) {
    // If HomeVm already has a profile, load immediately. Otherwise listen
    // for when it becomes available.
    if (_home != null && _home!.profile != null) {
      load();
    } else if (_home != null) {
      _home!.addListener(_homeListener);
    } else {
      // Fallback: attempt load (will use _api.getMySerial if provided).
      load();
    }
  }

  void _homeListener() {
    if (_home != null && _home!.profile != null) {
      _home!.removeListener(_homeListener);
      load();
    }
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      List<Map<String, dynamic>> raw = [];

      // Prefer the patient serial from HomeVm.profile when available.
      String serial = '';
      if (_home != null && _home!.profile != null) {
        serial = _home!.profile!.serial;
      }

      if (serial.isEmpty && _api != null) {
        serial = await _api!.getMySerial();
      }

      if (serial.isNotEmpty && _api != null) {
        raw = await _api!.getFamily(serial);
      }

      if (raw.isEmpty) {
        members = [];
      } else {
        members = [for (final e in raw) _fromApi(e)];
      }
    } catch (e) {
      members = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  FamilyMember _fromApi(Map<String, dynamic> e) {
    final idNum = e['id']?.toString() ?? '';
    final name = (e['companion_name'] ?? '').toString();
    final relation = (e['relation'] ?? '').toString();
    final phone = (e['companion_phone'] ?? '').toString();
    final canSee = (e['can_see_status'] ?? false) as bool? ?? false;
    final receives = (e['receives_alerts'] ?? false) as bool? ?? false;
    final isDecision = (e['is_decision_maker'] ?? false) as bool? ?? false;
    final accepted = (e['is_accepted'] ?? false) as bool? ?? false;

    final initials = _getInitials(name);
    final status = accepted ? 'active' : 'pending';
    String accessLevel = 'View Only';
    String description = '';
    if (isDecision) {
      accessLevel = 'Full Access';
      description = "Can act on patient's behalf";
    } else if (canSee && receives) {
      accessLevel = 'View Only';
      description = 'View status & receive alerts';
    } else if (canSee) {
      accessLevel = 'View Only';
      description = 'Can see status';
    }

    return FamilyMember(
      id: 'fm-$idNum',
      name: name.isNotEmpty ? name : 'Unknown',
      initials: initials,
      role: relation.isNotEmpty ? relation : 'Relative',
      relationship: phone,
      status: status,
      accessLevel: accessLevel,
      description: description,
    );
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

  @override
  void dispose() {
    if (_home != null) _home!.removeListener(_homeListener);
    super.dispose();
  }
}
