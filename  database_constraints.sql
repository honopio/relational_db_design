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
-- FIND THE FUCKING ISSUE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


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
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Inscription date must be between course start and end dates';
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


-- trigger to set the reussi column based on the score
CREATE TRIGGER tentativeScore
BEFORE INSERT ON Tentative
FOR EACH ROW
BEGIN
    DECLARE scoreMin INT;

    -- on recupere le score min de l'examen
    SELECT scoreMin INTO scoreMin
    FROM Examen
    WHERE idExamen = NEW.Examen_idExamen;

    -- set la colonne reussi selon le score
    IF NEW.score >= scoreMin THEN
        SET NEW.reussi = TRUE;
    ELSE
        SET NEW.reussi = FALSE;
    END IF;
END //

-- Requête de test qui fonctionne
INSERT INTO Tentative (Utilisateur_idUtilisateur, Examen_idExamen, score) VALUES (1, 1, 50);

-- Requête de test qui ne fonctionne pas
INSERT INTO Tentative (Utilisateur_idUtilisateur, Examen_idExamen, score) VALUES (1, 1, 40);


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

-- Requête de test qui fonctionne
INSERT INTO Utilisateur_Session (Utilisateur_idUtilisateur, Session_numSession) VALUES (1, 19);

-- Requête de test qui ne fonctionne pas
INSERT INTO Utilisateur_Session (Utilisateur_idUtilisateur, Session_numSession) VALUES (1, 29);


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


-- back to classic delimiter
DELIMITER ;


--------------------ROUTINES --------------------



-- End of file.

