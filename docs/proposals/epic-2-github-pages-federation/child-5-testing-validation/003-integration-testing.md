# Stage 3: Integration & Independence Testing

**Child**: #5 - Testing & Validation
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending (blocked by Stage 2)
**Estimated Duration**: 0.5 days (4 hours)

---

## 🎯 Stage Objective

Verify integration between workflows, test repository dispatch automation, and ensure workflows operate independently without interference.

---

## 📋 Tasks

### Task 1: Workflow Independence Verification

Test that workflows don't interfere with each other.

**Test Scenarios**:

1. **Concurrent Execution Attempt**:
   - Trigger corporate workflow
   - Immediately trigger docs workflow (while corporate running)
   - Observe: Should queue or run concurrently without conflicts

2. **Content Isolation**:
   - Deploy corporate site
   - Verify /docs/ untouched
   - Deploy docs
   - Verify corporate root untouched

3. **Atomic Deployment Verification**:
   - Check GitHub Pages deployment is atomic
   - Verify no partial states visible to users
   - Confirm rollback on failure (if testable)

**Success Criteria**:
- ✅ Workflows don't corrupt each other's content
- ✅ Concurrency handled gracefully
- ✅ Content boundaries respected
- ✅ Atomic deployment confirmed

---

### Task 2: Repository Dispatch Testing (Quiz)

Test automated deployment trigger from quiz repository.

**Steps**:
1. **Make Documentation Change**:
   ```bash
   cd /root/info-tech-io/quiz

   # Make small change to docs
   echo "\n## Test Update $(date)" >> docs/content/test-page.md

   # Commit and push
   git add docs/content/test-page.md
   git commit -m "test: Trigger docs federation test"
   git push origin main
   ```

2. **Verify notify-hub.yml Triggered**:
   ```bash
   # Check quiz workflow runs
   gh run list --repo info-tech-io/quiz --workflow=notify-hub.yml --limit 1
   ```

3. **Verify Repository Dispatch Sent**:
   - Check quiz workflow log for dispatch confirmation
   - Expected: "Repository Dispatch" step succeeds

4. **Verify Federation Workflow Triggered**:
   ```bash
   # Check hub workflow runs
   gh run list --workflow=deploy-docs-federation.yml --limit 1
   ```
   - Event type should be: `quiz-docs-updated`
   - Client payload should contain quiz repository info

5. **Verify Quiz Docs Updated**:
   - Visit: https://info-tech-io.github.io/docs/quiz/
   - Confirm test update visible
   - Check other products unaffected

**Success Criteria**:
- ✅ Quiz docs change triggers notify workflow
- ✅ Repository dispatch sent successfully
- ✅ Federation workflow triggered automatically
- ✅ Quiz docs updated on site
- ✅ Other products preserved

---

### Task 3: Repository Dispatch Testing (Hugo Templates)

Test automated deployment trigger from hugo-templates repository.

**Steps**:
1. **Make Documentation Change**:
   ```bash
   cd /root/info-tech-io/hugo-templates

   # Make small change
   echo "\n## Test Update $(date)" >> docs/content/test-page.md

   git add docs/content/test-page.md
   git commit -m "test: Trigger docs federation test"
   git push origin main
   ```

2. **Verify notify-hub.yml Triggered**:
   ```bash
   gh run list --repo info-tech-io/hugo-templates --workflow=notify-hub.yml --limit 1
   ```

3. **Verify Event Type Correct**:
   - Event type should be: `hugo-templates-docs-updated` (after bug fix in Child #4)
   - Verify bug fix working

4. **Verify Federation Workflow Triggered**:
   ```bash
   gh run list --workflow=deploy-docs-federation.yml --limit 1
   ```

5. **Verify Hugo Templates Docs Updated**:
   - Visit: https://info-tech-io.github.io/docs/hugo-templates/
   - Confirm test update visible

**Success Criteria**:
- ✅ Hugo-templates docs change triggers workflow
- ✅ Correct event type sent (bug fix validated)
- ✅ Federation workflow triggered
- ✅ Hugo-templates docs updated
- ✅ Other products preserved

---

### Task 4: Repository Dispatch Testing (Web Terminal)

Test automated deployment trigger from web-terminal repository.

**Steps**:
1. **Make Documentation Change**:
   ```bash
   cd /root/info-tech-io/web-terminal

   echo "\n## Test Update $(date)" >> docs/content/test-page.md

   git add docs/content/test-page.md
   git commit -m "test: Trigger docs federation test"
   git push origin main
   ```

2. **Verify Automation**:
   - Check notify workflow triggered
   - Check event type: `web-terminal-docs-updated`
   - Check federation workflow triggered

3. **Verify Web Terminal Docs Updated**:
   - Visit: https://info-tech-io.github.io/docs/web-terminal/
   - Confirm update visible

**Success Criteria**:
- ✅ Web-terminal triggers work
- ✅ End-to-end automation functional

---

### Task 5: Repository Dispatch Testing (InfoTech CLI)

Test automated deployment trigger from info-tech-cli repository.

**Steps**:
1. **Make Documentation Change**:
   ```bash
   cd /root/info-tech-io/info-tech-cli

   echo "\n## Test Update $(date)" >> docs/content/test-page.md

   git add docs/content/test-page.md
   git commit -m "test: Trigger docs federation test"
   git push origin main
   ```

2. **Verify Automation**:
   - Check notify workflow triggered
   - Check event type: `cli-docs-updated`
   - Check federation workflow triggered

3. **Verify CLI Docs Updated**:
   - Visit: https://info-tech-io.github.io/docs/info-tech-cli/
   - Confirm update visible

**Success Criteria**:
- ✅ CLI triggers work
- ✅ All 4 products now have validated automation

---

### Task 6: Download-Merge-Deploy Pattern Validation

Verify the core federation pattern works correctly.

**Tests**:

1. **Download Phase**:
   - Workflow downloads current gh-pages state
   - Existing content preserved in memory
   - No data loss during download

2. **Build Phase**:
   - New content built separately
   - Parallel builds working
   - No interference with existing content

3. **Merge Phase**:
   - Selective merge preserves non-target areas
   - rsync strategy working correctly
   - Conflict resolution appropriate
   - preserve-base-site strategy functional

4. **Deploy Phase**:
   - Atomic deployment
   - Complete or rollback (no partial)
   - GitHub Pages updated correctly

**Validation Method**:
- Review workflow logs for each phase
- Check file timestamps in gh-pages branch
- Verify no files deleted unexpectedly
- Confirm selective updates working

**Success Criteria**:
- ✅ All 4 phases work correctly
- ✅ Pattern preserves existing content
- ✅ Selective updates working
- ✅ No unintended file changes

---

## 🎯 Deliverables

- ✅ Workflow independence test report
- ✅ Repository dispatch test reports (all 4 products)
- ✅ Download-Merge-Deploy validation report
- ✅ Integration test summary
- ✅ Workflow execution logs
- ✅ Automation validation report

---

## ✅ Verification Criteria

- [ ] Workflows operate independently
- [ ] Repository dispatch works from all 4 products
- [ ] Automated triggers functional end-to-end
- [ ] Bug fix in hugo-templates validated
- [ ] Download-Merge-Deploy pattern working
- [ ] No deployment conflicts
- [ ] All products can update independently
- [ ] Selective merge preserves content correctly

---

## 📝 Notes

- Test repository dispatch carefully - creates real commits
- May want to use test branches for trigger testing
- Document any delay between trigger and deployment
- Note webhook/dispatch latency
- If automation fails, document and create GitHub issue
- Clean up test commits after validation

---

**Created**: 2025-10-27
**Status**: Ready to execute after Stage 2
**Next**: Stage 4 - User Experience Validation
