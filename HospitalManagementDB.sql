/*
============================================================
Hospital Management Database - SQL Server
============================================================
Purpose:
A complete portfolio/training database for SQL Server Engineer
practice: database design, constraints, relationships, T-SQL,
JOINs, aggregation, CTEs, views, procedures, functions,
triggers, transactions, indexes and reporting queries.

Run this script in SQL Server Management Studio (SSMS).
It creates/recreates HospitalManagementDB.

WARNING:
This script drops the database if it already exists.
Do NOT run against a real hospital/production database.
============================================================
*/

USE master;
GO

IF DB_ID(N'HospitalManagementDB') IS NOT NULL
BEGIN
    ALTER DATABASE HospitalManagementDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HospitalManagementDB;
END;
GO

CREATE DATABASE HospitalManagementDB;
GO

USE HospitalManagementDB;
GO

/* =========================================================
   1. TABLES
   ========================================================= */

CREATE TABLE Departments
(
    DepartmentID INT IDENTITY(1,1) CONSTRAINT PK_Departments PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL CONSTRAINT UQ_Departments_Name UNIQUE,
    Location VARCHAR(100) NULL,
    Phone VARCHAR(20) NULL
);
GO

CREATE TABLE Doctors
(
    DoctorID INT IDENTITY(1,1) CONSTRAINT PK_Doctors PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Specialization VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL CONSTRAINT UQ_Doctors_Email UNIQUE,
    HireDate DATE NOT NULL,
    DepartmentID INT NOT NULL,
    CONSTRAINT FK_Doctors_Departments
        FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
GO

CREATE TABLE Patients
(
    PatientID INT IDENTITY(1,1) CONSTRAINT PK_Patients PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Gender CHAR(1) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL,
    Address VARCHAR(250) NULL,
    BloodType VARCHAR(5) NULL,
    EmergencyContact VARCHAR(100) NULL,
    EmergencyPhone VARCHAR(20) NULL,
    RegistrationDate DATETIME2 NOT NULL CONSTRAINT DF_Patients_RegistrationDate DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Patients_Gender CHECK (Gender IN ('M','F')),
    CONSTRAINT CK_Patients_BloodType CHECK
        (BloodType IS NULL OR BloodType IN ('A+','A-','B+','B-','AB+','AB-','O+','O-'))
);
GO

CREATE TABLE Appointments
(
    AppointmentID INT IDENTITY(1,1) CONSTRAINT PK_Appointments PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME2 NOT NULL,
    Reason VARCHAR(500) NULL,
    Status VARCHAR(20) NOT NULL CONSTRAINT DF_Appointments_Status DEFAULT 'Scheduled',
    CONSTRAINT CK_Appointments_Status
        CHECK (Status IN ('Scheduled','Completed','Cancelled','No Show')),
    CONSTRAINT FK_Appointments_Patients
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_Appointments_Doctors
        FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);
GO

CREATE TABLE MedicalRecords
(
    RecordID INT IDENTITY(1,1) CONSTRAINT PK_MedicalRecords PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    Diagnosis VARCHAR(500) NOT NULL,
    Symptoms VARCHAR(1000) NULL,
    Treatment VARCHAR(1000) NULL,
    RecordDate DATETIME2 NOT NULL CONSTRAINT DF_MedicalRecords_RecordDate DEFAULT SYSDATETIME(),
    CONSTRAINT FK_MedicalRecords_Patients
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_MedicalRecords_Doctors
        FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);
GO

CREATE TABLE Medicines
(
    MedicineID INT IDENTITY(1,1) CONSTRAINT PK_Medicines PRIMARY KEY,
    MedicineName VARCHAR(150) NOT NULL CONSTRAINT UQ_Medicines_Name UNIQUE,
    Description VARCHAR(500) NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL CONSTRAINT DF_Medicines_Stock DEFAULT 0,
    CONSTRAINT CK_Medicines_Price CHECK (UnitPrice >= 0),
    CONSTRAINT CK_Medicines_Stock CHECK (StockQuantity >= 0)
);
GO

CREATE TABLE Prescriptions
(
    PrescriptionID INT IDENTITY(1,1) CONSTRAINT PK_Prescriptions PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    PrescriptionDate DATETIME2 NOT NULL CONSTRAINT DF_Prescriptions_Date DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Prescriptions_Patients
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_Prescriptions_Doctors
        FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);
GO

CREATE TABLE PrescriptionDetails
(
    PrescriptionDetailID INT IDENTITY(1,1) CONSTRAINT PK_PrescriptionDetails PRIMARY KEY,
    PrescriptionID INT NOT NULL,
    MedicineID INT NOT NULL,
    Dosage VARCHAR(100) NOT NULL,
    Frequency VARCHAR(100) NULL,
    Duration VARCHAR(100) NULL,
    Quantity INT NOT NULL CONSTRAINT DF_PrescriptionDetails_Quantity DEFAULT 1,
    CONSTRAINT CK_PrescriptionDetails_Quantity CHECK (Quantity > 0),
    CONSTRAINT FK_PrescriptionDetails_Prescriptions
        FOREIGN KEY (PrescriptionID) REFERENCES Prescriptions(PrescriptionID),
    CONSTRAINT FK_PrescriptionDetails_Medicines
        FOREIGN KEY (MedicineID) REFERENCES Medicines(MedicineID),
    CONSTRAINT UQ_PrescriptionDetails UNIQUE (PrescriptionID, MedicineID)
);
GO

CREATE TABLE Rooms
(
    RoomID INT IDENTITY(1,1) CONSTRAINT PK_Rooms PRIMARY KEY,
    RoomNumber VARCHAR(20) NOT NULL CONSTRAINT UQ_Rooms_Number UNIQUE,
    RoomType VARCHAR(30) NOT NULL,
    DailyRate DECIMAL(10,2) NOT NULL,
    IsAvailable BIT NOT NULL CONSTRAINT DF_Rooms_Available DEFAULT 1,
    CONSTRAINT CK_Rooms_Type CHECK (RoomType IN ('General','Private','ICU')),
    CONSTRAINT CK_Rooms_Rate CHECK (DailyRate >= 0)
);
GO

CREATE TABLE Admissions
(
    AdmissionID INT IDENTITY(1,1) CONSTRAINT PK_Admissions PRIMARY KEY,
    PatientID INT NOT NULL,
    RoomID INT NOT NULL,
    AdmissionDate DATETIME2 NOT NULL CONSTRAINT DF_Admissions_AdmissionDate DEFAULT SYSDATETIME(),
    DischargeDate DATETIME2 NULL,
    Diagnosis VARCHAR(500) NULL,
    CONSTRAINT CK_Admissions_Dates
        CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate),
    CONSTRAINT FK_Admissions_Patients
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_Admissions_Rooms
        FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);
GO

CREATE TABLE LabTests
(
    TestID INT IDENTITY(1,1) CONSTRAINT PK_LabTests PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    TestName VARCHAR(150) NOT NULL,
    TestDate DATETIME2 NOT NULL CONSTRAINT DF_LabTests_TestDate DEFAULT SYSDATETIME(),
    Result VARCHAR(1000) NULL,
    Cost DECIMAL(10,2) NOT NULL,
    CONSTRAINT CK_LabTests_Cost CHECK (Cost >= 0),
    CONSTRAINT FK_LabTests_Patients
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_LabTests_Doctors
        FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);
GO

CREATE TABLE Bills
(
    BillID INT IDENTITY(1,1) CONSTRAINT PK_Bills PRIMARY KEY,
    PatientID INT NOT NULL,
    BillDate DATETIME2 NOT NULL CONSTRAINT DF_Bills_Date DEFAULT SYSDATETIME(),
    TotalAmount DECIMAL(12,2) NOT NULL,
    Status VARCHAR(20) NOT NULL CONSTRAINT DF_Bills_Status DEFAULT 'Unpaid',
    CONSTRAINT CK_Bills_Amount CHECK (TotalAmount >= 0),
    CONSTRAINT CK_Bills_Status CHECK (Status IN ('Paid','Unpaid','Partial')),
    CONSTRAINT FK_Bills_Patients
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);
GO

CREATE TABLE Payments
(
    PaymentID INT IDENTITY(1,1) CONSTRAINT PK_Payments PRIMARY KEY,
    BillID INT NOT NULL,
    PaymentDate DATETIME2 NOT NULL CONSTRAINT DF_Payments_Date DEFAULT SYSDATETIME(),
    Amount DECIMAL(12,2) NOT NULL,
    PaymentMethod VARCHAR(30) NOT NULL,
    CONSTRAINT CK_Payments_Amount CHECK (Amount > 0),
    CONSTRAINT CK_Payments_Method
        CHECK (PaymentMethod IN ('Cash','Credit Card','Insurance','Bank Transfer')),
    CONSTRAINT FK_Payments_Bills
        FOREIGN KEY (BillID) REFERENCES Bills(BillID)
);
GO

CREATE TABLE PatientAudit
(
    AuditID INT IDENTITY(1,1) CONSTRAINT PK_PatientAudit PRIMARY KEY,
    PatientID INT NULL,
    ActionType VARCHAR(20) NOT NULL,
    ActionDate DATETIME2 NOT NULL CONSTRAINT DF_PatientAudit_Date DEFAULT SYSDATETIME(),
    ChangedBy SYSNAME NOT NULL CONSTRAINT DF_PatientAudit_User DEFAULT SUSER_SNAME()
);
GO

/* =========================================================
   2. SAMPLE DATA
   ========================================================= */

INSERT INTO Departments (DepartmentName, Location, Phone)
VALUES
('Cardiology','Building A - Floor 2','01010000001'),
('Neurology','Building A - Floor 3','01010000002'),
('Pediatrics','Building B - Floor 1','01010000003'),
('Emergency','Building A - Ground Floor','01010000004'),
('Orthopedics','Building B - Floor 2','01010000005');
GO

INSERT INTO Doctors
(FirstName, LastName, Specialization, Phone, Email, HireDate, DepartmentID)
VALUES
('Ahmed','Ali','Cardiologist','01110000001','ahmed.ali@hospital.local','2021-01-10',1),
('Mohamed','Hassan','Neurologist','01110000002','mohamed.hassan@hospital.local','2020-06-15',2),
('Sara','Mahmoud','Pediatrician','01110000003','sara.mahmoud@hospital.local','2022-03-20',3),
('Omar','Khaled','Emergency Doctor','01110000004','omar.khaled@hospital.local','2019-09-01',4),
('Mona','Samir','Orthopedic','01110000005','mona.samir@hospital.local','2023-02-12',5),
('Youssef','Adel','Cardiologist','01110000006','youssef.adel@hospital.local','2022-08-01',1);
GO

INSERT INTO Patients
(FirstName, LastName, Gender, DateOfBirth, Phone, Email, Address, BloodType, EmergencyContact, EmergencyPhone)
VALUES
('Mahmoud','Ali','M','1999-05-12','01000000001','mahmoud@gmail.com','Cairo','O+','Ali Mahmoud','01090000001'),
('Ahmed','Hassan','M','1985-08-20','01000000002','ahmed@gmail.com','Giza','A+','Hassan Ahmed','01090000002'),
('Mariam','Mohamed','F','2015-04-10','01000000003','mariam@gmail.com','Cairo','B+','Mohamed Mariam','01090000003'),
('Sara','Ali','F','1992-11-05','01000000004','sara@gmail.com','Qalyubia','AB+','Ali Sara','01090000004'),
('Omar','Ibrahim','M','1978-01-15','01000000005','omar@gmail.com','Giza','O+','Ibrahim Omar','01090000005'),
('Nour','Khaled','F','2001-07-22','01000000006','nour@gmail.com','Cairo','A-','Khaled Nour','01090000006'),
('Adam','Samir','M','2010-03-18','01000000007','adam@gmail.com','Qalyubia','B-','Samir Adam','01090000007'),
('Hana','Mostafa','F','1969-12-30','01000000008','hana@gmail.com','Giza','O-','Mostafa Hana','01090000008');
GO

INSERT INTO Appointments
(PatientID, DoctorID, AppointmentDate, Reason, Status)
VALUES
(1,1,'2026-10-01 09:00','Chest pain follow-up','Scheduled'),
(2,2,'2026-10-01 10:00','Headache assessment','Scheduled'),
(3,3,'2026-10-01 11:00','Routine pediatric visit','Scheduled'),
(4,1,'2026-09-28 12:00','Blood pressure check','Completed'),
(5,5,'2026-09-29 14:00','Knee pain','Completed'),
(1,6,'2026-09-30 13:00','Cardiology consultation','No Show'),
(6,4,'2026-09-27 16:00','Emergency assessment','Completed'),
(8,1,'2026-10-02 09:30','Heart checkup','Scheduled');
GO

INSERT INTO MedicalRecords
(PatientID, DoctorID, Diagnosis, Symptoms, Treatment, RecordDate)
VALUES
(1,1,'Hypertension','Headache and elevated blood pressure','Lifestyle changes and follow-up','2026-09-20 09:15'),
(2,2,'Migraine','Recurring headache','Medication and neurological follow-up','2026-09-21 10:20'),
(3,3,'Viral infection','Fever and sore throat','Rest, fluids and symptomatic treatment','2026-09-22 11:30'),
(4,1,'Mild hypertension','High blood pressure','Monitoring and lifestyle changes','2026-09-28 12:30'),
(5,5,'Knee osteoarthritis','Knee pain','Physiotherapy and pain management','2026-09-29 14:30'),
(6,4,'Minor injury','Arm pain','Wound care and observation','2026-09-27 16:30');
GO

INSERT INTO Medicines (MedicineName, Description, UnitPrice, StockQuantity)
VALUES
('Paracetamol 500mg','Pain and fever relief',25.00,200),
('Amoxicillin 500mg','Antibiotic',60.00,150),
('Ibuprofen 400mg','Pain and inflammation relief',35.00,120),
('Omeprazole 20mg','Acid reduction',45.00,100),
('Amlodipine 5mg','Blood pressure medication',30.00,180),
('Vitamin D3','Vitamin supplement',80.00,90),
('Azithromycin 500mg','Antibiotic',75.00,70),
('Diclofenac 50mg','Anti-inflammatory medicine',40.00,110);
GO

INSERT INTO Prescriptions (PatientID, DoctorID, PrescriptionDate)
VALUES
(1,1,'2026-09-20 09:20'),
(2,2,'2026-09-21 10:25'),
(3,3,'2026-09-22 11:35'),
(5,5,'2026-09-29 14:40');
GO

INSERT INTO PrescriptionDetails
(PrescriptionID, MedicineID, Dosage, Frequency, Duration, Quantity)
VALUES
(1,5,'5 mg','Once daily','30 days',30),
(1,1,'500 mg','Every 8 hours','5 days',15),
(2,1,'500 mg','As needed','5 days',10),
(2,3,'400 mg','Twice daily','5 days',10),
(3,1,'500 mg','Every 8 hours','3 days',9),
(3,7,'500 mg','Once daily','3 days',3),
(4,8,'50 mg','Twice daily','7 days',14);
GO

INSERT INTO Rooms (RoomNumber, RoomType, DailyRate, IsAvailable)
VALUES
('G-101','General',500,1),
('G-102','General',500,0),
('P-201','Private',1200,1),
('P-202','Private',1200,0),
('ICU-01','ICU',3000,0),
('ICU-02','ICU',3000,1);
GO

INSERT INTO Admissions
(PatientID, RoomID, AdmissionDate, DischargeDate, Diagnosis)
VALUES
(2,2,'2026-09-25 08:00','2026-09-27 14:00','Neurological observation'),
(5,4,'2026-09-29 09:00',NULL,'Knee surgery observation'),
(6,5,'2026-09-27 16:30','2026-09-28 12:00','Emergency observation');
GO

INSERT INTO LabTests
(PatientID, DoctorID, TestName, TestDate, Result, Cost)
VALUES
(1,1,'CBC','2026-09-20 08:30','Normal','250.00'),
(2,2,'MRI Brain','2026-09-21 09:00','No acute abnormality','2500.00'),
(4,1,'Blood Pressure Profile','2026-09-28 11:00','Elevated','150.00'),
(5,5,'Knee X-Ray','2026-09-29 13:30','Degenerative changes','500.00'),
(6,4,'X-Ray Arm','2026-09-27 17:00','No fracture','400.00');
GO

INSERT INTO Bills (PatientID, BillDate, TotalAmount, Status)
VALUES
(1,'2026-09-20',1250,'Partial'),
(2,'2026-09-21',3000,'Paid'),
(3,'2026-09-22',350,'Paid'),
(4,'2026-09-28',500,'Unpaid'),
(5,'2026-09-29',2200,'Partial'),
(6,'2026-09-27',900,'Paid');
GO

INSERT INTO Payments (BillID, PaymentDate, Amount, PaymentMethod)
VALUES
(1,'2026-09-20',500,'Cash'),
(2,'2026-09-21',3000,'Credit Card'),
(3,'2026-09-22',350,'Cash'),
(5,'2026-09-29',1000,'Insurance'),
(6,'2026-09-27',900,'Cash');
GO

/* =========================================================
   3. INDEXES
   ========================================================= */

CREATE INDEX IX_Doctors_DepartmentID
ON Doctors(DepartmentID);
GO

CREATE INDEX IX_Appointments_PatientID
ON Appointments(PatientID);
GO

CREATE INDEX IX_Appointments_DoctorID
ON Appointments(DoctorID);
GO

CREATE INDEX IX_Appointments_AppointmentDate
ON Appointments(AppointmentDate);
GO

CREATE INDEX IX_MedicalRecords_PatientID
ON MedicalRecords(PatientID);
GO

CREATE INDEX IX_LabTests_PatientID
ON LabTests(PatientID);
GO

CREATE INDEX IX_Bills_PatientID
ON Bills(PatientID);
GO

CREATE INDEX IX_Payments_BillID
ON Payments(BillID);
GO

/* =========================================================
   4. VIEWS
   ========================================================= */

CREATE VIEW dbo.vw_DoctorDepartment
AS
SELECT
    d.DoctorID,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    d.Specialization,
    dep.DepartmentName,
    d.Phone,
    d.Email,
    d.HireDate
FROM Doctors d
INNER JOIN Departments dep
    ON d.DepartmentID = dep.DepartmentID;
GO

CREATE VIEW dbo.vw_AppointmentDetails
AS
SELECT
    a.AppointmentID,
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    d.DoctorID,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    d.Specialization,
    dep.DepartmentName,
    a.AppointmentDate,
    a.Reason,
    a.Status
FROM Appointments a
INNER JOIN Patients p ON a.PatientID = p.PatientID
INNER JOIN Doctors d ON a.DoctorID = d.DoctorID
INNER JOIN Departments dep ON d.DepartmentID = dep.DepartmentID;
GO

CREATE VIEW dbo.vw_PatientMedicalHistory
AS
SELECT
    mr.RecordID,
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    d.Specialization,
    mr.Diagnosis,
    mr.Symptoms,
    mr.Treatment,
    mr.RecordDate
FROM MedicalRecords mr
INNER JOIN Patients p ON mr.PatientID = p.PatientID
INNER JOIN Doctors d ON mr.DoctorID = d.DoctorID;
GO

CREATE VIEW dbo.vw_BillingSummary
AS
SELECT
    b.BillID,
    b.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    b.BillDate,
    b.TotalAmount,
    ISNULL(SUM(pay.Amount),0) AS PaidAmount,
    b.TotalAmount - ISNULL(SUM(pay.Amount),0) AS RemainingAmount,
    b.Status
FROM Bills b
INNER JOIN Patients p ON b.PatientID = p.PatientID
LEFT JOIN Payments pay ON b.BillID = pay.BillID
GROUP BY
    b.BillID, b.PatientID, p.FirstName, p.LastName,
    b.BillDate, b.TotalAmount, b.Status;
GO

/* =========================================================
   5. FUNCTION
   ========================================================= */

CREATE FUNCTION dbo.fn_PatientAge (@DateOfBirth DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;

    SET @Age = DATEDIFF(YEAR, @DateOfBirth, CAST(GETDATE() AS DATE))
             - CASE
                 WHEN DATEADD(YEAR,
                              DATEDIFF(YEAR, @DateOfBirth, CAST(GETDATE() AS DATE)),
                              @DateOfBirth) > CAST(GETDATE() AS DATE)
                 THEN 1 ELSE 0
               END;

    RETURN @Age;
END;
GO

/* =========================================================
   6. STORED PROCEDURES
   ========================================================= */

CREATE PROCEDURE dbo.GetPatientAppointments
    @PatientID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AppointmentID,
        PatientID,
        DoctorName,
        Specialization,
        DepartmentName,
        AppointmentDate,
        Reason,
        Status
    FROM dbo.vw_AppointmentDetails
    WHERE PatientID = @PatientID
    ORDER BY AppointmentDate DESC;
END;
GO

CREATE PROCEDURE dbo.AddAppointment
    @PatientID INT,
    @DoctorID INT,
    @AppointmentDate DATETIME2,
    @Reason VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Patients WHERE PatientID = @PatientID)
        THROW 50001, 'Patient does not exist.', 1;

    IF NOT EXISTS (SELECT 1 FROM Doctors WHERE DoctorID = @DoctorID)
        THROW 50002, 'Doctor does not exist.', 1;

    INSERT INTO Appointments
    (
        PatientID,
        DoctorID,
        AppointmentDate,
        Reason,
        Status
    )
    VALUES
    (
        @PatientID,
        @DoctorID,
        @AppointmentDate,
        @Reason,
        'Scheduled'
    );

    SELECT SCOPE_IDENTITY() AS NewAppointmentID;
END;
GO

CREATE PROCEDURE dbo.GetPatientBilling
    @PatientID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_BillingSummary
    WHERE PatientID = @PatientID
    ORDER BY BillDate DESC;
END;
GO

CREATE PROCEDURE dbo.RecordPayment
    @BillID INT,
    @Amount DECIMAL(12,2),
    @PaymentMethod VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Bills WHERE BillID = @BillID)
            THROW 50003, 'Bill does not exist.', 1;

        IF @Amount <= 0
            THROW 50004, 'Payment amount must be greater than zero.', 1;

        INSERT INTO Payments (BillID, Amount, PaymentMethod)
        VALUES (@BillID, @Amount, @PaymentMethod);

        DECLARE @Total DECIMAL(12,2);
        DECLARE @Paid DECIMAL(12,2);

        SELECT @Total = TotalAmount
        FROM Bills
        WHERE BillID = @BillID;

        SELECT @Paid = ISNULL(SUM(Amount),0)
        FROM Payments
        WHERE BillID = @BillID;

        UPDATE Bills
        SET Status =
            CASE
                WHEN @Paid >= @Total THEN 'Paid'
                WHEN @Paid > 0 THEN 'Partial'
                ELSE 'Unpaid'
            END
        WHERE BillID = @BillID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   7. TRIGGERS
   ========================================================= */

CREATE TRIGGER dbo.trg_Patients_Audit
ON dbo.Patients
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PatientAudit (PatientID, ActionType)
    SELECT PatientID, 'INSERT'
    FROM inserted
    WHERE NOT EXISTS
    (
        SELECT 1 FROM deleted WHERE deleted.PatientID = inserted.PatientID
    );

    INSERT INTO PatientAudit (PatientID, ActionType)
    SELECT PatientID, 'UPDATE'
    FROM inserted
    WHERE EXISTS
    (
        SELECT 1 FROM deleted WHERE deleted.PatientID = inserted.PatientID
    );

    INSERT INTO PatientAudit (PatientID, ActionType)
    SELECT PatientID, 'DELETE'
    FROM deleted
    WHERE NOT EXISTS
    (
        SELECT 1 FROM inserted WHERE inserted.PatientID = deleted.PatientID
    );
END;
GO

/* =========================================================
   8. REPORTING / PRACTICE QUERIES
   ========================================================= */

-- Q01: All patients
SELECT * FROM Patients;
GO

-- Q02: Doctors with departments
SELECT * FROM dbo.vw_DoctorDepartment
ORDER BY DepartmentName, DoctorName;
GO

-- Q03: Appointment details
SELECT * FROM dbo.vw_AppointmentDetails
ORDER BY AppointmentDate;
GO

-- Q04: Number of doctors per department
SELECT
    dep.DepartmentName,
    COUNT(d.DoctorID) AS NumberOfDoctors
FROM Departments dep
LEFT JOIN Doctors d ON dep.DepartmentID = d.DepartmentID
GROUP BY dep.DepartmentName
ORDER BY NumberOfDoctors DESC;
GO

-- Q05: Number of appointments per doctor
SELECT
    d.DoctorID,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    COUNT(a.AppointmentID) AS AppointmentCount
FROM Doctors d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.FirstName, d.LastName
ORDER BY AppointmentCount DESC;
GO

-- Q06: Patients with more than one appointment
SELECT
    PatientID,
    COUNT(*) AS AppointmentCount
FROM Appointments
GROUP BY PatientID
HAVING COUNT(*) > 1;
GO

-- Q07: Unpaid/partial bills
SELECT *
FROM dbo.vw_BillingSummary
WHERE RemainingAmount > 0
ORDER BY RemainingAmount DESC;
GO

-- Q08: Total revenue
SELECT SUM(Amount) AS TotalRevenue
FROM Payments;
GO

-- Q09: Revenue by payment method
SELECT
    PaymentMethod,
    SUM(Amount) AS Revenue
FROM Payments
GROUP BY PaymentMethod
ORDER BY Revenue DESC;
GO

-- Q10: Available rooms
SELECT *
FROM Rooms
WHERE IsAvailable = 1;
GO

-- Q11: Current admissions
SELECT
    a.AdmissionID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    r.RoomNumber,
    r.RoomType,
    a.AdmissionDate,
    a.Diagnosis
FROM Admissions a
INNER JOIN Patients p ON a.PatientID = p.PatientID
INNER JOIN Rooms r ON a.RoomID = r.RoomID
WHERE a.DischargeDate IS NULL;
GO

-- Q12: Patient age
SELECT
    PatientID,
    FirstName + ' ' + LastName AS PatientName,
    DateOfBirth,
    dbo.fn_PatientAge(DateOfBirth) AS Age
FROM Patients
ORDER BY Age DESC;
GO

-- Q13: Most used medicines in prescriptions
SELECT
    m.MedicineName,
    SUM(pd.Quantity) AS TotalQuantityPrescribed
FROM PrescriptionDetails pd
INNER JOIN Medicines m ON pd.MedicineID = m.MedicineID
GROUP BY m.MedicineName
ORDER BY TotalQuantityPrescribed DESC;
GO

-- Q14: Average laboratory test cost
SELECT
    AVG(Cost) AS AverageLabTestCost
FROM LabTests;
GO

-- Q15: Patients with medical records
SELECT *
FROM dbo.vw_PatientMedicalHistory
ORDER BY RecordDate DESC;
GO

-- Q16: Doctors with no appointments
SELECT
    d.DoctorID,
    d.FirstName + ' ' + d.LastName AS DoctorName
FROM Doctors d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
WHERE a.AppointmentID IS NULL;
GO

-- Q17: CTE - department appointment counts
WITH DepartmentAppointments AS
(
    SELECT
        dep.DepartmentID,
        dep.DepartmentName,
        COUNT(a.AppointmentID) AS AppointmentCount
    FROM Departments dep
    LEFT JOIN Doctors d ON dep.DepartmentID = d.DepartmentID
    LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
    GROUP BY dep.DepartmentID, dep.DepartmentName
)
SELECT *
FROM DepartmentAppointments
ORDER BY AppointmentCount DESC;
GO

-- Q18: Subquery - patients whose bill is above the average bill
SELECT
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    b.TotalAmount
FROM Patients p
INNER JOIN Bills b ON p.PatientID = b.PatientID
WHERE b.TotalAmount > (SELECT AVG(TotalAmount) FROM Bills);
GO

-- Q19: CASE expression - patient age group
SELECT
    PatientID,
    FirstName + ' ' + LastName AS PatientName,
    dbo.fn_PatientAge(DateOfBirth) AS Age,
    CASE
        WHEN dbo.fn_PatientAge(DateOfBirth) < 18 THEN 'Child'
        WHEN dbo.fn_PatientAge(DateOfBirth) < 60 THEN 'Adult'
        ELSE 'Senior'
    END AS AgeGroup
FROM Patients;
GO

-- Q20: Daily/period appointment report
SELECT
    CAST(AppointmentDate AS DATE) AS AppointmentDay,
    COUNT(*) AS AppointmentCount
FROM Appointments
GROUP BY CAST(AppointmentDate AS DATE)
ORDER BY AppointmentDay;
GO

-- Q21: Patients with unpaid balances
SELECT
    PatientID,
    PatientName,
    SUM(RemainingAmount) AS TotalRemaining
FROM dbo.vw_BillingSummary
WHERE RemainingAmount > 0
GROUP BY PatientID, PatientName
ORDER BY TotalRemaining DESC;
GO

-- Q22: Top doctors by completed appointments
SELECT TOP (5)
    d.DoctorID,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    COUNT(*) AS CompletedAppointments
FROM Doctors d
INNER JOIN Appointments a ON d.DoctorID = a.DoctorID
WHERE a.Status = 'Completed'
GROUP BY d.DoctorID, d.FirstName, d.LastName
ORDER BY CompletedAppointments DESC;
GO

-- Q23: Lab cost by doctor
SELECT
    d.FirstName + ' ' + d.LastName AS DoctorName,
    SUM(l.Cost) AS TotalLabValue
FROM LabTests l
INNER JOIN Doctors d ON l.DoctorID = d.DoctorID
GROUP BY d.FirstName, d.LastName
ORDER BY TotalLabValue DESC;
GO

-- Q24: Patients and number of medical records
SELECT
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    COUNT(mr.RecordID) AS MedicalRecordCount
FROM Patients p
LEFT JOIN MedicalRecords mr ON p.PatientID = mr.PatientID
GROUP BY p.PatientID, p.FirstName, p.LastName
ORDER BY MedicalRecordCount DESC;
GO

-- Q25: Prescription details report
SELECT
    pr.PrescriptionID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    d.FirstName + ' ' + d.LastName AS DoctorName,
    m.MedicineName,
    pd.Dosage,
    pd.Frequency,
    pd.Duration,
    pd.Quantity
FROM PrescriptionDetails pd
INNER JOIN Prescriptions pr ON pd.PrescriptionID = pr.PrescriptionID
INNER JOIN Patients p ON pr.PatientID = p.PatientID
INNER JOIN Doctors d ON pr.DoctorID = d.DoctorID
INNER JOIN Medicines m ON pd.MedicineID = m.MedicineID
ORDER BY pr.PrescriptionID;
GO

/* =========================================================
   9. TRANSACTION EXAMPLE
   ========================================================= */

-- Safe demo: update a patient's phone and rollback it.
BEGIN TRANSACTION;

UPDATE Patients
SET Phone = '01011111111'
WHERE PatientID = 1;

SELECT PatientID, FirstName, LastName, Phone
FROM Patients
WHERE PatientID = 1;

ROLLBACK TRANSACTION;
GO

/* =========================================================
   10. EXECUTION PLAN PRACTICE
   ========================================================= */

-- In SSMS press Ctrl+M before executing this query
-- to view the Actual Execution Plan.
SELECT
    a.AppointmentID,
    a.AppointmentDate,
    p.FirstName + ' ' + p.LastName AS PatientName,
    d.FirstName + ' ' + d.LastName AS DoctorName
FROM Appointments a
INNER JOIN Patients p ON a.PatientID = p.PatientID
INNER JOIN Doctors d ON a.DoctorID = d.DoctorID
WHERE a.PatientID = 1
ORDER BY a.AppointmentDate DESC;
GO

/* =========================================================
   11. BACKUP EXAMPLE
   ========================================================= */

-- Run only after creating C:\SQLBackup on the SQL Server machine:
--
-- BACKUP DATABASE HospitalManagementDB
-- TO DISK = 'C:\SQLBackup\HospitalManagementDB.bak'
-- WITH INIT, FORMAT, NAME = 'Hospital Management Full Backup';
-- GO

/* =========================================================
   12. FINAL VERIFICATION
   ========================================================= */

SELECT 'Departments' AS TableName, COUNT(*) AS [RowCount] FROM Departments
UNION ALL SELECT 'Doctors', COUNT(*) FROM Doctors
UNION ALL SELECT 'Patients', COUNT(*) FROM Patients
UNION ALL SELECT 'Appointments', COUNT(*) FROM Appointments
UNION ALL SELECT 'MedicalRecords', COUNT(*) FROM MedicalRecords
UNION ALL SELECT 'Medicines', COUNT(*) FROM Medicines
UNION ALL SELECT 'Prescriptions', COUNT(*) FROM Prescriptions
UNION ALL SELECT 'PrescriptionDetails', COUNT(*) FROM PrescriptionDetails
UNION ALL SELECT 'Rooms', COUNT(*) FROM Rooms
UNION ALL SELECT 'Admissions', COUNT(*) FROM Admissions
UNION ALL SELECT 'LabTests', COUNT(*) FROM LabTests
UNION ALL SELECT 'Bills', COUNT(*) FROM Bills
UNION ALL SELECT 'Payments', COUNT(*) FROM Payments
UNION ALL SELECT 'PatientAudit', COUNT(*) FROM PatientAudit;
GO

PRINT 'HospitalManagementDB project setup completed successfully.';
GO
