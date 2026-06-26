# Chappy's Enter Price site status

Updated: 2026-06-26T02:32:04.806788+02:00

## Local artifact

- Project root: `/home/kyle/projects/chappys-enterprice-site`
- Main file: `/home/kyle/projects/chappys-enterprice-site/index.html`
- Logo: `/home/kyle/projects/chappys-enterprice-site/assets/chappys-enter-price-logo.svg`
- Zip package: `/home/kyle/projects/chappys-enterprice-site/dist/chappys-enterprice-site-static.zip`
- SHA256: `9502cea034dcdad15b3ce2ea4dde944ccafed1c2e8d1ed0c3fcc16bc874d1c59`

## What is built

Professional static landing page for **Chappy's Enter Price** promoting:

- **Chappy's Car Stories** — premium short-form old-car storytelling.
- **Chappy's Cartifacts** — JDM/youngtimer/weird-old-car humor and product/design line.

Design posture: premium automotive, sharp corners, black/cream/gold, no animation, no vortex/generative visual gimmicks.

## Verification

- HTML parse: PASS
- Assets present: PASS
- Animation CSS: none
- Video/vortex decorative elements: none
- Desktop screenshot: `C:/Users/kyle/Desktop/hermes/ChappyUploads/ops/chappys_enterprice_site_home_v2.png`
- Mobile screenshot: `C:/Users/kyle/Desktop/hermes/ChappyUploads/ops/chappys_enterprice_site_mobile_v4.png`

## Domain / hosting state

`chappysenterprice.top` currently points to Porkbun Pixie default hosting:

- `ALIAS chappysenterprice.top -> pixie.porkbun.com`
- `CNAME *.chappysenterprice.top -> pixie.porkbun.com`

Porkbun API works for DNS. I checked Porkbun API v3 spec: it exposes domain, DNS, URL forwarding and SSL retrieval endpoints, but no Pixie/static file upload endpoint.

**Live status:** not deployed yet — no content upload/hosting route found through the Porkbun API.

## Next live options

1. Use Porkbun web hosting/FTP/panel if enabled.
2. Use another static host and point Porkbun DNS there.
3. Use URL forwarding only if a redirect is acceptable, not as real hosting.


## Deploy attempt — 2026-06-26T02:38:10.096783+02:00

Checked available local deploy credentials: only Porkbun DNS/API credentials exist. No Cloudflare, Netlify, Vercel, FTP/SFTP, GitHub deploy token found.

Prepared deploy scripts:
- `deploy/deploy_ftp.sh`
- `deploy/deploy_netlify.sh`
- `deploy/deploy_cloudflare_pages.sh`

Current blocker for live publication: one real hosting credential/route is required. Porkbun API can edit DNS/URL forwarding/SSL but cannot upload static files to Pixie/default hosting.
