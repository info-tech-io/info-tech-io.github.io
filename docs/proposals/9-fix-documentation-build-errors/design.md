# Fix Documentation Sites Build Errors

**Type**: Bug Fix
**Status**: Planning
**Repository**: info-tech-io.github.io
**Issue**: #9
**Branch Strategy**: Direct commits to main (no feature branch needed)
**Related Epic**: #2 (GitHub Pages Federation)
**Related Child**: #5 (Testing & Validation) - BLOCKED by this issue

---

## Problem Statement

### Symptoms
During Epic #2 Child Issue #5 testing, discovered that 2 out of 4 documentation
products fail to build and return 404 errors in production:

- ❌ hugo-templates: https://info-tech-io.github.io/docs/hugo-templates/ (404)
- ❌ info-tech-cli: https://info-tech-io.github.io/docs/info-tech-cli/ (404)
- ✅ quiz: https://info-tech-io.github.io/docs/quiz/ (200 OK)
- ✅ web-terminal: https://info-tech-io.github.io/docs/web-terminal/ (200 OK)

### Impact
- 50% of documentation products are inaccessible
- Blocks Epic #2 Child Issue #5 from completion
- Silent failure (CI reports success, but no HTML generated)
- Users cannot access hugo-templates and info-tech-cli documentation

### Root Cause Summary
Detailed investigation in `investigation/root-cause-analysis.md` identified:

1. **Primary cause**: Undefined Hugo shortcodes in markdown content
   - `hugo-templates/docs/content/developer-docs/components.md:1025` uses `{{< quiz >}}` shortcode
   - `info-tech-cli/docs/content/getting-started.md:288` uses `{{< video >}}` shortcode
   - Theme doesn't provide these shortcodes

2. **Secondary cause**: build.sh bug ignores Hugo errors in verbose mode
   - Located in hugo-templates repository
   - NOT in scope for this Issue (different repository)
   - Will provide recommendations in Stage 3

3. **Detection gap**: Workflow validation doesn't check critical files
   - Counts all HTML files (including theme templates)
   - Doesn't verify index.html exists
   - NOT in scope for this Issue (can address later if needed)

---

## Solution Overview

### Goal
Fix documentation build failures by removing undefined shortcodes from content,
ensuring all 4 documentation sites are accessible on GitHub Pages.

### Workflow
Direct commits to main branches - no PRs, no feature branches needed.
This is a small bug fix with clear solution and low risk.

### Scope
**In Scope:**
- ✅ Fix hugo-templates/docs/content/developer-docs/components.md
- ✅ Fix info-tech-cli/docs/content/getting-started.md
- ✅ Verify successful builds:
  - Local builds (temporary test directories)
  - GitHub Actions builds
  - Production deployment on GitHub Pages
  - Live documentation update test
- ✅ Provide recommendations for hugo-templates maintainers

**Out of Scope:**
- ❌ Modifying hugo-templates build scripts
- ❌ Modifying hugo-templates federated-build.sh
- ❌ Creating stub shortcode implementations
- ❌ Changing workflow validation logic
- ❌ Feature branches or complex review process

---

## Technical Design

### Solution: Remove Undefined Shortcodes

Content-only fixes that make documentation compatible with current theme capabilities.

#### Change 1: hugo-templates documentation
**File**: `hugo-templates/docs/content/developer-docs/components.md:1025`

**Current (broken):**
```markdown
Before we begin, let's test your JavaScript knowledge:

{{< quiz id="js-fundamentals" file="javascript-basics" >}}

This quiz covers basic JavaScript concepts...
```

**Proposed fix:**
```markdown
Before we begin, let's test your JavaScript knowledge with a quiz.

**Quiz component example:**
```html
{{</* quiz id="js-fundamentals" file="javascript-basics" */>}}
```

This quiz shortcode demonstrates how to embed interactive quizzes.
It covers basic JavaScript concepts...
```

**Rationale:**
- Shows quiz usage as code example (educational purpose maintained)
- Prevents Hugo from trying to render undefined shortcode
- Documentation about components should show code, not execute it
- Users can copy-paste the example

#### Change 2: info-tech-cli documentation
**File**: `info-tech-cli/docs/content/getting-started.md:288`

**Current (broken):**
```markdown
Watch this introduction video:
{{< video src="../static/videos/intro-python.mp4" >}}
```

**Proposed fix:**
```markdown
Watch this introduction video:

[📹 Introduction to InfoTech CLI](../static/videos/intro-python.mp4)
```

**Rationale:**
- Standard markdown link (compatible with all themes)
- Provides same functionality (user can open video)
- No dependency on custom shortcode
- Works in any markdown renderer

---

## Implementation Stages

### Stage 1: Content Fixes
**Duration**: 0.5 days
**Deliverables**: Fixed content in 2 repositories

**Tasks:**
1. Fix hugo-templates components.md shortcode
2. Test local build in temporary directory
3. Commit + push directly to main
4. Fix info-tech-cli getting-started.md shortcode
5. Test local build in temporary directory
6. Commit + push directly to main

**Success Criteria:**
- ✅ hugo-templates local build succeeds with index.html
- ✅ info-tech-cli local build succeeds with index.html
- ✅ No Hugo errors in build output
- ✅ Changes committed to main branches

**Detailed Plan**: See `001-content-fixes.md`

---

### Stage 2: Build Verification
**Duration**: 0.5 days
**Deliverables**: Verified working builds locally, in CI/CD, and in production

**Tasks:**

**Part 2.1: Local Build Verification**
1. Test all 4 documentation builds locally (quiz, web-terminal, hugo-templates, info-tech-cli)
2. Verify each output has index.html and 404.html
3. Check for Hugo errors in build logs
4. Document results

**Part 2.2: GitHub Actions Build Verification**
1. Trigger deploy-github-pages.yml workflow manually
2. Monitor workflow execution (verbose logs)
3. Download and inspect artifact.tar structure
4. Compare artifact structure with local builds
5. Verify all 4 modules present with HTML files

**Part 2.3: Production Deployment Verification**
1. Wait for GitHub Pages deployment (2-3 minutes)
2. Test all 4 documentation URLs
3. Verify all return 200 OK (not 404)
4. Verify HTML content renders correctly
5. **Test live documentation update** (trigger workflow via doc change)

**Success Criteria (FINAL):**
- ✅ All 4 modules build successfully locally with index.html
- ✅ GitHub Actions workflow completes without errors
- ✅ Artifact contains index.html for all 4 modules
- ✅ All 4 production URLs return 200 OK
- ✅ HTML content renders correctly on GitHub Pages
- ✅ Documentation updates trigger workflow and deploy successfully

**Detailed Plan**: See `002-build-verification.md`

---

### Stage 3: hugo-templates Recommendations
**Duration**: 0.25 days
**Deliverables**: Recommendations document for hugo-templates maintainers

**Tasks:**
1. Document build.sh verbose mode bug
2. Provide code fix recommendations with explanation
3. Suggest validation improvements
4. Outline benefits and risks
5. Propose workflow for submitting to hugo-templates

**Success Criteria:**
- ✅ Clear documentation of build.sh issue
- ✅ Code fix with explanation
- ✅ Testing recommendations provided
- ✅ Ready for maintainer discussion (no PR yet)

**Detailed Plan**: See `003-hugo-templates-recommendations.md`

---

## Dependencies

### Upstream
- Epic #2 Child Issue #5 (blocked by this Issue)
- hugo-templates repository (for fix approval/merge)
- info-tech-cli repository (for fix approval/merge)

### Downstream
None - this is a bug fix, not a feature

---

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Fix rejected by maintainers | High | Low | We are maintainers, commits go directly to main |
| Different shortcode syntax needed | Medium | Very Low | Test locally before commit |
| Breaks existing links/references | Low | Very Low | Content changes are minimal, don't affect URLs |
| hugo-templates recommendations ignored | Low | Medium | Document for future reference anyway |
| Deployment still fails after fix | High | Very Low | Thorough local testing before commit |

---

## Testing Strategy

### Local Testing (Stage 2.1)
Test all 4 modules in temporary directories to ensure builds succeed:

```bash
cd /root/info-tech-io/hugo-templates

# Test all 4 modules
for repo in quiz web-terminal hugo-templates info-tech-cli; do
  ./scripts/build.sh \
    --config /root/info-tech-io/$repo/docs/module.json \
    --output /tmp/verify-$repo \
    --content /root/info-tech-io/$repo/docs/content \
    --verbose
done

# Verify outputs
for module in quiz web-terminal hugo-templates info-tech-cli; do
  ls -lh /tmp/verify-$module/index.html
done
```

### CI/CD Testing (Stage 2.2)
```bash
# Trigger and monitor workflow
gh workflow run deploy-github-pages.yml
gh run watch

# Download and inspect artifact
gh run download <run-id> --name github-pages
tar -xf artifact.tar
ls -la docs/*/index.html
```

### Production Testing (Stage 2.3)
```bash
# Check all documentation sites return 200 OK
for site in quiz web-terminal hugo-templates info-tech-cli; do
  curl -I "https://info-tech-io.github.io/docs/$site/" | grep "HTTP"
done

# Test live update trigger
# Make minor change to quiz docs
# Verify workflow triggers and deploys
```

---

## Rollback Plan

If content fixes cause unexpected issues:

1. Revert commits in hugo-templates and info-tech-cli
2. Original broken state resumes (404s return)
3. Re-evaluate solution approach

**Risk of rollback**: Very low
- Content changes are minimal and safe
- Changes don't affect functionality, only fix broken builds
- Can revert with single git revert command

---

## Success Metrics

### Primary Metrics (Must Achieve)
- ✅ All 4 documentation sites return 200 OK
- ✅ All sites have index.html in deployed artifact
- ✅ No Hugo build errors in workflow logs
- ✅ Documentation updates deploy successfully

### Secondary Metrics (Nice to Have)
- Zero production issues after deployment
- Epic #2 Child Issue #5 unblocked
- Build times remain similar (<2 minutes)
- No increase in artifact size

---

## Timeline

| Stage | Duration | Cumulative |
|-------|----------|------------|
| Stage 1: Content Fixes | 0.5 days | 0.5 days |
| Stage 2: Build Verification | 0.5 days | 1.0 days |
| Stage 3: Recommendations | 0.25 days | 1.25 days |

**Total Estimated Duration**: 1.25 days (10 hours)

**Breakdown:**
- Content fixes + local testing: 4 hours
- Full verification (local + CI + prod): 4 hours
- Recommendations: 2 hours

---

## Next Steps After Completion

1. ✅ Close this Issue #9
2. ✅ Update Epic #2 Child Issue #5 progress (remove BLOCKED status)
3. ✅ Continue Child Issue #5 Stage 2 (E2E Workflow Testing)
4. ⏳ (Optional) Discuss hugo-templates recommendations with maintainers
5. ⏳ (Optional) Create separate Issue for workflow validation improvements

---

## Related Documentation

**Investigation Materials** (in `investigation/` directory):
- `root-cause-analysis.md` - Complete root cause investigation with evidence
- `test-results.md` - Testing results from Epic #2 Child #5
- `LAST_SESSION.md` - Previous session notes and discoveries

**Epic #2 Documentation**:
- `../epic-2-github-pages-federation/design.md` - Epic-level design
- `../epic-2-github-pages-federation/child-5-testing-validation/design.md` - Child #5 design
- `../epic-2-github-pages-federation/child-5-testing-validation/progress.md` - Child #5 progress (BLOCKED)

**Related Issues**:
- Epic #2: GitHub Pages Federation
- Child Issue #5: Testing & Validation (blocked by this issue)

---

## Commit Strategy

**Simple workflow** (no branches, no PRs):

```bash
# Stage 1: hugo-templates fix
cd /root/info-tech-io/hugo-templates
vim docs/content/developer-docs/components.md
# Test locally in /tmp/
git add docs/content/developer-docs/components.md
git commit -m "fix(docs): replace undefined quiz shortcode with code example

The quiz shortcode is not defined in the documentation theme,
causing Hugo build to fail silently. Replace with code example
to demonstrate usage without executing the shortcode.

This fixes build failures discovered during Epic #2 Child #5 testing.

Fixes: info-tech-io/info-tech-io.github.io#9"
git push origin main

# Stage 1: info-tech-cli fix
cd /root/info-tech-io/info-tech-cli
vim docs/content/getting-started.md
# Test locally in /tmp/
git add docs/content/getting-started.md
git commit -m "fix(docs): replace undefined video shortcode with markdown link

The video shortcode is not defined in the documentation theme,
causing Hugo build to fail silently. Replace with standard markdown
link that provides same functionality.

This fixes build failures discovered during Epic #2 Child #5 testing.

Fixes: info-tech-io/info-tech-io.github.io#9"
git push origin main

# Stage 2: Verification (testing only, no commits)
# Stage 3: Recommendations (document in this Issue, commit to this repo)
```

---

**Document Version**: 1.0
**Created**: 2025-10-31
**Last Updated**: 2025-10-31
**Status**: Ready for Implementation
