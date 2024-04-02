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



-- End of file.

