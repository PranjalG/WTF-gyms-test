# WTF Token Server

Minimal Node.js server that generates signed 100ms JWT auth tokens.

## Setup

```bash
npm install
cp .env.example .env
# Edit .env and paste your 100ms credentials
node index.js
```

## Get 100ms Credentials

1. Go to https://dashboard.100ms.live
2. Create a free account / project
3. Navigate to **Developer → Access Credentials**
4. Copy **App Access Key** and **App Secret**
5. Paste into `.env`

## Endpoints

| Endpoint | Params | Response |
|----------|--------|----------|
| `GET /token` | `userId`, `role` (`member`\|`trainer`), `roomId` (optional) | `{ token: "..." }` |
| `GET /health` | — | `{ status: "ok" }` |

## Example

```bash
curl "http://localhost:3000/token?userId=DK&role=member"
# { "token": "eyJhbGci..." }

curl "http://localhost:3000/token?userId=Aarav&role=trainer&roomId=abc123"
# { "token": "eyJhbGci..." }
```
