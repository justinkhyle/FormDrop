<?php
require_once 'config/db.php';
require_once 'includes/auth.php';

if (isLoggedIn()) {
    $r = $_SESSION['role'];
    header("Location: $r/dashboard.php");
    exit;
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email'] ?? '');
    $pass  = $_POST['password'] ?? '';

    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if ($user && password_verify($pass, $user['password'])) {
        $_SESSION['user_id']   = $user['user_id'];
        $_SESSION['full_name'] = $user['full_name'];
        $_SESSION['role']      = $user['role'];
        header("Location: {$user['role']}/dashboard.php");
        exit;
    } else {
        $error = 'Invalid email or password.';
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>FormDrop — Sign In</title>
  <link rel="stylesheet" href="assets/css/app.css"/>
  <style>
    body { display: flex; align-items: center; justify-content: center; min-height: 100vh; }
    .login-wrap { width: 100%; max-width: 420px; padding: 20px; }
    .login-brand {
      font-family: var(--font-head);
      font-size: 32px;
      font-weight: 800;
      letter-spacing: -1px;
      color: var(--text);
      margin-bottom: 4px;
    }
    .login-brand span { color: var(--accent); }
    .login-sub { font-size: 14px; color: var(--text2); margin-bottom: 32px; }
    .login-card {
      background: var(--bg2);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      padding: 28px;
    }
    .login-card h2 {
      font-family: var(--font-head);
      font-size: 18px;
      font-weight: 600;
      color: var(--text);
      margin-bottom: 20px;
    }
    .divider-row {
      display: flex; align-items: center; gap: 12px;
      margin: 20px 0; font-size: 12px; color: var(--text3);
    }
    .divider-row::before, .divider-row::after {
      content: ''; flex: 1; height: 1px; background: var(--border);
    }
    .demo-accounts {
      background: var(--bg3);
      border: 1px solid var(--border);
      border-radius: var(--radius-sm);
      padding: 14px;
      margin-top: 20px;
    }
    .demo-accounts p { font-size: 11px; color: var(--text3); font-weight: 500; text-transform: uppercase; letter-spacing: .06em; margin-bottom: 10px; }
    .demo-row {
      display: flex; justify-content: space-between; align-items: center;
      padding: 6px 0; border-bottom: 1px solid var(--border);
      cursor: pointer;
    }
    .demo-row:last-child { border-bottom: none; }
    .demo-row:hover .demo-email { color: var(--accent); }
    .demo-email { font-size: 12px; color: var(--text2); }
    .demo-role  { font-size: 11px; color: var(--text3); }
    .bg-dots {
      position: fixed; inset: 0; pointer-events: none; z-index: -1;
      background-image: radial-gradient(circle, rgba(167,139,250,0.06) 1px, transparent 1px);
      background-size: 28px 28px;
    }
  </style>
</head>
<body>
<div class="bg-dots"></div>
<div class="login-wrap fade-up">
  <div class="login-brand">Form<span>Drop</span></div>
  <p class="login-sub">School document request automation system</p>

  <div class="login-card">
    <h2>Sign in to your account</h2>

    <?php if ($error): ?>
    <div class="alert alert-error" data-auto-dismiss><?= htmlspecialchars($error) ?></div>
    <?php endif; ?>

    <form method="POST">
      <div class="form-group">
        <label>Email address</label>
        <input type="email" name="email" id="email-input" placeholder="you@school.edu.ph" required autofocus/>
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" placeholder="••••••••" required/>
      </div>
      <button type="submit" class="btn btn-primary btn-block" style="margin-top:8px">
        Sign in →
      </button>
    </form>

    <div class="divider-row">demo accounts</div>

    <div class="demo-accounts">
      <p>Click to auto-fill</p>
      <div class="demo-row" onclick="fill('student@school.edu.ph','password')">
        <span class="demo-email">student@school.edu.ph</span>
        <span class="demo-role">Student</span>
      </div>
      <div class="demo-row" onclick="fill('registrar@school.edu.ph','password')">
        <span class="demo-email">registrar@school.edu.ph</span>
        <span class="demo-role">Registrar</span>
      </div>
      <div class="demo-row" onclick="fill('admin@school.edu.ph','password')">
        <span class="demo-email">admin@school.edu.ph</span>
        <span class="demo-role">Admin</span>
      </div>
    </div>
  </div>
</div>
<script>
function fill(email, pass) {
  document.getElementById('email-input').value = email;
  document.querySelector('input[name="password"]').value = pass;
}
</script>
<script src="assets/js/app.js"></script>
</body>
</html>
