-- CPU4:103 | Umer | Part C5-C6
-- Transcribed from screenshots C5 and C6 in the submitted report.
-- Run 01_schema.sql FIRST. Requires MySQL Workbench / mysql client DELIMITER.
USE crownfield_eye_hospital_umer_demo;

-- C5: Repeatable search for appointments by patient ID.
DROP PROCEDURE IF EXISTS sp_umer_patient_appointments;
DELIMITER $$
CREATE PROCEDURE sp_umer_patient_appointments(
    IN p_patient_id CHAR(5)
)
BEGIN
    SELECT a.appointment_id, a.appointment_date,
           a.appointment_time, c.full_name AS clinician,
           cl.clinic_name
    FROM appointments AS a
    INNER JOIN clinicians AS c ON c.clinician_id = a.clinician_id
    INNER JOIN clinics AS cl ON cl.clinic_id = a.clinic_id
    WHERE a.patient_id = p_patient_id
    ORDER BY a.appointment_date, a.appointment_time;
END$$
DELIMITER ;

-- C6: A prescription issue date must not precede its appointment date.
DROP TRIGGER IF EXISTS trg_umer_prescription_date;
DELIMITER $$
CREATE TRIGGER trg_umer_prescription_date
BEFORE INSERT ON prescriptions
FOR EACH ROW
BEGIN
    DECLARE v_appointment_date DATE;
    SELECT a.appointment_date INTO v_appointment_date
    FROM appointments AS a
    WHERE a.appointment_id = NEW.appointment_id;

    IF NEW.issued_date < v_appointment_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Prescription date cannot precede appointment';
    END IF;
END$$
DELIMITER ;

-- In the submitted assignment, trigger creation is evidenced, but an invalid
-- date rejection was NOT evidenced. An optional test appears in 06_validation_tests.sql.
