import '../models/diagnosis.dart';
import '../models/medicine.dart';
import '../models/patient.dart';
import '../models/report.dart';
import '../models/treatment.dart';
import '../models/visit.dart';
import '../models/visit_stage.dart';
import '../models/vital.dart';

/// The ONE data source for the whole app, for now.
///
/// Every method returns hardcoded mock data. ViewModels call these methods;
/// screens never call the repository directly.
///
/// TODO: extract interface + ApiPatientRepository when backend is ready.
/// (Keep this concrete class as the mock implementation for tests/dev.)
class PatientRepository {
  /// The current logged-in patient.
  Patient getPatient() => Patient.fromMock();

  /// Short text describing where the patient is in their care journey.
  String getJourneySummary() => 'Stage 5 of 8 Â· Recovery & Monitoring';

  /// Latest vital readings (shown in the Home screen strip).
  List<Vital> getVitals() {
    return const [
      Vital(label: 'Heart Rate', value: '72', unit: 'bpm'),
      Vital(label: 'SpOâ', value: '98', unit: '%'),
      Vital(label: 'Blood Pressure', value: '120/80', unit: ''),
      Vital(label: 'Temperature', value: '36.6', unit: 'Â°C'),
      Vital(label: 'Respiration', value: '16', unit: '/min'),
    ];
  }

  /// Stages of the treatment journey, in order.
  List<VisitStage> getStages() {
    return const [
      VisitStage(id: 's-001', title: 'Admission', status: 'done', rating: 5),
      VisitStage(id: 's-002', title: 'Diagnosis', status: 'done', rating: 4),
      VisitStage(id: 's-003', title: 'Treatment', status: 'current'),
      VisitStage(id: 's-004', title: 'Discharge', status: 'upcoming'),
    ];
  }

  /// The patient's visits (one active, the rest completed). The active visit
  /// carries its Care Journey timeline.
  List<Visit> getVisits() => Visit.mockList();

  /// Lab reports and medical documents.
  List<Report> getReports() {
    return const [
      Report(id: 'r-001', title: 'Blood Test â Complete Panel', date: '2026-06-10', type: 'lab'),
      Report(id: 'r-002', title: 'Chest X-Ray', date: '2026-06-11', type: 'imaging'),
      Report(id: 'r-003', title: 'Discharge Summary', date: '2026-06-13', type: 'summary'),
    ];
  }

  /// Prescribed medicines (with optional product photos).
  List<Medicine> getMedicines() {
    return const [
      Medicine(id: 'm-001', name: 'Aspirin', dose: '81 mg', schedule: 'Once daily · after breakfast', photoAsset: 'assets/images/meds/aspirin.jpeg'),
      Medicine(id: 'm-002', name: 'Atorvastatin', dose: '40 mg', schedule: 'Once daily · evening', photoAsset: 'assets/images/meds/atorvastatin.jpeg'),
      Medicine(id: 'm-003', name: 'Clopidogrel', dose: '75 mg', schedule: 'Once daily · morning', photoAsset: 'assets/images/meds/clopidogrel.jpeg'),
    ];
  }

  /// The current diagnosis: headline condition, explainer + prevention videos,
  /// and the plain-language summary shown on the Diagnosis screen.
  Diagnosis getDiagnosis() => Diagnosis.fromMock();

  /// The full treatment plan: recovery progress, explainer videos, today's
  /// medicine timeline, goals, and upcoming appointments.
  TreatmentPlan getTreatment() => TreatmentPlan.fromMock();
}
