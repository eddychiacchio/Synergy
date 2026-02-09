package com.synergy.servlet;

import com.synergy.controller.AuthenticationController;
import com.synergy.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet; // Se dà errore, controlla il pom.xml
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

// Questa stringa deve coincidere con l'action del form HTML
@WebServlet("/LoginServlet") 
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Prendo i dati dal form HTML
        String email = request.getParameter("email");
        String pass = request.getParameter("password");

        // 2. Chiamo il Controller
        AuthenticationController auth = new AuthenticationController();
        User loggedUser = auth.login(email, pass);

        if (loggedUser != null) {
            // LOGIN OK: Salvo l'utente nella "Sessione" (memoria del browser)
            HttpSession session = request.getSession();
            session.setAttribute("currentUser", loggedUser);
            
            // Vado alla dashboard
            response.sendRedirect("dashboard.jsp");
        } else {
            // LOGIN FALLITO: Torno indietro con errore
            response.sendRedirect("index.jsp?error=true");
        }
    }
}