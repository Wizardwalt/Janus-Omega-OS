# Janus Android Launcher

This Android project is a scaffold for the Titan-facing Janus launcher UI.

## Current Activities
- HomeActivity
- OperatorActivity
- ModulesActivity
- AssistantActivity
- ChatActivity
- DiagnosticsActivity
- NotesActivity
- CreateNoteActivity
- EvidenceActivity
- CreateEvidenceActivity
- ModeControlActivity
- SettingsActivity

## Services
- JanusForegroundService
- BootReceiver

## Runtime Integration
Expected runtime endpoint:

http://10.0.2.2:8080

## Working Android-side scaffold features
- runtime GET support
- runtime POST support
- assistant chat POST
- note create POST
- evidence create POST
- runtime mode switching POST

## Next Steps
- proper JSON parsing into models
- recycler/list-based UI
- button navigation to create screens
- default-home launcher mode
- Titan-style immersive operator UI
