# Stage 3: hugo-templates Recommendations

**Objective**: Document recommendations for hugo-templates repository maintainers
**Duration**: 0.25 days (2 hours)
**Dependencies**: Stage 2 complete (verification successful)

---

## Overview

Provide detailed recommendations for improving hugo-templates build scripts to prevent similar issues in the future. These recommendations are for future consideration and do not block this Issue.

---

## Recommendation 1: Fix build.sh Verbose Mode Bug

### Issue Description

**File**: `hugo-templates/scripts/build.sh`
**Lines**: 831-843 (function `run_hugo_build`)

**Problem**:
When `--verbose` flag is used, Hugo errors are not checked, causing silent failures. The build script reports success even when Hugo fails to generate any HTML files.

**Current Code** (BROKEN):
```bash
# Execute Hugo build
if [[ "$VERBOSE" == "true" ]]; then
    eval "$hugo_cmd"              # ❌ NO EXIT CODE CHECK!
else
    # Capture both stdout and stderr for error reporting
    local build_output
    build_output=$(eval "$hugo_cmd" 2>&1) || {
        log_error "Hugo build failed with output:"
        echo "$build_output" | sed 's/^/   /' >&2
        return 1
    }
    log_verbose "Hugo build output: $build_output"
fi

cd - >/dev/null

log_success "Hugo build completed"  # ❌ ALWAYS REPORTS SUCCESS!
```

### Proposed Fix

**Option A: Simple Fix** (Recommended)
```bash
# Execute Hugo build
if [[ "$VERBOSE" == "true" ]]; then
    eval "$hugo_cmd" || {
        log_error "Hugo build failed in verbose mode"
        cd - >/dev/null
        return 1
    }
else
    # Capture both stdout and stderr for error reporting
    local build_output
    build_output=$(eval "$hugo_cmd" 2>&1) || {
        log_error "Hugo build failed with output:"
        echo "$build_output" | sed 's/^/   /' >&2
        cd - >/dev/null
        return 1
    }
    log_verbose "Hugo build output: $build_output"
fi

cd - >/dev/null

log_success "Hugo build completed"
```

**Option B: Unified Approach** (Better long-term)
```bash
# Execute Hugo build
local build_output
if [[ "$VERBOSE" == "true" ]]; then
    # Show output directly but still capture for error checking
    eval "$hugo_cmd" 2>&1 | tee /tmp/hugo-build-$$.log
    local exit_code=${PIPESTATUS[0]}
    build_output=$(cat /tmp/hugo-build-$$.log)
    rm -f /tmp/hugo-build-$$.log
else
    # Capture output
    build_output=$(eval "$hugo_cmd" 2>&1)
    local exit_code=$?
fi

# Check exit code
if [[ $exit_code -ne 0 ]]; then
    log_error "Hugo build failed with exit code $exit_code"
    if [[ "$VERBOSE" != "true" ]]; then
        echo "$build_output" | sed 's/^/   /' >&2
    fi
    cd - >/dev/null
    return 1
fi

cd - >/dev/null
log_success "Hugo build completed"
```

### Benefits

- ✅ Catches Hugo build errors in all modes
- ✅ Prevents deployment of source files
- ✅ Provides clear error messages
- ✅ Fails fast (doesn't continue with broken build)

### Testing

```bash
# Test with known-bad content (undefined shortcode)
echo '{{< nonexistent >}}' > /tmp/test-content.md

# Should FAIL with error (not report success)
./scripts/build.sh \
  --config test-module.json \
  --output /tmp/test \
  --content /tmp/ \
  --verbose

# Expected: "Hugo build failed" error, exit code 1
# Current: "Build completed successfully!", exit code 0
```

---

## Recommendation 2: Enhance Validation

### Issue Description

**Current Validation**:
```bash
# Just counts HTML files (includes theme templates)
find "$output_dir" -name "*.html" | wc -l
```

**Problem**:
- Counts template files in themes/ directory
- Doesn't verify critical files exist
- Can report success even when no pages generated

### Proposed Enhancement

```bash
# Validate critical files exist
validate_build_output() {
    local output_dir="$1"
    local module_name="$2"

    log_info "Validating build output..."

    # Check critical files
    local critical_files=("index.html" "404.html")
    local missing_files=()

    for file in "${critical_files[@]}"; do
        if [[ ! -f "$output_dir/$file" ]]; then
            missing_files+=("$file")
        fi
    done

    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_error "Critical files missing: ${missing_files[*]}"
        log_error "Build may have failed silently"
        return 1
    fi

    # Count actual content HTML (exclude themes/)
    local content_html=$(find "$output_dir" -name "*.html" -type f \
        ! -path "*/themes/*" \
        ! -path "*/layouts/*" | wc -l)

    log_info "Content HTML files: $content_html"

    if [[ $content_html -lt 2 ]]; then
        log_warning "Very few HTML files generated ($content_html)"
        log_warning "Expected at least index.html and 404.html"
    fi

    log_success "Build output validation complete"
    return 0
}

# Call after Hugo build
if ! validate_build_output "$OUTPUT" "$MODULE_NAME"; then
    exit 1
fi
```

### Benefits

- ✅ Catches missing critical files
- ✅ Distinguishes between theme files and content
- ✅ Provides early warning of build issues
- ✅ Prevents silent failures

---

## Recommendation 3: Add Hugo Error Detection

### Issue Description

Hugo can output errors but still exit with code 0 in some cases, particularly with warnings that should be treated as errors.

### Proposed Enhancement

```bash
# After Hugo build, check for error messages in output
detect_hugo_errors() {
    local build_output="$1"

    # Check for common Hugo error patterns
    if echo "$build_output" | grep -qi "error building site"; then
        return 1
    fi

    if echo "$build_output" | grep -qi "failed to extract shortcode"; then
        return 1
    fi

    if echo "$build_output" | grep -qi "template.*not found"; then
        return 1
    fi

    return 0
}

# Use after Hugo build
if ! detect_hugo_errors "$build_output"; then
    log_error "Hugo errors detected in output"
    echo "$build_output" | grep -i "error" >&2
    return 1
fi
```

### Benefits

- ✅ Catches errors that don't set exit code
- ✅ Detects shortcode issues early
- ✅ Prevents deployment of broken builds

---

## Recommendation 4: Improve Error Messages

### Current State

Errors don't provide actionable information:
```
✅ Hugo build completed
✅ Build completed successfully!
```

### Proposed Improvement

```bash
log_build_summary() {
    local output_dir="$1"
    local exit_code="$2"

    if [[ $exit_code -eq 0 ]]; then
        log_success "Hugo build completed successfully"

        # Show helpful metrics
        local html_count=$(find "$output_dir" -name "*.html" ! -path "*/themes/*" | wc -l)
        local pages_count=$(find "$output_dir" -type d ! -path "*/themes/*" ! -path "*/.git/*" | wc -l)
        local size=$(du -sh "$output_dir" | cut -f1)

        log_info "Generated $html_count HTML files across $pages_count pages"
        log_info "Total output size: $size"

        # Verify critical files
        if [[ -f "$output_dir/index.html" ]]; then
            log_verbose "✅ index.html: $(stat -c%s "$output_dir/index.html") bytes"
        else
            log_warning "⚠️  index.html not found (may indicate build issue)"
        fi
    else
        log_error "Hugo build failed with exit code $exit_code"
        log_error "Common causes:"
        log_error "  - Undefined shortcodes in content"
        log_error "  - Missing theme files"
        log_error "  - Invalid front matter"
        log_error "  - Content syntax errors"
        log_error ""
        log_error "Check build output above for specific error messages"
    fi
}
```

### Benefits

- ✅ Clear success/failure indication
- ✅ Actionable error messages
- ✅ Helpful metrics for debugging
- ✅ Verification of critical files

---

## Implementation Priority

| Recommendation | Priority | Effort | Impact |
|----------------|----------|--------|--------|
| Fix verbose mode bug | **Critical** | Low (2 lines) | High |
| Add validation | High | Medium | High |
| Hugo error detection | Medium | Medium | Medium |
| Improve error messages | Low | Low | Low |

**Recommended Order**:
1. Fix verbose mode bug (immediate, critical)
2. Add validation (prevents future issues)
3. Improve error messages (better UX)
4. Hugo error detection (edge cases)

---

## Testing Strategy

### Test Case 1: Undefined Shortcode
```bash
# Create content with undefined shortcode
mkdir -p /tmp/test-module/content
echo '---
title: Test
---
{{< nonexistent >}}' > /tmp/test-module/content/_index.md

# Build with fixed script
./scripts/build.sh \
  --config /tmp/test-module.json \
  --output /tmp/test-output \
  --content /tmp/test-module/content \
  --verbose

# Expected: Build fails with clear error
# Current: Build succeeds but no HTML generated
```

### Test Case 2: Valid Content
```bash
# Create valid content
mkdir -p /tmp/test-module/content
echo '---
title: Test
---
# Hello World' > /tmp/test-module/content/_index.md

# Build with fixed script
./scripts/build.sh \
  --config /tmp/test-module.json \
  --output /tmp/test-output \
  --content /tmp/test-module/content \
  --verbose

# Expected: Build succeeds, index.html exists
```

### Test Case 3: Missing Theme
```bash
# Build with non-existent theme
./scripts/build.sh \
  --theme nonexistent-theme \
  --output /tmp/test-output

# Expected: Build fails with clear error about missing theme
```

---

## Rollout Strategy

### Phase 1: Fix Critical Bug (Immediate)
- Apply verbose mode fix
- Test with existing builds
- Deploy to main

### Phase 2: Add Validation (Next Release)
- Implement validation function
- Add tests
- Update documentation
- Deploy to main

### Phase 3: Enhance Error Messages (Future)
- Implement improved logging
- Add helpful hints
- Deploy to main

---

## Documentation Updates Needed

### build.sh --help
Update help text to mention:
```
Error Handling:
  The script will exit with non-zero status if:
    - Hugo build fails (in any mode)
    - Critical files are missing (index.html, 404.html)
    - Validation checks fail
```

### README.md
Add troubleshooting section:
```markdown
## Troubleshooting

### Build succeeds but no HTML generated

If build reports success but output directory has no index.html:
1. Check for undefined shortcodes in content
2. Verify theme is correctly specified
3. Run with --verbose flag for detailed output
4. Check build.sh exit code explicitly
```

---

## Related Issues

This bug affected:
- info-tech-io/info-tech-io.github.io#9 (this issue)
- Epic #2 Child #5 (blocked by this bug)
- hugo-templates documentation (failed silently)
- info-tech-cli documentation (failed silently)

---

## Conclusion

The verbose mode bug is a critical issue that causes silent failures in build scripts. The fix is simple (2 lines) but has high impact. All recommendations should be considered for hugo-templates repository improvements.

**Not blocking this Issue**: These recommendations are documented for future discussion with hugo-templates maintainers. Issue #9 is resolved by fixing content, not build scripts.

---

## Next Steps After This Issue

1. ✅ Document these recommendations (this file)
2. ⏳ Discuss with hugo-templates maintainers
3. ⏳ Create separate Issue in hugo-templates repository (optional)
4. ⏳ Submit PR with fixes (optional, not urgent)
5. ⏳ Add to hugo-templates roadmap

---

**Stage Status**: ⏳ Ready After Stage 2
**Dependencies**: Stage 2 complete
**Deliverable**: This recommendations document
**Action Required**: None (for future consideration)
