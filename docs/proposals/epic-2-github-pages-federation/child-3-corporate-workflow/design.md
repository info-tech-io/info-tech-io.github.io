# Child #3: Corporate Site Incremental Workflow

**Child Issue**: https://github.com/info-tech-io/info-tech-io.github.io/issues/5
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Ready to implement
**Estimated Duration**: ~3 days

---

## 🎯 Child Objective

Create GitHub Actions workflow for incremental deployment of corporate site that preserves existing documentation federation in `/docs/` directory.

---

## 🔍 Scope

### In Scope
1. **Workflow Creation**: Create `.github/workflows/deploy-corporate-incremental.yml`
2. **Configuration**: Create `configs/corporate-modules.json` for federated-build.sh
3. **Repository Dispatch**: Setup trigger from `info-tech` repository
4. **Incremental Logic**: Implement Download-Merge-Deploy pattern for corporate content
5. **Testing**: Validate incremental deployment preserves `/docs/`

### Out of Scope
- Documentation federation (handled by Child #4)
- Multi-product builds (handled by Child #4)
- E2E testing (handled by Child #5)
- Production monitoring (handled by Child #6)

---

## 🏗️ Architecture

### Workflow Pattern: Download-Merge-Deploy

```
┌─────────────────────────────────────────────────────────┐
│ 1. Download Current GitHub Pages State                  │
│    - Fetch latest deployment                            │
│    - Extract to current-site/                           │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 2. Build Corporate Site                                 │
│    - Clone info-tech repository                         │
│    - Clone hugo-templates (with Epic #15)               │
│    - Run federated-build.sh with corporate config       │
│    - Output to corporate-build/                         │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 3. Selective Merge                                      │
│    - rsync corporate-build/ → current-site/             │
│    - EXCLUDE: docs/ (preserve documentation)            │
│    - Ensure docs/ directory exists                      │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 4. Deploy to GitHub Pages                               │
│    - Upload current-site/ as Pages artifact             │
│    - Atomic deployment (all-or-nothing)                 │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 Stages Breakdown

### Stage 1: Workflow YAML Creation
**Goal**: Create complete GitHub Actions workflow file

**Tasks**:
1. Create `.github/workflows/deploy-corporate-incremental.yml`
2. Define workflow triggers:
   - `repository_dispatch` event type: `corporate-site-updated`
   - `workflow_dispatch` for manual testing
3. Define job steps:
   - Download current Pages state
   - Clone repositories (info-tech, hugo-templates)
   - Build corporate site
   - Merge with preservation logic
   - Deploy to Pages
4. Add error handling and logging
5. Configure permissions and environment

**Deliverable**: Working workflow YAML file

**Verification**:
- Workflow syntax valid
- All required permissions defined
- Error handling comprehensive

---

### Stage 2: Configuration Files
**Goal**: Create federated build configuration for corporate site

**Tasks**:
1. Create `configs/corporate-modules.json`:
   ```json
   {
     "federation": {
       "name": "InfoTech.io Corporate Site",
       "baseURL": "https://info-tech-io.github.io",
       "strategy": "preserve-base-site"
     },
     "modules": [
       {
         "name": "corporate-site",
         "source": {
           "repository": "https://github.com/info-tech-io/info-tech",
           "path": "docs",
           "branch": "main"
         },
         "module_json": "module.json",
         "destination": "/",
         "css_path_prefix": ""
       }
     ]
   }
   ```
2. Validate configuration against JSON Schema
3. Test with `federated-build.sh --dry-run`

**Deliverable**: Validated configuration file

**Verification**:
- JSON Schema validation passes
- Dry-run succeeds
- Configuration matches architecture design

---

### Stage 3: Repository Dispatch Integration
**Goal**: Setup trigger from info-tech repository

**Tasks**:
1. Create/update `.github/workflows/notify-hub.yml` in `info-tech` repo
2. Configure dispatch event on docs changes:
   ```yaml
   on:
     push:
       branches: [main]
       paths:
         - 'docs/**'

   jobs:
     notify:
       runs-on: ubuntu-latest
       steps:
         - name: Trigger GitHub Pages Update
           run: |
             curl -X POST \
               -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
               -H "Accept: application/vnd.github.v3+json" \
               https://api.github.com/repos/info-tech-io/info-tech-io.github.io/dispatches \
               -d '{"event_type":"corporate-site-updated"}'
   ```
3. Test dispatch mechanism
4. Verify workflow triggers

**Deliverable**: Working dispatch integration

**Verification**:
- Push to info-tech/docs triggers workflow
- Dispatch event received by hub
- Workflow executes correctly

---

### Stage 4: Testing & Validation
**Goal**: Validate incremental deployment preserves documentation

**Tasks**:
1. **Test Scenario 1**: Fresh deployment
   - Deploy corporate site to empty Pages
   - Verify structure correctness

2. **Test Scenario 2**: Incremental update (preservation test)
   - Create mock `/docs/` content
   - Deploy corporate site update
   - Verify `/docs/` preserved
   - Verify corporate content updated

3. **Test Scenario 3**: Multiple updates
   - Deploy corporate update 1
   - Deploy corporate update 2
   - Verify cumulative correctness

4. **Test Scenario 4**: Error handling
   - Simulate build failure
   - Verify rollback/no partial deployment

**Deliverable**: Test report with evidence

**Verification**:
- All 4 scenarios pass
- `/docs/` preservation confirmed
- No content loss
- Atomic deployment verified

---

## 🎯 Success Criteria

- [ ] Workflow YAML created and syntactically valid
- [ ] `corporate-modules.json` configuration validated
- [ ] Repository dispatch working from info-tech repo
- [ ] Corporate site deploys to root (/)
- [ ] `/docs/` directory preserved during updates
- [ ] Atomic deployment (no partial states)
- [ ] Build time < 3 minutes
- [ ] All tests passing

---

## 📊 Technical Specifications

### Workflow File Structure

```yaml
name: Deploy Corporate Site (Incremental)

on:
  repository_dispatch:
    types: [corporate-site-updated]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  deploy-corporate:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    steps:
      # Stage 1: Download current state
      - name: Download Current GitHub Pages
        uses: actions/checkout@v4
        with:
          ref: gh-pages
          path: current-site

      # Stage 2: Clone repositories
      - name: Clone Hugo Templates
        uses: actions/checkout@v4
        with:
          repository: info-tech-io/hugo-templates
          path: hugo-templates
          submodules: recursive

      - name: Clone Corporate Content
        uses: actions/checkout@v4
        with:
          repository: info-tech-io/info-tech
          path: info-tech

      # Stage 3: Build corporate site
      - name: Build Corporate Site
        run: |
          cd hugo-templates
          ./scripts/federated-build.sh \
            --config=../configs/corporate-modules.json \
            --output=../corporate-build \
            --verbose

      # Stage 4: Merge with preservation
      - name: Merge Corporate Content
        run: |
          rsync -av --exclude='docs/' corporate-build/ current-site/
          mkdir -p current-site/docs

      # Stage 5: Deploy
      - name: Upload Pages Artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: current-site

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### Key Parameters

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `strategy` | `preserve-base-site` | Preserve existing `/docs/` |
| `destination` | `/` | Deploy to site root |
| `css_path_prefix` | `""` (empty) | Root deployment, no prefix |
| `baseURL` | `https://info-tech-io.github.io` | Production URL |

---

## 🔗 Dependencies

**Prerequisites**:
- ✅ Child #1 (Investigation) - Complete
- ✅ Child #2 (Epic #15) - Complete
  - `federated-build.sh` available
  - `preserve-base-site` strategy implemented
  - Configuration validation working

**Blocks**:
- Child #4 (Docs Federation) - Needs working corporate workflow as template
- Child #5 (Testing) - Needs workflow to test

---

## 🧪 Testing Plan

### Unit Tests
- Configuration validation
- Workflow syntax checking
- Repository dispatch payload

### Integration Tests
- End-to-end workflow execution
- Download → Build → Merge → Deploy cycle
- Preservation of `/docs/` directory

### Manual Tests
- Trigger from info-tech repository
- Verify Pages deployment
- Check corporate site rendering
- Verify `/docs/` untouched

---

## 📝 Notes

- Use `rsync --exclude='docs/'` for safe merging
- Always create `/docs/` directory even if empty
- Monitor build times (target: < 3 minutes)
- Test with dry-run first
- Keep workflow simple for maintainability

---

## 📁 File Locations

**This Repository** (`info-tech-io.github.io`):
- `.github/workflows/deploy-corporate-incremental.yml`
- `configs/corporate-modules.json`
- `docs/proposals/epic-2-github-pages-federation/child-3-corporate-workflow/`

**Info-Tech Repository**:
- `.github/workflows/notify-hub.yml`

---

**Created**: 2025-10-26
**Status**: Design complete, ready for implementation
**Document Version**: 1.0
