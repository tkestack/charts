CREATE DATABASE IF NOT EXISTS `ti_auth_proxy`;
use `ti_auth_proxy`;

CREATE TABLE IF NOT EXISTS `user_session` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_name` varchar(128) DEFAULT '',
  `session_key` varchar(512) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4133 DEFAULT CHARSET=utf8;