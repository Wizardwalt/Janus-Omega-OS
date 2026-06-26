set -e

mkdir -p reports attachments

OUT="reports/smoke-test.txt"

{
  echo "==== JANUS SMOKE TEST ===="
  date
  echo

  echo "## HEALTH"
  curl -s http://127.0.0.1:8080/health
  echo
  echo

  echo "## STATUS"
  curl -s http://127.0.0.1:8080/api/status
  echo
  echo

  echo "## MODULES"
  curl -s http://127.0.0.1:8080/api/modules
  echo
  echo

  echo "## ASSISTANT"
  curl -s http://127.0.0.1:8080/api/assistant
  echo
  echo

  echo "## AUDIT"
  curl -s http://127.0.0.1:8080/api/audit
  echo
  echo

  echo "## MEMORY"
  curl -s http://127.0.0.1:8080/api/memory
  echo
  echo

  echo "## CHAT TEST"
  curl -s -X POST http://127.0.0.1:8080/api/assistant/chat \
    -H 'Content-Type: application/json' \
    -d '{"message":"hello janus smoke test"}'
  echo
  echo

  echo "## CREATE NOTE"
  curl -s -X POST http://127.0.0.1:8080/api/notes/create \
    -H 'Content-Type: application/json' \
    -d '{"title":"Smoke Test Note","body":"Created during automated runtime smoke test."}'
  echo
  echo

  echo "## LIST NOTES"
  curl -s http://127.0.0.1:8080/api/notes
  echo
  echo

  echo "## CREATE EVIDENCE"
  curl -s -X POST http://127.0.0.1:8080/api/evidence/create \
    -H 'Content-Type: application/json' \
    -d '{"label":"Smoke Test Evidence","details":"Created during automated smoke test.","attachment_path":"attachments/smoke-test.txt"}'
  echo
  echo

  echo "## LIST EVIDENCE"
  curl -s http://127.0.0.1:8080/api/evidence
  echo
  echo

  echo "## EXPORT BUNDLE"
  curl -s -X POST http://127.0.0.1:8080/api/export/bundle
  echo
  echo

  echo "## EXPORTS"
  curl -s http://127.0.0.1:8080/api/exports
  echo
  echo

  echo "## MODE GET"
  curl -s http://127.0.0.1:8080/api/mode
  echo
  echo

  echo "## MODE SWITCH -> operator"
  curl -s -X POST http://127.0.0.1:8080/api/mode/operator
  echo
  echo

  echo "## MODE GET AFTER SWITCH"
  curl -s http://127.0.0.1:8080/api/mode
  echo
  echo

  echo "## RUN MODULE core.system_status"
  curl -s -X POST http://127.0.0.1:8080/api/modules/core.system_status/run
  echo
  echo

  echo "## RUN MODULE core.encrypted_notes"
  curl -s -X POST http://127.0.0.1:8080/api/modules/core.encrypted_notes/run
  echo
  echo

  echo "## RUN MODULE core.evidence_index"
  curl -s -X POST http://127.0.0.1:8080/api/modules/core.evidence_index/run
  echo
  echo

  echo "## FINAL AUDIT"
  curl -s http://127.0.0.1:8080/api/audit
  echo
  echo

  echo "==== END SMOKE TEST ===="
} | tee "$OUT"

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
git add smoke_test_janus.sh reports/smoke-test.txt
git commit -m "Add Janus runtime smoke test script and latest smoke test report" || true
git push -u origin "$CURRENT_BRANCH" || echo "Push failed. Check auth/remote."

echo
echo "Smoke test finished."
echo "Report written to: $OUT"
