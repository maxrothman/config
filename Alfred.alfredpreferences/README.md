# Alfred
Backup of all Alfred-related configs.

## Setup
* In Alfred's preferances, got to "Advanced"
* Under "syncing", set the sync folder to this directory's parent
* In the Security & Privacy preference pane in the Privacy tab, add Alfred to the list of apps allowed to control your computer using accessibility features.
  * Without this, some workflows, namely menu bar search, won't work.

## Additional Notes
Some Alfred workflows are not tracked in this repo. They fall into 2 categories:

* Developed by me, and thus in another repo
  * AWS: https://github.com/maxrothman/aws-alfred-workflow
  * Ubuntu AMI Finder: https://github.com/maxrothman/ubuntu-ec2-ami-finder-alfred-workflow
* Dash, which modifies its own executable
  * https://github.com/Kapeli/Dash-Alfred-Workflow

These workflows are in this directory's `.gitignore`. If you install them manually, make sure their directories are still ignored.

This directory also contains a script, `alfred-workflow-status.bash`, that shows what workflows are tracked and not.
