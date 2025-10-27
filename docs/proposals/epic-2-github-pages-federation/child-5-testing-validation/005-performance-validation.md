# Stage 5: Performance Validation

**Child**: #5 - Testing & Validation
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending (blocked by Stage 4)
**Estimated Duration**: 0.25 days (2 hours)

---

## 🎯 Stage Objective

Measure and validate performance metrics: build times, load times, and resource utilization to ensure targets are met.

---

## 📋 Tasks

### Task 1: Build Time Measurement

Measure actual build times and compare with targets.

**Corporate Workflow Build Time**:

```bash
# Trigger workflow and measure
gh workflow run deploy-corporate-incremental.yml

# Get run ID
RUN_ID=$(gh run list --workflow=deploy-corporate-incremental.yml --limit 1 --json databaseId --jq '.[0].databaseId')

# Wait for completion and get duration
gh run view $RUN_ID --json conclusion,createdAt,updatedAt
```

**Measurements**:
- Total workflow duration
- Individual step durations
- Download phase time
- Build phase time
- Merge phase time
- Deploy phase time

**Target**: < 3 minutes total
**Baseline** (from Child #3): < 2 hours actual (58 seconds in test)

---

**Documentation Workflow Build Time**:

```bash
# Trigger workflow
gh workflow run deploy-docs-federation.yml

# Measure duration
RUN_ID=$(gh run list --workflow=deploy-docs-federation.yml --limit 1 --json databaseId --jq '.[0].databaseId')

gh run view $RUN_ID --json conclusion,createdAt,updatedAt
```

**Measurements**:
- Total workflow duration
- Repository clone times (4 products, parallel)
- Federated build execution time
- Individual product build times
- Hub generation time
- Merge phase time
- Deploy phase time

**Target**: < 3 minutes total
**Baseline** (from Child #4): 1m13s (73 seconds)

---

**Build Time Analysis**:

Create performance breakdown:
```markdown
## Build Time Analysis

### Corporate Workflow
- Total: [XX]s (target: 180s)
- Download: [XX]s
- Build: [XX]s
- Merge: [XX]s
- Deploy: [XX]s

### Documentation Workflow
- Total: [XX]s (target: 180s)
- Clone repos: [XX]s
- Build quiz: [XX]s
- Build hugo-templates: [XX]s
- Build web-terminal: [XX]s
- Build info-tech-cli: [XX]s
- Hub generation: [XX]s
- Merge: [XX]s
- Deploy: [XX]s

### Performance Status
- Corporate: ✅/❌ [within/exceeds] target
- Documentation: ✅/❌ [within/exceeds] target
```

**Success Criteria**:
- ✅ Corporate build < 3 minutes
- ✅ Documentation build < 3 minutes
- ✅ Parallel builds working efficiently
- ✅ No performance regressions

---

### Task 2: Page Load Time Measurement

Measure site load times using Lighthouse and browser tools.

**Tools**:
```bash
# Install Lighthouse (if not installed)
npm install -g lighthouse

# Or use Chrome DevTools Lighthouse tab
```

**Corporate Site Load Time**:

```bash
# Run Lighthouse
lighthouse https://info-tech-io.github.io/ \
  --output html \
  --output-path ./corporate-lighthouse.html \
  --chrome-flags="--headless"

# Key metrics to capture:
# - First Contentful Paint (FCP)
# - Largest Contentful Paint (LCP)
# - Time to Interactive (TTI)
# - Total Blocking Time (TBT)
# - Cumulative Layout Shift (CLS)
```

**Target**:
- FCP < 1.8s
- LCP < 2.5s
- TTI < 3.8s
- Overall load < 3s

---

**Documentation Hub Load Time**:

```bash
lighthouse https://info-tech-io.github.io/docs/ \
  --output html \
  --output-path ./docs-hub-lighthouse.html
```

---

**Product Documentation Load Times**:

Test each of 4 products:
```bash
lighthouse https://info-tech-io.github.io/docs/quiz/ --output html --output-path ./quiz-lighthouse.html
lighthouse https://info-tech-io.github.io/docs/hugo-templates/ --output html --output-path ./hugo-lighthouse.html
lighthouse https://info-tech-io.github.io/docs/web-terminal/ --output html --output-path ./terminal-lighthouse.html
lighthouse https://info-tech-io.github.io/docs/info-tech-cli/ --output html --output-path ./cli-lighthouse.html
```

---

**Load Time Summary**:

```markdown
## Page Load Times

| Page | FCP | LCP | TTI | Score | Status |
|------|-----|-----|-----|-------|--------|
| Corporate | Xs | Xs | Xs | X/100 | ✅/❌ |
| Docs Hub | Xs | Xs | Xs | X/100 | ✅/❌ |
| Quiz Docs | Xs | Xs | Xs | X/100 | ✅/❌ |
| Hugo Docs | Xs | Xs | Xs | X/100 | ✅/❌ |
| Terminal Docs | Xs | Xs | Xs | X/100 | ✅/❌ |
| CLI Docs | Xs | Xs | Xs | X/100 | ✅/❌ |

**Overall Performance Score**: XX/100
**Target**: > 90/100
```

**Success Criteria**:
- ✅ All pages load < 3 seconds
- ✅ Lighthouse scores > 90
- ✅ Core Web Vitals in "Good" range
- ✅ No performance bottlenecks

---

### Task 3: Resource Utilization Measurement

Measure GitHub Actions and deployment resource usage.

**GitHub Actions Minutes**:

```bash
# Check workflow run times
gh run list --workflow=deploy-corporate-incremental.yml --limit 10 --json conclusion,startedAt,updatedAt

gh run list --workflow=deploy-docs-federation.yml --limit 10 --json conclusion,startedAt,updatedAt
```

**Calculate**:
- Minutes used per corporate deployment
- Minutes used per docs deployment
- Total minutes for federation testing
- Projected monthly usage

**GitHub Actions Limits**:
- Free tier: 2,000 minutes/month
- Current usage estimate: [XX] minutes/month

---

**Artifact Sizes**:

```bash
# Check GitHub Pages artifact size
gh run view <run-id> --json jobs

# In workflow logs, find artifact upload size
```

**Measurements**:
- Corporate site artifact size
- Documentation artifact size
- Total deployed site size
- Size per product

**Expected Sizes**:
- Corporate site: ~5-10 MB
- Documentation hub: ~1 MB
- Each product docs: ~2-5 MB
- Total site: ~15-30 MB

---

**Deployment Size Analysis**:

```bash
# Clone gh-pages and measure
git clone -b gh-pages https://github.com/info-tech-io/info-tech-io.github.io.git gh-pages-size-check
cd gh-pages-size-check

# Measure sizes
du -sh .
du -sh docs/
du -sh docs/quiz/
du -sh docs/hugo-templates/
du -sh docs/web-terminal/
du -sh docs/info-tech-cli/

# Count files
find . -type f | wc -l
find . -name "*.html" | wc -l
find . -name "*.css" | wc -l
find . -name "*.js" | wc -l
```

**Resource Summary**:

```markdown
## Resource Utilization

### GitHub Actions
- Corporate workflow: [XX] minutes
- Docs workflow: [XX] minutes
- Average per deployment: [XX] minutes
- Estimated monthly: [XX] minutes
- Limit status: ✅ Within free tier / ❌ Approaching limit

### Artifact Sizes
- Corporate site: [XX] MB
- Docs hub: [XX] MB
- Quiz docs: [XX] MB
- Hugo docs: [XX] MB
- Terminal docs: [XX] MB
- CLI docs: [XX] MB
- **Total deployed**: [XX] MB

### File Counts
- Total files: [XX]
- HTML files: [XX]
- CSS files: [XX]
- JS files: [XX]
```

**Success Criteria**:
- ✅ Within GitHub Actions free tier limits
- ✅ Artifact sizes reasonable (< 50 MB total)
- ✅ Efficient resource usage
- ✅ No wasteful operations

---

### Task 4: Performance Baseline Documentation

Document current performance as baseline for future optimization.

**Create Performance Baseline Report**:

```markdown
# Performance Baseline - Child #5

**Date**: 2025-10-27
**Environment**: Production (info-tech-io.github.io)

## Build Performance

| Workflow | Duration | Target | Status |
|----------|----------|--------|--------|
| Corporate | XXs | 180s | ✅ |
| Documentation | XXs | 180s | ✅ |

## Load Performance

| Page | Load Time | Lighthouse Score | Status |
|------|-----------|------------------|--------|
| Corporate | Xs | XX/100 | ✅ |
| Docs Hub | Xs | XX/100 | ✅ |
| Product Docs | Xs | XX/100 | ✅ |

## Resource Usage

- GitHub Actions: XX min/month
- Site Size: XX MB
- Files: XX total

## Recommendations

[List of optimization opportunities if any]
```

**Success Criteria**:
- ✅ All metrics documented
- ✅ Baseline established
- ✅ Comparison with targets complete
- ✅ Recommendations provided (if needed)

---

## 🎯 Deliverables

- ✅ Build time measurement report
- ✅ Page load time analysis (Lighthouse reports)
- ✅ Resource utilization report
- ✅ Performance baseline documentation
- ✅ Optimization recommendations (if applicable)
- ✅ Performance test summary

---

## ✅ Verification Criteria

- [ ] Build times measured and within targets
- [ ] Load times measured and acceptable
- [ ] Lighthouse scores > 90
- [ ] Core Web Vitals in "Good" range
- [ ] Resource usage documented
- [ ] Within GitHub Actions limits
- [ ] Baseline established for future comparison
- [ ] No performance regressions identified

---

## 📝 Notes

- Save all Lighthouse reports for documentation
- Compare performance with initial estimates
- Note any performance surprises (better or worse than expected)
- If targets not met, document reasons and create optimization issues
- Consider running tests multiple times for average values
- Performance can vary based on GitHub infrastructure load

---

**Created**: 2025-10-27
**Status**: Ready to execute after Stage 4
**Next**: Stage 6 - Reliability Testing
