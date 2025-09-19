## High-Performance NestJS (Fastify) Best Practices

### 1. Keep the Dependency Graph Tiny
- Avoid `class-validator` / `class-transformer` unless absolutely required.
- Prefer functional style or simple classes; skip heavy abstractions.
- Remove auto-generated example pipes / filters / interceptors.

### 2. Minimize Work per Request
- Return small, flat JSON objects.
- No dynamic reflection / metadata scanning in hot path.
- Avoid unnecessary `await` if function is synchronous.

### 3. Framework Choices
- Use `@nestjs/platform-fastify` for lower overhead vs Express.
- Disable Nest logger (`logger: false`) and use an external sidecar if logs mandatory.
- Avoid global pipes unless they are pure & cheap; prefer explicit validation at edges.

### 4. Node.js Runtime Tuning
- Use latest LTS (20+) for performance & security.
- Set `NODE_OPTIONS="--max-old-space-size=<~75% container RAM> --dns-result-order=ipv4first"`.
- Keep `UV_THREADPOOL_SIZE` default unless doing crypto/fs heavy tasks.
- Warm-up service if using JIT-intense code before putting behind LB.

### 5. Container & OS
- Pin CPU: single-thread event loop benefits from isolated core (cgroup or cpuset).
- Provide generous file descriptor limit (`ulimit -n 1048576` at host / container runtime).
- Enable TCP reuse & tune kernel (host):
  - `sysctl net.core.somaxconn=65535`
  - `sysctl net.ipv4.ip_local_port_range="2000 65000"`
  - `sysctl net.ipv4.tcp_tw_reuse=1`
  - `sysctl net.ipv4.tcp_fin_timeout=15`
- Use ephemeral port reuse carefully when load testing from single host.

### 6. Load Balancing
- Keep-alive enabled; clients should reuse connections (k6 does by default).
- Use an L4 LB (e.g., AWS NLB) or highly optimized L7 (Envoy tuned, no filters) for scale.
- Scale horizontally rather than pushing single instance beyond stable latency.

### 7. Observability Without Tax
- Use sampling for traces.
- Push logs asynchronously (non-blocking transport) if enabled.
- Expose a lightweight `/metrics` (Prometheus) only if needed; isolate metrics scraping.

### 8. Memory & GC
- Monitor RSS / heap usage. Keep object churn low (reuse small objects where safe).
- Avoid large transient arrays or JSON serialization of big objects.
- Consider `clinic flame` or `0x` to profile hotspots.

### 9. Graceful Shutdown
- Listen for `SIGTERM` and close server quickly to release pod slot.
- Set short `terminationGracePeriodSeconds` plus preStop sleep (1–2s) in Kubernetes.

### 10. Benchmarking Discipline
- Use multiple independent load generators to avoid client saturation.
- Measure p50, p90, p99 separately; watch event loop lag not just CPU.
- Add chaos: packet loss / latency injection to ensure resilience.

### 11. Security Minimalism
- Non-root user in container.
- Read-only root FS plus tmpfs for `/tmp` if required.
- Strip build tools from final image (multi-stage build).

### 12. Future Enhancements (When Needed)
- HTTP/2 or QUIC (Fastify plugin) for multiplexed requests.
- Prefetch / cache immutable config.
- Circuit breakers / bulkheads if calling downstream services.

---
This file intentionally excludes optional layers (ORM, validation, auth) to keep base latency minimal. Introduce them incrementally with measurement.
