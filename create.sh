mysql --execute='drop database moocDB';
mysql --execute='create database moocDB';
mysql moocDB < database_create.sql;
php faker.php;