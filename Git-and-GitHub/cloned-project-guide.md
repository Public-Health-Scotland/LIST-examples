# Best Practice for Storing GitHub Clones in LIST

This guide outlines best practices for storing GitHub clones in LIST. Following these recommendations helps keep everyone’s work organised and secure.

## Store Clones in a Personal Folder in LIST_analytics

### How to do it
- A personal folder should exist for you directly under `/conf/LIST_analytics/` (e.g., `/conf/LIST_analytics/alice/`). If this folder does not exist, create your own directory with the same structure .
- Clone projects into this personal folder.
- **Do not** create or store any `data` folders or files inside your personal area — data should not be tracked by git, and also needs to be accessible by the whole team, so it should go in the team/project folder.
- For security, set the folder permissions so that only you can read, write, or execute files in your folder (see below).

#### How to create Your Personal Folder Securely in R
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
