package com.synergy.model;

import java.io.Serializable;
import java.util.ArrayList; // <--- FONDAMENTALE
import java.util.List;      // <--- FONDAMENTALE

public class Project implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String description;
    
    // Liste di oggetti collegati
    private List<ProjectMembership> memberships = new ArrayList<>();
    private List<Activity> activities = new ArrayList<>();
    private List<ProjectDocument> documents = new ArrayList<>(); // La lista documenti

    public Project(int id, String name, String description) {
        this.id = id;
        this.name = name;
        this.description = description;
    }

    // --- GETTERS & SETTERS ---

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public List<ProjectMembership> getMemberships() {
        if (memberships == null) memberships = new ArrayList<>();
        return memberships;
    }

    public List<Activity> getActivities() {
        if (activities == null) activities = new ArrayList<>();
        return activities;
    }

    // Getter per i documenti (con sicurezza anti-null)
    public List<ProjectDocument> getDocuments() {
        if (documents == null) documents = new ArrayList<>();
        return documents;
    }
}