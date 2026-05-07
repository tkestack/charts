USE `ti_perm_auth`;

CREATE TABLE IF NOT EXISTS `t_dept` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `dept_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门ID（全局唯一）',
    `uin` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '主账号ID',
    `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门名称（支持中英文、数字、_、-，首字符须为中英文或数字，长度≤60）',
    `e_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门英文名（支持英文、数字、_、-，首字符须为英文或数字，长度≤60）',
    `parent_dept_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '父部门ID',
    `path` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门路径',
    `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门类型',
    `description` text COLLATE utf8mb4_unicode_ci COMMENT '部门描述',
    `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '软删除标记，0未删除，1已删除',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `external_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '第三方ID',
    `space_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'default_space' COMMENT '所属空间ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_dept_id_space` (`dept_id`, `space_id`),
    UNIQUE KEY `uk_uin_pid_name_space` (`uin`,`parent_dept_id`,`name`,`space_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='部门表';

CREATE TABLE IF NOT EXISTS `t_user_dept` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `uin` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '主账号Uin',
    `sub_account_uin` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '子账号Uin',
    `dept_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门ID',
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `space_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'default_space' COMMENT '所属空间ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_subuin_orgid_space` (`sub_account_uin`,`dept_id`,`space_id`),
    KEY `idx_sub_uin` (`sub_account_uin`),
    KEY `idx_dept_id` (`dept_id`),
    KEY `idx_sub_uin_space` (`space_id`, `sub_account_uin`),
    KEY `idx_dept_id_space` (`space_id`, `dept_id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户部门关系表';