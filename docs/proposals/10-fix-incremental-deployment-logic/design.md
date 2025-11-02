# Fix Incremental Deployment Logic in Unified Workflow

**Type**: Bug Fix
**Status**: Planning
**Repository**: info-tech-io.github.io
**Issue**: #10
**Priority**: CRITICAL
**Branch Strategy**: Direct commits to main
**Related Epic**: #2 (GitHub Pages Federation)
**Related Child**: #5 (Testing & Validation) - BLOCKED

---

## Problem Statement

### Symptoms

Unified GitHub Pages workflow incorrectly determines build targets for `repository_dispatch` events, causing production outages.

**Production Status**:
- L Corporate site `/`: **404**
-  Documentation `/docs/*`: **200 OK**

### Root Cause

**File**: `.github/workflows/deploy-github-pages.yml:116-151`

Build target logic appears correct BUT production shows corporate site 404. Analysis reveals issue is likely in:
1. Build target determination edge cases
2. Merge logic with `--delete` flag
3. Possible GitHub Pages deployment issue

Need to bulletproof all three areas.

---

## Solution Overview

**Three-pronged approach**:
1. Make build target determination explicit with validation
2. Add safety checks to merge operations
3. Enhance deployment verification

---

## Implementation Stages

### Stage 1: Reproduce the Issue (0.5 days)

Воспроизвести проблему для точной диагностики:
- Analyze current production state
- Review workflow artifacts
- Attempt manual recovery
- Reproduce incremental failure
- Document failure mechanism

### Stage 2: Fix Build Target Logic (0.25 days)

Make determination bulletproof:
- Remove ambiguous fallbacks
- Add explicit validation
- Pattern match for docs events
- Full error handling

### Stage 3: Enhance Merge Safety (0.25 days)

Prevent content loss:
- Pre-merge validation
- Post-merge integrity checks
- Enhanced logging

### Stage 4: Test & Verify (0.5 days)

Comprehensive testing:
- Full deployment test
- Incremental deployment tests
- Error handling validation
- 24-hour monitoring

---

## Timeline

**Total**: 1.5 days (12 hours)

---

**See detailed plans in**:
- `001-reproduce-issue.md` + `001-progress.md`
- `002-fix-build-logic.md` + `002-progress.md`
- `003-enhance-safety.md` + `003-progress.md`
- `004-test-verify.md` + `004-progress.md`
