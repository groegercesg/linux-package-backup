# linux-package-backup
Linux Package Backup will allow you to backup all the packages you have in your system, so that they can be easily restored.

These are going to, by default, be restored in name only, i.e. the script will backup which packages you have, on restore it will then install the latest stable version of that package

## Sources of packages supported

| Package Sources | Backup | Restore |
| --------------- | ------ | ------- |
| snaps | :heavy_check_mark: | :heavy_check_mark: |
| flatpaks | :heavy_check_mark: | |
| apt | :heavy_check_mark: | :heavy_check_mark: |
| dnf | :heavy_check_mark: |  |
| yum | :heavy_check_mark: |  |
| rpm | :heavy_check_mark: |  |