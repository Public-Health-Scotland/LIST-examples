# Best Practice for Storing GitHub Clones in LIST

This guide outlines best practices for storing GitHub clones in LIST. Following these recommendations helps keep everyone’s work organised and secure. There are two options outlined: 
Option 1 is most closely aligned to existing ways of work and will be what most people are currently using in practice. 
Option 2 is simpler in principle but needs permissions to be set properly. 

## Option 1: Store Clones in your Area Directory (Within the project folder)

This option is the simplest to set up and is the most closely aligned with our usual workflows.

### How to do it 
- Each team has its own directory located under `/conf/LIST_analytics/`, for example, `Lanarkshire/` or `Orkney/`.
- Within each team folder, there is a separate directory for each project. These project directories may be further organised by project type, depending on the team, such as `Primary Care/`.
- Inside the `code` directory for a project, each team member should create a personal subdirectory.
- Clone the GitHub repository into your own folder within the appropriate project directory.

#### Example Directory Structure
```
/conf/LIST_analytics/
│
├── Lanarkshire/
│   ├── project_1/
│   │   ├── data/
│   │   │   ├── input/
│   │   │   └── output/
│   │   ├── code/
│   │   │   ├── alice/
│   │   │   │   └── project_1_github_clone/
│   │   │   └── bob/
│   │   │       └── project_1_github_clone/
│   ├── project_2/
│   │   ├── data/
│   │   │   ├── input/
│   │   │   └── output/
│   │   ├── code/
│   │   │   ├── bob/
│   │   │   │   └── project_2_github_clone/
│   │   │   └── charlie/
│   │   │       └── project_2_github_clone/
│
└── ...
```
### Benefits
- Consolidates project work, including code and data, in one place.  
- Aligns closely with existing workflows.  
- Permissions are managed through the current area directories.

### Drawbacks
- The folder structure can be confusing.  
- There is a potential for accidentally modifying a colleague's clone.  
- There is a risk of poor coding practices, such as referencing data with relative paths like `../../data/input`.

## Option 2: Store Clones in a Personal Folder in LIST_analytics

### How to do it
- Create your own directory directly under `/conf/LIST_analytics/` (e.g., `/conf/LIST_analytics/alice/`).
- Clone projects into this personal folder.
- **Do not** create or store any `data` folders or files inside your personal area — data should not be tracked by git, and also needs to be accessible by the whole team, so it should go in the team/project folder.
- For security, set the folder permissions so that only you can read, write, or execute files in your folder (see below).

#### Create Your Personal Folder Securely in R
Use `{fs}` to create your personal directory with permissions set for 'owner' only:

```r
install.packages("fs")
fs::dir_create("/conf/LIST_analytics/alice", mode = "u=rwx")
```
- Replace `"alice"` with your username.
- The `mode = "u=rwx"` option ensures that only you (the owner) have permissions; no group or other access.

#### Example Directory Structure
```
/conf/LIST_analytics/
│
├── git_clones/
|   ├── alice/
│   |   └── project_1_github_clone/
│   ├── bob/
│   │   ├── project_1_github_clone/
│   │   └── project_2_github_clone/
│   ├── charlie/
│   │   └── project_2_github_clone/
├── Lanarkshire/
│   ├── project_1/
│   │   ├── data/
│   │   │   ├── input/
│   │   │   └── output/
│   ├── project_2/
│   │   ├── data/
│   │   │   ├── input/
│   │   │   └── output/
└── ...
```

### Benefits
- Simpler structure, all project clones are in one place.
- Clear separation: your code is isolated from other users and from data.
- You have full control over permissions — when set correctly, only you can access your clones.
- Provides a location for any GitHub cloned work, even if it doesn't belong to an area, e.g. work on 'Public-Health-Scotland/phsmethods'

### Drawbacks
- Less aligned with existing team workflows.
- If not all projects are managed with GitHub, this approach will create a split system, possibly creating confusion.
- Extra care is needed to set folder permissions properly; otherwise, code could be accidentally exposed or inaccessible.
