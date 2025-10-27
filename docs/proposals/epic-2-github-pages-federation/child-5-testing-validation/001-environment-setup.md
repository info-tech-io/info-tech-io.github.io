# Stage 1: Test Environment & Prerequisites

**Child**: #5 - Testing & Validation
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending
**Estimated Duration**: 0.25 days (2 hours)

---

## 🎯 Stage Objective

Prepare and validate testing environment, verify all prerequisites from Child #4, and establish baseline for testing.

---

## 📋 Tasks

### Task 1: Verify PAT_TOKEN in Product Repositories

Check PAT_TOKEN secret exists in all 4 product repositories (deferred from Child #4).

**Repositories to check**:
- info-tech-io/quiz
- info-tech-io/hugo-templates
- info-tech-io/web-terminal
- info-tech-io/info-tech-cli

**Validation Method**:
```bash
# Use GitHub CLI to check secrets (if accessible)
gh secret list --repo info-tech-io/quiz
gh secret list --repo info-tech-io/hugo-templates
gh secret list --repo info-tech-io/web-terminal
gh secret list --repo info-tech-io/info-tech-cli
```

**Expected Result**: PAT_TOKEN present in all 4 repositories

**Alternative**: If secrets not accessible, verify by checking notify-hub.yml workflows reference the secret

---

### Task 2: Check Workflow Permissions

Verify GitHub Actions workflows have correct permissions in hub repository.

**Checks**:
1. Repository Settings → Actions → General
2. Workflow permissions: Read and write permissions
3. GitHub Pages deployment permissions
4. Repository dispatch permissions

**Files to verify**:
- `.github/workflows/deploy-corporate-incremental.yml` - permissions correct
- `.github/workflows/deploy-docs-federation.yml` - permissions correct

**Expected Permissions**:
```yaml
permissions:
  contents: read
  pages: write
  id-token: write
```

---

### Task 3: Validate Current Deployment State

Document current state of GitHub Pages as baseline for testing.

**URLs to check**:
1. **Corporate Site**: https://info-tech-io.github.io/
   - Homepage accessible
   - All corporate pages functional
   - Navigation working

2. **Documentation Hub**: https://info-tech-io.github.io/docs/
   - Hub page accessible
   - 4 product cards present
   - Links functional

3. **Product Documentation** (all 4):
   - https://info-tech-io.github.io/docs/quiz/
   - https://info-tech-io.github.io/docs/hugo-templates/
   - https://info-tech-io.github.io/docs/web-terminal/
   - https://info-tech-io.github.io/docs/info-tech-cli/

**Data to collect**:
- HTTP status codes (expect 200)
- Page load times
- Content presence
- CSS loading status
- Screenshots for baseline

---

### Task 4: Review Workflow Run History

Analyze recent workflow executions to establish performance baseline.

**Workflows to review**:
1. `deploy-corporate-incremental.yml`
   - Last 5 runs
   - Success rate
   - Average duration
   - Common issues

2. `deploy-docs-federation.yml`
   - Last 5 runs (manual triggers)
   - Success rate
   - Average duration
   - Build log analysis

**Commands**:
```bash
# List recent runs
gh run list --workflow=deploy-corporate-incremental.yml --limit 5
gh run list --workflow=deploy-docs-federation.yml --limit 5

# View specific run details
gh run view <run-id>
```

---

### Task 5: Setup Test Tracking Structure

Initialize tracking for test execution and results.

**Create test tracking file**: `test-results.md`

**Template**:
```markdown
# Child #5: Testing & Validation Results

**Testing Period**: [Start] - [End]
**Tester**: AI Agent + Human Review
**Environment**: Production (info-tech-io.github.io)

## Test Summary

| Stage | Status | Pass/Fail | Issues Found |
|-------|--------|-----------|--------------|
| Stage 1: Environment | ⏳ | - | - |
| Stage 2: E2E Testing | ⏳ | - | - |
| Stage 3: Integration | ⏳ | - | - |
| Stage 4: UX Validation | ⏳ | - | - |
| Stage 5: Performance | ⏳ | - | - |
| Stage 6: Reliability | ⏳ | - | - |
| Stage 7: Documentation | ⏳ | - | - |

## Baseline Metrics

### URLs Status
- Corporate: [Status]
- Docs Hub: [Status]
- Product Docs: [Status]

### Performance Baseline
- Corporate build time: [Time]
- Docs build time: [Time]
- Page load times: [Data]

## Issues Discovered

[List of issues with links to GitHub issues]

## Recommendations

[Testing recommendations]
```

---

## 🎯 Deliverables

- ✅ PAT_TOKEN verification report
- ✅ Workflow permissions validation
- ✅ Current deployment state documentation
- ✅ Workflow history analysis
- ✅ Test tracking structure initialized
- ✅ Baseline metrics documented

---

## ✅ Verification Criteria

- [ ] PAT_TOKEN confirmed in all 4 product repos (or verification method documented)
- [ ] Workflow permissions verified as correct
- [ ] All URLs accessible (200 status)
- [ ] Baseline metrics captured
- [ ] Test tracking initialized
- [ ] No blockers identified

---

## 📝 Notes

- If PAT_TOKEN not directly verifiable, document alternative verification
- Take screenshots of current site state
- Document any anomalies or issues discovered
- This stage resolves items deferred from Child #4

---

**Created**: 2025-10-27
**Status**: Ready to execute
**Next**: Stage 2 - End-to-End Workflow Testing
