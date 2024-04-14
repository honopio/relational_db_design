-- 1. Ordonner les cours par popularité
    -- a. par nb d'utilisateurs inscrits
SELECT Cours_numCours, COUNT(Utilisateur_idUtilisateur) AS numUsersEnrolled
FROM InscriptionCours
GROUP BY Cours_numCours
ORDER BY numUsersEnrolled DESC;

    -- b. par notes
SELECT Cours_numCours, AVG(noteAvis) AS moyenne
FROM InscriptionCours
GROUP BY Cours_numCours
ORDER BY moyenne DESC;

-- 2. Pour le cours 3, afficher la liste des utilisateurs :
    -- a. Qui ont terminé le cours (toutes les parties ont été marquées comme validées)
    -- compte le nombre de parties validées pour chaque utilisateur et compare avec le nombre total de parties du cours
SELECT ic.Utilisateur_idUtilisateur
FROM InscriptionCours ic
JOIN Progression p ON ic.Utilisateur_idUtilisateur = p.Utilisateur_idUtilisateur
JOIN Partie pt ON p.Partie_numPartie = pt.numPartie AND pt.Cours_numCours = 3
WHERE p.fini = TRUE
GROUP BY ic.Utilisateur_idUtilisateur
HAVING COUNT(DISTINCT pt.numPartie) = (SELECT COUNT(numPartie) FROM Partie WHERE Cours_numCours = 3);

    -- b. Qui ont tenté au moins une fois tous les examens du cours
    -- on select le nb d'examens du cours 3, et on compare pour chaque user au nb de distinct idExamen qu'il a passés pour le cours 3.
SELECT ic.Utilisateur_idUtilisateur
FROM InscriptionCours ic
JOIN Partie pt ON ic.Cours_numCours = pt.Cours_numCours
JOIN Examen e ON pt.numPartie = e.Partie_numPartie
JOIN Tentative t ON ic.Utilisateur_idUtilisateur = t.Utilisateur_idUtilisateur AND t.Examen_idExamen = e.idExamen
WHERE ic.Cours_numCours = 3
GROUP BY ic.Utilisateur_idUtilisateur
HAVING COUNT(DISTINCT e.idExamen) = (SELECT COUNT(idExamen) FROM Examen WHERE Partie_numPartie IN (SELECT numPartie FROM Partie WHERE Cours_numCours = 3));

    -- c. Qui ont validés le cours (réussi tous les examens)
    -- on select le nb d'examens du cours 3, et on compare pour chaque user au nb de distinct idExamen qu'il a réussi pour le cours 3 (t.reussi = TRUE).
SELECT ic.Utilisateur_idUtilisateur
FROM InscriptionCours ic
JOIN Partie pt ON ic.Cours_numCours = pt.Cours_numCours
JOIN Examen e ON pt.numPartie = e.Partie_numPartie
JOIN Tentative t ON ic.Utilisateur_idUtilisateur = t.Utilisateur_idUtilisateur AND t.Examen_idExamen = e.idExamen
WHERE ic.Cours_numCours = 3 AND t.reussi = TRUE
GROUP BY ic.Utilisateur_idUtilisateur
HAVING COUNT(DISTINCT e.idExamen) = (SELECT COUNT(idExamen) FROM Examen WHERE Partie_numPartie IN (SELECT numPartie FROM Partie WHERE Cours_numCours = 3));

-- 3. Afficher la liste des utilisateurs par ordre de dépenses 
-- somme du prix dépensé par utilisateur dans la colonne montantDepense
SELECT r.Utilisateur_idUtilisateur, SUM(c.cout) AS montantDepense
FROM Reglement r
JOIN Cours c ON r.Cours_numCours = c.numCours
WHERE c.cout > 0
GROUP BY r.Utilisateur_idUtilisateur
ORDER BY montantDepense DESC;

-- 4. Afficher les parties d’un cours, ordonnées par chapitres et ordre dans les chapitres.
SELECT *
FROM Partie
WHERE Cours_numCours = 1
ORDER BY numChapitre, ordreChapitre;

-- 5. Afficher tous les cours ainsi que les créateurs de cours et formateurs qui y sont rattachés
-- role 2 = créateur, role 3 = formateur
SELECT c.numCours, u.idUtilisateur, u.nom, u.prenom, ur.Role_idRole 
FROM Cours c
JOIN Cours_utilisateur cu ON c.numCours = cu.Cours_numCours
JOIN Utilisateur u ON cu.Utilisateur_idUtilisateur = u.idUtilisateur
JOIN Utilisateur_role ur ON u.idUtilisateur = ur.Utilisateur_idUtilisateur
WHERE ur.Role_idRole  IN (2, 3);

-- 6. Pour un utilisateur donné, affiché les cours auxquels il est inscrit, ainsi que son pourcentage de progression de chaque cours 
-- (nombre de parties marquées comme terminées par rapport au nombre de parties totales du cours)
-- pour l'utilisateur 1, on compte le nb de parties terminees, le nb de parties totales, et on calcule le pourcentage de progression
SELECT 
    ic.Cours_numCours, 
    ic.Utilisateur_idUtilisateur, 
    (SELECT COUNT(DISTINCT p.Partie_numPartie) 
     FROM Progression p 
     JOIN Partie pt ON p.Partie_numPartie = pt.numPartie
     WHERE ic.Utilisateur_idUtilisateur = p.Utilisateur_idUtilisateur AND p.fini = TRUE AND pt.Cours_numCours = ic.Cours_numCours) AS nbPartiesTerminees, 
    (SELECT COUNT(DISTINCT pt.numPartie) 
     FROM Partie pt 
     WHERE pt.Cours_numCours = ic.Cours_numCours) AS nbPartiesTotales, 
    ((SELECT COUNT(DISTINCT p.Partie_numPartie) 
      FROM Progression p 
      JOIN Partie pt ON p.Partie_numPartie = pt.numPartie
      WHERE ic.Utilisateur_idUtilisateur = p.Utilisateur_idUtilisateur AND p.fini = TRUE AND pt.Cours_numCours = ic.Cours_numCours) / 
     (SELECT COUNT(DISTINCT pt.numPartie) 
      FROM Partie pt 
      WHERE pt.Cours_numCours = ic.Cours_numCours) * 100) AS pourcentageProgression
FROM InscriptionCours ic
WHERE ic.Utilisateur_idUtilisateur = 1
GROUP BY ic.Cours_numCours, ic.Utilisateur_idUtilisateur;
