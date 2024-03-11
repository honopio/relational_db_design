-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2024-03-07 11:45:29.43

-- tables
-- Table: Cours
CREATE TABLE Cours (
    numCours integer  NOT NULL COMMENT 'le numéro identifiant de chaque cours',
    intitule varchar(128)  NOT NULL COMMENT 'le titre du cours',
    description text  NOT NULL COMMENT 'texte qui décrit le cours',
    preRequis text  NOT NULL COMMENT 'Texte qui précise les pré-requis du cours',
    dateDebut date  NULL,
    dateFin date  NULL,
    cout integer  NOT NULL COMMENT 'prix du cours, ne doit pas être inférieur à 0',
    CONSTRAINT Cours_pk PRIMARY KEY (numCours)
) COMMENT 'Les cours de la plateforme MOOC';

-- Table: Examen
CREATE TABLE Examen (
    idExamen integer  NOT NULL COMMENT 'numéro identifiant de l''''examen',
    titreExamen varchar(128)  NOT NULL COMMENT 'titre de l''''examen',
    contenuExamen Text  NOT NULL COMMENT 'le texte qui représente le contenu de l''''examen',
    scoreMin integer  NOT NULL COMMENT 'score minimal pour réussir l''''exxamen. Doit être compris entre 40 et 100',
    CONSTRAINT Examen_pk PRIMARY KEY (idExamen)
) COMMENT 'Les examens portent sur des parties de cours.';

-- Table: InscriptionCours
CREATE TABLE InscriptionCours (
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Cours_numCours integer  NOT NULL COMMENT 'le numéro identifiant de chaque cours',
    dateInscription date  NOT NULL,
    noteAvis integer  NULL,
    commentaireAvis Text  NULL,
    CONSTRAINT InscriptionCours_pk PRIMARY KEY (Utilisateur_idUtilisateur,Cours_numCours)
);

-- Table: Partie
CREATE TABLE Partie (
    numPartie integer  NOT NULL COMMENT 'identifiant de la partie',
    titrePartie varchar(128)  NOT NULL COMMENT 'titre de chaque partie',
    Contenu Text  NOT NULL COMMENT 'contenu de la partie du cours',
    numChapitre integer  NOT NULL COMMENT 'numéro de chapitre auquel la partie appartient',
    Cours_numCours integer  NOT NULL COMMENT 'le numéro identifiant de chaque cours',
    Examen_idExamen integer  NOT NULL COMMENT 'numéro identifiant de l''''examen',
    CONSTRAINT Partie_pk PRIMARY KEY (numPartie)
) COMMENT 'Les parties qui composent chaque cours. ';

-- Table: Progression
CREATE TABLE Progression (
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Partie_numPartie integer  NOT NULL COMMENT 'identifiant de la partie',
    fini boolean  NOT NULL,
    CONSTRAINT Progression_pk PRIMARY KEY (Utilisateur_idUtilisateur,Partie_numPartie)
) COMMENT 'Mesure la progression de chaque étudiant sur chaque partie de cours';

-- Table: Reglement
CREATE TABLE Reglement (
    numReglement integer  NOT NULL,
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Cours_numCours integer  NOT NULL COMMENT 'le numéro identifiant de chaque cours',
    CONSTRAINT Reglement_pk PRIMARY KEY (numReglement)
) COMMENT 'Règlement d''''un étudiant pour un cours dont le coût est supérieur à 0.';

-- Table: Role
CREATE TABLE Role (
    idRole integer  NOT NULL COMMENT 'Identifiant unique du rôle',
    nom varchar(128)  NOT NULL COMMENT 'Nom du rôle',
    description Text  NOT NULL COMMENT 'Description du rôle',
    CONSTRAINT Role_pk PRIMARY KEY (idRole)
) COMMENT 'Rôle qui détermine les droits de l''''utilisateur';

-- Table: Session
CREATE TABLE Session (
    numSession integer  NOT NULL COMMENT 'numéro identifiant de la session',
    dateHeureDebut datetime  NOT NULL COMMENT 'date et heure de début de session',
    dateHeureFin datetime  NOT NULL COMMENT 'date et heure de fin de session',
    capaciteMax integer  NULL COMMENT 'le nombre de place maximal pour la session. ne doit pas être inférieur à 0. optionnel.',
    modalite varchar(128)  NOT NULL COMMENT 'modalité de l''''enseignement : soit en distanciel, soit en présentiel',
    Cours_numCours integer  NOT NULL COMMENT 'le numéro identifiant de chaque cours',
    CONSTRAINT Session_pk PRIMARY KEY (numSession)
) COMMENT 'Représente les sessions de travail qui portent sur un cours. On numérote les sessions par cours.';

-- Table: Tentative
CREATE TABLE Tentative (
    numTentative integer  NOT NULL COMMENT 'Numéro de la tentative d''''un étudiant sur un examen. On numérote les tentatives qu''''un étudiant fait sur un examen.',
    date date  NOT NULL COMMENT 'date à laquelle la tentative est faite',
    score integer  NULL COMMENT 'résultat de la tentative, compris entre 0 et 100. attribut pas mandatory car le score n''''est pas connu au moment de l''''enregistrement de la tentative',
    reussi boolean  NULL COMMENT 'Réussi est true si le score est supérieur ou égal au scoreMin de l''''examen. On l''''entre comme attribut car on demande une procédure qui marque les tentatives comme réussies.',
    Examen_idExamen integer  NOT NULL COMMENT 'numéro identifiant de l''''examen',
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    CONSTRAINT Tentative_pk PRIMARY KEY (numTentative)
) COMMENT 'Représente une tentative d''''un étudiant de passer un examen. La tentative est réussie si le score est supérieur ou égal au scoreMin de l''''examen';

-- Table: Utilisateur
CREATE TABLE Utilisateur (
    idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    nom varchar(128)  NOT NULL COMMENT 'nom de l''''utilisateur',
    prenom varchar(128)  NOT NULL COMMENT 'prenom de l''''utilisateur',
    adresseMail varchar(128)  NOT NULL COMMENT 'adresse mail de l''''utilisateur',
    CONSTRAINT Utilisateur_pk PRIMARY KEY (idUtilisateur)
) COMMENT 'Les utilisateurs inscrits sur la plateforme.';

-- Table: Utilisateur_Cours
CREATE TABLE Utilisateur_Cours (
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Cours_numCours integer  NOT NULL COMMENT 'le numéro identifiant de chaque cours',
    CONSTRAINT Utilisateur_Cours_pk PRIMARY KEY (Utilisateur_idUtilisateur,Cours_numCours)
);

-- Table: Utilisateur_Role
CREATE TABLE Utilisateur_Role (
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Role_idRole integer  NOT NULL COMMENT 'Identifiant unique du rôle',
    CONSTRAINT Utilisateur_Role_pk PRIMARY KEY (Utilisateur_idUtilisateur,Role_idRole)
);

-- Table: Utilisateur_Session
CREATE TABLE Utilisateur_Session (
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Session_numSession integer  NOT NULL COMMENT 'numéro identifiant de la session',
    CONSTRAINT Utilisateur_Session_pk PRIMARY KEY (Utilisateur_idUtilisateur,Session_numSession)
);

-- foreign keys
-- Reference: Cours_InscriptionCours (table: InscriptionCours)
ALTER TABLE InscriptionCours ADD CONSTRAINT Cours_InscriptionCours FOREIGN KEY Cours_InscriptionCours (Cours_numCours)
    REFERENCES Cours (numCours);

-- Reference: Partie_Cours (table: Partie)
ALTER TABLE Partie ADD CONSTRAINT Partie_Cours FOREIGN KEY Partie_Cours (Cours_numCours)
    REFERENCES Cours (numCours);

-- Reference: Partie_Examen (table: Partie)
ALTER TABLE Partie ADD CONSTRAINT Partie_Examen FOREIGN KEY Partie_Examen (Examen_idExamen)
    REFERENCES Examen (idExamen);

-- Reference: Partie_Progression (table: Progression)
ALTER TABLE Progression ADD CONSTRAINT Partie_Progression FOREIGN KEY Partie_Progression (Partie_numPartie)
    REFERENCES Partie (numPartie);

-- Reference: Reglement_Cours (table: Reglement)
ALTER TABLE Reglement ADD CONSTRAINT Reglement_Cours FOREIGN KEY Reglement_Cours (Cours_numCours)
    REFERENCES Cours (numCours);

-- Reference: Reglement_Etudiant (table: Reglement)
ALTER TABLE Reglement ADD CONSTRAINT Reglement_Etudiant FOREIGN KEY Reglement_Etudiant (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur);

-- Reference: Session_Cours (table: Session)
ALTER TABLE Session ADD CONSTRAINT Session_Cours FOREIGN KEY Session_Cours (Cours_numCours)
    REFERENCES Cours (numCours);

-- Reference: Tentative_Etudiant (table: Tentative)
ALTER TABLE Tentative ADD CONSTRAINT Tentative_Etudiant FOREIGN KEY Tentative_Etudiant (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur);

-- Reference: Tentative_Examen (table: Tentative)
ALTER TABLE Tentative ADD CONSTRAINT Tentative_Examen FOREIGN KEY Tentative_Examen (Examen_idExamen)
    REFERENCES Examen (idExamen);

-- Reference: Utilisateur_Cours_Cours (table: Utilisateur_Cours)
ALTER TABLE Utilisateur_Cours ADD CONSTRAINT Utilisateur_Cours_Cours FOREIGN KEY Utilisateur_Cours_Cours (Cours_numCours)
    REFERENCES Cours (numCours);

-- Reference: Utilisateur_Cours_Utilisateur (table: Utilisateur_Cours)
ALTER TABLE Utilisateur_Cours ADD CONSTRAINT Utilisateur_Cours_Utilisateur FOREIGN KEY Utilisateur_Cours_Utilisateur (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur);

-- Reference: Utilisateur_InscriptionCours (table: InscriptionCours)
ALTER TABLE InscriptionCours ADD CONSTRAINT Utilisateur_InscriptionCours FOREIGN KEY Utilisateur_InscriptionCours (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur);

-- Reference: Utilisateur_Progression (table: Progression)
ALTER TABLE Progression ADD CONSTRAINT Utilisateur_Progression FOREIGN KEY Utilisateur_Progression (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur);

-- Reference: Utilisateur_Role_Role (table: Utilisateur_Role)
ALTER TABLE Utilisateur_Role ADD CONSTRAINT Utilisateur_Role_Role FOREIGN KEY Utilisateur_Role_Role (Role_idRole)
    REFERENCES Role (idRole);

-- Reference: Utilisateur_Role_Utilisateur (table: Utilisateur_Role)
ALTER TABLE Utilisateur_Role ADD CONSTRAINT Utilisateur_Role_Utilisateur FOREIGN KEY Utilisateur_Role_Utilisateur (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur);

-- Reference: Utilisateur_Session_Session (table: Utilisateur_Session)
ALTER TABLE Utilisateur_Session ADD CONSTRAINT Utilisateur_Session_Session FOREIGN KEY Utilisateur_Session_Session (Session_numSession)
    REFERENCES Session (numSession);

-- Reference: Utilisateur_Session_Utilisateur (table: Utilisateur_Session)
ALTER TABLE Utilisateur_Session ADD CONSTRAINT Utilisateur_Session_Utilisateur FOREIGN KEY Utilisateur_Session_Utilisateur (Utilisateur_idUtilisateur)
    REFERENCES Utilisateur (idUtilisateur);

-- End of file.

