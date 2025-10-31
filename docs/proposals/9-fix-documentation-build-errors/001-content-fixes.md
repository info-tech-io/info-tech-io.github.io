# Stage 1: Content Fixes

**Objective**: Remove undefined shortcodes from documentation content
**Duration**: 0.5 days (4 hours)
**Branch**: Direct commits to main (no feature branch)
**Dependencies**: None

---

## Overview

Fix content in two repositories by replacing undefined Hugo shortcodes with compatible alternatives. Test each fix locally before committing.

---

## Detailed Steps

### Step 1.1: Fix hugo-templates documentation

**Action**: Replace undefined quiz shortcode with code example

**File**: `hugo-templates/docs/content/developer-docs/components.md:1025`

**Current Line** (approximate):
```markdown
# JavaScript Fundamentals

Before we begin, let's test your current JavaScript knowledge:

{{< quiz id="js-fundamentals" file="javascript-basics" >}}

This quiz covers basic JavaScript concepts including:
```

**Proposed Change**:
```markdown
# JavaScript Fundamentals

Before we begin, let's test your current JavaScript knowledge with a quiz.

**Quiz component example:**
```html
{{</* quiz id="js-fundamentals" file="javascript-basics" */>}}
```

This quiz shortcode demonstrates how to embed interactive quizzes.
It covers basic JavaScript concepts including:
```

**Implementation Steps**:
```bash
cd /root/info-tech-io/hugo-templates

# Edit the file
vim docs/content/developer-docs/components.md
# Navigate to line ~1025
# Replace the shortcode as shown above
```

**Local Test**:
```bash
# Test build locally
./scripts/build.sh \
  --config docs/module.json \
  --output /tmp/test-hugo-templates \
  --content docs/content \
  --verbose 2>&1 | tee /tmp/build-hugo-templates.log

# Verify output
echo "=== Checking build results ==="
ls -lh /tmp/test-hugo-templates/index.html
ls -lh /tmp/test-hugo-templates/404.html

# Check for errors
echo "=== Checking for Hugo errors ==="
grep -i "error" /tmp/build-hugo-templates.log | grep -v "error_count" || echo "No errors found"

# Verify index.html size (should be ~40-50 KB)
stat -c%s /tmp/test-hugo-templates/index.html
```

**Verification Criteria**:
- [ ] Build completes without errors
- [ ] index.html exists (~40-50 KB)
- [ ] 404.html exists (~37-40 KB)
- [ ] No "shortcode not found" errors in logs
- [ ] No "failed to extract shortcode" errors

**Commit**:
```bash
cd /root/info-tech-io/hugo-templates

git add docs/content/developer-docs/components.md
git commit -m "fix(docs): replace undefined quiz shortcode with code example

The quiz shortcode is not defined in the documentation theme,
causing Hugo build to fail silently in verbose mode. The build
reports success but no HTML files are generated.

Replace shortcode invocation with code example to demonstrate
usage without executing it. This is more appropriate for
component documentation that shows how to use the component.

Root cause analysis:
- Hugo error: 'template for shortcode \"quiz\" not found'
- build.sh in verbose mode doesn't check exit codes (line 832)
- Results in deployment of source files instead of HTML

This fix resolves the build failure. Recommendations for
build.sh improvements will be provided separately.

Fixes: info-tech-io/info-tech-io.github.io#9
Related: Epic #2, Child #5"

git push origin main
```

---

### Step 1.2: Fix info-tech-cli documentation

**Action**: Replace undefined video shortcode with markdown link

**File**: `info-tech-cli/docs/content/getting-started.md:288`

**Current Lines** (approximate):
```markdown
![Python Logo](../static/images/python-logo.png)

Watch this introduction video:
{{< video src="../static/videos/intro-python.mp4" >}}
```

**Proposed Change**:
```markdown
![Python Logo](../static/images/python-logo.png)

Watch this introduction video:

[📹 Introduction to InfoTech CLI](../static/videos/intro-python.mp4)
```

**Implementation Steps**:
```bash
cd /root/info-tech-io/info-tech-cli

# Edit the file
vim docs/content/getting-started.md
# Navigate to line ~288
# Replace the shortcode as shown above
```

**Local Test**:
```bash
cd /root/info-tech-io/hugo-templates

# Test build locally
./scripts/build.sh \
  --config /root/info-tech-io/info-tech-cli/docs/module.json \
  --output /tmp/test-info-tech-cli \
  --content /root/info-tech-io/info-tech-cli/docs/content \
  --verbose 2>&1 | tee /tmp/build-info-tech-cli.log

# Verify output
echo "=== Checking build results ==="
ls -lh /tmp/test-info-tech-cli/index.html
ls -lh /tmp/test-info-tech-cli/404.html

# Check for errors
echo "=== Checking for Hugo errors ==="
grep -i "error" /tmp/build-info-tech-cli.log | grep -v "error_count" || echo "No errors found"

# Verify index.html size (should be ~40-50 KB)
stat -c%s /tmp/test-info-tech-cli/index.html
```

**Verification Criteria**:
- [ ] Build completes without errors
- [ ] index.html exists (~40-50 KB)
- [ ] 404.html exists (~37-40 KB)
- [ ] No "shortcode not found" errors in logs
- [ ] No "failed to extract shortcode" errors

**Commit**:
```bash
cd /root/info-tech-io/info-tech-cli

git add docs/content/getting-started.md
git commit -m "fix(docs): replace undefined video shortcode with markdown link

The video shortcode is not defined in the documentation theme,
causing Hugo build to fail silently in verbose mode. The build
reports success but no HTML files are generated.

Replace shortcode with standard markdown link that provides the
same functionality. Users can still access the video by clicking
the link.

Root cause analysis:
- Hugo error: 'template for shortcode \"video\" not found'
- build.sh in verbose mode doesn't check exit codes
- Results in deployment of source files instead of HTML

This fix resolves the build failure. Recommendations for
build.sh improvements will be provided separately.

Fixes: info-tech-io/info-tech-io.github.io#9
Related: Epic #2, Child #5"

git push origin main
```

---

## Success Criteria

**All must be true to proceed to Stage 2:**

### hugo-templates
- [x] Build completes without Hugo errors
- [x] index.html exists in /tmp/test-hugo-templates/
- [x] 404.html exists in /tmp/test-hugo-templates/
- [x] No "shortcode not found" in logs
- [x] Changes committed and pushed to main

### info-tech-cli
- [x] Build completes without Hugo errors
- [x] index.html exists in /tmp/test-info-tech-cli/
- [x] 404.html exists in /tmp/test-info-tech-cli/
- [x] No "shortcode not found" in logs
- [x] Changes committed and pushed to main

---

## Rollback Plan

If issues discovered after commit:

```bash
# hugo-templates rollback
cd /root/info-tech-io/hugo-templates
git revert HEAD
git push origin main

# info-tech-cli rollback
cd /root/info-tech-io/info-tech-cli
git revert HEAD
git push origin main
```

---

## Expected Output

### Before Fixes
```
hugo-templates build:
  Error: template for shortcode "quiz" not found
  ✅ Build completed successfully! (FALSE POSITIVE)
  Files: source files only, no index.html

info-tech-cli build:
  Error: template for shortcode "video" not found
  ✅ Build completed successfully! (FALSE POSITIVE)
  Files: source files only, no index.html
```

### After Fixes
```
hugo-templates build:
  ✅ Hugo build completed (NO ERRORS)
  ✅ Build completed successfully!
  Files: index.html (43 KB), 404.html (38 KB), + pages

info-tech-cli build:
  ✅ Hugo build completed (NO ERRORS)
  ✅ Build completed successfully!
  Files: index.html (42 KB), 404.html (37 KB), + pages
```

---

## Notes

- **No PRs needed**: Direct commits to main (small, safe changes)
- **Test locally first**: Verify build before push
- **Temporary directories**: All tests in /tmp/ (will be cleaned up)
- **Commit messages**: Follow conventional commits format
- **Cross-reference**: Link to Issue #9 in all commits

---

## Timeline

| Step | Duration | Cumulative |
|------|----------|------------|
| 1.1: hugo-templates fix + test | 2 hours | 2 hours |
| 1.2: info-tech-cli fix + test | 2 hours | 4 hours |

**Total Stage 1 Duration**: 4 hours (0.5 days)

---

**Stage Status**: ⏳ Ready to Start
**Dependencies**: None
**Blockers**: None
