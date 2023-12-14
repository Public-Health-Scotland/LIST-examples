## GitHub Setup

These instructions are for first-time users of GitHub and highlight the steps in setting up a GitHub account.

1. **Sign up** - To use GitHub, you'll need to have a personal GitHub account, you can set that up on the [GitHub website](http://github.com/signup). If using your PHS email address or LDAP username ensure you **don't use the same password as your email account or LDAP login**. 

2. **Edit your details** - you can set these items up as part of the sign-up process. If not, please follow the links and edit them now.

* Go to your [Profile Settings](https://github.com/settings/profile) and add your details with a picture of yourself if you feel comfortable doing so.
* Go to your [Account Settings](https://github.com/settings/admin) and make sure your username is set to be your name (or something more recognisable). This helps to easily identify users.

3. **Get added to the PHS Organisation**.

* The [Public Health Scotland GitHub organisation](https://github.com/Public-Health-Scotland) is the main way permissions are handled. Email [phs.datascience@phs.scot](mailto:phs.datascience@phs.scot) to be added to the organisation with your GitHub username. You'll then be able to be added to or create your own shared repos or teams.

## Gitea Setup

There's pretty much nothing for you to do here. The Gitea server is linked with LDAP and you can access Gitea here: https://phs-git.nhsnss.scot.nhs.uk/ - just log in with your usual LDAP username and password.

If you require an 'organisation' (team) set up or have other queries about Gitea accounts, email [phs.datascience@phs.scot](mailto:phs.datascience@phs.scot).

## git (in RStudio) set up
Git needs to know who you are, use the following commands to configure your username and email using the Terminal (*use the same email and username you're registered with on GitHub.* Remember not to type the arrow symbols `<>` when entering the command:

*The terminal tab can be found in the console pane. If it's not there you can open a new one with `Alt + Shift + R` or `Tools > Terminal > New Terminal`*

* `git config --global user.email "<email address>"` - use your PHS email address here.
* `git config --global user.name "<your name>"` - Use your full name.

    At any time you can check what the current user details are using:

* `git config --global user.email`
* `git config --global user.name`

## Create an SSH key and add it to your GitHub account

Authentication is required to work with Git remotes, e.g., GitHub. Gitea uses HTTPS authentication, with SSH not available, and accepts your standard LDAP username and password. As such, there is no setup required for Gitea. 

In the **Git/SVN** tab, hit *Create RSA Key* (Figure A). 
In the window that appears, hit the *Create* button (Figure B). 
Close this window.

Click, *View public key* (Figure C), and copy the displayed public key (Figure D).

![](https://github.com/SurgicalInformatics/healthyr_book/blob/dfa80747ee81e718d53ddb5f22bfd5599181ba3d/images/chapter14/1.png)


On the GitHub website, open the account settings page and go to the [SSH keys tab](https://github.com/settings/keys) (Figure A). 
Click *Add SSH key* and paste in the public key you have copied from RStudio (Figure B).

![](https://github.com/SurgicalInformatics/healthyr_book/blob/dfa80747ee81e718d53ddb5f22bfd5599181ba3d/images/chapter14/2.png)

## References
 [^1] [PHS git guide](https://public-health-scotland.github.io/git-guide/)
 [^2] [R for Health Data Science](https://argoshare.is.ed.ac.uk/healthyr_book/create-an-ssh-rsa-key-and-add-to-your-github-account.html)
