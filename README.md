Crownfield Eye Hospital database — Umer (CPU4:103)
This repository is a reconstructed, runnable teaching demonstration, created
from the Word assignment Muahmmad Umer's Assignment.docx. It is not an
original exported GitHub repository or a verified copy of the student's MySQL
files. All patient records are fictional.
Important before submission
The report contains ERD images and screenshots of some SQL code, but does not
contain a complete .sql source export. To make a full demo, this package:
- Transcribes / reconstructs: the original logical and conceptual diagrams,
  five evidenced table definitions, four SQL SELECT queries, the stored
  procedure and trigger, and the visible medicines, appointments, diagnoses
  and prescription data.
- Adds supporting material: missing group tables and synthetic master data,
  prescription-item dose/frequency entries, follow-up seed values, a new
  four-role access model, a reusable AES demo, and executable negative tests.
- Cannot prove: the added code was part of the original group build,
  that SQL ran successfully in the student's environment, that MySQL roles
  were verified, or that the trigger rejected an invalid date in the report.
Only claim work as personally completed if you actually understand and run it.
If you possess the actual group .sql export, use that original code instead
of this reconstructed substitute wherever possible.
Folder contents
Path	Purpose
01_schema.sql	Schema and synthetic test data (includes reconstructed additions)
02_individual_queries.sql	The six Part C features (queries and calls)
03_procedure_and_trigger.sql	Umer's procedure and insert trigger
04_security.sql	Reconstructed AES demo plus new illustrative MySQL roles
04_access_matrix.md	Added role/permission matrix and limitations
05_ERD/Conceptual_ERD_from_assignment.png	Original image extracted from Word report
05_ERD/Logical_ERD_from_assignment.png	Original image extracted from Word report
05_ERD/*.mmd	Editable Mermaid reconstructions of those diagrams
06_validation_tests.sql	New tests for trigger rejection, ROLLBACK, UPDATE/DELETE


Setup and execution order
1. Install MySQL 8.0+ and open MySQL Workbench using an account that can create
   databases and tables. 04_security.sql also needs CREATE ROLE and GRANT.
2. Open and execute 01_schema.sql to create a separate database called
   crownfield_eye_hospital_umer_demo. Running the schema script again
   drops and recreates demo tables, deleting data inside that demo database.
3. Execute 03_procedure_and_trigger.sql to create the procedure/trigger.
4. Execute 02_individual_queries.sql and capture your own results.
5. Execute 04_security.sql using an account authorised to manage roles.
6. Execute 06_validation_tests.sql for extra reproducible testing.
In MySQL Workbench, open a .sql file, select its whole content, then use the
lightning-bolt Execute button. The SQL uses DELIMITER $$ in stored programs,
which MySQL Workbench understands. Do not simply paste delimiter lines into a
library that sends individual SQL statements over a connector.
Reproducible expected results
- C1: Dr Maya Shah 4 appointments; Dr Leo Grant 2; Dr Priya Nair 2.
- C2: 5 records for appointments 1–5.
- C3: 1 appointment without a prescription: Sofia Bennett, 2026-10-06.
- C4: 4 repeated medicines: Latanoprost, Timolol, Aflibercept,
  and Sodium chloride drops. (Prescription items are illustrative reconstructions.)
- C5: CALL sp_umer_patient_appointments('OP001') returns her two appointments.
- C6: SHOW TRIGGERS shows trg_umer_prescription_date after creation.
- New 06_validation_tests.sql: invalid-date rejection should return 1;
  transaction test should return 0 remaining rows after rollback.
- D1/D2: AES-256-CBC ciphertext is displayed as HEX; the fictional plaintext
  comes back as Fictional training note only within the same session.
What must still be evidenced independently
The uploaded report explicitly says it lacked evidence that the trigger rejected
an invalid date and that four user-role permissions were successfully applied.
Run and document these tests before claiming them as completed. The published
report also identifies incomplete negative-test logging. An assessor may require
complete personal, attributable SQL scripts and screenshots from MySQL.
Diagram source note
PNG diagrams are byte-for-byte extracted from the submitted Word document.
Editable .mmd files reproduce the shown relationships with Mermaid syntax.
They are not the original diagram's editable source file.
Data safety and security
This uses fictional records, not medical advice. Example medicine doses/routes
are placeholders. The encryption key in the script is hard-coded for training
only, and the role model does not implement patient-specific row-level access.
Never reuse these values as production medical records, treatment instructions,
credentials or key-management practices.
