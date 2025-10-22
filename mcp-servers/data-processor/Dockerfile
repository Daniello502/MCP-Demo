FROM python:3.11-slim

WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir \
    mcp \
    asyncio-mqtt \
    aiohttp

# Copy server code
COPY server.py .

# Create startup script
RUN echo '#!/bin/bash' > start.sh && \
    echo 'python server.py' >> start.sh && \
    chmod +x start.sh

EXPOSE 8080

CMD ["./start.sh"]
