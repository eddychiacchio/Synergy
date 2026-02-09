package com.synergy.servlet;

import com.synergy.controller.ProjectController;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/UpdateStatusServlet")
public class UpdateStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Leggo i dati inviati da Javascript
        int projectId = Integer.parseInt(request.getParameter("projectId"));
        int activityId = Integer.parseInt(request.getParameter("activityId"));
        String newStatus = request.getParameter("status"); // "DA_FARE", "IN_CORSO", "COMPLETATO"

        // 2. Aggiorno il Backend
        ProjectController controller = new ProjectController();
        boolean success = controller.updateActivityStatus(projectId, activityId, newStatus);

        // 3. Rispondo al browser
        if (success) {
            response.setStatus(HttpServletResponse.SC_OK); // 200 OK
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 400 Errore
        }
    }
}