
CREATE DATABASE IF NOT EXISTS `ti_perm_auth`;
USE `ti_perm_auth`;

CREATE TABLE IF NOT EXISTS `auth_tickets` (
                                `ticketId` int(11) NOT NULL AUTO_INCREMENT,
                                `userId` int(11) DEFAULT 0,
                                `token` varchar(45) DEFAULT NULL,
                                `clientIp` varchar(45) DEFAULT NULL,
                                `createTime` datetime DEFAULT NULL,
                                `expiresAt` datetime DEFAULT NULL,
                                `updateTime` datetime DEFAULT NULL,
                                `user_name` varchar(512) NOT NULL DEFAULT '',
                                PRIMARY KEY (`ticketId`),
                                KEY `idx_user_id_token` (`userId`,`token`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `user` (
                        `id` int(11) NOT NULL AUTO_INCREMENT,
                        `type` tinyint(4) NOT NULL COMMENT '账号类型：0-超级管理员 1-管理员 2-主账号 3-子账号',
                        `account` varchar(256) NOT NULL COMMENT 'account',
                        `open_id` varchar(32) DEFAULT NULL,
                        `sub_account_uin` varchar(512) NOT NULL COMMENT '子账号',
                        `password` varchar(512) DEFAULT NULL COMMENT '密码',
                        `c_name` varchar(512) DEFAULT NULL COMMENT '中文名',
                        `e_name` varchar(512) DEFAULT NULL COMMENT '英文名',
                        `mail` varchar(512) DEFAULT NULL COMMENT '邮箱',
                        `phone_number` varchar(64) DEFAULT NULL COMMENT '手机',
                        `remark` text DEFAULT NULL COMMENT '备注信息',
                        `status` tinyint(4) DEFAULT 0 COMMENT '状态：0-正常 1-删除',
                        `creator` varchar(512) DEFAULT NULL COMMENT '创建者',
                        `create_at` datetime DEFAULT NULL COMMENT '创建时间',
                        `updator` varchar(512) DEFAULT NULL,
                        `update_at` datetime DEFAULT NULL COMMENT '更新时间',
                        `oa_name` varchar(64) DEFAULT NULL,
                        `is_first_login` tinyint(1) DEFAULT 0 NOT NULL COMMENT '是否首次登录， 0-否，1-是',
                        `disabled` tinyint(4) DEFAULT 0 COMMENT '状态：0-正常 1-禁用',
                        `last_login_time` datetime DEFAULT CURRENT_TIMESTAMP,
                        `last_change_password_at` datetime DEFAULT CURRENT_TIMESTAMP,
                        `history_password` varchar(2048) DEFAULT '' NOT NULL,
                        `uin` varchar(512) NOT NULL COMMENT '主账号',
                        PRIMARY KEY (`id`) USING BTREE,
                        UNIQUE KEY `account_UNIQUE` (`account`),
                        UNIQUE KEY `sub_account_uin_UNIQUE` (`sub_account_uin`),
                        KEY `key_status_open_id` (`status`,`open_id`),
                        KEY `key_c_name` (`c_name`),
                        KEY `key_e_name` (`e_name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

REPLACE INTO `user` (`id`,`type`,`account`,`open_id`,`sub_account_uin`,`password`,`c_name`,`e_name`,`mail`,`phone_number`,`remark`,`status`,`creator`,`create_at`,`updator`,`update_at`,`oa_name`,`is_first_login`,`disabled`,`last_login_time`,`last_change_password_at`,`history_password`,`uin`) VALUES 
(1,0,'superadmin','','superadmin','JnZiFdcp5nFcMMZFcwTm7zcpJKuNB9FYECKae4mmYu4=','超级管理员','','ETl9fI3R6vvTs5rZd50GZcKZc/Ckq/7r1KAfAMJpFBo=','Kzd2pFyfbaoG/f8X4RSlWVUUpfOT4+ujbcnyhWJOrng=','',0,'superadmin','2050-01-02 15:04:05','superadmin','2050-01-02 15:04:05','platform',0,0,'2024-08-21 20:40:14','2024-08-21 20:40:14','','superadmin'),
(2,1,'admin','','admin','4fRFbwo+6XL2iQiNLgLt2t4OkG0hxvAnzinjNd+XZEs=','管理员','','ETl9fI3R6vvTs5rZd50GZcKZc/Ckq/7r1KAfAMJpFBo=','Kzd2pFyfbaoG/f8X4RSlWVUUpfOT4+ujbcnyhWJOrng=','管理员账号',0,'admin','2050-01-02 15:04:05','superadmin','2025-02-27 18:49:10','platform',0,0,'2024-08-21 20:40:14','2024-08-21 20:40:14','','admin'),
(3,2,'100000000','','100000000000','rrQkdvUPA1qRFWBPY7qNJBls8fDHKecp2VEekSGl3+s=','主账号','','HVLNvgF4HgiugodtJepD0X0wmMixB5w4UN4lLcHK8E8=','YHboGkE+qhiuX7P8hgWkYbrd0qIXmn5gc39lNASAL/g=','100000000主账号',0,'admin','2025-02-27 18:24:34','admin','2025-02-27 18:24:34','platform',1,0,'2125-02-27 18:24:34','2125-02-27 18:24:34','','100000000000'),
(4,2,'999999999','','999999999','rrQkdvUPA1qRFWBPY7qNJBls8fDHKecp2VEekSGl3+s=','主账号','','HVLNvgF4HgiugodtJepD0X0wmMixB5w4UN4lLcHK8E8=','YHboGkE+qhiuX7P8hgWkYbrd0qIXmn5gc39lNASAL/g=','999999999主账号',0,'admin','2025-02-27 18:24:34','admin','2025-02-27 18:24:34','platform',1,0,'2125-02-27 18:24:34','2125-02-27 18:24:34','','999999999');

CREATE TABLE IF NOT EXISTS `user_cert` (
                             `id` int(11) NOT NULL AUTO_INCREMENT,
                             `user_id` int(11) DEFAULT 0,
                             `name` varchar(128) NOT NULL,
                             `cert` text NOT NULL,
                             `user_name` varchar(512) NOT NULL DEFAULT '',
                             PRIMARY KEY (`id`),
                             KEY `key_name` (`name`),
                             KEY `key_user_name` (`user_name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `user_identity` (
                                 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
                                 `product_id` int(11) DEFAULT NULL,
                                 `english_name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
                                 `chinese_name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
                                 PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_login_error` (
                                    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
                                    `user_name` varchar(512) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '用户名',
                                    `error_times` int(11) NOT NULL COMMENT '登录密码错误次数',
                                    `expiration` bigint(20) NOT NULL COMMENT '有效期',
                                    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_secret` (
                               `id` int(11) NOT NULL AUTO_INCREMENT,
                               `user_id` int(11) DEFAULT 0,
                               `secret_id` varchar(128) NOT NULL COMMENT '密钥id',
                               `secret_key` varchar(128) NOT NULL COMMENT '密钥key',
                               `create_time` datetime NOT NULL COMMENT '关联时间',
                               `secret_status` tinyint(4) DEFAULT 0 COMMENT '是否启用，0=否',
                               `user_name` varchar(512) NOT NULL DEFAULT '',
                               `uin` varchar(256) DEFAULT '' NOT NULL,
                               PRIMARY KEY (`id`),
                               UNIQUE KEY `secret_id_idx` (`secret_id`),
                               KEY `key_user_name` (`user_name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `verify_code` (
                               `id` int(11) NOT NULL AUTO_INCREMENT,
                               `verify_id` varchar(512) NOT NULL,
                               `verify_code` varchar(512) NOT NULL,
                               `expires_at` datetime DEFAULT NULL COMMENT '过期时间',
                               PRIMARY KEY (`id`),
                               UNIQUE KEY `verify_UNIQUE` (`verify_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
