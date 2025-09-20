# Coverage Configuration

This project uses multiple coverage approaches depending on Node.js version compatibility.

## c8 Coverage (Recommended for Node.js v24+)

Current working solution using c8:

```bash
npm run test:e2e:cov:manual
```

### c8 Configuration

Coverage settings can be configured in `.c8rc.json`:

```json
{
  "reporter": ["text", "html", "lcov"],
  "exclude": [
    "**/*.spec.ts",
    "**/*.e2e-spec.ts",
    "**/test/**",
    "**/node_modules/**",
    "**/dist/**",
    "src/main.ts"
  ],
  "all": true,
  "src": "src"
}
```

## Jest Coverage (Node.js < v24)

For older Node.js versions, Jest's built-in coverage works:

```bash
# Note: This command has been removed due to Node.js v24+ compatibility issues
# Use npm run test:e2e:cov:manual instead
```

## Coverage Reports

After running coverage, reports are available in:

- **Terminal**: Text output with coverage percentages
- **HTML**: `coverage/lcov-report/index.html` (open in browser)
- **LCOV**: `coverage/lcov.info` (for CI/CD integration)

## Troubleshooting

### Node.js v24+ Coverage Issues

If you encounter:
```
TypeError: The "original" argument must be of type function. Received an instance of Object
```

This is a known compatibility issue with Jest's Istanbul coverage tools and Node.js v24+. Use the c8 alternative:

```bash
npm run test:e2e:cov:manual
```

### Coverage Thresholds

To enforce minimum coverage, add to `jest-coverage.config.js`:

```javascript
coverageThreshold: {
  global: {
    branches: 80,
    functions: 80,
    lines: 80,
    statements: 80
  }
}
```
