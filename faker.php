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

    //20% chance of $cout being 0 <-> 20% chance of the class being free
    if ($faker->boolean(20)) {
         $cout = 0;
    } else {
         $cout = $faker->numberBetween(1, 200);
    }

   $stmt = $conn->prepare("INSERT INTO Cours (intitule, description, preRequis, dateDebut, dateFin, cout) VALUES (:intitule, :description, :preRequis, :dateDebut, :dateFin, :cout)");
   $stmt->bindParam(':intitule', $intitule, PDO::PARAM_STR);
   $stmt->bindParam(':description', $description, PDO::PARAM_STR);
   $stmt->bindParam(':preRequis', $preRequis, PDO::PARAM_STR);
   $stmt->bindParam(':dateDebut', $dateDebut, PDO::PARAM_STR);
   $stmt->bindParam(':dateFin', $dateFin, PDO::PARAM_STR);
   $stmt->bindParam(':cout', $cout, PDO::PARAM_INT);
   $stmt->execute();

}


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


/* ---------- EXAMEN TABLE ---------- */

// Fetch Cours_numCours and numPartie from Partie table
$partieStmt = $conn->prepare("SELECT Cours_numCours, numPartie FROM Partie");
$partieStmt->execute();
$partieRows = $partieStmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($partieRows as $partieRow) {
    $Cours_numCours = $partieRow['Cours_numCours'];
    $numPartie = $partieRow['numPartie'];

 //   $idExamen = $i;  //idExamen auto increments starting from 0
    $titreExamen = $faker->text(30);
    $contenuExamen = $faker->realText();
    $scoreMin = $faker->numberBetween(40, 100);

    $stmt = $conn->prepare("INSERT INTO Examen (titreExamen, contenuExamen, scoreMin, Partie_numPartie, Cours_numCours) VALUES (:titreExamen, :contenuExamen, :scoreMin, :Partie_numPartie, :Cours_numCours)");
    $stmt->bindParam(':titreExamen', $titreExamen, PDO::PARAM_STR);
    $stmt->bindParam(':contenuExamen', $contenuExamen, PDO::PARAM_STR);
    $stmt->bindParam(':scoreMin', $scoreMin, PDO::PARAM_INT);
    $stmt->bindParam(':Partie_numPartie', $numPartie, PDO::PARAM_INT);
    $stmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
    $stmt->execute();
}
echo "EXAMEN inserted successfully"."\n";


/* ---------- InscriptionCours TABLE ---------- */    
/*
//50 subscriptions are generated
$usedPairs = array(); // Array to store the pairs of user/cours that have been used
for ($i = 0; $i < 50; $i++) {
    //genere une paire user/cours unique
    do {
        $Utilisateur_idUtilisateur = $faker->numberBetween(1, 30); //on a genere 30 users
        $Cours_numCours = $faker->numberBetween(1, 10); //on a genere 10 cours
        $pair = "$Utilisateur_idUtilisateur-$Cours_numCours";
    } while (in_array($pair, $usedPairs)); // Check if the pair has been used
    $usedPairs[] = $pair; // Add the pair to the used pairs array
    
    $dateInscription = $faker->date();

    //50% chance of noteAvis being null
    if ($faker->boolean(50)) {
        $noteAvis = $faker->numberBetween(0, 5);
        //if noteAvis is not null, then commentaireAvis has 80% chance of not being null
        if ($faker->boolean(80)) {
            $commentaireAvis = $faker->realText();
        }
    }

    $stmt = $conn->prepare("INSERT INTO InscriptionCours (Utilisateur_idUtilisateur, Cours_numCours, dateInscription, noteAvis, commentaireAvis) VALUES (:Utilisateur_idUtilisateur, :Cours_numCours, :dateInscription, :noteAvis, :commentaireAvis)");
    $stmt->bindParam(':Utilisateur_idUtilisateur', $Utilisateur_idUtilisateur, PDO::PARAM_INT);
    $stmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
    $stmt->bindParam(':dateInscription', $dateInscription, PDO::PARAM_STR);
    $stmt->bindParam(':noteAvis', $noteAvis, PDO::PARAM_INT);
    $stmt->bindParam(':commentaireAvis', $commentaireAvis, PDO::PARAM_STR);
    $stmt->execute();
}
*/

echo "Fake data inserted successfully"."\n";
