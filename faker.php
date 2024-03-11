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

// COURS TABLE
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

// Generate and insert the fake data for the EXAMEN table


for ($i = 0; $i < 10; $i++) {
    $idExamen = $i;  //idExamen auto increments starting from 0
    $titreExamen = $faker->text(128);
    $contenuExamen = $faker->realText();
    $scoreMin = $faker->numberBetween(40, 100);

    //A MODIFIER QUAND LA TABLE PARTIE SERA FAITE
    $numPartie = $faker->unique()->numberBetween(1, 10); //deux examens ne doivent pas avoir le meme numPartie

    $stmt = $conn->prepare("INSERT INTO Examen (titreExamen, contenuExamen, scoreMin) VALUES (:titreExamen, :contenuExamen, :scoreMin)");
    $stmt->bindParam(':titreExamen', $titreExamen, PDO::PARAM_STR);
    $stmt->bindParam(':contenuExamen', $contenuExamen, PDO::PARAM_STR);
    $stmt->bindParam(':scoreMin', $scoreMin, PDO::PARAM_INT);
    $stmt->execute();
}
echo "EXAMEN inserted successfully"."\n";

// Generate and insert the fake data for the InscriptionCours
    
//50 subscriptions are generated
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


// Generate and insert the fake data for the Partie table which has this ddl :
    /* CREATE TABLE Partie (
    numPartie integer  NOT NULL COMMENT 'identifiant de la partie',
    titrePartie varchar(128)  NOT NULL COMMENT 'titre de chaque partie',
    Contenu Text  NOT NULL COMMENT 'contenu de la partie du cours',
    numChapitre integer  NOT NULL COMMENT 'numero de chapitre auquel la partie appartient',
    Cours_numCours integer  NOT NULL COMMENT 'le numero identifiant de chaque cours',
    CONSTRAINT Partie_pk PRIMARY KEY (numPartie)
) COMMENT 'Les parties qui composent chaque cours. ';
*/
//ESTCE QUE LE NUMCOURS EST CLE PRIMAIRE DE PARTIE? VERTABELO ME LAISSE PAS FAIRE DE numCours SOIT PRIMARY KEY

for ($i = 0; $i < 30; $i++) {
    $numPartie = $i;  //numPartie auto increments starting from 0
    $titrePartie = $faker->text(128);
    $Contenu = $faker->realText();
    $numChapitre = $faker->numberBetween(1, 10); //deux parties ne doivent pas avoir le meme numChapitre
    $Cours_numCours = $faker->numberBetween(1, 10); //deux parties ne doivent pas avoir le meme Cours_numCours

    $stmt = $conn->prepare("INSERT INTO Partie (titrePartie, Contenu, numChapitre, Cours_numCours) VALUES (:titrePartie, :Contenu, :numChapitre, :Cours_numCours)");
    $stmt->bindParam(':titrePartie', $titrePartie, PDO::PARAM_STR);
    $stmt->bindParam(':Contenu', $Contenu, PDO::PARAM_STR);
    $stmt->bindParam(':numChapitre', $numChapitre, PDO::PARAM_INT);
    $stmt->bindParam(':Cours_numCours', $Cours_numCours, PDO::PARAM_INT);
    $stmt->execute();
}

echo "Fake data inserted successfully"."\n";
