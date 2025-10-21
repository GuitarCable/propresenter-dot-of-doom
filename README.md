<h1>Dot of Doom</h1>
This app sends an iMessage to a team member or entire team(s) when triggered.
<h2>To Use</h2>
<h3>Field Setup</h3>
If you have not yet, download the "dot-of-doom.zip" from the latest release<br>
Then, unzip it to a new folder.<br>
To install, run ./install.sh in the terminal.<br>
Optionally add an argument to specify a custom install location.<br>
Unless otherwise specified, the install will be located in ./install<br>
There should be a "config.template.yml".<br>
Make a copy of this in the folder and fill out the various fields.<br>
These should match existing service types/positions/teams that exist.<br>
The message is arbitrary.<br>
If debug is true, a log will be generated and texts will not be sent.<br>
If debug is false, texts will actually be sent (and logged).
<h3>For retrieving a clientId and clientSecret</h3>
Follow instructions at https://developer.planning.center/docs/#/overview/authentication for generating a Personal Access Token
<h2>To Run</h2>
As long as you have a ruby installation, this application should run.<br>
Simply navigate to the directory and type "ruby ./run.rb" in the terminal.
