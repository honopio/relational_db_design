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




// Generate and insert the fake data for the USERS table
$faker = Faker\Factory::create();
for ($i = 0; $i < 5; $i++) {
   $user_email = $faker->email();
   $stmt = $conn->prepare("INSERT INTO USERS (email) VALUES (:email)");
   $stmt->bindParam(":email", $user_email, PDO::PARAM_STR);
   $stmt->execute();
}
echo "USERS inserted successfully"."\n";


//Fetch USERS ids
$result = $conn->query("SELECT id FROM USERS");
$users_ids = $result->fetchAll(PDO::FETCH_ASSOC);


// Generate and insert the fake data for the ARTICLES table
for ($i = 0; $i < 50; $i++) {
   $title = $faker->text();
   $content = $faker->realText();
   $date = $faker->date();
   $user_id = $users_ids[array_rand($users_ids)]['id']; //pick a random user id


   $stmt = $conn->prepare("INSERT INTO ARTICLES (title, content, date_created, USERS_id) VALUES  (:title, :content, :date_created, :USERS_id)");
   $stmt->bindParam(':title', $title, PDO::PARAM_STR);
   $stmt->bindParam(':content', $content, PDO::PARAM_STR);
   $stmt->bindParam(':date_created', $date, PDO::PARAM_STR);
   $stmt->bindParam(':USERS_id', $user_id, PDO::PARAM_INT);
   $stmt->execute();
}
echo "Articles inserted successfully"."\n";


//Fetch ARTICLES ids
$result = $conn->query("SELECT id FROM ARTICLES");
$articles_ids = $result->fetchAll(PDO::FETCH_ASSOC);


// Generate and insert the fake data for the COMMENTS table
for ($i = 0; $i < 100; $i++) {
   $article_id = $articles_ids[array_rand($articles_ids)]['id']; //pick a random article id
   $user_id = $users_ids[array_rand($users_ids)]['id']; //pick a random user id
   $content = $faker->realText();


   $stmt = $conn->prepare("INSERT INTO COMMENTS (ARTICLES_id, USERS_id, content) VALUES  (:ARTICLES_id, :USERS_id, :content)");
   $stmt->bindParam(':ARTICLES_id', $article_id, PDO::PARAM_INT);
   $stmt->bindParam(':USERS_id', $user_id, PDO::PARAM_INT);
   $stmt->bindParam(':content', $content, PDO::PARAM_STR);
   $stmt->execute();
}
echo "COMMENTS inserted successfully"."\n";




// Generate and insert the fake data for the USERS_USERS table
$already_inserted = array();
$max_friends = count($users_ids) * 2;
foreach ($users_ids as $user) {
   $user_id1 = $user['id'];
   $user_id2 = $users_ids[array_rand($users_ids)]['id']; //pick a random user id
   while($user_id1 == $user_id2 AND !in_array($user_id1."-".$user_id2, $already_inserted) ){ //make sure the two users are different and not already inserted
       $user_id2 = $users_ids[array_rand($users_ids)]['id']; //pick a random user id
   }
   $already_inserted[] = $user_id1."-".$user_id2;


   $stmt = $conn->prepare("INSERT INTO USERS_USERS (USERS_id1, USERS_id2) VALUES  (:USERS_id1, :USERS_id2)");
   $stmt->bindParam(':USERS_id1', $user_id1, PDO::PARAM_INT);
   $stmt->bindParam(':USERS_id2', $user_id2, PDO::PARAM_INT);
   $stmt->execute();
}
echo "USERS_USERS inserted successfully"."\n";


echo "Fake data inserted successfully"."\n";
