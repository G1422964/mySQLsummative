-- CPU4:103 | Umer | demonstration tests
-- SOME TESTS BELOW ARE NEW and are NOT historical evidence of the assignment.
-- Re-run and capture your OWN screenshots of results for assessment.
-- Requires 01_schema.sql followed by 03_procedure_and_trigger.sql.
USE crownfield_eye_hospital_umer_demo;

-- 1. Test: an invalid issue date is rejected by the C6 trigger.
-- A handler catches the trigger's specific SQLSTATE 45000 so this file remains
-- executable as a whole. `invalid_date_rejected` should be 1.
DROP PROCEDURE IF EXISTS sp_test_rejected_date;
DELIMITER $$
CREATE PROCEDURE sp_test_rejected_date()
BEGIN
    DECLARE invalid_date_rejected TINYINT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
        SET invalid_date_rejected = 1;

    START TRANSACTION;
    INSERT INTO prescriptions (prescription_id,appointment_id,issued_date)
    VALUES (9901,1,'2026-10-04'); -- earlier than appointment 1: 2026-10-05

    SELECT invalid_date_rejected AS invalid_date_rejected;
    ROLLBACK;
END$$
DELIMITER ;
CALL sp_test_rejected_date();
SELECT COUNT(*) AS rejected_test_rows_remaining
FROM prescriptions WHERE prescription_id = 9901;

-- 2. Positive transaction and ROLLBACK: based on source C7.
START TRANSACTION;
INSERT INTO prescriptions (prescription_id,appointment_id,issued_date)
VALUES (9902,4,'2026-10-06');
SELECT prescription_id,appointment_id,issued_date
FROM prescriptions WHERE prescription_id = 9902;
ROLLBACK;
SELECT COUNT(*) AS remaining_test_prescriptions
FROM prescriptions WHERE prescription_id = 9902;
-- Expected: 0.

-- 3. Controlled UPDATE: demonstrate then undo (extended from report summary).
START TRANSACTION;
SELECT followup_id,status FROM followup_plans WHERE followup_id=1;
UPDATE followup_plans SET status='Completed' WHERE followup_id=1;
SELECT followup_id,status FROM followup_plans WHERE followup_id=1;
ROLLBACK;
SELECT followup_id,status FROM followup_plans WHERE followup_id=1;

-- 4. Safe DELETE of a temporary unlinked test patient (added example).
START TRANSACTION;
INSERT INTO patients (patient_id,full_name,postcode)
VALUES ('OP999','Temporary Training Patient','TR1 0ZZ');
DELETE FROM patients WHERE patient_id='OP999';
SELECT COUNT(*) AS temporary_patient_rows_remaining
FROM patients WHERE patient_id='OP999';
ROLLBACK;

-- 5. Display table constraints.
SHOW CREATE TABLE appointments;
SHOW CREATE TABLE prescription_items;
SHOW CREATE TABLE prescriptions;
