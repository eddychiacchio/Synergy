<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.synergy.model.*" %>
<%@ page import="com.synergy.controller.ProjectController" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) { response.sendRedirect("index.jsp"); return; }

    String idStr = request.getParameter("id");
    Project currentProject = null;
    
    // --- FIX 1: Dichiaro il controller QUI, visibile ovunque ---
    ProjectController pc = new ProjectController(); 
    
    if (idStr != null) {
        currentProject = pc.getProjectById(Integer.parseInt(idStr));
    }
    if (currentProject == null) { response.sendRedirect("dashboard.jsp"); return; }

    // --- LOGICA STRATEGY ---
    String sortParam = request.getParameter("sort");
    List<Activity> sortedActivities = pc.getSortedActivities(currentProject.getId(), sortParam);
    
    // Logica Kanban
    List<Activity> todoList = new ArrayList<>();
    List<Activity> doingList = new ArrayList<>();
    List<Activity> doneList = new ArrayList<>();
    for(Activity a : sortedActivities) {
        if(a.getStatus() == ActivityStatus.DA_FARE) todoList.add(a);
        else if(a.getStatus() == ActivityStatus.IN_CORSO) doingList.add(a);
        else if(a.getStatus() == ActivityStatus.COMPLETATO) doneList.add(a);
    }
    
    // Logica Tabs
    String paramTab = request.getParameter("tab");
    String activeTab = "activities"; // Default
    if(paramTab != null && (paramTab.equals("docs") || paramTab.equals("documents"))) {
        activeTab = "documents";
    }
%>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title><%= currentProject.getName() %></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sortablejs@latest/Sortable.min.js"></script>
    
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f8f9fa; }
        .badge-ALTA { background: #ffe4e6; color: #be123c; border: 1px solid #fecdd3; }
        .badge-MEDIA { background: #ffedd5; color: #c2410c; border: 1px solid #fed7aa; }
        .badge-BASSA { background: #dbeafe; color: #1e40af; border: 1px solid #bfdbfe; }
        .sortable-ghost { opacity: 0.4; background-color: #f3f4f6; border: 2px dashed #cbd5e1; }
        .task-card { cursor: grab; }
        .task-card:active { cursor: grabbing; }
        .subtask-check:hover { color: #10b981; cursor: pointer; }
        .tab-btn { border-bottom: 2px solid transparent; color: #64748b; padding-bottom: 12px; cursor: pointer; transition: all 0.2s; }
        .tab-btn:hover { color: #334155; }
        .tab-btn.active { border-bottom: 2px solid #0ea5e9; color: #0f172a; font-weight: 600; }
        .tab-content { display: none; height: 100%; }
        .tab-content.active { display: block; }
    </style>
</head>
<body class="flex h-screen overflow-hidden">

    <aside class="w-64 bg-[#0f172a] text-white flex flex-col flex-shrink-0">
        <div class="p-6 text-2xl font-bold flex items-center gap-2">
            <div class="w-8 h-8 rounded-full border-2 border-cyan-400"></div> Synergy
        </div>
        <nav class="flex-1 px-4 space-y-2 mt-4">
            <a href="dashboard.jsp" class="block py-2.5 px-4 rounded transition hover:bg-slate-800 text-slate-400">
                <i class="fas fa-th-large mr-2"></i> Dashboard
            </a>
            <div class="text-xs font-semibold text-slate-500 mt-6 mb-2 px-4 uppercase">Progetti Recenti</div>
            <a href="#" class="block py-2 px-4 rounded bg-slate-800 text-cyan-400 font-medium border-l-4 border-cyan-400">
                <%= currentProject.getName() %>
            </a>

            <div class="text-xs font-semibold text-slate-500 mt-6 mb-2 px-4 uppercase">Team Progetto</div>
            <div class="px-4 flex -space-x-2 overflow-hidden mb-4">
                <% for(ProjectMembership pm : currentProject.getMemberships()) { %>
                    <div class="inline-block h-8 w-8 rounded-full ring-2 ring-[#0f172a] bg-gray-600 flex items-center justify-center text-xs font-bold" title="<%= pm.getUser().getName() %>">
                        <%= pm.getUser().getName().substring(0,2).toUpperCase() %>
                    </div>
                <% } %>
                <button onclick="openInviteModal()" class="inline-block h-8 w-8 rounded-full ring-2 ring-[#0f172a] bg-slate-700 hover:bg-slate-600 flex items-center justify-center text-xs text-white z-10" title="Aggiungi Membro">
                    <i class="fas fa-plus"></i>
                </button>
            </div>
        </nav>
        <div class="p-4 border-t border-slate-800 flex items-center gap-3">
            <div class="w-8 h-8 rounded-full bg-cyan-600 flex items-center justify-center font-bold text-xs"><%= user.getName().substring(0,2).toUpperCase() %></div>
            <div class="text-sm">
                <div class="font-medium"><%= user.getName() %></div>
                <div class="text-xs text-slate-500">Online</div>
            </div>
        </div>
    </aside>

    <main class="flex-1 flex flex-col min-w-0 bg-white">
        
        <header class="border-b border-gray-200 bg-white px-8 pt-6 pb-0 flex-shrink-0 z-10">
            <div class="flex justify-between items-start mb-6">
                <div>
                    <div class="flex items-center gap-2 text-gray-400 text-sm mb-1">
                        <a href="dashboard.jsp" class="hover:text-gray-600 flex items-center gap-1"><i class="fas fa-arrow-left"></i> Indietro</a>
                    </div>
                    <h1 class="text-2xl font-bold text-gray-800"><%= currentProject.getName() %></h1>
                    <p class="text-gray-500 text-sm"><%= currentProject.getDescription() %></p>
                </div>
                <div class="flex gap-3">
                    <button onclick="openInviteModal()" class="px-4 py-2 bg-white border border-gray-300 text-gray-600 rounded-lg text-sm font-medium shadow-sm hover:bg-gray-50 transition">
                        <i class="fas fa-user-plus mr-2"></i> Invita
                    </button>
                    
                    <button id="mainActionBtn" onclick="openCreateModal()" class="px-4 py-2 bg-[#14b8a6] text-white rounded-lg text-sm font-medium shadow-sm hover:bg-[#0d9488] transition" 
                            style="<%= activeTab.equals("documents") ? "display:none" : "" %>">
                        + Nuova Attività
                    </button>
                </div>
            </div>

            <div class="flex gap-8 text-sm font-medium">
                <div onclick="switchTab('activities')" id="tab-activities" class="tab-btn flex items-center gap-2 <%= activeTab.equals("activities") ? "active" : "" %>">
                    <i class="fas fa-tasks"></i> Attività
                </div>
                <div onclick="switchTab('documents')" id="tab-documents" class="tab-btn flex items-center gap-2 <%= activeTab.equals("documents") ? "active" : "" %>">
                    <i class="fas fa-folder-open"></i> Documenti
                </div>
            </div>
        </header>

        <div class="flex-1 overflow-hidden bg-[#f8f9fa] relative">
            
            <div id="content-activities" class="tab-content w-full h-full <%= activeTab.equals("activities") ? "active" : "" %>">
                <div class="overflow-x-auto h-full p-8">
                    
                    <div class="flex justify-end mb-4 gap-2 min-w-[1000px]">
                        <span class="text-xs font-bold text-gray-400 uppercase self-center mr-2">Ordina per:</span>
                        
                        <a href="project_details.jsp?id=<%= currentProject.getId() %>&sort=priority" 
                           class="px-3 py-1 bg-white border border-gray-200 text-gray-600 rounded-full text-xs hover:bg-gray-50 hover:border-gray-400 transition <%= "priority".equals(sortParam) ? "bg-gray-100 border-gray-400 font-bold" : "" %>">
                           <i class="fas fa-exclamation-circle text-red-400"></i> Priorità
                        </a>
                        
                        <a href="project_details.jsp?id=<%= currentProject.getId() %>&sort=deadline" 
                           class="px-3 py-1 bg-white border border-gray-200 text-gray-600 rounded-full text-xs hover:bg-gray-50 hover:border-gray-400 transition <%= "deadline".equals(sortParam) ? "bg-gray-100 border-gray-400 font-bold" : "" %>">
                           <i class="far fa-clock text-blue-400"></i> Scadenza
                        </a>
                        
                        <a href="project_details.jsp?id=<%= currentProject.getId() %>" 
                           class="px-3 py-1 bg-white border border-gray-200 text-gray-400 rounded-full text-xs hover:bg-gray-50">
                           Reset
                        </a>
                    </div>

                    <div class="grid grid-cols-3 gap-6 h-full min-w-[1000px]">
                        <div class="flex flex-col h-full kanban-column" data-status="DA_FARE">
                            <div class="flex items-center gap-2 mb-4">
                                <div class="w-2 h-2 rounded-full bg-gray-400"></div>
                                <h3 class="font-bold text-gray-700 text-sm uppercase">Da Fare</h3>
                                <span class="bg-gray-200 text-gray-600 text-xs px-2 py-0.5 rounded-full task-count"><%= todoList.size() %></span>
                            </div>
                            <div id="col-todo" class="flex-1 space-y-3 overflow-y-auto pr-2 pb-10 min-h-[100px]">
                                <% for(Activity a : todoList) { %> <%= renderCard(a) %> <% } %>
                            </div>
                        </div>

                        <div class="flex flex-col h-full kanban-column" data-status="IN_CORSO">
                            <div class="flex items-center gap-2 mb-4">
                                <div class="w-2 h-2 rounded-full bg-orange-400"></div>
                                <h3 class="font-bold text-gray-700 text-sm uppercase">In Corso</h3>
                                <span class="bg-orange-100 text-orange-600 text-xs px-2 py-0.5 rounded-full task-count"><%= doingList.size() %></span>
                            </div>
                            <div id="col-doing" class="flex-1 space-y-3 overflow-y-auto pr-2 pb-10 min-h-[100px]">
                                <% for(Activity a : doingList) { %> <%= renderCard(a) %> <% } %>
                            </div>
                        </div>

                        <div class="flex flex-col h-full kanban-column" data-status="COMPLETATO">
                            <div class="flex items-center gap-2 mb-4">
                                <div class="w-2 h-2 rounded-full bg-green-500"></div>
                                <h3 class="font-bold text-gray-700 text-sm uppercase">Completato</h3>
                                <span class="bg-green-100 text-green-600 text-xs px-2 py-0.5 rounded-full task-count"><%= doneList.size() %></span>
                            </div>
                            <div id="col-done" class="flex-1 space-y-3 overflow-y-auto pr-2 pb-10 min-h-[100px]">
                                <% for(Activity a : doneList) { %> <%= renderCard(a) %> <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div id="content-documents" class="tab-content w-full h-full <%= activeTab.equals("documents") ? "active" : "" %>">
                <div class="p-8 h-full overflow-y-auto">
                    <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50">
                            <h3 class="font-bold text-gray-700">File del Progetto</h3>
                            <button onclick="openUploadModal()" class="text-sm font-bold text-cyan-600 hover:underline flex items-center gap-1">
                                <i class="fas fa-cloud-upload-alt"></i> Carica File
                            </button>
                        </div>

                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="text-xs uppercase text-gray-400 border-b border-gray-100">
                                    <th class="px-6 py-3 font-semibold">Nome</th>
                                    <th class="px-6 py-3 font-semibold">Tipo</th>
                                    <th class="px-6 py-3 font-semibold">Data</th>
                                    <th class="px-6 py-3 font-semibold text-right">Azioni</th>
                                </tr>
                            </thead>
                            <tbody class="text-sm">
                                <% if (currentProject.getDocuments().isEmpty()) { %>
                                    <tr><td colspan="4" class="px-6 py-12 text-center text-gray-400">
                                        <div class="flex flex-col items-center">
                                            <i class="far fa-folder-open text-3xl mb-2 text-gray-300"></i>
                                            <p>Nessun documento caricato.</p>
                                        </div>
                                    </td></tr>
                                <% } else {
                                    for (ProjectDocument doc : currentProject.getDocuments()) { %>
                                    <tr class="hover:bg-gray-50 border-b border-gray-50 last:border-0 transition">
                                        <td class="px-6 py-4 font-medium text-gray-700 flex items-center gap-3">
                                            <i class="fas fa-file-alt text-red-400 text-lg"></i> <%= doc.getName() %>
                                        </td>
                                        <td class="px-6 py-4 text-gray-500 uppercase"><%= doc.getType() %></td>
                                        <td class="px-6 py-4 text-gray-500"><%= doc.getUploadDate() %></td>
                                        <td class="px-6 py-4 text-right flex justify-end gap-3">
                                            <a href="DownloadServlet?file=<%= doc.getFilename() %>&name=<%= doc.getName() %>" class="text-gray-400 hover:text-blue-600" title="Scarica">
                                                <i class="fas fa-download"></i>
                                            </a>
                                            <form action="DownloadServlet" method="post" style="display:inline;" onsubmit="return confirm('Eliminare questo file?');">
                                                <input type="hidden" name="projectId" value="<%= currentProject.getId() %>">
                                                <input type="hidden" name="docId" value="<%= doc.getId() %>">
                                                <button type="submit" class="text-gray-400 hover:text-red-500" title="Elimina"><i class="fas fa-trash"></i></button>
                                            </form>
                                        </td>
                                    </tr>
                                <% }} %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <div id="modalOverlay" class="fixed inset-0 bg-gray-900 bg-opacity-40 hidden items-center justify-center z-50 backdrop-blur-sm">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-lg overflow-hidden p-6 max-h-[90vh] overflow-y-auto">
            <div class="flex justify-between items-center mb-6">
                <h3 id="modalTitle" class="font-bold text-gray-800 text-lg">Nuova Attività</h3>
                <button onclick="closeModal()" class="text-gray-400 hover:text-gray-600"><i class="fas fa-times"></i></button>
            </div>
            
            <form id="activityForm" action="ActivityServlet" method="post">
                <input type="hidden" name="projectId" value="<%= currentProject.getId() %>">
                <input type="hidden" name="activityId" id="editActivityId" value="">
                
                <div class="mb-5">
                    <label class="block text-xs font-bold text-gray-500 uppercase tracking-wide mb-1">Titolo Attività *</label>
                    <input type="text" name="title" id="inputTitle" class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg outline-none" required>
                </div>
                
                <div class="grid grid-cols-2 gap-4 mb-5">
                    <div>
                        <label class="block text-xs font-bold text-gray-500 uppercase tracking-wide mb-1">Priorità</label>
                        <select name="priority" id="inputPriority" class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg outline-none">
                            <option value="MEDIA">Media</option>
                            <option value="ALTA">Alta</option>
                            <option value="BASSA">Bassa</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-gray-500 uppercase tracking-wide mb-1">Scadenza</label>
                        <input type="date" name="deadline" id="inputDeadline" class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg outline-none text-gray-600">
                    </div>
                </div>

                <div class="mb-6">
                    <label class="block text-xs font-bold text-gray-500 uppercase tracking-wide mb-1">Sottoattività</label>
                    <div id="subtasksContainer" class="space-y-2"></div>
                    <button type="button" onclick="addSubtaskField('')" class="mt-2 text-sm text-[#14b8a6] font-bold hover:underline flex items-center gap-1">
                        <i class="fas fa-plus-circle"></i> Aggiungi voce
                    </button>
                </div>

                <div class="flex justify-end gap-3 pt-4 border-t border-gray-100">
                    <button type="button" onclick="closeModal()" class="px-5 py-2.5 text-gray-600 font-medium hover:bg-gray-50 rounded-lg">Annulla</button>
                    <button type="submit" id="btnSubmit" class="px-6 py-2.5 bg-[#14b8a6] text-white font-medium rounded-lg hover:bg-[#0d9488] shadow-md">Crea</button>
                </div>
            </form>
        </div>
    </div>

    <div id="uploadModal" class="fixed inset-0 bg-gray-900 bg-opacity-40 hidden items-center justify-center z-50 backdrop-blur-sm">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-md p-6">
            <h3 class="font-bold text-gray-800 text-lg mb-4">Carica Documento</h3>
            <form action="UploadServlet" method="post" enctype="multipart/form-data">
                <input type="hidden" name="projectId" value="<%= currentProject.getId() %>">
                <div class="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center mb-6 hover:bg-gray-50 transition cursor-pointer relative">
                    <input type="file" name="file" class="absolute inset-0 w-full h-full opacity-0 cursor-pointer" required onchange="document.getElementById('fileNameDisplay').innerText = this.files[0].name">
                    <i class="fas fa-cloud-upload-alt text-3xl text-gray-300 mb-2"></i>
                    <p class="text-sm text-gray-500">Trascina qui o clicca per selezionare</p>
                    <p id="fileNameDisplay" class="text-sm font-bold text-cyan-600 mt-2"></p>
                </div>
                <div class="flex justify-end gap-3">
                    <button type="button" onclick="document.getElementById('uploadModal').classList.add('hidden'); document.getElementById('uploadModal').classList.remove('flex')" class="px-4 py-2 text-gray-600 hover:bg-gray-50 rounded-lg">Annulla</button>
                    <button type="submit" class="px-4 py-2 bg-black text-white font-medium rounded-lg hover:bg-gray-800">Carica</button>
                </div>
            </form>
        </div>
    </div>

    <div id="inviteModal" class="fixed inset-0 bg-gray-900 bg-opacity-40 hidden items-center justify-center z-50 backdrop-blur-sm">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-sm p-6">
            <h3 class="font-bold text-gray-800 text-lg mb-2">Invita nel Team</h3>
            <p class="text-sm text-gray-500 mb-4">Inserisci l'email del collega da aggiungere a <strong><%= currentProject.getName() %></strong>.</p>
            
            <form action="InviteServlet" method="post">
                <input type="hidden" name="projectId" value="<%= currentProject.getId() %>">
                
                <div class="mb-4">
                    <input type="email" name="email" class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg outline-none focus:ring-2 focus:ring-[#14b8a6]" placeholder="mario@esempio.com" required>
                </div>
                
                <% if("error".equals(request.getParameter("invite"))) { %>
                    <p class="text-xs text-red-500 mb-3 font-bold"><i class="fas fa-exclamation-circle"></i> Utente non trovato o già presente.</p>
                <% } else if("success".equals(request.getParameter("invite"))) { %>
                    <p class="text-xs text-green-500 mb-3 font-bold"><i class="fas fa-check-circle"></i> Invito inviato con successo!</p>
                <% } %>
                
                <div class="flex justify-end gap-3">
                    <button type="button" onclick="document.getElementById('inviteModal').classList.add('hidden'); document.getElementById('inviteModal').classList.remove('flex')" class="px-4 py-2 text-gray-600 hover:bg-gray-50 rounded-lg">Annulla</button>
                    <button type="submit" class="px-4 py-2 bg-black text-white font-medium rounded-lg hover:bg-gray-800">Invia Invito</button>
                </div>
            </form>
        </div>
    </div>

    <%!
        public String formatDate(java.time.LocalDate d) {
            if(d == null) return "Nessuna";
            return d.format(java.time.format.DateTimeFormatter.ofPattern("dd MMM"));
        }
    %>

    <%!
        public String renderCard(Activity a) {
            StringBuilder sb = new StringBuilder();
            sb.append("<div class='task-card p-4 relative bg-white rounded-lg shadow-sm border border-gray-200 hover:shadow-md transition group' data-id='" + a.getId() + "'>");
            sb.append("<div class='mb-2 flex justify-between items-start'><span class='text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wide badge-" + a.getPriority() + "'>" + a.getPriority() + "</span>");
            sb.append("<div class='flex gap-2 opacity-0 group-hover:opacity-100 transition'>");
            String subTasksString = "";
            if(a instanceof TaskGroup) {
                TaskGroup g = (TaskGroup) a;
                for(Activity child : g.getChildren()) subTasksString += child.getTitle().replace("'", "").replace("|", "") + "|"; 
            }
            String deadlineStr = (a.getDeadline() != null) ? a.getDeadline().toString() : "";
            sb.append("<button onclick=\"openEditModal(" + a.getId() + ", '" + a.getTitle().replace("'", "\\'") + "', '" + a.getPriority() + "', '" + deadlineStr + "', '" + subTasksString + "')\" class='text-gray-300 hover:text-blue-500'><i class='fas fa-pen'></i></button>");
            sb.append("<button onclick='deleteActivity(event, " + a.getId() + ")' class='text-gray-300 hover:text-red-500'><i class='fas fa-trash'></i></button>");
            sb.append("</div></div>");
            sb.append("<h4 class='font-semibold text-gray-800 mb-3 text-sm'>" + a.getTitle() + "</h4>");
            if(a instanceof TaskGroup) {
                TaskGroup g = (TaskGroup) a;
                if(!g.getChildren().isEmpty()) {
                    sb.append("<div class='space-y-1 mb-3'>");
                    for(Activity child : g.getChildren()) {
                        sb.append("<div class='flex items-center gap-2 text-xs text-gray-600'><i class='far fa-circle text-gray-400 subtask-check' onclick='deleteActivity(event, " + child.getId() + ")'></i><span>" + child.getTitle() + "</span></div>");
                    }
                    sb.append("</div>");
                }
            }
            sb.append("<div class='flex justify-between items-end mt-2'><span class='text-xs text-gray-400'>" + formatDate(a.getDeadline()) + "</span><div class='w-6 h-6 rounded-full bg-blue-600 text-white flex items-center justify-center text-[10px] font-bold'>EP</div></div></div>");
            return sb.toString();
        }
    %>

    <script>
        function switchTab(tabName) {
            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
            document.getElementById('tab-' + tabName).classList.add('active');
            document.getElementById('content-' + tabName).classList.add('active');
            const mainBtn = document.getElementById('mainActionBtn');
            if (tabName === 'documents') {
                mainBtn.style.display = 'none';
            } else {
                mainBtn.style.display = 'block';
            }
        }

        function openUploadModal() {
            document.getElementById('uploadModal').classList.remove('hidden');
            document.getElementById('uploadModal').classList.add('flex');
        }

        function openInviteModal() {
            document.getElementById('inviteModal').classList.remove('hidden');
            document.getElementById('inviteModal').classList.add('flex');
        }

        function addSubtaskField(value) {
            const container = document.getElementById('subtasksContainer');
            const div = document.createElement('div');
            div.className = 'flex items-center gap-3 px-4 py-3 bg-white border border-gray-200 rounded-lg focus-within:ring-2 focus-within:ring-[#14b8a6]';
            div.innerHTML = `<div class="w-5 h-5 rounded-full border border-gray-300"></div><input type="text" name="subtasks" value="${value}" class="w-full outline-none text-gray-700" placeholder="Aggiungi voce..."><i class="fas fa-times text-gray-300 cursor-pointer hover:text-red-500" onclick="this.parentElement.remove()"></i>`;
            container.appendChild(div);
        }

        function openCreateModal() {
            document.getElementById('modalTitle').innerText = "Nuova Attività";
            document.getElementById('btnSubmit').innerText = "Crea";
            document.getElementById('activityForm').action = "ActivityServlet";
            document.getElementById('inputTitle').value = "";
            document.getElementById('inputDeadline').value = "";
            document.getElementById('subtasksContainer').innerHTML = "";
            addSubtaskField("");
            document.getElementById('modalOverlay').classList.remove('hidden');
            document.getElementById('modalOverlay').classList.add('flex');
        }

        function openEditModal(id, title, priority, dateStr, subtasksStr) {
            document.getElementById('modalTitle').innerText = "Modifica Attività";
            document.getElementById('btnSubmit').innerText = "Salva Modifiche";
            document.getElementById('activityForm').action = "EditActivityServlet";
            document.getElementById('editActivityId').value = id;
            document.getElementById('inputTitle').value = title;
            document.getElementById('inputPriority').value = priority;
            document.getElementById('inputDeadline').value = dateStr;
            const container = document.getElementById('subtasksContainer');
            container.innerHTML = "";
            if (subtasksStr && subtasksStr.length > 0) {
                const tasks = subtasksStr.split("|");
                tasks.forEach(t => { if(t.trim() !== "") addSubtaskField(t); });
            } else {
                addSubtaskField("");
            }
            document.getElementById('modalOverlay').classList.remove('hidden');
            document.getElementById('modalOverlay').classList.add('flex');
        }

        function deleteActivity(event, activityId) {
            event.stopPropagation(); 
            const projectId = <%= currentProject.getId() %>;
            fetch('DeleteActivityServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'projectId=' + projectId + '&activityId=' + activityId
            }).then(r => { if(r.ok) location.reload(); });
        }
        
        function closeModal() {
            document.getElementById('modalOverlay').classList.add('hidden');
            document.getElementById('modalOverlay').classList.remove('flex');
            document.getElementById('inviteModal').classList.add('hidden');
            document.getElementById('inviteModal').classList.remove('flex');
        }

        document.getElementById('modalOverlay').addEventListener('click', function(e) {
            if (e.target === this) closeModal();
        });
        
        document.getElementById('inviteModal').addEventListener('click', function(e) {
            if (e.target === this) {
                 this.classList.add('hidden');
                 this.classList.remove('flex');
            }
        });

        // INIT SORTABLE
        const sortableOptions = {
            group: 'kanban', animation: 150, ghostClass: 'sortable-ghost', delay: 100, delayOnTouchOnly: true,
            onEnd: function (evt) {
                const itemEl = evt.item;
                const newCol = evt.to;
                const activityId = itemEl.getAttribute('data-id');
                const newStatus = newCol.closest('.kanban-column').getAttribute('data-status');
                const projectId = <%= currentProject.getId() %>;
                fetch('UpdateStatusServlet', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'projectId=' + projectId + '&activityId=' + activityId + '&status=' + newStatus
                });
            }
        };
        if(document.getElementById('col-todo')) new Sortable(document.getElementById('col-todo'), sortableOptions);
        if(document.getElementById('col-doing')) new Sortable(document.getElementById('col-doing'), sortableOptions);
        if(document.getElementById('col-done')) new Sortable(document.getElementById('col-done'), sortableOptions);
    </script>
</body>
</html>