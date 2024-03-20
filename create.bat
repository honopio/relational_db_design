mysql -u root -e "drop database moocDB"
mysql -u root -e "create database moocDB"
mysql -u root moocDB < database_create.sql 
php faker.php