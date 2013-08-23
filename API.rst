******************
Artifacts API docs
******************

Parameters may be passed via query string, request body (url encoded) or request body in json

Artifacts
=============
- get '/v1/data' - get a list of all artifacts
- get '/v1/data/:group' - get a list of all artifacts in a group
- get '/v1/data/:group/:artifact' - get information about a single artifact
- put '/v1/data/:group/:artifact' - create/update an artifact in a group

  - object - The actual object to upload
  - version - The version number of the object
  - filename - The filename of the object
- put '/v1/groups/:group' - create/update a particular group

  - method - deb, tar, war, rpm, gem, etc. ? trigger the appropriate action after upload (e.g. createrepo for RPMs)
- get '/v1/groups/:group' do - get a particular artifact group
- get '/v1/groups' - get a listof artifact groups

