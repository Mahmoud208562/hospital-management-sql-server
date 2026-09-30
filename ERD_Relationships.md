# ERD / Relationship Map

Departments 1 ---- * Doctors
Patients 1 ---- * Appointments
Doctors 1 ---- * Appointments
Patients 1 ---- * MedicalRecords
Doctors 1 ---- * MedicalRecords
Patients 1 ---- * Prescriptions
Doctors 1 ---- * Prescriptions
Prescriptions 1 ---- * PrescriptionDetails
Medicines 1 ---- * PrescriptionDetails
Patients 1 ---- * Admissions
Rooms 1 ---- * Admissions
Patients 1 ---- * LabTests
Doctors 1 ---- * LabTests
Patients 1 ---- * Bills
Bills 1 ---- * Payments

PatientAudit records INSERT / UPDATE / DELETE activity on Patients.
