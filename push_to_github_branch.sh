set -e

echo "== Janus GitHub branch push helper =="

printf "Enter branch name to push to: "
read BRANCH_NAME

if [ -z "$BRANCH_NAME" ]; then
  echo "Branch name cannot be empty."
  exit 1
fi

printf "Enter GitHub repo URL (example: https://github.com/YOUR_USER/YOUR_REPO.git): "
read REPO_URL

if [ -z "$REPO_URL" ]; then
  echo "Repo URL cannot be empty."
  exit 1
fi

if [ ! -d .git ]; then
  echo "== Initializing git repository =="
  git init
fi

git config user.name >/dev/null 2>&1 || git config user.name "Replit User"
git config user.email >/dev/null 2>&1 || git config user.email "replit@example.com"

echo "== Creating/switching to branch: $BRANCH_NAME =="
git checkout -B "$BRANCH_NAME"

echo "== Setting origin remote to: $REPO_URL =="
git remote remove origin 2>/dev/null || true
git remote add origin "$REPO_URL"

echo "== Staging files =="
git add .

echo "== Committing files =="
git commit -m "Update Janus Omega runtime, plugins, assistant, evidence, and Android launcher scaffolding" || true

echo "== Pushing branch to GitHub =="
git push -u origin "$BRANCH_NAME"

echo
echo "== Success =="
echo "Pushed current work to branch: $BRANCH_NAME"
echo "Remote:"
git remote -v
