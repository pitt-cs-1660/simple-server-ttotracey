# Build stage

# Use Python 3.12 base image
FROM python:3.12-slim AS builder

# Install uv package manager
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
# Set working directory
WORKDIR /app
# Copy pyproject.toml
COPY pyproject.toml ./
COPY . /cc_simple_server ./
# creates virutal environment and install dependencies 
RUN uv sync --no-install-project --no-editable


# Final stage  

# Use Python 3.12-slim base image (smaller footprint)
FROM python:3.12-slim
# set up virtual environment variables
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:${PATH}"
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
# Set working directory
WORKDIR /app
# Copy the virtual environment from build stage
COPY --from=builder --chown=app:app /app/.venv /app/.venv
# Copy application source code
COPY . /cc_simple_server ./
# USER app
# Expose port 8000
EXPOSE 8000
# Set CMD to run FastAPI server on 0.0.0.0:8000
CMD ["uvicorn", "cc_simple_server.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]