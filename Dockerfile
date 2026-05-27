# OpenAccountants MCP server — container image for local development and
# self-hosting.  Builds the Python MCP package and runs it under FastMCP's
# Streamable-HTTP transport so remote MCP clients (Claude Desktop custom
# connectors, ChatGPT, agents behind a reverse proxy, etc.) can connect over
# HTTP instead of stdio.
#
# Usage:
#   docker build -t openaccountants-mcp .
#   docker run --rm -p 8000:8000 openaccountants-mcp
#   # then point an MCP client at http://localhost:8000/mcp
#
# Environment knobs (all optional, see openaccountants_mcp/server.py):
#   MCP_TRANSPORT             stdio | streamable-http | sse   (default here: streamable-http)
#   MCP_HOST                  bind host                       (default here: 0.0.0.0)
#   MCP_PORT                  bind port                       (default here: 8000)
#   MCP_STREAMABLE_HTTP_PATH  mount path                      (default: /mcp;
#                             set to "/" when fronted by a proxy that strips
#                             an upstream path prefix)
#   OPENACCOUNTANTS_ROOT      skill content root              (set to /app in image)

FROM python:3.11-slim

WORKDIR /app

# Install the server package first so code edits don't bust the 44 MB
# skill-content layer on rebuild.
COPY pyproject.toml README.md ./
COPY openaccountants_mcp ./openaccountants_mcp
RUN pip install --no-cache-dir .

# Skill content the server reads from $OPENACCOUNTANTS_ROOT/packages.
# Synced from the openaccountants/openaccountants main repo on each release.
COPY packages ./packages

ENV OPENACCOUNTANTS_ROOT=/app \
    MCP_TRANSPORT=streamable-http \
    MCP_HOST=0.0.0.0 \
    MCP_PORT=8000

EXPOSE 8000

CMD ["openaccountants-mcp"]
