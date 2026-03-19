USE DIY_SKILL_SHARING_APP;
GO

SELECT * FROM Enrollments;
SELECT * FROM Workshops;

-- Trigger Testi 
UPDATE Enrollments 
SET Grade = 79 
WHERE LearnerID = 6 AND WorkshopID = 4;  -- learner 6 workshop id 4 ü alıyor ve dersin geçme notu 80, yüzden geçemeyecek
SELECT * FROM Enrollments WHERE LearnerID = 6;
GO


UPDATE Enrollments  -- şimdi notunu 85 yapmaya çalışırsak uyarı verecek ve değiştirilemeyecek
SET Grade = 85 
WHERE LearnerID = 6 AND WorkshopID = 4;
SELECT * FROM Enrollments WHERE LearnerID = 6;
GO    


