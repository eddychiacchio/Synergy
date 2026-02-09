package com.synergy.servlet;

import com.synergy.controller.ProjectController;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/EditActivityServlet")
public class EditActivityServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        int projectId = Integer.parseInt(request.getParameter("projectId"));
        int activityId = Integer.parseInt(request.getParameter("activityId")); // ID dell'attività da modificare
        String title = request.getParameter("title");
        String priority = request.getParameter("priority");
        String dateStr = request.getParameter("deadline");
        String[] subTasks = request.getParameterValues("subtasks");

        ProjectController controller = new ProjectController();
        controller.updateActivityContent(projectId, activityId, title, priority, dateStr, subTasks);

        response.sendRedirect("project_details.jsp?id=" + projectId);
    }
}