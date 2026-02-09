package com.synergy.servlet;

import com.synergy.controller.ProjectController;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/DeleteActivityServlet")
public class DeleteActivityServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int projectId = Integer.parseInt(request.getParameter("projectId"));
        int activityId = Integer.parseInt(request.getParameter("activityId"));

        ProjectController controller = new ProjectController();
        boolean success = controller.deleteActivity(projectId, activityId);

        if (success) {
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}