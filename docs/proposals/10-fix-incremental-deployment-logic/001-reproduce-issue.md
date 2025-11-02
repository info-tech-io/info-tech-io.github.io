# Stage 1: Reproduce the Issue

**Objective**: >A?@>8725AB8 A8BC0F8N ?>B5@8 :>=B5=B0 ?>A;5 deployment
**Duration**: 0.5 days (4 hours)
**Dependencies**: None

---

## Overview

5@54 B5< :0: 8A?@02;OBL ?@>1;5<C, =5>1E>48<> B>G=> 2>A?@>8725AB8 <5E0=87<, ?@8 :>B>@>< ?@>8AE>48B ?>B5@O 4>ABC?0 : corporate site ?>A;5 CA?5H=>3> deployment. -B> :@8B8G=> 4;O:
1. ">G=>9 4803=>AB8:8 root cause
2. @>25@:8 GB> 8A?@02;5=85 459AB28B5;L=> @5H05B ?@>1;5<C
3. >=8<0=8O 2A5E edge cases

---

## Detailed Steps

### Step 1.1: Analyze Current Production State

**Action**: 5B0;L=K9 0=0;87 B5:CI53> A>AB>O=8O production

**Implementation**:
```bash
# Check current production status
echo "=== CORPORATE SITE ==="
curl -I https://info-tech-io.github.io/
curl -s https://info-tech-io.github.io/ | head -50

echo -e "\n=== DOCUMENTATION SITES ==="
for site in quiz web-terminal hugo-templates info-tech-cli; do
  echo "--- $site ---"
  curl -I "https://info-tech-io.github.io/docs/$site/"
done

# Check GitHub Pages deployment history
gh api /repos/info-tech-io/info-tech-io.github.io/pages/builds?per_page=10

# Check latest workflow runs
gh run list --workflow=deploy-github-pages.yml --limit 10

# Check if gh-pages branch exists
git ls-remote --heads origin | grep gh-pages
```

**Verification**:
- [ ] Production status documented (corporate: 404, docs: 200)
- [ ] Last successful deployment identified
- [ ] Workflow runs timeline established
- [ ] GitHub Pages source configuration checked

**Success Criteria**:
-  Clear picture of what content is missing
-  Timeline of deployments established
-  Identified last known good state

---

### Step 1.2: Analyze Workflow Artifacts

**Action**: !:0G0BL 8 ?@>25@8BL artifacts 87 ?@>1;5<=KE workflow runs

**Implementation**:
```bash
# Download artifacts from recent runs
# Run #7 (manual, 2025-11-01 11:33)
gh run download 18996122733 --name github-pages -D /tmp/run-7-artifact

# Run #8 (quiz-docs-updated, 2025-11-01 11:59)
gh run download 18996356257 --name github-pages -D /tmp/run-8-artifact 2>/dev/null || echo "Run #8 artifact not available"

# Extract and inspect
cd /tmp/run-7-artifact
tar -xf artifact.tar

# Check structure
echo "=== Artifact Structure ==="
ls -la

echo "=== Corporate Site Files ==="
ls -la *.html 2>/dev/null || echo "No HTML files in root"

echo "=== Documentation Files ==="
ls -la docs/*/index.html 2>/dev/null || echo "No docs found"

# Count files
echo "=== File Counts ==="
find . -name "*.html" | wc -l
du -sh .
```

**Verification**:
- [ ] Artifact from Run #7 downloaded and inspected
- [ ] Artifact structure matches expectations
- [ ] Corporate site content present in artifact
- [ ] Documentation content present in artifact

**Success Criteria**:
-  Confirmed artifact contains correct content
-  Identified discrepancy between artifact and production

---

### Step 1.3: Attempt Manual Deployment Recovery

**Action**: >?KB0BLAO 2>AAB0=>28BL corporate site G5@57 manual workflow trigger

**Implementation**:
```bash
# Trigger manual workflow with both components
gh workflow run deploy-github-pages.yml \
  --field rebuild_corporate=true \
  --field rebuild_docs=true \
  --field debug=false

# Wait for completion
sleep 10
RUN_ID=$(gh run list --workflow=deploy-github-pages.yml --limit 1 --json databaseId --jq '.[0].databaseId')

echo "Monitoring run: $RUN_ID"
gh run watch $RUN_ID

# After completion, check production
echo "Waiting for GitHub Pages deployment (3 minutes)..."
sleep 180

echo "=== Checking Production ==="
curl -I https://info-tech-io.github.io/
curl -I https://info-tech-io.github.io/docs/quiz/
```

**Verification**:
- [ ] Manual workflow triggered successfully
- [ ] Build completed without errors
- [ ] Deployment reported success
- [ ] Production status checked after deployment

**Success Criteria**:
-  Workflow execution logged
-  Production status documented (fixed or still broken)

**Expected Outcomes**:
- **If Fixed**: Manual deployment restores corporate site ’ problem is specific to incremental deployments
- **If Not Fixed**: Corporate site still 404 ’ deeper GitHub Pages configuration issue

---

### Step 1.4: Reproduce Incremental Deployment Failure

**Action**: >A?@>8725AB8 ?@>1;5<C G5@57 incremental documentation update

**Prerequisites**: Corporate site 4>;65= 1KBL working (?>A;5 Step 1.3 8;8 4@C38< A?>A>1><)

**Implementation**:
```bash
# Step A: Verify corporate site is working
curl -I https://info-tech-io.github.io/
# Expected: 200 OK

# Step B: Make minor change to quiz docs
cd /root/info-tech-io/quiz
echo "<!-- Test trigger $(date +%s) -->" >> docs/content/_index.md

git add docs/content/_index.md
git commit -m "test: trigger incremental deployment for Issue #10 reproduction

This commit tests incremental documentation deployment to reproduce
the corporate site loss issue.

Related: info-tech-io/info-tech-io.github.io#10"

git push origin main

# Step C: Monitor workflow trigger
echo "Waiting for notify-hub to trigger..."
sleep 15

# Check notify-hub ran
cd /root/info-tech-io/quiz
gh run list --workflow=notify-hub.yml --limit 1

# Check deploy-github-pages triggered
cd /root/info-tech-io/info-tech-io.github.io
gh run list --workflow=deploy-github-pages.yml --limit 1

# Get latest run
RUN_ID=$(gh run list --workflow=deploy-github-pages.yml --limit 1 --json databaseId --jq '.[0].databaseId')

# Monitor execution
gh run watch $RUN_ID

# Step D: Check build plan in logs
gh run view $RUN_ID --log | grep -A5 "Build plan:"

# Step E: After completion, wait for Pages deployment
echo "Waiting for GitHub Pages deployment..."
sleep 180

# Step F: Verify production status
echo "=== AFTER INCREMENTAL DEPLOYMENT ==="
echo "Corporate site:"
curl -I https://info-tech-io.github.io/

echo "Documentation:"
curl -I https://info-tech-io.github.io/docs/quiz/
```

**Verification**:
- [ ] Corporate site confirmed working before test
- [ ] Quiz docs change committed and pushed
- [ ] repository_dispatch event triggered
- [ ] Workflow executed with correct event type
- [ ] Build plan logged and captured
- [ ] Production status checked after deployment

**Success Criteria**:
-  Incremental deployment triggered correctly
-  Build plan shows expected values (Corporate=false, Docs=true OR Corporate=true, Docs=true)
-  Production status documented (corporate working or 404)

**Possible Outcomes**:

**Outcome A: Corporate site remains working**
- Incremental deployment works correctly
- Problem was one-time issue or already fixed
- Need to investigate what changed

**Outcome B: Corporate site returns 404**
- Successfully reproduced the issue
- Can analyze exact failure mechanism
- Ready to implement fix

**Outcome C: Different failure mode**
- Document unexpected behavior
- Adjust investigation approach

---

### Step 1.5: Detailed Failure Analysis

**Action**: A;8 ?@>1;5<0 2>A?@>872545=0, ?@>25AB8 45B0;L=K9 0=0;87 <5E0=87<0

**Implementation**:
```bash
# Download failing run artifact
FAIL_RUN_ID="<id-of-failed-run>"
gh run download $FAIL_RUN_ID --name github-pages -D /tmp/fail-run

# Extract and analyze
cd /tmp/fail-run
tar -xf artifact.tar

# Compare structure with working run
echo "=== Structure Comparison ==="
echo "Failed run files:"
find . -type f -name "*.html" | head -20

echo "Working run files:"
find /tmp/run-7-artifact -type f -name "*.html" | head -20

# Check if corporate content was built
echo "=== Corporate Content Check ==="
ls -la index.html 2>/dev/null || echo "MISSING: index.html"
ls -la 404.html 2>/dev/null || echo "MISSING: 404.html"

# Check if documentation was built
echo "=== Documentation Check ==="
for site in quiz web-terminal hugo-templates info-tech-cli; do
  if [ -f "docs/$site/index.html" ]; then
    echo " docs/$site/index.html: $(stat -f%z docs/$site/index.html 2>/dev/null || stat -c%s docs/$site/index.html)"
  else
    echo "L docs/$site/index.html: MISSING"
  fi
done

# Analyze workflow logs
gh run view $FAIL_RUN_ID --log > /tmp/fail-run-logs.txt

# Extract key sections
echo "=== Build Targets Decision ==="
grep -A10 "Determine Build Targets" /tmp/fail-run-logs.txt | grep -E "Build plan|Corporate|Documentation"

echo "=== Merge Operations ==="
grep -A20 "Atomic Merge" /tmp/fail-run-logs.txt | grep -E "Merging|Skipping|rsync"

echo "=== Deployment Result ==="
grep -A10 "Deploy to GitHub Pages" /tmp/fail-run-logs.txt | grep -E "success|fail|error"
```

**Verification**:
- [ ] Failing run artifact analyzed
- [ ] Comparison with working run completed
- [ ] Workflow logs analyzed for decision points
- [ ] Failure mechanism identified

**Success Criteria**:
-  Exact point of failure identified
-  Build vs Deploy vs Pages issue clarified
-  Hypothesis about root cause formed

---

### Step 1.6: Document Findings

**Action**: 04>:C<5=B8@>20BL @57C;LB0BK 2>A?@>872545=8O

**Implementation**:

Create `001-progress.md` with:
1. Current production status
2. Reproduction steps executed
3. Results of each attempt
4. Failure mechanism (if reproduced)
5. Hypothesis about root cause
6. Evidence (screenshots, log excerpts, artifact diffs)

**Success Criteria**:
-  Complete reproduction documented
-  Root cause hypothesis validated or refined
-  Ready to proceed with fix implementation

---

## Testing Plan

Each reproduction attempt should be:
1. Documented with screenshots/logs
2. Repeatable
3. Isolated (one variable changed at a time)

---

## Rollback Plan

If reproduction attempts break production further:
1. Trigger manual workflow with both=true
2. Restore to last known good state
3. Document what went wrong
4. Adjust approach

---

## Definition of Done

- [ ] Current production state fully documented
- [ ] Artifacts from problematic runs analyzed
- [ ] Manual deployment recovery attempted
- [ ] Incremental deployment reproduction attempted
- [ ] Failure mechanism identified and documented
- [ ] Root cause hypothesis validated
- [ ] Evidence collected and organized
- [ ] Ready to implement fix in Stage 2

---

## Notes

**Important**: This stage is about understanding, not fixing. The goal is to:
- Confirm the problem exists
- Understand exact mechanism
- Validate our hypothesis
- Ensure fix will target the right issue

**Safety**: All reproduction attempts should be carefully monitored and reversible.

---

**Stage Status**: ó Ready to Start
**Dependencies**: None
**Blocks**: Stage 2 (cannot fix what we don't understand)
