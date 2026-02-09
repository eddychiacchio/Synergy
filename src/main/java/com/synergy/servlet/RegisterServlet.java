package com.synergy.servlet;

import com.synergy.model.User;
import com.synergy.util.DataManager;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        DataManager dm = DataManager.getInstance();
        
        // 1. Controllo se l'email esiste già
        for(User u : dm.getUsers()) {
            if(u.getEmail().equalsIgnoreCase(email)) {
                // Errore: email già in uso (per semplicità rimando al login, ma servirebbe un errore)
                response.sendRedirect("index.jsp"); 
                return;
            }
        }
        
        // 2. Genero ID univoco
        int newId = (int)(System.currentTimeMillis() & 0xfffffff);
        
        // 3. Creo Utente e Salvo
        User newUser = new User(newId, name, email, password);
        dm.getUsers().add(newUser);
        dm.saveData();
        
        // 4. Login automatico (metto l'utente in sessione)
        request.getSession().setAttribute("currentUser", newUser);
        
        // 5. Vado alla Dashboard
        response.sendRedirect("dashboard.jsp");
    }
}