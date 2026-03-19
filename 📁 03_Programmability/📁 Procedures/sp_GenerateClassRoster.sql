CREATE PROCEDURE sp_GenerateClassRoster  -- yoklama listesi i�in ge�ici tablo prosed�r�
    @WorkshopID INT
AS
BEGIN
    SET NOCOUNT ON;

   
    CREATE TABLE #Roster (  -- yoklama listesi roster
        RosterID INT IDENTITY(1,1), -- yoklama id si 1 den 1 artarak gider
        StudentName NVARCHAR(100), -- ��renci ad�
        EnrollmentStatus NVARCHAR(20),  -- kay�t durumu
        CheckInBox CHAR(3) DEFAULT '[ ]' -- ��rencilerin checkbox �
    );

    INSERT INTO #Roster (StudentName, EnrollmentStatus)  -- kay�t stat�s�nden veriyi �ekip ge�ici tabloya ekle
    SELECT 
        u.FirstName + ' ' + UPPER(u.LastName),  -- soy isim b�y�k harfle g�z�ks�n
        e.Status  -- durumu se�
    FROM Enrollments e  -- e Enrollments
    JOIN Learners l ON e.LearnerID = l.LearnerID
    JOIN Users u ON l.LearnerID = u.UserID
    WHERE e.WorkshopID = @WorkshopID AND e.Status = 'Enrolled';  -- kay�tl� durumda olanlar� al

 
    SELECT * FROM #Roster ORDER BY StudentName;  -- ge�ici tabloyu getir

    DROP TABLE #Roster;  -- tabloyu sil
END;
GO
