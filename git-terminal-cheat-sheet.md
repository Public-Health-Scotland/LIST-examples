## Git Terminal Cheat Sheet

This cheat sheet is for RStudio users moving from the Git pane to the terminal, with a focus on working with GitHub. It covers basic navigation and core Git commands you'll find most useful.

### Basic Terminal Commands

These commands help you navigate and inspect files in your file system.

* **`pwd`** (Print Working Directory)

  * **What it does:** Shows the full path to your current location.

  * **Example:** `pwd` (Might output `/conf/LIST_analytics/my_project`)

* **`ls`** (List)

  * **What it does:** Lists files and folders in your current directory.

  * **Example:** `ls` (Might show `script.R`, `data/`, `README.md`)

  * **Example (show hidden files):** `ls -a`

* **`ls -l`** (List Long Format)

  * **What it does:** Lists files and folders with detailed information, including permissions, ownership, size, and modification time.

  * **Example:** `ls -l`

  * **Understanding Permissions:** The first 10 characters show permissions:

    * 1st char: File type (`-` for file, `d` for directory).

    * Next 9 chars (three sets of three): User, Group, and Others permissions.

    * Within each set: `r` (Read), `w` (Write), `x` (Execute/Traverse), `-` (No permission).

    * **Example:** `-rw-r--r--` means file (`-`), owner can read/write (`rw-`), group can read (`r--`), others can read (`r--`).

* **`cd`** (Change Directory)

  * **What it does:** Moves you into a different folder.

  * **Example (move into a folder):** `cd data` (e.g., from `/conf/LIST_analytics/my_project` to `/conf/LIST_analytics/my_project/data`)

  * **Example (move up one folder):** `cd ..`

  * **Example (move to your home directory):** `cd ~` (This is typically `/home/yourusername` on Posit Workbench)

### Essential Git Commands

These commands mirror the primary actions you perform with the RStudio Git pane buttons. RStudio runs these commands in the background when you use the GUI.

* **`git status`**

  * **What it does:** Shows changed, staged, and untracked files. This is what RStudio shows in the Git pane, explicitly run when you click refresh.

  * **Example:** `git status`

* **`git add`**

  * **What it does:** Stages changes, preparing them for the next commit. Checking the box next to a file in RStudio runs `git add` for that file.

  * **Example (stage a specific file):** `git add script.R`

  * **Example (stage all changed files):** `git add .`

* **`git commit`**

  * **What it does:** Records staged changes to your local history. Clicking "Commit" in RStudio runs `git commit` with your message.

  * **Example:** `git commit -m "Add initial data analysis script"`

* **`git push`**

  * **What it does:** Uploads your local commits to your GitHub repository. Clicking "Push" in RStudio executes this.

  * **Example:** `git push origin main` (Pushes the `main` branch to the `origin` remote on GitHub)

* **`git pull`**

  * **What it does:** Downloads changes from the GitHub repository and integrates them into your current local branch. Clicking "Pull" in RStudio executes this. There is a little drop-down next to the pull button that will also let you do a pull with rebase.

  * **Example:** `git pull origin main`

  * **Example (with rebase):** `git pull --rebase origin main` (Reapplies your local commits on top of remote ones for a cleaner history.)

* **`git clone`**

  * **What it does:** Downloads an existing repository from GitHub to your local machine. This is how you typically start working on a project cloned from GitHub.

  * **Example:** `git clone https://github.com/username/repository.git`

### Advanced Git Commands

These are not in the RStudio GUI but are powerful for managing changes and history.

* **`git stash`**

  * **What it does:** Temporarily saves uncommitted changes. Useful when you need to switch context without committing unfinished work.

  * **Example Scenario:** You need to switch branches for an urgent fix but have unfinished analysis code. Use `git stash` to save your changes, switch branches, fix the bug, then return and use `git stash pop` to reapply your saved work.

  * **Example (stash changes):** `git stash`

  * **Example (apply and remove stash):** `git stash pop`

  * **Example (list stashes):** `git stash list`

* **`git reset`**

  * **What it does:** Undoes changes. Can unstage files, uncommit commits, or discard local modifications. **Use with extreme caution as it can lose work.**

  * **Example Scenario:** You staged a file with `git add` but changed your mind before committing. Use `git reset` to unstage it.

  * **Example (unstage a file):** `git reset HEAD script.R` (Unstages `script.R`, keeping changes in your working directory)

  * **Example Scenario:** You made a commit but immediately realised it was incorrect and want to completely undo it locally.

  * **Example (undo last commit, keep changes):** `git reset HEAD~1` (Moves branch pointer back one commit, keeps changes)

  * **Example (undo last commit, discard changes):** `git reset --hard HEAD~1` (**DANGEROUS**: Discards last commit and all associated changes.)

* **`git revert`**

  * **What it does:** Creates a *new* commit that undos the changes from a previous commit. Safer than `git reset --hard` for undoing committed changes, especially if they've been pushed, as it preserves history.

  * **Example Scenario:** You pushed a commit to GitHub that introduced a bug. Use `git revert` to create a new commit that cancels out the changes from the faulty one, keeping the history clear.

  * **Example:** `git revert HEAD` (Undoes the changes in the *last* commit with a new commit)

  * **Example (revert a specific commit):** `git revert [commit-hash]` (Replace `[commit-hash]` with the commit you want to undo. You can find the commit hash on GitHub by navigating to the commit history page for your repository and clicking on the specific commit.)

### Common Troubleshooting Workflows

Here are some scenarios you might encounter and how to fix them using a mix of terminal and RStudio GUI commands, focusing on GitHub workflows.

* **Scenario 1: Made a commit on the wrong branch**

  * **Problem:** You were working on branch `feature-A`, but forgot to switch and committed some changes to `main` by mistake.

  * **Solution:**

    1. **Undo the last commit (but keep the changes):** In the terminal, navigate to your repository and run `git reset HEAD~1`. This undoes the commit on `main` but leaves your file changes intact in your working directory.

    2. **Temporarily save your changes:** Use `git stash` in the terminal to save the changes you just uncommitted.

    3. **Switch to the correct branch:** Use the Branches menu in the RStudio Git pane to switch to your intended branch (`feature-A`).

    4. **Reapply your saved changes:** Back in the terminal, run `git stash pop` to bring your changes from the stash back into your working directory on `feature-A`.

    5. **Commit on the correct branch:** Use the RStudio Git pane to stage and commit your changes on `feature-A`.

* **Scenario 2: Keeping your feature branch up-to-date with remote `main`**

  * **Problem:** You are working on a feature branch, and the `main` branch on the GitHub repository has been updated. You want to incorporate those changes into your feature branch.

  * **Preferred Solution (GitHub PR flow):**

    1. **Create a Pull Request (PR):** Push your feature branch to GitHub and create a Pull Request from your feature branch targeting `main`.

    2. **Use GitHub's update feature:** On the PR page on GitHub, if `main` has new commits, you will often see a box indicating that the branch is out of date and suggesting an update. Click the "Update branch" button. GitHub will perform a merge or rebase (depending on your repository settings) to bring the latest changes from `main` into your feature branch on GitHub.

    3. **Enable 'Suggest updating branches':** To ensure this option appears, repository administrators can go to **Settings > General** on GitHub and scroll down to the "Pull Requests" section. There's a checkbox for "Suggest updating branches".

    4. **Consider a Draft PR:** If your work is not yet ready for review, you can open the PR as a "Draft Pull Request". This allows you to use the "Update branch" feature while clearly indicating the work is still in progress.

    5. **Pull the updated branch locally:** After updating the branch on GitHub, use `git pull origin your-feature-branch-name` (replace `your-feature-branch-name`) in the terminal or the RStudio Git pane's Pull button to bring those integrated changes back to your local machine.

  * **Alternative Solution (Terminal):**

    1. **Ensure your working directory is clean:** Commit or stash any uncommitted changes on your feature branch.

    2. **Fetch the latest changes:** In the terminal, run `git fetch origin`. This downloads the latest changes from GitHub but doesn't merge them.

    3. **Integrate changes from remote `main`:**

       * **Option A (Merge):** In the terminal, with your feature branch checked out, run `git merge origin/main`. This creates a merge commit.

       * **Option B (Rebase - often preferred for cleaner history):** In the terminal, with your feature branch checked out, run `git rebase origin/main`. This reapplies your feature branch commits on top of the latest `main`. **Be cautious with rebase if you have already pushed your feature branch commits to GitHub.**

    4. **Push your updated branch:** If you used merge, you can use the RStudio Git pane to push. If you used rebase and have previously pushed your branch, you may need to use `git push --force-with-lease origin your-feature-branch-name` in the terminal. **Use `--force-with-lease` instead of `--force` as it's safer.**

This cheat sheet provides the terminal commands for common Git actions, including some powerful ones less often used in the RStudio GUI, and now includes workflows for common issues when working with GitHub, highlighting the PR flow for updating branches.
