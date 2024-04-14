--------------------TRIGGERS --------------------

DELIMITER //
-- trigger to check if the Cours begins before it ends
CREATE TRIGGER dateCours
BEFORE INSERT ON Cours
FOR EACH ROW
BEGIN
    -- Check if the course start date is before the end date
    IF NEW.dateDebut >= NEW.dateFin THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Course start date must be before the end date';
    END IF;
END //

-- Requête de test qui fonctionne
INSERT INTO Cours (numCours, intitule, dateDebut, dateFin, description, cout, preRequis) VALUES (24, 'Cours X', '2020-01-01', '2020-01-02', 'Description', 100, 'Pre-requis');

-- Requête de test qui ne fonctionne pas
INSERT INTO Cours (numCours, intitule, dateDebut, dateFin, description, cout, preRequis) VALUES (25, 'Cours Y', '2020-01-02', '2020-01-01', 'Description', 100, 'Pre-requis');


--------------------SUIVANT --------------------

-- trigger to check if the inscription date is within the course's beginning and end dates
CREATE TRIGGER dateInscrCours
BEFORE INSERT ON InscriptionCours
FOR EACH ROW
BEGIN
    DECLARE debut DATE;
    DECLARE fin DATE;

    -- get the course's start and end dates
    SELECT dateDebut, dateFin INTO debut, fin
    FROM Cours
    WHERE numCours = NEW.Cours_numCours;

    -- check if the inscription date is within the dates (if the date range is set)
    IF debut IS NOT NULL AND fin IS NOT NULL THEN
        IF NEW.dateInscription < debut OR NEW.dateInscription > fin THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inscription date must be between course start and end dates';
        END IF;
    END IF;
END //

-- Requête de test qui fonctionne
INSERT INTO InscriptionCours (Utilisateur_idUtilisateur, Cours_numCours, dateInscription) VALUES (1, 24, '2020-01-01');

-- Requête de test qui ne fonctionne pas
INSERT INTO InscriptionCours (Utilisateur_idUtilisateur, Cours_numCours, dateInscription) VALUES (2, 24, '2019-01-01');


--------------------SUIVANT --------------------


-- trigger to check if the session starts before it ends
CREATE TRIGGER dateSession
BEFORE INSERT ON Session
FOR EACH ROW
BEGIN
    IF NEW.dateHeureDebut >= NEW.dateHeureFin THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Session start date must be before the end date';
    END IF;
END //

-- Requête de test qui fonctionne
INSERT INTO Session (numSession, Cours_numCours, dateHeureDebut, dateHeureFin, capaciteMax, modalite) VALUES (18, 24, '2020-01-01', '2020-01-02', 10, 'modalite');

-- Requête de test qui ne fonctionne pas
INSERT INTO Session (numSession, Cours_numCours, dateHeureDebut, dateHeureFin, capaciteMax, modalite) VALUES (28, 24, '2020-01-02', '2020-01-01', 10, 'modalite');


--------------------SUIVANT --------------------


-- trigger to check if the session's date is within the course's beginning and end dates
CREATE TRIGGER dateSessionCours
BEFORE INSERT ON Session
FOR EACH ROW
BEGIN
    DECLARE debut DATE;
    DECLARE fin DATE;

    -- get the course's start and end dates
    SELECT dateDebut, dateFin INTO debut, fin
    FROM Cours
    WHERE numCours = NEW.Cours_numCours;

    -- check if the session date is within the dates (if the date range is set)
    IF debut IS NOT NULL AND fin IS NOT NULL THEN
        IF NEW.dateHeureDebut < debut OR NEW.dateHeureDebut > fin THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Session start date must be between course start and end dates';
        END IF;
    END IF;
END //

-- Requête de test qui fonctionne
INSERT INTO Session (numSession, Cours_numCours, dateHeureDebut, dateHeureFin, capaciteMax, modalite) VALUES (19, 24, '2020-01-01', '2020-01-02', 10, 'modalite');

-- Requête de test qui ne fonctionne pas
INSERT INTO Session (numSession, Cours_numCours, dateHeureDebut, dateHeureFin, capaciteMax, modalite) VALUES (29, 24, '2020-01-03', '2020-01-02', 10, 'modalite');


--------------------SUIVANT --------------------


-- trigger to check if "reussi" is set according to the score
CREATE TRIGGER tentativeScore
BEFORE INSERT ON Tentative
FOR EACH ROW
BEGIN
    -- check if the score is set
    IF NEW.score IS NOT NULL THEN

        -- set the reussi attribute according to the score. if Tentative.score >= Examen.scoreMin, reussi = true
        IF NEW.score >= (
            SELECT scoreMin
            FROM Examen
            WHERE idExamen = NEW.Examen_idExamen
        ) THEN
            SET NEW.reussi = true;
        ELSE
            SET NEW.reussi = false;
        END IF;

    END IF;
END //

-- Requête de test qui fonctionne. reussi is true
INSERT INTO Tentative (Utilisateur_idUtilisateur, date, score, reussi, Examen_idExamen) VALUES (1, '2020-01-01', 60, true, 1);

-- Requête de test qui sera corrigee automatiquement. on essaye d'assigner true a une tentative non reussie.
INSERT INTO Tentative (Utilisateur_idUtilisateur, date, score, reussi, Examen_idExamen) VALUES (1, '2020-01-01', 40, true, 1);


--------------------SUIVANT --------------------


-- trigger to make sure the user is enrolled in a course before enrolling in a session
CREATE TRIGGER sessionInscription
BEFORE INSERT ON Utilisateur_Session
FOR EACH ROW
BEGIN
    DECLARE numCours INT;

    -- get the course number
    SELECT Cours_numCours INTO numCours
    FROM Session
    WHERE numSession = NEW.Session_numSession;

    -- check if the user is enrolled in the course
    IF NOT EXISTS (
        SELECT *
        FROM InscriptionCours
        WHERE Utilisateur_idUtilisateur = NEW.Utilisateur_idUtilisateur
        AND Cours_numCours = numCours
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User must be enrolled in the course before enrolling in a session';
    END IF;
END //

-- Requête de test qui fonctionne. le user 1 s'inscrit a une session du cours 1 (numSession 3), auquel il est insvrit
INSERT INTO Utilisateur_Session (Utilisateur_idUtilisateur, Session_numSession) VALUES (1, 3); 

-- Requête de test qui ne fonctionne pas. le user 1 s'inscrit a une session du cours 10 (numSession 9), auquel il n'est pas inscrit
INSERT INTO Utilisateur_Session (Utilisateur_idUtilisateur, Session_numSession) VALUES (1, 9);


--------------------SUIVANT --------------------


-- trigger to make sure the user is enrolled in a course before taking an exam
CREATE TRIGGER examInscription
BEFORE INSERT ON Tentative
FOR EACH ROW
BEGIN
    -- check if the user is enrolled in the course
    IF NOT EXISTS (
        SELECT *
        FROM InscriptionCours
        WHERE Utilisateur_idUtilisateur = NEW.Utilisateur_idUtilisateur
        AND Cours_numCours = (
            SELECT Cours_numCours
            FROM Partie
            WHERE numPartie = (
                SELECT Partie_numPartie
                FROM Examen
                WHERE idExamen = NEW.Examen_idExamen
            )
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User must be enrolled in the course before taking an exam';
    END IF;
END //
-- Requête de test qui fonctionne. user 2 fait une tentative pour l'exam 5 (numPartie 15), du numCours 2 auquel il est inscrit
INSERT INTO Tentative (Utilisateur_idUtilisateur, date, score, reussi, Examen_idExamen) VALUES (2, '2020-01-01', 60, true, 5);

-- Requête de test qui ne fonctionne pas. user 2 fait une tentative pour l'exam 22 (numPartie 53), du numCours 9 auquel il n'est pas inscrit
INSERT INTO Tentative (Utilisateur_idUtilisateur, date, score, reussi, Examen_idExamen) VALUES (2, '2020-01-01', 100, true, 22);


--------------------SUIVANT --------------------

------------------------ 
-- NE MARCHE PAS. J'ai vérifié avec des requêtes qu'on récupérait bien la capacité max d'une session et le nombre d'inscrits, 
-- mais on peut insérer ce qu'on veut
-----------------------------------------------------------------------------------------


-- trigger to check if the session is full before enrolling
CREATE TRIGGER sessionCapacite
BEFORE INSERT ON Utilisateur_Session
FOR EACH ROW
BEGIN
    DECLARE capaciteMax INT;
    DECLARE nbInscrits INT;

    -- get the session's maximum capacity
    SELECT capaciteMax INTO capaciteMax
    FROM Session
    WHERE numSession = NEW.Session_numSession;

    -- get the number of users enrolled in the session
    SELECT COUNT(*) INTO nbInscrits
    FROM Utilisateur_Session
    WHERE Session_numSession = NEW.Session_numSession;

    -- check if the session is full
    IF nbInscrits >= capaciteMax THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Session is full';
    END IF;
END //

-- Requête de test qui fonctionne. user 2 peut s'inscrire à la session 3
INSERT INTO Utilisateur_Session (Utilisateur_idUtilisateur, Session_numSession) VALUES (2, 3);

-- Requête de test qui ne fonctionne pas. user 7 est inscrit au cours lié à la session 1, mais la session est déjà remplie
INSERT INTO Utilisateur_Session (Utilisateur_idUtilisateur, Session_numSession) VALUES (7, 1);


--------------------SUIVANT --------------------

-- trigger to check if the user is not (only) a student, before creating or being assigned a course in table Cours_Utilisateur
CREATE TRIGGER userRole
BEFORE INSERT ON Cours_Utilisateur
FOR EACH ROW
BEGIN
    -- get the user roles in table Utilisateur_Role. If he has only role 1 (student), then he can't create or be assigned a course
    IF NOT EXISTS (
        SELECT *
        FROM Utilisateur_Role
        WHERE Utilisateur_idUtilisateur = NEW.Utilisateur_idUtilisateur
        AND Role_idRole != 1
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "L'utilisateur ne doit pas être seulement un etudiant";
    END IF;
END //

-- Requête de test qui fonctionne. user 5 est un createur, il peut donc être assigné à un cours
INSERT INTO Cours_Utilisateur (Utilisateur_idUtilisateur, Cours_numCours) VALUES (5, 1);

-- Requête de test qui ne fonctionne pas. user 2 est seulement un étudiant, il ne peut pas être assigné à un cours
INSERT INTO Cours_Utilisateur (Utilisateur_idUtilisateur, Cours_numCours) VALUES (2, 1);

-- back to classic delimiter
DELIMITER ;




--------------------ROUTINES --------------------



-- End of file.

