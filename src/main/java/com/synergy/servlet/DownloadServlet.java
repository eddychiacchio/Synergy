package com.synergy.servlet;

import com.synergy.controller.DocumentController;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.io.IOException;

@WebServlet("/DownloadServlet")
public class DownloadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String filename = request.getParameter("file");
        String originalName = request.getParameter("name");
        
        if(filename == null) return;

        DocumentController dc = new DocumentController();
        File file = new File(dc.getUploadPath() + File.separator + filename);

        if (file.exists()) {
            response.setContentType("application/octet-stream");
            response.setContentLength((int) file.length());
            // Forza il download con il nome originale
            response.setHeader("Content-Disposition", "attachment; filename=\"" + originalName + "\"");

            try (FileInputStream in = new FileInputStream(file);
                 OutputStream out = response.getOutputStream()) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
            }
        } else {
            response.getWriter().write("File non trovato sul server.");
        }
    }
    
    // Gestione Cancellazione (per comodità la metto qui o servirebbe un'altra servlet)
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Logica per cancellare documento
        int projectId = Integer.parseInt(request.getParameter("projectId"));
        int docId = Integer.parseInt(request.getParameter("docId"));
        
        new DocumentController().deleteDocument(projectId, docId);
        response.sendRedirect("project_details.jsp?id=" + projectId + "&tab=docs");
    }
}