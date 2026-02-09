<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.synergy.model.*" %>
<%@ page import="com.synergy.util.DataManager" %>
<%@ page import="com.synergy.controller.ProjectController" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    // 1. CONTROLLO SICUREZZA
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // 2. RECUPERO DATI (SOLO PROGETTI UTENTE)
    ProjectController pc = new ProjectController();
    List<Project> projects = pc.getProjectsByUser(user); // Variabile chiamata 'projects'
    
    // 3. PREPARAZIONE LISTA "LE MIE ATTIVITÀ"
    class ActivityView {
        Activity activity;
        String projectName;
        int projectId;
        public ActivityView(Activity a, String pName, int pId) { activity=a; projectName=pName; projectId=pId; }
    }
    List<ActivityView> myActivities = new ArrayList<>();
    
    // Popolo la lista delle attività scorrendo i progetti
    for(Project p : projects) {
        for(Activity a : p.getActivities()) {
            if(a.getStatus() != ActivityStatus.COMPLETATO) {
                myActivities.add(new ActivityView(a, p.getName(), p.getId()));
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Dashboard | Synergy</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f8f9fa; }
        .badge-ALTA { background: #ffe4e6; color: #be123c; }
        .badge-MEDIA { background: #ffedd5; color: #c2410c; }
        .badge-BASSA { background: #dbeafe; color: #1e40af; }
        .status-DA_FARE { background: #f3f4f6; color: #4b5563; border: 1px solid #e5e7eb; }
        .status-IN_CORSO { background: #ffedd5; color: #c2410c; border: 1px solid #fed7aa; }
        .status-COMPLETATO { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
    </style>
</head>
<body class="flex h-screen overflow-hidden">

    <aside class="w-64 bg-[#0f172a] text-white flex flex-col flex-shrink-0">
        <div class="p-6 text-2xl font-bold flex items-center gap-2">
            <div class="w-8 h-8 rounded-full border-2 border-cyan-400"></div> Synergy
        </div>
        
        <nav class="flex-1 px-4 space-y-2 mt-4">
            <a href="#" class="block py-2.5 px-4 rounded bg-slate-800 text-cyan-400 font-medium border-l-4 border-cyan-400">
                <i class="fas fa-th-large mr-2"></i> Dashboard
            </a>
            
            <div class="text-xs font-semibold text-slate-500 mt-8 mb-2 px-4 uppercase flex justify-between items-center">
                <span>Progetti Recenti</span>
            </div>
            
            <% 
            int count = 0;
            for(Project p : projects) { 
                if(count++ > 3) break; 
            %>
                <a href="project_details.jsp?id=<%= p.getId() %>" class="block py-2 px-4 rounded transition hover:bg-slate-800 text-slate-400 flex items-center gap-2 truncate">
                    <div class="w-2 h-2 rounded-full bg-green-400"></div> <%= p.getName() %>
                </a>
            <% } %>
        </nav>

        <div class="p-4 border-t border-slate-800 flex items-center gap-3">
            <div class="w-8 h-8 rounded-full bg-cyan-600 flex items-center justify-center font-bold text-xs"><%= user.getName().substring(0,2).toUpperCase() %></div>
            <div class="text-sm flex-1">
                <div class="font-medium"><%= user.getName() %></div>
                <div class="text-xs text-slate-500">Online</div>
            </div>
            <a href="index.jsp" class="text-slate-500 hover:text-red-400"><i class="fas fa-sign-out-alt"></i></a>
        </div>
    </aside>


    <main class="flex-1 flex flex-col min-w-0 overflow-y-auto">
        
        <header class="px-10 py-8 flex justify-between items-end">
            <div>
                <h1 class="text-3xl font-bold text-slate-800">Panoramica</h1>
                <p class="text-slate-500 mt-2">Bentornato. Ecco i tuoi progetti e le tue attività.</p>
            </div>
            <button onclick="openModal()" class="bg-black text-white px-5 py-2.5 rounded-lg font-medium hover:bg-gray-800 transition shadow-lg flex items-center gap-2">
                <i class="fas fa-plus"></i> Nuovo Progetto
            </button>
        </header>

        <div class="px-10 pb-10 space-y-10">

            <section>
                <h2 class="text-lg font-bold text-slate-700 mb-4 flex items-center gap-2">
                    <i class="fas fa-layer-group text-cyan-600"></i> I Miei Progetti
                </h2>
                
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <% 
                    // Colori alternati
                    String[] progressColors = {"bg-teal-400", "bg-purple-500", "bg-blue-500"};
                    int colorIdx = 0;

                    // CORRETTO: Uso 'projects' invece di 'allProjects' e rimuovo logica isMember
                    if(projects.isEmpty()) { 
                    %>
                        <div class="col-span-2 text-center py-10 bg-white rounded-xl border border-dashed border-gray-300">
                            <p class="text-gray-400">Non hai progetti attivi.</p>
                            <button onclick="openModal()" class="text-cyan-600 font-bold mt-2">Creane uno ora</button>
                        </div>
                    <% 
                    } else {
                        for(Project p : projects) {
                            // Trovo se sono admin
                            boolean isAdmin = false;
                            for(ProjectMembership pm : p.getMemberships()) {
                                if(pm.getUser().getId() == user.getId()) { // Usa getId() che è più sicuro
                                    isAdmin = pm.getIsAdmin();
                                    break;
                                }
                            }
                            
                            // Calcolo Progresso
                            int totalTasks = p.getActivities().size();
                            int completedTasks = 0;
                            for(Activity a : p.getActivities()) {
                                if(a.getStatus() == ActivityStatus.COMPLETATO) completedTasks++;
                            }
                            int progress = (totalTasks == 0) ? 0 : (completedTasks * 100 / totalTasks);
                            
                            String currentProgress = progressColors[colorIdx % progressColors.length];
                            colorIdx++;
                    %>
                        <a href="project_details.jsp?id=<%= p.getId() %>" class="bg-white p-6 rounded-xl shadow-sm border border-gray-200 hover:shadow-md transition group relative overflow-hidden block">
                            <div class="absolute left-0 top-0 bottom-0 w-1.5 <%= currentProgress %>"></div>
                            
                            <div class="flex justify-between items-start mb-3 pl-2">
                                <div class="w-10 h-10 rounded-lg <%= currentProgress %> bg-opacity-10 text-xl flex items-center justify-center">
                                    <i class="fas fa-code text-gray-700"></i>
                                </div>
                                <span class="text-xs font-bold uppercase tracking-wider px-2 py-1 bg-gray-100 text-gray-500 rounded">
                                    <%= isAdmin ? "Project Manager" : "Team Member" %>
                                </span>
                            </div>

                            <div class="pl-2">
                                <h3 class="font-bold text-lg text-slate-800 mb-1 group-hover:text-cyan-700 transition"><%= p.getName() %></h3>
                                <p class="text-sm text-slate-500 mb-6 line-clamp-1"><%= p.getDescription() %></p>
                                
                                <div class="flex items-center justify-between text-xs font-bold text-slate-600 mb-1">
                                    <span>Progresso</span>
                                    <span><%= progress %>%</span>
                                </div>
                                <div class="w-full bg-gray-100 rounded-full h-2 overflow-hidden">
                                    <div class="h-2 rounded-full <%= currentProgress %>" style="width: <%= progress %>%"></div>
                                </div>
                            </div>
                        </a>
                    <% 
                        } // fine for
                    } // fine else
                    %>
                </div>
            </section>

            <section>
                <h2 class="text-lg font-bold text-slate-700 mb-4 flex items-center gap-2">
                    <i class="fas fa-tasks text-cyan-600"></i> Le Mie Attività Recenti
                </h2>

                <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-gray-50 border-b border-gray-200 text-xs uppercase text-gray-500 font-bold tracking-wider">
                                <th class="px-6 py-4">Nome Attività</th>
                                <th class="px-6 py-4">Progetto</th>
                                <th class="px-6 py-4">Scadenza</th>
                                <th class="px-6 py-4 text-center">Priorità</th>
                                <th class="px-6 py-4 text-center">Stato</th>
                                <th class="px-6 py-4"></th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <% if(myActivities.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="px-6 py-8 text-center text-gray-400 text-sm">Non ci sono attività in sospeso. Ottimo lavoro! 🎉</td>
                                </tr>
                            <% } else {
                                // Mostra solo le prime 5 attività per pulizia
                                int actCount = 0;
                                for(ActivityView av : myActivities) {
                                    if(actCount++ >= 5) break;
                            %>
                            <tr class="hover:bg-gray-50 transition group">
                                <td class="px-6 py-4 font-semibold text-slate-700">
                                    <%= av.activity.getTitle() %>
                                    <% if(av.activity instanceof TaskGroup) { %>
                                        <span class="ml-2 text-xs bg-gray-100 text-gray-500 px-1.5 rounded border">GRUPPO</span>
                                    <% } %>
                                </td>
                                <td class="px-6 py-4">
                                    <a href="project_details.jsp?id=<%= av.projectId %>" class="bg-teal-50 text-teal-700 px-3 py-1 rounded-full text-xs font-bold border border-teal-100 hover:bg-teal-100 transition">
                                        <%= av.projectName %>
                                    </a>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-500 font-medium">
                                    <%= (av.activity.getDeadline() != null) ? av.activity.getDeadline().toString() : "Nessuna" %>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <span class="text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wide badge-<%= av.activity.getPriority() %>">
                                        <%= av.activity.getPriority() %>
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <span class="text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wide status-<%= av.activity.getStatus() %>">
                                        <%= av.activity.getStatus().toString().replace("_", " ") %>
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <a href="project_details.jsp?id=<%= av.projectId %>" class="text-gray-300 hover:text-cyan-600 transition">
                                        <i class="fas fa-chevron-right"></i>
                                    </a>
                                </td>
                            </tr>
                            <% }} %>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </main>

    <div id="createModal" class="fixed inset-0 bg-gray-900 bg-opacity-50 hidden items-center justify-center z-50 backdrop-blur-sm">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-md p-6 transform scale-100 transition-all">
            <h3 class="text-xl font-bold text-gray-800 mb-4">Nuovo Progetto</h3>
            <form action="ProjectServlet" method="post">
                
                <input type="hidden" name="action" value="create">
                
                <div class="mb-4">
                    <label class="block text-sm font-bold text-gray-700 mb-1">Nome Progetto</label>
                    <input type="text" name="projectName" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-black outline-none" required>
                </div>
                
                <div class="mb-6">
                    <label class="block text-sm font-bold text-gray-700 mb-1">Descrizione</label>
                    <textarea name="projectDesc" rows="3" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-black outline-none"></textarea>
                </div>
                
                <div class="flex justify-end gap-3">
                    <button type="button" onclick="closeModal()" class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg">Annulla</button>
                    <button type="submit" class="px-4 py-2 bg-black text-white font-medium rounded-lg hover:bg-gray-800">Crea Progetto</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openModal() {
            document.getElementById('createModal').classList.remove('hidden');
            document.getElementById('createModal').classList.add('flex');
        }
        function closeModal() {
            document.getElementById('createModal').classList.add('hidden');
            document.getElementById('createModal').classList.remove('flex');
        }
        document.getElementById('createModal').addEventListener('click', function(e) {
            if (e.target === this) closeModal();
        });
    </script>

</body>
</html>