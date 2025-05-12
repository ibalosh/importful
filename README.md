## ![Importful](app/assets/images/logo.svg)

[![GitHub Actions](https://github.com/ibalosh/importful/actions/workflows/ci.yml/badge.svg)](https://github.com/ibalosh/importful/actions)

This is a small fun playground Ruby on Rails app to manage affiliate data for merchants. 

The app allows you to:

- **Sign Up** and **Sign In** with merchants.
- **Upload CSV Files** containing affiliate data, for specific merchant.
- **Upload CSV Files** containing affiliate data, for any merchant (if you login as backdoor admin merchant)
- **Transform and Store** the uploaded data into the database.
- **Show upload to server progress** - show progress of uploaded file to a server 
- **Show error details progress** - in case there are errors during csv processing after uploading
- **Inline editing** - for merchant username/slug
- Show affiliates list for specific merchant (or for backdoor admin show them all)
- Show all imports list for specific merchant (or for backdoor admin show them all)

The app processes the uploaded CSV files, validates the data, and stores it in a structured format for further use.
To play with this task, active storage, hotwire (stimulus, turbo frame/stream) were used. 

The initial task for this app can be found [here](TASK.md).

<div style="text-align: center;">
    <img src="public/readme/main.jpg" alt="Readme image">
    <img src="public/readme/imports.jpg" alt="Readme image" width="600">
    <img src="public/readme/import-details.jpg" alt="Readme image" width="600">
</div>

### Example CSV File

You can find an example CSV files in examples folder.