#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  if [[ -f "$HOME/.hermes/.env" ]]; then
    set +u
    source <(grep -E '^(GITHUB_TOKEN|GH_TOKEN)=' "$HOME/.hermes/.env" || true)
    set -u
    GITHUB_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
  fi
fi
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "BLOCKED: set GITHUB_TOKEN or GH_TOKEN first" >&2
  exit 2
fi
api(){ curl -fsS -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "$@"; }
USER_JSON=$(api https://api.github.com/user)
GH_USER=$(python3 - <<'PY' <<<"$USER_JSON"
import sys,json; print(json.load(sys.stdin)['login'])
PY
)
REPO="chappys-enterprice-site"
OWNER_REPO="$GH_USER/$REPO"
if ! api "https://api.github.com/repos/$OWNER_REPO" >/tmp/cep_repo.json 2>/dev/null; then
  api -X POST https://api.github.com/user/repos \
    -d '{"name":"chappys-enterprice-site","description":"Chappy'"'"'s Enter Price static site","private":false,"has_issues":false,"has_projects":false,"has_wiki":false}' >/tmp/cep_repo.json
fi
git init -b main >/dev/null 2>&1 || git checkout -B main
git config user.name "Hermes Agent"
git config user.email "hermes-agent@users.noreply.github.com"
git add index.html assets CNAME .nojekyll README.md SITE_STATUS.md DEPLOY_GITHUB_PAGES.md
git commit -m "Deploy Chappy's Enter Price site" || true
git remote remove origin 2>/dev/null || true
git remote add origin "https://$GH_USER:$GITHUB_TOKEN@github.com/$OWNER_REPO.git"
git push -u origin main
api -X POST "https://api.github.com/repos/$OWNER_REPO/pages" \
  -d '{"source":{"branch":"main","path":"/"}}' >/tmp/cep_pages_create.json 2>/tmp/cep_pages_create.err || \
api -X PUT "https://api.github.com/repos/$OWNER_REPO/pages" \
  -d '{"source":{"branch":"main","path":"/"}}' >/tmp/cep_pages_update.json
api -X PUT "https://api.github.com/repos/$OWNER_REPO/pages" \
  -d '{"cname":"chappysenterprice.top","source":{"branch":"main","path":"/"}}' >/tmp/cep_pages_cname.json || true
api "https://api.github.com/repos/$OWNER_REPO/pages" > /tmp/cep_pages_status.json
python3 - <<'PY'
import json
p=json.load(open('/tmp/cep_pages_status.json'))
print(json.dumps({'html_url':p.get('html_url'),'status':p.get('status'),'cname':p.get('cname'),'custom_404':p.get('custom_404')}, indent=2))
PY
