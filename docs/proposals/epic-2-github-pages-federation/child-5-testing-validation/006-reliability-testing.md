# Stage 6: Reliability Testing

**Child**: #5 - Testing & Validation
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending (blocked by Stage 5)
**Estimated Duration**: 0.25 days (2 hours)

---

## 🎯 Stage Objective

Test system reliability, error handling, recovery procedures, and failure scenarios to ensure robust operation.

---

## 📋 Tasks

### Task 1: Build Failure Scenarios

Test how system handles build failures.

**Scenario 1: Invalid module.json**

1. **Create Test Branch** (to avoid breaking main):
   ```bash
   cd /root/info-tech-io/quiz
   git checkout -b test/invalid-module-json

   # Break module.json
   echo "INVALID JSON{" > docs/module.json

   git add docs/module.json
   git commit -m "test: Invalid module.json for reliability testing"
   git push origin test/invalid-module-json
   ```

2. **Trigger Build**:
   ```bash
   # Manually trigger docs workflow (or wait for dispatch)
   gh workflow run deploy-docs-federation.yml
   ```

3. **Expected Behavior**:
   - Build should fail gracefully
   - Error message should be clear
   - Other products should continue building (fail_fast=false)
   - No partial deployment
   - Cleanup should occur

4. **Verify**:
   - Check workflow log for error handling
   - Confirm site not broken
   - Verify other products still accessible
   - Check cleanup step executed

5. **Cleanup**:
   ```bash
   git checkout main
   git branch -D test/invalid-module-json
   git push origin --delete test/invalid-module-json
   ```

---

**Scenario 2: Missing Content Directory**

1. **Create Test Setup**:
   ```bash
   cd /root/info-tech-io/web-terminal
   git checkout -b test/missing-content

   # Temporarily hide content
   mv docs/content docs/content-backup

   git add -A
   git commit -m "test: Missing content for reliability testing"
   git push origin test/missing-content
   ```

2. **Trigger and Verify**:
   - Should fail gracefully
   - Error message clear
   - Other products unaffected

3. **Cleanup**:
   ```bash
   git checkout main
   git branch -D test/missing-content
   git push origin --delete test/missing-content
   ```

---

**Scenario 3: Hugo Build Error**

Simulate a Hugo build failure (syntax error in content).

1. **Create Test**:
   ```bash
   cd /root/info-tech-io/info-tech-cli
   git checkout -b test/build-error

   # Create page with invalid frontmatter
   cat > docs/content/test-error.md <<'EOF'
   +++
   title = "Test
   # Missing closing quote - invalid TOML
   +++

   Content here
   EOF

   git add docs/content/test-error.md
   git commit -m "test: Hugo build error for reliability testing"
   git push origin test/build-error
   ```

2. **Trigger and Verify**:
   - Build should fail with Hugo error
   - Error message should reference the file
   - Other products build successfully
   - No site corruption

3. **Cleanup**:
   ```bash
   git checkout main
   git branch -D test/build-error
   git push origin --delete test/build-error
   ```

**Success Criteria**:
- ✅ Build failures detected
- ✅ Clear error messages
- ✅ Other products continue building
- ✅ No partial/broken deployments
- ✅ System remains stable

---

### Task 2: Deployment Failure Recovery

Test deployment failure and rollback.

**Note**: This is harder to simulate in GitHub Pages. Document theoretical approach.

**Theoretical Scenarios**:

1. **GitHub Pages Service Unavailable**:
   - What happens if GitHub Pages down during deploy?
   - Does workflow retry?
   - Is there a timeout?
   - Check workflow YAML for timeout settings

2. **Artifact Upload Failure**:
   - If artifact upload fails partway through
   - Is there automatic retry?
   - Check actions/upload-pages-artifact behavior

3. **Partial Deployment**:
   - Can GitHub Pages have partial state?
   - How is atomicity ensured?
   - Review GitHub Pages deployment mechanism

**Verification Method**:
- Review workflow YAML for error handling
- Check for continue-on-error settings
- Verify cleanup-on-failure steps
- Document rollback procedures

**Document Findings**:
```markdown
## Deployment Failure Handling

### Current Protections:
- Atomic deployment via GitHub Pages API
- Cleanup on failure step exists
- Timeout: [XX] minutes

### Recovery Procedures:
1. Automatic: [describe]
2. Manual: [describe]

### Gaps Identified:
- [Any issues found]
```

---

### Task 3: Recovery Procedures Testing

Test manual recovery from failures.

**Scenario: Need to Rollback Deployment**

1. **Identify Previous Good State**:
   ```bash
   # Check gh-pages branch history
   git log gh-pages --oneline | head -20

   # Identify last known good commit
   GOOD_COMMIT="<commit-sha>"
   ```

2. **Test Rollback**:
   ```bash
   # Create rollback branch
   git checkout gh-pages
   git checkout -b rollback-test
   git reset --hard $GOOD_COMMIT
   git push -f origin rollback-test:gh-pages
   ```

3. **Verify Site Restored**:
   - Check site loads
   - Verify content correct
   - Confirm all pages accessible

4. **Cleanup**:
   ```bash
   # Push correct version back
   git push -f origin main:gh-pages
   ```

**Document Rollback Procedure**:
```markdown
## Emergency Rollback Procedure

### Steps:
1. Identify last good commit in gh-pages branch
2. Force push that commit to gh-pages
3. Wait for GitHub Pages to update (~1-2 minutes)
4. Verify site restored
5. Investigate root cause
6. Fix issue
7. Redeploy

### Command:
```bash
git push -f origin <good-commit>:gh-pages
```

### Recovery Time: ~5 minutes
```

**Success Criteria**:
- ✅ Rollback procedure documented
- ✅ Rollback tested successfully
- ✅ Recovery time acceptable
- ✅ Procedure clear for future use

---

### Task 4: Edge Case Testing

Test unusual but possible scenarios.

**Edge Case 1: Empty docs/ Directory**

1. **Test Setup**:
   ```bash
   cd /root/info-tech-io/quiz
   git checkout -b test/empty-docs

   # Create empty docs dir
   rm -rf docs/*
   touch docs/.gitkeep

   git add -A
   git commit -m "test: Empty docs for edge case testing"
   git push origin test/empty-docs
   ```

2. **Expected Behavior**:
   - Should handle gracefully
   - Maybe skip this product
   - Or show error message
   - Don't break other products

3. **Cleanup**: Delete test branch

---

**Edge Case 2: Very Large Documentation**

Document potential issue (may not test in practice):

```markdown
## Edge Case: Large Docs

**Scenario**: Product has 10,000+ pages

**Potential Issues**:
- Build timeout (current: 10 min)
- Artifact size limit (GitHub: 2GB)
- Deployment time

**Mitigation**:
- Timeout can be increased if needed
- Size limits unlikely to hit
- Pagination/splitting if needed

**Current Limits**:
- Max build time: 10 minutes (configurable)
- Max artifact size: 2GB
- Current largest docs: ~5MB
```

---

**Edge Case 3: Concurrent Modifications**

**Scenario**: Two developers push to different product docs simultaneously

1. **Expected Behavior**:
   - Two repository_dispatch events sent
   - Two federation workflows triggered
   - GitHub Actions queues them
   - They run sequentially (concurrency group)

2. **Verification**:
   - Check concurrency group in workflow YAML
   - Confirm queue behavior
   - Test if possible

**From workflow YAML**:
```yaml
concurrency:
  group: "pages-docs"
  cancel-in-progress: false
```

This means: workflows queue, don't cancel.

---

**Edge Case 4: Network Timeout During Clone**

**Scenario**: Network issue during repository clone

**Expected Behavior**:
- GitHub Actions has built-in retry
- Checkout action handles transient failures
- Workflow should retry or fail clearly

**Verification**:
- Review actions/checkout behavior
- Note retry logic
- Document timeout settings

---

### Task 5: Error Message Validation

Verify error messages are clear and actionable.

**Review Error Messages**:

1. **Collect Error Scenarios**:
   - Invalid JSON
   - Missing file
   - Build failure
   - Permission denied
   - Network error

2. **For Each Error, Verify**:
   - Error message clear
   - Includes context
   - Suggests solution
   - Points to relevant file/line
   - Logs easily findable

3. **Document Error Catalog**:
   ```markdown
   ## Error Message Catalog

   | Error Type | Message | Clarity | Action |
   |------------|---------|---------|--------|
   | Invalid JSON | "..." | ✅ Clear | ✅ Points to file |
   | Build fail | "..." | ✅ Clear | ✅ Shows Hugo error |
   | Missing file | "..." | ✅ Clear | ✅ Shows path |
   ```

**Success Criteria**:
- ✅ All error messages clear
- ✅ Actionable information provided
- ✅ Logs easily accessible
- ✅ Debugging straightforward

---

## 🎯 Deliverables

- ✅ Build failure test report
- ✅ Deployment failure analysis
- ✅ Recovery procedure documentation
- ✅ Edge case test results
- ✅ Error message validation report
- ✅ Rollback procedure guide
- ✅ Reliability test summary

---

## ✅ Verification Criteria

- [ ] Build failures handled gracefully
- [ ] Clear error messages
- [ ] Automatic cleanup works
- [ ] fail_fast=false working (other products continue)
- [ ] No partial deployments
- [ ] Rollback procedure documented and tested
- [ ] Edge cases handled appropriately
- [ ] System resilient to failures
- [ ] Recovery time acceptable

---

## 📝 Notes

- Use test branches to avoid affecting main
- Clean up test branches after testing
- Some scenarios theoretical (document approach)
- Take screenshots of error messages
- If issues found, create GitHub issues with "reliability" label
- Consider creating runbook for common failures

---

**Created**: 2025-10-27
**Status**: Ready to execute after Stage 5
**Next**: Stage 7 - Results Documentation & Issue Creation
