# Best Practice for Storing GitHub Clones in LIST

This guide describes best practices for storing GitHub clones in LIST. Following these recommendations helps keep everyone's work organised and secure. We have considered several options for managing this and have decided on the following.

## Store Clones in a Personal Folder in LIST_analytics

### How to do it

- A personal folder should exist for you directly under `/conf/LIST_analytics/git_clones` (e.g., `/conf/LIST_analytics/git_clones/alice1/`).
  - If this folder does not exist, create your own directory with the same structure. For security, set the folder permissions so that only you can read, write, or execute files in your folder (see below).
- Clone projects into this personal folder.
- **Do not create or store any `data` folders or files inside your personal area** — data should not be tracked by git, and also needs to be accessible by the whole team, so it should go in the team/project folder.

### Example Directory Structure
```
/conf/LIST_analytics/
│
├── git_clones/
|   ├── alice1/
│   |   └── project_1_github_clone/
│   ├── bob2/
│   │   ├── project_1_github_clone/
│   │   └── project_2_github_clone/
│   ├── charlie1/
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

### How to create your Personal Folder securely in R

*These folders have already been created for most staff using your LDAP username, so these instructions are only relevant for new staff*

Use `{fs}` to create your personal directory with permissions set for 'owner' only:

```r
install.packages("fs")
fs::dir_create("/conf/LIST_analytics/alice1", mode = "u=rwx")
```
- Replace `"alice"` with your username.
- The `mode = "u=rwx"` option ensures that only you (the owner) have permissions; no group or other access.
