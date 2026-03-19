USE DIY_SKILL_SHARING_APP;
GO

DROP VIEW IF EXISTS vw_SystemGeneralReport;            -- Varsa eski g�r�n�m� sil
GO

CREATE VIEW vw_SystemGeneralReport AS                  -- Raporlama i�in sanal tablo olu�tur
SELECT 
    w.Title AS Atolye_Adi,                             -- At�lye ba�l���n� al
    cat.CategoryName AS Kategori,                      -- Kategori ad�n� al
    
    CONCAT(u_mentor.FirstName, ' ', u_mentor.LastName) AS Egitmen, -- E�itmen ad�n� birle�tir
    CONCAT(u_learner.FirstName, ' ', u_learner.LastName) AS Ogrenci, -- ��renci ad�n� birle�tir
    
    e.EnrollmentDate AS Kayit_Tarihi,                  -- Kay�t tarihini g�ster
    
    CASE 
        WHEN e.Grade IS NULL THEN 'Notland�r�lmad�'    -- Not yoksa mesaj yaz
        ELSE CAST(e.Grade AS NVARCHAR(10))             -- Varsa metne �evirip g�ster
    END AS Notu,
    
    CASE e.Status                                      -- Durum kodlar�n� T�rk�ele�tir
        WHEN 'Enrolled' THEN 'Kay�tl� / Devam Ediyor'
        WHEN 'Completed' THEN 'Ba�ar�yla Tamamland�'
        WHEN 'Failed' THEN 'Ba�ar�s�z'
        WHEN 'Cancelled' THEN '�ptal Edildi'
        ELSE e.Status                                  -- Bilinmeyen durumlar� aynen yaz
    END AS Basari_Durumu,

    dbo.fn_CalculateWorkshopRevenue(w.WorkshopID) AS Atolye_Toplam_Hasilati -- Ciro fonksiyonunu �a��r

FROM Enrollments e                                     -- Ana tablo: Kay�tlar
JOIN Workshops w ON e.WorkshopID = w.WorkshopID        -- At�lye detaylar�n� ba�la
JOIN Mentors m ON w.MentorID = m.MentorID              -- Ment�r ID'sini bul
JOIN Users u_mentor ON m.MentorID = u_mentor.UserID    -- Ment�r ismini Users'dan �ek
JOIN Learners l ON e.LearnerID = l.LearnerID           -- ��renci ID'sini bul
JOIN Users u_learner ON l.LearnerID = u_learner.UserID -- ��renci ismini Users'dan �ek
JOIN Skills s ON w.SkillID = s.SkillID                 -- Yetenek detay�n� ba�la
JOIN Categories cat ON s.CategoryID = cat.CategoryID;  -- Kategori ismini ba�la
GO

SELECT * FROM vw_SystemGeneralReport ORDER BY Atolye_Adi, Ogrenci; -- Raporu test et
GO
