# Deploy Chappy's Enter Price via GitHub Pages

Status: local site is ready. GitHub deploy is blocked until a GitHub token or authenticated gh/browser session is available.

## Required token scope

Use a GitHub Personal Access Token with repo creation/push permissions.

Set it locally only, never paste in chat:

```bash
export GITHUB_TOKEN=...
```

Then run:

```bash
cd /home/kyle/projects/chappys-enterprice-site
./deploy-github-pages.sh
```

The script will:

1. detect GitHub username,
2. create/update repo `chappys-enterprice-site`,
3. push `main`,
4. enable GitHub Pages from branch root,
5. set custom domain `chappysenterprice.top`,
6. leave Porkbun DNS to be changed only after Pages exists.
