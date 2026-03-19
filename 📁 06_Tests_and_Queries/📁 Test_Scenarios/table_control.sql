SELECT 
    w.Title AS [At�lye �smi],
    cat.CategoryName AS [Kategori],
    
    (u_mentor.FirstName + ' ' + u_mentor.LastName) AS [Mentor], -- hoca ad ve soyad�
    
    (u_learner.FirstName + ' ' + u_learner.LastName) AS [��renci],  -- ��renci ad ve soyad�
    
    e.Status AS [Durum],
    e.Grade AS [Notu],
    
    ISNULL(b.BadgeName, 'Hen�z Yok') AS [Kazan�lan Rozet]  -- rozet yoksa hen�z yok 

FROM Enrollments e

-- 1. At�lye ve Kategori Ba�lant�lar�
JOIN Workshops w ON e.WorkshopID = w.WorkshopID
JOIN Skills s ON w.SkillID = s.SkillID
JOIN Categories cat ON s.CategoryID = cat.CategoryID

-- 2. Ment�r Bilgileri (Ment�r -> User)
JOIN Mentors m ON w.MentorID = m.MentorID
JOIN Users u_mentor ON m.MentorID = u_mentor.UserID

-- 3. ��renci Bilgileri (Learner -> User)
JOIN Learners l ON e.LearnerID = l.LearnerID
JOIN Users u_learner ON l.LearnerID = u_learner.UserID

-- 4. Rozet Bilgileri (Varsa getir - LEFT JOIN)
LEFT JOIN UserBadges ub ON l.LearnerID = ub.LearnerID 
LEFT JOIN Badges b ON ub.BadgeID = b.BadgeID

ORDER BY w.Title, [��renci];
