# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2020-04-20
### Added
- CHANGELOG.md file.
- ZMBACKUP_METHOD option, supporting wget, cURL and zimbra.

### Changed
- Renamed folder "installScript" to "install".
- Renamed folder "project" to "src".
- Renamed file "depDownload.sh" to "dependencies.sh".
- Renamed column "sessionID" to "id" in backup_session table.
- Renamed column "sessionID" to "session_id" in backup_account table.
- Changed PID folder to "/var/run/zmbackup".
- HTTPie changed to cURL.
- Minor code changes.
- Correct identation.

### Removed
- Incremental backup options.