## Setting Up Git for PHS Posit Users

These instructions guide you through setting up a GitHub account and configuring Git access for working with Public Health Scotland (PHS) Posit infrastructure.

1. **Sign Up and Edit Details**
   * Create a personal account on [GitHub](http://github.com/signup). **Important:** If using your PHS email address or LDAP username ensure you **don't use the same password** as your email account or LDAP login.
   * Set up your profile details (picture optional) and display name (preferably your full name) in your account settings:

        * [Profile Settings](https://github.com/settings/profile) to add details and a profile picture.
        * [Account Settings](https://github.com/settings/admin) to set your username/display name. This helps find and identify users.

4. **Be added to the PHS Organisation**.

    * The [Public Health Scotland GitHub organisation](https://github.com/Public-Health-Scotland) is the main way permissions are handled. To be added, email [phs.datascience@phs.scot](mailto:phs.datascience@phs.scot) with your GitHub username. This allows access to shared repositories and teams.

## Gitea Setup

There's no additional setup required for Gitea. You can log in with your usual LDAP credentials at [phs-git.nhsnss.scot.nhs.uk](https://phs-git.nhsnss.scot.nhs.uk/).

If you require an 'organisation' (team) set up or have other queries about Gitea accounts, email [phs.datascience@phs.scot](mailto:phs.datascience@phs.scot).

## git (in RStudio) set up
Git needs to know who you are, use the following commands to configure your username and email using the Terminal (*use the same email and username you're registered with on GitHub.* Remember not to type the arrow symbols `<>` when entering the command:

*The terminal tab can be found in the console pane. If it's not there you can open a new one with `Alt + Shift + R` or `Tools > Terminal > New Terminal`*

* `git config --global user.email "<email address>"` - use your PHS email address here.
* `git config --global user.name "<your name>"` - Use your full name.

You can verify your user details with:

* `git config --global user.email`
* `git config --global user.name`

## Create an SSH key and add it to your GitHub account

*SSH key authentication is required for working with Git remotes like GitHub. However, Gitea uses HTTPS authentication and accepts your standard LDAP credentials, so no additional setup is needed for Gitea.*

In the **Git/SVN** tab, hit *Create RSA Key* (Figure A). 
In the window that appears, hit the *Create* button (Figure B). 
Close this window.

Click, *View public key* (Figure C), and copy the displayed public key (Figure D).

![](https://github.com/SurgicalInformatics/healthyr_book/blob/dfa80747ee81e718d53ddb5f22bfd5599181ba3d/images/chapter14/1.png)


On the GitHub website, open the account settings page and go to the [SSH keys tab](https://github.com/settings/keys) (Figure A). 
Click *Add SSH key* and paste the public key you copied from RStudio (Figure B).

![](https://github.com/SurgicalInformatics/healthyr_book/blob/dfa80747ee81e718d53ddb5f22bfd5599181ba3d/images/chapter14/2.png)

## References
 [^1] [PHS git guide](https://public-health-scotland.github.io/git-guide/)
 [^2] [R for Health Data Science](https://argoshare.is.ed.ac.uk/healthyr_book/create-an-ssh-rsa-key-and-add-to-your-github-account.html)
