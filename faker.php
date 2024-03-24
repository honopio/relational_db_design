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

$faker = Faker\Factory::create();

/*---------- COURS TABLE-------------- */

for ($i = 0; $i < 10; $i++) {
   $intitule = $faker->text(128);
   $description = $faker->realText();
   $preRequis = $faker->realText(); // only text

   //50% chance of generating both dates
    if ($faker->boolean(50)) {
         $dateDebut = $faker->date();
         $dateFin = $faker->dateTimeBetween($dateDebut . "+10 days", $dateDebut . '+1 year')->format('Y-m-d'); //dateFin is between dateDebut and 1 year after
    } else { //else dates are null
         $dateDebut = null;
         $dateFin = null;
    }

    //50% chance of $cout being 0
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



/*---------- PARTY TABLE-------------- */


// Fetch numCours from Cours table
$coursStmt = $conn->prepare("SELECT numCours FROM Cours");
$coursStmt->execute();
$coursRows = $coursStmt->fetchAll(PDO::FETCH_ASSOC);

// Insert into Partie table for each Cours
foreach ($coursRows as $coursRow) {
    $Cours_numCours = $coursRow['numCours'];
    
    //random number of parties, between 1 and 8 per cours
    //$numParties = $faker->numberBetween(1, 8); // Random number of parties between 1 and 10 per course

    // random number of Chapitre, between 1 and 5 per cours
    $howManyChapitre = $faker->numberBetween(1, 5);
    for ($i=1; $i <= $howManyChapitre; $i++) {
        $numChapitre = $i;  //numChapitre auto increments starting from 1

        // random number of parties per chapitre, between 1 and 3 per cours
        $howManyPartiesPerChapitre = $faker->numberBetween(1, 3);

        for ($j=1; $j <= $howManyPartiesPerChapitre; $j++) {
            $ordreChapitre = $j;  //numPartie auto increments starting from 1
            $titrePartie = $faker->text(128);
            $Contenu = $faker->realText();        

            $stmt = $conn->prepare("INSERT INTO Partie (titrePartie, Contenu, numChapitre, Cours_numCours, numPartie, ordreChapitre) VALUES (:titrePartie, :Contenu, :numChapitre, :Cours_numCours, :numPartie, :ordreChapitre)");
            $stmt->bindParam(':titrePartie', $titrePartie, PDO::PARAM_STR);
            $stmt->bindParam(':numPartie', $numPartie, PDO::PARAM_STR);
            $stmt->bindParam(':Contenu', $Contenu, PDO::PARAM_STR);
            $stmt->bindParam(':numChapitre', $numChapitre, PDO::PARAM_INT);
            $stmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
            $stmt->bindParam(':ordreChapitre', $ordreChapitre, PDO::PARAM_INT);
            $stmt->execute();
        }

    }
 
}
echo "PARTIE inserted successfully"."\n";



/* ---------- EXAMEN TABLE ---------- */

// Fetch numPartie : PRIMARY KEY from Partie table
$partieStmt = $conn->prepare("SELECT numPartie FROM Partie");
$partieStmt->execute();
$partieRows = $partieStmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($partieRows as $partieRow) {
    $numPartie = $partieRow['numPartie'];
    // 50% chance of generating an exam for each Partie
    if ($faker->boolean(50)) {
        // Generate random exam data
        $titreExamen = $faker->text(30);
        $contenuExamen = $faker->realText();
        /* scoreMin is a multiple of 5 between 40 and 100 */
        $rawScoreMin = $faker->numberBetween(40, 100);
        $scoreMin = round($rawScoreMin / 5) * 5;

        // Insert into Examen table
        $stmt = $conn->prepare("INSERT INTO Examen (titreExamen, contenuExamen, scoreMin, Partie_numPartie) VALUES (:titreExamen, :contenuExamen, :scoreMin, :Partie_numPartie)");
        $stmt->bindParam(':titreExamen', $titreExamen, PDO::PARAM_STR);
        $stmt->bindParam(':contenuExamen', $contenuExamen, PDO::PARAM_STR);
        $stmt->bindParam(':scoreMin', $scoreMin, PDO::PARAM_INT);
        $stmt->bindParam(':Partie_numPartie', $numPartie, PDO::PARAM_INT);
        $stmt->execute();
    }
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
            $dateCoursStmt = $conn->prepare("SELECT dateDebut, dateFin FROM Cours WHERE numCours = :numCours");
            $dateCoursStmt->bindParam(':numCours', $Cours_numCours, PDO::PARAM_INT);
            $dateCoursStmt->execute();
            $coursRow = $dateCoursStmt->fetch(PDO::FETCH_ASSOC);

            // si la requete retourne un resultat valide, on peut inserer une date d'inscription
            if ($coursRow) {
                $dateDebut = $coursRow['dateDebut'];
                $dateFin = $coursRow['dateFin'];
                if ($dateDebut != null && $dateFin != null) { //if dates are defined for this course
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
        $stmt = $conn->prepare("INSERT INTO Progression (Utilisateur_idUtilisateur, Partie_numPartie, fini) VALUES (:Utilisateur_idUtilisateur, :Partie_numPartie, :fini)");
        $stmt->bindParam(':Utilisateur_idUtilisateur', $Utilisateur_idUtilisateur, PDO::PARAM_INT);
        $stmt->bindParam(':Partie_numPartie', $numPartie, PDO::PARAM_INT);
        $stmt->bindParam(':fini', $fini, PDO::PARAM_INT);
        $stmt->execute();
    }
}
echo "PROGRESSION inserted successfully"."\n";

/* ---------- TABLE REGLEMENT ----------------- */


//fetch every user enrolled in a course that is not free
$reglementStmt = $conn->prepare("SELECT Utilisateur_idUtilisateur, Cours_numCours FROM InscriptionCours WHERE Cours_numCours IN (SELECT numCours FROM Cours WHERE cout > 0)");
$reglementStmt->execute();
$reglementRows = $reglementStmt->fetchAll(PDO::FETCH_ASSOC);

//var_dump($reglementRows);die;
$num = 1; //variable pour numReglement
foreach ($reglementRows as $reglementRow) {
    $numReglement = $num; //demarre a 1
    $num++;
    $Utilisateur_idUtilisateur = $reglementRow['Utilisateur_idUtilisateur'];
    $Cours_numCours = $reglementRow['Cours_numCours'];

    // Insert into Reglement table
    $stmt = $conn->prepare("INSERT INTO Reglement (Utilisateur_idUtilisateur, Cours_numCours) VALUES (:Utilisateur_idUtilisateur, :Cours_numCours)");
    $stmt->bindParam(':Utilisateur_idUtilisateur', $Utilisateur_idUtilisateur, PDO::PARAM_INT);
    $stmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
    $stmt->execute();
}


/* ---------- TABLE ROLE ----------------- */
// Role table data isn't generated randomly, as it's a reference table

$idRole = [1, 2, 3, 4, 5];
$nom = ['etudiant', 'createur', 'formateur', 'administrateur', 'personnelAdmin'];
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

//get all numCours from Cours table in an array
$sessionCoursStmt = $conn->prepare("SELECT numCours FROM Cours");
$sessionCoursStmt->execute();
$coursRowsForSession = $sessionCoursStmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($coursRowsForSession as $coursRowForSession) {
    //for every cours, 50% chance of the course having sessions
    if ($faker->boolean(50)) {

        //generate a random number of sessions btw 1 and 5
        $nbSessions = $faker->numberBetween(1, 5);
        for ($j = 1; $j <= $nbSessions; $j++) {
            //$Cours_numCours is the numCours from the Cours table //var_dump($coursRow); die;
            $Cours_numCours = $coursRowForSession['numCours'];
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
                else {
                    $dateHeureDebut = $faker->dateTimeBetween('now', '+1 year')->format('Y-m-d H:i:00');
                }
            }
            // same for dateHeureFin
            foreach ($dateCoursRows as $coursRow) {
                $dateDebut = $coursRow['dateDebut'];
                $dateFin = $coursRow['dateFin'];
                if ($dateDebut != null) { //if dates are defined for this course
                    $dateHeureFin = $faker->dateTimeBetween($dateHeureDebut, $dateHeureDebut . '+12 hours')->format('Y-m-d H:i:00');
                }
                else {
                    $dateHeureFin = $faker->dateTimeBetween($dateHeureDebut, $dateHeureDebut . '+12 hours')->format('Y-m-d H:i:00');
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
}
echo "SESSION inserted successfully"."\n";


/* ---------- TABLE TENTATIVE ----------------- */

//fetch every user enrolled in a course with an exam
$inscriptionCoursStmt = $conn->prepare("SELECT InscriptionCours.Cours_numCours, InscriptionCours.Utilisateur_idUtilisateur 
    FROM InscriptionCours 
    INNER JOIN Partie ON InscriptionCours.Cours_numCours = Partie.Cours_numCours 
    INNER JOIN Examen ON Partie.numPartie = Examen.Partie_numPartie");
$inscriptionCoursStmt->execute();
$inscriptionCoursRows = $inscriptionCoursStmt->fetchAll(PDO::FETCH_ASSOC);

$incrementeur = 1; //variable pour numTentative
//for every user enrolled in a course with an exam
foreach ($inscriptionCoursRows as $inscriptionCoursRow) {
    $Utilisateur_idUtilisateur = $inscriptionCoursRow['Utilisateur_idUtilisateur'];

    //select every examen of the Cours_numCours
    $examenStmt = $conn->prepare("SELECT idExamen, scoreMin FROM Examen WHERE Partie_numPartie IN (SELECT numPartie FROM Partie WHERE Cours_numCours = :Cours_numCours)");
    $examenStmt->bindParam(':Cours_numCours', $inscriptionCoursRow['Cours_numCours'], PDO::PARAM_INT);
    $examenStmt->execute();
    $examenRows = $examenStmt->fetchAll(PDO::FETCH_ASSOC);

    //for every examen of the course
    foreach ($examenRows as $examenRow) {
        
        // have a 30% chance of the user taking the exam
        if ($faker->boolean(30)) {
            //generate between 1 and 3 tentatives
            $nbTentatives = $faker->numberBetween(1, 3);
            for ($j = 1; $j <= $nbTentatives; $j++) {
                $Examen_idExamen = $examenRow['idExamen'];
                $numTentative = $incrementeur; //auto increments starting from 1
                $incrementeur++;
                $date = $faker->date();
                $score = $faker->numberBetween(0, 100);
                $reussi = $score >= $scoreMin ? true : false; //true if the score is greater or equal to the scoreMin of the examen

            // Insert into Tentative table
            $stmt = $conn->prepare("INSERT INTO Tentative (numTentative, date, score, reussi, Examen_idExamen, Utilisateur_idUtilisateur) VALUES (:numTentative, :date, :score, :reussi, :Examen_idExamen, :Utilisateur_idUtilisateur)");
            $stmt->bindParam(':numTentative', $numTentative, PDO::PARAM_INT);
            $stmt->bindParam(':date', $date, PDO::PARAM_STR);
            $stmt->bindParam(':score', $score, PDO::PARAM_INT);
            $stmt->bindParam(':reussi', $reussi, PDO::PARAM_INT);
            $stmt->bindParam(':Examen_idExamen', $Examen_idExamen, PDO::PARAM_INT);
            $stmt->bindParam(':Utilisateur_idUtilisateur', $Utilisateur_idUtilisateur, PDO::PARAM_INT);
            $stmt->execute();
            }
        }
    }
}
echo "TENTATIVE inserted successfully"."\n";


/* ---------- TABLE UTILISATEUR_ROLE ----------------- */
/* CREATE TABLE Utilisateur_Role (
    Utilisateur_idUtilisateur integer  NOT NULL COMMENT 'identifiant unique des utilisateurs',
    Role_idRole integer  NOT NULL COMMENT 'Identifiant unique du role',
    CONSTRAINT Utilisateur_Role_pk PRIMARY KEY (Utilisateur_idUtilisateur,Role_idRole)
); */
//a utilisateur can have more than one role. c'est une table de jointure
//fetch every user
$utilisateurStmt = $conn->prepare("SELECT idUtilisateur FROM Utilisateur");
$utilisateurStmt->execute();
$utilisateurRows = $utilisateurStmt->fetchAll(PDO::FETCH_ASSOC);

//for every user, assign a random number of roles between 1 and 3
foreach ($utilisateurRows as $utilisateurRow) {
    $Utilisateur_idUtilisateur = $utilisateurRow['idUtilisateur'];
    $nbRoles = $faker->numberBetween(1, 3);

    //a user can't have the same idRole twice
    //create an array to store the roles that have been used for each user
    $usedRoles = array();

    for ($j = 1; $j <= $nbRoles; $j++) {

        do {
            $Role_idRole = $faker->numberBetween(1, 5); //random role between 1 and 5
        } while (in_array($Role_idRole, $usedRoles)); // Check if the role has been used for this user
        // Add the role to the used roles array
        $usedRoles[] = $Role_idRole ;

        // Insert into Utilisateur_Role table
        $stmt = $conn->prepare("INSERT INTO Utilisateur_Role (Utilisateur_idUtilisateur, Role_idRole) VALUES (:Utilisateur_idUtilisateur, :Role_idRole)");
        $stmt->bindParam(':Utilisateur_idUtilisateur', $Utilisateur_idUtilisateur, PDO::PARAM_INT);
        $stmt->bindParam(':Role_idRole', $Role_idRole, PDO::PARAM_INT);
        $stmt->execute();
    }
}
echo "UTILISATEUR_ROLE inserted successfully"."\n";




/* ---------- TABLE UTILISATEUR_SESSION ----------------- */

//a user can participate in a session for a course he is enrolled in
//fetch every user from inscriptionCours where the course has sessions
$inscriptionCoursStmt2 = $conn->prepare("SELECT Utilisateur_idUtilisateur, Cours_numCours FROM InscriptionCours WHERE Cours_numCours IN (SELECT Cours_numCours FROM Session)");
$inscriptionCoursStmt2->execute();
$inscriptionCoursRows2 = $inscriptionCoursStmt2->fetchAll(PDO::FETCH_ASSOC);

//for every user enrolled in a course with sessions
foreach ($inscriptionCoursRows2 as $inscriptionCoursRow2) {
    $Utilisateur_idUtilisateur = $inscriptionCoursRow2['Utilisateur_idUtilisateur'];
    $Cours_numCours = $inscriptionCoursRow2['Cours_numCours'];
    //fetch every session of the course
    $sessionStmt = $conn->prepare("SELECT numSession FROM Session WHERE Cours_numCours = :Cours_numCours");
    $sessionStmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
    $sessionStmt->execute();
    $sessionRows = $sessionStmt->fetchAll(PDO::FETCH_ASSOC);
    //for every session of the course
    foreach ($sessionRows as $sessionRow) {
        //var_dump($sessionRows);die;

        $Session_numSession = $sessionRow['numSession'];

        // have a 20% chance of the user participating in the session
        if ($faker->boolean(20)) {
            // Insert into Utilisateur_Session table
            $stmt = $conn->prepare("INSERT INTO Utilisateur_Session (Utilisateur_idUtilisateur, Session_numSession) VALUES (:Utilisateur_idUtilisateur, :Session_numSession)");
            $stmt->bindParam(':Utilisateur_idUtilisateur', $Utilisateur_idUtilisateur, PDO::PARAM_INT);
            $stmt->bindParam(':Session_numSession', $Session_numSession, PDO::PARAM_INT);
            $stmt->execute();
        }
    }
}
echo "UTILISATEUR_SESSION inserted successfully"."\n";

echo "Fake data inserted successfully"."\n";
