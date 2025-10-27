# Stage 2: End-to-End Workflow Testing

**Child**: #5 - Testing & Validation
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending (blocked by Stage 1)
**Estimated Duration**: 0.75 days (6 hours)

---

## 🎯 Stage Objective

Execute complete end-to-end testing of both workflows (corporate and documentation) to verify full federation lifecycle.

---

## 📋 Tasks

### Task 1: Corporate Workflow E2E Test

Test complete corporate site deployment workflow.

**Steps**:
1. **Trigger Workflow**:
   ```bash
   gh workflow run deploy-corporate-incremental.yml
   ```

2. **Monitor Execution**:
   - Watch workflow progress in real-time
   - Note each step completion
   - Capture any warnings or errors
   - Record execution time

3. **Verify Deployment**:
   - Check corporate site updated: https://info-tech-io.github.io/
   - Verify all corporate pages accessible
   - Check navigation links
   - Confirm content correctness

4. **Verify Preservation**:
   - Confirm /docs/ directory preserved
   - Check all doc products still accessible
   - Verify no content loss

**Success Criteria**:
- ✅ Workflow completes successfully
- ✅ Corporate site updated correctly
- ✅ /docs/ directory fully preserved
- ✅ No 404 errors
- ✅ Build time < 3 minutes

---

### Task 2: Documentation Workflow E2E Test

Test complete documentation federation deployment workflow.

**Steps**:
1. **Trigger Workflow**:
   ```bash
   gh workflow run deploy-docs-federation.yml
   ```

2. **Monitor Execution**:
   - Watch parallel product builds
   - Monitor federated-build.sh execution
   - Note hub generation
   - Record merge process
   - Capture execution time

3. **Verify All Products Deployed**:
   - Check quiz: https://info-tech-io.github.io/docs/quiz/
   - Check hugo-templates: https://info-tech-io.github.io/docs/hugo-templates/
   - Check web-terminal: https://info-tech-io.github.io/docs/web-terminal/
   - Check info-tech-cli: https://info-tech-io.github.io/docs/info-tech-cli/

4. **Verify Documentation Hub**:
   - Hub accessible: https://info-tech-io.github.io/docs/
   - All 4 product cards present
   - Links to products work
   - Back to main site link works

5. **Verify Corporate Preservation**:
   - Corporate site still accessible
   - No content overwritten
   - Root pages intact

**Success Criteria**:
- ✅ Workflow completes successfully
- ✅ All 4 products deployed correctly
- ✅ Documentation hub functional
- ✅ Corporate site fully preserved
- ✅ No 404 errors
- ✅ Build time < 3 minutes

---

### Task 3: Sequential Execution Test

Test both workflows running in sequence without conflicts.

**Steps**:
1. **Run Corporate Workflow First**:
   ```bash
   gh workflow run deploy-corporate-incremental.yml
   ```
   - Wait for completion
   - Verify deployment

2. **Run Documentation Workflow Second**:
   ```bash
   gh workflow run deploy-docs-federation.yml
   ```
   - Wait for completion
   - Verify deployment

3. **Verify No Conflicts**:
   - Check corporate site intact
   - Check all docs intact
   - Verify no content loss
   - Check timestamps

4. **Reverse Order Test**:
   - Run docs workflow first
   - Then run corporate workflow
   - Verify both preserved

**Success Criteria**:
- ✅ Both workflows execute successfully in sequence
- ✅ No conflicts or interference
- ✅ All content preserved
- ✅ Order doesn't matter (both sequences work)

---

### Task 4: Content Validation

Thorough validation of deployed content.

**Corporate Site Checks**:
- [ ] Homepage loads correctly
- [ ] About page accessible
- [ ] Products page accessible
- [ ] Open source page accessible
- [ ] Blog accessible (if exists)
- [ ] All assets loading (CSS, images)
- [ ] Navigation functional

**Documentation Hub Checks**:
- [ ] Hub index.html loads
- [ ] 4 product cards render
- [ ] Icons display correctly
- [ ] Descriptions present
- [ ] Links clickable
- [ ] Responsive design works
- [ ] Back link functional

**Product Documentation Checks** (for each of 4 products):
- [ ] Index page loads
- [ ] Content directory accessible
- [ ] Navigation within docs works
- [ ] CSS styling correct
- [ ] Images/assets load
- [ ] Internal links functional
- [ ] No broken links

**HTML Structure Validation**:
```bash
# Check for common HTML issues
curl -s https://info-tech-io.github.io/ | grep -i "error\|404\|not found"
curl -s https://info-tech-io.github.io/docs/ | grep -i "error\|404\|not found"
```

---

### Task 5: Deployment Completeness Check

Verify all expected files deployed.

**GitHub Pages Branch Check**:
```bash
# Clone gh-pages branch
git clone -b gh-pages https://github.com/info-tech-io/info-tech-io.github.io.git gh-pages-check
cd gh-pages-check

# Verify structure
ls -la
ls -la docs/
ls -la docs/quiz/
ls -la docs/hugo-templates/
ls -la docs/web-terminal/
ls -la docs/info-tech-cli/

# Count files
find . -type f -name "*.html" | wc -l
find . -type f -name "*.css" | wc -l
find . -type f -name "*.js" | wc -l
```

**Expected Structure**:
```
/
├── index.html (corporate)
├── about/
├── products/
├── open-source/
├── blog/ (if exists)
├── assets/
└── docs/
    ├── index.html (hub)
    ├── quiz/
    ├── hugo-templates/
    ├── web-terminal/
    └── info-tech-cli/
```

---

## 🎯 Deliverables

- ✅ Corporate workflow E2E test report
- ✅ Documentation workflow E2E test report
- ✅ Sequential execution test report
- ✅ Content validation report
- ✅ Deployment completeness verification
- ✅ Screenshots of all tested pages
- ✅ Workflow execution logs

---

## ✅ Verification Criteria

- [ ] Corporate workflow E2E test passes
- [ ] Documentation workflow E2E test passes
- [ ] Sequential execution works both ways
- [ ] All URLs return 200 status
- [ ] Content complete and correct
- [ ] No 404 errors found
- [ ] All assets loading properly
- [ ] Build times within targets

---

## 📝 Notes

- Capture screenshots at each verification step
- Save workflow logs for analysis
- Document any warnings or anomalies
- Note performance metrics for Stage 5
- If any test fails, document details and create GitHub issue

---

**Created**: 2025-10-27
**Status**: Ready to execute after Stage 1
**Next**: Stage 3 - Integration & Independence Testing
