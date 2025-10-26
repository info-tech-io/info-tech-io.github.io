# Stage 1: Workflow YAML Creation

**Child**: #4 - Documentation Federation Workflow
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Ready to implement
**Estimated Duration**: 1.5 days

---

## 🎯 Stage Objective

Create GitHub Actions workflow file (`.github/workflows/deploy-docs-federation.yml`) for parallel multi-product documentation deployment using Download-Merge-Deploy pattern.

---

## 📋 Tasks

### Task 1: Create Workflow File Structure

Create `.github/workflows/deploy-docs-federation.yml` with metadata:

```yaml
name: Deploy InfoTech.io Documentation Federation

on:
  repository_dispatch:
    types:
      - quiz-docs-updated
      - hugo-templates-docs-updated
      - web-terminal-docs-updated
      - cli-docs-updated
  workflow_dispatch:
    inputs:
      product:
        description: 'Build specific product (or "all")'
        required: false
        default: 'all'
      debug:
        description: 'Enable debug mode'
        type: boolean
        default: false

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages-docs"
  cancel-in-progress: false
```

---

### Task 2: Download Current Pages State

Implement state download step:

```yaml
jobs:
  deploy-docs:
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
        continue-on-error: true

      - name: Validate Current State
        run: |
          echo "📦 Checking current site state..."

          if [ -d "current-site" ]; then
            echo "✅ Current site downloaded"
            echo "📊 Current site size: $(du -sh current-site | cut -f1)"

            # Check corporate site exists
            if [ -f "current-site/index.html" ]; then
              echo "✅ Corporate site found"
            else
              echo "⚠️  Corporate site missing - may be first deployment"
            fi

            # Check existing docs
            if [ -d "current-site/docs" ]; then
              echo "📚 Existing docs: $(find current-site/docs -type d -maxdepth 1 | wc -l) products"
            fi
          else
            echo "⚠️  No existing site found (fresh deployment)"
            mkdir -p current-site
          fi
```

---

### Task 3: Setup Build Environment

Clone required repositories:

```yaml
      - name: Checkout Hub Repository (for configs)
        uses: actions/checkout@v4
        with:
          path: hub-repo

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: '0.148.0'
          extended: true

      - name: Clone Hugo Templates Framework
        uses: actions/checkout@v4
        with:
          repository: info-tech-io/hugo-templates
          token: ${{ secrets.PAT_TOKEN }}
          path: hugo-templates
          submodules: recursive
          ref: main

      - name: Prepare Hugo Templates
        run: |
          echo "🔧 Preparing Hugo Templates framework..."
          cd hugo-templates
          git submodule update --init --recursive
          npm install || echo "⚠️  npm install failed, continuing..."
          chmod +x scripts/build.sh scripts/federated-build.sh
          cd ..
          echo "✅ Hugo Templates ready"
```

---

### Task 4: Clone Product Documentation Repositories

Parallel clone of all product repos:

```yaml
      - name: Clone Product Documentation Repositories
        run: |
          echo "📥 Cloning all product documentation repositories..."

          # Create products directory
          mkdir -p products

          # Clone in parallel using background processes
          (
            echo "Cloning quiz..."
            git clone https://github.com/info-tech-io/quiz.git products/quiz &

            echo "Cloning hugo-templates..."
            git clone https://github.com/info-tech-io/hugo-templates.git products/hugo-templates-repo &

            echo "Cloning web-terminal..."
            git clone https://github.com/info-tech-io/web-terminal.git products/web-terminal &

            echo "Cloning info-tech-cli..."
            git clone https://github.com/info-tech-io/info-tech-cli.git products/info-tech-cli &

            # Wait for all clones to complete
            wait
          )

          echo "✅ All product repositories cloned"

          # Verify all clones succeeded
          for product in quiz hugo-templates-repo web-terminal info-tech-cli; do
            if [ -d "products/$product" ]; then
              echo "  ✅ $product: $(du -sh products/$product | cut -f1)"
            else
              echo "  ❌ $product: FAILED"
              exit 1
            fi
          done
```

---

### Task 5: Build All Product Documentation in Parallel

Use federated-build.sh for parallel builds:

```yaml
      - name: Build All Product Documentation (Parallel)
        run: |
          echo "🏗️ Building all product documentation in parallel..."

          cd hugo-templates

          # Use federated-build.sh with documentation-modules.json
          if [ "${{ github.event.inputs.debug }}" = "true" ]; then
            ./scripts/federated-build.sh \
              --config=../hub-repo/configs/documentation-modules.json \
              --output=../docs-build \
              --verbose \
              --debug
          else
            ./scripts/federated-build.sh \
              --config=../hub-repo/configs/documentation-modules.json \
              --output=../docs-build \
              --verbose
          fi

          cd ..
          echo "✅ All documentation built"

      - name: Validate Build Output
        run: |
          echo "🔍 Validating documentation builds..."

          products=("quiz" "hugo-templates" "web-terminal" "info-tech-cli")

          for product in "${products[@]}"; do
            if [ -d "docs-build/docs/$product" ]; then
              html_count=$(find "docs-build/docs/$product" -name '*.html' | wc -l)
              echo "  ✅ $product: $html_count HTML files"

              # Check for index.html
              if [ ! -f "docs-build/docs/$product/index.html" ]; then
                echo "  ⚠️  Warning: $product missing index.html"
              fi
            else
              echo "  ❌ $product: Build output missing"
              exit 1
            fi
          done

          echo "✅ All documentation validated"
```

---

### Task 6: Create Documentation Hub

Generate unified navigation:

```yaml
      - name: Create Documentation Hub
        run: |
          echo "🏠 Creating documentation hub..."

          # This will be expanded in Stage 3
          # For now, create placeholder
          mkdir -p docs-build/docs

          cat > docs-build/docs/index.html <<'EOF'
          <!DOCTYPE html>
          <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Documentation Hub - InfoTech.io</title>
            </head>
            <body>
              <h1>📚 InfoTech.io Documentation</h1>
              <nav>
                <ul>
                  <li><a href="/docs/quiz/">Quiz Engine</a></li>
                  <li><a href="/docs/hugo-templates/">Hugo Templates</a></li>
                  <li><a href="/docs/web-terminal/">Web Terminal</a></li>
                  <li><a href="/docs/info-tech-cli/">InfoTech CLI</a></li>
                </ul>
              </nav>
              <p><a href="/">← Back to Main Site</a></p>
            </body>
          </html>
          EOF

          echo "✅ Documentation hub created"
```

---

### Task 7: Selective Merge (Preserve Corporate Site)

Merge documentation while preserving root:

```yaml
      - name: Merge Documentation (Preserve Corporate Site)
        run: |
          echo "🔄 Merging documentation, preserving corporate site..."

          # Backup corporate root if exists
          if [ -d "current-site" ] && [ -f "current-site/index.html" ]; then
            echo "💾 Corporate site exists, will be preserved"
          fi

          # Create /docs/ directory in current site
          mkdir -p current-site/docs

          # Sync only /docs/ from build output
          echo "📋 Syncing documentation to /docs/..."
          rsync -av --delete docs-build/docs/ current-site/docs/

          echo "✅ Merge complete"

      - name: Verify Merge Result
        run: |
          echo "📊 Final site structure verification:"
          echo ""
          echo "=== Corporate site (root) ==="
          if [ -f "current-site/index.html" ]; then
            echo "✅ Corporate index.html preserved"
          else
            echo "⚠️  Corporate index.html missing"
          fi

          echo ""
          echo "=== Documentation (/docs/) ==="
          products=("quiz" "hugo-templates" "web-terminal" "info-tech-cli")
          for product in "${products[@]}"; do
            if [ -d "current-site/docs/$product" ]; then
              files=$(find "current-site/docs/$product" -type f | wc -l)
              echo "  ✅ $product: $files files"
            else
              echo "  ❌ $product: Missing"
            fi
          done

          echo ""
          echo "=== Documentation Hub ==="
          if [ -f "current-site/docs/index.html" ]; then
            echo "✅ Hub index.html present"
          else
            echo "❌ Hub index.html missing"
          fi

          echo ""
          echo "📦 Total site size: $(du -sh current-site | cut -f1)"
```

---

### Task 8: Deploy to GitHub Pages

Upload and deploy:

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
          echo "✅ Documentation federation deployed successfully!"
          echo "🌐 URL: ${{ steps.deployment.outputs.page_url }}"
          echo ""
          echo "📋 Deployment Summary:"
          echo "  - Corporate site: Preserved ✅"
          echo "  - Documentation: Updated ✅"
          echo "  - Products deployed: quiz, hugo-templates, web-terminal, info-tech-cli"
          echo "  - Deployment mode: Incremental (docs only)"
```

---

### Task 9: Error Handling

Add error handling:

```yaml
      - name: Cleanup on Failure
        if: failure()
        run: |
          echo "❌ Workflow failed!"
          echo "🧹 Cleaning up temporary files..."
          rm -rf docs-build current-site hugo-templates products hub-repo
          echo "✅ Cleanup complete"

      - name: Notify on Failure
        if: failure()
        run: |
          echo "::error::Documentation federation deployment failed. Check logs for details."
          echo "::error::Failed job: ${{ github.job }}"
```

---

## 🎯 Deliverable

**File**: `.github/workflows/deploy-docs-federation.yml`
**Size**: ~300-350 lines
**Functionality**: Complete multi-product documentation federation deployment

---

## ✅ Verification Criteria

- [ ] Workflow file created and syntactically valid
- [ ] All steps defined with proper error handling
- [ ] Parallel build logic implemented
- [ ] Corporate site preservation logic in place
- [ ] Documentation hub creation included
- [ ] Manual trigger works (`workflow_dispatch`)
- [ ] Repository dispatch configured for all products

---

## 🧪 Testing Plan

1. **Syntax Check**:
   ```bash
   gh workflow view deploy-docs-federation.yml
   ```

2. **Manual Trigger Test**:
   - Go to Actions tab on GitHub
   - Find "Deploy InfoTech.io Documentation Federation"
   - Click "Run workflow" with product="all"
   - Monitor execution

3. **Verify Results**:
   - Corporate site unchanged
   - All product docs deployed to `/docs/{product}/`
   - Documentation hub accessible at `/docs/`
   - CSS styling works in all subdirectories

---

## 📝 Notes

- Based on Child #3 workflow pattern
- Uses federated-build.sh for parallel builds
- Preserves corporate site during docs updates
- Supports selective product builds via input parameter

---

**Created**: 2025-10-26
**Status**: Ready to implement
**Next**: Create documentation-modules.json configuration
