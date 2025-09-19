# Syntax docker/dockerfile:1.7-labs
FROM node:20-alpine AS base
ENV NODE_ENV=production \
    TZ=UTC \
    NODE_OPTIONS="--max-old-space-size=768 --dns-result-order=ipv4first"

# Enable corepack for pnpm/yarn if desired (keeping npm for minimalism)
RUN corepack enable || true

FROM base AS build
WORKDIR /app
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
# Ensure dev dependencies (typescript) are installed regardless of production base env
ENV NODE_ENV=development
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
COPY tsconfig.json ./
COPY src ./src
RUN npx tsc -p tsconfig.json

RUN npm prune --omit=dev && npm cache clean --force

FROM base AS runtime
WORKDIR /app
# Copy only needed runtime artifacts
COPY --from=build /app/dist ./dist
COPY package.json ./
COPY --from=build /app/node_modules ./node_modules
EXPOSE 3000
USER node
HEALTHCHECK --interval=30s --timeout=1s --start-period=5s --retries=2 CMD node -e "fetch('http://127.0.0.1:3000/health').then(r=>{if(r.ok)process.exit(0);process.exit(1)}).catch(()=>process.exit(1))"
CMD ["node","dist/main.js"]
