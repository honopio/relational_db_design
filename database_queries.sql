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
