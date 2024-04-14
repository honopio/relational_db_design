-- 1. Ordonner les cours par popularité
    -- a. par nb d'utilisateurs inscrits
SELECT C.intitule, COUNT(IC.Utilisateur_idUtilisateur) AS utilisateurs_inscrits
FROM Cours C
JOIN InscriptionCours IC ON C.numCours = IC.Cours_numCours
GROUP BY C.numCours
ORDER BY utilisateurs_inscrits DESC;

    -- b. par notes
SELECT C.intitule, AVG(IC.noteAvis) AS note_moyenne
FROM Cours C
JOIN InscriptionCours IC ON C.numCours = IC.Cours_numCours
WHERE IC.noteAvis IS NOT NULL
GROUP BY C.numCours
ORDER BY note_moyenne DESC;

-- 2. Pour le cours 3, afficher la liste des utilisateurs :
    -- a. Qui ont terminé le cours (toutes les parties ont été marquées comme validées)
    -- compte le nombre de parties validées pour chaque utilisateur et compare avec le nombre total de parties du cours
SELECT DISTINCT U.idUtilisateur, U.nom
FROM Utilisateur U
JOIN Progression P ON U.idUtilisateur = P.Utilisateur_idUtilisateur
JOIN Partie Pt ON P.Partie_numPartie = Pt.numPartie
WHERE Pt.Cours_numCours = 3 AND P.fini = TRUE -- Cours 3 choisi aléatoirement.
GROUP BY U.idUtilisateur
HAVING COUNT(Pt.numPartie) = (SELECT COUNT(*) FROM Partie WHERE Cours_numCours = 3);

    -- b. Qui ont tenté au moins une fois tous les examens du cours
    -- on select le nb d'examens du cours 3, et on compare pour chaque user au nb de distinct idExamen qu'il a passés pour le cours 3.
SELECT DISTINCT U.idUtilisateur, U.nom
FROM Utilisateur U
JOIN InscriptionCours ic ON U.idUtilisateur = ic.Utilisateur_idUtilisateur
JOIN Partie pt ON ic.Cours_numCours = pt.Cours_numCours
JOIN Examen e ON pt.numPartie = e.Partie_numPartie
JOIN Tentative t ON ic.Utilisateur_idUtilisateur = t.Utilisateur_idUtilisateur AND t.Examen_idExamen = e.idExamen
WHERE ic.Cours_numCours = 3
GROUP BY ic.Utilisateur_idUtilisateur
HAVING COUNT(DISTINCT e.idExamen) = (SELECT COUNT(idExamen) FROM Examen WHERE Partie_numPartie IN (SELECT numPartie FROM Partie WHERE Cours_numCours = 3));

    -- c. Qui ont validés le cours (réussi tous les examens)
    -- on select le nb d'examens du cours 3, et on compare pour chaque user au nb de distinct idExamen qu'il a réussi pour le cours 3 (t.reussi = TRUE).
SELECT DISTINCT U.idUtilisateur, U.nom
FROM Utilisateur U
JOIN InscriptionCours ic ON U.idUtilisateur = ic.Utilisateur_idUtilisateur
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
SELECT numPartie, titrePartie, numChapitre, ordreChapitre
FROM Partie
WHERE Cours_numCours = 1  -- Cours 1 choisit aléatoirement.
ORDER BY numChapitre ASC, ordreChapitre ASC;

-- 5. Afficher tous les cours ainsi que les créateurs de cours et formateurs qui y sont rattachés
SELECT c.numCours, u.idUtilisateur, u.nom, u.prenom, r.nom AS role
FROM Cours c
JOIN Cours_utilisateur cu ON c.numCours = cu.Cours_numCours
JOIN Utilisateur u ON cu.Utilisateur_idUtilisateur = u.idUtilisateur
JOIN Utilisateur_role ur ON u.idUtilisateur = ur.Utilisateur_idUtilisateur
JOIN Role r ON ur.Role_idRole = r.idRole
WHERE ur.Role_idRole IN (2, 3);

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
GROUP BY ic.Cours_numCours, ic.Utilisateur_idUtilisateur
ORDER BY pourcentageProgression DESC;