package com.synergy.servlet;

import com.synergy.controller.ProjectController;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/InviteServlet")
public class InviteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int projectId = Integer.parseInt(request.getParameter("projectId"));
        String email = request.getParameter("email");
        
        ProjectController controller = new ProjectController();
        boolean success = controller.inviteUserToProject(projectId, email);
        
        // Redirect con messaggio (opzionale gestirlo nel JSP, per ora torniamo lì)
        if(success) {
            response.sendRedirect("project_details.jsp?id=" + projectId + "&invite=success");
        } else {
            response.sendRedirect("project_details.jsp?id=" + projectId + "&invite=error");
        }
    }
}