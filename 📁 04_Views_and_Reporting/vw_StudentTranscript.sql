USE DIY_SKILL_SHARING_APP;
GO

CREATE VIEW vw_StudentTranscript AS
SELECT 
    u.UserID AS OgrenciID, -- id
    u.FirstName + ' ' + UPPER(u.LastName) AS Ogrenci_AdSoyad, -- Öğrenci soyadını büyük harflerde al
    w.Title AS Ders_Adi, -- ders adı
    
    cat.CategoryName AS Kategori, -- kategori bilgisi
    
    ISNULL(CAST(e.Grade AS NVARCHAR(5)), '-') AS Notu,  -- not NULL ise yazmayacak
    
    CASE e.Status
        WHEN 'Completed' THEN 'GEÇTİ'  -- Completed ise geçti
        WHEN 'Failed' THEN 'KALDI'  -- failed ise kaldı
        WHEN 'Enrolled' THEN 'DEVAM EDİYOR' -- enrolled ise devam ediyor durumunda olacak
        ELSE e.Status
    END AS Durum,
    
    -- subsequery ile kazanılan yetenekleri gösterme
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM UserSkills us 
            WHERE us.UserID = u.UserID AND us.SkillID = w.SkillID
        ) THEN 'Yetenek Rozeti Alındı!'
        ELSE 'Henüz Yok'
    END AS Rozet_Durumu  -- Rozet durumu kolonu

FROM Enrollments e
JOIN Users u ON e.LearnerID = u.UserID
JOIN Workshops w ON e.WorkshopID = w.WorkshopID
JOIN Skills s ON w.SkillID = s.SkillID
JOIN Categories cat ON s.CategoryID = cat.CategoryID;
GO

PRINT 'ÖĞRENCİ TRANSKRİPTİ GÖRÜNTÜLENİYOR...'; -- görüntüleme bildirimi
SELECT * FROM vw_StudentTranscript ORDER BY Ogrenci_AdSoyad;
GO
