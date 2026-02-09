package com.synergy.servlet;

import com.synergy.controller.DocumentController;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;

@WebServlet("/UploadServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 10,      // 10 MB
    maxRequestSize = 1024 * 1024 * 15    // 15 MB
)
public class UploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int projectId = Integer.parseInt(request.getParameter("projectId"));
        Part filePart = request.getPart("file"); // Input type="file" name="file"

        if (filePart != null && filePart.getSize() > 0) {
            DocumentController dc = new DocumentController();
            dc.uploadFile(projectId, filePart);
        }

        response.sendRedirect("project_details.jsp?id=" + projectId + "&tab=docs");
    }
}