-- ============================================================
--  FormDrop — Database Setup
--  Run this in phpMyAdmin or via: mysql -u root -p < database.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS formdrop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE formdrop;

-- ── Users ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  user_id     INT AUTO_INCREMENT PRIMARY KEY,
  student_no  VARCHAR(20)  DEFAULT NULL,
  full_name   VARCHAR(100) NOT NULL,
  email       VARCHAR(100) NOT NULL UNIQUE,
  password    VARCHAR(255) NOT NULL,
  role        ENUM('student','registrar','admin') NOT NULL DEFAULT 'student',
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ── Document types ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS document_types (
  type_id         INT AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(100) NOT NULL,
  description     TEXT,
  requirements    TEXT,
  processing_days INT NOT NULL DEFAULT 3,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- ── Requests ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS requests (
  request_id   INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  type_id      INT NOT NULL,
  purpose      TEXT,
  copies       INT NOT NULL DEFAULT 1,
  status       ENUM('pending','processing','ready','claimed','cancelled') NOT NULL DEFAULT 'pending',
  student_file VARCHAR(255) DEFAULT NULL,
  output_file  VARCHAR(255) DEFAULT NULL,
  remarks      TEXT,
  requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  claimed_at   TIMESTAMP NULL DEFAULT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (type_id) REFERENCES document_types(type_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ── Notifications ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
  notif_id    INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL,
  request_id  INT NOT NULL,
  message     TEXT NOT NULL,
  is_read     TINYINT(1) NOT NULL DEFAULT 0,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)    REFERENCES users(user_id)    ON DELETE CASCADE,
  FOREIGN KEY (request_id) REFERENCES requests(request_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── Status history / audit trail ───────────────────────────
CREATE TABLE IF NOT EXISTS status_history (
  history_id  INT AUTO_INCREMENT PRIMARY KEY,
  request_id  INT NOT NULL,
  changed_by  INT NOT NULL,
  old_status  VARCHAR(20) DEFAULT NULL,
  new_status  VARCHAR(20) NOT NULL,
  remarks     TEXT,
  changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (request_id) REFERENCES requests(request_id) ON DELETE CASCADE,
  FOREIGN KEY (changed_by) REFERENCES users(user_id)       ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
--  SEED DATA
-- ============================================================

-- Demo users (password = "password" for all)
INSERT INTO users (student_no, full_name, email, password, role) VALUES
('2024-00001', 'Juan Dela Cruz',       'student@school.edu.ph',   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student'),
('2024-00002', 'Maria Santos',         'maria@school.edu.ph',     '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student'),
('2024-00003', 'Jose Reyes',           'jose@school.edu.ph',      '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student'),
(NULL,         'Ana Rivera',           'registrar@school.edu.ph', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'registrar'),
(NULL,         'System Administrator', 'admin@school.edu.ph',     '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- Document types
INSERT INTO document_types (name, description, requirements, processing_days, is_active) VALUES
('Transcript of Records',
 'Official academic record showing all subjects, grades, and units earned.',
 'Clearance slip, 2x2 ID photo, official receipt of payment',
 5, 1),

('Good Moral Certificate',
 'Certification of good moral character issued by the school.',
 'Clearance slip, valid school ID',
 2, 1),

('Enrollment Certificate',
 'Proof of current enrollment status for the current semester.',
 'Valid school ID',
 1, 1),

('Diploma Authentication',
 'Official authentication of diploma for employment or further studies abroad.',
 'Original diploma, photocopy of diploma, official receipt',
 7, 1),

('CAV / Red Ribbon',
 'Certification, Authentication and Verification of school documents for international use.',
 'Original TOR, diploma, clearance slip, official receipt',
 10, 1),

('Honorable Dismissal',
 'Document for students transferring to another institution.',
 'Clearance slip, letter of intent, school ID',
 3, 1);

-- Sample requests
INSERT INTO requests (user_id, type_id, purpose, copies, status, remarks, requested_at) VALUES
(1, 1, 'For scholarship application at DOST-SEI',          2, 'processing', NULL,                                        NOW() - INTERVAL 3 DAY),
(1, 2, 'Required by my new employer, BDO Unibank',        1, 'ready',      'Please bring your school ID for pickup.',    NOW() - INTERVAL 5 DAY),
(1, 3, 'For PhilHealth membership update',                 1, 'pending',    NULL,                                        NOW() - INTERVAL 1 DAY),
(1, 4, 'For application to graduate school in UP Manila',  1, 'claimed',    NULL,                                        NOW() - INTERVAL 14 DAY),
(2, 1, 'Required for work abroad visa application',        1, 'pending',    NULL,                                        NOW() - INTERVAL 2 DAY),
(2, 5, 'For TESDA credential evaluation',                  1, 'processing', NULL,                                        NOW() - INTERVAL 4 DAY),
(3, 2, 'For government job application at DepEd',          1, 'pending',    NULL,                                        NOW() - INTERVAL 6 HOUR),
(3, 6, 'Transferring to FEU Manila next semester',         1, 'cancelled',  'Cancelled by student.',                     NOW() - INTERVAL 7 DAY);

-- Status history for sample requests
INSERT INTO status_history (request_id, changed_by, old_status, new_status, remarks, changed_at) VALUES
(1, 1, NULL,        'pending',    'Request submitted by student.',                         NOW() - INTERVAL 3 DAY),
(1, 4, 'pending',   'processing', 'Documents received, now being processed.',              NOW() - INTERVAL 2 DAY),
(2, 1, NULL,        'pending',    'Request submitted by student.',                         NOW() - INTERVAL 5 DAY),
(2, 4, 'pending',   'processing', 'Processing started.',                                   NOW() - INTERVAL 4 DAY),
(2, 4, 'processing','ready',      'Please bring your school ID for pickup.',               NOW() - INTERVAL 2 DAY),
(3, 1, NULL,        'pending',    'Request submitted by student.',                         NOW() - INTERVAL 1 DAY),
(4, 1, NULL,        'pending',    'Request submitted by student.',                         NOW() - INTERVAL 14 DAY),
(4, 4, 'pending',   'processing', NULL,                                                    NOW() - INTERVAL 13 DAY),
(4, 4, 'processing','ready',      'Please claim before end of semester.',                  NOW() - INTERVAL 10 DAY),
(4, 4, 'ready',     'claimed',    NULL,                                                    NOW() - INTERVAL 7 DAY),
(5, 2, NULL,        'pending',    'Request submitted by student.',                         NOW() - INTERVAL 2 DAY),
(6, 2, NULL,        'pending',    'Request submitted by student.',                         NOW() - INTERVAL 4 DAY),
(6, 4, 'pending',   'processing', 'Verification in progress.',                             NOW() - INTERVAL 3 DAY),
(7, 3, NULL,        'pending',    'Request submitted by student.',                         NOW() - INTERVAL 6 HOUR),
(8, 3, NULL,        'pending',    'Request submitted by student.',                         NOW() - INTERVAL 7 DAY),
(8, 3, 'pending',   'cancelled',  'Cancelled by student.',                                 NOW() - INTERVAL 7 DAY);

-- Notifications for student 1
INSERT INTO notifications (user_id, request_id, message, is_read, created_at) VALUES
(1, 1, 'Your request for Transcript of Records is now being processed.',                             0, NOW() - INTERVAL 2 DAY),
(1, 2, 'Your document (Good Moral Certificate) is ready for pickup at the registrar\'s office!',    0, NOW() - INTERVAL 2 DAY),
(1, 4, 'Your request for Diploma Authentication has been marked as claimed.',                        1, NOW() - INTERVAL 7 DAY);
