# Janus Android Launcher

This Android project is a scaffold for the Titan-facing Janus launcher UI.

## Current Activities
- HomeActivity
- OperatorActivity
- ModulesActivity
- AssistantActivity
- DiagnosticsActivity
- NotesActivity
- EvidenceActivity
- SettingsActivity

## Services
- JanusForegroundService
- BootReceiver

## Runtime Integration
The app currently expects the Janus runtime to be reachable at:

http://10.0.2.2:8080

## Next Steps
- add real JSON parsing
- add assistant chat UI
- add module run buttons
- add evidence create UI
- add default-home launcher mode for Titan builds
