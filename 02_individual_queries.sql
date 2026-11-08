-- CPU4:103 | Umer | Part C1-C6
-- C1-C4 SQL reconstructed from screenshots C1-C4; C5-C6 call objects in 03.
-- Run 01_schema.sql, then 03_procedure_and_trigger.sql, THEN this file.
USE crownfield_eye_hospital_umer_demo;

-- C1. Which clinicians have at least two appointments?
SELECT c.clinician_id, c.full_name AS clinician,
       COUNT(a.appointment_id) AS total_appointments
FROM clinicians AS c
JOIN appointments AS a ON a.clinician_id = c.clinician_id
GROUP BY c.clinician_id, c.full_name
HAVING COUNT(a.appointment_id) >= 2
ORDER BY total_appointments DESC, c.full_name;
-- Expected in the reconstructed demo: Dr Maya Shah 4, Dr Leo Grant 2, Dr Priya Nair 2.

-- C2. Show appointment details from four related tables (first five original rows).
SELECT a.appointment_id, p.full_name AS patient,
       c.full_name AS clinician, cl.clinic_name,
       a.appointment_date, a.appointment_time
FROM appointments AS a
INNER JOIN patients AS p ON p.patient_id = a.patient_id
INNER JOIN clinicians AS c ON c.clinician_id = a.clinician_id
INNER JOIN clinics AS cl ON cl.clinic_id = a.clinic_id
WHERE a.appointment_id BETWEEN 1 AND 5
ORDER BY a.appointment_id;
-- Expected: five original appointments.

-- C3. Which appointments do not have prescriptions?
SELECT a.appointment_id, p.full_name AS patient,
       a.appointment_date, pr.prescription_id
FROM appointments AS a
INNER JOIN patients AS p ON p.patient_id = a.patient_id
LEFT JOIN prescriptions AS pr ON pr.appointment_id = a.appointment_id
WHERE pr.prescription_id IS NULL
ORDER BY a.appointment_id;
-- Expected: appointment 4, Sofia Bennett, 2026-10-06.

-- C4. Which medicines are present in two or more prescription items?
SELECT m.medicine_id, m.medicine_name
FROM medicines AS m
WHERE m.medicine_id IN (
    SELECT pi.medicine_id
    FROM prescription_items AS pi
    GROUP BY pi.medicine_id
    HAVING COUNT(*) >= 2
)
ORDER BY m.medicine_id;
-- Expected: Latanoprost, Timolol, Aflibercept, Sodium chloride drops.
-- Note: illustrative prescription-item rows were reconstructed to match this output.

-- C5. Execute the stored procedure (created by 03_procedure_and_trigger.sql).
CALL sp_umer_patient_appointments('OP001');

-- C6. Show the prescription-date trigger definition.
SHOW TRIGGERS FROM crownfield_eye_hospital_umer_demo LIKE 'prescriptions';
-- Run 06_validation_tests.sql separately to check negative/rollback behaviour.
