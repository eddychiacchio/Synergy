<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Registrati - Synergy</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-[#0f172a] h-screen flex items-center justify-center">

    <div class="bg-white p-8 rounded-xl shadow-2xl w-full max-w-md">
        <div class="text-center mb-8">
            <div class="w-12 h-12 rounded-full border-4 border-cyan-400 mx-auto mb-4"></div>
            <h2 class="text-2xl font-bold text-gray-800">Crea Account</h2>
            <p class="text-gray-500 text-sm">Unisciti al team di Synergy</p>
        </div>

        <form action="RegisterServlet" method="post" class="space-y-4">
            <div>
                <label class="block text-xs font-bold text-gray-500 uppercase tracking-wide mb-1">Nome Completo</label>
                <input type="text" name="name" class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-cyan-500" placeholder="Mario Rossi" required>
            </div>
            
            <div>
                <label class="block text-xs font-bold text-gray-500 uppercase tracking-wide mb-1">Email</label>
                <input type="email" name="email" class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-cyan-500" placeholder="mario@synergy.com" required>
            </div>
            
            <div>
                <label class="block text-xs font-bold text-gray-500 uppercase tracking-wide mb-1">Password</label>
                <input type="password" name="password" class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-cyan-500" placeholder="••••••••" required>
            </div>

            <button type="submit" class="w-full bg-cyan-600 hover:bg-cyan-700 text-white font-bold py-3 rounded-lg transition duration-200 shadow-lg mt-2">
                Registrati
            </button>
        </form>

        <div class="mt-6 text-center text-sm text-gray-500">
            Hai già un account? <a href="index.jsp" class="text-cyan-600 font-bold hover:underline">Accedi</a>
        </div>
    </div>

</body>
</html>