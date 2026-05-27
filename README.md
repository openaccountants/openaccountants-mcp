<!-- mcp-name: io.github.openaccountants/openaccountants-mcp -->

<p align="center">
  <a href="https://openaccountants.com">
    <img src="https://avatars.githubusercontent.com/u/275335790?s=400&u=d4b2d3b29d970da1ce3985ac1358b0e4cb45a87e&v=4" alt="OpenAccountants" width="140" />
  </a>
</p>

<h1 align="center">OpenAccountants MCP Server</h1>

<p align="center">
  <strong>AI is computing the world's tax returns.<br/>Who checks the rules it follows?</strong>
</p>

<p align="center">
  An open library of tax-computation skills that AI agents follow instead of guessing — rates,<br/>
  thresholds, and law references written out and checked by licensed practitioners.<br/>
  This MCP server plugs that library straight into Claude, ChatGPT, Cursor, and any MCP client.
</p>

<p align="center">
  <a href="https://pypi.org/project/openaccountants-mcp/"><img src="https://img.shields.io/pypi/v/openaccountants-mcp?style=flat-square&color=blue&label=PyPI" alt="PyPI" /></a>
  <a href="https://github.com/openaccountants/openaccountants-mcp/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/openaccountants/openaccountants-mcp/ci.yml?branch=main&style=flat-square&label=CI" alt="CI" /></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-AGPL--3.0-green?style=flat-square" alt="License: AGPL-3.0" /></a>
  <img src="https://img.shields.io/badge/MCP-compatible-blueviolet?style=flat-square" alt="MCP compatible" />
  <img src="https://img.shields.io/badge/endpoint-live-success?style=flat-square" alt="Endpoint live" />
</p>

<p align="center">
  <a href="https://openaccountants.com">Website</a> ·
  <a href="#quick-start">Quickstart</a> ·
  <a href="#tools">Tools</a> ·
  <a href="https://github.com/openaccountants/openaccountants">Skill catalogue</a> ·
  <a href="https://github.com/openaccountants/openaccountants-mcp/issues">Issues</a>
</p>

<p align="center">
  <strong>134 countries</strong> · <strong>51 US states</strong> · <strong>13 Canadian provinces</strong> · <strong>882 verified skills</strong> · <strong>49 licensed accountants</strong> signed off
</p>

---

## Who this is for

- **Doing your own taxes with AI?** Load a skill for your country so your AI follows the real rules — not its best guess from training data.
- **Building tax into your product?** Drop-in MCP tools, no API key, no rate-limited SaaS, no per-call fees. Self-host or `pip install`.
- **Licensed practitioner?** Verify the rules AI uses for your jurisdiction, put your name on the work — [contribute upstream](https://github.com/openaccountants/openaccountants).

## What changes vs. uploading PDFs to your AI

| Before (manual)                           | After (MCP)                                                |
|-------------------------------------------|------------------------------------------------------------|
| Drag markdown files into every chat       | Install once, AI fetches what it needs                     |
| Pick the right file yourself              | Model calls `list_skills` / `search_skills` and pivots    |
| Locked into one country per conversation  | Cross-border? Load multiple jurisdictions in the same chat |
| Trusting your AI's training data          | Real law references, signed off by named accountants       |

## How it works

```text
You:    "Help me set up a company in Malta and understand my tax obligations."
          ↓
Claude: start(intent="formation", jurisdiction="MT")
          → plan: [mt-freelance-intake, malta-formation, malta-vat-return]
Claude: get_skill("malta-formation")    → entity types, registration steps
Claude: get_skill("malta-vat-return")   → VAT thresholds, filing cadence
          ↓
Claude: walks you through entity choice, registration, and tax setup —
        citing the exact Maltese statutes each rule comes from.
```

US states and Canadian provinces work the same way. Cross-border treaties (Pillar Two, FATCA/CRS, CBAM, DSTs, transfer-pricing) live in a top-level `_cross-border` package so any combination of countries can be loaded together.

| Package | What's inside |
|---------|---------------|
| `_cross-border` | Multi-jurisdiction orchestrator, EU rules, OECD treaty defaults, 70+ treaty corridor WHT rates |
| `_verticals` | Industry-specific skills (developer, e-commerce, content creator, consultant, property investor, medical) |
| `_integrations` | Platform export formats (Xero, QuickBooks, Stripe, Wise, PayPal, Revolut, Amazon, Shopify, FreeAgent, Sage) |

## Tools

This server mirrors the hosted server at `https://www.openaccountants.com/api/mcp` — same surface, same answers.

| Tool | Description |
|------|-------------|
| `start` | **Front door.** Call first whenever a user asks for tax/accounting help. Takes optional `intent` (free text — e.g. `"taxes"`, `"VAT return"`, `"set up a company"`) and `jurisdiction` (e.g. `"MT"`, `"GB"`, `"US-CA"`). Returns either a clarification question or a ready-to-execute plan (`skills_to_load`, `expectations`, `next_action`, `guardrails`). |
| `list_skills` | List published skills with quality tier and verifier. Optional `jurisdiction` (ISO code) and `category` filters. |
| `get_skill` | Given a skill `slug`, returns the full markdown plus a provenance/attribution footer. |
| `get_skill_sections` | Given a `slug`, returns the skill parsed into sections (`heading`, `content`, `level`) for step-by-step application. |
| `search_skills` | Keyword search across skill markdown. Returns the matched section heading and a snippet. |
| `submit_feedback` | Build a pre-filled GitHub New Issue URL the user opens to submit feedback (skill problem, missing jurisdiction, bug). No server-side auth — user submits under their own account. |

Skill access is **read-only** and **path-sandboxed** to the `packages/` directory; `submit_feedback` only constructs a URL, it never calls GitHub itself.

### The `start` flow

`start` is what makes the connector self-guiding:

```text
User:    "Help me with my Malta taxes."
          ↓
Model:   start(intent="taxes", jurisdiction="MT")
          → { status: "ready",
              skills_to_load: [mt-freelance-intake, malta-income-tax, …],
              expectations: "I'll help you build a working paper for your accountant…",
              next_action: "Run the intake skill first, then classify transactions",
              guardrails: [...] }
          ↓
Model:   get_skill("mt-freelance-intake")  →  scope-check questions
Model:   get_skill("malta-income-tax")     →  rates, brackets, deductions
          ↓
Model:   walks the user through the working paper using the loaded skills
```

If the user says "help me with my taxes" with no country, call `start(intent="taxes")` — you get back the list of jurisdictions that have a tax skill so you can ask which applies. Same the other way: `start(jurisdiction="MT")` returns the categories available for Malta.

## Prompts

Guided workflows that turn the skills into a tax engine, not just a library:

| Prompt | Arguments | Purpose |
|--------|-----------|---------|
| `tax-return` | `country`, `tax_year`, `entity_type` | Intake → transaction classification → working paper. |
| `vat-check` | `country`, `period` | Classify transactions for VAT/GST and build a return working paper. |
| `find-deductions` | `country`, `entity_type` | Review expenses and surface deductions the taxpayer is missing. |
| `compare-jurisdictions` | `countries`, `income`, `entity_type` | Side-by-side tax comparison for cross-border planning. |
| `skill-feedback` | `skill_slug`, `country` | Collect structured feedback on a skill after use. |
| `skill-review` | `skillSlug`, `scenario` | Load a skill's sections and apply them to one scenario. |

> The on-disk server reads the open-source markdown in `packages/`. Most skill files don't carry a `jurisdiction` field — it's inherited from the package directory (the folder name for `us-XX`/`ca-XX`, otherwise the code its siblings declare). Quality tier is derived from whether a file names a verifier.

## Quick start

Requires **Python 3.10+**.

```bash
pip install openaccountants-mcp
```

Or with `uv`:

```bash
uv pip install openaccountants-mcp
```

Or from source:

```bash
git clone https://github.com/openaccountants/openaccountants-mcp.git
cd openaccountants-mcp
pip install .
```

### Connect to your AI client

Pick **one**.

**Claude Desktop** — add to `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS):

```json
{
  "mcpServers": {
    "openaccountants": {
      "command": "openaccountants-mcp"
    }
  }
}
```

If installed in a virtualenv or with `uv`:

```json
{
  "mcpServers": {
    "openaccountants": {
      "command": "uv",
      "args": ["run", "--directory", "/path/to/openaccountants-mcp", "openaccountants-mcp"]
    }
  }
}
```

**Cursor** — add to `.cursor/mcp.json` (or via Cursor Settings → MCP):

```json
{
  "mcpServers": {
    "openaccountants": {
      "command": "openaccountants-mcp"
    }
  }
}
```

**Any other MCP client** — run `openaccountants-mcp` (or `python -m openaccountants_mcp`) as a **stdio** transport server.

### Try it

> Help me with my 2025 taxes. Here's my bank statement.

> I need to run payroll for my German employee. What are the withholding rates?

> Help me set up a company in Singapore. What are my options?

The AI calls the MCP tools behind the scenes to load the right country and domain skills, then produces working papers, payslips, formation guides, or whatever output matches your request — without you uploading a single file.

## Docker (self-host / HTTP transport)

The repo root ships a `Dockerfile` that runs the server under FastMCP's Streamable-HTTP transport:

```bash
docker build -t openaccountants-mcp .
docker run --rm -p 8000:8000 openaccountants-mcp
# Point an MCP client at http://localhost:8000/mcp
```

When fronted by a reverse proxy that strips an upstream path prefix (e.g. Caddy `uri strip_prefix /oamcp`), set `MCP_STREAMABLE_HTTP_PATH=/` so the endpoint mounts at the proxied root:

```bash
docker run --rm -p 8000:8000 -e MCP_STREAMABLE_HTTP_PATH=/ openaccountants-mcp
```

The default stdio transport (`pip install openaccountants-mcp && openaccountants-mcp`) is unchanged.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENACCOUNTANTS_ROOT` | Installed package parent (contains `packages/`) | Override to point at a local checkout of the [main repo](https://github.com/openaccountants/openaccountants) when testing unreleased skill content. |
| `MCP_TRANSPORT` | `stdio` | `stdio`, `streamable-http`, or `sse`. HTTP lets remote clients connect via a reverse proxy. |
| `MCP_HOST` | `127.0.0.1` (stdio) / `0.0.0.0` (HTTP) | Bind host for HTTP transports. |
| `MCP_PORT` | `8000` | Bind port for HTTP transports. |
| `MCP_STREAMABLE_HTTP_PATH` | `/mcp` | Mount path for the Streamable-HTTP endpoint. Set to `/` when behind a proxy that strips the upstream prefix. |

## Where the skill content comes from

The `packages/` directory in this repo is a **read-only mirror** of [`openaccountants/openaccountants`](https://github.com/openaccountants/openaccountants) — the canonical source where licensed accountants author and verify the skills. A sync workflow updates this repo on every change upstream, so `pip install openaccountants-mcp` always ships the latest catalogue.

Found a problem with a skill? File it [against the main repo](https://github.com/openaccountants/openaccountants/issues), or call the `submit_feedback` tool from inside any chat — it'll build a pre-filled issue URL for you.

## Smoke test

```bash
python smoke_test.py
```

Exercises every tool, asserts the path sandbox holds, and verifies the catalogue parses cleanly. CI runs this on every push.

## Disclaimer

All skills and outputs are for informational and computational purposes only. **Not tax, legal, or financial advice.** Not a replacement for professional judgment.

Every skill carries a quality tier — either [**accountant-verified**](https://github.com/openaccountants/openaccountants/blob/main/docs/QUALITY-TIERS.md) (a licensed practitioner has signed off, by name) or **research-verified** (drafted from authoritative sources, awaiting sign-off). Always have a qualified professional review before filing or acting upon the output.

## License

[AGPL-3.0-or-later](./LICENSE), with [additional terms](./LICENSE-ADDITIONAL.md). Commercial licensing available — see [COMMERCIAL_LICENSE.md](./COMMERCIAL_LICENSE.md).
