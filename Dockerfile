# Use the official Node.js 20 image as a parent image
FROM node:20-alpine AS base

# Set working directory
WORKDIR /app

# Install required system dependencies including prisma requirements
RUN apk add --no-cache \
    libc6-compat \
    openssl \
    && corepack enable

# Set environment variables
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Install dependencies stage
FROM base AS deps

# Copy package files for workspace
COPY pnpm-*.yaml ./
COPY package.json ./
COPY turbo.json ./

# Copy all package.json files from workspace
COPY apps/app/package.json ./apps/app/
COPY apps/api/package.json ./apps/api/
COPY packages/ ./packages/

# Install all dependencies (including devDependencies) for build stage
RUN pnpm install --frozen-lockfile

# Builder stage
FROM base AS builder

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/packages ./packages

# Copy source code
COPY . .

# Generate Prisma Client and build the application
RUN cd packages/database && \
    pnpm exec prisma generate --no-hints --schema=./prisma/schema.prisma && \
    cd ../.. && \
    pnpm run build

# Production stage
FROM base AS runner

# Set production environment
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S -u 1001 -G nodejs nextjs

# Set working directory
WORKDIR /app

# Copy necessary files from builder
COPY --from=builder --chown=nextjs:nodejs /app/apps/app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/apps/app/.next/static ./apps/app/.next/static
COPY --from=builder --chown=nextjs:nodejs /app/apps/app/public ./apps/app/public

# Use non-root user
USER nextjs

# Expose the port the app will run on
EXPOSE 3000

# Start the application
CMD ["node", "apps/app/server.js"]
