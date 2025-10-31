# Stage 2: Build Verification

**Objective**: Verify fixes work in local builds, GitHub Actions, and production
**Duration**: 0.5 days (4 hours)
**Dependencies**: Stage 1 complete (content fixes committed)

---

## Overview

Comprehensive verification that the content fixes resolve the build failures across all environments:
- Part 2.1: Local builds (all 4 modules)
- Part 2.2: GitHub Actions builds
- Part 2.3: Production deployment (including live documentation update test)

---

## Part 2.1: Local Build Verification

**Objective**: Verify all 4 modules build successfully locally

### Step 2.1.1: Clean test environment

**Action**: Remove any previous test artifacts

**Implementation**:
```bash
# Clean up previous tests
rm -rf /tmp/verify-* /tmp/build-*.log /tmp/test-*
```

### Step 2.1.2: Build all modules locally

**Action**: Build all 4 documentation modules in temporary directories

**Implementation**:
```bash
cd /root/info-tech-io/hugo-templates

# Test quiz (working baseline)
echo "=== Building quiz-docs ==="
./scripts/build.sh \
  --config /root/info-tech-io/quiz/docs/module.json \
  --output /tmp/verify-quiz \
  --content /root/info-tech-io/quiz/docs/content \
  --verbose 2>&1 | tee /tmp/build-quiz.log

# Test web-terminal (working baseline)
echo "=== Building web-terminal-docs ==="
./scripts/build.sh \
  --config /root/info-tech-io/web-terminal/docs/module.json \
  --output /tmp/verify-web-terminal \
  --content /root/info-tech-io/web-terminal/docs/content \
  --verbose 2>&1 | tee /tmp/build-web-terminal.log

# Test hugo-templates (FIXED)
echo "=== Building hugo-templates-docs ==="
./scripts/build.sh \
  --config /root/info-tech-io/hugo-templates/docs/module.json \
  --output /tmp/verify-hugo-templates \
  --content /root/info-tech-io/hugo-templates/docs/content \
  --verbose 2>&1 | tee /tmp/build-hugo-templates.log

# Test info-tech-cli (FIXED)
echo "=== Building info-tech-cli-docs ==="
./scripts/build.sh \
  --config /root/info-tech-io/info-tech-cli/docs/module.json \
  --output /tmp/verify-info-tech-cli \
  --content /root/info-tech-io/info-tech-cli/docs/content \
  --verbose 2>&1 | tee /tmp/build-info-tech-cli.log
```

### Step 2.1.3: Verify outputs

**Action**: Check that all modules produced HTML files correctly

**Implementation**:
```bash
# Verify critical files exist
for module in quiz web-terminal hugo-templates info-tech-cli; do
  echo "========================================="
  echo "Checking $module"
  echo "========================================="
  
  if [[ -f "/tmp/verify-$module/index.html" ]]; then
    SIZE=$(stat -c%s "/tmp/verify-$module/index.html")
    echo "✅ index.html: $SIZE bytes"
  else
    echo "❌ index.html: MISSING"
  fi
  
  if [[ -f "/tmp/verify-$module/404.html" ]]; then
    SIZE=$(stat -c%s "/tmp/verify-$module/404.html")
    echo "✅ 404.html: $SIZE bytes"
  else
    echo "❌ 404.html: MISSING"
  fi
  
  # Count HTML files
  HTML_COUNT=$(find "/tmp/verify-$module" -name "*.html" -type f | wc -l)
  echo "📄 Total HTML files: $HTML_COUNT"
  
  # Check for Hugo errors in logs
  if grep -i "error" "/tmp/build-$module.log" | grep -v "error_count" | grep -qv "Error: error"; then
    echo "⚠️  Errors found in build log:"
    grep -i "error" "/tmp/build-$module.log" | grep -v "error_count" | head -5
  else
    echo "✅ No errors in build log"
  fi
  
  echo ""
done
```

**Verification Criteria**:
- [ ] quiz: index.html exists (~44 KB), 404.html exists
- [ ] web-terminal: index.html exists (~40-50 KB), 404.html exists
- [ ] hugo-templates: index.html exists (~40-50 KB), 404.html exists ✅ (was missing before)
- [ ] info-tech-cli: index.html exists (~40-50 KB), 404.html exists ✅ (was missing before)
- [ ] All modules: No "shortcode not found" errors in any logs
- [ ] All modules: No Hugo build errors in any logs

---

## Part 2.2: GitHub Actions Build Verification

**Objective**: Verify federated build works in CI/CD environment

### Step 2.2.1: Trigger workflow manually

**Action**: Manually trigger deploy-github-pages.yml

**Implementation**:
```bash
cd /root/info-tech-io/info-tech-io.github.io

# Trigger workflow
gh workflow run deploy-github-pages.yml

# Wait a few seconds for workflow to start
sleep 5

# Monitor
gh run watch
```

**Verification**:
- [ ] Workflow triggered successfully
- [ ] Workflow starts running (not failed immediately)

### Step 2.2.2: Monitor execution

**Action**: Watch workflow logs for build success

**Implementation**:
```bash
# Get latest run ID
RUN_ID=$(gh run list --workflow=deploy-github-pages.yml --limit 1 --json databaseId --jq '.[0].databaseId')

echo "Monitoring run: $RUN_ID"

# View relevant logs
gh run view $RUN_ID --log | grep -E "Built|ERROR|WARN|hugo-templates|info-tech-cli|shortcode" | head -50
```

**Verification**:
- [ ] "✅ Built hugo-templates-docs in Xs" appears
- [ ] "✅ Built info-tech-cli-docs in Xs" appears
- [ ] "✅ Built quiz-docs in Xs" appears
- [ ] "✅ Built web-terminal-docs in Xs" appears
- [ ] No "shortcode not found" errors
- [ ] No "failed to extract shortcode" errors
- [ ] "Deploy to GitHub Pages" step succeeds
- [ ] Deployment marked as "success"

### Step 2.2.3: Download and inspect artifact

**Action**: Download artifact and verify structure matches local builds

**Implementation**:
```bash
cd /tmp
mkdir -p github-actions-verify
cd github-actions-verify

# Download artifact
gh run download $RUN_ID --name github-pages --repo info-tech-io/info-tech-io.github.io

# Extract
tar -xf artifact.tar

# Inspect structure
echo "========================================="
echo "Artifact Structure"
echo "========================================="
ls -lh docs/

echo ""
echo "========================================="
echo "Checking Critical Files"
echo "========================================="

# Check critical files for all modules
for module in quiz web-terminal hugo-templates info-tech-cli; do
  echo "--- $module ---"
  
  if [[ -f "docs/$module/index.html" ]]; then
    SIZE=$(stat -c%s "docs/$module/index.html")
    echo "✅ index.html: $SIZE bytes"
  else
    echo "❌ index.html: MISSING"
  fi
  
  if [[ -f "docs/$module/404.html" ]]; then
    SIZE=$(stat -c%s "docs/$module/404.html")
    echo "✅ 404.html: $SIZE bytes"
  else
    echo "❌ 404.html: MISSING (optional)"
  fi
  
  # Count HTML files
  HTML_COUNT=$(find "docs/$module" -name "*.html" -type f | wc -l)
  echo "📄 Total HTML files: $HTML_COUNT"
  
  echo ""
done
```

**Verification**:
- [ ] Artifact downloaded successfully
- [ ] docs/quiz/index.html exists
- [ ] docs/web-terminal/index.html exists
- [ ] docs/hugo-templates/index.html exists ✅ (NEW - was missing before)
- [ ] docs/info-tech-cli/index.html exists ✅ (NEW - was missing before)
- [ ] All index.html files > 30 KB (not empty)
- [ ] No source-only directories (content/, themes/)

### Step 2.2.4: Compare with local builds

**Action**: Ensure GitHub Actions produces similar output to local

**Implementation**:
```bash
echo "========================================="
echo "Comparing Local vs GitHub Actions"
echo "========================================="

for module in hugo-templates info-tech-cli; do
  echo "--- $module ---"
  
  # Compare file counts
  LOCAL_COUNT=$(find /tmp/verify-$module -name "*.html" 2>/dev/null | wc -l)
  CI_COUNT=$(find /tmp/github-actions-verify/docs/$module -name "*.html" 2>/dev/null | wc -l)
  
  echo "Local HTML files: $LOCAL_COUNT"
  echo "CI HTML files: $CI_COUNT"
  
  # Compare index.html sizes
  if [[ -f "/tmp/verify-$module/index.html" && -f "/tmp/github-actions-verify/docs/$module/index.html" ]]; then
    LOCAL_SIZE=$(stat -c%s "/tmp/verify-$module/index.html")
    CI_SIZE=$(stat -c%s "/tmp/github-actions-verify/docs/$module/index.html")
    
    echo "Local index.html: $LOCAL_SIZE bytes"
    echo "CI index.html: $CI_SIZE bytes"
    
    # Calculate difference percentage
    DIFF=$((LOCAL_SIZE - CI_SIZE))
    DIFF_ABS=${DIFF#-}
    DIFF_PCT=$((DIFF_ABS * 100 / LOCAL_SIZE))
    
    echo "Difference: $DIFF_PCT%"
  fi
  
  echo ""
done
```

**Verification**:
- [ ] File counts similar (±10%)
- [ ] File sizes similar (±20% acceptable due to timestamps/hashes)
- [ ] Both have index.html in root

---

## Part 2.3: Production Deployment Verification

**Objective**: Verify all sites accessible on GitHub Pages (FINAL SUCCESS CRITERIA)

### Step 2.3.1: Wait for deployment

**Action**: Wait for GitHub Pages to deploy artifact

**Implementation**:
```bash
echo "Waiting for GitHub Pages deployment (3 minutes)..."
echo "Deployment typically takes 2-3 minutes to propagate"
sleep 180

echo "Deployment window complete. Proceeding to verification..."
```

### Step 2.3.2: Test all documentation URLs

**Action**: Verify all 4 sites return 200 OK

**Implementation**:
```bash
echo "========================================="
echo "Testing Production URLs"
echo "========================================="

# Test all sites
for site in quiz web-terminal hugo-templates info-tech-cli; do
  echo ""
  echo "--- Testing $site ---"
  
  URL="https://info-tech-io.github.io/docs/$site/"
  
  # Get HTTP status
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
  
  if [[ "$STATUS" == "200" ]]; then
    echo "✅ Status: $STATUS"
  else
    echo "❌ Status: $STATUS (expected 200)"
  fi
  
  # Check content length
  CONTENT_LENGTH=$(curl -s "$URL" | wc -c)
  echo "📏 Content length: $CONTENT_LENGTH bytes"
  
  # Check for title
  TITLE=$(curl -s "$URL" | grep -oP '<title>\K[^<]+' 2>/dev/null || echo "No title found")
  echo "📄 Title: $TITLE"
  
  # Check for common HTML elements
  if curl -s "$URL" | grep -q "<nav\|<article\|<main"; then
    echo "✅ Main content structure present"
  else
    echo "⚠️  Main content structure not detected"
  fi
done

echo ""
echo "========================================="
```

**Verification (CRITICAL)**:
- [ ] quiz: 200 OK ✅
- [ ] web-terminal: 200 OK ✅
- [ ] hugo-templates: 200 OK ✅ (was 404 before)
- [ ] info-tech-cli: 200 OK ✅ (was 404 before)
- [ ] All sites have HTML content (> 10 KB)
- [ ] All sites have proper titles
- [ ] All sites have navigation/content structure

### Step 2.3.3: Visual verification

**Action**: Check that HTML content renders correctly (no errors in HTML)

**Implementation**:
```bash
echo "========================================="
echo "Content Quality Check"
echo "========================================="

for site in hugo-templates info-tech-cli; do
  echo ""
  echo "--- Checking $site content ---"
  
  URL="https://info-tech-io.github.io/docs/$site/"
  
  # Check for navigation
  if curl -s "$URL" | grep -q "<nav"; then
    echo "✅ Navigation present"
  else
    echo "⚠️  No navigation found"
  fi
  
  # Check for main content
  if curl -s "$URL" | grep -q "<article\|<main\|<div class=\"content\""; then
    echo "✅ Main content present"
  else
    echo "⚠️  No main content found"
  fi
  
  # Check for error messages
  if curl -s "$URL" | grep -qi "error\|not found\|404"; then
    echo "⚠️  Error messages detected in HTML"
  else
    echo "✅ No error messages in HTML"
  fi
  
  # Check for CSS
  if curl -s "$URL" | grep -q "\.css"; then
    echo "✅ CSS references present"
  else
    echo "⚠️  No CSS references found"
  fi
done

echo ""
```

**Verification**:
- [ ] hugo-templates has navigation and content
- [ ] info-tech-cli has navigation and content
- [ ] No error messages in HTML
- [ ] CSS loads correctly (no broken styling)
- [ ] Pages are not showing source code

### Step 2.3.4: Test live documentation update (NEW)

**Objective**: Verify that documentation updates trigger workflow and deploy successfully

**Action**: Make a minor test change to quiz docs, verify it triggers workflow and deploys

**Implementation**:
```bash
cd /root/info-tech-io/quiz

echo "========================================="
echo "Testing Live Documentation Update"
echo "========================================="

# Make a minor test change to _index.md
echo "" >> docs/content/_index.md
echo "<!-- Deployment test $(date -u +%Y-%m-%d-%H%M%S) - Issue #9 verification -->" >> docs/content/_index.md

echo "✅ Added test marker to quiz docs"

# Commit and push
git add docs/content/_index.md
git commit -m "test: add deployment test marker for Issue #9 verification

Minor change to verify repository_dispatch trigger and
GitHub Pages deployment work correctly.

Related: info-tech-io/info-tech-io.github.io#9"
git push origin main

echo "✅ Changes pushed to quiz repository"
echo ""
echo "Waiting for notify-hub workflow to trigger (10 seconds)..."
sleep 10

# Check if notify-hub workflow triggered
echo "Checking notify-hub workflow..."
gh run list --workflow=notify-hub.yml --limit 1 --repo info-tech-io/quiz

# Wait for hub workflow to trigger
echo ""
echo "Waiting for hub workflow to trigger (15 seconds)..."
sleep 15

# Check hub workflow
cd /root/info-tech-io/info-tech-io.github.io
echo "Checking deploy-github-pages workflow..."
LATEST_RUN=$(gh run list --workflow=deploy-github-pages.yml --limit 1 --json databaseId,event,status --jq '.[0]')

echo "Latest run: $LATEST_RUN"

# Monitor the run
echo ""
echo "Monitoring workflow execution..."
gh run watch --exit-status

# Wait for deployment
echo ""
echo "Waiting for GitHub Pages deployment (3 minutes)..."
sleep 180

# Verify the test marker appears in production
echo ""
echo "========================================="
echo "Verifying Test Marker in Production"
echo "========================================="

TEST_MARKER="Deployment test $(date -u +%Y-%m-%d)"
if curl -s "https://info-tech-io.github.io/docs/quiz/" | grep -q "Deployment test"; then
  echo "✅ Test marker found in production"
  echo "✅ Live documentation updates work correctly"
else
  echo "⚠️  Test marker not found (may need more time for CDN)"
  echo "⚠️  Re-check manually after 5 more minutes"
fi

echo ""
echo "========================================="
```

**Verification (Live Update Test)**:
- [ ] Commit pushed to quiz repository
- [ ] notify-hub.yml workflow triggered in quiz
- [ ] repository_dispatch event sent successfully
- [ ] deploy-github-pages.yml workflow triggered in info-tech-io.github.io
- [ ] Workflow completed successfully
- [ ] Test marker appears in production HTML
- [ ] No errors in workflow logs

---

## Final Success Criteria

**ALL must be true to proceed to Stage 3:**

### Local Builds (Part 2.1)
- [x] All 4 modules build successfully locally
- [x] All 4 modules produce index.html
- [x] No Hugo errors in any build logs
- [x] No "shortcode not found" errors

### GitHub Actions (Part 2.2)
- [x] Workflow completes successfully
- [x] All 4 modules in artifact have index.html
- [x] Artifact structure matches local builds
- [x] No Hugo errors in workflow logs

### Production (Part 2.3) - FINAL
- [x] quiz: https://info-tech-io.github.io/docs/quiz/ returns 200 OK
- [x] web-terminal: https://info-tech-io.github.io/docs/web-terminal/ returns 200 OK
- [x] hugo-templates: https://info-tech-io.github.io/docs/hugo-templates/ returns 200 OK ✅
- [x] info-tech-cli: https://info-tech-io.github.io/docs/info-tech-cli/ returns 200 OK ✅
- [x] All sites render HTML content correctly
- [x] Live documentation update triggers workflow successfully ✅
- [x] Live update deploys to production successfully ✅

---

## Cleanup

```bash
# Remove temporary directories
rm -rf /tmp/verify-*
rm -rf /tmp/build-*.log
rm -rf /tmp/github-actions-verify
rm -rf /tmp/test-*

echo "✅ Cleanup complete"
```

---

## Expected Results

### Before Fixes (Baseline)
```
Local builds:
  hugo-templates: Error (shortcode not found), no index.html
  info-tech-cli: Error (shortcode not found), no index.html

Production:
  hugo-templates: 404 Not Found
  info-tech-cli: 404 Not Found
```

### After Fixes (Target)
```
Local builds:
  hugo-templates: Success, index.html present (40-50 KB)
  info-tech-cli: Success, index.html present (40-50 KB)

GitHub Actions:
  All 4 modules: Success, HTML in artifact

Production:
  hugo-templates: 200 OK, HTML content
  info-tech-cli: 200 OK, HTML content
  Live updates: Work correctly
```

---

## Timeline

| Part | Duration | Cumulative |
|------|----------|------------|
| 2.1: Local verification | 1 hour | 1 hour |
| 2.2: GitHub Actions verification | 1 hour | 2 hours |
| 2.3: Production verification | 1.5 hours | 3.5 hours |
| 2.3.4: Live update test | 0.5 hours | 4 hours |

**Total Stage 2 Duration**: 4 hours (0.5 days)

---

**Stage Status**: ⏳ Ready After Stage 1
**Dependencies**: Stage 1 complete
**Blockers**: None
