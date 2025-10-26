# Stage 1: Workflow YAML Creation

**Child**: #3 - Corporate Site Incremental Workflow
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Ready to implement
**Estimated Duration**: 1 day

---

## 🎯 Stage Objective

Create complete GitHub Actions workflow file for incremental corporate site deployment with Download-Merge-Deploy pattern.

---

## 📋 Detailed Steps

### Step 1.1: Create Workflow File Structure
**Duration**: 30 minutes

**Actions**:
1. Create file: `.github/workflows/deploy-corporate-incremental.yml`
2. Add workflow metadata:
   ```yaml
   name: Deploy InfoTech.io Corporate Site (Incremental)
   ```
3. Define triggers:
   ```yaml
   on:
     repository_dispatch:
       types: [corporate-site-updated]
     workflow_dispatch:  # For manual testing
   ```
4. Set permissions:
   ```yaml
   permissions:
     contents: read
     pages: write
     id-token: write
   ```

**Verification**:
- [ ] File created in correct location
- [ ] Workflow name descriptive
- [ ] Both triggers defined
- [ ] Permissions minimal and correct

---

### Step 1.2: Implement Download Current State
**Duration**: 1 hour

**Actions**:
1. Add checkout step for current Pages:
   ```yaml
   - name: Download Current GitHub Pages
     uses: actions/checkout@v4
     with:
       ref: gh-pages  # or latest deployment
       path: current-site
   ```
2. Alternative: Use GitHub API to download deployment artifact
3. Add validation step:
   ```yaml
   - name: Validate Current State
     run: |
       echo "Current site size: $(du -sh current-site)"
       echo "Docs directory: $(ls -la current-site/docs 2>/dev/null || echo 'Does not exist')"
   ```

**Verification**:
- [ ] Current Pages state downloaded successfully
- [ ] Download includes /docs/ if exists
- [ ] Validation step shows meaningful output

---

### Step 1.3: Implement Repository Cloning
**Duration**: 30 minutes

**Actions**:
1. Clone hugo-templates with submodules:
   ```yaml
   - name: Clone Hugo Templates (Epic #15)
     uses: actions/checkout@v4
     with:
       repository: info-tech-io/hugo-templates
       path: hugo-templates
       submodules: recursive
   ```
2. Clone corporate content:
   ```yaml
   - name: Clone Corporate Content
     uses: actions/checkout@v4
     with:
       repository: info-tech-io/info-tech
       path: info-tech
       ref: main
   ```

**Verification**:
- [ ] Both repositories cloned
- [ ] Submodules initialized in hugo-templates
- [ ] Correct branches checked out

---

### Step 1.4: Implement Federated Build
**Duration**: 1 hour

**Actions**:
1. Add build step:
   ```yaml
   - name: Build Corporate Site with Federated System
     run: |
       cd hugo-templates
       ./scripts/federated-build.sh \
         --config=../configs/corporate-modules.json \
         --output=../corporate-build \
         --verbose
   ```
2. Add build validation:
   ```yaml
   - name: Validate Build Output
     run: |
       if [ ! -f "corporate-build/index.html" ]; then
         echo "❌ Build failed: No index.html"
         exit 1
       fi
       echo "✅ Build successful: $(find corporate-build -name '*.html' | wc -l) HTML files"
   ```

**Verification**:
- [ ] federated-build.sh executes successfully
- [ ] Corporate site built to corporate-build/
- [ ] Validation passes

---

### Step 1.5: Implement Selective Merge
**Duration**: 1.5 hours

**Actions**:
1. Add merge step with preservation:
   ```yaml
   - name: Merge Corporate Content (Preserve Docs)
     run: |
       echo "📦 Merging corporate site, preserving /docs/"

       # Merge corporate files, excluding docs/
       rsync -av --exclude='docs/' corporate-build/ current-site/

       # Ensure docs directory exists (even if empty)
       mkdir -p current-site/docs

       # Create fallback docs index if missing
       if [ ! -f "current-site/docs/index.html" ]; then
         cat > current-site/docs/index.html <<'EOF'
       <!DOCTYPE html>
       <html>
         <head><title>Documentation Hub</title></head>
         <body>
           <h1>Documentation Hub</h1>
           <p>Documentation will be available here soon.</p>
         </body>
       </html>
       EOF
       fi

       echo "✅ Merge complete"
   ```
2. Add merge verification:
   ```yaml
   - name: Verify Merge Result
     run: |
       echo "Corporate site files:"
       ls -la current-site/ | head -20

       echo "Docs directory:"
       ls -la current-site/docs/ || echo "Docs empty (expected)"

       echo "Total site size: $(du -sh current-site)"
   ```

**Verification**:
- [ ] Corporate files merged to current-site/
- [ ] /docs/ directory preserved (if existed)
- [ ] /docs/ directory exists (created if missing)
- [ ] Fallback docs index created if needed

---

### Step 1.6: Implement Deployment
**Duration**: 1 hour

**Actions**:
1. Add Pages artifact upload:
   ```yaml
   - name: Upload Pages Artifact
     uses: actions/upload-pages-artifact@v3
     with:
       path: current-site
   ```
2. Add deployment step:
   ```yaml
   - name: Deploy to GitHub Pages
     id: deployment
     uses: actions/deploy-pages@v4
   ```
3. Add deployment verification:
   ```yaml
   - name: Verify Deployment
     run: |
       echo "Deployment URL: ${{ steps.deployment.outputs.page_url }}"
       echo "Deployment successful!"
   ```

**Verification**:
- [ ] Artifact uploaded successfully
- [ ] Deployment completes
- [ ] Deployment URL returned

---

### Step 1.7: Add Error Handling
**Duration**: 1 hour

**Actions**:
1. Add error handling to critical steps:
   ```yaml
   - name: Build Corporate Site
     id: build
     continue-on-error: false
     run: |
       # Build commands
   ```
2. Add failure notification:
   ```yaml
   - name: Notify on Failure
     if: failure()
     run: |
       echo "❌ Workflow failed at step: ${{ github.job }}"
       echo "Review logs for details"
   ```
3. Add success notification:
   ```yaml
   - name: Report Success
     if: success()
     run: |
       echo "✅ Corporate site deployed successfully"
       echo "URL: https://info-tech-io.github.io"
   ```

**Verification**:
- [ ] Failures stop workflow immediately
- [ ] Failure notifications clear
- [ ] Success confirmation displayed

---

### Step 1.8: Testing & Validation
**Duration**: 1.5 hours

**Actions**:
1. **Syntax Validation**:
   ```bash
   # Use yamllint or GitHub CLI
   gh workflow view deploy-corporate-incremental.yml
   ```
2. **Dry-Run Test**:
   - Trigger workflow manually with `workflow_dispatch`
   - Monitor execution
   - Verify all steps execute
3. **Error Injection Test**:
   - Introduce deliberate error
   - Verify workflow fails gracefully
   - Verify rollback/no partial deployment

**Verification**:
- [ ] YAML syntax valid
- [ ] Workflow executes successfully
- [ ] All steps complete
- [ ] Error handling works

---

## 🎯 Success Criteria

- [ ] Workflow file created and valid
- [ ] All 8 steps implemented
- [ ] Download-Merge-Deploy pattern working
- [ ] /docs/ preservation verified
- [ ] Error handling comprehensive
- [ ] Manual test successful

---

## 📊 Deliverables

1. **File**: `.github/workflows/deploy-corporate-incremental.yml`
2. **Size**: ~150 lines YAML
3. **Functionality**: Complete incremental corporate deployment

---

## 🔗 Related Files

- `configs/corporate-modules.json` (created in Stage 2)
- `hugo-templates/scripts/federated-build.sh` (from Epic #15)

---

## 📝 Notes

- Start with manual `workflow_dispatch` for testing
- Add `repository_dispatch` trigger after validation
- Keep workflow simple and readable
- Add generous logging for debugging

---

**Created**: 2025-10-26
**Status**: Ready to implement
**Next**: Begin implementation
