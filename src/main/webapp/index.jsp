<!DOCTYPE html>
<html>
<head>
    <title>Synergy - Login</title>
    <style>
        body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #f4f4f9; }
        .login-box { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); text-align: center; }
        input { display: block; margin: 10px auto; padding: 10px; width: 200px; }
        button { background-color: #28a745; color: white; padding: 10px 20px; border: none; cursor: pointer; }
        button:hover { background-color: #218838; }
        .error { color: red; font-size: 0.9em; }
    </style>
</head>
<body>

<div class="login-box">
    <h2>Synergy Login</h2>
    
    <form action="LoginServlet" method="post">
        <input type="email" name="email" placeholder="Email (es. test@synergy.com)" required>
        <input type="password" name="password" placeholder="Password (es. 12345)" required>
        <button type="submit">Accedi</button>
    </form>
    
    <% if (request.getParameter("error") != null) { %>
        <p class="error">Credenziali errate!</p>
    <% } %>
</div>

<div class="mt-6 text-center text-sm text-gray-500">
    Non hai un account? <a href="register.jsp" class="text-cyan-600 font-bold hover:underline">Registrati</a>
</div>

</body>
</html>