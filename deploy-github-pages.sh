#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

load_token() {
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then return 0; fi
  if [[ -n "${GH_TOKEN:-}" ]]; then export GITHUB_TOKEN="$GH_TOKEN"; return 0; fi
  if [[ -f "$HOME/.hermes/.env" ]]; then
    local line
    line=$(grep -E '^(GITHUB_TOKEN|GH_TOKEN)=' "$HOME/.hermes/.env" | tail -1 || true)
    if [[ -n "$line" ]]; then
      export GITHUB_TOKEN="${line#*=}"
      export GITHUB_TOKEN="${GITHUB_TOKEN%$'\r'}"
      export GITHUB_TOKEN="${GITHUB_TOKEN%$'\n'}"
      return 0
    fi
  fi
  for f in /mnt/c/Users/kyle/Desktop/Hermes/github.txt /mnt/c/Users/kyle/Desktop/hermes/github.txt; do
    if [[ -f "$f" ]]; then
      local txt
      txt=$(tr -d '\r\n' < "$f")
      txt="${txt#GITHUB_TOKEN=}"
      txt="${txt#GH_TOKEN=}"
      if [[ -n "$txt" ]]; then export GITHUB_TOKEN="$txt"; return 0; fi
    fi
  done
  return 1
}

if ! load_token; then
  echo "BLOCKED: set GITHUB_TOKEN or GH_TOKEN first" >&2
  exit 2
fi

api() {
  curl -fsS \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$@"
}

USER_JSON=$(api https://api.github.com/user)
GH_USER=$(printf '%s' "$USER_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["login"])')
REPO="chappys-enterprice-site"
OWNER_REPO="$GH_USER/$REPO"

if ! api "https://api.github.com/repos/$OWNER_REPO" >/tmp/cep_repo.json 2>/tmp/cep_repo_get.err; then
  api -X POST https://api.github.com/user/repos \
    -d '{"name":"chappys-enterprice-site","description":"Chappy'"'"'s Enter Price static site","private":false,"has_issues":false,"has_projects":false,"has_wiki":false}' \
    >/tmp/cep_repo.json
fi

git init -b main >/dev/null 2>&1 || git checkout -B main >/dev/null
git config user.name "Hermes Agent"
git config user.email "hermes-agent@users.noreply.github.com"
git add index.html assets CNAME .nojekyll README.md SITE_STATUS.md DEPLOY_GITHUB_PAGES.md deploy-github-pages.sh
git commit -m "Deploy Chappy's Enter Price site" >/dev/null 2>&1 || true
git remote remove origin >/dev/null 2>&1 || true
git remote add origin "https://$GH_USER:$GITHUB_TOKEN@github.com/$OWNER_REPO.git"
git push -u origin main >/tmp/cep_git_push.out 2>/tmp/cep_git_push.err
# Remove token-bearing remote immediately after push.
git remote set-url origin "https://github.com/$OWNER_REPO.git"

# Enable/update GitHub Pages from main branch root.
if ! api -X POST "https://api.github.com/repos/$OWNER_REPO/pages" \
  -d '{"source":{"branch":"main","path":"/"}}' >/tmp/cep_pages_create.json 2>/tmp/cep_pages_create.err; then
  api -X PUT "https://api.github.com/repos/$OWNER_REPO/pages" \
    -d '{"source":{"branch":"main","path":"/"}}' >/tmp/cep_pages_update.json
fi

# Set custom domain on Pages. Ignore transient domain verification errors here; CNAME exists in repo too.
api -X PUT "https://api.github.com/repos/$OWNER_REPO/pages" \
  -d '{"cname":"chappysenterprice.top","source":{"branch":"main","path":"/"}}' >/tmp/cep_pages_cname.json 2>/tmp/cep_pages_cname.err || true

api "https://api.github.com/repos/$OWNER_REPO/pages" > /tmp/cep_pages_status.json
python3 - <<'PY'
import json
p=json.load(open('/tmp/cep_pages_status.json'))
print(json.dumps({
  'repo': p.get('html_url','').split('/settings/pages')[0] if p.get('html_url') else None,
  'html_url': p.get('html_url'),
  'status': p.get('status'),
  'cname': p.get('cname'),
  'source': p.get('source'),
}, indent=2))
PY
