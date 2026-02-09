package com.synergy.servlet;

import com.synergy.controller.ProjectController;
import com.synergy.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/ProjectServlet")
public class ProjectServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Controllo sicurezza (chi sei?)
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // 2. Prendo i dati dal form HTML
        String name = request.getParameter("projectName");
        String desc = request.getParameter("projectDesc");
        String action = request.getParameter("action");

        // 3. Eseguo l'azione
        if ("create".equals(action)) {
            ProjectController controller = new ProjectController();
            controller.createProject(name, desc, user);
        }

        // 4. Ricarico la pagina dashboard (che ora mostrerà il nuovo progetto)
        response.sendRedirect("dashboard.jsp");
    }
}