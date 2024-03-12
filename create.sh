mysql --user=root --execute='drop database moocDB';
mysql --user=root --execute='create database moocDB';
mysql --user=root moocDB < database_create.sql;
php faker.php;