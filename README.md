# <h1> DIY Skill Sharing App - Relational Database Architecture </h1>

## <h2> About the Project </h2>

This project contains the end-to-end database architecture for a "Do It Yourself (DIY) Skill Sharing" platform. The system is designed to bring together mentors who want to share their expertise and learners who are eager to acquire new skills.

Going beyond a standard CRUD application, this architecture is built upon advanced T-SQL principles, including **ACID properties, transaction management, triggers for automating complex business rules, and secure role-based authorization**.

## <h2> Key Engineering Features <h2>

* **Transaction Management (`TRY-CATCH`):** Implemented to ensure data consistency and rollback capabilities during learner registration and capacity-checking processes.
* **Automated Business Rules (Triggers):** Background triggers were developed to evaluate grading; if a learner passes a workshop, the system automatically updates their status and awards the corresponding skill badge.
* **Advanced SQL Objects:** Utilized **Views** for dynamic reporting, **Stored Procedures** with parameters for complex search filters and waitlist processing, and **Table-Valued Functions** to retrieve mentor schedules.
* **Data Security & Role Management:** Configured distinct database Logins and User permissions (`GRANT`/`DENY`) to separate System Administrator and Assistant privileges.
* **XML Integration:** Enabled exporting Waitlist data for external system integrations using the `FOR XML PATH` clause.

## <h2> Database Architecture </h2>

The system consists of tables normalized up to **3NF (Third Normal Form)**, effectively handling multivalued attributes, composite attributes, and identifying relationships (weak entities).

### <h2> ER Diagram </h2>

*(Conceptual relationships between Mentors, Learners, Workshops, and Skills)*

<img width="659" height="381" alt="Feature Importance" src="📁 Docs/ER DIAGRAM.jpg" />

### Relational Schema
*(Table structures, Primary Key (PK), and Foreign Key (FK) constraints)*

<img width="659" height="381" alt="Feature Importance" src="📁 Docs/RELATIONAL SCHEMA.jpg" />


##  <h2> Folder Structure & Installation </h2>

To run this project in your local SQL Server (SSMS) environment, it is highly recommended to execute the scripts in the following order:

1. **`01_DDL_Schema_and_Tables/`**: Creation of the database, core tables, and the 'Analiz' (Analysis) schema.
2. **`02_DML_Mock_Data/`**: Importing dummy data (Mock Data) to populate the system for testing.
3. **`03_Programmability/`**: Loading system functions, stored procedures (registration, search, roster generation), and grading triggers.
4. **`04_Views_and_Reporting/`**: Executing general status reports and student transcript views.
5. **`05_Security/`**: Configuration of database security roles and logins.

> 📄 **Note:** For detailed business requirements, constraints, and project analysis, please review the comprehensive project report located in the `Docs/` folder.

## 💻 Technologies Used
* **DBMS:** Microsoft SQL Server
* **Language:** T-SQL
* **Tools:** SQL Server Management Studio (SSMS)
