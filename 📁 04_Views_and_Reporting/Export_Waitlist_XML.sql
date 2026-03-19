-- XML �IKTISI ALMA �RNE��
-- Bekleme listesindeki ��rencileri XML format�nda d��ar� aktar�r.

SELECT 
    w.Title AS Atolye,
    u.FirstName AS Ogrenci_Adi,
    u.LastName AS Ogrenci_Soyadi,
    wl.RequestDate AS Basvuru_Tarihi
FROM Waitlist wl
JOIN Workshops w ON wl.WorkshopID = w.WorkshopID
JOIN Learners l ON wl.LearnerID = l.LearnerID
JOIN Users u ON l.LearnerID = u.UserID
FOR XML PATH('WaitlistEntry'), ROOT('WaitlistData');
