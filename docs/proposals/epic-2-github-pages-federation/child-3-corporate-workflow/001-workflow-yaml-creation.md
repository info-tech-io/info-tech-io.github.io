# Stage 1: Workflow YAML Creation

**Child**: #3 - Corporate Site Incremental Workflow
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Ready to implement
**Estimated Duration**: 1 day

---

## 🎯 Stage Objective

Create complete GitHub Actions workflow file (`.github/workflows/deploy-corporate-incremental.yml`) for incremental corporate site deployment using Download-Merge-Deploy pattern.

---

## 📋 Tasks

### Task 1: Create Workflow File
Create `.github/workflows/deploy-corporate-incremental.yml` with basic structure:

**Workflow Metadata**:
```yaml
name: Deploy InfoTech.io Corporate Site (Incremental)

on:
  repository_dispatch:
    types: [corporate-site-updated]
  workflow_dispatch:  # Manual trigger for testing

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false
```

---

### Task 2: Implement Download Current State
Add step to download existing GitHub Pages deployment:

```yaml
jobs:
  deploy-corporate:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    steps:
      - name: Download Current GitHub Pages State
        uses: actions/checkout@v4
        with:
          ref: gh-pages
          path: current-site

      - name: Validate Current State
        run: |
          echo "📦 Current site size: $(du -sh current-site)"
          if [ -d "current-site/docs" ]; then
            echo "✅ Docs directory exists: $(du -sh current-site/docs)"
          else
            echo "⚠️  Docs directory does not exist (will be created)"
          fi
```

---

### Task 3: Clone Required Repositories
Clone hugo-templates (with Epic #15) and info-tech content:

```yaml
      - name: Clone Hugo Templates Framework
        uses: actions/checkout@v4
        with:
          repository: info-tech-io/hugo-templates
          path: hugo-templates
          submodules: recursive
          ref: main

      - name: Clone Corporate Content
        uses: actions/checkout@v4
        with:
          repository: info-tech-io/info-tech
          path: info-tech
          ref: main
```

---

### Task 4: Build Corporate Site
Execute federated build using Epic #15 system:

```yaml
      - name: Build Corporate Site (Federated Build)
        run: |
          cd hugo-templates
          ./scripts/federated-build.sh \
            --config=../configs/corporate-modules.json \
            --output=../corporate-build \
            --verbose

      - name: Validate Build Output
        run: |
          if [ ! -f "corporate-build/index.html" ]; then
            echo "❌ Build failed: No index.html found"
            exit 1
          fi

          html_count=$(find corporate-build -name '*.html' | wc -l)
          echo "✅ Build successful: $html_count HTML files generated"

          if [ $html_count -lt 5 ]; then
            echo "⚠️  Warning: Very few HTML files generated"
          fi
```

---

### Task 5: Selective Merge with Preservation
Merge corporate content while preserving `/docs/`:

```yaml
      - name: Merge Corporate Content (Preserve /docs/)
        run: |
          echo "📦 Merging corporate site to root, preserving /docs/"

          # Merge corporate files, excluding docs/
          rsync -av --exclude='docs/' corporate-build/ current-site/

          # Ensure docs directory exists (even if empty)
          mkdir -p current-site/docs

          # Create fallback docs index if missing
          if [ ! -f "current-site/docs/index.html" ]; then
            cat > current-site/docs/index.html <<'EOF'
          <!DOCTYPE html>
          <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Documentation Hub - InfoTech.io</title>
            </head>
            <body>
              <h1>Documentation Hub</h1>
              <p>Product documentation will be available here soon.</p>
              <p><a href="/">← Back to Main Site</a></p>
            </body>
          </html>
          EOF
            echo "✅ Created fallback docs/index.html"
          fi

          echo "✅ Merge complete"

      - name: Verify Merge Result
        run: |
          echo "📊 Final site structure:"
          echo "Root files:"
          ls -lah current-site/ | head -20

          echo ""
          echo "Docs directory:"
          ls -lah current-site/docs/ 2>/dev/null || echo "(empty or minimal)"

          echo ""
          echo "Total site size: $(du -sh current-site)"
```

---

### Task 6: Deploy to GitHub Pages
Upload and deploy merged result:

```yaml
      - name: Upload Pages Artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: current-site

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4

      - name: Deployment Success
        run: |
          echo "✅ Corporate site deployed successfully!"
          echo "🌐 URL: ${{ steps.deployment.outputs.page_url }}"
```

---

### Task 7: Add Error Handling
Ensure failures are handled gracefully:

```yaml
      - name: Cleanup on Failure
        if: failure()
        run: |
          echo "❌ Workflow failed!"
          echo "Cleaning up temporary files..."
          rm -rf corporate-build current-site hugo-templates info-tech

      - name: Notify on Failure
        if: failure()
        run: |
          echo "::error::Corporate site deployment failed. Check logs for details."
          echo "Failed step: ${{ github.job }}"
```

---

## 🎯 Deliverable

**File**: `.github/workflows/deploy-corporate-incremental.yml`
**Size**: ~150-200 lines
**Functionality**: Complete incremental corporate deployment

---

## ✅ Verification Criteria

- [ ] Workflow file created
- [ ] YAML syntax valid (check with `yamllint` or GitHub CLI)
- [ ] All steps defined
- [ ] Download-Merge-Deploy pattern implemented
- [ ] `/docs/` preservation logic in place
- [ ] Error handling comprehensive
- [ ] Manual trigger works (`workflow_dispatch`)

---

## 🧪 Testing Plan

1. **Syntax Check**:
   ```bash
   gh workflow view deploy-corporate-incremental.yml
   ```

2. **Manual Trigger Test**:
   - Go to Actions tab on GitHub
   - Find "Deploy InfoTech.io Corporate Site (Incremental)"
   - Click "Run workflow"
   - Monitor execution

3. **Verify Results**:
   - Check workflow completes successfully
   - Visit https://info-tech-io.github.io
   - Verify corporate site updated
   - Verify `/docs/` preserved (if existed)

---

## 📝 Notes

- Start testing with `workflow_dispatch` (manual trigger)
- Add `repository_dispatch` after validation
- Keep logging verbose for initial debugging
- Monitor first few runs closely

---

**Created**: 2025-10-26
**Status**: Ready to implement
**Next**: Create workflow file and test
