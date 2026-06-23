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
    final canBook = (e['can_book'] ?? false) as bool? ?? false;
    final canRate = (e['can_rate'] ?? false) as bool? ?? false;
    final canEmergency = (e['can_raise_emergency'] ?? false) as bool? ?? false;
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
      canSeeStatus: canSee,
      receivesAlerts: receives,
      canBook: canBook,
      canRate: canRate,
      canRaiseEmergency: canEmergency,
      isDecisionMaker: isDecision,
    );
  }

  /// Updates a member's six permission flags via
  /// `PATCH /family/{id}/permissions`, then reloads from the server.
  Future<void> updatePermissions(
    String memberId,
    Map<String, dynamic> permissions,
  ) async {
    final rawId = memberId.replaceFirst('fm-', '');
    final api = _api;
    if (api == null || rawId.isEmpty) return;
    try {
      await api.updateFamilyPermissions(rawId, permissions);
      await load();
    } catch (_) {
      await load(); // re-sync with the server on failure
    }
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
    // Manual add form: name, relationship, phone, and the six permission flags.
    String name = '';
    String relationship = '';
    String phone = '';
    final perms = <String, bool>{
      'can_see_status': true,
      'receives_alerts': true,
      'can_book': false,
      'can_rate': true,
      'can_raise_emergency': false,
      'is_decision_maker': false,
    };

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => AlertDialog(
          title: const Text('Add Family Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'Relationship'),
                  onChanged: (value) => relationship = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => phone = value,
                ),
                const SizedBox(height: 8),
                for (final entry in _permissionLabels.entries)
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.value),
                    value: perms[entry.key] ?? false,
                    onChanged: (v) => setSheet(() => perms[entry.key] = v),
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
                  _addMember(name, relationship, phone, Map.of(perms));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  /// Human-readable labels for the six backend permission flags.
  static const Map<String, String> _permissionLabels = {
    'can_see_status': 'Can see care status',
    'receives_alerts': 'Receives alerts',
    'can_book': 'Can book appointments',
    'can_rate': 'Can submit ratings',
    'can_raise_emergency': 'Can raise emergency',
    'is_decision_maker': 'Decision maker',
  };

  /// The patient serial (from HomeVm.profile or /auth/me).
  Future<String> _serial() async {
    final fromHome = _home?.profile?.serial ?? '';
    if (fromHome.isNotEmpty) return fromHome;
    if (_api != null) return _api!.getMySerial();
    return '';
  }

  /// Adds a family member via `POST /patients/{serial}/family`, then reloads.
  Future<void> _addMember(
    String name,
    String relationship,
    String phone,
    Map<String, bool> permissions,
  ) async {
    final serial = await _serial();
    final api = _api;
    if (serial.isEmpty || api == null) return;

    try {
      await api.addFamilyMember(serial, {
        'companion_name': name,
        'relation': relationship,
        'companion_phone': phone,
        ...permissions,
      });
      await load();
    } catch (_) {
      // Keep the list as-is; the user can retry.
    }
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

  /// Removes a family member via `DELETE /family/{id}`. Optimistic.
  Future<void> removeMember(String memberId) async {
    final rawId = memberId.replaceFirst('fm-', '');
    members.removeWhere((m) => m.id == memberId);
    notifyListeners();

    final api = _api;
    if (api == null || rawId.isEmpty) return;
    try {
      await api.deleteFamilyMember(rawId);
    } catch (_) {
      await load(); // restore from server on failure
    }
  }

  @override
  void dispose() {
    if (_home != null) _home!.removeListener(_homeListener);
    super.dispose();
  }
}
