<?php


//First install Faker in your project with the command : composer require fakerphp/faker


// when installed via composer
require_once 'vendor/autoload.php';

// Connect to the database
$user = 'root';
$password = '';
$dbname = 'moocDB';
$driver = 'mysql';//Change this to your database driver if you use sqlite or postgresql

try {
   $conn = new PDO($driver.':host=localhost;dbname='.$dbname, $user, $password);
} catch (PDOException $e) {
   die("Connection failed: " . $e->getMessage());
}
/*
// Truncate or delete data from tables
$tables = ['InscriptionCours', 'Examen', 'Partie', 'Cours']; // Adjust the table names as needed

foreach ($tables as $table) {
    if ($table == 'Cours') {
        // Delete related records in Partie first
        $stmt = $conn->prepare("DELETE FROM Partie WHERE Cours_numCours IN (SELECT numCours FROM Cours)");
        $stmt->execute();

        // Then delete records in Cours
        $conn->exec("DELETE FROM $table");
    } else {
        $conn->exec("DELETE FROM $table");
    }
}
*/

$faker = Faker\Factory::create();

/*---------- COURS TABLE-------------- */

for ($i = 0; $i < 10; $i++) {
   $intitule = $faker->text(128);
   $description = $faker->realText();
   $preRequis = $faker->realText(); //is preRequis supposed to be a text?

   //70% chance of generating both dates
    if ($faker->boolean(70)) {
         $dateDebut = $faker->date();
         $dateFin = $faker->dateTimeBetween($dateDebut . "+10 days", $dateDebut . '+1 year')->format('Y-m-d'); //dateFin is between dateDebut and 1 year after
    }

    //50% chance of $cout being 0 <-> 50% chance of the class being free
    if ($faker->boolean(50)) {
         $cout = 0;
    } else {
         $cout = $faker->numberBetween(1, 200);
    }

   // Insert into Cours table
   $stmt = $conn->prepare("INSERT INTO Cours (intitule, description, preRequis, dateDebut, dateFin, cout) VALUES (:intitule, :description, :preRequis, :dateDebut, :dateFin, :cout)");
   $stmt->bindParam(':intitule', $intitule, PDO::PARAM_STR);
   $stmt->bindParam(':description', $description, PDO::PARAM_STR);
   $stmt->bindParam(':preRequis', $preRequis, PDO::PARAM_STR);
   $stmt->bindParam(':dateDebut', $dateDebut, PDO::PARAM_STR);
   $stmt->bindParam(':dateFin', $dateFin, PDO::PARAM_STR);
   $stmt->bindParam(':cout', $cout, PDO::PARAM_INT);
   $stmt->execute();

}
echo "COURS inserted successfully"."\n";



/*---------- PARTIE TABLE-------------- */


// Fetch numCours from Cours table
$coursStmt = $conn->prepare("SELECT numCours FROM Cours");
$coursStmt->execute();
$coursRows = $coursStmt->fetchAll(PDO::FETCH_ASSOC);

// Insert into Partie table for each Cours
foreach ($coursRows as $coursRow) {
    $Cours_numCours = $coursRow['numCours'];
    
    //random number of parties, between 1 and 8 per cours
    $numParties = $faker->numberBetween(1, 8); // Random number of parties between 1 and 10 per course

    for ($j = 1; $j <= $numParties; $j++) {
        $numPartie = $j;  //numPartie auto increments starting from 1
        $titrePartie = $faker->text(128);
        $Contenu = $faker->realText();

        /* --------A MODIFIER -----------*/
        $numChapitre = 1; 

        $stmt = $conn->prepare("INSERT INTO Partie (titrePartie, Contenu, numChapitre, Cours_numCours, numPartie) VALUES (:titrePartie, :Contenu, :numChapitre, :Cours_numCours, :numPartie)");
        $stmt->bindParam(':titrePartie', $titrePartie, PDO::PARAM_STR);
        $stmt->bindParam(':numPartie', $numPartie, PDO::PARAM_STR);
        $stmt->bindParam(':Contenu', $Contenu, PDO::PARAM_STR);
        $stmt->bindParam(':numChapitre', $numChapitre, PDO::PARAM_INT);
        $stmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
        $stmt->execute();
    }
}
echo "PARTIE inserted successfully"."\n";



/* ---------- EXAMEN TABLE ---------- */

// Fetch Cours_numCours and numPartie : PRIMARY KEY from Partie table
$partieStmt = $conn->prepare("SELECT Cours_numCours, numPartie FROM Partie");
$partieStmt->execute();
$partieRows = $partieStmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($partieRows as $partieRow) {
    // Fetch Cours_numCours and numPartie from Partie table
    $Cours_numCours = $partieRow['Cours_numCours'];
    $numPartie = $partieRow['numPartie'];

    // Generate random exam data
    $titreExamen = $faker->text(30);
    $contenuExamen = $faker->realText();
    /* scoreMin is a multiple of 5 between 40 and 100 */
    $rawScoreMin = $faker->numberBetween(40, 100);
    $scoreMin = round($rawScoreMin / 5) * 5;

    // Insert into Examen table
    $stmt = $conn->prepare("INSERT INTO Examen (titreExamen, contenuExamen, scoreMin, Partie_numPartie, Cours_numCours) VALUES (:titreExamen, :contenuExamen, :scoreMin, :Partie_numPartie, :Cours_numCours)");
    $stmt->bindParam(':titreExamen', $titreExamen, PDO::PARAM_STR);
    $stmt->bindParam(':contenuExamen', $contenuExamen, PDO::PARAM_STR);
    $stmt->bindParam(':scoreMin', $scoreMin, PDO::PARAM_INT);
    $stmt->bindParam(':Partie_numPartie', $numPartie, PDO::PARAM_INT);
    $stmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
    $stmt->execute();
}
echo "EXAMEN inserted successfully"."\n";

/* ---------- UTILISATEUR TABLE ---------- */

for ($i = 0; $i < 20; $i++) {
    // Generate random user data
    $nom = $faker->lastName;
    $prenom = $faker->firstName;
    $adresseMail = $faker->email;

    // Insert into Utilisateur table
    $stmt = $conn->prepare("INSERT INTO Utilisateur (nom, prenom, adresseMail) VALUES (:nom, :prenom, :adresseMail)");
    $stmt->bindParam(':nom', $nom, PDO::PARAM_STR);
    $stmt->bindParam(':prenom', $prenom, PDO::PARAM_STR);
    $stmt->bindParam(':adresseMail', $adresseMail, PDO::PARAM_STR);
    $stmt->execute();
}
echo "UTILISATEUR inserted successfully"."\n";


/* ---------- InscriptionCours TABLE ---------- */  

/* --------------------------
    SI LE COURS EST PAYANT IL DOIT AVOIR ETE REGLE 
    ----------------------------------*/

    // Fetch primary keys from Utilisateur and Cours tables
    $utilisateurStmt = $conn->prepare("SELECT idUtilisateur FROM Utilisateur");
    $utilisateurStmt->execute();
    $utilisateurRows = $utilisateurStmt->fetchAll(PDO::FETCH_ASSOC);

    // Fetch primary keys from Cours table
    $coursStmt = $conn->prepare("SELECT numCours FROM Cours");
    $coursStmt->execute();
    $coursRows = $coursStmt->fetchAll(PDO::FETCH_ASSOC);

    // Insert into InscriptionCours table for each user
    foreach ($utilisateurRows as $utilisateurRow) {
       // Fetch primary key from Utilisateur table
        $Utilisateur_idUtilisateur = $utilisateurRow['idUtilisateur'];

        $usedCourses = array(); // Array to store the courses that have been used
        //reinitialized for every user

        $nbInscriptions = $faker->numberBetween(0, 10); // a student is enrolled in a random nb of courses (between 0 and 10)
        for ($j = 1; $j <= $nbInscriptions; $j++) {
           
            //a user can't be enrolled in the same course twice
            do {
            $randomCours = array_rand($coursRows); //random cours
            $Cours_numCours = $coursRows[$randomCours]['numCours'];
            } while (in_array($Cours_numCours, $usedCourses)); // Check if the course has been used for this user
            $usedCourses[] = $Cours_numCours; // Add the course to the used courses array

            
            /* if the course has dates, dateInscription must be between dateDebut and dateFin */
            $dateCoursStmt = $conn->prepare("SELECT dateDebut, dateFin FROM Cours");
            $dateCoursStmt->execute();
            $dateCoursRows = $dateCoursStmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($dateCoursRows as $coursRow) {
                $dateDebut = $coursRow['dateDebut'];
                $dateFin = $coursRow['dateFin'];
                if ($dateDebut != null) { //if dates are defined for this course
                    $dateInscription = $faker->dateTimeBetween($dateDebut, $dateFin)->format('Y-m-d');
                } else {
                    $dateInscription = $faker->date(); //else, random date
                }
            }

            // 50% chance of noteAvis being null
            if ($faker->boolean(50)) {
                $noteAvis = $faker->numberBetween(0, 5);

                // 80% chance of commentaireAvis not being null if noteAvis is not null
                if ($faker->boolean(80)) {
                    $commentaireAvis = $faker->realText();
                }
            
            // Insert into InscriptionCours table
            $stmt = $conn->prepare("INSERT INTO InscriptionCours (Utilisateur_idUtilisateur, Cours_numCours, dateInscription, noteAvis, commentaireAvis) VALUES (:Utilisateur_idUtilisateur, :Cours_numCours, :dateInscription, :noteAvis, :commentaireAvis)");
            $stmt->bindParam(':Utilisateur_idUtilisateur', $Utilisateur_idUtilisateur, PDO::PARAM_INT);
            $stmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
            $stmt->bindParam(':dateInscription', $dateInscription, PDO::PARAM_STR);
            $stmt->bindParam(':noteAvis', $noteAvis, PDO::PARAM_INT);
            $stmt->bindParam(':commentaireAvis', $commentaireAvis, PDO::PARAM_STR);
            $stmt->execute();
        }
    }
}

echo "INSCRIPTIONCOURS inserted successfully"."\n";


/* ---------- TABLE PROGRESSION ----------------- */

//Fetch Utilisateur_idUtilisateur and Cours_numCours from Utilisateur_Cours table
$utilisateurCoursStmt = $conn->prepare("SELECT Utilisateur_idUtilisateur, Cours_numCours FROM InscriptionCours");
$utilisateurCoursStmt->execute();
$utilisateurCoursRows = $utilisateurCoursStmt->fetchAll(PDO::FETCH_ASSOC); //stores every cours-user pair

//for every user enrolled in a course, insert for every Partie of this course true or false in fini

/* for every cours a user is enrolled in */
foreach ($utilisateurCoursRows as $utilisateurCoursRow) {
    $Utilisateur_idUtilisateur = $utilisateurCoursRow['Utilisateur_idUtilisateur'];
    $Cours_numCours = $utilisateurCoursRow['Cours_numCours'];

    //fetch every partie of the course
    $partieStmt = $conn->prepare("SELECT numPartie FROM Partie WHERE Cours_numCours = :Cours_numCours");
    $partieStmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
    $partieStmt->execute();
    $partieRows = $partieStmt->fetchAll(PDO::FETCH_ASSOC); //$partieRows stores every partie of the course

    /* for every partie of the course the user is enrolled in */
    foreach ($partieRows as $partieRow) {
        $numPartie = $partieRow['numPartie'];

        $fini = $faker->boolean(50) ? true : false; //50% chance of fini being true

        // Insert into Progression table
        $stmt = $conn->prepare("INSERT INTO Progression (Utilisateur_idUtilisateur, Partie_numPartie, Cours_numCours, fini) VALUES (:Utilisateur_idUtilisateur, :Partie_numPartie, :Cours_numCours, :fini)");
        $stmt->bindParam(':Utilisateur_idUtilisateur', $Utilisateur_idUtilisateur, PDO::PARAM_INT);
        $stmt->bindParam(':Partie_numPartie', $numPartie, PDO::PARAM_INT);
        $stmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
        $stmt->bindParam(':fini', $fini, PDO::PARAM_INT);
        $stmt->execute();
    }
}
echo "PROGRESSION inserted successfully"."\n";

/* ---------- TABLE REGLEMENT ----------------- */

/* DDL: CREATE TABLE Reglement (
    numReglement integer AUTO_INCREMENT NOT NULL,
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Cours_numCours integer  NOT NULL COMMENT 'le numero identifiant de chaque cours',
    CONSTRAINT Reglement_pk PRIMARY KEY (numReglement)
) COMMENT 'Reglement d''''un etudiant pour un cours dont le coût est superieur a 0.';
*/




/* ---------- TABLE ROLE ----------------- */
// Role table data isn't generated randomly, as it's a reference table

$idRole = [1, 2, 3, 4, 5];
$nom = ['etudiant', 'createur', 'formateur', 'administrateur', 'personnesAdmin'];
$descriptions = ['Les etudiants peuvent s\'inscrire a des cours, passer des examens, evaluer les cours qu\'ils ont suivi', 
'Les createurs de cours concoivent de nouveaux cours pour la plateforme.', 
'Les formateurs peuvent encadrer des cours, des sessions, et evaluer les etudiants.', 
'Les administrateurs ont des droits etendus pour gerer la plateforme MOOC. Ils peuvent superviser les utilisateurs, gerer les problemes techniques, et assurer le bon fonctionnement de la plateforme.', 
'Le personnel administratif a des privileges specifiques lies a l\'administration generale de la plateforme.'];

// Insert into Role table
for ($i = 0; $i < 5; $i++) {
    $stmt = $conn->prepare("INSERT INTO Role (idRole, nom, description) VALUES (:idRole, :nom, :description)");
    $stmt->bindParam(':idRole', $idRole[$i], PDO::PARAM_INT);
    $stmt->bindParam(':nom', $nom[$i], PDO::PARAM_STR);
    $stmt->bindParam(':description', $descriptions[$i], PDO::PARAM_STR);
    $stmt->execute();
}

echo "ROLE inserted successfully"."\n";

/* ---------- TABLE SESSION ----------------- */


/* ---------------------------
- JAI RAJOUTE COURS_NUMCOURS COMME PRIMARY KEY PR NUMEROTER LES SESSIONS DANS CHQ COURS
- SI LES PLACES SONT LIMITEES IL FAUT SINSCRIRE?
- SI LE COURS A DES DATES DE DEBUT ET FIN, IL FAUT QUE LA SESSION SOIT ENTRE CES DATES?

----------------------------------*/

//fetch numCours from Cours table
$coursStmt = $conn->prepare("SELECT numCours FROM Cours");
$coursStmt->execute();
$coursRows = $coursStmt->fetchAll(PDO::FETCH_ASSOC);

//for every cours, 80% chance of it having sessions
foreach ($coursRows as $coursRow) {
    //80% chance of the course having sessions
    if ($faker->boolean(80)) {

        //generate a random number of sessions btw 1 and 10
        $nbSessions = $faker->numberBetween(1, 10);
        for ($j = 1; $j <= $nbSessions; $j++) {
            $Cours_numCours = $coursRow['numCours'];
            $numSession = $j; //session number increments starting from 1
            $faker->boolean(50) ? $capaciteMax = null : $capaciteMax = $faker->numberBetween(5, 100); //50% chance of capaciteMax being null (optional)
            $modalite = $faker->randomElement(['distanciel', 'presentiel']);

            $stmt = $conn->prepare("INSERT INTO Session (numSession, dateHeureDebut, dateHeureFin, capaciteMax, modalite, Cours_numCours) VALUES (:numSession, :dateHeureDebut, :dateHeureFin, :capaciteMax, :modalite, :Cours_numCours)");
            $stmt->bindParam(':numSession', $numSession, PDO::PARAM_INT);

            // if table partie has dates, dateHeureDebut must be between dateDebut and dateFin
            $dateCoursStmt = $conn->prepare("SELECT dateDebut, dateFin FROM Cours WHERE numCours = :Cours_numCours");
            $dateCoursStmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
            $dateCoursStmt->execute();
            $dateCoursRows = $dateCoursStmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($dateCoursRows as $coursRow) {
                $dateDebut = $coursRow['dateDebut'];
                $dateFin = $coursRow['dateFin'];
                if ($dateDebut != null) { //if dates are defined for this course
                    $dateHeureDebut = $faker->dateTimeBetween($dateDebut, $dateFin)->format('Y-m-d H:i:00');
                }
            }
            // same for dateHeureFin
            foreach ($dateCoursRows as $coursRow) {
                $dateDebut = $coursRow['dateDebut'];
                $dateFin = $coursRow['dateFin'];
                if ($dateDebut != null) { //if dates are defined for this course
                    $dateHeureFin = $faker->dateTimeBetween($dateHeureDebut, $dateHeureDebut . '+12 hours')->format('Y-m-d H:i:00');
                }
            }
            $stmt->bindParam(':dateHeureDebut', $dateHeureDebut, PDO::PARAM_STR);
            $stmt->bindParam(':dateHeureFin', $dateHeureFin, PDO::PARAM_STR);
            $stmt->bindParam(':capaciteMax', $capaciteMax, PDO::PARAM_INT);
            $stmt->bindParam(':modalite', $modalite, PDO::PARAM_STR);
            $stmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
            $stmt->execute();
        }
    }
}


/* ---------- TABLE TENTATIVE ----------------- */


/* ---------- TABLE UTILISATEUR_ROLE ----------------- */


/* ---------- TABLE UTILISATEUR_SESSION ----------------- */

echo "Fake data inserted successfully"."\n";
