<h1>Dot of Doom</h1>
This app sends an iMessage to a team member or entire team(s) when triggered.
<h2>To Use</h2>
<h3>Download</h3>
If you have not yet, download a build from the latest release<br>
This will be<br>
  "dot-of-doom-macos-15-intel.zip" for macs with intel chips<br>
  "dot-of-doom-macos-latest.zip" for macs with m-series chips<br>
Unzip this into your target folder.
<h3>Field Setup</h3>
There should be a "config.template.yml".<br>
Make a copy of this in the folder and fill out the various fields.<br>
These should match existing service types/positions/teams that exist.<br>
The message is arbitrary.<br>
If debug is true, a log will be generated and texts will not be sent.<br>
If debug is false, texts will actually be sent (and logged).
<h3>For retrieving a clientId and clientSecret</h3>
Follow instructions at https://developer.planning.center/docs/#/overview/authentication for generating a Personal Access Token
<h3>To Run</h3>
Run the run.sh via terminal or some trigger.<br>
<span style="color:red;">Note: if running from a context outside of the folder where run.sh is, make sure that you specify the path where run.sh is</span>
Logs will go to logs/dot_of_doom.txt.
