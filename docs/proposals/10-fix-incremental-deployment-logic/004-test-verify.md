# Stage 4: Test & Verify Fix

**Objective**: Comprehensive testing 8A?@02;5=89 8 25@8D8:0F8O 2 production
**Duration**: 0.5 days (4 hours)
**Dependencies**: Stages 1, 2, 3 complete

---

## Overview

$8=0;L=0O stage 4;O ?@>25@:8 GB> 2A5 8A?@02;5=8O @01>B0NB :>@@5:B=>:
1. Manual deployment test (both components)
2. Incremental deployment tests (each component separately)
3. Production verification
4. Monitoring period

---

## Detailed Steps

### Step 4.1: Baseline - Full Deployment Test

**Action**: Trigger manual workflow A >1>8<8 :><?>=5=B0<8 4;O 2>AAB0=>2;5=8O known-good state

**Implementation**:
```bash
echo "=== STEP 4.1: Full Deployment Test ==="

# Trigger manual workflow
gh workflow run deploy-github-pages.yml \
  --field rebuild_corporate=true \
  --field rebuild_docs=true \
  --field debug=false

echo "ó Waiting for workflow to start..."
sleep 15

# Get run ID
RUN_ID=$(gh run list --workflow=deploy-github-pages.yml --limit 1 --json databaseId --jq '.[0].databaseId')
echo "=Ê Monitoring Run ID: $RUN_ID"

# Watch execution
gh run watch $RUN_ID

# Check logs for build plan
echo ""
echo "=== Build Plan from Logs ==="
gh run view $RUN_ID --log | grep -A5 "Build Plan:"

# Wait for GitHub Pages deployment
echo ""
echo "ó Waiting for GitHub Pages deployment (3 minutes)..."
sleep 180

# Verify production
echo ""
echo "=== Production Verification ==="
echo "Corporate site:"
curl -I https://info-tech-io.github.io/ 2>&1 | grep "HTTP"

echo ""
echo "Documentation sites:"
for site in quiz web-terminal hugo-templates info-tech-cli; do
  echo -n "  $site: "
  curl -I "https://info-tech-io.github.io/docs/$site/" 2>&1 | grep "HTTP"
done
```

**Verification**:
- [ ] Workflow triggered successfully
- [ ] Build plan shows: Corporate=true, Docs=true
- [ ] No errors in workflow logs
- [ ] Merge integrity check passed
- [ ] Deployment completed
- [ ] Corporate site returns 200 OK
- [ ] All 4 docs sites return 200 OK

**Success Criteria**:
-  Known-good state established
-  Both components deployed successfully
-  All production URLs return 200

**Expected Result**: Full deployment successful, all sites working.

---

### Step 4.2: Incremental Test - Documentation Only

**Action**: Update quiz docs 8 ?@>25@8BL GB> corporate  ?5@570?8AK205BAO

**Implementation**:
```bash
echo "=== STEP 4.2: Incremental Deployment Test (Docs Only) ==="

# Record current corporate site state
echo "=ø Capturing current corporate site state..."
BEFORE_ETAG=$(curl -sI https://info-tech-io.github.io/ | grep -i etag | cut -d' ' -f2)
BEFORE_SIZE=$(curl -s https://info-tech-io.github.io/ | wc -c)

echo "Before state:"
echo "  - ETag: $BEFORE_ETAG"
echo "  - Size: $BEFORE_SIZE bytes"

# Make test change to quiz docs
cd /root/info-tech-io/quiz
echo "<!-- Test $(date +%s) -->" >> docs/content/_index.md

git add docs/content/_index.md
git commit -m "test(docs): trigger incremental deployment test for Issue #10

Test incremental documentation deployment to verify corporate site
is NOT overwritten.

Related: info-tech-io/info-tech-io.github.io#10, Stage: 4, Step: 4.2"

git push origin main

echo ""
echo "ó Waiting for notify-hub trigger..."
sleep 20

# Monitor workflow
cd /root/info-tech-io/info-tech-io.github.io
RUN_ID=$(gh run list --workflow=deploy-github-pages.yml --limit 1 --json databaseId --jq '.[0].databaseId')
echo "=Ê Monitoring Run ID: $RUN_ID"

# Check event type
gh run view $RUN_ID --json event,displayTitle

# Watch execution
gh run watch $RUN_ID

# Check build plan
echo ""
echo "=== Build Plan ==="
gh run view $RUN_ID --log | grep -A10 "Build Plan:"

# Expected: Corporate=false, Docs=true

# Wait for deployment
echo ""
echo "ó Waiting for GitHub Pages deployment..."
sleep 180

# Verify corporate site NOT changed
echo ""
echo "=== Corporate Site Verification ==="
AFTER_ETAG=$(curl -sI https://info-tech-io.github.io/ | grep -i etag | cut -d' ' -f2)
AFTER_SIZE=$(curl -s https://info-tech-io.github.io/ | wc -c)

echo "After state:"
echo "  - ETag: $AFTER_ETAG"
echo "  - Size: $AFTER_SIZE bytes"

if [ "$BEFORE_ETAG" = "$AFTER_ETAG" ] && [ "$BEFORE_SIZE" = "$AFTER_SIZE" ]; then
  echo " Corporate site PRESERVED (not rebuilt)"
else
  echo "   Corporate site CHANGED"
  echo "This might indicate the incremental logic failed."
fi

# Verify docs updated
echo ""
echo "=== Documentation Verification ==="
echo -n "Quiz docs: "
curl -I "https://info-tech-io.github.io/docs/quiz/" 2>&1 | grep "HTTP"

# Check for test marker
if curl -s "https://info-tech-io.github.io/docs/quiz/" | grep -q "Test $(date +%s)"; then
  echo " Quiz docs UPDATED (test marker found)"
else
  echo "ó Quiz docs update not visible yet (CDN cache?)"
fi
```

**Verification**:
- [ ] repository_dispatch triggered
- [ ] Build plan shows: Corporate=false, Docs=true
- [ ] Corporate site unchanged (ETag and size match)
- [ ] Quiz docs updated
- [ ] No errors in logs

**Success Criteria**:
-  Incremental deployment worked correctly
-  Corporate site preserved
-  Only docs rebuilt

**Expected Result**: Docs updated, corporate untouched.

---

### Step 4.3: Incremental Test - Corporate Only

**Action**: Update corporate content 8 ?@>25@8BL GB> docs  ?5@570?8AK20NBAO

**Prerequisites**: This requires notify-hub.yml in info-tech repository. If not set up, skip this step.

**Implementation**:
```bash
echo "=== STEP 4.3: Incremental Deployment Test (Corporate Only) ==="

# Note: This test requires info-tech repository to have notify-hub workflow
# If not configured, document as "TODO: Set up corporate-site-updated trigger"

# Record current docs state
echo "=ø Capturing current docs state..."
BEFORE_QUIZ_ETAG=$(curl -sI https://info-tech-io.github.io/docs/quiz/ | grep -i etag | cut -d' ' -f2)

echo "Before state:"
echo "  - Quiz ETag: $BEFORE_QUIZ_ETAG"

# Make test change to corporate content
cd /root/info-tech-io/info-tech
echo "<!-- Corporate test $(date +%s) -->" >> docs/content/_index.md

git add docs/content/_index.md
git commit -m "test(content): trigger incremental deployment test

Test corporate site incremental deployment.

Related: info-tech-io/info-tech-io.github.io#10"

git push origin main

# If notify-hub configured, continue
# Otherwise, manually trigger workflow with corporate=true, docs=false
gh workflow run deploy-github-pages.yml \
  --repo info-tech-io/info-tech-io.github.io \
  --field rebuild_corporate=true \
  --field rebuild_docs=false

# Monitor and verify as in Step 4.2
# ...
```

**Success Criteria**:
-  Corporate rebuilt
-  Docs preserved

---

### Step 4.4: Error Handling Test

**Action**: @>25@8BL GB> safety checks @01>B0NB

**Implementation**:
```bash
echo "=== STEP 4.4: Error Handling Test ==="

# This test verifies merge integrity check catches issues
# We'll simulate by checking workflow behavior with hypothetical failures

# Review recent workflow for integrity check execution
echo "Checking merge integrity validation in recent runs..."

gh run view $RUN_ID --log | grep -A20 "Verify Merge Integrity"

# Look for:
# - "Verifying merged content integrity"
# - Corporate Site Checks
# - Documentation Checks
# - Integrity Check Summary

echo ""
echo " Verification: Check that logs show integrity validation executed"
```

**Verification**:
- [ ] Integrity check executes
- [ ] All files verified
- [ ] Summary shows 0 errors

**Success Criteria**:
-  Safety checks execute every deployment
-  Validation catches missing files (if simulated)

---

### Step 4.5: Production Monitoring

**Action**: 24-hour monitoring period

**Implementation**:
```bash
echo "=== STEP 4.5: 24-Hour Monitoring ==="

# Create monitoring script
cat > /tmp/monitor-site.sh <<'EOF'
#!/bin/bash

while true; do
  echo "=== $(date) ==="

  # Check corporate
  CORP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://info-tech-io.github.io/)
  echo "Corporate: $CORP_STATUS"

  # Check docs
  for site in quiz web-terminal hugo-templates info-tech-cli; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://info-tech-io.github.io/docs/$site/")
    echo "$site: $STATUS"
  done

  echo ""
  sleep 3600  # Check every hour
done
EOF

chmod +x /tmp/monitor-site.sh

echo "=Ê Starting 24-hour monitoring..."
echo "Run: /tmp/monitor-site.sh"
echo "Or manually check periodically."
```

**Verification**:
- [ ] Corporate site stable (200 OK)
- [ ] All docs sites stable (200 OK)
- [ ] No unexpected 404s
- [ ] Multiple incremental deployments successful

**Success Criteria**:
-  24 hours of stability
-  No regressions
-  Incremental deployments work reliably

---

### Step 4.6: Document Results

**Action**: Update progress.md and stage progress files

**Implementation**:
```bash
# Update 004-progress.md with test results
vim docs/proposals/10-fix-incremental-deployment-logic/004-progress.md

# Document:
# - Step 4.1 results (full deployment)
# - Step 4.2 results (docs incremental)
# - Step 4.3 results (corporate incremental)
# - Step 4.4 results (error handling)
# - Step 4.5 results (monitoring)

# Update main progress.md
vim docs/proposals/10-fix-incremental-deployment-logic/progress.md

# Commit progress update
git add docs/proposals/10-fix-incremental-deployment-logic/
git commit -m "docs(issue-10): update Stage 4 progress - testing complete

All tests passed:
- Full deployment: 
- Incremental docs deployment: 
- Corporate site preservation verified: 
- Safety checks validated: 
- 24-hour monitoring: 

Production status: All sites return 200 OK

Related: #10, Stage: 4, Step: 4.6"

git push origin main
```

---

## Testing Summary

### Test Matrix

| Test Case | Corporate | Docs | Expected Result | Actual | Status |
|-----------|-----------|------|-----------------|--------|--------|
| Full deployment | Build | Build | Both updated | - | ó |
| Docs incremental | Preserve | Build | Docs only updated | - | ó |
| Corporate incremental | Build | Preserve | Corporate only updated | - | ó |
| Error handling | - | - | Validation executes | - | ó |
| Stability | - | - | 24h uptime | - | ó |

---

## Success Metrics

### Primary Metrics (Must Achieve)
-  Corporate site returns 200 OK
-  All 4 docs sites return 200 OK
-  Incremental deployments work correctly
-  No content overwrites

### Secondary Metrics (Nice to Have)
-  Build plan always correct in logs
-  Merge integrity check passes
-  Zero false deployments
-  24-hour stability

---

## Rollback Plan

If testing reveals issues:
1. Identify which stage failed
2. Revert commits from that stage
3. Trigger manual full deployment
4. Re-analyze problem
5. Adjust fix approach

---

## Definition of Done

- [ ] Full deployment test passed
- [ ] Incremental docs deployment test passed
- [ ] Corporate preservation verified
- [ ] Error handling validated
- [ ] 24-hour monitoring completed
- [ ] All production URLs return 200 OK
- [ ] Test results documented
- [ ] Issue #10 ready to close

---

**Stage Status**: ó Ready After Stages 1-3
**Dependencies**: Stages 1, 2, 3 complete
**Deliverable**: Verified working solution
