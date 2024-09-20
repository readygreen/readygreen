DROP DATABASE IF EXISTS `ssafy_app_db`;

CREATE DATABASE `ssafy_app_db-db`;

USE `ssafy_app_db-db`;

DROP TABLE IF EXISTS `User`;

CREATE TABLE `User` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(20),
  `company` VARCHAR(20),
  `position` VARCHAR(20)
);