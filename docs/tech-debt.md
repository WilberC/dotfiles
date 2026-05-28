# Tech Debt

## projects.conf — source from 1Password

`projects.conf` defines the project directory structure created during install.
It currently lives in the repo, but it contains personal/work structure that
should be private and machine-specific.

**Goal:** store `projects.conf` in 1Password and have `install.sh` fetch it
automatically. If the file is missing, the script should detect it, prompt the
user to authenticate with 1Password, and pull the file before continuing.
