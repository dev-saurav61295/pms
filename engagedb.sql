-- phpMyAdmin SQL Dump
-- version 4.9.5
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jul 27, 2026 at 08:02 AM
-- Server version: 8.0.32
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `engagedb`
--

-- --------------------------------------------------------

--
-- Table structure for table `department`
--

CREATE TABLE `department` (
  `group_id` int NOT NULL,
  `hrbp_id` int NOT NULL,
  `owner_id` int DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `department_type` enum('Department','Vertical','ARM') NOT NULL DEFAULT 'Department',
  `unit` enum('Not Applicable','SPU','RPU') NOT NULL DEFAULT 'Not Applicable',
  `production_status` enum('Yes','No') NOT NULL DEFAULT 'Yes',
  `short_url` varchar(50) NOT NULL,
  `org_dept_type` enum('Production','Growth','Admin') DEFAULT 'Production',
  `sbu_type` varchar(150) DEFAULT 'Centralize',
  `department_function` varchar(255) DEFAULT NULL,
  `showinpf` tinyint(1) NOT NULL DEFAULT '0',
  `is_enterprise` enum('Yes','No') NOT NULL DEFAULT 'No',
  `last_updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `project_infrastructure_requirements`
--

CREATE TABLE `project_infrastructure_requirements` (
  `requirements_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `project_id` int NOT NULL,
  `owner_id` int NOT NULL,
  `tag` varchar(255) NOT NULL,
  `provided_by` varchar(255) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `review` int NOT NULL,
  `reviewer_id` int NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `last_updated_by` datetime NOT NULL,
  `post_ip` varchar(255) NOT NULL,
  `requirements_status_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `project_infrastructure_requirements_audit_trails`
--

CREATE TABLE `project_infrastructure_requirements_audit_trails` (
  `id` int NOT NULL,
  `project_id` int NOT NULL DEFAULT '0' COMMENT 'Project ID',
  `requirements_id` int NOT NULL DEFAULT '0' COMMENT 'Task ID',
  `user_id` int NOT NULL DEFAULT '0' COMMENT 'User ID',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'STATUS, PRIORITY, RAG, ADD_ASSIGN, REMOVE_ASSIGN, ESTIMATE, ESTIMATE_COMPLETE, TASK_USER_ADDED, TASK_USER_DELETED, TASK_DELAYED, TASK_DEFERRED, TASK_CHARGEABLE, TASK_INVOICE',
  `type_value` varchar(100) DEFAULT NULL COMMENT 'Type Value like status ID, Priority, Added/Removed User id etc.',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(100) NOT NULL COMMENT 'Post IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `project_requirements_lineitem`
--

CREATE TABLE `project_requirements_lineitem` (
  `id` int NOT NULL,
  `requirements_id` int NOT NULL,
  `sl_no` int NOT NULL,
  `service_category` varchar(255) NOT NULL,
  `tennancy` varchar(255) NOT NULL,
  `instance_type` varchar(255) NOT NULL,
  `region` varchar(255) NOT NULL,
  `operating_system` varchar(255) NOT NULL,
  `vcpu` varchar(255) NOT NULL,
  `memory` varchar(255) NOT NULL,
  `storage` varchar(255) NOT NULL,
  `cost` varchar(255) NOT NULL,
  `monthly_cost` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_activities`
--

CREATE TABLE `tbl_activities` (
  `activity_id` bigint NOT NULL,
  `parent_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store parent activity id',
  `activity_type_id` int NOT NULL COMMENT 'Activity ID',
  `share_status` int NOT NULL DEFAULT '0' COMMENT 'Set 1 if shared',
  `user_id` int NOT NULL COMMENT 'Users'' ID',
  `company_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Store Company ID ',
  `profile_id` int NOT NULL DEFAULT '0' COMMENT 'Store profile id to identify wall post',
  `question_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store Idea or Challenge ID',
  `group_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store Group ID',
  `event_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store Event ID',
  `follow_id` bigint NOT NULL,
  `project_id` bigint NOT NULL COMMENT 'Project ID',
  `parameters` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store values',
  `related_activity` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store parent activity_type',
  `user_ids` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Store user''s id for like/unlike activity',
  `activity_time` datetime NOT NULL COMMENT 'Store activity time',
  `file_operation` int DEFAULT '0' COMMENT 'Checked if there is anu file related operations',
  `file_operation_type` enum('FILE','PHOTO','VIDEO','PROFILE_PHOTO','GROUP','GROUP_FILE','GROUP_PHOTO','GROUP_POLL','GROUP_VIDEO','PROJECT','PROJECT_FILE','PROJECT_PHOTO','PROJECT_POLL','PROJECT_VIDEO','ALBUM_PHOTO','DOCUMENT','NONE') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT 'NONE' COMMENT 'Store file operation type',
  `files` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Store files path in serialized format',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store users'' IP',
  `group_operation` int NOT NULL DEFAULT '0' COMMENT 'Store group operation type',
  `privacy_status` int NOT NULL DEFAULT '1' COMMENT 'set Privacy status. -1=private,  1= public, 2=-contact, 3=friends of friends',
  `update_time` datetime NOT NULL COMMENT 'Update date for any related activities',
  `activity_privacy` tinyint NOT NULL DEFAULT '1' COMMENT '1 - Public - can see all user , 3 -  Friends - Can see only friends , 2 -  Friends of Friends - can see Friends and their friends , 4 - only me - can see only me , 5 - Specific people or lists -  can see the selected list of people or groups , 6 - Hide th',
  `delete_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Deleted activity time',
  `status` int NOT NULL DEFAULT '1' COMMENT '1 - Active , 0 - Deleted, 2 - Deleted with warning message',
  `activity_severity` int NOT NULL DEFAULT '0',
  `process_read_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to track if the activity read status has been processed or not, -1 = ignore, 1 = processed, 0 = processing pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_activity_privacy_settings`
--

CREATE TABLE `tbl_activity_privacy_settings` (
  `activity_id` bigint NOT NULL COMMENT 'store activity id',
  `activity_privacy` tinyint DEFAULT NULL COMMENT 'store activity privacy',
  `privacy_settings` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'store activity privacy settings '
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_activity_tags`
--

CREATE TABLE `tbl_activity_tags` (
  `activity_id` int NOT NULL COMMENT 'store activity_id',
  `tag_id` int NOT NULL COMMENT 'store tag_id'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_activity_types`
--

CREATE TABLE `tbl_activity_types` (
  `activity_type_id` int NOT NULL,
  `activity_type` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'It will store constant values',
  `related_activity` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `parameters` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'The parameters which need to be replaced',
  `section` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store related section name for breacrumb concept',
  `module_read_flag` enum('G','P') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store related module; G=Groups, P=Projects',
  `ref_path` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store activity ref path',
  `icon_img` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Icon image name; Images will be stored in global folder',
  `description` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Short descrioption about this activity.',
  `display_at` enum('HOME','WALL','BOTH','NONE') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `group_operation` int NOT NULL DEFAULT '0',
  `status` int NOT NULL DEFAULT '0' COMMENT 'Will be used to check active/inactive',
  `group_activity_type` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'group activity type',
  `vote_status` enum('NONE','ACTIVITY','COMMENT','BOTH') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'NONE',
  `mail_recipients` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'mail recipients in json format'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_activity_types_desc`
--

CREATE TABLE `tbl_activity_types_desc` (
  `activity_type_id` int NOT NULL,
  `gender_id` int NOT NULL,
  `language_id` int NOT NULL,
  `activity_desc` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Will be used to store activity message format'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_admins`
--

CREATE TABLE `tbl_admins` (
  `admin_id` int NOT NULL,
  `group_id` int NOT NULL COMMENT 'Store admin group ID',
  `username` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store administrator''s username',
  `password` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store password in md5 format after adding salt',
  `salt` varchar(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Password salt',
  `email` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Administrator''s email address',
  `first_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Administrator''s first name',
  `last_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Administrator''s last name',
  `last_login_time` datetime DEFAULT '0000-00-00 00:00:00' COMMENT 'Store login date time after successful login',
  `super_admin` int NOT NULL DEFAULT '0' COMMENT 'Used to check super admin status',
  `login_try` int NOT NULL DEFAULT '0' COMMENT 'Used to check unsuccessful attempt',
  `reset_password` int NOT NULL DEFAULT '0' COMMENT 'Used to redirect administrator to change password section after resetting password',
  `block_reason` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'reason for account block',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store account creation date',
  `up_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store last update date',
  `status` int NOT NULL DEFAULT '0' COMMENT 'Need to check active status',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store last access IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_admin_groups`
--

CREATE TABLE `tbl_admin_groups` (
  `group_id` int NOT NULL,
  `group_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Administrator''s group name',
  `access_permission` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Need to store section access settings in serialized format',
  `status` int NOT NULL DEFAULT '0' COMMENT 'Active/Inactive Status',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Creation date',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Last modified date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'IP - Last access'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_admin_group_settings`
--

CREATE TABLE `tbl_admin_group_settings` (
  `group_id` int NOT NULL COMMENT 'Store admin group id',
  `section_id` int NOT NULL COMMENT 'Store admin section id'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_admin_sections`
--

CREATE TABLE `tbl_admin_sections` (
  `section_id` int NOT NULL COMMENT 'Section ID',
  `parent_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Section Parent ID',
  `section_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store section code name',
  `section_desc` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store section description ',
  `section_order` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Section Order',
  `module` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Module name',
  `action` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Module action',
  `ref_action` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Reference action ',
  `font_class` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Font class',
  `templates` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Loaded Templates',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Section creation date',
  `status` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Active/Inactive status',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store last IP address'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_agenda`
--

CREATE TABLE `tbl_agenda` (
  `agenda_id` int NOT NULL,
  `event_id` int NOT NULL,
  `user_id` int NOT NULL,
  `topic` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `topic_date` datetime NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_albums`
--

CREATE TABLE `tbl_albums` (
  `album_id` bigint NOT NULL,
  `user_id` int NOT NULL COMMENT 'Store user''s ID',
  `activity_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store activity id',
  `group_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store group ID',
  `event_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store event ID',
  `company_id` int NOT NULL DEFAULT '0' COMMENT 'Store company ID',
  `album_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store album''s name',
  `album_desc` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store album''s description',
  `location` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store location',
  `type` enum('D','W','P') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'D',
  `privacy` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT '0 for noone; -1 for friends only; -2 for fiends of friends; comma separated ids for selected friends',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store post date',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store update date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store user''s IP',
  `status` int NOT NULL DEFAULT '0' COMMENT 'Diaplay status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_album_photos`
--

CREATE TABLE `tbl_album_photos` (
  `album_id` bigint NOT NULL COMMENT 'Set ''-1'' for wall photo; set ''-2'' for profile photo',
  `photo_id` bigint NOT NULL COMMENT 'Store photo ID',
  `user_id` bigint NOT NULL COMMENT 'Store user''s ID',
  `album_image` enum('N','Y') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Set ''Y'' if the photo has been assigned for album Image'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_announcements`
--

CREATE TABLE `tbl_announcements` (
  `announce_id` int NOT NULL,
  `announce_title` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `post_date` date NOT NULL,
  `update_date` date NOT NULL,
  `status` enum('0','1') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `post_ip` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `company_ids` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `job_ids` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_area_of_work`
--

CREATE TABLE `tbl_area_of_work` (
  `area_work_id` int UNSIGNED NOT NULL COMMENT 'Area of Work Auto ID',
  `area_work_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Area of Work Title',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Area of Work Status',
  `post_date` datetime NOT NULL COMMENT 'Post Date ',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Post IP Address'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_attachment`
--

CREATE TABLE `tbl_attachment` (
  `file_id` int NOT NULL COMMENT 'Auto Increment ID',
  `folder_id` int NOT NULL DEFAULT '0' COMMENT 'Foreign key of tbl_uploads_folder',
  `type` enum('G','GD','GT','P','PD','PT','PI','PR','C','E','PMSI','PRCA','PICA') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'GD: Group Discussion, GT: Group Ticket, PD: Project Discussion, PT: Project Task, PI: Project Issue, PR: Project Risk, C: Comment, E: Event',
  `type_id` int NOT NULL COMMENT 'type_id is task_id, issue_id or topic_id',
  `activity_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store activity ID',
  `ori_file_name` varchar(500) NOT NULL COMMENT 'stores original file name',
  `sys_file_name` varchar(100) NOT NULL COMMENT 'stores system file name',
  `file_size` double(10,2) NOT NULL COMMENT 'stores size of file',
  `file_type` enum('DOCUMENT','TEXT','PRESENTATION','SPREADSHEET','IMAGE','PDF','OTHERS') NOT NULL COMMENT 'stores file type',
  `starred` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Starred flag',
  `post_date` datetime NOT NULL COMMENT 'Post date of attachment',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Update date of attachment',
  `post_ip` varchar(30) NOT NULL COMMENT 'Post IP address',
  `status` tinyint(1) NOT NULL COMMENT 'Active/ Inactive',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Deleted flag'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_attachment_dl_log`
--

CREATE TABLE `tbl_attachment_dl_log` (
  `log_id` int NOT NULL,
  `file_id` int NOT NULL,
  `email` varchar(100) NOT NULL,
  `registered` enum('0','1') NOT NULL,
  `is_downloaded` enum('0','1') NOT NULL,
  `token` varchar(10) NOT NULL,
  `post_ip` varchar(100) NOT NULL,
  `downloaded_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_attachment_relation`
--

CREATE TABLE `tbl_attachment_relation` (
  `relation_id` int NOT NULL COMMENT 'Primary Key',
  `file_id` int NOT NULL COMMENT 'foreign key of tbl_uploads',
  `caption` varchar(500) NOT NULL COMMENT 'store file caption',
  `description` text NOT NULL COMMENT 'store file description',
  `tagged` text NOT NULL,
  `privacy` text NOT NULL COMMENT 'Store privacy details',
  `image_inline_id` varchar(255) NOT NULL,
  `disposition` enum('attachment','inline') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_available_for_info`
--

CREATE TABLE `tbl_available_for_info` (
  `available_for_id` int NOT NULL COMMENT 'Store available for ID',
  `code` char(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store code name',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store update date',
  `status` int DEFAULT '0' COMMENT 'Store display status',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store user''s IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_available_for_info_desc`
--

CREATE TABLE `tbl_available_for_info_desc` (
  `available_for_id` int NOT NULL COMMENT 'Store available for ID',
  `language_id` int NOT NULL COMMENT 'Store language ID',
  `description` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store available for description'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_batch_notifications`
--

CREATE TABLE `tbl_batch_notifications` (
  `batch_id` int UNSIGNED NOT NULL COMMENT 'Batch ID',
  `receipent_id` int UNSIGNED NOT NULL COMMENT 'User/Receipent ID',
  `sender_id` int UNSIGNED NOT NULL COMMENT 'Sender ID',
  `mail_code` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Batch Mail Code',
  `parameters` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Batch Mail Paramters',
  `batch_type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Batch Type',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `send_date` datetime DEFAULT NULL COMMENT 'Send Date',
  `send_status` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Batch Send Status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_bulletin`
--

CREATE TABLE `tbl_bulletin` (
  `bulletin_id` int NOT NULL COMMENT 'Bulletin ID',
  `title` varchar(200) NOT NULL COMMENT 'Title',
  `description` text NOT NULL COMMENT 'Description',
  `activity_id` int NOT NULL COMMENT 'Activity ID',
  `category_id` int NOT NULL COMMENT 'Category ID',
  `group_id` int NOT NULL COMMENT 'Group ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `reference_no` int NOT NULL COMMENT 'Reference No',
  `short_url` varchar(200) NOT NULL COMMENT 'Short url',
  `views` tinyint NOT NULL COMMENT 'Distinct count of user logged in',
  `post_date` datetime NOT NULL COMMENT 'Post date',
  `update_date` datetime NOT NULL COMMENT 'Update date',
  `post_ip` varchar(15) NOT NULL COMMENT 'Post IP',
  `status` int NOT NULL COMMENT 'Status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_bulletin_bookmark`
--

CREATE TABLE `tbl_bulletin_bookmark` (
  `bulletin_id` int NOT NULL COMMENT 'Bulletin id to mark as a bookmark / reply later',
  `user_id` int NOT NULL COMMENT 'Userd id who will mark as bookmark / reply later',
  `mark_as_bookmark` int NOT NULL COMMENT 'Mark bulletin as a bookmark',
  `mark_as_reply_later` int NOT NULL COMMENT 'Mark bulletin as a reply later',
  `post_date` datetime NOT NULL COMMENT 'Post date',
  `post_ip` varchar(15) NOT NULL COMMENT 'Post ip'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_bulletin_category`
--

CREATE TABLE `tbl_bulletin_category` (
  `category_id` int NOT NULL COMMENT 'Category id',
  `title` varchar(150) NOT NULL COMMENT 'Title',
  `post_date` datetime NOT NULL COMMENT 'Post date',
  `update_date` datetime NOT NULL COMMENT 'Updated date',
  `created_by` int NOT NULL COMMENT 'Created by',
  `status` int NOT NULL COMMENT 'Status',
  `post_ip` varchar(15) NOT NULL COMMENT 'Post ip'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_bulletin_comment`
--

CREATE TABLE `tbl_bulletin_comment` (
  `comment_id` int NOT NULL COMMENT 'Comment id',
  `bulletin_id` int NOT NULL,
  `activity_id` int NOT NULL COMMENT 'Activity id',
  `user_id` int NOT NULL COMMENT 'Commented by',
  `comment` text NOT NULL COMMENT 'Commented text',
  `mark_as_private` int NOT NULL COMMENT 'private mark to comment',
  `post_date` datetime NOT NULL COMMENT 'Post date',
  `post_ip` varchar(15) NOT NULL COMMENT 'Post ip',
  `status` int NOT NULL COMMENT 'Status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_bulletin_tags`
--

CREATE TABLE `tbl_bulletin_tags` (
  `tag_id` int NOT NULL COMMENT 'Tag id',
  `title` varchar(150) NOT NULL COMMENT 'Title',
  `post_date` datetime NOT NULL COMMENT 'Post date',
  `update_date` datetime NOT NULL COMMENT 'Updated date',
  `status` int NOT NULL COMMENT 'Status',
  `created_by` int NOT NULL COMMENT 'Created by',
  `post_ip` varchar(15) NOT NULL COMMENT 'Post ip'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_bulletin_tags_mapping`
--

CREATE TABLE `tbl_bulletin_tags_mapping` (
  `bulletin_id` int NOT NULL COMMENT 'Bulletin id',
  `tag_id` int NOT NULL COMMENT 'Tag id',
  `post_ip` varchar(15) NOT NULL COMMENT 'Post ip',
  `created_on` datetime NOT NULL COMMENT 'Created on date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_bulletin_views`
--

CREATE TABLE `tbl_bulletin_views` (
  `bulletin_id` int NOT NULL COMMENT 'Bulletin id',
  `user_id` int NOT NULL COMMENT 'User id',
  `post_date` datetime NOT NULL COMMENT 'Post date',
  `post_ip` varchar(15) NOT NULL COMMENT 'Post ip'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_chat_broadcast_messages`
--

CREATE TABLE `tbl_chat_broadcast_messages` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `broadcast_id` int UNSIGNED NOT NULL,
  `message` text NOT NULL,
  `sent` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_chat_groups`
--

CREATE TABLE `tbl_chat_groups` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `last_activity` int UNSIGNED NOT NULL,
  `created_by` int UNSIGNED NOT NULL,
  `type` tinyint UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_chat_group_messages`
--

CREATE TABLE `tbl_chat_group_messages` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `chat_group_id` int UNSIGNED NOT NULL,
  `message` text NOT NULL,
  `sent` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_chat_group_users`
--

CREATE TABLE `tbl_chat_group_users` (
  `user_id` int UNSIGNED NOT NULL,
  `chat_group_id` int UNSIGNED NOT NULL,
  `last_activity` int UNSIGNED NOT NULL,
  `chat_status` int DEFAULT '0' COMMENT '1 for LEFT; 2 for REMOVED; 3 for MUTED;'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_chat_messages`
--

CREATE TABLE `tbl_chat_messages` (
  `id` int UNSIGNED NOT NULL,
  `from` int UNSIGNED NOT NULL,
  `to` int UNSIGNED NOT NULL,
  `message` text NOT NULL,
  `sent` int UNSIGNED NOT NULL DEFAULT '0',
  `token` varchar(100) NOT NULL,
  `read` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `direction` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `group_read` int NOT NULL DEFAULT '0',
  `leave_group` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_chat_status`
--

CREATE TABLE `tbl_chat_status` (
  `user_id` int UNSIGNED NOT NULL COMMENT 'User ID',
  `messages` varchar(255) DEFAULT NULL COMMENT 'User Status Messages',
  `status` enum('online','offline','away','busy','invisible') NOT NULL COMMENT 'User Login Status',
  `last_activity` int UNSIGNED NOT NULL COMMENT 'User Last Activity Time'
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_clients`
--

CREATE TABLE `tbl_clients` (
  `id` int NOT NULL,
  `client_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `client_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `business_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `poc_name` varchar(255) DEFAULT NULL,
  `poc_email` varchar(255) DEFAULT NULL,
  `poc_phone_no` varchar(255) DEFAULT NULL,
  `status` tinyint(1) DEFAULT '1',
  `created_date` date NOT NULL,
  `update_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_client_summary_report`
--

CREATE TABLE `tbl_client_summary_report` (
  `report_id` int NOT NULL,
  `group_name` varchar(100) DEFAULT NULL,
  `user_name` varchar(100) DEFAULT NULL,
  `summary` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `file_name` varchar(255) NOT NULL,
  `post_date` datetime NOT NULL,
  `save_date` date DEFAULT NULL,
  `stage` varchar(100) DEFAULT NULL,
  `client_mood` varchar(100) DEFAULT NULL,
  `live_issues` varchar(100) DEFAULT NULL,
  `dev_issues` varchar(100) DEFAULT NULL,
  `resource` varchar(100) DEFAULT NULL,
  `dev` varchar(255) DEFAULT NULL,
  `test` varchar(255) DEFAULT NULL,
  `issues` varchar(1000) DEFAULT NULL,
  `risks` text,
  `pm` varchar(255) DEFAULT NULL,
  `remaining_tail` varchar(50) DEFAULT NULL,
  `group_id` bigint DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `latest` enum('0','1') NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_cms`
--

CREATE TABLE `tbl_cms` (
  `id` int NOT NULL,
  `page_id` int NOT NULL COMMENT 'Page id',
  `admin_id` int NOT NULL COMMENT 'Admin id - who modified',
  `identifier` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Page Identifier',
  `title` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Page title',
  `seo_url` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Page SEO url',
  `meta_keywords` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Page meta keywords',
  `meta_description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Page meta description',
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Page content',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Page active used for internal action - 0=Inactive/1=Active',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Active/Inactive status - 0=Inactive/1=Active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_comments`
--

CREATE TABLE `tbl_comments` (
  `comment_id` bigint NOT NULL,
  `parent_id` int NOT NULL,
  `depth` int NOT NULL,
  `activity_id` bigint NOT NULL COMMENT 'Store activity ID',
  `company_id` int UNSIGNED NOT NULL COMMENT 'Store user''s company ID',
  `user_id` int NOT NULL COMMENT 'Store user''s ID',
  `comment` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store users comments',
  `like_status` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store like/unlike status',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store users'' IP address',
  `status` int NOT NULL DEFAULT '1' COMMENT '1 - Active, 0 - Deleted, 2 - Deleted with message',
  `attach_flag` enum('0','1') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '0',
  `activity_severity` int NOT NULL DEFAULT '0',
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Triggers `tbl_comments`
--
DELIMITER $$
CREATE TRIGGER `comment_search_delete` AFTER DELETE ON `tbl_comments` FOR EACH ROW BEGIN
	DELETE FROM `tbl_search` WHERE `ref_id` = OLD.`comment_id` AND `stype` = '9';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `comment_search_update` BEFORE UPDATE ON `tbl_comments` FOR EACH ROW BEGIN   
	IF( NEW.`status` = 1 AND OLD.`search_status` = 1 ) THEN
		SET NEW.`search_status` = 2;
	ELSEIF ( NEW.`status` = 0 ) THEN 
		SET NEW.`search_status` = 0;
		DELETE FROM `tbl_search` WHERE `ref_id` = NEW.`comment_id` AND `stype` = '9'; 
	END IF;		 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_comment_likes`
--

CREATE TABLE `tbl_comment_likes` (
  `comment_id` int UNSIGNED NOT NULL DEFAULT '0',
  `activity_id` int UNSIGNED NOT NULL DEFAULT '0',
  `user_id` int UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_comment_privacy`
--

CREATE TABLE `tbl_comment_privacy` (
  `id` int NOT NULL,
  `comment_id` int NOT NULL COMMENT 'Comment ID',
  `group_id` int NOT NULL DEFAULT '0' COMMENT 'Groip ID',
  `project_id` int NOT NULL DEFAULT '0' COMMENT 'Project ID',
  `type` enum('TASK','ISSUE','RT') NOT NULL COMMENT 'TASK, ISSUE, RT',
  `type_id` int NOT NULL COMMENT 'TASK ID, ISSUE ID, RT ID',
  `privacy` text NOT NULL COMMENT 'Specific people or role'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_companies`
--

CREATE TABLE `tbl_companies` (
  `company_id` int NOT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `domain_name` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `theme` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `is_private` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Set company as a private network',
  `status` tinyint(1) NOT NULL,
  `post_ip` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_contents`
--

CREATE TABLE `tbl_contents` (
  `content_id` int NOT NULL COMMENT 'Page id',
  `type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `page_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store name to display in the menu',
  `page_sef_name` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store name to display in the url',
  `status` int NOT NULL DEFAULT '0' COMMENT 'Store page status',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store post date',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store last update date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store users'' IP address',
  `static_flag` int NOT NULL DEFAULT '0' COMMENT 'Store static block',
  `block_content` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store block name'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_contents_desc`
--

CREATE TABLE `tbl_contents_desc` (
  `content_desc_id` int NOT NULL COMMENT 'Store content description ID',
  `content_id` int NOT NULL COMMENT 'Store content ID',
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store page content',
  `language_id` int NOT NULL COMMENT 'Store language ID',
  `page_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store page title',
  `meta_keywords` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store meta keywords',
  `meta_description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store meta description'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_countries`
--

CREATE TABLE `tbl_countries` (
  `country_id` int NOT NULL,
  `country_code` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Country short code',
  `flag_icon` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT '' COMMENT 'Flag Icon path',
  `status` int NOT NULL DEFAULT '0',
  `post_date` datetime DEFAULT '0000-00-00 00:00:00',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `update_date` datetime DEFAULT '0000-00-00 00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_countries_desc`
--

CREATE TABLE `tbl_countries_desc` (
  `country_id` int NOT NULL,
  `country_name` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Country name',
  `language_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_discussion`
--

CREATE TABLE `tbl_discussion` (
  `id` int NOT NULL COMMENT 'store auto incremented ID',
  `type` enum('G','P') NOT NULL COMMENT 'G:Group,P:Project',
  `type_id` int NOT NULL COMMENT 'stoe group_id or project_id',
  `owner_id` int NOT NULL COMMENT 'store_owner_id',
  `activity_id` bigint NOT NULL COMMENT 'store activity_id',
  `title` varchar(255) NOT NULL COMMENT 'store discussion title',
  `description` longtext NOT NULL COMMENT 'store discussion description',
  `reference_no` varchar(50) NOT NULL COMMENT 'store reference no',
  `post_date` datetime NOT NULL COMMENT 'store post date in which discussion was posted',
  `update_date` datetime NOT NULL COMMENT 'store post date in which discussion was updated',
  `post_ip` varchar(15) NOT NULL COMMENT 'store post_ip',
  `search_status` tinyint NOT NULL COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done',
  `status` tinyint NOT NULL COMMENT 'store status active as 1 and inactive as 0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_document_folder`
--

CREATE TABLE `tbl_document_folder` (
  `activity_id` int NOT NULL,
  `folder_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_document_history`
--

CREATE TABLE `tbl_document_history` (
  `document_id` int NOT NULL COMMENT 'Document ID',
  `file_sys_name` varchar(255) NOT NULL COMMENT 'System File Name',
  `file_ori_name` varchar(255) NOT NULL COMMENT 'Original File Name',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status` tinyint(1) NOT NULL COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_ehs`
--

CREATE TABLE `tbl_ehs` (
  `id` int NOT NULL,
  `project_id` int NOT NULL DEFAULT '0',
  `group_id` int NOT NULL DEFAULT '0',
  `user_id` int NOT NULL,
  `activity_id` int NOT NULL DEFAULT '0',
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `timeline` varchar(255) NOT NULL,
  `timeline_year` varchar(255) NOT NULL,
  `scope` varchar(100) NOT NULL,
  `scope_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `financials` varchar(100) NOT NULL,
  `financials_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `resource` varchar(100) NOT NULL,
  `resource_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `product_quality` varchar(100) NOT NULL,
  `product_quality_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `risk` varchar(100) NOT NULL,
  `risk_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `customer` varchar(100) NOT NULL,
  `customer_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `schedule` varchar(100) NOT NULL,
  `schedule_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `overall` varchar(100) NOT NULL,
  `overall_score` int NOT NULL DEFAULT '0',
  `project_risk_level` varchar(100) NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime DEFAULT NULL,
  `reject_details` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `ehs_status_id` tinyint NOT NULL DEFAULT '1',
  `status` tinyint NOT NULL COMMENT 'status(Active/Inactive)',
  `isvalid` enum('0','1') NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_ehs_status`
--

CREATE TABLE `tbl_ehs_status` (
  `status_id` int NOT NULL,
  `status_name` varchar(100) NOT NULL,
  `color_code` varchar(15) NOT NULL,
  `status_order` int NOT NULL,
  `status_type` mediumint NOT NULL COMMENT '1 => Open, 2 => Closed',
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `update_date` datetime NOT NULL,
  `status` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_ehs_status_old`
--

CREATE TABLE `tbl_ehs_status_old` (
  `status_id` int NOT NULL,
  `status_name` varchar(100) NOT NULL,
  `color_code` varchar(15) NOT NULL,
  `status_order` int NOT NULL,
  `status_type` mediumint NOT NULL COMMENT '1 => Open, 2 => Closed',
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `update_date` datetime NOT NULL,
  `status` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_estimation_assumption_map`
--

CREATE TABLE `tbl_estimation_assumption_map` (
  `id` int NOT NULL,
  `el_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `hours` int NOT NULL,
  `posted_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` datetime NOT NULL,
  `status` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_estimation_asumption`
--

CREATE TABLE `tbl_estimation_asumption` (
  `id` int NOT NULL,
  `estimation_id` int NOT NULL,
  `assumption` varchar(255) NOT NULL,
  `post_date` datetime NOT NULL,
  `updated_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_estimation_complexity`
--

CREATE TABLE `tbl_estimation_complexity` (
  `id` int NOT NULL,
  `level` int NOT NULL,
  `optimistic_level_value` int NOT NULL,
  `pessimistic_level_value` int NOT NULL,
  `post_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_estimation_deliverables`
--

CREATE TABLE `tbl_estimation_deliverables` (
  `id` int NOT NULL,
  `estimation_id` int NOT NULL,
  `deliverables` varchar(255) NOT NULL,
  `post_date` datetime NOT NULL,
  `updated_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_estimation_risks`
--

CREATE TABLE `tbl_estimation_risks` (
  `id` int NOT NULL,
  `estimation_id` int NOT NULL,
  `risks` varchar(255) NOT NULL,
  `post_date` datetime NOT NULL,
  `updated_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_estimation_summary`
--

CREATE TABLE `tbl_estimation_summary` (
  `id` int NOT NULL,
  `estimation_id` int NOT NULL,
  `dev_design` varchar(255) NOT NULL,
  `qa` varchar(255) NOT NULL,
  `effort` varchar(255) NOT NULL,
  `contingency` varchar(255) NOT NULL,
  `uat` varchar(255) NOT NULL,
  `total` varchar(255) NOT NULL,
  `support` varchar(255) NOT NULL,
  `grand_total` varchar(255) NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_events`
--

CREATE TABLE `tbl_events` (
  `event_id` int NOT NULL,
  `user_id` int NOT NULL,
  `company_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `group_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `all_day` tinyint NOT NULL DEFAULT '0',
  `is_repeat` tinyint NOT NULL DEFAULT '0',
  `has_attachment` tinyint NOT NULL DEFAULT '0',
  `repeat_type` varchar(10) NOT NULL,
  `no_of_occurrence` int NOT NULL,
  `last_occurrence_date` datetime NOT NULL,
  `repeat_settings` text NOT NULL,
  `privacy` tinyint NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `post_ip` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_event_dates`
--

CREATE TABLE `tbl_event_dates` (
  `id` int NOT NULL,
  `event_id` int NOT NULL,
  `group_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `actual_event` int NOT NULL DEFAULT '0',
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Triggers `tbl_event_dates`
--
DELIMITER $$
CREATE TRIGGER `event_dates_delete` AFTER DELETE ON `tbl_event_dates` FOR EACH ROW BEGIN  
    UPDATE tbl_activities SET STATUS = 0 WHERE activity_id = old.activity_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_event_users`
--

CREATE TABLE `tbl_event_users` (
  `event_id` bigint DEFAULT NULL COMMENT 'Store event ID [FK]',
  `user_id` int DEFAULT NULL COMMENT 'Store user id [FK]',
  `access_type` enum('NORMAL','ADMIN') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT 'NORMAL' COMMENT 'Store access type; NORMAL = members, ADMIN = admin;',
  `hidden_admin` int NOT NULL DEFAULT '0',
  `request_status` enum('A','R','I') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store request status; A = approve, R= Request, I=Invited',
  `rsvp` enum('A','M','N') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store RSVP status; A=Attending, M=Maybe, N=Not attending',
  `post_date` datetime DEFAULT '0000-00-00 00:00:00' COMMENT 'Store request date',
  `update_date` datetime DEFAULT '0000-00-00 00:00:00' COMMENT 'Store last update date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store users IP address',
  `manager_flag` int NOT NULL DEFAULT '0',
  `group_id` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_fetched_mails`
--

CREATE TABLE `tbl_fetched_mails` (
  `mail_id` int UNSIGNED NOT NULL COMMENT 'Auto ID',
  `message_id` int NOT NULL COMMENT 'store the message id of the email',
  `subject` varchar(500) NOT NULL COMMENT 'Subject of the email',
  `mail_date` datetime NOT NULL COMMENT 'Store mail date time',
  `from_address` varchar(255) NOT NULL COMMENT 'Sender''s address',
  `to_address` text NOT NULL COMMENT 'Receipient Address',
  `cc_address` text NOT NULL COMMENT 'CC Address',
  `raw_header` longtext NOT NULL COMMENT 'Message raw header',
  `text_message` longtext NOT NULL COMMENT 'Store Raw header',
  `html_message` longtext NOT NULL COMMENT 'Store the html of the email',
  `read_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Store 1 for read, 0 for unread',
  `read_time` datetime NOT NULL COMMENT 'Store date time of the mail read time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_fetched_mails_attachments`
--

CREATE TABLE `tbl_fetched_mails_attachments` (
  `attachment_id` int NOT NULL COMMENT 'primary key',
  `mail_id` int NOT NULL COMMENT 'store foreign key of table tbl_fetched_mails',
  `disposition` varchar(20) NOT NULL COMMENT 'store disposition value',
  `inline_content_id` varchar(255) NOT NULL COMMENT 'store attachment mime type',
  `original_file_name` varchar(255) NOT NULL COMMENT 'store original file name',
  `size_in_bytes` int NOT NULL COMMENT 'store attachment size in bytes',
  `file_name` varchar(255) NOT NULL COMMENT 'store generated file name'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_files`
--

CREATE TABLE `tbl_files` (
  `file_id` bigint NOT NULL,
  `user_id` int NOT NULL,
  `activity_id` bigint DEFAULT NULL,
  `group_id` bigint DEFAULT '0',
  `event_id` bigint DEFAULT '0',
  `company_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Store user''s company ID',
  `project_id` bigint NOT NULL DEFAULT '0',
  `caption` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `file_key` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store file key for the OnlyOffice',
  `file_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `ori_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'save original file name',
  `file_size` double(10,2) DEFAULT NULL COMMENT 'save file size',
  `tagged` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `privacy` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_folder`
--

CREATE TABLE `tbl_folder` (
  `folder_id` int UNSIGNED NOT NULL COMMENT 'Folder ID',
  `parent_id` int NOT NULL DEFAULT '0' COMMENT 'Parent ID',
  `folder_name` varchar(255) NOT NULL COMMENT 'Folder Name',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(30) NOT NULL COMMENT 'IP Address',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_folder_mapping`
--

CREATE TABLE `tbl_folder_mapping` (
  `map_id` bigint UNSIGNED NOT NULL,
  `folder_id` int NOT NULL,
  `group_id` int NOT NULL,
  `project_id` int NOT NULL,
  `user_id` int NOT NULL,
  `status` int NOT NULL DEFAULT '1',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'store 1 for deleted'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_follow`
--

CREATE TABLE `tbl_follow` (
  `follow_id` int NOT NULL,
  `user_id` int NOT NULL,
  `follow_type` int NOT NULL COMMENT 'Quest=1, Event=2, Group=3, Profile=4',
  `follow_type_id` int NOT NULL,
  `follow_ip` varchar(255) NOT NULL,
  `status` int NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Follow quest, group, events and profile';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_form_fields`
--

CREATE TABLE `tbl_form_fields` (
  `element_id` int UNSIGNED NOT NULL COMMENT 'Store Element ID',
  `element_type` enum('IC','GT','ET','PT') NOT NULL COMMENT 'Store Element Type (IC => Idea Category, GT => Group Type, ET => Event Type, PT => Project Type)',
  `element_type_id` int UNSIGNED NOT NULL COMMENT 'Store Element Type ID',
  `label` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store Field Label',
  `field_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store Field Name',
  `field_value` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store Field Value',
  `display` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Field Display ',
  `mandatory` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'process field mandatory',
  `mandatoryform` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'form field mandatory',
  `formvisible` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'visible on form create',
  `processvisible` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'visible on process cr form',
  `field_type` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Field Type',
  `order` int NOT NULL COMMENT 'Store Field Order;',
  `err_msg` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store error message;',
  `help_text` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store additional help text;',
  `prefilled` varchar(50) NOT NULL,
  `category_flag` int NOT NULL DEFAULT '0' COMMENT '0=acorn, 1=quest',
  `targettype` varchar(50) NOT NULL COMMENT 'e.g. title, desc',
  `prepopulate` int NOT NULL DEFAULT '0',
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_form_fields_value`
--

CREATE TABLE `tbl_form_fields_value` (
  `element_id` int UNSIGNED NOT NULL COMMENT 'Element ID',
  `type_id` int UNSIGNED NOT NULL COMMENT 'Type ID (ex : Question ID for IC, Group ID for GT, Document ID for PT etc)',
  `element_value` mediumtext NOT NULL COMMENT 'Element Value',
  `element_file_type` varchar(50) NOT NULL,
  `post_date` datetime NOT NULL,
  `visible_on` varchar(50) NOT NULL COMMENT 'e.g.: form, process'
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_genders`
--

CREATE TABLE `tbl_genders` (
  `gender_id` int NOT NULL,
  `status` int NOT NULL DEFAULT '0',
  `post_date` datetime DEFAULT '0000-00-00 00:00:00',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `update_date` datetime DEFAULT '0000-00-00 00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_genders_desc`
--

CREATE TABLE `tbl_genders_desc` (
  `gender_id` int NOT NULL,
  `gender_name` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Gender name',
  `language_id` int NOT NULL COMMENT 'Language ID'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_global_settings`
--

CREATE TABLE `tbl_global_settings` (
  `id` int NOT NULL,
  `parameter` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store global setting parameter',
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store global setting parameter description',
  `value` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store global setting value'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_groups`
--

CREATE TABLE `tbl_groups` (
  `group_id` bigint NOT NULL,
  `owner_id` int NOT NULL,
  `activity_id` bigint NOT NULL,
  `company_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Company ID',
  `language_id` int NOT NULL,
  `group_type_id` int NOT NULL,
  `subscription_id` int NOT NULL COMMENT 'subscription id',
  `name` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `short_url` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'store short url ',
  `group_photo` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `group_photo_medium` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `group_photo_small` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `settings` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Stor group''s settings in serialized format',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `type` enum('o','c','h') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'o' COMMENT 'sete the type of the group o= open, c= close, h= hidden',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` int NOT NULL DEFAULT '1',
  `group_status` int NOT NULL DEFAULT '1',
  `group_privacy` int DEFAULT '1' COMMENT 'group privacy setting default open to everyone',
  `request_join` int DEFAULT '0' COMMENT 'Members need to request to join 1 - yes, 0- no , default no',
  `email_notification` tinyint UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Email Notification for a Group',
  `archive` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Archive group',
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_group_domain`
--

CREATE TABLE `tbl_group_domain` (
  `id` int UNSIGNED NOT NULL,
  `group_id` int DEFAULT NULL COMMENT 'FK - Group ID',
  `domain` varchar(100) DEFAULT NULL COMMENT 'Requestor''s email domainname'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_group_files`
--

CREATE TABLE `tbl_group_files` (
  `file_id` int NOT NULL,
  `type` enum('TOPIC','EVENT') DEFAULT NULL COMMENT 'type is topic',
  `type_id` int NOT NULL COMMENT 'type_id is topic_id',
  `ori_file_name` varchar(100) NOT NULL COMMENT 'stores original file name',
  `sys_file_name` varchar(100) NOT NULL COMMENT 'stores system file name',
  `file_size` double(10,2) NOT NULL COMMENT 'stores size of file',
  `file_type` enum('PHOTO','FILE') DEFAULT NULL COMMENT 'stores file type is photo or file',
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `status` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_group_projects`
--

CREATE TABLE `tbl_group_projects` (
  `group_id` int NOT NULL,
  `project_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_group_release`
--

CREATE TABLE `tbl_group_release` (
  `release_id` int NOT NULL COMMENT 'release_id',
  `parent_id` int NOT NULL COMMENT 'sub release id',
  `title` varchar(100) NOT NULL COMMENT 'release title',
  `release_note` longtext NOT NULL COMMENT 'release note',
  `release_owner` int NOT NULL COMMENT 'release owner',
  `group_id` int NOT NULL COMMENT 'group id',
  `release_status_id` int NOT NULL COMMENT 'release status',
  `rag` varchar(50) NOT NULL COMMENT 'RAG(Red, Amber, Green)',
  `release_date` datetime NOT NULL COMMENT 'release date',
  `post_date` datetime NOT NULL COMMENT 'post date of release',
  `update_date` datetime NOT NULL COMMENT 'updated date if release updated',
  `status` tinyint(1) NOT NULL COMMENT 'release status active or inactive',
  `post_ip` varchar(15) NOT NULL COMMENT 'post ip'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_group_role`
--

CREATE TABLE `tbl_group_role` (
  `group_id` int NOT NULL,
  `role_id` int NOT NULL,
  `access_permission` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_group_task_income_var`
--

CREATE TABLE `tbl_group_task_income_var` (
  `id` int NOT NULL,
  `group_id` int NOT NULL,
  `yearmonth` varchar(10) NOT NULL,
  `incomevar` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_group_topics`
--

CREATE TABLE `tbl_group_topics` (
  `group_topic_id` bigint NOT NULL,
  `user_id` int NOT NULL,
  `group_id` bigint NOT NULL,
  `activity_id` bigint NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store topic title',
  `description` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store topic description',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `reference_no` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT '"reference no"',
  `status` int NOT NULL,
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Triggers `tbl_group_topics`
--
DELIMITER $$
CREATE TRIGGER `group_topic_search_delete` AFTER DELETE ON `tbl_group_topics` FOR EACH ROW BEGIN
	DECLARE `activityID` INTEGER;
	
	SELECT `activity_id` INTO `activityID` FROM `tbl_search` WHERE `ref_id` = OLD.`group_topic_id` AND `stype` = '7';
	DELETE FROM `tbl_search` WHERE `activity_id` = `activityID` AND `stype` IN (7,9);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `group_topic_search_update` BEFORE UPDATE ON `tbl_group_topics` FOR EACH ROW BEGIN   
	DECLARE `activityID` INTEGER;
	
	IF( NEW.`status` = 1 AND OLD.`search_status` = 1 ) THEN
		SET NEW.`search_status` = 2;
	ELSEIF ( NEW.`status` = 0 ) THEN 
		SET NEW.`search_status` = 0;
		SELECT `activity_id` INTO `activityID` FROM `tbl_search` WHERE `ref_id` = NEW.`group_topic_id` AND `stype` = '7';
	   	DELETE FROM `tbl_search` WHERE `activity_id` = `activityID` AND `stype` IN (7,9); 
	END IF;		 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_group_types`
--

CREATE TABLE `tbl_group_types` (
  `group_type_id` int NOT NULL,
  `parent_id` int NOT NULL DEFAULT '0' COMMENT 'Store group type name',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `update_date` datetime DEFAULT '0000-00-00 00:00:00',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_group_types_desc`
--

CREATE TABLE `tbl_group_types_desc` (
  `group_type_id` int NOT NULL,
  `language_id` int NOT NULL,
  `group_type_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store group type name'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_group_users`
--

CREATE TABLE `tbl_group_users` (
  `group_id` bigint DEFAULT NULL COMMENT 'Store group ID [FK]',
  `user_id` int DEFAULT NULL COMMENT 'Store user id [FK]',
  `role_id` int NOT NULL DEFAULT '0',
  `access_type` enum('NORMAL','ADMIN') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT 'NORMAL' COMMENT 'Store access type; NORMAL = members, ADMIN = admin;',
  `request_status` enum('A','R','I') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store request status; A = approve, R= Request, I=Invited',
  `post_date` datetime DEFAULT '0000-00-00 00:00:00' COMMENT 'Store request date',
  `update_date` datetime DEFAULT '0000-00-00 00:00:00' COMMENT 'Store last update date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store users'' IP address'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Triggers `tbl_group_users`
--
DELIMITER $$
CREATE TRIGGER `group_user_delete` AFTER DELETE ON `tbl_group_users` FOR EACH ROW BEGIN
	if(old.request_status = 'A') then
	   update tbl_site_search set info1 = info1 -1 where ref_id = old.group_id
	   and stype = '3';	   
	end if;
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `group_user_insert` AFTER INSERT ON `tbl_group_users` FOR EACH ROW BEGIN
	IF(NEW.request_status = 'A') THEN
	   UPDATE tbl_site_search SET info1 = info1 + 1 WHERE ref_id = NEW.group_id
	   AND stype = '3';	   
	END IF;
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `group_user_update` AFTER UPDATE ON `tbl_group_users` FOR EACH ROW BEGIN
	IF(new.request_status = 'A' and old.request_status <> 'A') THEN
	   UPDATE tbl_site_search SET info1 = info1+1 WHERE ref_id = new.group_id
	   AND stype = '3';
	ELSEIF(old.request_status = 'A' AND new.request_status <> 'A') THEN	
	   UPDATE tbl_site_search SET info1 = info1 -1 WHERE ref_id = new.group_id
	   AND stype = '3';   
	END IF;
    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_homepage`
--

CREATE TABLE `tbl_homepage` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `source` mediumtext NOT NULL,
  `url` mediumtext NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `post_ip` varchar(100) NOT NULL,
  `status` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_ims`
--

CREATE TABLE `tbl_ims` (
  `im_id` int NOT NULL COMMENT 'IM id',
  `status` int NOT NULL DEFAULT '0',
  `post_date` datetime DEFAULT '0000-00-00 00:00:00',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `update_date` datetime DEFAULT '0000-00-00 00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_ims_desc`
--

CREATE TABLE `tbl_ims_desc` (
  `im_id` int NOT NULL,
  `im_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'IM Name',
  `im_icon` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `language_id` int NOT NULL COMMENT 'Language ID'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_interests`
--

CREATE TABLE `tbl_interests` (
  `interest_id` int NOT NULL COMMENT 'Store interest ID',
  `suggestion_status` int NOT NULL DEFAULT '0' COMMENT 'Set one if the interest is stored as users'' suggestions',
  `status` int NOT NULL DEFAULT '0' COMMENT 'Store display status',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store post date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store users'' IP address',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store last update date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_interests_desc`
--

CREATE TABLE `tbl_interests_desc` (
  `interest_id` int NOT NULL COMMENT 'Store interest ID',
  `interest_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store interest name',
  `language_id` int NOT NULL COMMENT 'Store language ID'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_ipfilter`
--

CREATE TABLE `tbl_ipfilter` (
  `ip_id` int NOT NULL,
  `ip_type` int NOT NULL,
  `type_id` int NOT NULL,
  `status` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_ipignorelist`
--

CREATE TABLE `tbl_ipignorelist` (
  `ignore_id` int NOT NULL,
  `ignore_type` int NOT NULL COMMENT 'user=1,group=2,event=3,company=4',
  `ignore_type_id` int NOT NULL COMMENT 'e.g. user_id or group_id',
  `status` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_iplist`
--

CREATE TABLE `tbl_iplist` (
  `ip_id` int NOT NULL,
  `ip` varchar(255) NOT NULL,
  `type_status` int NOT NULL COMMENT '1:everyone, 2:user, 3:company, 4:group',
  `status` int NOT NULL,
  `netname` text,
  `descr` text,
  `is_internal` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Internal IP for ageas network',
  `theme_option` enum('default','ageuk') NOT NULL DEFAULT 'default' COMMENT '''default'', ''ageuk'''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_jobs`
--

CREATE TABLE `tbl_jobs` (
  `job_id` int NOT NULL,
  `job_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `level_id` int NOT NULL,
  `admin_access` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `post_ip` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_languages`
--

CREATE TABLE `tbl_languages` (
  `language_id` int NOT NULL,
  `language_name` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Language name',
  `language_code` varchar(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Language short code',
  `flag_icon` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Flag Icon path',
  `default` int NOT NULL DEFAULT '0' COMMENT 'Set as default language',
  `status` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_lineitem_assumption`
--

CREATE TABLE `tbl_lineitem_assumption` (
  `id` int NOT NULL,
  `item_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `hours` int NOT NULL,
  `posted_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` datetime NOT NULL,
  `status` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_lineitem_category`
--

CREATE TABLE `tbl_lineitem_category` (
  `category_id` int NOT NULL,
  `category_name` varchar(255) NOT NULL,
  `status` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_lineitem_priority`
--

CREATE TABLE `tbl_lineitem_priority` (
  `priority_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_lineitem_techstack`
--

CREATE TABLE `tbl_lineitem_techstack` (
  `techstack_id` int NOT NULL,
  `techstack_name` varchar(255) NOT NULL,
  `post_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `status` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_locations`
--

CREATE TABLE `tbl_locations` (
  `location_id` int NOT NULL,
  `country_id` int NOT NULL COMMENT 'Country id',
  `status` int NOT NULL DEFAULT '0',
  `verified` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_locations_desc`
--

CREATE TABLE `tbl_locations_desc` (
  `location_id` int NOT NULL,
  `language_id` int NOT NULL COMMENT 'Language ID',
  `country_id` int NOT NULL COMMENT 'Country id',
  `city` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'City name',
  `status` int NOT NULL DEFAULT '0',
  `verified` int NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_login_attempts`
--

CREATE TABLE `tbl_login_attempts` (
  `user_id` int NOT NULL COMMENT 'FK to users table',
  `user_type` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'admin/member/other user',
  `attempt_counter` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'wrong attempt increases counter by 1',
  `post_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'attempt date and time',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'user''s ip'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci COMMENT='log user''s login attempt';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_login_history`
--

CREATE TABLE `tbl_login_history` (
  `session_id` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store session ID',
  `user_id` int UNSIGNED NOT NULL COMMENT 'Store user ID',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '0.0.0.0' COMMENT 'Store post IP',
  `browser` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store browsers'' details',
  `ref_url` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store ref URL',
  `login_time` datetime DEFAULT NULL COMMENT 'Store login time',
  `logout_time` datetime DEFAULT NULL COMMENT 'Store logout time',
  `browser_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'store browser name',
  `browser_version` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'store browser version',
  `platform_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'store platform name',
  `platform_version` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'store platform version',
  `platform_type` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'store platform type'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_log_comment_mail`
--

CREATE TABLE `tbl_log_comment_mail` (
  `id` int NOT NULL COMMENT 'auto incremented id',
  `log_mail_id` int NOT NULL COMMENT 'mail id of `tbl_log_mails`',
  `type` text NOT NULL COMMENT 'c=> comment, th=> ticket thread',
  `type_id` int NOT NULL COMMENT 'comment_id, thread_id',
  `is_sent` tinyint NOT NULL COMMENT 'mails send => 1,mail send failed=>0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_log_external_mails`
--

CREATE TABLE `tbl_log_external_mails` (
  `id` bigint NOT NULL COMMENT 'PK',
  `mail_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store mail code',
  `sender_id` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store sender''s email ID',
  `receipient_id` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store recepient''s email ID',
  `subject` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store Subject Line',
  `body` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store message Body',
  `send_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store Send date',
  `is_sent` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Store send mail status',
  `log_message` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Send message log information'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_log_mails`
--

CREATE TABLE `tbl_log_mails` (
  `id` bigint NOT NULL COMMENT 'mail send id',
  `mail_code` varchar(50) NOT NULL COMMENT 'store mail code',
  `sender_email` varchar(100) NOT NULL COMMENT 'store sender email Id',
  `recipient_email` varchar(100) NOT NULL COMMENT 'store recipient email Id',
  `reply_to_email` varchar(200) NOT NULL COMMENT 'store reply to email Id',
  `cc_email` varchar(500) NOT NULL COMMENT 'store CC email Id with comma separator',
  `bcc_email` varchar(500) NOT NULL COMMENT 'store BCC email Id with comma separator',
  `embedded_attachment` longtext NOT NULL COMMENT 'store embedded attachment in JSON',
  `attachment_ids` varchar(500) NOT NULL COMMENT 'store attachment ids in JSON',
  `subject` text NOT NULL COMMENT 'mail subject',
  `body` longtext NOT NULL COMMENT 'mail body',
  `post_date` datetime NOT NULL COMMENT 'date on which data was inserted in this table',
  `send_date` datetime DEFAULT NULL COMMENT 'date on which is_sent flag changes to ''1''',
  `is_sent` tinyint NOT NULL DEFAULT '0' COMMENT 'store send mail status (1 => Success, 2 => Custom, 3=> Failure)',
  `log_message` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'store message log information'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_mails`
--

CREATE TABLE `tbl_mails` (
  `mail_id` int NOT NULL,
  `mail_code` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Will be used to get the email content',
  `mail_type` enum('I','E') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'E' COMMENT 'Store mail type',
  `mail_parameters` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Comma separated parameters',
  `description` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Will be used for future reference',
  `cc_list` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Mail CC List',
  `bcc_list` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Mail BCC List',
  `status` int NOT NULL DEFAULT '0' COMMENT 'Used to check the display status',
  `chk_login` int NOT NULL DEFAULT '0' COMMENT 'Store check login status. 1[if need logout], 0[if need not check login]',
  `reply_separator` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used for message separator'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_mails_backup`
--

CREATE TABLE `tbl_mails_backup` (
  `mail_id` int NOT NULL,
  `mail_code` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Will be used to get the email content',
  `mail_type` enum('I','E') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'E' COMMENT 'Store mail type',
  `mail_parameters` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Comma separated parameters',
  `description` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Will be used for future reference',
  `cc_list` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Mail CC List',
  `bcc_list` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Mail BCC List',
  `status` int NOT NULL DEFAULT '0' COMMENT 'Used to check the display status',
  `chk_login` int NOT NULL DEFAULT '0' COMMENT 'Store check login status. 1[if need logout], 0[if need not check login]',
  `reply_separator` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used for message separator'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_mails_desc`
--

CREATE TABLE `tbl_mails_desc` (
  `mail_content_id` int NOT NULL,
  `mail_id` int NOT NULL,
  `language_id` int NOT NULL,
  `subject` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Used to store mail subject',
  `body` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Used to store mail bcontent'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_mails_desc_live`
--

CREATE TABLE `tbl_mails_desc_live` (
  `mail_content_id` int NOT NULL,
  `mail_id` int NOT NULL,
  `language_id` int NOT NULL,
  `subject` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Used to store mail subject',
  `body` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Used to store mail bcontent'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_mails_live`
--

CREATE TABLE `tbl_mails_live` (
  `mail_id` int NOT NULL,
  `mail_code` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Will be used to get the email content',
  `mail_type` enum('I','E') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'E' COMMENT 'Store mail type',
  `mail_parameters` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Comma separated parameters',
  `description` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Will be used for future reference',
  `cc_list` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Mail CC List',
  `bcc_list` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Mail BCC List',
  `status` int NOT NULL DEFAULT '0' COMMENT 'Used to check the display status',
  `chk_login` int NOT NULL DEFAULT '0' COMMENT 'Store check login status. 1[if need logout], 0[if need not check login]',
  `reply_separator` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used for message separator'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_master_skills`
--

CREATE TABLE `tbl_master_skills` (
  `id` int NOT NULL,
  `name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `status` enum('1','0') NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_master_skills_back`
--

CREATE TABLE `tbl_master_skills_back` (
  `id` int NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `status` enum('1','0') NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_menu_settings`
--

CREATE TABLE `tbl_menu_settings` (
  `id` int NOT NULL COMMENT 'ID',
  `type` enum('Group','Project') NOT NULL COMMENT 'Group/Project',
  `position` enum('Top','Main','Settings') NOT NULL COMMENT 'Menu Position',
  `title` varchar(100) NOT NULL COMMENT 'Menu Title',
  `slug` varchar(100) NOT NULL COMMENT 'Menu Slug',
  `module` varchar(100) NOT NULL COMMENT 'Module',
  `action` varchar(100) NOT NULL COMMENT 'Action',
  `selected_action` varchar(255) NOT NULL COMMENT 'Selected Menu Action',
  `themes_exception` varchar(255) NOT NULL COMMENT 'Themes Exception',
  `menu_class` varchar(255) NOT NULL COMMENT 'Menu Class',
  `is_popup` tinyint NOT NULL DEFAULT '0' COMMENT 'Is Popup',
  `is_onclick_evt` tinyint NOT NULL DEFAULT '0' COMMENT 'Is Onclick Evt',
  `permission` tinyint NOT NULL DEFAULT '0' COMMENT 'For admin access (1 => Normal User , 2 => Admin & 4 => Owner)',
  `menu_order` int NOT NULL DEFAULT '0',
  `privacy_module` varchar(100) NOT NULL COMMENT 'Privacy Module',
  `privacy_section` varchar(100) NOT NULL COMMENT 'Privacy Section',
  `media_class` tinyint NOT NULL DEFAULT '0' COMMENT 'Open In Mobile',
  `mobile_off` tinyint NOT NULL DEFAULT '0',
  `add_link` tinyint NOT NULL DEFAULT '0' COMMENT 'Add Icon Exists',
  `add_link_module` varchar(100) NOT NULL COMMENT 'Add Module',
  `add_link_action` varchar(100) NOT NULL COMMENT 'Add Action',
  `add_data_fb_id` varchar(100) NOT NULL COMMENT 'Add Facebox Id',
  `extra_param` varchar(100) NOT NULL COMMENT 'extra parameter in json format',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT 'Status',
  `update_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_meta`
--

CREATE TABLE `tbl_meta` (
  `meta_tag_id` int NOT NULL COMMENT 'Auto inrement ',
  `module` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store module name',
  `action` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store action name',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store post date',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store update date',
  `status` int NOT NULL COMMENT 'Set ''1'' to display',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'store User''s IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_meta_desc`
--

CREATE TABLE `tbl_meta_desc` (
  `meta_tag_id` int NOT NULL COMMENT 'Store meta',
  `language_id` int NOT NULL DEFAULT '1' COMMENT 'Store language ID',
  `page_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store page title',
  `meta_keywords` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store meta keywords',
  `meta_desc` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store meta desc'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_notes`
--

CREATE TABLE `tbl_notes` (
  `note_id` int NOT NULL COMMENT 'Store note ID;',
  `user_id` int NOT NULL COMMENT 'Store user ID;',
  `project_id` int NOT NULL COMMENT 'Store Event ID;',
  `title` varchar(250) NOT NULL COMMENT 'Store note title;',
  `description` text NOT NULL COMMENT 'Store note description;',
  `submission_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store Submission date;'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_notifications`
--

CREATE TABLE `tbl_notifications` (
  `notification_id` bigint NOT NULL,
  `notified_by` int NOT NULL COMMENT 'Store user''s id',
  `notified_to` int NOT NULL COMMENT 'Store user''s id',
  `notification_type_id` int NOT NULL COMMENT 'Store notification type',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` enum('1','0') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '1',
  `notification_url` mediumtext CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Notification url in serilize format',
  `parameters_value` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'store serialize format of notification parameters'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_notification_settings`
--

CREATE TABLE `tbl_notification_settings` (
  `setting_id` int UNSIGNED NOT NULL COMMENT 'Notification Setting ID',
  `mail_code` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Notification Mail Code',
  `field_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Notification Field Name',
  `description` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Notification Description',
  `section` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Notification Section',
  `display_order` int UNSIGNED NOT NULL COMMENT 'Notification Display Order',
  `status` tinyint UNSIGNED NOT NULL COMMENT 'Notification Display Status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_notification_types`
--

CREATE TABLE `tbl_notification_types` (
  `notification_type_id` int NOT NULL,
  `notification_parameters` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Comma separated parameters',
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `status` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_notification_types_desc`
--

CREATE TABLE `tbl_notification_types_desc` (
  `notification_type_id` int NOT NULL,
  `language_id` int NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store notification description'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_onlyoffice_file_logs`
--

CREATE TABLE `tbl_onlyoffice_file_logs` (
  `file_id` bigint NOT NULL COMMENT 'Store file id, FK from tbl_files',
  `user_ids` varchar(255) NOT NULL COMMENT 'Store user ids involded in the document updates, refer tbl_users',
  `file_key` varchar(30) NOT NULL COMMENT 'Store file key used in OnlyOffice',
  `onlyoffice_url` varchar(255) NOT NULL COMMENT 'Store file URL for the OnlyOffice version ',
  `status` enum('0','1','2','3','4') NOT NULL COMMENT 'Store activity status; 0 => ''NotFound'', 1 => ''Editing'', 2 => ''MustSave'', 3 => ''Corrupted'', 4 => ''Closed''',
  `post_date` datetime NOT NULL COMMENT 'Store posted date & time',
  `post_ip` varchar(39) NOT NULL COMMENT 'Store the user''s IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Store OnlyOffice file revision histories';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_opportunity`
--

CREATE TABLE `tbl_opportunity` (
  `opportunity_id` int NOT NULL,
  `activity_id` int DEFAULT NULL,
  `category_id` int UNSIGNED NOT NULL,
  `description` text,
  `project_id` int NOT NULL,
  `reference_no` varchar(50) DEFAULT NULL,
  `source` text,
  `review_date` date DEFAULT NULL,
  `probability_id` int DEFAULT NULL,
  `impact_id` int DEFAULT NULL,
  `opportunity_exposure` enum('H','M','L') DEFAULT NULL,
  `tangible_id` int DEFAULT NULL,
  `intangible` text,
  `opportunity_management_strategy` text,
  `priority_set` text,
  `status_id` int DEFAULT NULL,
  `response_id` int DEFAULT NULL,
  `responsibility_for_realization` text,
  `post_realization_assessment` text,
  `owner_id` int UNSIGNED NOT NULL,
  `post_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `post_ip` varchar(15) DEFAULT NULL,
  `update_date` datetime DEFAULT NULL,
  `approved_by` int UNSIGNED DEFAULT NULL,
  `approved_date` timestamp NULL DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '1' COMMENT 'status(Active/Inactive)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_opportunity_history`
--

CREATE TABLE `tbl_opportunity_history` (
  `opportunity_id` int NOT NULL,
  `user_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `probability_id` int NOT NULL,
  `impact_id` int NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_opportunity_tangible`
--

CREATE TABLE `tbl_opportunity_tangible` (
  `tangible_id` int NOT NULL,
  `tangible_name` varchar(100) NOT NULL,
  `tangible_value` int NOT NULL,
  `post_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `post_ip` varchar(15) NOT NULL,
  `update_date` datetime DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_password_histories`
--

CREATE TABLE `tbl_password_histories` (
  `user_id` int NOT NULL COMMENT 'FK to users table',
  `password` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'user''s password',
  `salt` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'password salt',
  `user_type` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'normal users=1,guest_user=2',
  `post_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'current time',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'user''s ip'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci COMMENT='store all passwords for every user';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_photos`
--

CREATE TABLE `tbl_photos` (
  `photo_id` bigint NOT NULL,
  `activity_id` bigint DEFAULT NULL COMMENT 'Will be updated during insertion',
  `user_id` int NOT NULL COMMENT 'Store user''s ID',
  `group_id` bigint NOT NULL COMMENT 'Store group ID',
  `project_id` int NOT NULL DEFAULT '0' COMMENT 'Store project ID',
  `event_id` bigint NOT NULL,
  `company_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Store user''s company ID',
  `profile_status` int NOT NULL DEFAULT '0' COMMENT '1= profile picture ,0=other picture',
  `ori_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `file_name` varchar(70) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store uploaded file name',
  `medium_file_name` varchar(70) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store medium sized file name',
  `small_file_name` varchar(70) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store small sized file name',
  `caption` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store photo caption',
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Store photo description',
  `tagged` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `privacy` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` int DEFAULT NULL COMMENT 'Active/inactive status',
  `post_date` datetime DEFAULT NULL COMMENT 'Insertion date',
  `update_date` datetime DEFAULT NULL COMMENT 'Update date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Post IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_photos_users`
--

CREATE TABLE `tbl_photos_users` (
  `photo_tag_id` bigint NOT NULL COMMENT 'Photo tag primary key',
  `photo_id` bigint DEFAULT NULL COMMENT 'Tagged photo id ',
  `user_id` int DEFAULT NULL COMMENT 'Tagged user id',
  `poster_id` int DEFAULT NULL COMMENT 'Tag poster id',
  `tag_value` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'if tagging to custom user name then user_id will be ''0''',
  `left_pos` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Tag position from left',
  `top_pos` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Tag position from top'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pms_issues`
--

CREATE TABLE `tbl_pms_issues` (
  `issue_id` int NOT NULL COMMENT 'Project Issue ID',
  `activity_id` int DEFAULT NULL,
  `group_id` int DEFAULT '0',
  `project_id` int DEFAULT '0' COMMENT 'Project ID',
  `user_id` int NOT NULL COMMENT 'Raised by',
  `title` varchar(255) NOT NULL COMMENT 'Issue Title',
  `description` longtext NOT NULL COMMENT 'Issue Description',
  `date_raised` datetime DEFAULT NULL COMMENT 'Start Date',
  `date_closed` datetime DEFAULT NULL COMMENT 'End Date',
  `issue_status_id` int DEFAULT '0',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Active/ Inactive',
  `attention_required` varchar(100) DEFAULT NULL,
  `date_analyzed` datetime DEFAULT NULL COMMENT 'Analysis date',
  `analysis_plan` text,
  `estimated_effort` varchar(255) DEFAULT NULL,
  `estimated_duration` varchar(255) DEFAULT NULL,
  `estimated_cost` varchar(255) DEFAULT NULL,
  `planned_resolution_date` datetime DEFAULT NULL,
  `issue_type_id` int DEFAULT NULL,
  `action_taken` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `actual_effort` varchar(255) NOT NULL,
  `actual_cost` varchar(255) NOT NULL,
  `remarks` varchar(255) NOT NULL,
  `date_resolved` datetime DEFAULT NULL,
  `reject_details` varchar(255) DEFAULT NULL,
  `isvalid` enum('0','1') NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pms_issue_audit_trails`
--

CREATE TABLE `tbl_pms_issue_audit_trails` (
  `id` int NOT NULL,
  `project_id` int NOT NULL DEFAULT '0' COMMENT 'Project ID',
  `pms_issue_id` int NOT NULL DEFAULT '0' COMMENT 'PMS issue ID',
  `user_id` int NOT NULL DEFAULT '0' COMMENT 'User ID',
  `type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'STATUS,RISK_ACCEPTED,RISK_USER_ADDED',
  `type_value` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'Type Value like status ID, Added/Removed User id etc.',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(100) NOT NULL COMMENT 'Post IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Audit trails for Project Tasks';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pms_issue_status`
--

CREATE TABLE `tbl_pms_issue_status` (
  `status_id` int NOT NULL,
  `status_name` varchar(100) NOT NULL,
  `color_code` varchar(15) NOT NULL,
  `status_order` int NOT NULL,
  `status_type` mediumint NOT NULL COMMENT '1 => Open, 2 => Closed',
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `update_date` datetime NOT NULL,
  `status` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pms_issue_types`
--

CREATE TABLE `tbl_pms_issue_types` (
  `type_id` int UNSIGNED NOT NULL COMMENT 'Project Issue type ID',
  `type_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'Project Issue type Name',
  `post_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Post Date',
  `post_ip` varchar(15) DEFAULT NULL COMMENT 'IP Address',
  `update_date` datetime DEFAULT NULL COMMENT 'Update Date',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive',
  `display_order` int DEFAULT NULL COMMENT 'Display Order'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pms_issue_users`
--

CREATE TABLE `tbl_pms_issue_users` (
  `issue_id` int NOT NULL COMMENT 'Issue ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Status',
  `post_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_privacy_rules`
--

CREATE TABLE `tbl_privacy_rules` (
  `id` int NOT NULL,
  `related_id` int NOT NULL,
  `rules` varchar(255) NOT NULL,
  `related_type` varchar(50) NOT NULL,
  `code` varchar(50) NOT NULL COMMENT 'Store code',
  `action_type` varchar(10) NOT NULL COMMENT 'A="Action" V="View"',
  `module` varchar(30) NOT NULL COMMENT 'store module name',
  `post_date` datetime NOT NULL,
  `status` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_privacy_settings`
--

CREATE TABLE `tbl_privacy_settings` (
  `level_id` tinyint NOT NULL,
  `level_id2` tinyint NOT NULL COMMENT '0=Own,-1=everyone,-2=none',
  `access_permission` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_process_issue_analysis`
--

CREATE TABLE `tbl_process_issue_analysis` (
  `issue_analysis_id` int NOT NULL,
  `process_issue_id` int NOT NULL,
  `analysis_by` int NOT NULL,
  `analysis_on` date NOT NULL,
  `action_plan` text,
  `estimated_hour` decimal(13,2) DEFAULT NULL,
  `estimated_days` int DEFAULT NULL,
  `planned_resolution_date` date DEFAULT NULL,
  `estimated_expenses` decimal(13,2) DEFAULT NULL,
  `update_date` datetime DEFAULT NULL,
  `post_ip` varchar(15) DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_projects`
--

CREATE TABLE `tbl_projects` (
  `project_id` bigint NOT NULL COMMENT 'Project ID',
  `parent_id` bigint NOT NULL DEFAULT '0' COMMENT '	Merged with parent project',
  `activity_id` int NOT NULL COMMENT 'Project Activity ID',
  `client_id` int DEFAULT NULL,
  `project_unique_id` varchar(30) DEFAULT NULL,
  `master_project_id` varchar(255) DEFAULT NULL,
  `pm_user_id` int DEFAULT NULL,
  `requestor_email` varchar(50) NOT NULL,
  `project_type` enum('Internal','Business','eGov','Billing On Actual','Presale') NOT NULL DEFAULT 'Business',
  `business_model` varchar(100) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `short_url` varchar(255) DEFAULT NULL COMMENT 'Project Short URL',
  `project_key` varchar(10) NOT NULL,
  `project_parent_type_id` int NOT NULL,
  `project_type_id` int NOT NULL COMMENT 'Project Type',
  `subscription_id` int NOT NULL COMMENT 'Subscription Id',
  `start_date` datetime NOT NULL COMMENT 'Project Start Date',
  `end_date` datetime NOT NULL COMMENT 'Project End Date',
  `project_status_id` int NOT NULL COMMENT 'Project Status (eg Open, Closed etc)',
  `project_stage_id` int NOT NULL COMMENT 'Project Stage (eg Start Up, Build)',
  `priority` int NOT NULL COMMENT 'Project Priority',
  `rag` varchar(20) NOT NULL COMMENT 'Project Traffic (eg Red, Amber, Green)',
  `company_id` int NOT NULL,
  `department_id` int NOT NULL,
  `team_id` int NOT NULL,
  `project_owner_id` int NOT NULL COMMENT 'Project Owner/Creater',
  `sponsor` int NOT NULL COMMENT 'Sponsor (Existing Ageas Companies or Business Partner)',
  `post_date` datetime NOT NULL COMMENT 'Project Creation Date',
  `update_date` datetime NOT NULL COMMENT 'Project Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status` tinyint(1) NOT NULL COMMENT 'Project Active/ Inactive',
  `due_notification` varchar(100) NOT NULL COMMENT 'Task reminder [0=On due date; D=Daily; 2=2 day before; 5=5 day before]',
  `settings` mediumtext NOT NULL,
  `reference_no` varchar(255) NOT NULL,
  `archive` tinyint(1) NOT NULL DEFAULT '0',
  `change_owner` int NOT NULL DEFAULT '0' COMMENT 'change project ownership',
  `estimate` double(11,2) NOT NULL DEFAULT '0.00' COMMENT 'project estimation in hours',
  `total_hours_booked` double(11,2) NOT NULL DEFAULT '0.00' COMMENT 'total hours booked for project completion',
  `total_chargable_hours` double(11,2) NOT NULL DEFAULT '0.00' COMMENT 'total chargable hours for project',
  `grant_hours` double(11,2) NOT NULL DEFAULT '0.00',
  `combined_hours` double(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Sum of Main & sub project hours if project is merged with master.',
  `is_approved` tinyint NOT NULL DEFAULT '0' COMMENT 'estimation hour is approved or not by change owner of a project',
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done',
  `category_type` enum('high','simple','complex','medium') NOT NULL,
  `deal_type` int NOT NULL,
  `business_type` int NOT NULL,
  `deal_value` int NOT NULL,
  `complience_report` int NOT NULL,
  `project_duration` int NOT NULL,
  `overall_score` int NOT NULL,
  `pm_note` text NOT NULL,
  `audit_status` enum('review','pending','confirm') NOT NULL,
  `discovery_phase` text NOT NULL,
  `project_initiation` text NOT NULL,
  `project_execution` text NOT NULL,
  `project_closure` text NOT NULL,
  `updated_by` int NOT NULL,
  `source` enum('I','T','P','V') NOT NULL COMMENT 'I = INT T = Techshu P = Prime V = VLoka',
  `merge_comment` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Triggers `tbl_projects`
--
DELIMITER $$
CREATE TRIGGER `project_search_delete` AFTER DELETE ON `tbl_projects` FOR EACH ROW BEGIN
	DECLARE `activityID` INTEGER;
	
	SELECT `activity_id` INTO `activityID` FROM `tbl_search` WHERE `ref_id` = OLD.`project_id` AND `stype` = '4';
	DELETE FROM `tbl_search` WHERE `activity_id` = `activityID` AND `stype` IN (4,9);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `project_search_update` BEFORE UPDATE ON `tbl_projects` FOR EACH ROW BEGIN   
	DECLARE `activityID` INTEGER;
	
	IF( NEW.`status` = 1 AND OLD.`search_status` = 1 ) THEN
		SET NEW.`search_status` = 2;
	ELSEIF ( NEW.`status` = 0 OR NEW.`archive` = 1 ) THEN 
		SET NEW.`search_status` = 0;
		SELECT `activity_id` INTO `activityID` FROM `tbl_search` WHERE `ref_id` = NEW.`project_id` AND `stype` = '4';
	   	DELETE FROM `tbl_search` WHERE `activity_id` = `activityID` AND `stype` IN (4,9); 
	END IF;		 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_projects_archive`
--

CREATE TABLE `tbl_projects_archive` (
  `project_id` bigint NOT NULL COMMENT 'Project ID',
  `activity_id` int NOT NULL COMMENT 'Project Activity ID',
  `client_id` int DEFAULT NULL,
  `project_unique_id` varchar(30) DEFAULT NULL,
  `master_project_id` varchar(255) DEFAULT NULL,
  `pm_user_id` int DEFAULT NULL,
  `requestor_email` varchar(50) NOT NULL,
  `project_type` enum('Internal','Business','eGov','Billing On Actual','Presale') NOT NULL DEFAULT 'Business',
  `business_model` varchar(100) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `short_url` varchar(255) DEFAULT NULL COMMENT 'Project Short URL',
  `project_key` varchar(10) NOT NULL,
  `project_parent_type_id` int NOT NULL,
  `project_type_id` int NOT NULL COMMENT 'Project Type',
  `subscription_id` int NOT NULL COMMENT 'Subscription Id',
  `start_date` datetime NOT NULL COMMENT 'Project Start Date',
  `end_date` datetime NOT NULL COMMENT 'Project End Date',
  `project_status_id` int NOT NULL COMMENT 'Project Status (eg Open, Closed etc)',
  `project_stage_id` int NOT NULL COMMENT 'Project Stage (eg Start Up, Build)',
  `priority` int NOT NULL COMMENT 'Project Priority',
  `rag` varchar(20) NOT NULL COMMENT 'Project Traffic (eg Red, Amber, Green)',
  `company_id` int NOT NULL,
  `department_id` int NOT NULL,
  `team_id` int NOT NULL,
  `project_owner_id` int NOT NULL COMMENT 'Project Owner/Creater',
  `sponsor` int NOT NULL COMMENT 'Sponsor (Existing Ageas Companies or Business Partner)',
  `post_date` datetime NOT NULL COMMENT 'Project Creation Date',
  `update_date` datetime NOT NULL COMMENT 'Project Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status` tinyint(1) NOT NULL COMMENT 'Project Active/ Inactive',
  `due_notification` varchar(100) NOT NULL COMMENT 'Task reminder [0=On due date; D=Daily; 2=2 day before; 5=5 day before]',
  `settings` mediumtext NOT NULL,
  `reference_no` varchar(255) NOT NULL,
  `archive` tinyint(1) NOT NULL DEFAULT '0',
  `change_owner` int NOT NULL DEFAULT '0' COMMENT 'change project ownership',
  `estimate` double(11,2) NOT NULL DEFAULT '0.00' COMMENT 'project estimation in hours',
  `total_hours_booked` double(11,2) NOT NULL DEFAULT '0.00' COMMENT 'total hours booked for project completion',
  `total_chargable_hours` double(11,2) NOT NULL DEFAULT '0.00' COMMENT 'total chargable hours for project',
  `grant_hours` double(11,2) NOT NULL DEFAULT '0.00',
  `is_approved` tinyint NOT NULL DEFAULT '0' COMMENT 'estimation hour is approved or not by change owner of a project',
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done',
  `category_type` enum('high','simple','complex','medium') NOT NULL,
  `deal_type` int NOT NULL,
  `business_type` int NOT NULL,
  `deal_value` int NOT NULL,
  `complience_report` int NOT NULL,
  `project_duration` int NOT NULL,
  `overall_score` int NOT NULL,
  `pm_note` text NOT NULL,
  `audit_status` enum('review','pending','confirm') NOT NULL,
  `discovery_phase` text NOT NULL,
  `project_initiation` text NOT NULL,
  `project_execution` text NOT NULL,
  `project_closure` text NOT NULL,
  `updated_by` int NOT NULL,
  `source` enum('I','T','P','V') NOT NULL COMMENT 'I = INT T = Techshu P = Prime V = VLoka'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_projects_backup_n`
--

CREATE TABLE `tbl_projects_backup_n` (
  `project_id` bigint NOT NULL COMMENT 'Project ID',
  `activity_id` int NOT NULL COMMENT 'Project Activity ID',
  `client_id` int DEFAULT NULL,
  `project_unique_id` varchar(30) DEFAULT NULL,
  `master_project_id` varchar(255) DEFAULT NULL,
  `pm_user_id` int DEFAULT NULL,
  `requestor_email` varchar(50) NOT NULL,
  `project_type` enum('Internal','Business','eGov','Billing On Actual','Presale') NOT NULL DEFAULT 'Business',
  `business_model` varchar(100) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `short_url` varchar(255) DEFAULT NULL COMMENT 'Project Short URL',
  `project_key` varchar(10) NOT NULL,
  `project_parent_type_id` int NOT NULL,
  `project_type_id` int NOT NULL COMMENT 'Project Type',
  `subscription_id` int NOT NULL COMMENT 'Subscription Id',
  `start_date` datetime NOT NULL COMMENT 'Project Start Date',
  `end_date` datetime NOT NULL COMMENT 'Project End Date',
  `project_status_id` int NOT NULL COMMENT 'Project Status (eg Open, Closed etc)',
  `project_stage_id` int NOT NULL COMMENT 'Project Stage (eg Start Up, Build)',
  `priority` int NOT NULL COMMENT 'Project Priority',
  `rag` varchar(20) NOT NULL COMMENT 'Project Traffic (eg Red, Amber, Green)',
  `company_id` int NOT NULL,
  `department_id` int NOT NULL,
  `team_id` int NOT NULL,
  `project_owner_id` int NOT NULL COMMENT 'Project Owner/Creater',
  `sponsor` int NOT NULL COMMENT 'Sponsor (Existing Ageas Companies or Business Partner)',
  `post_date` datetime NOT NULL COMMENT 'Project Creation Date',
  `update_date` datetime NOT NULL COMMENT 'Project Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status` tinyint(1) NOT NULL COMMENT 'Project Active/ Inactive',
  `due_notification` varchar(100) NOT NULL COMMENT 'Task reminder [0=On due date; D=Daily; 2=2 day before; 5=5 day before]',
  `settings` mediumtext NOT NULL,
  `reference_no` varchar(255) NOT NULL,
  `archive` tinyint(1) NOT NULL DEFAULT '0',
  `change_owner` int NOT NULL DEFAULT '0' COMMENT 'change project ownership',
  `estimate` double(11,2) NOT NULL DEFAULT '0.00' COMMENT 'project estimation in hours',
  `total_hours_booked` double(11,2) NOT NULL DEFAULT '0.00' COMMENT 'total hours booked for project completion',
  `total_chargable_hours` double(11,2) NOT NULL DEFAULT '0.00' COMMENT 'total chargable hours for project',
  `grant_hours` double(11,2) NOT NULL DEFAULT '0.00',
  `is_approved` tinyint NOT NULL DEFAULT '0' COMMENT 'estimation hour is approved or not by change owner of a project',
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done',
  `category_type` enum('high','simple','complex','medium') NOT NULL,
  `deal_type` int NOT NULL,
  `business_type` int NOT NULL,
  `deal_value` int NOT NULL,
  `complience_report` int NOT NULL,
  `project_duration` int NOT NULL,
  `overall_score` int NOT NULL,
  `pm_note` text NOT NULL,
  `audit_status` enum('review','pending','confirm') NOT NULL,
  `discovery_phase` text NOT NULL,
  `project_initiation` text NOT NULL,
  `project_execution` text NOT NULL,
  `project_closure` text NOT NULL,
  `updated_by` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_audit_fields`
--

CREATE TABLE `tbl_project_audit_fields` (
  `id` int NOT NULL,
  `section_id` int NOT NULL,
  `section_name` varchar(100) NOT NULL,
  `cat_type` enum('high','simple','complex','medium') NOT NULL,
  `mandatory_option` int NOT NULL,
  `created_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_department`
--

CREATE TABLE `tbl_project_department` (
  `department_id` int UNSIGNED NOT NULL COMMENT 'Department ID',
  `company_id` int NOT NULL COMMENT 'Company ID',
  `department_name` varchar(255) NOT NULL COMMENT 'Department Name',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_documents`
--

CREATE TABLE `tbl_project_documents` (
  `document_id` int NOT NULL COMMENT 'Document ID',
  `project_id` int NOT NULL COMMENT 'Project ID',
  `activity_id` int NOT NULL COMMENT 'Activity ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `file_sys_name` varchar(255) NOT NULL COMMENT 'System File name',
  `file_ori_name` varchar(255) NOT NULL COMMENT 'Original File Name',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Active/Inactive',
  `visibility` varchar(100) NOT NULL DEFAULT 'A'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_estimation`
--

CREATE TABLE `tbl_project_estimation` (
  `estimation_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `project_id` int NOT NULL,
  `user_id` int NOT NULL,
  `reviewer_id` int NOT NULL,
  `review` int NOT NULL,
  `posted_on` datetime NOT NULL,
  `updated_on` datetime NOT NULL,
  `version` varchar(255) NOT NULL,
  `estimation_status_id` int NOT NULL,
  `status` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_estimation_audit_trails`
--

CREATE TABLE `tbl_project_estimation_audit_trails` (
  `id` int NOT NULL,
  `project_id` int NOT NULL DEFAULT '0' COMMENT 'Project ID',
  `estimation_id` int NOT NULL DEFAULT '0' COMMENT 'Estimation ID',
  `user_id` int NOT NULL DEFAULT '0' COMMENT 'User ID',
  `type` varchar(20) NOT NULL COMMENT 'STATUS, PRIORITY, RAG, ADD_ASSIGN, REMOVE_ASSIGN, ESTIMATE, ESTIMATE_COMPLETE, TASK_USER_ADDED, TASK_USER_DELETED, TASK_DELAYED, TASK_DEFERRED, TASK_CHARGEABLE, TASK_INVOICE',
  `type_value` varchar(100) DEFAULT NULL COMMENT 'Type Value like status ID, Priority, Added/Removed User id etc.',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(100) NOT NULL COMMENT 'Post IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_estimation_lineitem_map`
--

CREATE TABLE `tbl_project_estimation_lineitem_map` (
  `el_id` int NOT NULL,
  `estimation_id` int NOT NULL,
  `item_id` int NOT NULL,
  `project_id` int NOT NULL,
  `ref_project_id` int NOT NULL,
  `optimistic_score` int NOT NULL,
  `pessimistic_score` int NOT NULL,
  `most_likely_score` int NOT NULL,
  `priority` int NOT NULL,
  `created_by` int NOT NULL,
  `created_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `status` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_estimation_status`
--

CREATE TABLE `tbl_project_estimation_status` (
  `rca_status_id` int UNSIGNED NOT NULL COMMENT 'Project Rca Status ID',
  `project_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Project ID (Optional)',
  `status_name` varchar(255) NOT NULL COMMENT 'Task Status Name',
  `color_code` varchar(15) NOT NULL,
  `status_type` mediumint NOT NULL DEFAULT '0' COMMENT '1 => Reported, 2 => In-Progress, 3 => RCA Identified, 4 => Resolution In Progress, 5 => Resolved, 6 => closed',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_executive_summary`
--

CREATE TABLE `tbl_project_executive_summary` (
  `executive_id` int NOT NULL,
  `project_id` int NOT NULL,
  `group_id` int DEFAULT '0',
  `user_id` int NOT NULL,
  `summary` text NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `post_date` datetime NOT NULL,
  `save_date` datetime NOT NULL,
  `stage` varchar(100) DEFAULT NULL,
  `client_mood` varchar(100) DEFAULT NULL,
  `live_issues` varchar(100) DEFAULT NULL,
  `dev_issues` varchar(100) DEFAULT NULL,
  `resource` varchar(100) DEFAULT NULL,
  `dev` varchar(255) DEFAULT NULL,
  `test` varchar(255) DEFAULT NULL,
  `issues` text,
  `risks` text,
  `pm` varchar(255) DEFAULT NULL,
  `remaining_tail` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_files`
--

CREATE TABLE `tbl_project_files` (
  `file_id` int NOT NULL,
  `type` enum('PROJECT','TASK','ISSUE','TOPIC','RISK') DEFAULT NULL COMMENT 'type is project, task, issue or topic',
  `type_id` int NOT NULL COMMENT 'type_id is task_id, issue_id or topic_id',
  `ori_file_name` varchar(100) NOT NULL COMMENT 'stores original file name',
  `sys_file_name` varchar(100) NOT NULL COMMENT 'stores system file name',
  `file_size` double(10,2) NOT NULL COMMENT 'stores size of file',
  `file_type` enum('PHOTO','FILE') DEFAULT NULL COMMENT 'stores file type is photo or file',
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `status` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_impact`
--

CREATE TABLE `tbl_project_impact` (
  `impact_id` int UNSIGNED NOT NULL COMMENT 'Issue impact ID',
  `impact_name` varchar(255) NOT NULL COMMENT 'Issue impact Name',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_infrastructure_audit_trails`
--

CREATE TABLE `tbl_project_infrastructure_audit_trails` (
  `id` int NOT NULL,
  `project_id` int NOT NULL DEFAULT '0' COMMENT 'Project ID',
  `infrastructure_planning_id` int NOT NULL DEFAULT '0' COMMENT 'Task ID',
  `user_id` int NOT NULL DEFAULT '0' COMMENT 'User ID',
  `type` varchar(20) NOT NULL COMMENT 'STATUS, PRIORITY, RAG, ADD_ASSIGN, REMOVE_ASSIGN, ESTIMATE, ESTIMATE_COMPLETE, TASK_USER_ADDED, TASK_USER_DELETED, TASK_DELAYED, TASK_DEFERRED, TASK_CHARGEABLE, TASK_INVOICE',
  `type_value` varchar(100) DEFAULT NULL COMMENT 'Type Value like status ID, Priority, Added/Removed User id etc.',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(100) NOT NULL COMMENT 'Post IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Audit trails for Project Tasks';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_infrastructure_planning`
--

CREATE TABLE `tbl_project_infrastructure_planning` (
  `infrastructure_planning_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `planning_owner` int NOT NULL,
  `project_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` longtext NOT NULL,
  `version` varchar(100) NOT NULL,
  `start_date` datetime NOT NULL,
  `due_date` datetime NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `last_updated_by` int NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `application_fld_1` text NOT NULL,
  `application_fld_2` varchar(255) NOT NULL,
  `technology` text NOT NULL,
  `hosting_preferred_environment` varchar(255) NOT NULL,
  `hosting_multi_region_setup` varchar(255) NOT NULL,
  `hosting_primary_business_location` varchar(255) NOT NULL,
  `hosting_strategy` text NOT NULL,
  `middleware_technology` varchar(255) NOT NULL,
  `nfr_logging` text NOT NULL,
  `nfr_monthly_activity` varchar(255) NOT NULL,
  `nfr_traffic` varchar(255) NOT NULL,
  `nfr_usage_spikes` varchar(255) NOT NULL,
  `nfr_usage_spikes_details` text NOT NULL,
  `nfr_business_criticality` text NOT NULL,
  `nfr_sequence_priority` varchar(255) NOT NULL,
  `nfr_additional_requirements` text NOT NULL,
  `nfr_patch_management` text NOT NULL,
  `deployment_strategy` text NOT NULL,
  `deployment_execution` text NOT NULL,
  `deployment_cicd_tool` varchar(255) NOT NULL,
  `deployment_cicd_owner` varchar(255) NOT NULL,
  `deployment_automation_tool` varchar(255) NOT NULL,
  `data_monthly_volume` varchar(255) NOT NULL,
  `data_retention_policy` varchar(255) NOT NULL,
  `data_growth` varchar(255) NOT NULL,
  `data_application_specific` varchar(255) NOT NULL,
  `data_application_specific_volume` varchar(255) NOT NULL,
  `data_retention_policy_application_generated` text NOT NULL,
  `data_log_in_application_db` varchar(255) NOT NULL,
  `data_log_monitoring` varchar(255) NOT NULL,
  `data_log_monitoring_tool` text NOT NULL,
  `data_application_backup` varchar(255) NOT NULL,
  `data_backup_frequency` varchar(255) NOT NULL,
  `drdc` text NOT NULL,
  `attachment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `review` int NOT NULL,
  `reviewer_id` int NOT NULL,
  `planning_status_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_infrastructure_planning_status`
--

CREATE TABLE `tbl_project_infrastructure_planning_status` (
  `rca_status_id` int UNSIGNED NOT NULL COMMENT 'Project Rca Status ID',
  `project_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Project ID (Optional)',
  `status_name` varchar(255) NOT NULL COMMENT 'Task Status Name',
  `color_code` varchar(15) NOT NULL,
  `status_type` mediumint NOT NULL DEFAULT '0' COMMENT '1 => Draft, 2 => In-Review, 3 =>Approved',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_infrastructure_requirements_status`
--

CREATE TABLE `tbl_project_infrastructure_requirements_status` (
  `rca_status_id` int UNSIGNED NOT NULL COMMENT 'Project Rca Status ID',
  `project_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Project ID (Optional)',
  `status_name` varchar(255) NOT NULL COMMENT 'Task Status Name',
  `color_code` varchar(15) NOT NULL,
  `status_type` mediumint NOT NULL DEFAULT '0' COMMENT '1 => Reported, 2 => In-Progress, 3 => RCA Identified, 4 => Resolution In Progress, 5 => Resolved, 6 => closed',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_initiation_areas`
--

CREATE TABLE `tbl_project_initiation_areas` (
  `area_id` int UNSIGNED NOT NULL,
  `area_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_initiation_check_points`
--

CREATE TABLE `tbl_project_initiation_check_points` (
  `check_point_id` int UNSIGNED NOT NULL,
  `area_id` int UNSIGNED NOT NULL,
  `check_point_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_initiation_records`
--

CREATE TABLE `tbl_project_initiation_records` (
  `project_initiation_record_id` int UNSIGNED NOT NULL,
  `project_id` int UNSIGNED NOT NULL,
  `project_initiation_data` text,
  `created_by` int UNSIGNED NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_issues`
--

CREATE TABLE `tbl_project_issues` (
  `issue_id` int NOT NULL COMMENT 'Project Issue ID',
  `activity_id` int NOT NULL,
  `project_id` int NOT NULL COMMENT 'Project ID',
  `user_id` int NOT NULL COMMENT 'Raised by',
  `type_id` int NOT NULL DEFAULT '0' COMMENT 'Issue type id',
  `title` varchar(255) NOT NULL COMMENT 'Issue Title',
  `description` longtext NOT NULL COMMENT 'Issue Description',
  `impact_id` int NOT NULL DEFAULT '0' COMMENT 'Impact ID',
  `date_raised` datetime NOT NULL COMMENT 'Start Date',
  `date_closed` datetime NOT NULL COMMENT 'End Date',
  `issue_status_id` int NOT NULL,
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `reference_no` varchar(50) NOT NULL COMMENT '"reference no"',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Active/ Inactive',
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done',
  `task_reference` int NOT NULL DEFAULT '0',
  `client_reference` varchar(50) NOT NULL,
  `attention_required` varchar(100) NOT NULL,
  `external_defect_id` varchar(255) NOT NULL,
  `defect_origination_phase` int NOT NULL,
  `defect_detection_phase` int NOT NULL,
  `severity` int NOT NULL,
  `priority` int NOT NULL,
  `impact` int NOT NULL,
  `external_defect` tinyint(1) NOT NULL,
  `planned_closure_date` datetime NOT NULL,
  `overdue_status` tinyint(1) NOT NULL,
  `rca` int NOT NULL,
  `correction` longtext NOT NULL,
  `corrective_action` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Triggers `tbl_project_issues`
--
DELIMITER $$
CREATE TRIGGER `project_issue_search_delete` AFTER DELETE ON `tbl_project_issues` FOR EACH ROW BEGIN
	DECLARE `activityID` INTEGER;
	
	SELECT `activity_id` INTO `activityID` FROM `tbl_search` WHERE `ref_id` = OLD.`issue_id` AND `stype` = '5';
	DELETE FROM `tbl_search` WHERE `activity_id` = `activityID` AND `stype` IN (5,9);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `project_issue_search_update` BEFORE UPDATE ON `tbl_project_issues` FOR EACH ROW BEGIN   
	DECLARE `activityID` INTEGER;
	
	IF( NEW.`status` = 1 AND OLD.`search_status` = 1 ) THEN
		SET NEW.`search_status` = 2;
	ELSEIF ( NEW.`status` = 0 ) THEN 
		SET NEW.`search_status` = 0;
		SELECT `activity_id` INTO `activityID` FROM `tbl_search` WHERE `ref_id` = NEW.`issue_id` AND `stype` = '5';
	   	DELETE FROM `tbl_search` WHERE `activity_id` = `activityID` AND `stype` IN (5,9); 
	END IF;		 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_issue_comment_users`
--

CREATE TABLE `tbl_project_issue_comment_users` (
  `id` int NOT NULL COMMENT 'ID',
  `issue_id` int NOT NULL COMMENT 'Issue ID',
  `comment_id` int NOT NULL COMMENT 'Comment ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Status',
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_issue_history`
--

CREATE TABLE `tbl_project_issue_history` (
  `issue_id` int NOT NULL COMMENT 'Issue ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `activity_id` int NOT NULL,
  `issue_status` varchar(100) NOT NULL COMMENT 'Issue Status',
  `issue_status_id` int NOT NULL,
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_issue_impact_history`
--

CREATE TABLE `tbl_project_issue_impact_history` (
  `issue_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `activity_id` int DEFAULT NULL,
  `issue_impact_id` int DEFAULT NULL,
  `post_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_issue_move_history`
--

CREATE TABLE `tbl_project_issue_move_history` (
  `issue_id` int NOT NULL COMMENT 'issue_id of issue',
  `user_id` int NOT NULL COMMENT 'user who has moved task to another project',
  `activity_id` int NOT NULL COMMENT 'activity_id of a task',
  `previous_project_id` int NOT NULL COMMENT 'previous project id of a task',
  `present_project_id` int NOT NULL COMMENT 'present project id of a task',
  `post_date` datetime NOT NULL COMMENT 'post date of task movement',
  `post_ip` varchar(25) NOT NULL COMMENT 'post IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_issue_status`
--

CREATE TABLE `tbl_project_issue_status` (
  `issue_status_id` int UNSIGNED NOT NULL COMMENT 'Project Issue Status ID',
  `project_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Project ID (Optional)',
  `status_name` varchar(255) NOT NULL COMMENT 'Issue Status Name',
  `color_code` varchar(15) NOT NULL,
  `status_type` smallint NOT NULL DEFAULT '0' COMMENT '1 => New, 2 => In Progress, 3 => Closed',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_issue_types`
--

CREATE TABLE `tbl_project_issue_types` (
  `type_id` int UNSIGNED NOT NULL COMMENT 'Project Issue type ID',
  `type_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'Project Issue type Name',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive',
  `display_order` int DEFAULT NULL COMMENT 'Display Order'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_issue_users`
--

CREATE TABLE `tbl_project_issue_users` (
  `issue_id` int NOT NULL COMMENT 'Issue ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Status',
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_issue_views`
--

CREATE TABLE `tbl_project_issue_views` (
  `issue_id` int UNSIGNED NOT NULL COMMENT 'Issue ID',
  `user_id` int UNSIGNED NOT NULL COMMENT 'User ID',
  `project_id` int UNSIGNED NOT NULL COMMENT 'Project ID',
  `last_access` datetime NOT NULL COMMENT 'Last Access Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_lineitem`
--

CREATE TABLE `tbl_project_lineitem` (
  `item_id` int NOT NULL,
  `item_title` varchar(255) DEFAULT NULL,
  `category_id` int NOT NULL,
  `techstack_id` int NOT NULL,
  `optimistic_score` int NOT NULL,
  `pessimistic_score` int NOT NULL,
  `most_likely_score` int NOT NULL,
  `priority` int NOT NULL,
  `created_by` int NOT NULL,
  `created_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `status` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_priority`
--

CREATE TABLE `tbl_project_priority` (
  `priority_id` int UNSIGNED NOT NULL COMMENT 'Project Priority ID',
  `project_type_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Project Type ID',
  `priority_name` varchar(255) NOT NULL COMMENT 'Project Priotity Value',
  `priority_order` int NOT NULL,
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_process_issue`
--

CREATE TABLE `tbl_project_process_issue` (
  `process_issue_id` int NOT NULL,
  `activity_id` int DEFAULT NULL,
  `project_id` int NOT NULL,
  `reference_no` varchar(50) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `title` text,
  `description` text,
  `identified_date` date DEFAULT NULL,
  `identified_by` int DEFAULT NULL,
  `issue_references` text,
  `assigned_to` int DEFAULT NULL,
  `assigned_date` date DEFAULT NULL,
  `status_of_action_taken` text,
  `issue_resolution_date` date DEFAULT NULL,
  `actual_effort_spent_hours` decimal(13,2) DEFAULT NULL,
  `actual_expenses` decimal(13,2) DEFAULT NULL,
  `update_date` datetime DEFAULT NULL,
  `post_ip` varchar(15) DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_rca`
--

CREATE TABLE `tbl_project_rca` (
  `rca_id` int NOT NULL COMMENT 'Rca ID',
  `incident_no` int NOT NULL DEFAULT '0' COMMENT 'Auto Generated',
  `activity_id` int DEFAULT NULL,
  `project_id` int NOT NULL COMMENT 'Project ID',
  `reference_no` varchar(50) NOT NULL COMMENT '"reference no"',
  `user_id` int NOT NULL,
  `reported_by_type` enum('I','E') DEFAULT 'E' COMMENT 'Store reported by type',
  `reported_by` varchar(255) DEFAULT NULL,
  `comments` longtext,
  `severity_level` int NOT NULL COMMENT 'RCA Severity level ',
  `incident_date` datetime NOT NULL COMMENT 'Rca Incident date',
  `rca_status_id` int NOT NULL,
  `update_date` datetime NOT NULL COMMENT 'Project Update Date',
  `last_updated_by` int NOT NULL DEFAULT '0' COMMENT 'Last Updated By',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `comment` varchar(100) DEFAULT NULL COMMENT 'task comment',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Project Active/ Inactive',
  `archive` tinyint NOT NULL DEFAULT '0' COMMENT 'Archive(1/0)',
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done',
  `issue_type` varchar(255) NOT NULL COMMENT 'RCA Issue type',
  `issue_description` text NOT NULL COMMENT 'Event or Issue Description',
  `timeline` text NOT NULL COMMENT 'Chronology of events or timeline',
  `repeat_incident` enum('0','1') NOT NULL DEFAULT '0' COMMENT 'Is it a repeat incident',
  `advise_original_event` text NOT NULL COMMENT 'If Repeat incident, then please advise the original Event/Incident',
  `business_impact` text NOT NULL COMMENT 'Client or business impact',
  `troubleshooting_steps_taken` text COMMENT 'Troubleshooting steps taken',
  `root_cause_analysis` text COMMENT 'Root cause analysis',
  `roadblocks` text COMMENT 'Roadblocks',
  `corrective_preventive_action` text COMMENT 'Corrective/Preventive actions',
  `key_takeaway` text COMMENT 'Key takeaway',
  `follow_ups` text COMMENT 'Follow-Ups'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_rca_audit_trails`
--

CREATE TABLE `tbl_project_rca_audit_trails` (
  `id` int NOT NULL,
  `project_id` int NOT NULL DEFAULT '0' COMMENT 'Project ID',
  `rca_id` int NOT NULL DEFAULT '0' COMMENT 'Task ID',
  `user_id` int NOT NULL DEFAULT '0' COMMENT 'User ID',
  `type` varchar(20) NOT NULL COMMENT 'STATUS, PRIORITY, RAG, ADD_ASSIGN, REMOVE_ASSIGN, ESTIMATE, ESTIMATE_COMPLETE, TASK_USER_ADDED, TASK_USER_DELETED, TASK_DELAYED, TASK_DEFERRED, TASK_CHARGEABLE, TASK_INVOICE',
  `type_value` varchar(100) DEFAULT NULL COMMENT 'Type Value like status ID, Priority, Added/Removed User id etc.',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(100) NOT NULL COMMENT 'Post IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Audit trails for Project Tasks';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_rca_internal_users`
--

CREATE TABLE `tbl_project_rca_internal_users` (
  `rca_id` int NOT NULL COMMENT 'RCA ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Status',
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_rca_owners`
--

CREATE TABLE `tbl_project_rca_owners` (
  `rca_id` int NOT NULL COMMENT 'RCA ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Status',
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_rca_status`
--

CREATE TABLE `tbl_project_rca_status` (
  `rca_status_id` int UNSIGNED NOT NULL COMMENT 'Project Rca Status ID',
  `project_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Project ID (Optional)',
  `status_name` varchar(255) NOT NULL COMMENT 'Task Status Name',
  `color_code` varchar(15) NOT NULL,
  `status_type` mediumint NOT NULL DEFAULT '0' COMMENT '1 => Reported, 2 => In-Progress, 3 => RCA Identified, 4 => Resolution In Progress, 5 => Resolved, 6 => closed',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_rca_users`
--

CREATE TABLE `tbl_project_rca_users` (
  `rca_id` int NOT NULL COMMENT 'RCA ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Status',
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_release`
--

CREATE TABLE `tbl_project_release` (
  `release_id` int NOT NULL COMMENT 'release_id',
  `parent_id` int NOT NULL COMMENT 'sub release id',
  `title` varchar(100) NOT NULL COMMENT 'release title',
  `release_note` longtext NOT NULL COMMENT 'release note',
  `release_owner` int NOT NULL COMMENT 'release owner',
  `project_id` int NOT NULL COMMENT 'project id',
  `release_status_id` int NOT NULL COMMENT 'release status',
  `rag` varchar(50) NOT NULL COMMENT 'RAG(Red, Amber, Green)',
  `release_date` datetime NOT NULL COMMENT 'release date',
  `post_date` datetime NOT NULL COMMENT 'post date of release',
  `update_date` datetime NOT NULL COMMENT 'updated date if release updated',
  `status` tinyint(1) NOT NULL COMMENT 'release status active or inactive',
  `post_ip` varchar(15) NOT NULL COMMENT 'post ip'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_repositories`
--

CREATE TABLE `tbl_project_repositories` (
  `repo_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `project_id` int NOT NULL,
  `repo_name` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `posted_by` int NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `post_ip` varchar(255) NOT NULL,
  `status` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_repository_access`
--

CREATE TABLE `tbl_project_repository_access` (
  `id` int NOT NULL,
  `repo_id` int NOT NULL,
  `user_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_risk`
--

CREATE TABLE `tbl_project_risk` (
  `project_risk_id` int UNSIGNED NOT NULL,
  `version` int DEFAULT NULL,
  `project_id` int NOT NULL,
  `risk_category_id` int UNSIGNED NOT NULL,
  `source_of_risk` text,
  `title` text,
  `date_identified` date DEFAULT NULL,
  `priority` enum('H','M','L') DEFAULT NULL,
  `probability_of_occurrence` enum('H','M','L') DEFAULT NULL,
  `impact` enum('H','M','L') DEFAULT NULL,
  `risk_exposure` enum('H','M','L') DEFAULT NULL,
  `risk_management_strategy_id` int UNSIGNED DEFAULT NULL COMMENT 'tbl_risk_response id',
  `mitigation_action_plan` text,
  `contingency_action_plan` text,
  `provision_for_risk_management` text,
  `responsibility` text,
  `mitigation_action` text,
  `revised_probability` enum('H','M','L') DEFAULT NULL,
  `revised_impact` enum('H','M','L') DEFAULT NULL,
  `residual_risk_exposure` enum('H','M','L') DEFAULT NULL,
  `project_risk_status_id` int UNSIGNED DEFAULT NULL,
  `resolution_date` date DEFAULT NULL,
  `comment` text,
  `original_risk_score` int DEFAULT NULL,
  `after_mitigation_risk_score` int DEFAULT NULL,
  `created_by` int UNSIGNED NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_risk_audit_trails`
--

CREATE TABLE `tbl_project_risk_audit_trails` (
  `id` int NOT NULL,
  `project_id` int NOT NULL DEFAULT '0' COMMENT 'Project ID',
  `risk_id` int NOT NULL DEFAULT '0' COMMENT 'Risk ID',
  `user_id` int NOT NULL DEFAULT '0' COMMENT 'User ID',
  `type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'STATUS,RISK_ACCEPTED,RISK_USER_ADDED',
  `type_value` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'Type Value like status ID, Added/Removed User id etc.',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(100) NOT NULL COMMENT 'Post IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Audit trails for Project Tasks';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_risk_status`
--

CREATE TABLE `tbl_project_risk_status` (
  `risk_status_id` int UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_risk_users`
--

CREATE TABLE `tbl_project_risk_users` (
  `risk_id` int NOT NULL COMMENT 'Risk ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Status',
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_sponsors`
--

CREATE TABLE `tbl_project_sponsors` (
  `project_id` int NOT NULL COMMENT 'Project ID',
  `sponsor_id` int NOT NULL COMMENT 'Sponsor ID',
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_stages`
--

CREATE TABLE `tbl_project_stages` (
  `stage_id` int UNSIGNED NOT NULL COMMENT 'Project Stage ID',
  `group_id` int NOT NULL,
  `color_code` varchar(100) NOT NULL,
  `project_type_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Project Status ID',
  `stage_name` varchar(255) NOT NULL COMMENT 'Project Stage Name',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_status`
--

CREATE TABLE `tbl_project_status` (
  `status_id` int UNSIGNED NOT NULL COMMENT 'Project Status ID',
  `group_id` int NOT NULL,
  `color_code` varchar(100) NOT NULL,
  `project_type_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Project Type ID',
  `status_name` varchar(255) NOT NULL COMMENT 'Project Status Value',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_status_history`
--

CREATE TABLE `tbl_project_status_history` (
  `id` int NOT NULL,
  `project_id` int NOT NULL COMMENT 'Project ID',
  `status_id` int NOT NULL COMMENT 'Status ID',
  `activity_id` int NOT NULL,
  `user_id` int NOT NULL COMMENT 'User ID',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_tasks`
--

CREATE TABLE `tbl_project_tasks` (
  `task_id` int NOT NULL COMMENT 'Task ID',
  `parent_id` int NOT NULL DEFAULT '0' COMMENT 'master task aasign',
  `activity_id` int NOT NULL,
  `task_owner` int NOT NULL,
  `project_id` int NOT NULL COMMENT 'Project ID',
  `parent_project_id` bigint DEFAULT NULL,
  `type_id` int DEFAULT '0' COMMENT 'Project Task Types',
  `title` varchar(255) NOT NULL COMMENT 'Task Title',
  `description` longtext NOT NULL COMMENT 'Task Description',
  `comments` longtext NOT NULL,
  `start_date` datetime NOT NULL,
  `due_date` datetime NOT NULL COMMENT 'Task Due Date',
  `post_date` datetime NOT NULL COMMENT 'Task Post Date',
  `task_status_id` int NOT NULL,
  `release_id` int NOT NULL,
  `priority` enum('High','Medium','Low','Default','In Staging') DEFAULT NULL,
  `chargeable` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'Chargeble or not',
  `invoice` enum('Y','N') NOT NULL DEFAULT 'N',
  `invoice_date` datetime NOT NULL,
  `requirement_complete` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'requirement is completed or not',
  `released` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'released or not',
  `ignore_report` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'included in report or not',
  `ignore_release_note` enum('Y','N') NOT NULL DEFAULT 'N',
  `ref_task_id` int NOT NULL DEFAULT '0',
  `rag` varchar(100) NOT NULL,
  `update_date` datetime NOT NULL COMMENT 'Project Update Date',
  `last_updated_by` int NOT NULL DEFAULT '0' COMMENT 'Last Updated By',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `reference_no` varchar(50) NOT NULL COMMENT '"reference no"',
  `release_reference_no` varchar(50) NOT NULL,
  `estimate` float(11,2) NOT NULL DEFAULT '0.00' COMMENT 'estimate time of a task',
  `estimate_complete` float(11,2) NOT NULL DEFAULT '0.00' COMMENT 'estimate time to complete a task',
  `actual_hours` tinyint NOT NULL,
  `percent_complete` float NOT NULL DEFAULT '0' COMMENT 'task completed in percentage',
  `comment` varchar(100) DEFAULT NULL COMMENT 'task comment',
  `release_note` longtext NOT NULL COMMENT 'release note if any',
  `bespoke_item` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'T013265 - as per this request',
  `bespoke_code` text COMMENT 'T013265 - as per this request',
  `reference_type` varchar(15) NOT NULL DEFAULT 'NONE' COMMENT 'reference type from where task is generated',
  `reference_id` int NOT NULL DEFAULT '0' COMMENT 'reference id is ID of reference',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Project Active/ Inactive',
  `archive` tinyint NOT NULL DEFAULT '0' COMMENT 'Archive(1/0)',
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done',
  `client_reference` varchar(50) NOT NULL,
  `client_sequence` varchar(50) NOT NULL,
  `attention_required` varchar(100) DEFAULT NULL,
  `size` int NOT NULL,
  `dependent_task_id` int NOT NULL,
  `acceptance_criteria` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_tasks_17_07_25`
--

CREATE TABLE `tbl_project_tasks_17_07_25` (
  `task_id` int NOT NULL COMMENT 'Task ID',
  `parent_id` int NOT NULL DEFAULT '0' COMMENT 'master task aasign',
  `activity_id` int NOT NULL,
  `task_owner` int NOT NULL,
  `project_id` int NOT NULL COMMENT 'Project ID',
  `parent_project_id` bigint DEFAULT NULL,
  `type_id` int DEFAULT '0' COMMENT 'Project Task Types',
  `title` varchar(255) NOT NULL COMMENT 'Task Title',
  `description` longtext NOT NULL COMMENT 'Task Description',
  `comments` longtext NOT NULL,
  `start_date` datetime NOT NULL,
  `due_date` datetime NOT NULL COMMENT 'Task Due Date',
  `post_date` datetime NOT NULL COMMENT 'Task Post Date',
  `task_status_id` int NOT NULL,
  `release_id` int NOT NULL,
  `priority` enum('High','Medium','Low','Default','In Staging') DEFAULT NULL,
  `chargeable` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'Chargeble or not',
  `invoice` enum('Y','N') NOT NULL DEFAULT 'N',
  `invoice_date` datetime NOT NULL,
  `requirement_complete` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'requirement is completed or not',
  `released` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'released or not',
  `ignore_report` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'included in report or not',
  `ignore_release_note` enum('Y','N') NOT NULL DEFAULT 'N',
  `ref_task_id` int NOT NULL DEFAULT '0',
  `rag` varchar(100) NOT NULL,
  `update_date` datetime NOT NULL COMMENT 'Project Update Date',
  `last_updated_by` int NOT NULL DEFAULT '0' COMMENT 'Last Updated By',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `reference_no` varchar(50) NOT NULL COMMENT '"reference no"',
  `release_reference_no` varchar(50) NOT NULL,
  `estimate` float(11,2) NOT NULL DEFAULT '0.00' COMMENT 'estimate time of a task',
  `estimate_complete` float(11,2) NOT NULL DEFAULT '0.00' COMMENT 'estimate time to complete a task',
  `actual_hours` tinyint NOT NULL,
  `percent_complete` float NOT NULL DEFAULT '0' COMMENT 'task completed in percentage',
  `comment` varchar(100) DEFAULT NULL COMMENT 'task comment',
  `release_note` longtext NOT NULL COMMENT 'release note if any',
  `bespoke_item` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'T013265 - as per this request',
  `bespoke_code` text COMMENT 'T013265 - as per this request',
  `reference_type` varchar(15) NOT NULL DEFAULT 'NONE' COMMENT 'reference type from where task is generated',
  `reference_id` int NOT NULL DEFAULT '0' COMMENT 'reference id is ID of reference',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Project Active/ Inactive',
  `archive` tinyint NOT NULL DEFAULT '0' COMMENT 'Archive(1/0)',
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done',
  `client_reference` varchar(50) NOT NULL,
  `client_sequence` varchar(50) NOT NULL,
  `attention_required` varchar(100) DEFAULT NULL,
  `size` int NOT NULL,
  `dependent_task_id` int NOT NULL,
  `acceptance_criteria` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_tasks_audit_trails`
--

CREATE TABLE `tbl_project_tasks_audit_trails` (
  `id` int NOT NULL,
  `project_id` int NOT NULL DEFAULT '0' COMMENT 'Project ID',
  `task_id` int NOT NULL DEFAULT '0' COMMENT 'Task ID',
  `user_id` int NOT NULL DEFAULT '0' COMMENT 'User ID',
  `type` varchar(20) NOT NULL COMMENT 'STATUS, PRIORITY, RAG, ADD_ASSIGN, REMOVE_ASSIGN, ESTIMATE, ESTIMATE_COMPLETE, TASK_USER_ADDED, TASK_USER_DELETED, TASK_DELAYED, TASK_DEFERRED, TASK_CHARGEABLE, TASK_INVOICE',
  `type_value` varchar(100) DEFAULT NULL COMMENT 'Type Value like status ID, Priority, Added/Removed User id etc.',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(100) NOT NULL COMMENT 'Post IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Audit trails for Project Tasks';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_tasks_bkp`
--

CREATE TABLE `tbl_project_tasks_bkp` (
  `task_id` int NOT NULL COMMENT 'Task ID',
  `parent_id` int NOT NULL DEFAULT '0' COMMENT 'master task aasign',
  `activity_id` int NOT NULL,
  `task_owner` int NOT NULL,
  `project_id` int NOT NULL COMMENT 'Project ID',
  `parent_project_id` bigint DEFAULT NULL,
  `type_id` int DEFAULT '0' COMMENT 'Project Task Types',
  `title` varchar(255) NOT NULL COMMENT 'Task Title',
  `description` longtext NOT NULL COMMENT 'Task Description',
  `comments` longtext NOT NULL,
  `start_date` datetime NOT NULL,
  `due_date` datetime NOT NULL COMMENT 'Task Due Date',
  `post_date` datetime NOT NULL COMMENT 'Task Post Date',
  `task_status_id` int NOT NULL,
  `release_id` int NOT NULL,
  `priority` enum('High','Medium','Low','Default','In Staging') DEFAULT NULL,
  `chargeable` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'Chargeble or not',
  `invoice` enum('Y','N') NOT NULL DEFAULT 'N',
  `invoice_date` datetime NOT NULL,
  `requirement_complete` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'requirement is completed or not',
  `released` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'released or not',
  `ignore_report` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'included in report or not',
  `ignore_release_note` enum('Y','N') NOT NULL DEFAULT 'N',
  `ref_task_id` int NOT NULL DEFAULT '0',
  `rag` varchar(100) NOT NULL,
  `update_date` datetime NOT NULL COMMENT 'Project Update Date',
  `last_updated_by` int NOT NULL DEFAULT '0' COMMENT 'Last Updated By',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `reference_no` varchar(50) NOT NULL COMMENT '"reference no"',
  `release_reference_no` varchar(50) NOT NULL,
  `estimate` float(11,2) NOT NULL DEFAULT '0.00' COMMENT 'estimate time of a task',
  `estimate_complete` float(11,2) NOT NULL DEFAULT '0.00' COMMENT 'estimate time to complete a task',
  `actual_hours` tinyint NOT NULL,
  `percent_complete` float NOT NULL DEFAULT '0' COMMENT 'task completed in percentage',
  `comment` varchar(100) DEFAULT NULL COMMENT 'task comment',
  `release_note` longtext NOT NULL COMMENT 'release note if any',
  `bespoke_item` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'T013265 - as per this request',
  `bespoke_code` text COMMENT 'T013265 - as per this request',
  `reference_type` varchar(15) NOT NULL DEFAULT 'NONE' COMMENT 'reference type from where task is generated',
  `reference_id` int NOT NULL DEFAULT '0' COMMENT 'reference id is ID of reference',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Project Active/ Inactive',
  `archive` tinyint NOT NULL DEFAULT '0' COMMENT 'Archive(1/0)',
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done',
  `client_reference` varchar(50) NOT NULL,
  `client_sequence` varchar(50) NOT NULL,
  `attention_required` varchar(100) DEFAULT NULL,
  `size` int NOT NULL,
  `dependent_task_id` int NOT NULL,
  `acceptance_criteria` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_tasks_chargeable_logs`
--

CREATE TABLE `tbl_project_tasks_chargeable_logs` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `user_id` int NOT NULL,
  `chargeable` enum('Y','N') NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_tasks_history`
--

CREATE TABLE `tbl_project_tasks_history` (
  `task_id` int NOT NULL COMMENT 'Task ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `activity_id` int NOT NULL,
  `task_status` varchar(100) NOT NULL COMMENT 'Task Status',
  `task_status_id` int NOT NULL,
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_tasks_move_history`
--

CREATE TABLE `tbl_project_tasks_move_history` (
  `task_id` int NOT NULL COMMENT 'task_id of task',
  `user_id` int NOT NULL COMMENT 'user who has moved task to another project',
  `activity_id` int NOT NULL COMMENT 'activity_id of a task',
  `previous_project_id` int NOT NULL COMMENT 'previous project id of a task',
  `present_project_id` int NOT NULL COMMENT 'present project id of a task',
  `post_date` datetime NOT NULL COMMENT 'post date of task movement',
  `post_ip` varchar(25) NOT NULL COMMENT 'post IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_tasks_prompt`
--

CREATE TABLE `tbl_project_tasks_prompt` (
  `prompt_id` int NOT NULL,
  `task_id` int DEFAULT NULL,
  `project_id` int NOT NULL,
  `user_id` int NOT NULL,
  `prompt` longtext NOT NULL,
  `prompt_response` longtext,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_task_comment_users`
--

CREATE TABLE `tbl_project_task_comment_users` (
  `id` int NOT NULL COMMENT 'ID',
  `task_id` int NOT NULL COMMENT 'Task ID',
  `comment_id` int NOT NULL COMMENT 'Comment ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Status',
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_task_dependent_comment`
--

CREATE TABLE `tbl_project_task_dependent_comment` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `project_id` int NOT NULL,
  `task_id` int NOT NULL,
  `old_start_date` datetime NOT NULL,
  `old_due_date` datetime NOT NULL,
  `new_start_date` datetime NOT NULL,
  `new_due_date` datetime NOT NULL,
  `diff_days` int NOT NULL,
  `comment` text NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_task_milestone`
--

CREATE TABLE `tbl_project_task_milestone` (
  `milestone_id` int NOT NULL,
  `milestone` varchar(100) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_task_milestone_mapping`
--

CREATE TABLE `tbl_project_task_milestone_mapping` (
  `milestone_id` int NOT NULL,
  `project_id` int NOT NULL,
  `task_id` int NOT NULL,
  `task_start_date` datetime NOT NULL,
  `task_end_date` datetime NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_task_status`
--

CREATE TABLE `tbl_project_task_status` (
  `task_status_id` int UNSIGNED NOT NULL COMMENT 'Project Task Status ID',
  `project_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Project ID (Optional)',
  `status_name` varchar(255) NOT NULL COMMENT 'Task Status Name',
  `color_code` varchar(15) NOT NULL,
  `status_type` mediumint NOT NULL DEFAULT '0' COMMENT '1 => New, 2 => In Progress, 3 => Closed, 4 => UAT, 5 => Abandoned, 6 => Reopened',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_task_types`
--

CREATE TABLE `tbl_project_task_types` (
  `type_id` int UNSIGNED NOT NULL COMMENT 'Project Issue type ID',
  `type_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'Project Issue type Name',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive',
  `display_order` int DEFAULT NULL COMMENT 'Display Order'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_task_users`
--

CREATE TABLE `tbl_project_task_users` (
  `task_id` int NOT NULL COMMENT 'Task ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `allot_percentage` decimal(9,2) NOT NULL DEFAULT '0.00',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Status',
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_task_views`
--

CREATE TABLE `tbl_project_task_views` (
  `task_id` int UNSIGNED NOT NULL COMMENT 'Task ID',
  `user_id` int UNSIGNED NOT NULL COMMENT 'User ID',
  `project_id` int UNSIGNED NOT NULL COMMENT 'Project ID',
  `last_access` datetime NOT NULL COMMENT 'Last Access Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_team`
--

CREATE TABLE `tbl_project_team` (
  `team_id` int UNSIGNED NOT NULL COMMENT 'Team ID',
  `company_id` int NOT NULL,
  `department_id` int NOT NULL,
  `parent_id` int NOT NULL,
  `team_name` varchar(255) NOT NULL COMMENT 'Team Name',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_topics`
--

CREATE TABLE `tbl_project_topics` (
  `project_topic_id` bigint NOT NULL,
  `user_id` int NOT NULL,
  `project_id` bigint NOT NULL,
  `activity_id` bigint NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store topic title',
  `description` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store topic description',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `reference_no` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT '"reference no"',
  `status` int NOT NULL,
  `search_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Triggers `tbl_project_topics`
--
DELIMITER $$
CREATE TRIGGER `project_topic_search_delete` AFTER DELETE ON `tbl_project_topics` FOR EACH ROW BEGIN
	DECLARE `activityID` INTEGER;
	
	SELECT `activity_id` INTO `activityID` FROM `tbl_search` WHERE `ref_id` = OLD.`project_topic_id` AND `stype` = '6';
	DELETE FROM `tbl_search` WHERE `activity_id` = `activityID` AND `stype` IN (6,9);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `project_topic_search_update` BEFORE UPDATE ON `tbl_project_topics` FOR EACH ROW BEGIN   
	DECLARE `activityID` INTEGER;
	
	IF( NEW.`status` = 1 AND OLD.`search_status` = 1 ) THEN
		SET NEW.`search_status` = 2;
	ELSEIF ( NEW.`status` = 0 ) THEN 
		SET NEW.`search_status` = 0;
		SELECT `activity_id` INTO `activityID` FROM `tbl_search` WHERE `ref_id` = NEW.`project_topic_id` AND `stype` = '6';
	   	DELETE FROM `tbl_search` WHERE `activity_id` = `activityID` AND `stype` IN (6,9); 
	END IF;		 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_types`
--

CREATE TABLE `tbl_project_types` (
  `project_type_id` int NOT NULL COMMENT 'Project Type ID',
  `parent_type_id` int NOT NULL COMMENT 'Project Parent ID',
  `group_id` int NOT NULL,
  `project_type` varchar(255) NOT NULL COMMENT 'Project Type',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_users`
--

CREATE TABLE `tbl_project_users` (
  `project_id` int NOT NULL COMMENT 'Project  ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `access_type` enum('ADMIN','PARTICIPANT','SUBSCRIBER') NOT NULL DEFAULT 'PARTICIPANT' COMMENT 'Project Access Type',
  `role_id` int NOT NULL,
  `allocation_from` date DEFAULT NULL,
  `allocation_to` date DEFAULT NULL,
  `allocation_hrs` decimal(9,2) NOT NULL DEFAULT '0.00',
  `resource_type` enum('D','P','S') NOT NULL DEFAULT 'P' COMMENT 'D=Dedicated,P=Part-Time,S=Support ',
  `request_status` enum('A','I','R') NOT NULL COMMENT 'A => Accepted, I => Invited, R => Rejected',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_project_users_log`
--

CREATE TABLE `tbl_project_users_log` (
  `id` int NOT NULL,
  `project_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `action_by` int DEFAULT NULL,
  `action_mode` enum('R') DEFAULT 'R' COMMENT 'R=Removed',
  `post_ip` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_promotion`
--

CREATE TABLE `tbl_promotion` (
  `promotion_id` int NOT NULL,
  `user_id` int NOT NULL,
  `promo_type` int NOT NULL COMMENT 'Quest=1, Event=2, Group=3',
  `promo_type_id` int NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `post_ip` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` enum('0','1') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_promotion_desc`
--

CREATE TABLE `tbl_promotion_desc` (
  `promotion_id` int NOT NULL,
  `share_type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'GroupType=1, EventType=2, Company=3, Job=4',
  `share_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_promotion_ignore_user`
--

CREATE TABLE `tbl_promotion_ignore_user` (
  `promotion_id` int NOT NULL,
  `user_id` int NOT NULL,
  `post_ip` varchar(255) NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qa`
--

CREATE TABLE `tbl_qa` (
  `qa_id` bigint NOT NULL COMMENT 'Store QA id',
  `user_id` int NOT NULL COMMENT 'Store users'' ID',
  `related_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store related section''s ID',
  `related_section` enum('PROFILE','GROUP','EVENT','CAREERS','COURSES','INSTITUTION','COMPANY','JOBS','WORK') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store related section',
  `guideline` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Store guideline',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store post date',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store update date',
  `status` int NOT NULL COMMENT 'Store qa status',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store users'' IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qa_answer_votes`
--

CREATE TABLE `tbl_qa_answer_votes` (
  `answer_id` bigint NOT NULL,
  `user_id` int NOT NULL,
  `vote` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qa_attachment`
--

CREATE TABLE `tbl_qa_attachment` (
  `attach_id` int NOT NULL,
  `attach_qid` int NOT NULL,
  `attach_original_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `attach_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `attach_type` enum('File','External') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'File',
  `attach_filetype` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qa_category`
--

CREATE TABLE `tbl_qa_category` (
  `category_id` bigint NOT NULL COMMENT 'store category id',
  `parent_group_id` int NOT NULL COMMENT 'Parent Group ID',
  `language_id` int NOT NULL COMMENT 'store language id',
  `category` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'store category name',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'store post date',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'store update date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'store post ip address',
  `status` tinyint NOT NULL DEFAULT '1',
  `group_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `noty_emails` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qa_category_group`
--

CREATE TABLE `tbl_qa_category_group` (
  `category_id` int NOT NULL,
  `group_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qa_category_noty_users`
--

CREATE TABLE `tbl_qa_category_noty_users` (
  `category_id` int NOT NULL,
  `user_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qa_process`
--

CREATE TABLE `tbl_qa_process` (
  `process_id` int UNSIGNED NOT NULL,
  `category_id` int NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` mediumtext NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `status` int NOT NULL,
  `process_type` enum('NORMAL','SUBMIT','APPROVED','PROMOTE','REJECT','GOLIVE') NOT NULL,
  `post_ip` varchar(100) NOT NULL,
  `order` int NOT NULL,
  `color` varchar(50) NOT NULL,
  `show_leaderboard` int NOT NULL,
  `status_point` int NOT NULL DEFAULT '0',
  `show_edit` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qa_questions`
--

CREATE TABLE `tbl_qa_questions` (
  `question_id` bigint NOT NULL COMMENT 'Store question ID',
  `parent_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store parrent question ID to map re-eritten questions',
  `qa_id` bigint NOT NULL COMMENT 'Store Q&A ID',
  `user_id` int NOT NULL COMMENT 'Store user ID',
  `activity_id` bigint NOT NULL COMMENT 'Store activity ID',
  `company_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Store company ID',
  `question` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store question',
  `description` mediumtext NOT NULL COMMENT 'Question description',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store post date',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store update date',
  `is_rewrite` int NOT NULL DEFAULT '0',
  `is_main` smallint NOT NULL,
  `status` int NOT NULL COMMENT 'Process status',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store users'' IP',
  `session_id` varchar(100) NOT NULL COMMENT 'Store session id',
  `challenge_flag` tinyint NOT NULL DEFAULT '0',
  `group_id` int NOT NULL DEFAULT '0',
  `event_id` int NOT NULL DEFAULT '0',
  `end_date` date NOT NULL,
  `category_id` int NOT NULL,
  `project_id` int NOT NULL COMMENT 'Project ID',
  `review_id` int NOT NULL,
  `review_version` int NOT NULL,
  `reject_msg` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `review_user` int NOT NULL,
  `review_date` datetime NOT NULL,
  `benefit` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `impact` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `succ_criteria` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `reference_no` varchar(50) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Triggers `tbl_qa_questions`
--
DELIMITER $$
CREATE TRIGGER `idea_master_delete` AFTER DELETE ON `tbl_qa_questions` FOR EACH ROW BEGIN    
	 DELETE FROM `tbl_qa_question_topic` WHERE `question_id` = OLD.question_id;
	 DELETE FROM `tbl_qa_votes` WHERE `question_id` = OLD.question_id;
	 DELETE FROM `tbl_qa_question_mapping` WHERE `question_id` = OLD.question_id;
	 DELETE FROM `tbl_qa_question_answers` WHERE `question_id` = OLD.question_id; 
	 DELETE FROM `tbl_qa_attachment` WHERE attach_qid = OLD.question_id; 
	 DELETE FROM `tbl_qa_status_history` WHERE question_id = OLD.question_id;   
     DELETE FROM `tbl_follow` WHERE follow_type_id = OLD.question_id AND follow_type = 1; 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qa_status_history`
--

CREATE TABLE `tbl_qa_status_history` (
  `id` int NOT NULL,
  `question_id` int NOT NULL,
  `reason` text NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(100) NOT NULL,
  `user_id` int NOT NULL,
  `status` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qa_votes`
--

CREATE TABLE `tbl_qa_votes` (
  `question_id` bigint NOT NULL,
  `user_id` int NOT NULL,
  `vote` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qualifications`
--

CREATE TABLE `tbl_qualifications` (
  `qualification_id` int NOT NULL COMMENT 'Store qualification ID; primary key',
  `level_of_education_id` int NOT NULL COMMENT 'Store level of education ID',
  `status` int NOT NULL COMMENT 'Store display status',
  `verified` int NOT NULL COMMENT 'Set one if the qualification name is verified by admin',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store update date',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store post date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store users'' IP address'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_qualifications_desc`
--

CREATE TABLE `tbl_qualifications_desc` (
  `qualification_id` int NOT NULL COMMENT 'Store qualification ID',
  `language_id` int NOT NULL COMMENT 'Store language ID',
  `name` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store qualification name'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rca_severity`
--

CREATE TABLE `tbl_rca_severity` (
  `severity_id` int NOT NULL,
  `severity_level_name` varchar(100) NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `update_date` datetime NOT NULL,
  `status` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_read_histories`
--

CREATE TABLE `tbl_read_histories` (
  `activity_id` int NOT NULL COMMENT 'Store activity id',
  `user_id` int NOT NULL COMMENT 'Store user id',
  `group_id` int NOT NULL COMMENT 'Store group id',
  `project_id` int NOT NULL COMMENT 'Store project id',
  `readtime` datetime DEFAULT NULL COMMENT 'Store read date & time',
  `post_ip` varchar(40) NOT NULL COMMENT 'Store IP when the read status changed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='This is to track activity read/unread status by users';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_regions`
--

CREATE TABLE `tbl_regions` (
  `region_id` int NOT NULL,
  `region_name` varchar(100) NOT NULL,
  `status` int NOT NULL DEFAULT '1',
  `post_ip` varchar(50) NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_release_activity`
--

CREATE TABLE `tbl_release_activity` (
  `release_id` int NOT NULL COMMENT 'release id',
  `task_id` int NOT NULL COMMENT 'task id',
  `user_id` int NOT NULL COMMENT 'user id',
  `released` tinyint NOT NULL COMMENT 'released (1/0)',
  `post_date` datetime NOT NULL COMMENT 'post date',
  `post_ip` varchar(15) NOT NULL COMMENT 'post ip'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_release_status`
--

CREATE TABLE `tbl_release_status` (
  `release_status_id` int UNSIGNED NOT NULL COMMENT 'Release Status ID',
  `status_name` varchar(255) NOT NULL COMMENT 'Release Status Name',
  `color_code` varchar(15) NOT NULL,
  `status_type` mediumint NOT NULL DEFAULT '0' COMMENT '1 => New, 2 => In Progress, 3 => Closed, 4 => UAT',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `post_ip` varchar(15) NOT NULL COMMENT 'IP Address',
  `status_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_reminder`
--

CREATE TABLE `tbl_reminder` (
  `reminder_id` int NOT NULL,
  `reminder_title` mediumtext NOT NULL,
  `reminder_date` datetime NOT NULL,
  `reminder_type` enum('GROUP','PROJECT') NOT NULL,
  `reminder_type_id` int NOT NULL,
  `posted_by` int NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(100) NOT NULL,
  `status` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_review`
--

CREATE TABLE `tbl_review` (
  `review_id` int UNSIGNED NOT NULL COMMENT 'Review ID',
  `category_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Category ID',
  `review_date` datetime NOT NULL COMMENT 'Review Date',
  `reviewer_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Reviewer ID',
  `post_date` datetime NOT NULL COMMENT 'Review Post Date',
  `status` tinyint UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Review Status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk`
--

CREATE TABLE `tbl_risk` (
  `risk_id` int UNSIGNED NOT NULL COMMENT 'risk id',
  `activity_id` int NOT NULL COMMENT 'activity id',
  `category_id` int NOT NULL COMMENT 'category id',
  `title` varchar(200) DEFAULT NULL,
  `description` text NOT NULL COMMENT 'description of risk',
  `cause` text NOT NULL COMMENT 'cause',
  `consequence` text NOT NULL COMMENT 'consequence',
  `controls` text NOT NULL,
  `update_risk` text NOT NULL,
  `action` text NOT NULL,
  `reference_no` varchar(50) NOT NULL COMMENT 'risk reference number',
  `group_id` int NOT NULL DEFAULT '0',
  `project_id` int NOT NULL COMMENT 'project id',
  `probability_id` int NOT NULL COMMENT 'probabiliyy id',
  `impact_id` int NOT NULL COMMENT 'impact id',
  `risk_priority_id` int DEFAULT NULL,
  `mitigation_action_plan` text,
  `contingency_action_plan` text,
  `action_plan_cost` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `provision_for_risk_management` text,
  `responsibility` text,
  `revised_probability` int DEFAULT '0',
  `revised_impact` int DEFAULT '0',
  `mitigation_action_taken` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `rating` int NOT NULL COMMENT 'rating',
  `rating_color_code` varchar(15) NOT NULL COMMENT 'rating color code',
  `response_id` int NOT NULL COMMENT 'response id',
  `status_id` int NOT NULL DEFAULT '1' COMMENT 'status id',
  `owner_id` int NOT NULL COMMENT 'owner id',
  `target_closure_date` datetime DEFAULT NULL,
  `revised_target_closure_date` datetime DEFAULT NULL,
  `closure_details` varchar(100) NOT NULL,
  `reject_details` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `isvalid` enum('0','1') NOT NULL DEFAULT '0',
  `process_responsibility` text,
  `process_reason` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `transfer_thirdparty_details` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `review_date` datetime NOT NULL COMMENT 'review date',
  `date_raised` datetime NOT NULL COMMENT 'date raised',
  `date_closed` datetime NOT NULL COMMENT 'date closed',
  `post_date` datetime NOT NULL COMMENT 'post date',
  `post_ip` varchar(15) NOT NULL COMMENT 'post ip',
  `after_mitigation_risk_score` int DEFAULT NULL,
  `update_date` datetime NOT NULL COMMENT 'update date',
  `status` tinyint NOT NULL COMMENT 'status(Active/Inactive)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_action`
--

CREATE TABLE `tbl_risk_action` (
  `action_id` int UNSIGNED NOT NULL,
  `action` text NOT NULL,
  `risk_id` int NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `update_date` datetime NOT NULL,
  `status` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_bkp`
--

CREATE TABLE `tbl_risk_bkp` (
  `risk_id` int UNSIGNED NOT NULL COMMENT 'risk id',
  `activity_id` int NOT NULL COMMENT 'activity id',
  `category_id` int NOT NULL COMMENT 'category id',
  `description` text NOT NULL COMMENT 'description of risk',
  `reference_no` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `cause` text NOT NULL COMMENT 'cause',
  `consequence` text NOT NULL COMMENT 'consequence',
  `controls` text NOT NULL,
  `update_risk` text NOT NULL,
  `action` text NOT NULL,
  `project_id` int NOT NULL COMMENT 'project id',
  `probability_id` int NOT NULL COMMENT 'probabiliyy id',
  `impact_id` int NOT NULL COMMENT 'impact id',
  `rating` int NOT NULL COMMENT 'rating',
  `rating_color_code` varchar(15) NOT NULL COMMENT 'rating color code',
  `response_id` int NOT NULL COMMENT 'response id',
  `status_id` int NOT NULL COMMENT 'status id',
  `owner_id` int NOT NULL COMMENT 'owner id',
  `review_date` datetime NOT NULL COMMENT 'review date',
  `date_raised` datetime NOT NULL COMMENT 'date raised',
  `date_closed` datetime NOT NULL COMMENT 'date closed',
  `post_date` datetime NOT NULL COMMENT 'post date',
  `post_ip` varchar(15) NOT NULL COMMENT 'post ip',
  `update_date` datetime NOT NULL COMMENT 'update date',
  `status` tinyint NOT NULL COMMENT 'status(Active/Inactive)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_category`
--

CREATE TABLE `tbl_risk_category` (
  `category_id` int NOT NULL COMMENT 'category id',
  `category_name` varchar(50) NOT NULL COMMENT 'category name',
  `post_date` datetime NOT NULL COMMENT 'post date',
  `post_ip` varchar(15) NOT NULL COMMENT 'post ip',
  `update_date` datetime NOT NULL COMMENT 'update date',
  `status` tinyint NOT NULL COMMENT 'status (Active/Inactive)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_history`
--

CREATE TABLE `tbl_risk_history` (
  `risk_id` int NOT NULL,
  `user_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `status_id` int NOT NULL,
  `response_id` int NOT NULL,
  `probability_id` int NOT NULL,
  `impact_id` int NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_history_old`
--

CREATE TABLE `tbl_risk_history_old` (
  `risk_id` int NOT NULL,
  `user_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `status_id` int NOT NULL,
  `response_id` int NOT NULL,
  `probability_id` int NOT NULL,
  `impact_id` int NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_impact`
--

CREATE TABLE `tbl_risk_impact` (
  `impact_id` int NOT NULL,
  `impact_name` varchar(100) NOT NULL,
  `impact_value` int NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `update_date` datetime NOT NULL,
  `status` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_mitigation_actions`
--

CREATE TABLE `tbl_risk_mitigation_actions` (
  `mitigation_action_id` int NOT NULL,
  `risk_id` int UNSIGNED NOT NULL,
  `activity_id` int UNSIGNED NOT NULL COMMENT 'Store activity ID',
  `user_id` int UNSIGNED NOT NULL,
  `comment` longtext NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `status` int NOT NULL DEFAULT '1' COMMENT '1 - Active, 0 - Deleted, 2 - Deleted with message'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_priority`
--

CREATE TABLE `tbl_risk_priority` (
  `risk_priority_id` int NOT NULL,
  `priority_name` varchar(255) NOT NULL,
  `priority_value` int NOT NULL,
  `status` tinyint NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_probability`
--

CREATE TABLE `tbl_risk_probability` (
  `probability_id` int NOT NULL,
  `probability_name` varchar(100) NOT NULL,
  `probability_value` int NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `update_date` datetime NOT NULL,
  `status` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_response`
--

CREATE TABLE `tbl_risk_response` (
  `response_id` int NOT NULL,
  `response_name` varchar(100) NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `update_date` datetime NOT NULL,
  `status` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_status`
--

CREATE TABLE `tbl_risk_status` (
  `status_id` int NOT NULL,
  `status_name` varchar(100) NOT NULL,
  `color_code` varchar(15) NOT NULL,
  `status_order` int NOT NULL,
  `status_type` mediumint NOT NULL COMMENT '1 => Open, 2 => Closed',
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `update_date` datetime NOT NULL,
  `status` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_risk_update`
--

CREATE TABLE `tbl_risk_update` (
  `update_id` int NOT NULL,
  `updated_text` text NOT NULL,
  `risk_id` int NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) NOT NULL,
  `update_date` datetime NOT NULL,
  `status` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_roles`
--

CREATE TABLE `tbl_roles` (
  `role_id` int NOT NULL,
  `default_role` int NOT NULL,
  `role_slug` enum('CLIENT','MANAGER','DEVELOPER','SUPPORT','SUPPORT_ADMIN','SUB_ADMIN','NONE') DEFAULT 'NONE',
  `role_name` varchar(100) NOT NULL DEFAULT '0',
  `access_permission` text NOT NULL,
  `status` int NOT NULL DEFAULT '1',
  `post_ip` varchar(30) NOT NULL,
  `post_date` datetime NOT NULL,
  `display_order` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_roles_back`
--

CREATE TABLE `tbl_roles_back` (
  `role_id` int NOT NULL,
  `default_role` int NOT NULL,
  `role_slug` enum('CLIENT','MANAGER','DEVELOPER','SUPPORT','SUPPORT_ADMIN','SUB_ADMIN','NONE') DEFAULT 'NONE',
  `role_name` varchar(100) NOT NULL DEFAULT '0',
  `access_permission` text NOT NULL,
  `status` int NOT NULL DEFAULT '1',
  `post_ip` varchar(30) NOT NULL,
  `post_date` datetime NOT NULL,
  `display_order` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_category`
--

CREATE TABLE `tbl_rt_category` (
  `category_id` int NOT NULL COMMENT 'category id',
  `category_name` varchar(50) NOT NULL COMMENT 'RT category name',
  `default_category` tinyint NOT NULL COMMENT 'RT default category ',
  `post_date` datetime NOT NULL COMMENT 'Post date of RT category',
  `update_date` datetime NOT NULL COMMENT 'Updated date of RT category',
  `post_ip` varchar(15) NOT NULL COMMENT 'Post IP of Rt category',
  `status` tinyint NOT NULL COMMENT 'Status of RT category'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_env_details`
--

CREATE TABLE `tbl_rt_env_details` (
  `ticket_id` int NOT NULL COMMENT 'store ticket id',
  `browser_name` varchar(255) NOT NULL COMMENT 'store browser name',
  `browser_version` varchar(255) NOT NULL COMMENT 'store browser version',
  `os_name` varchar(255) NOT NULL COMMENT 'store operating system name',
  `os_version` varchar(255) NOT NULL COMMENT 'store operating system version',
  `resolution` varchar(255) NOT NULL COMMENT 'store display resolution',
  `user_agent` text NOT NULL COMMENT 'store user agent'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Environment details of tickets submitted from support button';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_file`
--

CREATE TABLE `tbl_rt_file` (
  `file_id` int NOT NULL,
  `thread_id` int NOT NULL,
  `ori_name` varchar(100) NOT NULL,
  `sys_name` varchar(100) NOT NULL,
  `file_size` float(11,2) NOT NULL,
  `file_type` varchar(100) NOT NULL,
  `image_inline_id` varchar(255) NOT NULL,
  `disposition` enum('attachment','inline') NOT NULL DEFAULT 'attachment',
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `status` enum('0','1') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_merge_history`
--

CREATE TABLE `tbl_rt_merge_history` (
  `id` int NOT NULL,
  `ticket_id` int NOT NULL COMMENT 'Ticket 1',
  `merge_id` int NOT NULL COMMENT 'Ticket 2',
  `status` tinyint(1) NOT NULL COMMENT 'Status',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `revert` tinyint(1) NOT NULL DEFAULT '0',
  `revert_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_merge_thread_notification`
--

CREATE TABLE `tbl_rt_merge_thread_notification` (
  `ticket_id` int UNSIGNED NOT NULL COMMENT 'Ticket ID ',
  `merge_type` enum('T','N') DEFAULT NULL COMMENT 'Merge Type ( T => Tickets, N => Notification)',
  `type_id` int UNSIGNED NOT NULL COMMENT 'Ticket/Notification ID',
  `merge_time` datetime NOT NULL COMMENT 'Merge Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_notifications`
--

CREATE TABLE `tbl_rt_notifications` (
  `notification_id` bigint NOT NULL,
  `notified_by` int NOT NULL COMMENT 'Store user''s id',
  `notification_type_id` int NOT NULL COMMENT 'Store notification type',
  `ticket_id` int NOT NULL,
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` enum('1','0') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '1',
  `parameters_value` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'store serialize format of notification parameters'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_notification_types`
--

CREATE TABLE `tbl_rt_notification_types` (
  `notification_type_id` int NOT NULL,
  `notification_parameters` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Comma separated parameters',
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `status` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_notification_types_desc`
--

CREATE TABLE `tbl_rt_notification_types_desc` (
  `notification_type_id` int NOT NULL,
  `language_id` int NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store notification description'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_priority`
--

CREATE TABLE `tbl_rt_priority` (
  `priority_id` int NOT NULL COMMENT 'Priority ID',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `priority_order` int NOT NULL,
  `default` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Default item at add ticket',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update',
  `status` enum('0','1') NOT NULL DEFAULT '1' COMMENT 'Status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_status`
--

CREATE TABLE `tbl_rt_status` (
  `status_id` int NOT NULL COMMENT 'Status ID',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `color_code` varchar(50) NOT NULL COMMENT 'RT Status Color Code',
  `status_order` int NOT NULL COMMENT 'RT Status',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update',
  `status` enum('0','1') NOT NULL DEFAULT '1' COMMENT 'Status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_status_history`
--

CREATE TABLE `tbl_rt_status_history` (
  `history_id` int NOT NULL,
  `user_id` int NOT NULL DEFAULT '0',
  `ticket_id` int NOT NULL,
  `status_id` int NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_support`
--

CREATE TABLE `tbl_rt_support` (
  `ticket_id` int UNSIGNED NOT NULL,
  `activity_id` int UNSIGNED NOT NULL DEFAULT '0',
  `reference_id` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL COMMENT 'Type(P = Project, G=Group) ',
  `type_id` int NOT NULL DEFAULT '0' COMMENT 'Project/Group Id',
  `category_id` int NOT NULL DEFAULT '0' COMMENT 'RT category type',
  `ticket_status` int NOT NULL DEFAULT '1',
  `priority` int NOT NULL DEFAULT '0',
  `posted_by` int NOT NULL DEFAULT '0',
  `requestor` varchar(255) NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `closed_date` datetime NOT NULL,
  `merge_id` int NOT NULL DEFAULT '0',
  `merge_tickets` text COMMENT 'Step by step tickets seperated by ::',
  `status` enum('0','1') NOT NULL DEFAULT '1',
  `search_status` tinyint NOT NULL DEFAULT '0' COMMENT 'Used to check and process the data for site search; set ''1'' when the processing is done',
  `client_reference` varchar(50) NOT NULL,
  `attention_required` varchar(100) NOT NULL,
  `client_priority` int NOT NULL DEFAULT '9999' COMMENT 'ordering of the tickets\r\n9999 => BLANK PRIORITY'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_support_owner`
--

CREATE TABLE `tbl_rt_support_owner` (
  `ticket_id` int NOT NULL COMMENT 'Ticket ID',
  `owner_id` int NOT NULL COMMENT 'Assigned to',
  `status` enum('0','1') NOT NULL COMMENT 'Status',
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rt_support_thread`
--

CREATE TABLE `tbl_rt_support_thread` (
  `thread_id` int UNSIGNED NOT NULL,
  `parent_id` int UNSIGNED NOT NULL DEFAULT '0',
  `activity_id` int UNSIGNED NOT NULL DEFAULT '0',
  `ticket_id` int NOT NULL,
  `mail_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Support mail fetching Id',
  `user_id` int NOT NULL,
  `cc` varchar(500) NOT NULL,
  `subject` varchar(500) NOT NULL,
  `description` longtext NOT NULL,
  `post_date` datetime NOT NULL,
  `status` enum('0','1') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_save_search`
--

CREATE TABLE `tbl_save_search` (
  `search_id` int NOT NULL COMMENT 'search id',
  `user_id` int NOT NULL COMMENT 'user of search criteria',
  `type` varchar(15) NOT NULL COMMENT 'Type(''TASK'',''TICKET'')',
  `main_type` enum('GROUP','PROJECT','RT') DEFAULT NULL COMMENT 'group or project',
  `main_type_id` int DEFAULT NULL COMMENT 'group_id or project_id as defined in main_type',
  `search_parameter` text NOT NULL COMMENT 'search parameter ',
  `post_date` datetime NOT NULL COMMENT 'post date',
  `post_ip` varchar(15) NOT NULL COMMENT 'post ip'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_search`
--

CREATE TABLE `tbl_search` (
  `id` bigint NOT NULL COMMENT 'PK',
  `search` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Contains the search data in JSON format',
  `photo` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store related photo name',
  `company_id` int NOT NULL DEFAULT '0' COMMENT 'Store related company ID',
  `group_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store the group ID, used to filter contents by access permissions',
  `project_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store the project ID, used to filter contents by access permissions',
  `ref_id` int NOT NULL COMMENT 'Store Related PK; e.g. ProjectID, TaskID, IssueID, CommentID, TickectID',
  `activity_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store related activity ID from activity table',
  `language_id` int NOT NULL DEFAULT '1' COMMENT 'Store language id',
  `stype` enum('1','2','3','4','5','6','7','8','9') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '1' COMMENT 'Store data type like 1=user, 2=task, 3=group, 4=project, 5=issues, 6=project-discussion, 7=group-discussion, 8=tickets',
  `display_priority` int NOT NULL DEFAULT '0' COMMENT 'Store data type like 1=user, 2=task, 3=group, 4=project, 5=issues, 6=project-discussion, 7=group-discussion, 8=tickets, 9=comments',
  `process_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Store the timestamp when the data was actually processed'
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_sessions`
--

CREATE TABLE `tbl_sessions` (
  `id` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `data` blob,
  `expires` int DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Triggers `tbl_sessions`
--
DELIMITER $$
CREATE TRIGGER `resetOnlineStatus` BEFORE DELETE ON `tbl_sessions` FOR EACH ROW BEGIN
	UPDATE `tbl_users` as u SET 
		u.`online_status` = '0',
		u.`session_id` = '' 
	where u.`session_id` = OLD.`id`;
    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_settings`
--

CREATE TABLE `tbl_settings` (
  `setting_id` int NOT NULL COMMENT 'Store settings ID; autoincrement',
  `group` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store settings group name',
  `code` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store code name',
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store setting description',
  `value` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store settings value',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store last update date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store users'' IP address'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_short_url`
--

CREATE TABLE `tbl_short_url` (
  `id` bigint NOT NULL COMMENT 'Autoincrement ID',
  `code` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'URL code',
  `url` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store URL',
  `views` int NOT NULL COMMENT 'Impression count',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Post date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_site_search`
--

CREATE TABLE `tbl_site_search` (
  `id` bigint NOT NULL COMMENT 'PK',
  `sname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store the main element name',
  `desc` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Stote the description in plain text format',
  `photo` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store related photo name',
  `company_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Store related company ID',
  `info1` int NOT NULL COMMENT 'Store secondary information; like location_id for users, institution_type_id for Institution',
  `info2` int NOT NULL COMMENT 'Store secondary information; like location_id for users, institution_type_id for Institution',
  `ref_id` int NOT NULL COMMENT 'Store Related PK; like user_id, company_id',
  `language_id` int NOT NULL COMMENT 'Store language id',
  `stype` enum('1','2','3','4','5','6','7','8','9') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '1' COMMENT 'Store data type like 1=user, 2=task, 3=group, 4=project, 5=issues, 6=project-discussion, 7=group-discussion, 8=tickets',
  `display_order` int NOT NULL DEFAULT '0' COMMENT 'Store display order for the search section'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_starred_files`
--

CREATE TABLE `tbl_starred_files` (
  `file_id` int NOT NULL,
  `user_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `video_id` int NOT NULL,
  `photo_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_static_modules`
--

CREATE TABLE `tbl_static_modules` (
  `module_id` int NOT NULL,
  `module_name` varchar(100) NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `display_order` int NOT NULL,
  `status` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_static_text`
--

CREATE TABLE `tbl_static_text` (
  `static_id` int NOT NULL,
  `module_id` int NOT NULL,
  `order_id` int NOT NULL,
  `page_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `slug` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `action` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` int NOT NULL DEFAULT '1',
  `update_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_subscriptions`
--

CREATE TABLE `tbl_subscriptions` (
  `subscription_id` int NOT NULL,
  `user_id` int NOT NULL COMMENT 'stores subscribed user',
  `no_of_groups` int NOT NULL DEFAULT '5000' COMMENT 'stores no of groups per subscription',
  `no_of_projects` int NOT NULL DEFAULT '5000' COMMENT 'stores no of projects per subscription',
  `no_of_users` int NOT NULL DEFAULT '5000' COMMENT 'stores no of users per subscrip',
  `cost_per_month` int NOT NULL DEFAULT '0' COMMENT 'cost per month per subscription',
  `cost_per_annual` int NOT NULL DEFAULT '0' COMMENT 'cost per anual per subscription'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_sub_todo_list`
--

CREATE TABLE `tbl_sub_todo_list` (
  `subtodo_id` int NOT NULL,
  `todo_id` int NOT NULL,
  `title` varchar(150) NOT NULL,
  `user_id` int NOT NULL,
  `note` varchar(150) NOT NULL,
  `sort_order` int NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `post_ip` varchar(50) NOT NULL,
  `status` int NOT NULL,
  `done` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_support`
--

CREATE TABLE `tbl_support` (
  `support_id` int NOT NULL,
  `user_id` int NOT NULL,
  `support_type` varchar(100) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `status` int NOT NULL,
  `support_url` varchar(255) NOT NULL,
  `browser` varchar(100) NOT NULL,
  `platform` varchar(100) NOT NULL,
  `agent` varchar(255) NOT NULL,
  `language_id` varchar(100) NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_support_category`
--

CREATE TABLE `tbl_support_category` (
  `category_id` int NOT NULL,
  `category_title` varchar(255) NOT NULL,
  `type` varchar(100) DEFAULT NULL,
  `type_id` int NOT NULL DEFAULT '0',
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `status` enum('0','1') NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_support_details`
--

CREATE TABLE `tbl_support_details` (
  `group_id` int NOT NULL COMMENT 'Stores the group id',
  `domain_name` varchar(255) NOT NULL COMMENT 'store the domain name',
  `support_hash` varchar(255) NOT NULL COMMENT 'Stores the unique key',
  `support_key` varchar(255) NOT NULL COMMENT 'stores the token',
  `button_text` varchar(50) NOT NULL COMMENT 'Store support button text',
  `button_position` enum('LEFT_MIDDLE','RIGHT_MIDDLE','LEFT_BOTTOM','RIGHT_BOTTOM') NOT NULL COMMENT 'Store support button position',
  `button_color` varchar(10) NOT NULL COMMENT 'Store support button color',
  `code` text NOT NULL COMMENT 'stores the generated JS code'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_support_reply`
--

CREATE TABLE `tbl_support_reply` (
  `support_id` int NOT NULL,
  `user_id` int NOT NULL,
  `reply` text NOT NULL,
  `status` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_tags`
--

CREATE TABLE `tbl_tags` (
  `tag_id` bigint NOT NULL COMMENT 'Store tag ID',
  `language_id` int NOT NULL COMMENT 'Store language ID',
  `tag` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store tag',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store post date',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store update date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store users IP address',
  `status` tinyint(1) NOT NULL COMMENT 'active status 0,1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_tasktype`
--

CREATE TABLE `tbl_tasktype` (
  `id` int NOT NULL,
  `task_type_name` varchar(50) NOT NULL,
  `status` int NOT NULL,
  `created_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_task_date_history`
--

CREATE TABLE `tbl_task_date_history` (
  `history_id` int NOT NULL COMMENT 'task date history id',
  `user_id` int NOT NULL COMMENT 'user who changed the task date',
  `task_id` int NOT NULL COMMENT 'task on which date is changed',
  `start_date` date NOT NULL COMMENT 'start date of a task',
  `due_date` date NOT NULL COMMENT 'end date of a task',
  `post_date` datetime NOT NULL COMMENT 'post date on which task date is changed',
  `post_ip` varchar(15) NOT NULL COMMENT 'post ip from which task date is changed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_task_insights`
--

CREATE TABLE `tbl_task_insights` (
  `id` int NOT NULL,
  `group_id` int NOT NULL,
  `project_id` int NOT NULL,
  `task_id` int NOT NULL,
  `bugs` int NOT NULL,
  `issues` int NOT NULL,
  `reopened` int NOT NULL,
  `effort_variance` double(10,2) NOT NULL,
  `schedule_variance` double(10,2) NOT NULL,
  `bugs_values` text NOT NULL,
  `update_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_task_release`
--

CREATE TABLE `tbl_task_release` (
  `release_id` int NOT NULL COMMENT 'release id',
  `task_id` int NOT NULL COMMENT 'task id'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_test_api_data`
--

CREATE TABLE `tbl_test_api_data` (
  `id` int NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_timesheets`
--

CREATE TABLE `tbl_timesheets` (
  `timesheet_id` int NOT NULL COMMENT 'Primary Key',
  `todo_id` int NOT NULL COMMENT 'FK - Store related to-do id',
  `task_id` int NOT NULL DEFAULT '0' COMMENT 'FK - Store related task id',
  `user_id` int NOT NULL COMMENT 'FK - Store user id',
  `project_task_type_id` int NOT NULL,
  `timesheet_date` date NOT NULL COMMENT 'Store timesheet log date',
  `hours` int NOT NULL DEFAULT '0' COMMENT 'Store hours for the timesheet log',
  `minutes` int NOT NULL DEFAULT '0' COMMENT 'Store minutes for the timesheet log',
  `note` varchar(255) NOT NULL COMMENT 'Notes if any',
  `post_ip` varchar(39) NOT NULL COMMENT 'Store IP addess',
  `post_date` datetime NOT NULL COMMENT 'Store insert date & time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='For all timesheet logs';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_todo_list`
--

CREATE TABLE `tbl_todo_list` (
  `todo_id` int NOT NULL,
  `user_id` int NOT NULL COMMENT 'Store assigned user''s id',
  `task_id` int NOT NULL DEFAULT '0' COMMENT 'Store related task ID',
  `title` varchar(255) NOT NULL COMMENT 'Store to-do title',
  `activity_id` int NOT NULL,
  `note` varchar(255) NOT NULL COMMENT 'Store closing notes',
  `original_file_name` varchar(100) NOT NULL COMMENT 'original name of file',
  `rename_file_name` varchar(100) NOT NULL COMMENT 'rename name of file',
  `start_date` datetime NOT NULL COMMENT 'Store to-do start date',
  `due_date` datetime NOT NULL COMMENT 'Store to-do end date',
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL COMMENT 'Store update date & time',
  `post_ip` varchar(50) NOT NULL,
  `status` int NOT NULL,
  `is_completed` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Store complete status',
  `completion_date` datetime NOT NULL COMMENT 'Store datetime when marked as completed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_tooltip`
--

CREATE TABLE `tbl_tooltip` (
  `tooltip_id` int NOT NULL,
  `module` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `code` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `identifier` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `text` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `show_on` enum('ADD','EDIT','BOTH') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'BOTH',
  `status` enum('1','0') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '1',
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_tview_list`
--

CREATE TABLE `tbl_tview_list` (
  `list_id` int UNSIGNED NOT NULL COMMENT 'Default List Id (Auto Increment)',
  `list_type` enum('P','G') DEFAULT NULL COMMENT 'P => Project List, G => Group List',
  `list_type_id` int UNSIGNED NOT NULL COMMENT 'Listed Type Id',
  `user_id` int UNSIGNED NOT NULL COMMENT 'Created by',
  `list_name` varchar(255) NOT NULL COMMENT 'List Name',
  `callback_params` mediumtext COMMENT 'List of Call back Parameters (JSON Format)',
  `show` tinyint UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Show/Hide List',
  `post_date` datetime NOT NULL COMMENT 'Post Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_tview_list_settings`
--

CREATE TABLE `tbl_tview_list_settings` (
  `setting_id` int UNSIGNED NOT NULL COMMENT 'List id (Auto increment)',
  `list_type_id` int UNSIGNED NOT NULL COMMENT 'List type id ( project/group )',
  `list_type` enum('P','G') NOT NULL COMMENT 'P => Project, G => Group',
  `settings` mediumtext COMMENT 'Settings value as JSON format ',
  `post_date` datetime NOT NULL COMMENT 'Post date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_tview_release_settings`
--

CREATE TABLE `tbl_tview_release_settings` (
  `setting_id` int UNSIGNED NOT NULL COMMENT 'List id (Auto increment)',
  `list_type_id` int UNSIGNED NOT NULL COMMENT 'List type id ( project/group )',
  `list_type` enum('P','G') NOT NULL COMMENT 'P => Project, G => Group',
  `settings` mediumtext COMMENT 'Settings value as JSON format ',
  `post_date` datetime NOT NULL COMMENT 'Post date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_tview_saved_search`
--

CREATE TABLE `tbl_tview_saved_search` (
  `save_search_id` int NOT NULL,
  `user_id` int NOT NULL,
  `saved_search` text NOT NULL,
  `list_type_id` int NOT NULL,
  `list_type` enum('P','G') NOT NULL,
  `post_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_url_tracks`
--

CREATE TABLE `tbl_url_tracks` (
  `id` bigint NOT NULL,
  `session_id` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  `url` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `referer` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `browser_info` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `browser_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `browser_version` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `platform_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `platform_version` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `mobile_device` enum('Y','N') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `module_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `action_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `request_type` enum('G','P','A') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `entry_time` int NOT NULL DEFAULT '0',
  `time_diff` int DEFAULT '0',
  `request_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `server_address` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users`
--

CREATE TABLE `tbl_users` (
  `user_id` int NOT NULL,
  `username` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Use for login for user',
  `online_status` int NOT NULL DEFAULT '0' COMMENT 'Used to display online status',
  `session_id` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `email` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Users'' primary email address - also be used as username',
  `password` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Add salt with actual password',
  `salt` varchar(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Will be used as password salt',
  `company_id` int NOT NULL,
  `job_id` int NOT NULL,
  `role_id` int NOT NULL,
  `area_work_id` int NOT NULL DEFAULT '0' COMMENT 'User Area of Work',
  `profile_completion` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store profile completion status as serialized array format',
  `enabled` int NOT NULL DEFAULT '0' COMMENT 'Account active/inactive status',
  `verified` int NOT NULL DEFAULT '0' COMMENT 'For account verification',
  `language_id` int NOT NULL DEFAULT '1' COMMENT 'Foreign key - Language table',
  `mentor_status` int NOT NULL DEFAULT '-1' COMMENT 'Store mentor status',
  `mentees_status` smallint NOT NULL DEFAULT '-1',
  `signup_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Signup date',
  `lastlogin_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Will update on every successful login',
  `login_status` int NOT NULL DEFAULT '0' COMMENT 'Used to protect multiple log-in from different locations',
  `ip_signup` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Remote IP - During signup',
  `ip_lastactive` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Remote IP - Last Login',
  `status_message` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'To display profile status',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Update - for any change in users'' profile',
  `invisible` int NOT NULL COMMENT 'Users'' online status',
  `user_photo` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Only photo name will be stored',
  `user_photo_medium` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Only photo name will be stored',
  `user_photo_small` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Only photo name will be stored',
  `use_album_photo` int NOT NULL COMMENT 'If album photo has been set as profile photo',
  `first_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'First Name',
  `last_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Last Name',
  `gender_id` int NOT NULL DEFAULT '0' COMMENT 'Gender Id',
  `display_sex` int NOT NULL DEFAULT '1' COMMENT 'Sex display status',
  `birth_date` date NOT NULL COMMENT 'Users'' birthday',
  `display_birthdate` int NOT NULL DEFAULT '1' COMMENT 'Birthday display status',
  `hometown_id` int NOT NULL DEFAULT '0' COMMENT 'Will be zero if it is not found in location table',
  `designation` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'designation',
  `interest_in` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Comma separated value from interest table',
  `im_list` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'IM ID and IM service provider''s name will be stored in serialized format',
  `display_im` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT '0 for none; -1 for friends only; -2 for fiends of friends; comma separated ids for selected friends',
  `mobile_number` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Mobile number',
  `phone_number` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'phone number',
  `address` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Address',
  `current_location_id` int NOT NULL DEFAULT '0' COMMENT 'Will be zero if it is not found in the location table',
  `country_id` int NOT NULL,
  `region_id` int NOT NULL,
  `city_other` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Will be used if city name is not in the location table',
  `zip` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store ZIP code from contact information',
  `about_me` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'About Me from personal information',
  `mentor_answers` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store mentor related answers',
  `available_for_ids` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store comma separated available for Ids',
  `work_education_type_id` int NOT NULL COMMENT 'Store users'' work education type Id',
  `read_info_message` int NOT NULL DEFAULT '1' COMMENT 'Store read messages value',
  `want_to_be` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `is_achieve` int NOT NULL,
  `intern_status` enum('I','N') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'N' COMMENT 'Use to store user internship status',
  `skill_profile_completion` enum('0','1') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '0',
  `journey_skip_menu` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `available_for` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `personal_website` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'personal website',
  `profile_complete_flag` int DEFAULT '0' COMMENT 'profile complete 100% 0 no 1 yes',
  `lastactivity` int DEFAULT '0',
  `guest_user` int NOT NULL,
  `speaker_info` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `email_notification` tinyint UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Email notification status',
  `admin_access` int NOT NULL DEFAULT '0',
  `is_default` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Is default value is 1 when user insert through script/cron',
  `is_block` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Status for block user [30 minutes]',
  `read_flash_message` int NOT NULL DEFAULT '1',
  `color_code` varchar(7) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `hide_archive` enum('TRUE','FALSE') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'TRUE' COMMENT 'When hide_archive  FALSE archive data show.',
  `source` enum('I','T','P','V') COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'I = INT T = Techshu P = Prime V = VLoka'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Triggers `tbl_users`
--
DELIMITER $$
CREATE TRIGGER `user_master_delete` AFTER DELETE ON `tbl_users` FOR EACH ROW BEGIN    
	 DELETE FROM tbl_site_search WHERE ref_id = OLD.user_id AND stype = '1'; 	  
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `user_master_insert` AFTER INSERT ON `tbl_users` FOR EACH ROW BEGIN	
	IF(NEW.enabled = 1 AND NEW.verified = 1) THEN					
	    INSERT INTO tbl_site_search
	    SET sname = CONCAT(NEW.first_name,' ',NEW.last_name),
	    company_id = NEW.company_id,
	    info1 = NEW.hometown_id,
	    photo = NEW.user_photo_small,
	    ref_id = NEW.user_id,
	    language_id = NEW.language_id,
	    stype = '1';	    	    
	END IF;	
	INSERT INTO tbl_subscriptions SET user_id = NEW.user_id;
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `user_master_update` AFTER UPDATE ON `tbl_users` FOR EACH ROW BEGIN   
	DECLARE ROW_COUNT INTEGER;
	
	IF(NEW.enabled = 1 AND NEW.verified = 1) THEN
	
           SELECT COUNT(*) INTO ROW_COUNT FROM tbl_site_search WHERE ref_id = NEW.user_id 
           AND stype = '1';	    
	        IF(ROW_COUNT = 0)THEN
		      INSERT INTO tbl_site_search
		       SET sname = CONCAT(NEW.first_name,' ',NEW.last_name),
		       company_id = NEW.company_id,
		       info1 = NEW.hometown_id,
		       photo = NEW.user_photo_small,
		       ref_id = NEW.user_id,
		       language_id = NEW.language_id,
		       stype = '1';			
		     
		ELSE
		      UPDATE tbl_site_search
			SET sname = CONCAT(NEW.first_name,' ',NEW.last_name),
			company_id = NEW.company_id,	
			photo = NEW.user_photo_small,
			info1 = NEW.hometown_id
			WHERE ref_id = NEW.user_id			
			AND stype = '1'; 	
		
		END IF;
	ELSE
	   DELETE FROM tbl_site_search WHERE ref_id = NEW.user_id AND stype = '1'; 
	END IF;		 
	   
    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users_backup`
--

CREATE TABLE `tbl_users_backup` (
  `user_id` int NOT NULL,
  `username` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Use for login for user',
  `online_status` int NOT NULL DEFAULT '0' COMMENT 'Used to display online status',
  `session_id` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `email` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Users'' primary email address - also be used as username',
  `password` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Add salt with actual password',
  `salt` varchar(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Will be used as password salt',
  `company_id` int NOT NULL,
  `job_id` int NOT NULL,
  `role_id` int NOT NULL,
  `area_work_id` int NOT NULL DEFAULT '0' COMMENT 'User Area of Work',
  `profile_completion` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store profile completion status as serialized array format',
  `enabled` int NOT NULL DEFAULT '0' COMMENT 'Account active/inactive status',
  `verified` int NOT NULL DEFAULT '0' COMMENT 'For account verification',
  `language_id` int NOT NULL DEFAULT '1' COMMENT 'Foreign key - Language table',
  `mentor_status` int NOT NULL DEFAULT '-1' COMMENT 'Store mentor status',
  `mentees_status` smallint NOT NULL DEFAULT '-1',
  `signup_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Signup date',
  `lastlogin_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Will update on every successful login',
  `login_status` int NOT NULL DEFAULT '0' COMMENT 'Used to protect multiple log-in from different locations',
  `ip_signup` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Remote IP - During signup',
  `ip_lastactive` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Remote IP - Last Login',
  `status_message` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'To display profile status',
  `update_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Update - for any change in users'' profile',
  `invisible` int NOT NULL COMMENT 'Users'' online status',
  `user_photo` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Only photo name will be stored',
  `user_photo_medium` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Only photo name will be stored',
  `user_photo_small` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Only photo name will be stored',
  `use_album_photo` int NOT NULL COMMENT 'If album photo has been set as profile photo',
  `first_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'First Name',
  `last_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Last Name',
  `gender_id` int NOT NULL DEFAULT '0' COMMENT 'Gender Id',
  `display_sex` int NOT NULL DEFAULT '1' COMMENT 'Sex display status',
  `birth_date` date NOT NULL COMMENT 'Users'' birthday',
  `display_birthdate` int NOT NULL DEFAULT '1' COMMENT 'Birthday display status',
  `hometown_id` int NOT NULL DEFAULT '0' COMMENT 'Will be zero if it is not found in location table',
  `designation` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'designation',
  `interest_in` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Comma separated value from interest table',
  `im_list` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'IM ID and IM service provider''s name will be stored in serialized format',
  `display_im` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT '0 for none; -1 for friends only; -2 for fiends of friends; comma separated ids for selected friends',
  `mobile_number` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Mobile number',
  `phone_number` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'phone number',
  `address` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Address',
  `current_location_id` int NOT NULL DEFAULT '0' COMMENT 'Will be zero if it is not found in the location table',
  `country_id` int NOT NULL,
  `region_id` int NOT NULL,
  `city_other` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Will be used if city name is not in the location table',
  `zip` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store ZIP code from contact information',
  `about_me` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'About Me from personal information',
  `mentor_answers` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store mentor related answers',
  `available_for_ids` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '' COMMENT 'Store comma separated available for Ids',
  `work_education_type_id` int NOT NULL COMMENT 'Store users'' work education type Id',
  `read_info_message` int NOT NULL DEFAULT '1' COMMENT 'Store read messages value',
  `want_to_be` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `is_achieve` int NOT NULL,
  `intern_status` enum('I','N') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'N' COMMENT 'Use to store user internship status',
  `skill_profile_completion` enum('0','1') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '0',
  `journey_skip_menu` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `available_for` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `personal_website` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'personal website',
  `profile_complete_flag` int DEFAULT '0' COMMENT 'profile complete 100% 0 no 1 yes',
  `lastactivity` int DEFAULT '0',
  `guest_user` int NOT NULL,
  `speaker_info` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `email_notification` tinyint UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Email notification status',
  `admin_access` int NOT NULL DEFAULT '0',
  `is_default` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Is default value is 1 when user insert through script/cron',
  `is_block` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Status for block user [30 minutes]',
  `read_flash_message` int NOT NULL DEFAULT '1',
  `color_code` varchar(7) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `hide_archive` enum('TRUE','FALSE') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'TRUE' COMMENT 'When hide_archive  FALSE archive data show.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_account_history`
--

CREATE TABLE `tbl_user_account_history` (
  `user_id` int NOT NULL COMMENT 'Store user_id',
  `account_status` enum('DFA','FRA','DS','DA','DR') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'DFA - Default Activate, FRA - Force active, DS - Deactivated by self, DA - Deactivated by Admin, DR - Deactivate by report',
  `update_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci COMMENT='Store user account statue';

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_company`
--

CREATE TABLE `tbl_user_company` (
  `id` int NOT NULL COMMENT 'Primary ID',
  `user_id` int NOT NULL DEFAULT '0' COMMENT 'User ID',
  `company_id` int NOT NULL DEFAULT '0' COMMENT 'Company ID',
  `post_date` datetime NOT NULL COMMENT 'Post Date',
  `update_date` datetime NOT NULL COMMENT 'Update Date',
  `status` int NOT NULL DEFAULT '1' COMMENT 'Status is Active/Inactive'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_journey`
--

CREATE TABLE `tbl_user_journey` (
  `user_id` int UNSIGNED NOT NULL COMMENT 'User Id',
  `module_id` int UNSIGNED NOT NULL COMMENT 'Visited Module ID',
  `pages` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Visited Pages by User',
  `update_date` datetime NOT NULL COMMENT 'Page Visited Time',
  `status` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_photos`
--

CREATE TABLE `tbl_user_photos` (
  `user_photo_id` bigint UNSIGNED NOT NULL COMMENT 'User Photo Auto Increment ID',
  `user_id` int UNSIGNED NOT NULL COMMENT 'User ID',
  `image_file` varchar(255) NOT NULL COMMENT 'Uploaded Image File',
  `image_type` enum('ACTUAL','SMALL','MEDIUM','LARGE') DEFAULT NULL COMMENT 'Image Type (Actual Image, Small, Medium and Large)',
  `upload_date` int NOT NULL COMMENT 'Image Upload Date'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_settings`
--

CREATE TABLE `tbl_user_settings` (
  `user_id` int NOT NULL,
  `gender` int NOT NULL DEFAULT '0',
  `page` int NOT NULL DEFAULT '0' COMMENT 'Settings for Page',
  `info` int NOT NULL DEFAULT '0' COMMENT 'Settings for Personal Info',
  `basic_info` int NOT NULL DEFAULT '0',
  `contact_info` int NOT NULL DEFAULT '0',
  `user_info` int NOT NULL DEFAULT '0',
  `work_history` int NOT NULL DEFAULT '0',
  `education_info` int NOT NULL DEFAULT '0',
  `mentoring` int NOT NULL DEFAULT '0',
  `skill_profile` int NOT NULL DEFAULT '0',
  `personality_test` int NOT NULL DEFAULT '0',
  `suggested_career` int NOT NULL DEFAULT '0',
  `blog` int NOT NULL DEFAULT '0',
  `qa` int NOT NULL DEFAULT '0',
  `my_media` int NOT NULL DEFAULT '0',
  `my_photos` int NOT NULL DEFAULT '0',
  `my_videos` int NOT NULL DEFAULT '0',
  `my_files` int NOT NULL DEFAULT '0',
  `work_edu_status` int NOT NULL DEFAULT '0',
  `avilable_for` int NOT NULL DEFAULT '0',
  `about_me` int NOT NULL DEFAULT '0',
  `interest` int NOT NULL DEFAULT '0',
  `personal_info` int NOT NULL DEFAULT '0',
  `birth_day` int NOT NULL DEFAULT '0',
  `education` int NOT NULL DEFAULT '0',
  `work_info` int NOT NULL DEFAULT '0',
  `groups` int NOT NULL DEFAULT '0',
  `photos_of_me` int NOT NULL DEFAULT '0',
  `albums_of_me` int NOT NULL DEFAULT '0',
  `videos_of_me` int NOT NULL DEFAULT '0',
  `files_of_me` int NOT NULL DEFAULT '0',
  `post_by_user` int NOT NULL DEFAULT '0',
  `friends_to_user_wall` int NOT NULL DEFAULT '0',
  `posts_by_friends` int NOT NULL DEFAULT '0',
  `comments_on_posts` int NOT NULL DEFAULT '0',
  `im_screen` int NOT NULL DEFAULT '0',
  `mobile_phone` int NOT NULL DEFAULT '0',
  `other_phone` int NOT NULL DEFAULT '0',
  `current_location` int NOT NULL DEFAULT '0',
  `hometown` int NOT NULL DEFAULT '0',
  `current_address` int NOT NULL DEFAULT '0',
  `add_me` int NOT NULL DEFAULT '0',
  `send_me_msg` int NOT NULL DEFAULT '0',
  `email_visible` int NOT NULL DEFAULT '0',
  `search_me` int NOT NULL DEFAULT '0',
  `notification_set` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `general_notification_option` enum('INSTANT','BATCH_TWICE_DAY','BATCH_THRICE_DAY','BATCH_WEEKLY','NONE') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'INSTANT',
  `event_notification_option` enum('INSTANT','BATCH_THRICE_DAY','BATCH_TWICE_DAY','BATCH_WEEKLY','NONE') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'INSTANT',
  `group_notification_option` enum('INSTANT','BATCH_THRICE_DAY','BATCH_TWICE_DAY','BATCH_WEEKLY','NONE') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'INSTANT',
  `idea_notification_option` enum('INSTANT','BATCH_THRICE_DAY','BATCH_TWICE_DAY','BATCH_WEEKLY','NONE') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'INSTANT',
  `primary_language` int NOT NULL DEFAULT '0',
  `profile_left_setting` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `who_can_send_msg` int NOT NULL DEFAULT '0',
  `allow_blog` int NOT NULL DEFAULT '1',
  `allow_post_comments` int NOT NULL DEFAULT '1',
  `personal_website` int NOT NULL DEFAULT '3' COMMENT 'personal website settings',
  `profile_available` int NOT NULL DEFAULT '0' COMMENT 'profile available to search engines. 1 yes 0 no'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_skills`
--

CREATE TABLE `tbl_user_skills` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `project_id` int DEFAULT NULL,
  `skill_id` int NOT NULL,
  `status` enum('1','0') NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_subscriptions`
--

CREATE TABLE `tbl_user_subscriptions` (
  `subscription_id` int NOT NULL,
  `user_id` int NOT NULL COMMENT 'subscribed user_id',
  `sub_type` int NOT NULL COMMENT 'owner =>1               admin=>2               without_subscription =>0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_venue`
--

CREATE TABLE `tbl_venue` (
  `venue_id` int NOT NULL,
  `venue_title` varchar(255) NOT NULL,
  `venue_address` mediumtext NOT NULL,
  `venue_user` int NOT NULL,
  `status` int NOT NULL,
  `post_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `post_ip` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_videos`
--

CREATE TABLE `tbl_videos` (
  `video_id` bigint NOT NULL,
  `activity_id` bigint NOT NULL COMMENT 'Will be updated during insertion',
  `company_id` int UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Store user''s company ID',
  `user_id` int NOT NULL COMMENT 'Store user''s ID',
  `group_id` bigint NOT NULL DEFAULT '0' COMMENT 'Store group ID',
  `event_id` bigint NOT NULL DEFAULT '0',
  `project_id` int NOT NULL,
  `ori_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `file_name` varchar(70) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store uploaded file name',
  `duration` int NOT NULL,
  `thumb_images` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store thum images name as serialized format',
  `main_thumb_image` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store main thumnail photo',
  `caption` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store video caption',
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Store video description',
  `width` int DEFAULT '0' COMMENT 'Store video width',
  `height` int DEFAULT '0' COMMENT 'Store video height',
  `aspect_ratio` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store video aspect ratio',
  `tagged` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `privacy` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` int DEFAULT NULL COMMENT 'Active/inactive status',
  `post_date` datetime DEFAULT NULL COMMENT 'Insertion date',
  `update_date` datetime DEFAULT NULL COMMENT 'Update date',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Post IP'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_visitors`
--

CREATE TABLE `tbl_visitors` (
  `session_id` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store session ID',
  `user_id` int NOT NULL COMMENT 'Store user''s ID',
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Store IP address',
  `section_id` bigint NOT NULL COMMENT 'Store section ID',
  `section` enum('GROUP','EVENT','CAREER','COURSE','INSTITUTION','COMPANY','JOB','BLOG') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Store section name',
  `visit_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Store visit date and time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_weekly_issue_status`
--

CREATE TABLE `tbl_weekly_issue_status` (
  `id` int NOT NULL,
  `group_id` int NOT NULL COMMENT 'Group ID',
  `project_id` int NOT NULL COMMENT 'Project ID',
  `week_range` varchar(100) NOT NULL COMMENT 'Milestone week',
  `total_till_date` int NOT NULL COMMENT 'Total Tickets [Total tickets raised till date]',
  `closed_till_date` int NOT NULL COMMENT 'Closed [Total tickets resolved/deleted/rejected till date]',
  `carried_forward` int NOT NULL COMMENT 'Carried forward [Should have finished last week or earlier]',
  `raised_this_week` int NOT NULL COMMENT 'Raised this week',
  `closed_this_week` int NOT NULL COMMENT 'Closed this week ',
  `mail_sent` enum('0','1') NOT NULL COMMENT '0-Not sent, 1-Sent'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_weekly_task_status`
--

CREATE TABLE `tbl_weekly_task_status` (
  `id` int NOT NULL,
  `group_id` int NOT NULL COMMENT 'Group ID',
  `project_id` int NOT NULL COMMENT 'Project ID',
  `week_range` varchar(100) NOT NULL COMMENT 'Milestone week',
  `total_till_date` int NOT NULL COMMENT 'Total Tasks [Total tasks till date]',
  `open_till_date` int NOT NULL COMMENT 'Open [Total tasks other than Live, Abandon and UAT till date]',
  `closed_till_date` int NOT NULL COMMENT 'Closed [Total Live, Abandoned tasks till date]',
  `carried_forward` int NOT NULL COMMENT 'Carried forward [Should have finished last week or earlier]',
  `scheduled_this_week` int NOT NULL COMMENT 'Scheduled this week [Tasks scheduled for completion this week]',
  `due_this_week` int NOT NULL COMMENT 'Due this week [Carried forward + Scheduled this week]',
  `uat_this_week` int NOT NULL COMMENT 'Moved to UAT [Number of tasks moved to UAT this week]',
  `closed_this_week` int NOT NULL COMMENT 'Closed this week [Number of tasks moved to LIVE or Abandoned this week]',
  `mail_sent` enum('0','1') NOT NULL DEFAULT '0' COMMENT '0-Not sent, 1-Sent'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_weekly_ticket_status`
--

CREATE TABLE `tbl_weekly_ticket_status` (
  `id` int NOT NULL,
  `group_id` int NOT NULL,
  `project_id` int NOT NULL,
  `week_range` varchar(100) NOT NULL COMMENT 'Milestone week',
  `total_till_date` int NOT NULL COMMENT 'Total Tickets [Total tickets raised till date]',
  `closed_till_date` int NOT NULL COMMENT 'Closed [Total tickets resolved/deleted/rejected till date]',
  `carried_forward` int NOT NULL COMMENT 'Carried forward [Should have finished last week or earlier]',
  `raised_this_week` int NOT NULL COMMENT 'Raised this week',
  `closed_this_week` int NOT NULL COMMENT 'Closed this week ',
  `mail_sent` enum('0','1') NOT NULL COMMENT '0-Not sent, 1-Sent'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_word_group`
--

CREATE TABLE `tbl_word_group` (
  `id` int NOT NULL,
  `group_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_work_education_types`
--

CREATE TABLE `tbl_work_education_types` (
  `work_education_type_id` int NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `type` enum('W','E','C') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'W=Work,E=Educatuion,C=Company',
  `language_id` int NOT NULL DEFAULT '1',
  `status` int NOT NULL DEFAULT '1',
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_work_education_types_desc`
--

CREATE TABLE `tbl_work_education_types_desc` (
  `work_education_type_id` int NOT NULL,
  `name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `language_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_work_edu_mapping`
--

CREATE TABLE `tbl_work_edu_mapping` (
  `rel_id` int NOT NULL,
  `work_education_type_id` int DEFAULT '0' COMMENT 'Insert related activity id',
  `user_id` int NOT NULL,
  `type` varchar(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `company_id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `period` varchar(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `post_date` datetime NOT NULL,
  `post_ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `temp_all_task`
--

CREATE TABLE `temp_all_task` (
  `task_id` int DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `description` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `start_date` datetime DEFAULT NULL,
  `due_date` datetime DEFAULT NULL,
  `rag` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `priority` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `task_status_id` int DEFAULT NULL,
  `task_owner` int DEFAULT NULL,
  `reference_no` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `project_id` int DEFAULT NULL,
  `chargeable` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `attention_required` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_project_tasks_combined`
-- (See below for the actual view)
--
CREATE TABLE `view_project_tasks_combined` (
`task_id` bigint
,`title` varchar(255)
,`description` longtext
,`start_date` datetime
,`due_date` datetime
,`rag` varchar(100)
,`priority` varchar(10)
,`task_status_id` bigint
,`task_owner` bigint
,`reference_no` varchar(50)
,`release_id` bigint
,`chargeable` varchar(1)
,`project_id` bigint
,`project_name` varchar(255)
,`group_id` int
,`group_name` varchar(250)
,`release_date` datetime
);

-- --------------------------------------------------------

--
-- Structure for view `view_project_tasks_combined`
--
DROP TABLE IF EXISTS `view_project_tasks_combined`;

CREATE ALGORITHM=UNDEFINED DEFINER=`engageusr`@`%` SQL SECURITY DEFINER VIEW `view_project_tasks_combined`  AS  select if((`t2`.`parent_id` > 0),`t2`.`task_id`,`t1`.`task_id`) AS `task_id`,if((`t2`.`parent_id` > 0),`t2`.`title`,`t1`.`title`) AS `title`,if((`t2`.`parent_id` > 0),`t2`.`description`,`t1`.`description`) AS `description`,if((`t2`.`parent_id` > 0),`t2`.`start_date`,`t1`.`start_date`) AS `start_date`,if((`t2`.`parent_id` > 0),`t2`.`due_date`,`t1`.`due_date`) AS `due_date`,if((`t2`.`parent_id` > 0),`t2`.`rag`,`t1`.`rag`) AS `rag`,if((`t2`.`parent_id` > 0),`t2`.`priority`,`t1`.`priority`) AS `priority`,if((`t2`.`parent_id` > 0),`t2`.`task_status_id`,`t1`.`task_status_id`) AS `task_status_id`,if((`t2`.`parent_id` > 0),`t2`.`task_owner`,`t1`.`task_owner`) AS `task_owner`,if((`t2`.`parent_id` > 0),`t2`.`reference_no`,`t1`.`reference_no`) AS `reference_no`,if((`t2`.`parent_id` > 0),`t2`.`release_id`,`t1`.`release_id`) AS `release_id`,if((`t2`.`parent_id` > 0),`t2`.`chargeable`,`t1`.`chargeable`) AS `chargeable`,if((`t2`.`parent_id` > 0),`t2`.`project_id`,`t1`.`project_id`) AS `project_id`,`tbl_projects`.`title` AS `project_name`,`tbl_group_projects`.`group_id` AS `group_id`,`tbl_groups`.`name` AS `group_name`,`tbl_group_release`.`release_date` AS `release_date` from (((((`tbl_project_tasks` `t1` left join `tbl_project_tasks` `t2` on((`t1`.`task_id` = `t2`.`parent_id`))) left join `tbl_group_projects` on((`t1`.`project_id` = `tbl_group_projects`.`project_id`))) left join `tbl_group_release` on((`t2`.`release_id` = `tbl_group_release`.`release_id`))) left join `tbl_groups` on((`tbl_group_projects`.`group_id` = `tbl_groups`.`group_id`))) left join `tbl_projects` on((`tbl_group_projects`.`project_id` = `tbl_projects`.`project_id`))) where ((`t1`.`status` = '1') and ((`t1`.`parent_id` = '0') or (`t1`.`task_id` = `t1`.`parent_id`)) and (`t2`.`parent_id` > '0') and (`t2`.`status` = '1')) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`group_id`),
  ADD KEY `department_name` (`name`),
  ADD KEY `hrbp_id` (`hrbp_id`),
  ADD KEY `hod_id` (`owner_id`),
  ADD KEY `department_type` (`department_type`),
  ADD KEY `unit` (`unit`),
  ADD KEY `production_status` (`production_status`),
  ADD KEY `shortname` (`short_url`),
  ADD KEY `org_dept_type` (`org_dept_type`),
  ADD KEY `sbu_type` (`sbu_type`),
  ADD KEY `department_function` (`department_function`),
  ADD KEY `showinpf` (`showinpf`),
  ADD KEY `is_enterprise` (`is_enterprise`),
  ADD KEY `last_updated_date` (`last_updated_date`);

--
-- Indexes for table `project_infrastructure_requirements`
--
ALTER TABLE `project_infrastructure_requirements`
  ADD PRIMARY KEY (`requirements_id`);

--
-- Indexes for table `project_infrastructure_requirements_audit_trails`
--
ALTER TABLE `project_infrastructure_requirements_audit_trails`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `project_requirements_lineitem`
--
ALTER TABLE `project_requirements_lineitem`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_activities`
--
ALTER TABLE `tbl_activities`
  ADD PRIMARY KEY (`activity_id`),
  ADD KEY `relatedIds` (`group_id`,`event_id`),
  ADD KEY `activityIndex` (`activity_type_id`,`user_id`),
  ADD KEY `statusIndex` (`status`),
  ADD KEY `shareIndex` (`share_status`),
  ADD KEY `update_time` (`update_time`),
  ADD KEY `activity_time` (`activity_time`),
  ADD KEY `activity_type_id` (`activity_type_id`),
  ADD KEY `idx_activity_project` (`project_id`);

--
-- Indexes for table `tbl_activity_privacy_settings`
--
ALTER TABLE `tbl_activity_privacy_settings`
  ADD PRIMARY KEY (`activity_id`),
  ADD UNIQUE KEY `privacy_index` (`activity_id`,`activity_privacy`);
ALTER TABLE `tbl_activity_privacy_settings` ADD FULLTEXT KEY `settings_index` (`privacy_settings`);

--
-- Indexes for table `tbl_activity_types`
--
ALTER TABLE `tbl_activity_types`
  ADD PRIMARY KEY (`activity_type_id`),
  ADD UNIQUE KEY `activityType` (`activity_type`,`display_at`),
  ADD KEY `relatedActivity` (`related_activity`);

--
-- Indexes for table `tbl_activity_types_desc`
--
ALTER TABLE `tbl_activity_types_desc`
  ADD UNIQUE KEY `activityTypeDesc` (`activity_type_id`,`language_id`,`gender_id`);

--
-- Indexes for table `tbl_admins`
--
ALTER TABLE `tbl_admins`
  ADD PRIMARY KEY (`admin_id`);

--
-- Indexes for table `tbl_admin_groups`
--
ALTER TABLE `tbl_admin_groups`
  ADD PRIMARY KEY (`group_id`);

--
-- Indexes for table `tbl_admin_group_settings`
--
ALTER TABLE `tbl_admin_group_settings`
  ADD UNIQUE KEY `adminGroupIndex` (`group_id`,`section_id`);

--
-- Indexes for table `tbl_admin_sections`
--
ALTER TABLE `tbl_admin_sections`
  ADD PRIMARY KEY (`section_id`),
  ADD UNIQUE KEY `section_code` (`section_code`);

--
-- Indexes for table `tbl_agenda`
--
ALTER TABLE `tbl_agenda`
  ADD PRIMARY KEY (`agenda_id`);

--
-- Indexes for table `tbl_albums`
--
ALTER TABLE `tbl_albums`
  ADD PRIMARY KEY (`album_id`);

--
-- Indexes for table `tbl_album_photos`
--
ALTER TABLE `tbl_album_photos`
  ADD UNIQUE KEY `PhotoAlbums` (`album_id`,`photo_id`,`user_id`,`album_image`);

--
-- Indexes for table `tbl_announcements`
--
ALTER TABLE `tbl_announcements`
  ADD PRIMARY KEY (`announce_id`),
  ADD KEY `status` (`status`),
  ADD KEY `start_date` (`start_date`),
  ADD KEY `end_start` (`end_date`);

--
-- Indexes for table `tbl_area_of_work`
--
ALTER TABLE `tbl_area_of_work`
  ADD PRIMARY KEY (`area_work_id`);

--
-- Indexes for table `tbl_attachment`
--
ALTER TABLE `tbl_attachment`
  ADD PRIMARY KEY (`file_id`),
  ADD KEY `folder ID` (`folder_id`),
  ADD KEY `idx_type_typeid_status` (`type`,`type_id`,`status`);

--
-- Indexes for table `tbl_attachment_dl_log`
--
ALTER TABLE `tbl_attachment_dl_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `tbl_attachment_relation`
--
ALTER TABLE `tbl_attachment_relation`
  ADD PRIMARY KEY (`relation_id`),
  ADD UNIQUE KEY `file_id` (`file_id`);

--
-- Indexes for table `tbl_available_for_info`
--
ALTER TABLE `tbl_available_for_info`
  ADD PRIMARY KEY (`available_for_id`);

--
-- Indexes for table `tbl_batch_notifications`
--
ALTER TABLE `tbl_batch_notifications`
  ADD PRIMARY KEY (`batch_id`);

--
-- Indexes for table `tbl_bulletin`
--
ALTER TABLE `tbl_bulletin`
  ADD PRIMARY KEY (`bulletin_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `group_id` (`group_id`);

--
-- Indexes for table `tbl_bulletin_bookmark`
--
ALTER TABLE `tbl_bulletin_bookmark`
  ADD UNIQUE KEY `bulletin_id` (`bulletin_id`,`user_id`);

--
-- Indexes for table `tbl_bulletin_category`
--
ALTER TABLE `tbl_bulletin_category`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `tbl_bulletin_comment`
--
ALTER TABLE `tbl_bulletin_comment`
  ADD PRIMARY KEY (`comment_id`);

--
-- Indexes for table `tbl_bulletin_tags`
--
ALTER TABLE `tbl_bulletin_tags`
  ADD PRIMARY KEY (`tag_id`);

--
-- Indexes for table `tbl_bulletin_tags_mapping`
--
ALTER TABLE `tbl_bulletin_tags_mapping`
  ADD KEY `tag_id` (`tag_id`);

--
-- Indexes for table `tbl_chat_broadcast_messages`
--
ALTER TABLE `tbl_chat_broadcast_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `userid` (`user_id`),
  ADD KEY `broadcast_id` (`broadcast_id`),
  ADD KEY `sent` (`sent`);

--
-- Indexes for table `tbl_chat_groups`
--
ALTER TABLE `tbl_chat_groups`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lastactivity` (`last_activity`),
  ADD KEY `createdby` (`created_by`),
  ADD KEY `type` (`type`);

--
-- Indexes for table `tbl_chat_group_messages`
--
ALTER TABLE `tbl_chat_group_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `userid` (`user_id`),
  ADD KEY `chatroomid` (`chat_group_id`),
  ADD KEY `sent` (`sent`);

--
-- Indexes for table `tbl_chat_group_users`
--
ALTER TABLE `tbl_chat_group_users`
  ADD PRIMARY KEY (`user_id`,`chat_group_id`) USING BTREE,
  ADD KEY `chatroomid` (`chat_group_id`),
  ADD KEY `lastactivity` (`last_activity`),
  ADD KEY `userid` (`user_id`),
  ADD KEY `userid_chatroomid` (`chat_group_id`,`user_id`);

--
-- Indexes for table `tbl_chat_messages`
--
ALTER TABLE `tbl_chat_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `to` (`to`),
  ADD KEY `from` (`from`),
  ADD KEY `direction` (`direction`),
  ADD KEY `read` (`read`),
  ADD KEY `sent` (`sent`);

--
-- Indexes for table `tbl_chat_status`
--
ALTER TABLE `tbl_chat_status`
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `user_id_index` (`user_id`);

--
-- Indexes for table `tbl_clients`
--
ALTER TABLE `tbl_clients`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_client_summary_report`
--
ALTER TABLE `tbl_client_summary_report`
  ADD PRIMARY KEY (`report_id`);

--
-- Indexes for table `tbl_cms`
--
ALTER TABLE `tbl_cms`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_comments`
--
ALTER TABLE `tbl_comments`
  ADD PRIMARY KEY (`comment_id`),
  ADD KEY `activity_id` (`activity_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `parentId` (`parent_id`),
  ADD KEY `searchStatus` (`search_status`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `tbl_comment_likes`
--
ALTER TABLE `tbl_comment_likes`
  ADD PRIMARY KEY (`comment_id`,`activity_id`,`user_id`);

--
-- Indexes for table `tbl_comment_privacy`
--
ALTER TABLE `tbl_comment_privacy`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_companies`
--
ALTER TABLE `tbl_companies`
  ADD PRIMARY KEY (`company_id`);

--
-- Indexes for table `tbl_contents`
--
ALTER TABLE `tbl_contents`
  ADD PRIMARY KEY (`content_id`);

--
-- Indexes for table `tbl_contents_desc`
--
ALTER TABLE `tbl_contents_desc`
  ADD PRIMARY KEY (`content_desc_id`);

--
-- Indexes for table `tbl_countries`
--
ALTER TABLE `tbl_countries`
  ADD PRIMARY KEY (`country_id`),
  ADD KEY `countryCode` (`country_code`);

--
-- Indexes for table `tbl_countries_desc`
--
ALTER TABLE `tbl_countries_desc`
  ADD UNIQUE KEY `countryDescId` (`country_id`,`language_id`),
  ADD KEY `countryName` (`country_name`);

--
-- Indexes for table `tbl_discussion`
--
ALTER TABLE `tbl_discussion`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_document_folder`
--
ALTER TABLE `tbl_document_folder`
  ADD UNIQUE KEY `document_folder_index` (`activity_id`,`folder_id`);

--
-- Indexes for table `tbl_ehs`
--
ALTER TABLE `tbl_ehs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_estimation_assumption_map`
--
ALTER TABLE `tbl_estimation_assumption_map`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_estimation_asumption`
--
ALTER TABLE `tbl_estimation_asumption`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_estimation_complexity`
--
ALTER TABLE `tbl_estimation_complexity`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_estimation_deliverables`
--
ALTER TABLE `tbl_estimation_deliverables`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_estimation_risks`
--
ALTER TABLE `tbl_estimation_risks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_estimation_summary`
--
ALTER TABLE `tbl_estimation_summary`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_events`
--
ALTER TABLE `tbl_events`
  ADD PRIMARY KEY (`event_id`);

--
-- Indexes for table `tbl_event_dates`
--
ALTER TABLE `tbl_event_dates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_fetched_mails`
--
ALTER TABLE `tbl_fetched_mails`
  ADD PRIMARY KEY (`mail_id`),
  ADD UNIQUE KEY `message_id` (`message_id`),
  ADD KEY `readStatus` (`read_status`);

--
-- Indexes for table `tbl_fetched_mails_attachments`
--
ALTER TABLE `tbl_fetched_mails_attachments`
  ADD PRIMARY KEY (`attachment_id`),
  ADD KEY `mailId` (`mail_id`);

--
-- Indexes for table `tbl_files`
--
ALTER TABLE `tbl_files`
  ADD PRIMARY KEY (`file_id`),
  ADD UNIQUE KEY `fileUsers` (`user_id`,`activity_id`);

--
-- Indexes for table `tbl_folder`
--
ALTER TABLE `tbl_folder`
  ADD PRIMARY KEY (`folder_id`);

--
-- Indexes for table `tbl_folder_mapping`
--
ALTER TABLE `tbl_folder_mapping`
  ADD PRIMARY KEY (`map_id`);

--
-- Indexes for table `tbl_follow`
--
ALTER TABLE `tbl_follow`
  ADD PRIMARY KEY (`follow_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `follow_type` (`follow_type`),
  ADD KEY `follow_type_id` (`follow_type_id`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `tbl_form_fields`
--
ALTER TABLE `tbl_form_fields`
  ADD PRIMARY KEY (`element_id`),
  ADD UNIQUE KEY `competitionID` (`element_type`,`field_name`);

--
-- Indexes for table `tbl_form_fields_value`
--
ALTER TABLE `tbl_form_fields_value`
  ADD KEY `element_id` (`element_id`),
  ADD KEY `type_id` (`type_id`);
ALTER TABLE `tbl_form_fields_value` ADD FULLTEXT KEY `element_value` (`element_value`);

--
-- Indexes for table `tbl_genders`
--
ALTER TABLE `tbl_genders`
  ADD PRIMARY KEY (`gender_id`);

--
-- Indexes for table `tbl_genders_desc`
--
ALTER TABLE `tbl_genders_desc`
  ADD UNIQUE KEY `gendarName` (`gender_id`,`language_id`);

--
-- Indexes for table `tbl_global_settings`
--
ALTER TABLE `tbl_global_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `globalSettings` (`parameter`);

--
-- Indexes for table `tbl_groups`
--
ALTER TABLE `tbl_groups`
  ADD PRIMARY KEY (`group_id`),
  ADD KEY `status` (`status`),
  ADD KEY `email_notification` (`email_notification`),
  ADD KEY `group_privacy` (`group_privacy`),
  ADD KEY `activity_id` (`activity_id`),
  ADD KEY `group_type_id` (`group_type_id`),
  ADD KEY `archive` (`archive`);

--
-- Indexes for table `tbl_group_domain`
--
ALTER TABLE `tbl_group_domain`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_group_files`
--
ALTER TABLE `tbl_group_files`
  ADD PRIMARY KEY (`file_id`);

--
-- Indexes for table `tbl_group_projects`
--
ALTER TABLE `tbl_group_projects`
  ADD KEY `TGP_indexing` (`group_id`,`project_id`),
  ADD KEY `idx_tgp_project` (`project_id`),
  ADD KEY `idx_tgp_group` (`group_id`),
  ADD KEY `idx_project_group` (`project_id`,`group_id`);

--
-- Indexes for table `tbl_group_release`
--
ALTER TABLE `tbl_group_release`
  ADD PRIMARY KEY (`release_id`);

--
-- Indexes for table `tbl_group_role`
--
ALTER TABLE `tbl_group_role`
  ADD UNIQUE KEY `group_id` (`group_id`,`role_id`);

--
-- Indexes for table `tbl_group_task_income_var`
--
ALTER TABLE `tbl_group_task_income_var`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_group_topics`
--
ALTER TABLE `tbl_group_topics`
  ADD PRIMARY KEY (`group_topic_id`);

--
-- Indexes for table `tbl_group_types`
--
ALTER TABLE `tbl_group_types`
  ADD PRIMARY KEY (`group_type_id`),
  ADD KEY `groupTypeParent` (`parent_id`);

--
-- Indexes for table `tbl_group_types_desc`
--
ALTER TABLE `tbl_group_types_desc`
  ADD UNIQUE KEY `group_type_id` (`group_type_id`);

--
-- Indexes for table `tbl_group_users`
--
ALTER TABLE `tbl_group_users`
  ADD UNIQUE KEY `groupUsers` (`group_id`,`user_id`),
  ADD KEY `request_status` (`request_status`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `group_id` (`group_id`);

--
-- Indexes for table `tbl_homepage`
--
ALTER TABLE `tbl_homepage`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_ims`
--
ALTER TABLE `tbl_ims`
  ADD PRIMARY KEY (`im_id`);

--
-- Indexes for table `tbl_ims_desc`
--
ALTER TABLE `tbl_ims_desc`
  ADD UNIQUE KEY `imsName` (`im_id`,`language_id`);

--
-- Indexes for table `tbl_interests`
--
ALTER TABLE `tbl_interests`
  ADD PRIMARY KEY (`interest_id`);

--
-- Indexes for table `tbl_interests_desc`
--
ALTER TABLE `tbl_interests_desc`
  ADD UNIQUE KEY `interestsName` (`interest_id`,`language_id`);

--
-- Indexes for table `tbl_ipignorelist`
--
ALTER TABLE `tbl_ipignorelist`
  ADD PRIMARY KEY (`ignore_id`);

--
-- Indexes for table `tbl_iplist`
--
ALTER TABLE `tbl_iplist`
  ADD PRIMARY KEY (`ip_id`);

--
-- Indexes for table `tbl_jobs`
--
ALTER TABLE `tbl_jobs`
  ADD PRIMARY KEY (`job_id`),
  ADD KEY `level_id` (`level_id`);

--
-- Indexes for table `tbl_languages`
--
ALTER TABLE `tbl_languages`
  ADD PRIMARY KEY (`language_id`),
  ADD UNIQUE KEY `languageCode` (`language_code`);

--
-- Indexes for table `tbl_lineitem_assumption`
--
ALTER TABLE `tbl_lineitem_assumption`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_lineitem_category`
--
ALTER TABLE `tbl_lineitem_category`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `tbl_lineitem_priority`
--
ALTER TABLE `tbl_lineitem_priority`
  ADD PRIMARY KEY (`priority_id`);

--
-- Indexes for table `tbl_lineitem_techstack`
--
ALTER TABLE `tbl_lineitem_techstack`
  ADD PRIMARY KEY (`techstack_id`);

--
-- Indexes for table `tbl_locations`
--
ALTER TABLE `tbl_locations`
  ADD PRIMARY KEY (`location_id`),
  ADD KEY `locationIndex` (`country_id`,`status`,`verified`);

--
-- Indexes for table `tbl_locations_desc`
--
ALTER TABLE `tbl_locations_desc`
  ADD KEY `locationIndex` (`language_id`,`country_id`,`status`,`verified`,`location_id`),
  ADD KEY `location_id` (`location_id`);
ALTER TABLE `tbl_locations_desc` ADD FULLTEXT KEY `cityName` (`city`);

--
-- Indexes for table `tbl_login_attempts`
--
ALTER TABLE `tbl_login_attempts`
  ADD KEY `user_id` (`user_id`,`user_type`),
  ADD KEY `user_id_single` (`user_id`);

--
-- Indexes for table `tbl_login_history`
--
ALTER TABLE `tbl_login_history`
  ADD PRIMARY KEY (`session_id`);

--
-- Indexes for table `tbl_log_comment_mail`
--
ALTER TABLE `tbl_log_comment_mail`
  ADD PRIMARY KEY (`id`),
  ADD KEY `type` (`type`(10));

--
-- Indexes for table `tbl_log_external_mails`
--
ALTER TABLE `tbl_log_external_mails`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_log_mails`
--
ALTER TABLE `tbl_log_mails`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_mails`
--
ALTER TABLE `tbl_mails`
  ADD PRIMARY KEY (`mail_id`),
  ADD UNIQUE KEY `mailCode` (`mail_code`);

--
-- Indexes for table `tbl_mails_backup`
--
ALTER TABLE `tbl_mails_backup`
  ADD PRIMARY KEY (`mail_id`),
  ADD UNIQUE KEY `mailCode` (`mail_code`);

--
-- Indexes for table `tbl_mails_desc`
--
ALTER TABLE `tbl_mails_desc`
  ADD PRIMARY KEY (`mail_content_id`),
  ADD UNIQUE KEY `mailContentIndex` (`mail_id`,`language_id`);

--
-- Indexes for table `tbl_mails_desc_live`
--
ALTER TABLE `tbl_mails_desc_live`
  ADD PRIMARY KEY (`mail_content_id`),
  ADD UNIQUE KEY `mailContentIndex` (`mail_id`,`language_id`);

--
-- Indexes for table `tbl_mails_live`
--
ALTER TABLE `tbl_mails_live`
  ADD PRIMARY KEY (`mail_id`),
  ADD UNIQUE KEY `mailCode` (`mail_code`);

--
-- Indexes for table `tbl_master_skills`
--
ALTER TABLE `tbl_master_skills`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_master_skills_back`
--
ALTER TABLE `tbl_master_skills_back`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_menu_settings`
--
ALTER TABLE `tbl_menu_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_meta`
--
ALTER TABLE `tbl_meta`
  ADD PRIMARY KEY (`meta_tag_id`);

--
-- Indexes for table `tbl_meta_desc`
--
ALTER TABLE `tbl_meta_desc`
  ADD KEY `metaIndex` (`meta_tag_id`);

--
-- Indexes for table `tbl_notifications`
--
ALTER TABLE `tbl_notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `notified_by` (`notified_by`),
  ADD KEY `notified_to` (`notified_to`),
  ADD KEY `status` (`status`),
  ADD KEY `post_date` (`post_date`);

--
-- Indexes for table `tbl_notification_settings`
--
ALTER TABLE `tbl_notification_settings`
  ADD PRIMARY KEY (`setting_id`),
  ADD UNIQUE KEY `mail_code` (`mail_code`),
  ADD KEY `section` (`section`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `tbl_notification_types`
--
ALTER TABLE `tbl_notification_types`
  ADD PRIMARY KEY (`notification_type_id`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `tbl_notification_types_desc`
--
ALTER TABLE `tbl_notification_types_desc`
  ADD UNIQUE KEY `notification_type_id` (`notification_type_id`);

--
-- Indexes for table `tbl_opportunity`
--
ALTER TABLE `tbl_opportunity`
  ADD PRIMARY KEY (`opportunity_id`);

--
-- Indexes for table `tbl_opportunity_tangible`
--
ALTER TABLE `tbl_opportunity_tangible`
  ADD PRIMARY KEY (`tangible_id`);

--
-- Indexes for table `tbl_password_histories`
--
ALTER TABLE `tbl_password_histories`
  ADD KEY `post_date` (`post_date`),
  ADD KEY `user_id_single` (`user_id`),
  ADD KEY `user_post_date` (`user_id`,`post_date`);

--
-- Indexes for table `tbl_photos`
--
ALTER TABLE `tbl_photos`
  ADD PRIMARY KEY (`photo_id`),
  ADD UNIQUE KEY `photoUsers` (`activity_id`,`user_id`),
  ADD KEY `group_id` (`group_id`);

--
-- Indexes for table `tbl_photos_users`
--
ALTER TABLE `tbl_photos_users`
  ADD PRIMARY KEY (`photo_tag_id`);

--
-- Indexes for table `tbl_pms_issues`
--
ALTER TABLE `tbl_pms_issues`
  ADD PRIMARY KEY (`issue_id`);

--
-- Indexes for table `tbl_pms_issue_audit_trails`
--
ALTER TABLE `tbl_pms_issue_audit_trails`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_pms_issue_types`
--
ALTER TABLE `tbl_pms_issue_types`
  ADD PRIMARY KEY (`type_id`);

--
-- Indexes for table `tbl_privacy_rules`
--
ALTER TABLE `tbl_privacy_rules`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_process_issue_analysis`
--
ALTER TABLE `tbl_process_issue_analysis`
  ADD PRIMARY KEY (`issue_analysis_id`);

--
-- Indexes for table `tbl_projects`
--
ALTER TABLE `tbl_projects`
  ADD PRIMARY KEY (`project_id`),
  ADD KEY `idx_projects_archive` (`project_id`,`archive`,`short_url`,`project_owner_id`) USING BTREE,
  ADD KEY `idx_project_id` (`project_id`),
  ADD KEY `idx_project_unique_id` (`project_unique_id`),
  ADD KEY `idx_tp_archive` (`archive`),
  ADD KEY `idx_project_master` (`master_project_id`),
  ADD KEY `idx_project_parent` (`parent_id`),
  ADD KEY `idx_archive_project` (`project_id`,`archive`);

--
-- Indexes for table `tbl_projects_backup_n`
--
ALTER TABLE `tbl_projects_backup_n`
  ADD PRIMARY KEY (`project_id`),
  ADD UNIQUE KEY `short_url` (`short_url`);

--
-- Indexes for table `tbl_project_audit_fields`
--
ALTER TABLE `tbl_project_audit_fields`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_project_department`
--
ALTER TABLE `tbl_project_department`
  ADD PRIMARY KEY (`department_id`);

--
-- Indexes for table `tbl_project_documents`
--
ALTER TABLE `tbl_project_documents`
  ADD PRIMARY KEY (`document_id`);

--
-- Indexes for table `tbl_project_estimation`
--
ALTER TABLE `tbl_project_estimation`
  ADD PRIMARY KEY (`estimation_id`);

--
-- Indexes for table `tbl_project_estimation_audit_trails`
--
ALTER TABLE `tbl_project_estimation_audit_trails`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_project_estimation_lineitem_map`
--
ALTER TABLE `tbl_project_estimation_lineitem_map`
  ADD PRIMARY KEY (`el_id`);

--
-- Indexes for table `tbl_project_estimation_status`
--
ALTER TABLE `tbl_project_estimation_status`
  ADD PRIMARY KEY (`rca_status_id`);

--
-- Indexes for table `tbl_project_executive_summary`
--
ALTER TABLE `tbl_project_executive_summary`
  ADD PRIMARY KEY (`executive_id`);

--
-- Indexes for table `tbl_project_files`
--
ALTER TABLE `tbl_project_files`
  ADD PRIMARY KEY (`file_id`);

--
-- Indexes for table `tbl_project_impact`
--
ALTER TABLE `tbl_project_impact`
  ADD PRIMARY KEY (`impact_id`),
  ADD UNIQUE KEY `TPI_indexing` (`impact_id`);

--
-- Indexes for table `tbl_project_infrastructure_audit_trails`
--
ALTER TABLE `tbl_project_infrastructure_audit_trails`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_project_infrastructure_planning`
--
ALTER TABLE `tbl_project_infrastructure_planning`
  ADD PRIMARY KEY (`infrastructure_planning_id`);

--
-- Indexes for table `tbl_project_infrastructure_planning_status`
--
ALTER TABLE `tbl_project_infrastructure_planning_status`
  ADD PRIMARY KEY (`rca_status_id`),
  ADD KEY `project_id` (`project_id`),
  ADD KEY `status_index` (`status`);

--
-- Indexes for table `tbl_project_infrastructure_requirements_status`
--
ALTER TABLE `tbl_project_infrastructure_requirements_status`
  ADD PRIMARY KEY (`rca_status_id`),
  ADD KEY `project_id` (`project_id`),
  ADD KEY `status_index` (`status`);

--
-- Indexes for table `tbl_project_initiation_areas`
--
ALTER TABLE `tbl_project_initiation_areas`
  ADD PRIMARY KEY (`area_id`);

--
-- Indexes for table `tbl_project_initiation_check_points`
--
ALTER TABLE `tbl_project_initiation_check_points`
  ADD PRIMARY KEY (`check_point_id`);

--
-- Indexes for table `tbl_project_initiation_records`
--
ALTER TABLE `tbl_project_initiation_records`
  ADD PRIMARY KEY (`project_initiation_record_id`);

--
-- Indexes for table `tbl_project_issues`
--
ALTER TABLE `tbl_project_issues`
  ADD PRIMARY KEY (`issue_id`),
  ADD KEY `TPI_indexing` (`project_id`,`attention_required`,`status`),
  ADD KEY `idx_tpi_status` (`status`),
  ADD KEY `idx_tpi_attention_required` (`attention_required`),
  ADD KEY `idx_tpi_project` (`project_id`),
  ADD KEY `idx_ipi_issue` (`issue_id`),
  ADD KEY `TPi_issue_status_id` (`issue_status_id`),
  ADD KEY `TPi_impact_id` (`impact_id`),
  ADD KEY `idx_status_project_issue` (`status`,`project_id`,`issue_id`),
  ADD KEY `idx_issue_status_project` (`issue_id`,`status`,`project_id`);

--
-- Indexes for table `tbl_project_issue_comment_users`
--
ALTER TABLE `tbl_project_issue_comment_users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_project_issue_status`
--
ALTER TABLE `tbl_project_issue_status`
  ADD PRIMARY KEY (`issue_status_id`),
  ADD UNIQUE KEY `TPIS_indexing` (`issue_status_id`,`project_id`,`status`);

--
-- Indexes for table `tbl_project_issue_types`
--
ALTER TABLE `tbl_project_issue_types`
  ADD PRIMARY KEY (`type_id`);

--
-- Indexes for table `tbl_project_issue_users`
--
ALTER TABLE `tbl_project_issue_users`
  ADD KEY `idx_issue_user_status` (`user_id`,`status`,`issue_id`);

--
-- Indexes for table `tbl_project_issue_views`
--
ALTER TABLE `tbl_project_issue_views`
  ADD UNIQUE KEY `task_user_id` (`issue_id`,`user_id`);

--
-- Indexes for table `tbl_project_lineitem`
--
ALTER TABLE `tbl_project_lineitem`
  ADD PRIMARY KEY (`item_id`);

--
-- Indexes for table `tbl_project_priority`
--
ALTER TABLE `tbl_project_priority`
  ADD PRIMARY KEY (`priority_id`);

--
-- Indexes for table `tbl_project_process_issue`
--
ALTER TABLE `tbl_project_process_issue`
  ADD PRIMARY KEY (`process_issue_id`);

--
-- Indexes for table `tbl_project_rca`
--
ALTER TABLE `tbl_project_rca`
  ADD PRIMARY KEY (`rca_id`),
  ADD KEY `project_id` (`project_id`),
  ADD KEY `active_inactive_status` (`status`),
  ADD KEY `parentId` (`incident_no`),
  ADD KEY `taskStatus` (`rca_status_id`),
  ADD KEY `parent_id` (`incident_no`),
  ADD KEY `parent_id_2` (`incident_no`),
  ADD KEY `task_id` (`rca_id`);

--
-- Indexes for table `tbl_project_rca_audit_trails`
--
ALTER TABLE `tbl_project_rca_audit_trails`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_project_rca_internal_users`
--
ALTER TABLE `tbl_project_rca_internal_users`
  ADD UNIQUE KEY `task_user` (`rca_id`,`user_id`);

--
-- Indexes for table `tbl_project_rca_owners`
--
ALTER TABLE `tbl_project_rca_owners`
  ADD UNIQUE KEY `task_user` (`rca_id`,`user_id`);

--
-- Indexes for table `tbl_project_rca_status`
--
ALTER TABLE `tbl_project_rca_status`
  ADD PRIMARY KEY (`rca_status_id`),
  ADD KEY `project_id` (`project_id`),
  ADD KEY `status_index` (`status`);

--
-- Indexes for table `tbl_project_rca_users`
--
ALTER TABLE `tbl_project_rca_users`
  ADD UNIQUE KEY `task_user` (`rca_id`,`user_id`);

--
-- Indexes for table `tbl_project_release`
--
ALTER TABLE `tbl_project_release`
  ADD PRIMARY KEY (`release_id`),
  ADD KEY `idx_project_release_release_id` (`release_id`,`project_id`,`parent_id`,`release_status_id`,`post_date`,`release_date`,`status`);

--
-- Indexes for table `tbl_project_repositories`
--
ALTER TABLE `tbl_project_repositories`
  ADD PRIMARY KEY (`repo_id`);

--
-- Indexes for table `tbl_project_repository_access`
--
ALTER TABLE `tbl_project_repository_access`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_project_risk`
--
ALTER TABLE `tbl_project_risk`
  ADD PRIMARY KEY (`project_risk_id`);

--
-- Indexes for table `tbl_project_risk_audit_trails`
--
ALTER TABLE `tbl_project_risk_audit_trails`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_project_risk_status`
--
ALTER TABLE `tbl_project_risk_status`
  ADD PRIMARY KEY (`risk_status_id`);

--
-- Indexes for table `tbl_project_stages`
--
ALTER TABLE `tbl_project_stages`
  ADD PRIMARY KEY (`stage_id`);

--
-- Indexes for table `tbl_project_status`
--
ALTER TABLE `tbl_project_status`
  ADD PRIMARY KEY (`status_id`);

--
-- Indexes for table `tbl_project_status_history`
--
ALTER TABLE `tbl_project_status_history`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_project_tasks`
--
ALTER TABLE `tbl_project_tasks`
  ADD PRIMARY KEY (`task_id`),
  ADD KEY `idx_tasks_status_parent_post` (`task_id`,`project_id`,`parent_id`,`task_status_id`,`post_date`,`status`) USING BTREE,
  ADD KEY `idx_only_parent` (`parent_id`),
  ADD KEY `idx_task_id` (`task_id`),
  ADD KEY `idx_date` (`start_date`),
  ADD KEY `idx_project_status_task_parent` (`project_id`,`status`,`task_id`,`parent_id`),
  ADD KEY `idx_task_project_status` (`project_id`,`task_status_id`,`status`),
  ADD KEY `idx_status_parent_task_project` (`status`,`parent_id`,`task_id`,`project_id`),
  ADD KEY `idx_project_status_parent_zero` (`project_id`,`status`,`parent_id`);

--
-- Indexes for table `tbl_project_tasks_17_07_25`
--
ALTER TABLE `tbl_project_tasks_17_07_25`
  ADD PRIMARY KEY (`task_id`),
  ADD KEY `idx_tasks_status_parent_post` (`task_id`,`project_id`,`parent_id`,`task_status_id`,`post_date`,`status`) USING BTREE,
  ADD KEY `idx_only_parent` (`parent_id`),
  ADD KEY `idx_task_id` (`task_id`),
  ADD KEY `idx_date` (`start_date`);

--
-- Indexes for table `tbl_project_tasks_audit_trails`
--
ALTER TABLE `tbl_project_tasks_audit_trails`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_project_tasks_bkp`
--
ALTER TABLE `tbl_project_tasks_bkp`
  ADD PRIMARY KEY (`task_id`),
  ADD KEY `idx_tasks_status_parent_post` (`task_id`,`project_id`,`parent_id`,`task_status_id`,`post_date`,`status`) USING BTREE,
  ADD KEY `idx_only_parent` (`parent_id`),
  ADD KEY `idx_task_id` (`task_id`),
  ADD KEY `idx_date` (`start_date`);

--
-- Indexes for table `tbl_project_tasks_chargeable_logs`
--
ALTER TABLE `tbl_project_tasks_chargeable_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_project_tasks_history`
--
ALTER TABLE `tbl_project_tasks_history`
  ADD KEY `post_date` (`post_date`),
  ADD KEY `task_status_id` (`task_status_id`);

--
-- Indexes for table `tbl_project_tasks_prompt`
--
ALTER TABLE `tbl_project_tasks_prompt`
  ADD PRIMARY KEY (`prompt_id`);

--
-- Indexes for table `tbl_project_task_comment_users`
--
ALTER TABLE `tbl_project_task_comment_users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ptcu` (`task_id`,`user_id`);

--
-- Indexes for table `tbl_project_task_dependent_comment`
--
ALTER TABLE `tbl_project_task_dependent_comment`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_project_task_milestone`
--
ALTER TABLE `tbl_project_task_milestone`
  ADD PRIMARY KEY (`milestone_id`);

--
-- Indexes for table `tbl_project_task_milestone_mapping`
--
ALTER TABLE `tbl_project_task_milestone_mapping`
  ADD UNIQUE KEY `milestone_project_task` (`milestone_id`,`project_id`,`task_id`);

--
-- Indexes for table `tbl_project_task_status`
--
ALTER TABLE `tbl_project_task_status`
  ADD PRIMARY KEY (`task_status_id`),
  ADD KEY `idx_task_status_id` (`task_status_id`,`project_id`,`status`);

--
-- Indexes for table `tbl_project_task_types`
--
ALTER TABLE `tbl_project_task_types`
  ADD PRIMARY KEY (`type_id`);

--
-- Indexes for table `tbl_project_task_users`
--
ALTER TABLE `tbl_project_task_users`
  ADD KEY `idx_task_users_user_status` (`user_id`,`status`,`task_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_task_id` (`task_id`);

--
-- Indexes for table `tbl_project_task_views`
--
ALTER TABLE `tbl_project_task_views`
  ADD UNIQUE KEY `task_user_id` (`task_id`,`user_id`);

--
-- Indexes for table `tbl_project_team`
--
ALTER TABLE `tbl_project_team`
  ADD PRIMARY KEY (`team_id`);

--
-- Indexes for table `tbl_project_topics`
--
ALTER TABLE `tbl_project_topics`
  ADD PRIMARY KEY (`project_topic_id`);

--
-- Indexes for table `tbl_project_types`
--
ALTER TABLE `tbl_project_types`
  ADD PRIMARY KEY (`project_type_id`);

--
-- Indexes for table `tbl_project_users`
--
ALTER TABLE `tbl_project_users`
  ADD UNIQUE KEY `project_user` (`project_id`,`user_id`),
  ADD KEY `idx_project_request_status` (`project_id`,`request_status`,`status`,`user_id`);

--
-- Indexes for table `tbl_project_users_log`
--
ALTER TABLE `tbl_project_users_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_promotion`
--
ALTER TABLE `tbl_promotion`
  ADD PRIMARY KEY (`promotion_id`);

--
-- Indexes for table `tbl_promotion_desc`
--
ALTER TABLE `tbl_promotion_desc`
  ADD UNIQUE KEY `promotion_id` (`promotion_id`,`share_type`,`share_id`);

--
-- Indexes for table `tbl_qa`
--
ALTER TABLE `tbl_qa`
  ADD PRIMARY KEY (`qa_id`);

--
-- Indexes for table `tbl_qa_attachment`
--
ALTER TABLE `tbl_qa_attachment`
  ADD PRIMARY KEY (`attach_id`);

--
-- Indexes for table `tbl_qa_category`
--
ALTER TABLE `tbl_qa_category`
  ADD PRIMARY KEY (`category_id`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `status` (`status`),
  ADD KEY `group_id_status` (`status`,`group_id`);

--
-- Indexes for table `tbl_qa_process`
--
ALTER TABLE `tbl_qa_process`
  ADD PRIMARY KEY (`process_id`),
  ADD KEY `status_point` (`status_point`);

--
-- Indexes for table `tbl_qa_questions`
--
ALTER TABLE `tbl_qa_questions`
  ADD PRIMARY KEY (`question_id`),
  ADD UNIQUE KEY `question_user_activity` (`question_id`,`user_id`,`activity_id`),
  ADD KEY `challenge_flag` (`challenge_flag`),
  ADD KEY `user_id` (`user_id`);
ALTER TABLE `tbl_qa_questions` ADD FULLTEXT KEY `question` (`question`);

--
-- Indexes for table `tbl_qa_status_history`
--
ALTER TABLE `tbl_qa_status_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `question_id` (`question_id`),
  ADD KEY `status` (`status`),
  ADD KEY `post_date` (`post_date`);

--
-- Indexes for table `tbl_qa_votes`
--
ALTER TABLE `tbl_qa_votes`
  ADD UNIQUE KEY `userQAVote` (`question_id`,`user_id`,`vote`);

--
-- Indexes for table `tbl_qualifications`
--
ALTER TABLE `tbl_qualifications`
  ADD PRIMARY KEY (`qualification_id`),
  ADD KEY `educationLevel` (`level_of_education_id`);

--
-- Indexes for table `tbl_qualifications_desc`
--
ALTER TABLE `tbl_qualifications_desc`
  ADD UNIQUE KEY `qualificationName` (`qualification_id`,`language_id`);

--
-- Indexes for table `tbl_rca_severity`
--
ALTER TABLE `tbl_rca_severity`
  ADD PRIMARY KEY (`severity_id`);

--
-- Indexes for table `tbl_read_histories`
--
ALTER TABLE `tbl_read_histories`
  ADD KEY `groupSearch` (`group_id`,`readtime`) USING BTREE,
  ADD KEY `projectSearch` (`project_id`,`readtime`) USING BTREE;

--
-- Indexes for table `tbl_regions`
--
ALTER TABLE `tbl_regions`
  ADD PRIMARY KEY (`region_id`);

--
-- Indexes for table `tbl_release_status`
--
ALTER TABLE `tbl_release_status`
  ADD PRIMARY KEY (`release_status_id`);

--
-- Indexes for table `tbl_reminder`
--
ALTER TABLE `tbl_reminder`
  ADD PRIMARY KEY (`reminder_id`);

--
-- Indexes for table `tbl_review`
--
ALTER TABLE `tbl_review`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `review_date` (`review_date`),
  ADD KEY `reviewer_id` (`reviewer_id`);

--
-- Indexes for table `tbl_risk`
--
ALTER TABLE `tbl_risk`
  ADD PRIMARY KEY (`risk_id`);

--
-- Indexes for table `tbl_risk_action`
--
ALTER TABLE `tbl_risk_action`
  ADD PRIMARY KEY (`action_id`);

--
-- Indexes for table `tbl_risk_bkp`
--
ALTER TABLE `tbl_risk_bkp`
  ADD PRIMARY KEY (`risk_id`);

--
-- Indexes for table `tbl_risk_category`
--
ALTER TABLE `tbl_risk_category`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `tbl_risk_impact`
--
ALTER TABLE `tbl_risk_impact`
  ADD PRIMARY KEY (`impact_id`);

--
-- Indexes for table `tbl_risk_mitigation_actions`
--
ALTER TABLE `tbl_risk_mitigation_actions`
  ADD PRIMARY KEY (`mitigation_action_id`);

--
-- Indexes for table `tbl_risk_priority`
--
ALTER TABLE `tbl_risk_priority`
  ADD PRIMARY KEY (`risk_priority_id`);

--
-- Indexes for table `tbl_risk_probability`
--
ALTER TABLE `tbl_risk_probability`
  ADD PRIMARY KEY (`probability_id`);

--
-- Indexes for table `tbl_risk_response`
--
ALTER TABLE `tbl_risk_response`
  ADD PRIMARY KEY (`response_id`);

--
-- Indexes for table `tbl_risk_status`
--
ALTER TABLE `tbl_risk_status`
  ADD PRIMARY KEY (`status_id`);

--
-- Indexes for table `tbl_risk_update`
--
ALTER TABLE `tbl_risk_update`
  ADD PRIMARY KEY (`update_id`);

--
-- Indexes for table `tbl_roles`
--
ALTER TABLE `tbl_roles`
  ADD PRIMARY KEY (`role_id`);

--
-- Indexes for table `tbl_roles_back`
--
ALTER TABLE `tbl_roles_back`
  ADD PRIMARY KEY (`role_id`);

--
-- Indexes for table `tbl_rt_category`
--
ALTER TABLE `tbl_rt_category`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `tbl_rt_env_details`
--
ALTER TABLE `tbl_rt_env_details`
  ADD UNIQUE KEY `ticket_id` (`ticket_id`);

--
-- Indexes for table `tbl_rt_file`
--
ALTER TABLE `tbl_rt_file`
  ADD PRIMARY KEY (`file_id`);

--
-- Indexes for table `tbl_rt_merge_history`
--
ALTER TABLE `tbl_rt_merge_history`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_rt_merge_thread_notification`
--
ALTER TABLE `tbl_rt_merge_thread_notification`
  ADD UNIQUE KEY `ticket_type_id` (`ticket_id`,`merge_type`,`type_id`);

--
-- Indexes for table `tbl_rt_notifications`
--
ALTER TABLE `tbl_rt_notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `ticket_id` (`ticket_id`);

--
-- Indexes for table `tbl_rt_notification_types`
--
ALTER TABLE `tbl_rt_notification_types`
  ADD PRIMARY KEY (`notification_type_id`);

--
-- Indexes for table `tbl_rt_notification_types_desc`
--
ALTER TABLE `tbl_rt_notification_types_desc`
  ADD PRIMARY KEY (`notification_type_id`);

--
-- Indexes for table `tbl_rt_priority`
--
ALTER TABLE `tbl_rt_priority`
  ADD PRIMARY KEY (`priority_id`);

--
-- Indexes for table `tbl_rt_status`
--
ALTER TABLE `tbl_rt_status`
  ADD PRIMARY KEY (`status_id`);

--
-- Indexes for table `tbl_rt_status_history`
--
ALTER TABLE `tbl_rt_status_history`
  ADD PRIMARY KEY (`history_id`);

--
-- Indexes for table `tbl_rt_support`
--
ALTER TABLE `tbl_rt_support`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `reference_id` (`reference_id`),
  ADD KEY `status` (`status`),
  ADD KEY `ticket_status` (`ticket_status`);

--
-- Indexes for table `tbl_rt_support_thread`
--
ALTER TABLE `tbl_rt_support_thread`
  ADD PRIMARY KEY (`thread_id`),
  ADD KEY `ticket_id` (`ticket_id`),
  ADD KEY `subject` (`subject`(255));

--
-- Indexes for table `tbl_save_search`
--
ALTER TABLE `tbl_save_search`
  ADD PRIMARY KEY (`search_id`);

--
-- Indexes for table `tbl_search`
--
ALTER TABLE `tbl_search`
  ADD PRIMARY KEY (`id`),
  ADD KEY `groupId` (`group_id`),
  ADD KEY `projectId` (`project_id`);
ALTER TABLE `tbl_search` ADD FULLTEXT KEY `search` (`search`);

--
-- Indexes for table `tbl_sessions`
--
ALTER TABLE `tbl_sessions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_settings`
--
ALTER TABLE `tbl_settings`
  ADD PRIMARY KEY (`setting_id`),
  ADD UNIQUE KEY `settingsCode` (`code`);

--
-- Indexes for table `tbl_short_url`
--
ALTER TABLE `tbl_short_url`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `shortCode` (`code`),
  ADD KEY `URL` (`url`);

--
-- Indexes for table `tbl_site_search`
--
ALTER TABLE `tbl_site_search`
  ADD PRIMARY KEY (`id`),
  ADD KEY `searchIndex` (`sname`,`language_id`),
  ADD KEY `stype` (`stype`);

--
-- Indexes for table `tbl_static_modules`
--
ALTER TABLE `tbl_static_modules`
  ADD PRIMARY KEY (`module_id`);

--
-- Indexes for table `tbl_static_text`
--
ALTER TABLE `tbl_static_text`
  ADD PRIMARY KEY (`static_id`);

--
-- Indexes for table `tbl_subscriptions`
--
ALTER TABLE `tbl_subscriptions`
  ADD PRIMARY KEY (`subscription_id`);

--
-- Indexes for table `tbl_sub_todo_list`
--
ALTER TABLE `tbl_sub_todo_list`
  ADD PRIMARY KEY (`subtodo_id`);

--
-- Indexes for table `tbl_support`
--
ALTER TABLE `tbl_support`
  ADD PRIMARY KEY (`support_id`);

--
-- Indexes for table `tbl_support_category`
--
ALTER TABLE `tbl_support_category`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `tbl_support_details`
--
ALTER TABLE `tbl_support_details`
  ADD PRIMARY KEY (`group_id`);

--
-- Indexes for table `tbl_support_reply`
--
ALTER TABLE `tbl_support_reply`
  ADD PRIMARY KEY (`support_id`);

--
-- Indexes for table `tbl_tags`
--
ALTER TABLE `tbl_tags`
  ADD PRIMARY KEY (`tag_id`);

--
-- Indexes for table `tbl_tasktype`
--
ALTER TABLE `tbl_tasktype`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_task_date_history`
--
ALTER TABLE `tbl_task_date_history`
  ADD PRIMARY KEY (`history_id`);

--
-- Indexes for table `tbl_task_insights`
--
ALTER TABLE `tbl_task_insights`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_task_release`
--
ALTER TABLE `tbl_task_release`
  ADD KEY `idx_task_release_task_id` (`release_id`,`task_id`);

--
-- Indexes for table `tbl_test_api_data`
--
ALTER TABLE `tbl_test_api_data`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_timesheets`
--
ALTER TABLE `tbl_timesheets`
  ADD PRIMARY KEY (`timesheet_id`),
  ADD KEY `taskID` (`task_id`) USING BTREE,
  ADD KEY `todoID` (`todo_id`),
  ADD KEY `idx_user_date_todo` (`user_id`,`timesheet_date`,`todo_id`);

--
-- Indexes for table `tbl_todo_list`
--
ALTER TABLE `tbl_todo_list`
  ADD PRIMARY KEY (`todo_id`),
  ADD KEY `idx_user_status` (`user_id`,`status`);

--
-- Indexes for table `tbl_tooltip`
--
ALTER TABLE `tbl_tooltip`
  ADD PRIMARY KEY (`tooltip_id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `tbl_tview_list`
--
ALTER TABLE `tbl_tview_list`
  ADD PRIMARY KEY (`list_id`);

--
-- Indexes for table `tbl_tview_list_settings`
--
ALTER TABLE `tbl_tview_list_settings`
  ADD PRIMARY KEY (`setting_id`);

--
-- Indexes for table `tbl_tview_release_settings`
--
ALTER TABLE `tbl_tview_release_settings`
  ADD PRIMARY KEY (`setting_id`);

--
-- Indexes for table `tbl_tview_saved_search`
--
ALTER TABLE `tbl_tview_saved_search`
  ADD PRIMARY KEY (`save_search_id`);

--
-- Indexes for table `tbl_url_tracks`
--
ALTER TABLE `tbl_url_tracks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `session_id` (`session_id`),
  ADD KEY `mobile_device` (`mobile_device`);

--
-- Indexes for table `tbl_users`
--
ALTER TABLE `tbl_users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `UNIQUE` (`email`),
  ADD KEY `activeStatus` (`enabled`,`verified`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `job_id` (`job_id`),
  ADD KEY `role_id` (`role_id`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- Indexes for table `tbl_users_backup`
--
ALTER TABLE `tbl_users_backup`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `UNIQUE` (`email`),
  ADD KEY `activeStatus` (`enabled`,`verified`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `job_id` (`job_id`),
  ADD KEY `role_id` (`role_id`);

--
-- Indexes for table `tbl_user_account_history`
--
ALTER TABLE `tbl_user_account_history`
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `tbl_user_company`
--
ALTER TABLE `tbl_user_company`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_company_id` (`user_id`,`company_id`),
  ADD KEY `company_id` (`company_id`);

--
-- Indexes for table `tbl_user_journey`
--
ALTER TABLE `tbl_user_journey`
  ADD KEY `user_module_id` (`user_id`,`module_id`);

--
-- Indexes for table `tbl_user_photos`
--
ALTER TABLE `tbl_user_photos`
  ADD PRIMARY KEY (`user_photo_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `image_type` (`image_type`);

--
-- Indexes for table `tbl_user_settings`
--
ALTER TABLE `tbl_user_settings`
  ADD UNIQUE KEY `userID` (`user_id`);

--
-- Indexes for table `tbl_user_skills`
--
ALTER TABLE `tbl_user_skills`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_venue`
--
ALTER TABLE `tbl_venue`
  ADD PRIMARY KEY (`venue_id`);

--
-- Indexes for table `tbl_videos`
--
ALTER TABLE `tbl_videos`
  ADD PRIMARY KEY (`video_id`),
  ADD UNIQUE KEY `videoUsers` (`activity_id`,`user_id`);

--
-- Indexes for table `tbl_weekly_issue_status`
--
ALTER TABLE `tbl_weekly_issue_status`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_weekly_task_status`
--
ALTER TABLE `tbl_weekly_task_status`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_weekly_ticket_status`
--
ALTER TABLE `tbl_weekly_ticket_status`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_word_group`
--
ALTER TABLE `tbl_word_group`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_work_education_types`
--
ALTER TABLE `tbl_work_education_types`
  ADD PRIMARY KEY (`work_education_type_id`);

--
-- Indexes for table `tbl_work_edu_mapping`
--
ALTER TABLE `tbl_work_edu_mapping`
  ADD PRIMARY KEY (`rel_id`),
  ADD KEY `activityIndex` (`work_education_type_id`),
  ADD KEY `workIndex` (`type`),
  ADD KEY `educationIndex` (`title`),
  ADD KEY `pediaIndex` (`start_date`,`end_date`,`post_date`),
  ADD KEY `periodIndex` (`post_ip`);

--
-- Indexes for table `temp_all_task`
--
ALTER TABLE `temp_all_task`
  ADD KEY `task_id` (`task_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `department`
--
ALTER TABLE `department`
  MODIFY `group_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `project_infrastructure_requirements`
--
ALTER TABLE `project_infrastructure_requirements`
  MODIFY `requirements_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `project_infrastructure_requirements_audit_trails`
--
ALTER TABLE `project_infrastructure_requirements_audit_trails`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `project_requirements_lineitem`
--
ALTER TABLE `project_requirements_lineitem`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_activities`
--
ALTER TABLE `tbl_activities`
  MODIFY `activity_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_activity_types`
--
ALTER TABLE `tbl_activity_types`
  MODIFY `activity_type_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_admins`
--
ALTER TABLE `tbl_admins`
  MODIFY `admin_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_admin_groups`
--
ALTER TABLE `tbl_admin_groups`
  MODIFY `group_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_admin_sections`
--
ALTER TABLE `tbl_admin_sections`
  MODIFY `section_id` int NOT NULL AUTO_INCREMENT COMMENT 'Section ID';

--
-- AUTO_INCREMENT for table `tbl_agenda`
--
ALTER TABLE `tbl_agenda`
  MODIFY `agenda_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_albums`
--
ALTER TABLE `tbl_albums`
  MODIFY `album_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_announcements`
--
ALTER TABLE `tbl_announcements`
  MODIFY `announce_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_area_of_work`
--
ALTER TABLE `tbl_area_of_work`
  MODIFY `area_work_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Area of Work Auto ID';

--
-- AUTO_INCREMENT for table `tbl_attachment`
--
ALTER TABLE `tbl_attachment`
  MODIFY `file_id` int NOT NULL AUTO_INCREMENT COMMENT 'Auto Increment ID';

--
-- AUTO_INCREMENT for table `tbl_attachment_dl_log`
--
ALTER TABLE `tbl_attachment_dl_log`
  MODIFY `log_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_attachment_relation`
--
ALTER TABLE `tbl_attachment_relation`
  MODIFY `relation_id` int NOT NULL AUTO_INCREMENT COMMENT 'Primary Key';

--
-- AUTO_INCREMENT for table `tbl_available_for_info`
--
ALTER TABLE `tbl_available_for_info`
  MODIFY `available_for_id` int NOT NULL AUTO_INCREMENT COMMENT 'Store available for ID';

--
-- AUTO_INCREMENT for table `tbl_batch_notifications`
--
ALTER TABLE `tbl_batch_notifications`
  MODIFY `batch_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Batch ID';

--
-- AUTO_INCREMENT for table `tbl_bulletin`
--
ALTER TABLE `tbl_bulletin`
  MODIFY `bulletin_id` int NOT NULL AUTO_INCREMENT COMMENT 'Bulletin ID';

--
-- AUTO_INCREMENT for table `tbl_bulletin_category`
--
ALTER TABLE `tbl_bulletin_category`
  MODIFY `category_id` int NOT NULL AUTO_INCREMENT COMMENT 'Category id';

--
-- AUTO_INCREMENT for table `tbl_bulletin_comment`
--
ALTER TABLE `tbl_bulletin_comment`
  MODIFY `comment_id` int NOT NULL AUTO_INCREMENT COMMENT 'Comment id';

--
-- AUTO_INCREMENT for table `tbl_bulletin_tags`
--
ALTER TABLE `tbl_bulletin_tags`
  MODIFY `tag_id` int NOT NULL AUTO_INCREMENT COMMENT 'Tag id';

--
-- AUTO_INCREMENT for table `tbl_chat_broadcast_messages`
--
ALTER TABLE `tbl_chat_broadcast_messages`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_chat_groups`
--
ALTER TABLE `tbl_chat_groups`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_chat_group_messages`
--
ALTER TABLE `tbl_chat_group_messages`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_chat_messages`
--
ALTER TABLE `tbl_chat_messages`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_clients`
--
ALTER TABLE `tbl_clients`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_client_summary_report`
--
ALTER TABLE `tbl_client_summary_report`
  MODIFY `report_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_cms`
--
ALTER TABLE `tbl_cms`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_comments`
--
ALTER TABLE `tbl_comments`
  MODIFY `comment_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_comment_privacy`
--
ALTER TABLE `tbl_comment_privacy`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_companies`
--
ALTER TABLE `tbl_companies`
  MODIFY `company_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_contents`
--
ALTER TABLE `tbl_contents`
  MODIFY `content_id` int NOT NULL AUTO_INCREMENT COMMENT 'Page id';

--
-- AUTO_INCREMENT for table `tbl_contents_desc`
--
ALTER TABLE `tbl_contents_desc`
  MODIFY `content_desc_id` int NOT NULL AUTO_INCREMENT COMMENT 'Store content description ID';

--
-- AUTO_INCREMENT for table `tbl_countries`
--
ALTER TABLE `tbl_countries`
  MODIFY `country_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_discussion`
--
ALTER TABLE `tbl_discussion`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'store auto incremented ID';

--
-- AUTO_INCREMENT for table `tbl_ehs`
--
ALTER TABLE `tbl_ehs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_estimation_assumption_map`
--
ALTER TABLE `tbl_estimation_assumption_map`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_estimation_asumption`
--
ALTER TABLE `tbl_estimation_asumption`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_estimation_complexity`
--
ALTER TABLE `tbl_estimation_complexity`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_estimation_deliverables`
--
ALTER TABLE `tbl_estimation_deliverables`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_estimation_risks`
--
ALTER TABLE `tbl_estimation_risks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_estimation_summary`
--
ALTER TABLE `tbl_estimation_summary`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_events`
--
ALTER TABLE `tbl_events`
  MODIFY `event_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_event_dates`
--
ALTER TABLE `tbl_event_dates`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_fetched_mails`
--
ALTER TABLE `tbl_fetched_mails`
  MODIFY `mail_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Auto ID';

--
-- AUTO_INCREMENT for table `tbl_fetched_mails_attachments`
--
ALTER TABLE `tbl_fetched_mails_attachments`
  MODIFY `attachment_id` int NOT NULL AUTO_INCREMENT COMMENT 'primary key';

--
-- AUTO_INCREMENT for table `tbl_files`
--
ALTER TABLE `tbl_files`
  MODIFY `file_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_folder`
--
ALTER TABLE `tbl_folder`
  MODIFY `folder_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Folder ID';

--
-- AUTO_INCREMENT for table `tbl_folder_mapping`
--
ALTER TABLE `tbl_folder_mapping`
  MODIFY `map_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_follow`
--
ALTER TABLE `tbl_follow`
  MODIFY `follow_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_form_fields`
--
ALTER TABLE `tbl_form_fields`
  MODIFY `element_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Store Element ID';

--
-- AUTO_INCREMENT for table `tbl_genders`
--
ALTER TABLE `tbl_genders`
  MODIFY `gender_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_global_settings`
--
ALTER TABLE `tbl_global_settings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_groups`
--
ALTER TABLE `tbl_groups`
  MODIFY `group_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_group_domain`
--
ALTER TABLE `tbl_group_domain`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_group_files`
--
ALTER TABLE `tbl_group_files`
  MODIFY `file_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_group_release`
--
ALTER TABLE `tbl_group_release`
  MODIFY `release_id` int NOT NULL AUTO_INCREMENT COMMENT 'release_id';

--
-- AUTO_INCREMENT for table `tbl_group_task_income_var`
--
ALTER TABLE `tbl_group_task_income_var`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_group_topics`
--
ALTER TABLE `tbl_group_topics`
  MODIFY `group_topic_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_group_types`
--
ALTER TABLE `tbl_group_types`
  MODIFY `group_type_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_homepage`
--
ALTER TABLE `tbl_homepage`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_ims`
--
ALTER TABLE `tbl_ims`
  MODIFY `im_id` int NOT NULL AUTO_INCREMENT COMMENT 'IM id';

--
-- AUTO_INCREMENT for table `tbl_interests`
--
ALTER TABLE `tbl_interests`
  MODIFY `interest_id` int NOT NULL AUTO_INCREMENT COMMENT 'Store interest ID';

--
-- AUTO_INCREMENT for table `tbl_ipignorelist`
--
ALTER TABLE `tbl_ipignorelist`
  MODIFY `ignore_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_iplist`
--
ALTER TABLE `tbl_iplist`
  MODIFY `ip_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_jobs`
--
ALTER TABLE `tbl_jobs`
  MODIFY `job_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_languages`
--
ALTER TABLE `tbl_languages`
  MODIFY `language_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_lineitem_assumption`
--
ALTER TABLE `tbl_lineitem_assumption`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_lineitem_category`
--
ALTER TABLE `tbl_lineitem_category`
  MODIFY `category_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_lineitem_priority`
--
ALTER TABLE `tbl_lineitem_priority`
  MODIFY `priority_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_lineitem_techstack`
--
ALTER TABLE `tbl_lineitem_techstack`
  MODIFY `techstack_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_locations`
--
ALTER TABLE `tbl_locations`
  MODIFY `location_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_log_comment_mail`
--
ALTER TABLE `tbl_log_comment_mail`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'auto incremented id';

--
-- AUTO_INCREMENT for table `tbl_log_external_mails`
--
ALTER TABLE `tbl_log_external_mails`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'PK';

--
-- AUTO_INCREMENT for table `tbl_log_mails`
--
ALTER TABLE `tbl_log_mails`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'mail send id';

--
-- AUTO_INCREMENT for table `tbl_mails`
--
ALTER TABLE `tbl_mails`
  MODIFY `mail_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_mails_backup`
--
ALTER TABLE `tbl_mails_backup`
  MODIFY `mail_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_mails_desc`
--
ALTER TABLE `tbl_mails_desc`
  MODIFY `mail_content_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_mails_desc_live`
--
ALTER TABLE `tbl_mails_desc_live`
  MODIFY `mail_content_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_mails_live`
--
ALTER TABLE `tbl_mails_live`
  MODIFY `mail_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_master_skills`
--
ALTER TABLE `tbl_master_skills`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_master_skills_back`
--
ALTER TABLE `tbl_master_skills_back`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_menu_settings`
--
ALTER TABLE `tbl_menu_settings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- AUTO_INCREMENT for table `tbl_meta`
--
ALTER TABLE `tbl_meta`
  MODIFY `meta_tag_id` int NOT NULL AUTO_INCREMENT COMMENT 'Auto inrement ';

--
-- AUTO_INCREMENT for table `tbl_notifications`
--
ALTER TABLE `tbl_notifications`
  MODIFY `notification_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_notification_settings`
--
ALTER TABLE `tbl_notification_settings`
  MODIFY `setting_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Notification Setting ID';

--
-- AUTO_INCREMENT for table `tbl_notification_types`
--
ALTER TABLE `tbl_notification_types`
  MODIFY `notification_type_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_opportunity`
--
ALTER TABLE `tbl_opportunity`
  MODIFY `opportunity_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_opportunity_tangible`
--
ALTER TABLE `tbl_opportunity_tangible`
  MODIFY `tangible_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_photos`
--
ALTER TABLE `tbl_photos`
  MODIFY `photo_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_photos_users`
--
ALTER TABLE `tbl_photos_users`
  MODIFY `photo_tag_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Photo tag primary key';

--
-- AUTO_INCREMENT for table `tbl_pms_issues`
--
ALTER TABLE `tbl_pms_issues`
  MODIFY `issue_id` int NOT NULL AUTO_INCREMENT COMMENT 'Project Issue ID';

--
-- AUTO_INCREMENT for table `tbl_pms_issue_audit_trails`
--
ALTER TABLE `tbl_pms_issue_audit_trails`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_pms_issue_types`
--
ALTER TABLE `tbl_pms_issue_types`
  MODIFY `type_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Issue type ID';

--
-- AUTO_INCREMENT for table `tbl_privacy_rules`
--
ALTER TABLE `tbl_privacy_rules`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_process_issue_analysis`
--
ALTER TABLE `tbl_process_issue_analysis`
  MODIFY `issue_analysis_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_projects`
--
ALTER TABLE `tbl_projects`
  MODIFY `project_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Project ID';

--
-- AUTO_INCREMENT for table `tbl_projects_backup_n`
--
ALTER TABLE `tbl_projects_backup_n`
  MODIFY `project_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Project ID';

--
-- AUTO_INCREMENT for table `tbl_project_audit_fields`
--
ALTER TABLE `tbl_project_audit_fields`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_department`
--
ALTER TABLE `tbl_project_department`
  MODIFY `department_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Department ID';

--
-- AUTO_INCREMENT for table `tbl_project_documents`
--
ALTER TABLE `tbl_project_documents`
  MODIFY `document_id` int NOT NULL AUTO_INCREMENT COMMENT 'Document ID';

--
-- AUTO_INCREMENT for table `tbl_project_estimation`
--
ALTER TABLE `tbl_project_estimation`
  MODIFY `estimation_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_estimation_audit_trails`
--
ALTER TABLE `tbl_project_estimation_audit_trails`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_estimation_lineitem_map`
--
ALTER TABLE `tbl_project_estimation_lineitem_map`
  MODIFY `el_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_estimation_status`
--
ALTER TABLE `tbl_project_estimation_status`
  MODIFY `rca_status_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Rca Status ID';

--
-- AUTO_INCREMENT for table `tbl_project_executive_summary`
--
ALTER TABLE `tbl_project_executive_summary`
  MODIFY `executive_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_files`
--
ALTER TABLE `tbl_project_files`
  MODIFY `file_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_impact`
--
ALTER TABLE `tbl_project_impact`
  MODIFY `impact_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Issue impact ID';

--
-- AUTO_INCREMENT for table `tbl_project_infrastructure_audit_trails`
--
ALTER TABLE `tbl_project_infrastructure_audit_trails`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_infrastructure_planning`
--
ALTER TABLE `tbl_project_infrastructure_planning`
  MODIFY `infrastructure_planning_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_infrastructure_planning_status`
--
ALTER TABLE `tbl_project_infrastructure_planning_status`
  MODIFY `rca_status_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Rca Status ID';

--
-- AUTO_INCREMENT for table `tbl_project_infrastructure_requirements_status`
--
ALTER TABLE `tbl_project_infrastructure_requirements_status`
  MODIFY `rca_status_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Rca Status ID';

--
-- AUTO_INCREMENT for table `tbl_project_initiation_areas`
--
ALTER TABLE `tbl_project_initiation_areas`
  MODIFY `area_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_initiation_check_points`
--
ALTER TABLE `tbl_project_initiation_check_points`
  MODIFY `check_point_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_initiation_records`
--
ALTER TABLE `tbl_project_initiation_records`
  MODIFY `project_initiation_record_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_issues`
--
ALTER TABLE `tbl_project_issues`
  MODIFY `issue_id` int NOT NULL AUTO_INCREMENT COMMENT 'Project Issue ID';

--
-- AUTO_INCREMENT for table `tbl_project_issue_comment_users`
--
ALTER TABLE `tbl_project_issue_comment_users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- AUTO_INCREMENT for table `tbl_project_issue_status`
--
ALTER TABLE `tbl_project_issue_status`
  MODIFY `issue_status_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Issue Status ID';

--
-- AUTO_INCREMENT for table `tbl_project_issue_types`
--
ALTER TABLE `tbl_project_issue_types`
  MODIFY `type_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Issue type ID';

--
-- AUTO_INCREMENT for table `tbl_project_lineitem`
--
ALTER TABLE `tbl_project_lineitem`
  MODIFY `item_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_priority`
--
ALTER TABLE `tbl_project_priority`
  MODIFY `priority_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Priority ID';

--
-- AUTO_INCREMENT for table `tbl_project_process_issue`
--
ALTER TABLE `tbl_project_process_issue`
  MODIFY `process_issue_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_rca`
--
ALTER TABLE `tbl_project_rca`
  MODIFY `rca_id` int NOT NULL AUTO_INCREMENT COMMENT 'Rca ID';

--
-- AUTO_INCREMENT for table `tbl_project_rca_audit_trails`
--
ALTER TABLE `tbl_project_rca_audit_trails`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_rca_status`
--
ALTER TABLE `tbl_project_rca_status`
  MODIFY `rca_status_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Rca Status ID';

--
-- AUTO_INCREMENT for table `tbl_project_release`
--
ALTER TABLE `tbl_project_release`
  MODIFY `release_id` int NOT NULL AUTO_INCREMENT COMMENT 'release_id';

--
-- AUTO_INCREMENT for table `tbl_project_repositories`
--
ALTER TABLE `tbl_project_repositories`
  MODIFY `repo_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_repository_access`
--
ALTER TABLE `tbl_project_repository_access`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_risk`
--
ALTER TABLE `tbl_project_risk`
  MODIFY `project_risk_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_risk_audit_trails`
--
ALTER TABLE `tbl_project_risk_audit_trails`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_risk_status`
--
ALTER TABLE `tbl_project_risk_status`
  MODIFY `risk_status_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_stages`
--
ALTER TABLE `tbl_project_stages`
  MODIFY `stage_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Stage ID';

--
-- AUTO_INCREMENT for table `tbl_project_status`
--
ALTER TABLE `tbl_project_status`
  MODIFY `status_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Status ID';

--
-- AUTO_INCREMENT for table `tbl_project_status_history`
--
ALTER TABLE `tbl_project_status_history`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_tasks`
--
ALTER TABLE `tbl_project_tasks`
  MODIFY `task_id` int NOT NULL AUTO_INCREMENT COMMENT 'Task ID';

--
-- AUTO_INCREMENT for table `tbl_project_tasks_17_07_25`
--
ALTER TABLE `tbl_project_tasks_17_07_25`
  MODIFY `task_id` int NOT NULL AUTO_INCREMENT COMMENT 'Task ID';

--
-- AUTO_INCREMENT for table `tbl_project_tasks_audit_trails`
--
ALTER TABLE `tbl_project_tasks_audit_trails`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_tasks_bkp`
--
ALTER TABLE `tbl_project_tasks_bkp`
  MODIFY `task_id` int NOT NULL AUTO_INCREMENT COMMENT 'Task ID';

--
-- AUTO_INCREMENT for table `tbl_project_tasks_chargeable_logs`
--
ALTER TABLE `tbl_project_tasks_chargeable_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_tasks_prompt`
--
ALTER TABLE `tbl_project_tasks_prompt`
  MODIFY `prompt_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_task_comment_users`
--
ALTER TABLE `tbl_project_task_comment_users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID';

--
-- AUTO_INCREMENT for table `tbl_project_task_dependent_comment`
--
ALTER TABLE `tbl_project_task_dependent_comment`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_task_milestone`
--
ALTER TABLE `tbl_project_task_milestone`
  MODIFY `milestone_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_task_status`
--
ALTER TABLE `tbl_project_task_status`
  MODIFY `task_status_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Task Status ID';

--
-- AUTO_INCREMENT for table `tbl_project_task_types`
--
ALTER TABLE `tbl_project_task_types`
  MODIFY `type_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Project Issue type ID';

--
-- AUTO_INCREMENT for table `tbl_project_team`
--
ALTER TABLE `tbl_project_team`
  MODIFY `team_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Team ID';

--
-- AUTO_INCREMENT for table `tbl_project_topics`
--
ALTER TABLE `tbl_project_topics`
  MODIFY `project_topic_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_project_types`
--
ALTER TABLE `tbl_project_types`
  MODIFY `project_type_id` int NOT NULL AUTO_INCREMENT COMMENT 'Project Type ID';

--
-- AUTO_INCREMENT for table `tbl_project_users_log`
--
ALTER TABLE `tbl_project_users_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_promotion`
--
ALTER TABLE `tbl_promotion`
  MODIFY `promotion_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_qa`
--
ALTER TABLE `tbl_qa`
  MODIFY `qa_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Store QA id';

--
-- AUTO_INCREMENT for table `tbl_qa_attachment`
--
ALTER TABLE `tbl_qa_attachment`
  MODIFY `attach_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_qa_category`
--
ALTER TABLE `tbl_qa_category`
  MODIFY `category_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'store category id';

--
-- AUTO_INCREMENT for table `tbl_qa_process`
--
ALTER TABLE `tbl_qa_process`
  MODIFY `process_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_qa_questions`
--
ALTER TABLE `tbl_qa_questions`
  MODIFY `question_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Store question ID';

--
-- AUTO_INCREMENT for table `tbl_qa_status_history`
--
ALTER TABLE `tbl_qa_status_history`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_qualifications`
--
ALTER TABLE `tbl_qualifications`
  MODIFY `qualification_id` int NOT NULL AUTO_INCREMENT COMMENT 'Store qualification ID; primary key';

--
-- AUTO_INCREMENT for table `tbl_rca_severity`
--
ALTER TABLE `tbl_rca_severity`
  MODIFY `severity_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_regions`
--
ALTER TABLE `tbl_regions`
  MODIFY `region_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_release_status`
--
ALTER TABLE `tbl_release_status`
  MODIFY `release_status_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Release Status ID';

--
-- AUTO_INCREMENT for table `tbl_reminder`
--
ALTER TABLE `tbl_reminder`
  MODIFY `reminder_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_review`
--
ALTER TABLE `tbl_review`
  MODIFY `review_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Review ID';

--
-- AUTO_INCREMENT for table `tbl_risk`
--
ALTER TABLE `tbl_risk`
  MODIFY `risk_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'risk id';

--
-- AUTO_INCREMENT for table `tbl_risk_action`
--
ALTER TABLE `tbl_risk_action`
  MODIFY `action_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_risk_bkp`
--
ALTER TABLE `tbl_risk_bkp`
  MODIFY `risk_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'risk id';

--
-- AUTO_INCREMENT for table `tbl_risk_category`
--
ALTER TABLE `tbl_risk_category`
  MODIFY `category_id` int NOT NULL AUTO_INCREMENT COMMENT 'category id';

--
-- AUTO_INCREMENT for table `tbl_risk_impact`
--
ALTER TABLE `tbl_risk_impact`
  MODIFY `impact_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_risk_mitigation_actions`
--
ALTER TABLE `tbl_risk_mitigation_actions`
  MODIFY `mitigation_action_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_risk_priority`
--
ALTER TABLE `tbl_risk_priority`
  MODIFY `risk_priority_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_risk_probability`
--
ALTER TABLE `tbl_risk_probability`
  MODIFY `probability_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_risk_response`
--
ALTER TABLE `tbl_risk_response`
  MODIFY `response_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_risk_status`
--
ALTER TABLE `tbl_risk_status`
  MODIFY `status_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_risk_update`
--
ALTER TABLE `tbl_risk_update`
  MODIFY `update_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_roles`
--
ALTER TABLE `tbl_roles`
  MODIFY `role_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_roles_back`
--
ALTER TABLE `tbl_roles_back`
  MODIFY `role_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_rt_category`
--
ALTER TABLE `tbl_rt_category`
  MODIFY `category_id` int NOT NULL AUTO_INCREMENT COMMENT 'category id';

--
-- AUTO_INCREMENT for table `tbl_rt_file`
--
ALTER TABLE `tbl_rt_file`
  MODIFY `file_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_rt_merge_history`
--
ALTER TABLE `tbl_rt_merge_history`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_rt_notifications`
--
ALTER TABLE `tbl_rt_notifications`
  MODIFY `notification_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_rt_priority`
--
ALTER TABLE `tbl_rt_priority`
  MODIFY `priority_id` int NOT NULL AUTO_INCREMENT COMMENT 'Priority ID';

--
-- AUTO_INCREMENT for table `tbl_rt_status`
--
ALTER TABLE `tbl_rt_status`
  MODIFY `status_id` int NOT NULL AUTO_INCREMENT COMMENT 'Status ID';

--
-- AUTO_INCREMENT for table `tbl_rt_status_history`
--
ALTER TABLE `tbl_rt_status_history`
  MODIFY `history_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_rt_support`
--
ALTER TABLE `tbl_rt_support`
  MODIFY `ticket_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_rt_support_thread`
--
ALTER TABLE `tbl_rt_support_thread`
  MODIFY `thread_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_save_search`
--
ALTER TABLE `tbl_save_search`
  MODIFY `search_id` int NOT NULL AUTO_INCREMENT COMMENT 'search id';

--
-- AUTO_INCREMENT for table `tbl_search`
--
ALTER TABLE `tbl_search`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'PK';

--
-- AUTO_INCREMENT for table `tbl_settings`
--
ALTER TABLE `tbl_settings`
  MODIFY `setting_id` int NOT NULL AUTO_INCREMENT COMMENT 'Store settings ID; autoincrement';

--
-- AUTO_INCREMENT for table `tbl_short_url`
--
ALTER TABLE `tbl_short_url`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Autoincrement ID';

--
-- AUTO_INCREMENT for table `tbl_site_search`
--
ALTER TABLE `tbl_site_search`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'PK';

--
-- AUTO_INCREMENT for table `tbl_static_modules`
--
ALTER TABLE `tbl_static_modules`
  MODIFY `module_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_static_text`
--
ALTER TABLE `tbl_static_text`
  MODIFY `static_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_subscriptions`
--
ALTER TABLE `tbl_subscriptions`
  MODIFY `subscription_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_sub_todo_list`
--
ALTER TABLE `tbl_sub_todo_list`
  MODIFY `subtodo_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_support`
--
ALTER TABLE `tbl_support`
  MODIFY `support_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_support_category`
--
ALTER TABLE `tbl_support_category`
  MODIFY `category_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_support_reply`
--
ALTER TABLE `tbl_support_reply`
  MODIFY `support_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_tags`
--
ALTER TABLE `tbl_tags`
  MODIFY `tag_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Store tag ID';

--
-- AUTO_INCREMENT for table `tbl_tasktype`
--
ALTER TABLE `tbl_tasktype`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_task_date_history`
--
ALTER TABLE `tbl_task_date_history`
  MODIFY `history_id` int NOT NULL AUTO_INCREMENT COMMENT 'task date history id';

--
-- AUTO_INCREMENT for table `tbl_task_insights`
--
ALTER TABLE `tbl_task_insights`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_test_api_data`
--
ALTER TABLE `tbl_test_api_data`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_timesheets`
--
ALTER TABLE `tbl_timesheets`
  MODIFY `timesheet_id` int NOT NULL AUTO_INCREMENT COMMENT 'Primary Key';

--
-- AUTO_INCREMENT for table `tbl_todo_list`
--
ALTER TABLE `tbl_todo_list`
  MODIFY `todo_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_tooltip`
--
ALTER TABLE `tbl_tooltip`
  MODIFY `tooltip_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_tview_list`
--
ALTER TABLE `tbl_tview_list`
  MODIFY `list_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Default List Id (Auto Increment)';

--
-- AUTO_INCREMENT for table `tbl_tview_list_settings`
--
ALTER TABLE `tbl_tview_list_settings`
  MODIFY `setting_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'List id (Auto increment)';

--
-- AUTO_INCREMENT for table `tbl_tview_release_settings`
--
ALTER TABLE `tbl_tview_release_settings`
  MODIFY `setting_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'List id (Auto increment)';

--
-- AUTO_INCREMENT for table `tbl_tview_saved_search`
--
ALTER TABLE `tbl_tview_saved_search`
  MODIFY `save_search_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_url_tracks`
--
ALTER TABLE `tbl_url_tracks`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `user_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_users_backup`
--
ALTER TABLE `tbl_users_backup`
  MODIFY `user_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_company`
--
ALTER TABLE `tbl_user_company`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'Primary ID';

--
-- AUTO_INCREMENT for table `tbl_user_photos`
--
ALTER TABLE `tbl_user_photos`
  MODIFY `user_photo_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'User Photo Auto Increment ID';

--
-- AUTO_INCREMENT for table `tbl_user_skills`
--
ALTER TABLE `tbl_user_skills`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_venue`
--
ALTER TABLE `tbl_venue`
  MODIFY `venue_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_videos`
--
ALTER TABLE `tbl_videos`
  MODIFY `video_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_weekly_issue_status`
--
ALTER TABLE `tbl_weekly_issue_status`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_weekly_task_status`
--
ALTER TABLE `tbl_weekly_task_status`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_weekly_ticket_status`
--
ALTER TABLE `tbl_weekly_ticket_status`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_word_group`
--
ALTER TABLE `tbl_word_group`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_work_education_types`
--
ALTER TABLE `tbl_work_education_types`
  MODIFY `work_education_type_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_work_edu_mapping`
--
ALTER TABLE `tbl_work_edu_mapping`
  MODIFY `rel_id` int NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
