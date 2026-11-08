-- CPU4:103 | Umer | Part D | EXTENDED DEMONSTRATION CODE
-- The report SHOWS one encrypted note and authorised decryption in screenshots
-- D1-D2, but does NOT contain all original encryption setup SQL or proof of
-- 4 roles being applied. This file reconstructs encryption for a demo and adds
-- example MySQL roles; DO NOT claim these roles were verified in the report.
-- Administrative account with CREATE ROLE and GRANT privileges is required.
-- Do not use real patient data, real passwords or production encryption keys.
USE crownfield_eye_hospital_umer_demo;

-- D2 demo: Encrypt one fictional note using AES-256-CBC. Stored IV is required.
CREATE TABLE IF NOT EXISTS patient_private_notes (
    note_id INT PRIMARY KEY,
    patient_id CHAR(5) NOT NULL,
    encryption_iv BINARY(16) NOT NULL,
    encrypted_note VARBINARY(1024) NOT NULL,
    CONSTRAINT fk_private_note_patient FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
);

-- THIS STRING IS PUBLIC DEMO MATERIAL, NOT A SECURE SECRET OR KEY POLICY.
SET SESSION block_encryption_mode = 'aes-256-cbc';
SET @training_key = UNHEX(SHA2('DEMO-ONLY-KEY-REPLACE-NEVER-USE-IN-PRODUCTION', 256));
SET @training_iv = RANDOM_BYTES(16);

INSERT INTO patient_private_notes (note_id,patient_id,encryption_iv,encrypted_note)
VALUES (9001,'OP001',@training_iv,
        AES_ENCRYPT('Fictional training note only',@training_key,@training_iv))
ON DUPLICATE KEY UPDATE
    encryption_iv = VALUES(encryption_iv),
    encrypted_note = VALUES(encrypted_note);

-- D1. The ciphertext is unreadable in a HEX result grid.
SELECT note_id, patient_id, HEX(encrypted_note) AS ciphertext
FROM patient_private_notes
WHERE note_id = 9001;

-- D2. Decrypt the fictional note while the training key is in this session.
SELECT note_id,
       CAST(AES_DECRYPT(encrypted_note,@training_key,encryption_iv)
           AS CHAR(255) CHARACTER SET utf8mb4) AS authorised_decryption
FROM patient_private_notes
WHERE note_id = 9001;

-- Four role EXAMPLES added for assessment brief D1, not evidenced by report.
-- Role privileges are demonstrative. Patient self-service would require
-- additional user authentication and properly enforced row-level restrictions.
CREATE OR REPLACE VIEW public_clinic_directory AS
    SELECT clinic_name FROM clinics;

CREATE ROLE IF NOT EXISTS
    'ceh_admin', 'ceh_doctor', 'ceh_receptionist', 'ceh_patient';

GRANT SELECT, INSERT, UPDATE, DELETE
    ON crownfield_eye_hospital_umer_demo.* TO 'ceh_admin';

GRANT SELECT ON crownfield_eye_hospital_umer_demo.patients TO 'ceh_doctor';
GRANT SELECT ON crownfield_eye_hospital_umer_demo.clinicians TO 'ceh_doctor';
GRANT SELECT ON crownfield_eye_hospital_umer_demo.clinics TO 'ceh_doctor';
GRANT SELECT ON crownfield_eye_hospital_umer_demo.appointments TO 'ceh_doctor';
GRANT SELECT, INSERT, UPDATE ON crownfield_eye_hospital_umer_demo.diagnoses TO 'ceh_doctor';
GRANT SELECT, INSERT, UPDATE ON crownfield_eye_hospital_umer_demo.prescriptions TO 'ceh_doctor';
GRANT SELECT, INSERT, UPDATE ON crownfield_eye_hospital_umer_demo.prescription_items TO 'ceh_doctor';
GRANT SELECT, INSERT, UPDATE ON crownfield_eye_hospital_umer_demo.followup_plans TO 'ceh_doctor';
GRANT SELECT ON crownfield_eye_hospital_umer_demo.medicines TO 'ceh_doctor';

GRANT SELECT ON crownfield_eye_hospital_umer_demo.patients TO 'ceh_receptionist';
GRANT SELECT ON crownfield_eye_hospital_umer_demo.clinicians TO 'ceh_receptionist';
GRANT SELECT ON crownfield_eye_hospital_umer_demo.clinics TO 'ceh_receptionist';
GRANT SELECT, INSERT, UPDATE ON crownfield_eye_hospital_umer_demo.appointments TO 'ceh_receptionist';

-- This view contains no patient details. It does NOT give users access to their
-- individual medical information; implementing that needs separate design.
GRANT SELECT ON crownfield_eye_hospital_umer_demo.public_clinic_directory TO 'ceh_patient';

SHOW GRANTS FOR 'ceh_admin';
SHOW GRANTS FOR 'ceh_doctor';
SHOW GRANTS FOR 'ceh_receptionist';
SHOW GRANTS FOR 'ceh_patient';

-- Sample access matrix is in 04_access_matrix.md.
