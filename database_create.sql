-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2024-03-23 22:01:44.43

-- tables
-- Table: Cours
CREATE TABLE Cours (
    numCours integer  NOT NULL AUTO_INCREMENT COMMENT 'le numero identifiant de chaque cours',
    intitule varchar(128)  NOT NULL COMMENT 'le titre du cours',
    description text  NOT NULL COMMENT 'texte qui decrit le cours',
    preRequis text  NOT NULL COMMENT 'Texte qui precise les pre-requis du cours',
    dateDebut date  NULL COMMENT 'date de debut du cours (optionnel)',
    dateFin date  NULL COMMENT 'date de fin du cours (optionnel)',
    cout integer  NOT NULL COMMENT 'prix du cours, ne doit pas etre inferieur a 0',
    CONSTRAINT Cours_pk PRIMARY KEY (numCours),
    CONSTRAINT cout_check CHECK (cout >= 0), -- Cout doit etre superieur ou egal a 0
    CONSTRAINT date_check CHECK (dateDebut <= dateFin) -- dateDebut doit preceder dateFin
) COMMENT 'Les cours de la plateforme MOOC';

-- Table: Examen
CREATE TABLE Examen (
    idExamen integer  NOT NULL AUTO_INCREMENT COMMENT 'numero identifiant de l''''examen',
    titreExamen varchar(128)  NOT NULL COMMENT 'titre de l''''examen',
    contenuExamen Text  NOT NULL COMMENT 'le texte qui represente le contenu de l''''examen',
    scoreMin integer  NOT NULL COMMENT 'score minimal pour reussir l''''exxamen. Doit etre compris entre 40 et 100',
    Partie_numPartie integer  NOT NULL COMMENT 'Partie sur laquelle porte l''''examen',
    CONSTRAINT Examen_pk PRIMARY KEY (idExamen),
    CONSTRAINT scoreMin_check CHECK (scoreMin >= 40 AND scoreMin <= 100) -- scoreMin doit etre compris entre 40 et 100
) COMMENT 'Les examens portent sur des parties de cours.';

-- Table: InscriptionCours
CREATE TABLE InscriptionCours (
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Cours_numCours integer  NOT NULL COMMENT 'le numero identifiant de chaque cours',
    dateInscription date  NOT NULL COMMENT 'date d''''''''inscription d''''''''un eleve a un cours',
    noteAvis integer  NULL COMMENT 'note donnee par l''''''''eleve au cours. optionnel',
    commentaireAvis Text  NULL COMMENT 'commentaire donne par l''''''''eleve au cours. optionnel',
    CONSTRAINT InscriptionCours_pk PRIMARY KEY (Utilisateur_idUtilisateur,Cours_numCours),
    CONSTRAINT noteAvis_check CHECK (noteAvis >= 0 AND noteAvis <= 5) -- noteAvis doit etre compris entre 0 et 5
) COMMENT "Inscription d'un eleve a un cours";

-- Table: Partie
CREATE TABLE Partie (
    numPartie integer  NOT NULL AUTO_INCREMENT COMMENT 'identifiant de la partie',
    titrePartie varchar(128)  NOT NULL COMMENT 'titre de chaque partie',
    Contenu Text  NOT NULL COMMENT 'contenu de la partie du cours',
    Cours_numCours integer  NOT NULL COMMENT 'le numero identifiant de chaque cours',
    numChapitre integer  NOT NULL COMMENT 'numero de chapitre auquel la partie appartient',
    ordreChapitre int  NOT NULL COMMENT 'Position de la partie dans le chapitre',
    CONSTRAINT Partie_pk PRIMARY KEY (numPartie),
    CONSTRAINT ordreChapitre_check CHECK (ordreChapitre >= 1), -- ordreChapitre doit etre superieur ou egal a 1
    CONSTRAINT numChapitre_check CHECK (numChapitre >= 1) -- numChapitre doit etre superieur ou egal a 1
) COMMENT 'Les parties qui composent chaque cours. ';

-- Table: Progression
CREATE TABLE Progression (
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Partie_numPartie integer  NOT NULL COMMENT 'identifiant de la partie',
    fini boolean  NOT NULL COMMENT 'Fini est true si l''''''''utilisateur a fini la partie',
    CONSTRAINT Progression_pk PRIMARY KEY (Utilisateur_idUtilisateur,Partie_numPartie)
) COMMENT 'Mesure la progression de chaque etudiant sur chaque partie de cours';

-- Table: Reglement
CREATE TABLE Reglement (
    numReglement integer  NOT NULL AUTO_INCREMENT COMMENT 'identifiant unique du reglement',
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Cours_numCours integer  NOT NULL COMMENT 'le numero identifiant de chaque cours',
    CONSTRAINT Reglement_pk PRIMARY KEY (numReglement)
) COMMENT 'Reglement d''''un etudiant pour un cours dont le coût payant.';

-- Table: Role
CREATE TABLE Role (
    idRole integer  NOT NULL COMMENT 'Identifiant unique du role',
    nom varchar(128)  NOT NULL COMMENT 'Nom du role',
    description Text  NOT NULL COMMENT 'Description du role',
    CONSTRAINT Role_pk PRIMARY KEY (idRole)
) COMMENT 'Role qui determine les droits de l''''utilisateur';

-- Table: Session
CREATE TABLE Session (
    numSession integer  NOT NULL AUTO_INCREMENT COMMENT 'numero identifiant de la session',
    dateHeureDebut datetime  NOT NULL COMMENT 'date et heure de debut de session',
    dateHeureFin datetime  NOT NULL COMMENT 'date et heure de fin de session',
    capaciteMax integer  NULL COMMENT 'le nombre de place maximal pour la session. ne doit pas etre inferieur a 0. optionnel.',
    modalite varchar(128)  NOT NULL COMMENT 'modalite de l''''enseignement : soit en distanciel, soit en presentiel',
    Cours_numCours integer  NOT NULL COMMENT 'le numero identifiant de chaque cours',
    CONSTRAINT Session_pk PRIMARY KEY (numSession),
    CONSTRAINT capaciteMax_check CHECK (capaciteMax >= 0), -- capaciteMax doit etre superieur ou egal a 0
    CONSTRAINT dateHeure_check CHECK (dateHeureDebut < dateHeureFin) -- dateHeureDebut doit preceder dateHeureFin
) COMMENT 'Represente les sessions de travail qui portent sur un cours.';

-- Table: Tentative
CREATE TABLE Tentative (
    numTentative integer  NOT NULL AUTO_INCREMENT COMMENT 'identifiant unique de la tentative d''''un etudiant sur un examen.',
    date date  NOT NULL COMMENT 'date a laquelle la tentative est faite',
    score integer  NULL COMMENT 'resultat de la tentative, compris entre 0 et 100. attribut pas mandatory car le score n''''est pas connu au moment de l''''enregistrement de la tentative',
    reussi boolean  NULL COMMENT 'Reussi est true si le score est superieur ou egal au scoreMin de l''''examen. On l''''entre comme attribut car on demande une procedure qui marque les tentatives comme reussies.',
    Examen_idExamen integer  NOT NULL COMMENT 'numero identifiant de l''''examen',
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    CONSTRAINT Tentative_pk PRIMARY KEY (numTentative),
    CONSTRAINT score_check CHECK (score >= 0 AND score <= 100) -- score doit etre compris entre 0 et 100
) COMMENT 'Represente une tentative d''''un etudiant de passer un examen. La tentative est reussie si le score est superieur ou egal au scoreMin de l''''examen';

-- Table: Utilisateur
CREATE TABLE Utilisateur (
    idUtilisateur integer  NOT NULL AUTO_INCREMENT COMMENT 'identifiant unique des utilisateurs',
    nom varchar(128)  NOT NULL COMMENT 'nom de l''''utilisateur',
    prenom varchar(128)  NOT NULL COMMENT 'prenom de l''''utilisateur',
    adresseMail varchar(128)  NOT NULL COMMENT 'adresse mail de l''''utilisateur',
    CONSTRAINT Utilisateur_pk PRIMARY KEY (idUtilisateur)
) COMMENT 'Les utilisateurs inscrits sur la plateforme.';

-- Table: Utilisateur_Role
CREATE TABLE Utilisateur_Role (
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Role_idRole integer  NOT NULL COMMENT 'Identifiant unique du role',
    CONSTRAINT Utilisateur_Role_pk PRIMARY KEY (Utilisateur_idUtilisateur,Role_idRole)
) COMMENT 'Les roles des utilisateurs';

-- Table: Utilisateur_Session
CREATE TABLE Utilisateur_Session (
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Session_numSession integer  NOT NULL COMMENT 'numero identifiant de la session',
    CONSTRAINT Utilisateur_Session_pk PRIMARY KEY (Utilisateur_idUtilisateur,Session_numSession)
) COMMENT 'Les sessions auxquelles les utilisateurs sont inscrits';

-- foreign keys
-- Reference: Cours_InscriptionCours (table: InscriptionCours)
ALTER TABLE InscriptionCours ADD CONSTRAINT Cours_InscriptionCours FOREIGN KEY Cours_InscriptionCours (Cours_numCours)
    REFERENCES Cours (numCours)
    ON UPDATE CASCADE;

-- Reference: Examen_Partie (table: Examen)
ALTER TABLE Examen ADD CONSTRAINT Examen_Partie FOREIGN KEY Examen_Partie (Partie_numPartie)
    REFERENCES Partie (numPartie)
    ON UPDATE CASCADE;

-- Reference: Partie_Cours (table: Partie)
ALTER TABLE Partie ADD CONSTRAINT Partie_Cours FOREIGN KEY Partie_Cours (Cours_numCours)
    REFERENCES Cours (numCours)
    ON UPDATE CASCADE;

-- Reference: Partie_Progression (table: Progression)
ALTER TABLE Progression ADD CONSTRAINT Partie_Progression FOREIGN KEY Partie_Progression (Partie_numPartie)
    REFERENCES Partie (numPartie)
    ON UPDATE CASCADE;

-- Reference: Reglement_Cours (table: Reglement)
ALTER TABLE Reglement ADD CONSTRAINT Reglement_Cours FOREIGN KEY Reglement_Cours (Cours_numCours)
    REFERENCES Cours (numCours)
    ON UPDATE CASCADE; 

-- Reference: Reglement_Etudiant (table: Reglement)
ALTER TABLE Reglement ADD CONSTRAINT Reglement_Etudiant FOREIGN KEY Reglement_Etudiant (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur)
    ON UPDATE CASCADE;

-- Reference: Session_Cours (table: Session)
ALTER TABLE Session ADD CONSTRAINT Session_Cours FOREIGN KEY Session_Cours (Cours_numCours)
    REFERENCES Cours (numCours)
    ON UPDATE CASCADE;

-- Reference: Tentative_Etudiant (table: Tentative)
ALTER TABLE Tentative ADD CONSTRAINT Tentative_Etudiant FOREIGN KEY Tentative_Etudiant (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur)
    ON UPDATE CASCADE;

-- Reference: Tentative_Examen (table: Tentative)
ALTER TABLE Tentative ADD CONSTRAINT Tentative_Examen FOREIGN KEY Tentative_Examen (Examen_idExamen)
    REFERENCES Examen (idExamen)
    ON UPDATE CASCADE;

-- Reference: Utilisateur_InscriptionCours (table: InscriptionCours)
ALTER TABLE InscriptionCours ADD CONSTRAINT Utilisateur_InscriptionCours FOREIGN KEY Utilisateur_InscriptionCours (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur)
    ON UPDATE CASCADE
    ON DELETE CASCADE;

-- Reference: Utilisateur_Progression (table: Progression)
ALTER TABLE Progression ADD CONSTRAINT Utilisateur_Progression FOREIGN KEY Utilisateur_Progression (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur)
    ON UPDATE CASCADE
    ON DELETE CASCADE;

-- Reference: Utilisateur_Role_Role (table: Utilisateur_Role)
ALTER TABLE Utilisateur_Role ADD CONSTRAINT Utilisateur_Role_Role FOREIGN KEY Utilisateur_Role_Role (Role_idRole)
    REFERENCES Role (idRole)
    ON UPDATE CASCADE;

-- Reference: Utilisateur_Role_Utilisateur (table: Utilisateur_Role)
ALTER TABLE Utilisateur_Role ADD CONSTRAINT Utilisateur_Role_Utilisateur FOREIGN KEY Utilisateur_Role_Utilisateur (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur)
    ON UPDATE CASCADE
    ON DELETE CASCADE;

-- Reference: Utilisateur_Session_Session (table: Utilisateur_Session)
ALTER TABLE Utilisateur_Session ADD CONSTRAINT Utilisateur_Session_Session FOREIGN KEY Utilisateur_Session_Session (Session_numSession)
    REFERENCES Session (numSession)
    ON UPDATE CASCADE;

-- Reference: Utilisateur_Session_Utilisateur (table: Utilisateur_Session)
ALTER TABLE Utilisateur_Session ADD CONSTRAINT Utilisateur_Session_Utilisateur FOREIGN KEY Utilisateur_Session_Utilisateur (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur)
    ON UPDATE CASCADE
    ON DELETE CASCADE;


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



    

DELIMITER ;



-- End of file.

