package com.synergy.controller;

import com.synergy.model.*;
import com.synergy.util.DataManager;
import java.util.List;
import java.time.LocalDate;
import java.util.ArrayList;

public class ProjectController {

    public void createProject(String name, String description, User creator) {
        DataManager dm = DataManager.getInstance();
        
        int newId = dm.getProjects().size() + 1;
        Project newProject = new Project(newId, name, description);
        
        ProjectMembership membership = new ProjectMembership();
        membership.setProject(newProject);
        membership.setUser(creator);
        membership.setIsAdmin(true);
        
        newProject.getMemberships().add(membership);
        
        dm.getProjects().add(newProject);
        dm.saveData();
    }
    
    public Project getProjectById(int id) {
        for (Project p : DataManager.getInstance().getProjects()) {
            if (p.getId() == id) {
                return p;
            }
        }
        return null;
    }
    
    // Metodo CREAZIONE
    public void addActivityToProject(int projectId, String title, String priorityStr, String dateStr, String[] subTasks) {
        DataManager dm = DataManager.getInstance();
        Project p = getProjectById(projectId);
        
        if (p != null) {
            int baseId = (int) (System.currentTimeMillis() & 0xfffffff);
            PriorityLevel priority = PriorityLevel.valueOf(priorityStr);
            
            LocalDate deadline;
            if (dateStr != null && !dateStr.isEmpty()) {
                deadline = LocalDate.parse(dateStr);
            } else {
                deadline = LocalDate.now().plusDays(7);
            }

            Activity newActivity;

            // Logica Gruppo vs Singola
            if (subTasks != null && subTasks.length > 0) {
                boolean hasValidSubtasks = false;
                for(String s : subTasks) if(s != null && !s.trim().isEmpty()) hasValidSubtasks = true;

                if (hasValidSubtasks) {
                    TaskGroup group = new TaskGroup(baseId, title, priority);
                    group.setDeadline(deadline); 

                    int i = 1;
                    for (String subTitle : subTasks) {
                        if (subTitle != null && !subTitle.trim().isEmpty()) {
                            int subId = baseId + i + (int)(Math.random() * 1000); 
                            SingleTask subTask = new SingleTask(subId, subTitle, priority);
                            subTask.setDeadline(deadline); 
                            group.addActivity(subTask);
                            i++;
                        }
                    }
                    newActivity = group;
                } else {
                    newActivity = new SingleTask(baseId, title, priority);
                    newActivity.setDeadline(deadline);
                }
            } else {
                newActivity = new SingleTask(baseId, title, priority);
                newActivity.setDeadline(deadline);
            }
            
            p.getActivities().add(newActivity);
            p.notifyObservers("Notifica attività aggiunta: " + title);
            dm.saveData();
        }
    }
    
    // Metodo DELETE
    public boolean deleteActivity(int projectId, int activityId) {
        DataManager dm = DataManager.getInstance();
        Project p = getProjectById(projectId);
        
        if (p != null) {
            boolean removed = p.getActivities().removeIf(a -> a.getId() == activityId);
            
            if (removed) {
                dm.saveData();
                return true;
            }
            
            for (Activity a : p.getActivities()) {
                if (a instanceof TaskGroup) {
                    TaskGroup group = (TaskGroup) a;
                    boolean removedFromChild = group.getChildren().removeIf(child -> child.getId() == activityId);
                    if (removedFromChild) {
                        dm.saveData();
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    // Metodo UPDATE (Status)
    public boolean updateActivityStatus(int projectId, int activityId, String newStatusStr) {
        DataManager dm = DataManager.getInstance();
        Project p = getProjectById(projectId);
        
        if (p != null) {
            for (Activity a : p.getActivities()) {
                if (a.getId() == activityId) {
                    a.setStatus(ActivityStatus.valueOf(newStatusStr));
                    dm.saveData(); 
                    return true;
                }
                if (a instanceof TaskGroup) {
                    for (Activity child : ((TaskGroup) a).getChildren()) {
                        if (child.getId() == activityId) {
                            child.setStatus(ActivityStatus.valueOf(newStatusStr));
                            dm.saveData();
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }
    
    // Metodo MODIFICA CONTENUTO
    public void updateActivityContent(int projectId, int activityId, String title, String priorityStr, String dateStr, String[] subTasks) {
        DataManager dm = DataManager.getInstance();
        Project p = getProjectById(projectId);
        
        if (p != null) {
            List<Activity> list = p.getActivities();
            for (int i = 0; i < list.size(); i++) {
                Activity a = list.get(i);
                
                if (a.getId() == activityId) {
                    // Usa i setter che abbiamo aggiunto in Activity.java
                    a.setTitle(title);
                    a.setPriority(PriorityLevel.valueOf(priorityStr));
                    
                    if (dateStr != null && !dateStr.isEmpty()) {
                        a.setDeadline(LocalDate.parse(dateStr));
                    }

                    boolean newSubtasksExist = (subTasks != null && subTasks.length > 0 && subTasks[0].trim().length() > 0);
                    
                    if (a instanceof TaskGroup) {
                        TaskGroup group = (TaskGroup) a;
                        group.getChildren().clear();
                        
                        if (newSubtasksExist) {
                            int count = 1;
                            for (String s : subTasks) {
                                if (s != null && !s.trim().isEmpty()) {
                                    int subId = (int)(System.currentTimeMillis() + count * 100);
                                    SingleTask sub = new SingleTask(subId, s, PriorityLevel.valueOf(priorityStr));
                                    sub.setDeadline(a.getDeadline()); 
                                    group.addActivity(sub);
                                    count++;
                                }
                            }
                        }
                    } else if (newSubtasksExist) {
                        TaskGroup newGroup = new TaskGroup(a.getId(), title, PriorityLevel.valueOf(priorityStr));
                        newGroup.setStatus(a.getStatus());
                        newGroup.setDeadline(a.getDeadline()); 
                        
                        int count = 1;
                        for (String s : subTasks) {
                             if (s != null && !s.trim().isEmpty()) {
                                int subId = (int)(System.currentTimeMillis() + count * 100);
                                SingleTask sub = new SingleTask(subId, s, PriorityLevel.MEDIA);
                                sub.setDeadline(a.getDeadline());
                                newGroup.addActivity(sub);
                                count++;
                             }
                        }
                        list.set(i, newGroup);
                    }
                    
                    dm.saveData();
                    return;
                }
            }
        }
    }
    
    // --- GESTIONE TEAM ---
    public boolean inviteUserToProject(int projectId, String userEmail) {
        DataManager dm = DataManager.getInstance();
        Project p = getProjectById(projectId);
        
        if (p == null) return false;
        
        // 1. Cerco l'utente nel database globale
        User userfound = null;
        for (User u : dm.getUsers()) {
            if (u.getEmail().equalsIgnoreCase(userEmail)) {
                userfound = u;
                break;
            }
        }
        
        // Se l'utente non esiste, fallisco
        if (userfound == null) {
            System.out.println("Utente non trovato: " + userEmail);
            return false;
        }
        
        // 2. Controllo se è GIÀ membro del progetto
        for (ProjectMembership pm : p.getMemberships()) {
            if (pm.getUser().getId() == userfound.getId()) {
                System.out.println("Utente già presente nel progetto.");
                return false; 
            }
        }
        
        // 3. Creo la nuova membership (Ruolo default: MEMBER)
        ProjectMembership membership = new ProjectMembership();
        membership.setProject(p);
        membership.setUser(userfound);
        membership.setIsAdmin(false); // Solo chi crea è admin per ora
        
        // 4. Aggiungo e Salvo
        p.getMemberships().add(membership);
        dm.saveData();
        
        return true;
    }
    
 // Metodo FILTRATO: Restituisce solo i progetti dell'utente
    public List<Project> getProjectsByUser(User user) {
        List<Project> result = new ArrayList<>();
        DataManager dm = DataManager.getInstance();
        
        // Scorro tutti i progetti del sistema
        for (Project p : dm.getProjects()) {
            // Per ogni progetto, controllo la lista dei membri
            for (ProjectMembership pm : p.getMemberships()) {
                // Se trovo l'ID dell'utente tra i membri...
                if (pm.getUser().getId() == user.getId()) {
                    result.add(p); // ...aggiungo il progetto alla lista
                    break; // Passo al prossimo progetto
                }
            }
        }
        return result;
    }
}