# CodePraise Web API [![Build Status](https://travis-ci.org/ISS-SOA/codepraise-api.svg?branch=master)](https://travis-ci.org/ISS-SOA/codepraise-api)

Web API that allowsGithub *projects* to be *appraised* for inidividual *contributions* by *members* of a team.

## Routes

### Root check

`GET /`

Status:

- 200: API server running (happy)

### Appraise a previously stored project

`GET /projects/{owner_name}/{project_name}[/{folder}/]`

Status

- 200: appraisal returned (happy)
- 404: project or folder not found (sad)
- 500: problems finding or cloning Github project (bad)

### Store a project for appraisal

`POST /projects/{owner_name}/{project_name}`

Status

- 201: project stored (happy)
- 404: project or folder not found on Github (sad)
- 500: problems storing the project (bad)

### Set up for test

1. Run `RACK_ENV=test rake db:migrate` if you never run the test.
2. Open a new kernal and run `rake worker:run:test`.
3. Run `rake spec` or any other sperate file on the first kernal to go through the test. 

