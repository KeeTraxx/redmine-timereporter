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
If you need additional information about your project in the 

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
      "hours": 5,
      "time_entry": {
        "comments": "test",
        "hours": 5,
        "issue_id": 1,
        "project_id": 1,
        "tmonth": 7,
        "tweek": 30,
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
      },
      "issue": {
        "tracker_id": 1,
        "project_id": 1,
        "subject": "tester245687",
        "description": "test",
        "due_date": "2015-05-24",
        "category_id": null,
        "status_id": 1,
        "assigned_to_id": 1,
        "priority_id": 1,
        "fixed_version_id": null,
        "author_id": 1,
        "created_on": "2015-05-22T12:41:29Z",
        "updated_on": "2015-07-16T09:38:22Z",
        "start_date": "2015-05-22",
        "done_ratio": 0,
        "estimated_hours": null,
        "parent_id": null,
        "root_id": 1,
        "closed_on": null
      }
    }