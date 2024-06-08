# Docker file from
# https://github.com/vercel/next.js/tree/canary/examples/with-docker
FROM node:18-alpine as base

FROM base AS deps
RUN apk --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED 1

RUN npm run build

FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
COPY --from=builder /app/public ./public

RUN mkdir .next
RUN chwon nextjs:nextjs .next

COPY --from=builder --chown=nextjs:nextjs ./app/.next/standalone .
COPY --from=builder --chown=nextjs:nextjs ./app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV PORT 3000
CMD HOSTNAME="0.0.0.0" node server.js
