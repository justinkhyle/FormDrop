# FormDrop — School Document Request System
## Setup Guide

### Requirements
- PHP 7.4 or higher
- MySQL 5.7 / MariaDB 10.3 or higher
- Apache with mod_rewrite (XAMPP / WAMP / Laragon)

---

### 1. Install & place files
Copy the `formdrop/` folder into your web server root:
- XAMPP → `C:/xampp/htdocs/formdrop/`
- Laragon → `C:/laragon/www/formdrop/`

---

### 2. Create the database
Open **phpMyAdmin** → click **Import** → select `formdrop/database.sql` → click **Go**.

Or via terminal:
```bash
mysql -u root -p < database.sql
```

---

### 3. Configure database connection
Edit `config/db.php` if your MySQL credentials differ:
```php
$host = 'localhost';
$db   = 'formdrop';
$user = 'root';
$pass = '';          // your MySQL password
```

---

### 4. Set upload folder permissions
The uploads folder must be writable:
```bash
chmod -R 775 uploads/
```
On Windows/XAMPP this is handled automatically.

---

### 5. Open in browser
```
http://localhost/formdrop/
```

---

### Demo Accounts
| Role       | Email                      | Password |
|------------|----------------------------|----------|
| Student    | student@school.edu.ph      | password |
| Student 2  | maria@school.edu.ph        | password |
| Registrar  | registrar@school.edu.ph    | password |
| Admin      | admin@school.edu.ph        | password |

---

### Project Structure
```
formdrop/
├── index.php                  ← Login page
├── logout.php
├── database.sql               ← Database setup + seed data
├── config/
│   └── db.php                 ← PDO connection
├── includes/
│   ├── auth.php               ← Session & role guard
│   ├── head.php               ← HTML <head>
│   └── sidebar.php            ← Navigation sidebar
├── assets/
│   ├── css/app.css            ← Global styles
│   └── js/app.js              ← Global scripts
├── student/
│   ├── dashboard.php          ← Student home
│   ├── new_request.php        ← Submit a request
│   ├── my_requests.php        ← View all requests
│   ├── view_request.php       ← Single request detail + timeline
│   ├── notifications.php      ← Notification inbox
│   └── cancel_request.php     ← Cancel a pending request
├── registrar/
│   ├── dashboard.php          ← Registrar home
│   ├── queue.php              ← All requests queue
│   └── update_status.php      ← Process a request
├── admin/
│   ├── dashboard.php          ← Admin overview + analytics
│   ├── document_types.php     ← Add/edit/disable document types
│   ├── users.php              ← Add/edit/delete users
│   └── export.php             ← CSV report export
├── api/
│   └── notif_count.php        ← AJAX notification count
└── uploads/
    ├── student_files/         ← Files uploaded by students
    └── output_files/          ← Documents uploaded by registrar
```

---

### Key Features
- **3 user roles**: Student, Registrar, Admin
- **Full request lifecycle**: Pending → Processing → Ready → Claimed
- **File uploads**: Students attach requirements; registrar uploads finished docs
- **Live notifications**: Students notified on every status change
- **Audit trail**: Every status change is logged with timestamp and actor
- **Search & filter**: Registrar can search and filter by status
- **CSV export**: Admin exports full report by date range
- **Auto-dismiss alerts**: UI feedback disappears automatically
- **Responsive**: Works on mobile via Bootstrap-like grid
