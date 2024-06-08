FROM node:18-alpine
WORKDIR /app
EXPOSE 3000
ENV PORT 3000
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
RUN apk add --no-cache libc6-compat
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
COPY . .
RUN npm ci
RUN npm run build
RUN chwon -R nextjs:nodejs .

USER nextjs
CMD npm run start
