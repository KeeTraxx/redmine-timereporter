# redmine-timereporter
Redmine Plugin for reporting time logs to a REST backend

## Compability
Plugin has been tested on Redmine 2.4.x and 2.6.x. But should be compatible with most 2.x and 3.x versions.

## Install

    cd ~/redmine/plugins/
    git clone https://github.com/KeeTraxx/redmine-timereporter.git
    
## Configure
The REST endpoint can be configured in the plugin configuration screen.

## Project custom fields

## REST backend format
The plugin will HTTP POST to the REST backend in this JSON format:
 
    {
        "user": {
            "login": "admin",
            "mail": "admin@example.net",
            "firstname": "Redmine",
            "lastname": "Admin",
            "id": 1
        },
        "issue_id": "1",
        "project_id": 1,
        "user_id": 1,
        "hours": 1,
        "time_entry": {
            "comments": "1",
            "hours": 1,
            "issue_id": 1,
            "project_id": 1,
            "tmonth": 7,
            "tweek": 29,
            "tyear": 2015
        },
        "project": {
            "description": "Testerproject",
            "homepage": "",
            "id": 1,
            "identifier": "test",
            "name": "Test",
            "parent_id": null,
            "status": 1,
            "custom_fields": {
                "backend_id": "2"
            }
        }
    }
