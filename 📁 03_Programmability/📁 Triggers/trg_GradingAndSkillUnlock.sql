USE DIY_SKILL_SHARING_APP;
GO

DROP TRIGGER IF EXISTS trg_Notland�rma;
GO

CREATE TRIGGER trg_Notland�rma
ON Enrollments  
AFTER UPDATE  -- enrollments g�ncellendi�inde
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Grade)  -- E�er grade'e update gelirse
    BEGIN
        DECLARE @EnrollmentID INT;
        DECLARE @NewGrade INT;
        DECLARE @WorkshopID INT;
        DECLARE @LearnerID INT;
        DECLARE @SkillID INT;
        DECLARE @PassingGrade INT; -- O dersin ge�me notu

        
        SELECT   -- g�ncellenen sat�rdan bilgiler al�n�r
            @EnrollmentID = i.EnrollmentID, 
            @NewGrade = i.Grade,  -- yeni not
            @LearnerID = i.LearnerID,
            @WorkshopID = i.WorkshopID
        FROM inserted i;

  
        SELECT    -- at�lyelerin ge�me notlar� oldu�u i�in
            @SkillID = SkillID, 
            @PassingGrade = MinPassingGrade  -- at�lyelerden o ge�me notu �ekilir
        FROM Workshops 
        WHERE WorkshopID = @WorkshopID;

        SET @PassingGrade = ISNULL(@PassingGrade, 50);  -- e�er derse ge�me notu girilmediyse varsay�lan ge�me notu 50 olur

        IF @NewGrade IS NOT NULL 
        BEGIN
            IF @NewGrade >= @PassingGrade  -- ment�r�n girdi�i not ge�me notundan y�ksekse
            BEGIN
                
                UPDATE Enrollments SET Status = 'Completed' WHERE EnrollmentID = @EnrollmentID;  -- enrolment status durumu tamamland� olur
                
                IF NOT EXISTS (SELECT 1 FROM UserSkills WHERE UserID = @LearnerID AND SkillID = @SkillID)  -- ve ��renci o at�lyenin yetene�ini kazan�r
                BEGIN
                    INSERT INTO UserSkills (UserID, SkillID, ProficiencyLevel, AcquiredDate)  -- ve beceri tablosuna eklenir
                    VALUES (@LearnerID, @SkillID, 'Beginner', GETDATE());  -- ve o beceride ba�lang�� seviyesine eri�ir
                    
                    PRINT '��renci dersi ge�ti ve yeni bir yetenek kazand�!';  -- ge�me bildirisi
                END
                ELSE  -- e�er notu sonradan y�kseltirsek
                BEGIN
                    PRINT 'Not g�ncellendi: ��renci dersi ge�ti ve yetene�i kazand�!'; 
                END
            END
            ELSE  -- e�er ge�emezse
            BEGIN
                
                UPDATE Enrollments SET Status = 'Failed' WHERE EnrollmentID = @EnrollmentID;  -- failed olarak update edilir
                PRINT 'Not baraj�n alt�nda kald��� i�in ders ba�ar�s�z tamamland�. (Baraj: ' + CAST(@PassingGrade AS VARCHAR) + ')';  -- baraj not ge�ilemedi bildirimi
            END
        END
    END
END;
GO
