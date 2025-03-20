# Docker Setup Guide

## Overview
This Docker configuration provides a production-ready setup for your Next.js application.

## Prerequisites
- Docker installed on your system
- Docker Compose installed on your system
- Node.js 20.x or later

## Configuration Files
- `Dockerfile`: Multi-stage build for optimal production image
- `.dockerignore`: Excludes unnecessary files from the build
- `docker-compose.yml`: Orchestrates the application deployment

## Getting Started

1. Build the Docker image:
```bash
docker compose build
```

2. Start the application:
```bash
docker compose up -d
```

3. Check the logs:
```bash
docker compose logs -f
```

## Environment Variables
Create a `.env` file with the following variables:
```env
DATABASE_URL=your_database_url
NODE_ENV=production
```

## Health Checks
The application includes a health check endpoint at `/api/health`.
Monitor container health with:
```bash
docker compose ps
```