-- CPU4:103 | Crownfield Eye Hospital | Umer
-- RECONSTRUCTED DEMONSTRATION from Umer's assignment, NOT the original SQL export.
-- Source: logical ERD (Figure A2), screenshots B1-B9 and original case rows.
-- Missing group-owned structures and missing seed values are completed with
-- NEW, FICTITIOUS training data. See README.md for what is evidenced and new.
-- WARNING: Rerunning this script DELETES the demo tables and their data.
-- It deliberately uses a separate *_umer_demo database to avoid overwriting
-- the group's crownfield_eye_hospital database shown in the screenshots.

CREATE DATABASE IF NOT EXISTS crownfield_eye_hospital_umer_demo
    CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE crownfield_eye_hospital_umer_demo;

DROP TABLE IF EXISTS patient_private_notes;
DROP VIEW IF EXISTS public_clinic_directory;
DROP TABLE IF EXISTS prescription_items;
DROP TABLE IF EXISTS followup_plans;
DROP TABLE IF EXISTS prescriptions;
DROP TABLE IF EXISTS diagnoses;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS medicines;
DROP TABLE IF EXISTS clinicians;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS clinics;
DROP TABLE IF EXISTS specialties;

-- Shared/group tables reconstructed from the assignment's logical ERD.
CREATE TABLE specialties (
    specialty_id INT PRIMARY KEY,
    specialty_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE patients (
    patient_id CHAR(5) PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    postcode VARCHAR(12) NOT NULL
);

CREATE TABLE clinicians (
    clinician_id INT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    specialty_id INT NOT NULL,
    CONSTRAINT fk_clinician_specialty FOREIGN KEY (specialty_id)
        REFERENCES specialties(specialty_id)
);

CREATE TABLE clinics (
    clinic_id INT PRIMARY KEY,
    clinic_name VARCHAR(100) NOT NULL UNIQUE
);

-- Medicines: structure is visible in screenshot B1.
CREATE TABLE medicines (
    medicine_id INT PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE
);

-- Appointments: types, foreign keys, and the two UNIQUE constraints are visible
-- in screenshot B3. The year CHECK comes from its ALTER TABLE statement.
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id CHAR(5) NOT NULL,
    clinician_id INT NOT NULL,
    clinic_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    notes VARCHAR(255),
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    CONSTRAINT fk_appointment_clinician FOREIGN KEY (clinician_id)
        REFERENCES clinicians(clinician_id),
    CONSTRAINT fk_appointment_clinic FOREIGN KEY (clinic_id)
        REFERENCES clinics(clinic_id),
    CONSTRAINT uq_clinician_slot UNIQUE (clinician_id, appointment_date, appointment_time),
    CONSTRAINT uq_clinic_slot UNIQUE (clinic_id, appointment_date, appointment_time)
);
ALTER TABLE appointments ADD CONSTRAINT ck_appointment_year
    CHECK (appointment_date >= '2020-01-01');

-- Diagnoses: structure shown in B5.
CREATE TABLE diagnoses (
    diagnosis_id INT PRIMARY KEY,
    appointment_id INT NOT NULL,
    diagnosis_text VARCHAR(200) NOT NULL,
    CONSTRAINT fk_diagnosis_appointment FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
);

-- Prescriptions: structure shown in B7.
CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY,
    appointment_id INT NOT NULL,
    issued_date DATE NOT NULL,
    CONSTRAINT fk_prescription_appointment FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
);

-- Prescription items: structure shown in B9.
CREATE TABLE prescription_items (
    prescription_id INT NOT NULL,
    medicine_id INT NOT NULL,
    dose VARCHAR(100) NOT NULL,
    route VARCHAR(50) NOT NULL,
    frequency VARCHAR(80) NOT NULL,
    duration_days SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (prescription_id, medicine_id),
    CONSTRAINT ck_duration_positive CHECK (duration_days > 0),
    CONSTRAINT fk_item_prescription FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(prescription_id),
    CONSTRAINT fk_item_medicine FOREIGN KEY (medicine_id)
        REFERENCES medicines(medicine_id)
);

-- Follow-up fields and constraints inferred from Figure A2.
CREATE TABLE followup_plans (
    followup_id INT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    due_date DATE NOT NULL,
    priority ENUM('Routine', 'High', 'Urgent') NOT NULL,
    status ENUM('Planned', 'Scheduled', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Planned',
    CONSTRAINT fk_followup_appointment FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
);

-- Records below: original first five patients/clinicians/clinics and related
-- appointments follow the appendix and screenshots. Extra supporting rows are
-- reconstructed, fictional training rows (NOT copied original group SQL).
INSERT INTO specialties (specialty_id, specialty_name) VALUES
(1,'Glaucoma'), (2,'Retina'), (3,'Cornea'), (4,'Paediatric ophthalmology'),
(5,'Neuro-ophthalmology'), (6,'Oculoplastics'), (7,'Vitreoretinal surgery'),
(8,'Uveitis'), (9,'Cataract'), (10,'Ocular oncology');

INSERT INTO clinicians (clinician_id, full_name, specialty_id) VALUES
(1,'Dr Maya Shah',1), (2,'Dr Leo Grant',2), (3,'Dr Priya Nair',3),
(4,'Training Clinician 04',4), (5,'Training Clinician 05',5),
(6,'Training Clinician 06',6), (7,'Training Clinician 07',7),
(8,'Training Clinician 08',8), (9,'Training Clinician 09',9),
(10,'Training Clinician 10',10), (11,'Training Clinician 11',4),
(12,'Training Clinician 12',10);

INSERT INTO clinics (clinic_id, clinic_name) VALUES
(1,'City Road'), (2,'Bedford'), (3,'Croydon'),
(4,'Training Clinic 04'), (5,'Training Clinic 05'),
(6,'Training Clinic 06'), (7,'Training Clinic 07'),
(8,'Training Clinic 08'), (9,'Training Clinic 09'),
(10,'Training Clinic 10'), (11,'Training Clinic 11'),
(12,'Training Clinic 12');

INSERT INTO patients (patient_id, full_name, postcode) VALUES
('OP001','Amina Yusuf','NE1 4AB'), ('OP002','Daniel Reed','N16 7QP'),
('OP003','Sofia Bennett','E8 2LD'), ('OP004','Michael Okoro','SE6 3RT'),
('OP005','Training Patient 005','TR1 0AA'),
('OP006','Training Patient 006','TR1 0AB'),
('OP007','Training Patient 007','TR1 0AC'),
('OP008','Training Patient 008','TR1 0AD'),
('OP009','Training Patient 009','TR1 0AE'),
('OP010','Training Patient 010','TR1 0AF'),
('OP011','Training Patient 011','TR1 0AG'),
('OP012','Training Patient 012','TR1 0AH'),
('OP013','Training Patient 013','TR1 0AJ'),
('OP014','Training Patient 014','TR1 0AK'),
('OP015','Training Patient 015','TR1 0AL'),
('OP016','Training Patient 016','TR1 0AM');

-- All thirteen names reproduced from Medicines screenshot B2.
INSERT INTO medicines (medicine_id, medicine_name) VALUES
(1,'Latanoprost'), (2,'Timolol'), (3,'Aflibercept'),
(4,'Sodium chloride drops'), (5,'Dorzolamide'), (6,'Brimonidine'),
(7,'Artificial tears'), (8,'Prednisolone acetate'), (9,'Ofloxacin'),
(10,'Cyclopentolate'), (11,'Ketorolac drops'),
(12,'Hypromellose drops'), (13,'Tropicamide');

-- Appointments B4 (original five + rows displayed in the screenshot).
INSERT INTO appointments
(appointment_id, patient_id, clinician_id, clinic_id, appointment_date, appointment_time, notes)
VALUES
(1,'OP001',1,1,'2026-10-05','09:00:00','Review IOP'),
(2,'OP002',2,1,'2026-10-05','09:30:00','OCT before review'),
(3,'OP001',1,2,'2026-11-16','10:15:00','Visual field test'),
(4,'OP003',1,1,'2026-10-06','11:00:00','Monitor'),
(5,'OP004',3,3,'2026-10-07','14:00:00','Corneal topography'),
(6,'OP005',5,6,'2026-11-07','14:00:00','Synthetic scheduled review'),
(7,'OP006',6,7,'2026-11-08','15:00:00','Synthetic scheduled review'),
(8,'OP007',7,8,'2026-11-09','08:00:00','Synthetic scheduled review'),
(9,'OP008',8,9,'2026-11-10','09:00:00','Synthetic scheduled review'),
(10,'OP009',9,10,'2026-11-11','10:00:00','Synthetic scheduled review'),
(11,'OP010',10,1,'2026-11-12','11:00:00','Synthetic scheduled review'),
(12,'OP011',1,2,'2026-11-13','12:00:00','Synthetic scheduled review'),
(13,'OP012',2,3,'2026-11-14','13:00:00','Synthetic scheduled review'),
(14,'OP013',3,4,'2026-11-15','14:00:00','Synthetic scheduled review'),
(15,'OP014',4,5,'2026-11-16','15:00:00','Synthetic scheduled review'),
(16,'OP015',11,11,'2026-11-17','09:30:00','Orthoptics assessment'),
(17,'OP016',12,12,'2026-11-18','10:30:00','Ocular oncology assessment');

-- All 17 diagnoses visible in screenshot B6.
INSERT INTO diagnoses (diagnosis_id, appointment_id, diagnosis_text) VALUES
(1,1,'Ocular hypertension'), (2,2,'Diabetic macular oedema'),
(3,3,'Ocular hypertension'), (4,4,'Glaucoma suspect'),
(5,5,'Keratoconus'), (6,6,'Dry eye syndrome'),
(7,7,'Cataract'), (8,8,'Conjunctivitis'),
(9,9,'Uveitis'), (10,10,'Retinal tear'),
(11,11,'Blepharitis'), (12,12,'Myopia'),
(13,13,'Macular degeneration'), (14,14,'Corneal abrasion'),
(15,15,'Raised intraocular pressure'),
(16,16,'Strabismus'), (17,17,'Choroidal lesion');

-- Prescription IDs, appointment IDs and dates are shown in B8.
-- Appointment 4 deliberately has no prescription: original C3 LEFT JOIN.
INSERT INTO prescriptions (prescription_id, appointment_id, issued_date) VALUES
(1,1,'2026-10-05'), (2,2,'2026-10-05'),
(3,3,'2026-11-16'), (4,5,'2026-10-07'),
(5,6,'2026-11-07'), (6,7,'2026-11-08'),
(7,8,'2026-11-09'), (8,9,'2026-11-10'),
(9,10,'2026-11-11'), (10,11,'2026-11-12'),
(11,12,'2026-11-13'), (12,13,'2026-11-14'),
(13,14,'2026-11-15'), (14,15,'2026-11-16'),
(15,16,'2026-11-17'), (16,17,'2026-11-18');

-- Missing from the screenshots: the actual prescription_items INSERT script.
-- The following NEW illustrative prescription items are designed to match the
-- source C4's four repeatedly-used medicines; they are not original records.
INSERT INTO prescription_items
(prescription_id, medicine_id, dose, route, frequency, duration_days)
VALUES
(1,1,'1 drop','Ophthalmic','Once daily',30),
(1,2,'1 drop','Ophthalmic','Twice daily',30),
(2,3,'Training dose','Intravitreal','As directed',30),
(3,1,'1 drop','Ophthalmic','Once daily',30),
(4,4,'1 drop','Ophthalmic','As directed',14),
(5,5,'1 drop','Ophthalmic','As directed',14),
(6,6,'1 drop','Ophthalmic','As directed',14),
(7,2,'1 drop','Ophthalmic','Twice daily',30),
(8,3,'Training dose','Intravitreal','As directed',30),
(9,4,'1 drop','Ophthalmic','As directed',14),
(10,7,'1 drop','Ophthalmic','As directed',14),
(11,8,'1 drop','Ophthalmic','As directed',14),
(12,9,'1 drop','Ophthalmic','As directed',14),
(13,10,'1 drop','Ophthalmic','As directed',14),
(14,11,'1 drop','Ophthalmic','As directed',14),
(15,12,'1 drop','Ophthalmic','As directed',14),
(16,13,'1 drop','Ophthalmic','As directed',14);

-- Follow-up plan data not supplied as a complete SQL INSERT screenshot.
-- First five follow-up intervals from case data; subsequent rows illustrative.
INSERT INTO followup_plans (followup_id, appointment_id, due_date, priority, status) VALUES
(1,1,'2026-11-16','High','Planned'),
(2,2,'2026-11-02','Urgent','Planned'),
(3,3,'2027-02-08','Routine','Planned'),
(4,4,'2027-04-06','Routine','Planned'),
(5,5,'2026-12-02','Routine','Planned'),
(6,6,'2026-12-05','Routine','Scheduled'),
(7,7,'2026-12-06','Routine','Scheduled'),
(8,8,'2026-12-07','Routine','Planned'),
(9,9,'2026-12-08','High','Planned'),
(10,10,'2026-12-09','Routine','Planned'),
(11,11,'2026-12-10','Routine','Planned'),
(12,12,'2026-12-11','Routine','Planned');

-- Evidence helpers: row counts and parent-child integrity.
SELECT 'patients' AS entity, COUNT(*) AS record_count FROM patients
UNION ALL SELECT 'clinicians',COUNT(*) FROM clinicians
UNION ALL SELECT 'clinics',COUNT(*) FROM clinics
UNION ALL SELECT 'medicines',COUNT(*) FROM medicines
UNION ALL SELECT 'appointments',COUNT(*) FROM appointments
UNION ALL SELECT 'diagnoses',COUNT(*) FROM diagnoses
UNION ALL SELECT 'prescriptions',COUNT(*) FROM prescriptions
UNION ALL SELECT 'prescription_items',COUNT(*) FROM prescription_items
UNION ALL SELECT 'followup_plans',COUNT(*) FROM followup_plans;
