USE DIY_SKILL_SHARING_APP;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Analiz') -- öðrenci analiz þemasý
BEGIN
    EXEC('CREATE SCHEMA [Analiz]');
    PRINT 'Analiz þemasý baþarýyla oluþturuldu.';
END
GO

CREATE OR ALTER VIEW [Analiz].[vw_TopOgrenciListesi] AS -- en baþarýlý öðrenciler için view
SELECT TOP 10
    u.FirstName + ' ' + UPPER(u.LastName) AS Ogrenci_AdSoyad, -- ilk 10 u al
    
    COUNT(e.EnrollmentID) AS Tamamlanan_Ders_Sayisi, -- öðrencinin bitirdiði ders sayýsý
    
    -- not ortalamasý
    CAST(AVG(CAST(e.Grade AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS Not_Ortalamasi,
    
    SUM(w.Price) AS Toplam_Harcama, -- toplam harcamasý
    
    CASE 
        WHEN AVG(e.Grade) >= 85 THEN 'Yýldýz Öðrenci' -- ortalamasý 85 üzeriyse yýldýz
        WHEN AVG(e.Grade) >= 70 THEN 'Baþarýlý Öðrenci' -- 70 üzeriyse baþarýlý
        ELSE 'Gayretli' -- altýndakiler de gayretli
    END AS Basari_Etiketi -- baþarý etiketi kolonu

FROM Enrollments e
JOIN Users u ON e.LearnerID = u.UserID
JOIN Workshops w ON e.WorkshopID = w.WorkshopID
WHERE e.Status = 'Completed' -- sadece biten derslere göre
GROUP BY u.UserID, u.FirstName, u.LastName
ORDER BY Not_Ortalamasi DESC, Tamamlanan_Ders_Sayisi DESC; -- en iyiler üstte olacak
GO

-- sonuç
PRINT 'ANALÝZ RAPORU: EN BAÞARILI ÖÐRENCÝLER LÝSTESÝ';
SELECT * FROM [Analiz].[vw_TopOgrenciListesi];
GO
