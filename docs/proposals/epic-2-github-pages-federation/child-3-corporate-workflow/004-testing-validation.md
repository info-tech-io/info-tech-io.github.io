# Stage 4: Testing & Validation

**Child**: #3 - Corporate Site Incremental Workflow
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending (after Stage 1, 2, 3)
**Estimated Duration**: 1 day

---

## 🎯 Stage Objective

Comprehensive testing and validation of complete corporate site incremental deployment workflow to ensure `/docs/` preservation and correct operation.

---

## 📋 Test Scenarios

### Scenario 1: Fresh Deployment (Baseline)
**Goal**: Deploy corporate site to empty/new GitHub Pages

**Steps**:
1. Clear existing GitHub Pages (if any):
   ```bash
   # Manual: Delete gh-pages branch or clear Pages settings
   ```
2. Trigger corporate workflow manually
3. Wait for completion
4. Verify deployment

**Expected Results**:
- ✅ Corporate site deployed to root (/)
- ✅ All corporate pages accessible
- ✅ `/docs/` directory created (even if empty with fallback)
- ✅ No errors in workflow logs

**Verification**:
```bash
# Check site structure
curl -I https://info-tech-io.github.io/
curl -I https://info-tech-io.github.io/about/
curl -I https://info-tech-io.github.io/docs/

# All should return 200 OK
```

---

### Scenario 2: Incremental Update (Preservation Test)
**Goal**: Update corporate site while preserving existing `/docs/`

**Setup**:
1. Create mock documentation content:
   ```bash
   # Manually create test docs
   mkdir -p test-docs/docs/test-product
   echo "<h1>Test Product Docs</h1>" > test-docs/docs/test-product/index.html

   # Deploy to Pages (manual)
   ```
2. Note current docs content

**Steps**:
1. Make change to corporate content in info-tech repo
2. Push to main (triggers workflow via repository_dispatch)
3. Wait for deployment
4. Verify corporate updated AND docs preserved

**Expected Results**:
- ✅ Corporate content updated
- ✅ `/docs/test-product/` still exists
- ✅ `/docs/test-product/index.html` unchanged
- ✅ No docs content lost

**Verification**:
```bash
# Verify corporate updated
curl https://info-tech-io.github.io/ | grep "updated-content"

# Verify docs preserved
curl https://info-tech-io.github.io/docs/test-product/ | grep "Test Product Docs"
```

---

### Scenario 3: Multiple Sequential Updates
**Goal**: Verify multiple corporate updates work correctly

**Steps**:
1. Make corporate change #1, push, deploy
2. Make corporate change #2, push, deploy
3. Make corporate change #3, push, deploy
4. Verify cumulative changes

**Expected Results**:
- ✅ All 3 updates reflected
- ✅ No content loss between updates
- ✅ `/docs/` preserved through all updates
- ✅ Each deployment atomic (no partial states)

**Verification**:
- Check all 3 changes visible
- Verify workflow logs show 3 successful runs
- Confirm no errors or rollbacks

---

### Scenario 4: Error Handling & Rollback
**Goal**: Verify graceful failure handling

**Setup**:
1. Introduce deliberate error (e.g., invalid module.json)

**Steps**:
1. Push broken configuration
2. Trigger workflow
3. Watch workflow fail
4. Verify no partial deployment

**Expected Results**:
- ✅ Workflow fails at validation/build step
- ✅ No partial deployment to Pages
- ✅ Previous deployment remains intact
- ✅ Clear error message in logs

**Verification**:
```bash
# Site should still be previous version
curl https://info-tech-io.github.io/ | grep "previous-content"

# Not broken content
```

---

### Scenario 5: Build Performance
**Goal**: Measure and validate build performance

**Metrics to Measure**:
1. **Download time**: How long to download current Pages state
2. **Build time**: How long federated-build.sh takes
3. **Merge time**: How long rsync merge takes
4. **Deploy time**: How long GitHub Pages deployment takes
5. **Total workflow time**: Start to finish

**Target**: < 3 minutes total

**Steps**:
1. Trigger workflow
2. Monitor execution times
3. Record metrics

**Expected Results**:
- ✅ Total time < 3 minutes
- ✅ Build time < 90 seconds
- ✅ No performance degradation over baseline

---

### Scenario 6: Concurrent Update Test
**Goal**: Verify behavior when multiple updates triggered

**Setup**:
1. Configure workflow concurrency (should be `cancel-in-progress: false`)

**Steps**:
1. Trigger workflow manually
2. Immediately trigger again
3. Observe behavior

**Expected Results**:
- ✅ Second workflow queues (waits for first)
- ✅ Both complete successfully
- ✅ No conflicts or failures
- ✅ Final state reflects both updates

---

## 🎯 Acceptance Criteria

### Functional Requirements
- [ ] Scenario 1: Fresh deployment succeeds
- [ ] Scenario 2: `/docs/` preservation confirmed
- [ ] Scenario 3: Multiple updates work
- [ ] Scenario 4: Error handling graceful
- [ ] Scenario 5: Performance within targets
- [ ] Scenario 6: Concurrency handled correctly

### Quality Requirements
- [ ] No content loss in any scenario
- [ ] Atomic deployments (all-or-nothing)
- [ ] Clear error messages
- [ ] Comprehensive logging

### Documentation Requirements
- [ ] All test results documented
- [ ] Screenshots/evidence captured
- [ ] Performance metrics recorded
- [ ] Known issues documented (if any)

---

## 📊 Test Report Template

```markdown
# Child #3 Test Report

**Date**: YYYY-MM-DD
**Tester**: [Name]
**Environment**: Production / Staging

## Test Results Summary

| Scenario | Status | Duration | Notes |
|----------|--------|----------|-------|
| 1. Fresh Deployment | ✅/❌ | Xm Ys | ... |
| 2. Preservation Test | ✅/❌ | Xm Ys | ... |
| 3. Multiple Updates | ✅/❌ | Xm Ys | ... |
| 4. Error Handling | ✅/❌ | Xm Ys | ... |
| 5. Performance | ✅/❌ | Xm Ys | ... |
| 6. Concurrency | ✅/❌ | Xm Ys | ... |

## Performance Metrics

- Download time: X seconds
- Build time: X seconds
- Merge time: X seconds
- Deploy time: X seconds
- Total time: X minutes Y seconds

## Issues Found

1. [Issue description]
   - Severity: High/Medium/Low
   - Status: Open/Resolved

## Conclusion

[ ] All tests passed - Ready for production
[ ] Minor issues - Needs fixes
[ ] Major issues - Requires rework
```

---

## 🧪 Testing Tools

### Manual Testing
```bash
# Test workflow trigger
gh workflow run deploy-corporate-incremental.yml

# Watch workflow progress
gh run watch

# Check workflow logs
gh run view --log
```

### Automated Validation
```bash
# Validate site structure
./scripts/validate-site-structure.sh https://info-tech-io.github.io

# Check for broken links
wget --spider -r -nd -nv https://info-tech-io.github.io 2>&1 | grep -B1 "broken link"
```

---

## 📝 Notes

- Document ALL test runs
- Capture screenshots of key verifications
- Save workflow logs for each scenario
- Note any unexpected behaviors
- Record exact timestamps for performance metrics

---

## 🔄 Iteration Plan

**If tests fail**:
1. Document failure details
2. Fix issues in Stages 1-3
3. Re-run failed scenarios
4. Update test report

**If tests pass**:
1. Complete test report
2. Get stakeholder approval
3. Mark Child #3 as complete
4. Proceed to Child #4

---

**Created**: 2025-10-26
**Status**: Ready to implement after Stage 1, 2, 3
**Next**: Execute test scenarios
