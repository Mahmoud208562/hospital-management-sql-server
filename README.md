# 🏥 Hospital Management Database — SQL Server

A portfolio-ready relational database project built with **Microsoft SQL Server and T-SQL** to simulate the core data operations of a hospital management system.

The project demonstrates database design, relational modeling, constraints, SQL querying, reporting, stored procedures, functions, triggers, indexing, transactions, execution plans, and backup concepts.

## 🎯 Project Objectives

- Design a normalized relational database for hospital operations.
- Model relationships between patients, doctors, departments, appointments, prescriptions, admissions, laboratory tests, billing, and payments.
- Practice professional T-SQL development in SQL Server Management Studio (SSMS).
- Demonstrate reusable database objects such as views, stored procedures, functions, and triggers.
- Practice performance concepts including indexes and execution plans.

## 🛠️ Technologies

- **Database:** Microsoft SQL Server
- **Language:** T-SQL
- **IDE:** SQL Server Management Studio (SSMS)
- **Modeling:** Relational database design / ERD

## 🗂️ Database Schema

The database contains **14 tables**:

| Table | Purpose |
|---|---|
| `Departments` | Hospital departments and specialties |
| `Doctors` | Doctor information and department assignment |
| `Patients` | Patient demographic and contact information |
| `Appointments` | Patient-doctor appointment scheduling |
| `MedicalRecords` | Patient diagnosis and clinical notes |
| `Medicines` | Medicine catalog and pricing |
| `Prescriptions` | Prescriptions issued to patients |
| `PrescriptionDetails` | Medicines included in each prescription |
| `Rooms` | Hospital rooms and room status |
| `Admissions` | Patient admission and discharge information |
| `LabTests` | Laboratory test results and costs |
| `Bills` | Patient billing records |
| `Payments` | Payments made against bills |
| `PatientAudit` | Audit history for patient record changes |

## 🔗 Main Relationships

- One **Department** → Many **Doctors**
- One **Patient** → Many **Appointments**
- One **Doctor** → Many **Appointments**
- One **Patient** → Many **Medical Records**
- One **Patient** → Many **Prescriptions**
- One **Prescription** → Many **Prescription Details**
- One **Medicine** → Many **Prescription Details**
- One **Patient** → Many **Admissions**
- One **Room** → Many **Admissions**
- One **Patient** → Many **Lab Tests**
- One **Patient** → Many **Bills**
- One **Bill** → Many **Payments**

See [`ERD_Relationships.md`](ERD_Relationships.md) for the relationship map.

## ⚙️ SQL Server Features Demonstrated

### Database Design
- Primary Keys
- Foreign Keys
- `CHECK` constraints
- `UNIQUE` constraints
- `DEFAULT` constraints
- Referential integrity
- One-to-many relationships
- Many-to-many modeling through junction tables

### T-SQL Querying
- `SELECT`
- `WHERE`
- `ORDER BY`
- `INNER JOIN`
- `LEFT JOIN`
- `GROUP BY`
- `HAVING`
- Aggregate functions
- Subqueries
- CTEs
- `CASE` expressions
- Reporting queries

### Programmability
- Views
- Stored Procedures
- Scalar User-Defined Function
- Trigger
- Audit table

### Performance & Reliability
- Nonclustered indexes
- Actual Execution Plan practice
- Transactions and `ROLLBACK`
- `TRY...CATCH` error handling
- Full database backup example

## 📊 Included Database Objects

### Views
- `dbo.vw_DoctorDepartment`
- `dbo.vw_AppointmentDetails`
- `dbo.vw_PatientMedicalHistory`
- `dbo.vw_BillingSummary`

### Stored Procedures
- `dbo.GetPatientAppointments`
- `dbo.AddAppointment`
- `dbo.GetPatientBilling`
- `dbo.RecordPayment`

### Function
- `dbo.fn_PatientAge`

### Trigger
- `dbo.trg_Patients_Audit`

## 🚀 How to Run the Project

### 1. Requirements

Install:

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)

### 2. Open the project

1. Open **SSMS**.
2. Connect to your SQL Server instance.
3. Open `HospitalManagementDB.sql`.
4. Execute the script with **F5** or **Execute**.
5. Refresh **Databases** in Object Explorer.
6. Open `HospitalManagementDB`.
7. Explore **Tables**, **Views**, **Programmability**, and **Security**.

### 3. Verify the database

Run:

```sql
USE HospitalManagementDB;
GO

SELECT * FROM dbo.Patients;
SELECT * FROM dbo.Doctors;
SELECT * FROM dbo.Appointments;
```

## ⚠️ Important Note

The setup script is designed for a **training/portfolio environment**. It recreates `HospitalManagementDB` if the database already exists.

Do **not** run the setup script against a production database containing real data.

## 💾 Backup Example

A commented full-backup example is included near the end of the SQL script. The backup path must exist on the machine where the SQL Server service can write the file.

## 📁 Project Structure

```text
Hospital_Management_SQL_Server/
│
├── HospitalManagementDB.sql
├── ERD_Relationships.md
├── SQL_Server_Practice_Checklist.md
└── README.md
```

## 🧠 Skills Demonstrated

`SQL Server` `T-SQL` `SSMS` `Database Design` `Relational Databases` `ERD` `Joins` `CTE` `Subqueries` `Views` `Stored Procedures` `Functions` `Triggers` `Indexes` `Transactions` `Execution Plans` `Backup & Restore`

## 💼 CV Description

**Hospital Management Database — SQL Server**  
Designed and implemented a relational hospital management database using Microsoft SQL Server and T-SQL, including 14 related tables, constraints, complex queries, views, stored procedures, a user-defined function, audit trigger, indexes, transactions, execution-plan analysis, and backup operations.

## 👨‍💻 Author

**Mahmoud Tharwat**  
Computer Science & Information Graduate | Data Analyst | Data Scientist
