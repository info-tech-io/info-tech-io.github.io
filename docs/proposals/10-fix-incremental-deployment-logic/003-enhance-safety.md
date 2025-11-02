# Stage 3: Enhance Merge Safety

**Objective**: >1028BL safety checks 4;O ?@54>B2@0I5=8O ?>B5@8 :>=B5=B0
**Duration**: 0.25 days (2 hours)
**Dependencies**: Stage 2 (build logic fixed)

---

## Overview

065 A ?@028;L=>9 ;>38:>9 build targets, merge >?5@0F88 A `--delete` D;03>< <>3CB 1KBL >?0A=K. 5>1E>48<> 4>1028BL:
1. Pre-merge validation
2. Post-merge integrity checks
3. Clear warnings for unexpected states

---

## Detailed Steps

### Step 3.1: Add Pre-Merge Validation

**Action**: >1028BL ?@>25@:8 ?5@54 merge >?5@0F8O<8

**File**: `.github/workflows/deploy-github-pages.yml` (Atomic Merge section, >:>;> line 346)

**Current Code** (=5157>?0A=K9):
```yaml
# Step 2: Merge corporate site (if built)
if [ "${{ steps.build-targets.outputs.build_corporate }}" = "true" ] && [ -d "corporate-build" ]; then
  echo "=Ë Merging corporate site to root (excluding /docs/)..."
  rsync -av --delete --exclude='docs/' corporate-build/ final-site/
  echo " Corporate site merged"
else
  echo "í  Skipping corporate site merge (not rebuilt)"
fi
```

**New Code** (A validation):
```yaml
# Step 2: Merge corporate site (if built)
if [ "${{ steps.build-targets.outputs.build_corporate }}" = "true" ]; then
  echo "=Ë Preparing to merge corporate site..."

  # Validation: build directory must exist
  if [ ! -d "corporate-build" ]; then
    echo "L ERROR: BUILD_CORPORATE=true but corporate-build/ directory not found!"
    echo "This indicates a build failure that wasn't caught."
    exit 1
  fi

  # Validation: critical files must exist
  if [ ! -f "corporate-build/index.html" ]; then
    echo "L ERROR: Missing corporate-build/index.html!"
    echo "Corporate build is incomplete."
    ls -la corporate-build/ | head -20
    exit 1
  fi

  if [ ! -f "corporate-build/404.html" ]; then
    echo "   WARNING: Missing corporate-build/404.html"
    echo "Continuing, but this might indicate incomplete build."
  fi

  # Show what we're about to merge
  echo "=Ê Corporate build summary:"
  echo "  - Total files: $(find corporate-build -type f | wc -l)"
  echo "  - HTML files: $(find corporate-build -name '*.html' | wc -l)"
  echo "  - Total size: $(du -sh corporate-build | cut -f1)"

  echo "= Merging corporate site to root (excluding /docs/)..."
  rsync -av --delete --exclude='docs/' corporate-build/ final-site/
  echo " Corporate site merged successfully"

else
  echo "í  Skipping corporate site merge (BUILD_CORPORATE=false)"

  # Check if corporate content exists from previous deployment
  if [ -f "final-site/index.html" ]; then
    echo " Corporate site preserved from previous deployment"
    echo "  - Size: $(stat -f%z final-site/index.html 2>/dev/null || stat -c%s final-site/index.html) bytes"
  else
    echo "   WARNING: No corporate index.html in final-site!"
    echo "This is unexpected - final-site should contain previous corporate content."
    echo "Current final-site structure:"
    ls -la final-site/ | head -10
  fi
fi
```

**Verification**:
- [ ] Validation code added
- [ ] Error handling for missing directories
- [ ] Warnings for unexpected states
- [ ] Informative logging

**Success Criteria**:
-  Build failures caught before merge
-  Clear error messages
-  Merge summary logged

---

### Step 3.2: Enhance Documentation Merge Safety

**Action**: >1028BL 0=0;>38G=K5 checks 4;O documentation merge

**Current Code**:
```yaml
# Step 3: Merge documentation (if built)
if [ "${{ steps.build-targets.outputs.build_docs }}" = "true" ] && [ -d "docs-build/docs" ]; then
  echo "=Ë Merging documentation to /docs/..."
  mkdir -p final-site/docs
  rsync -av --delete docs-build/docs/ final-site/docs/
  echo " Documentation merged"
else
  echo "í  Skipping documentation merge (not rebuilt)"
fi
```

**New Code**:
```yaml
# Step 3: Merge documentation (if built)
if [ "${{ steps.build-targets.outputs.build_docs }}" = "true" ]; then
  echo "=Ë Preparing to merge documentation..."

  # Validation: docs directory must exist
  if [ ! -d "docs-build/docs" ]; then
    echo "L ERROR: BUILD_DOCS=true but docs-build/docs/ directory not found!"
    echo "This indicates a docs build failure."
    exit 1
  fi

  # Validate each product documentation
  products=("quiz" "hugo-templates" "web-terminal" "info-tech-cli")
  MISSING_COUNT=0

  for product in "${products[@]}"; do
    if [ ! -f "docs-build/docs/$product/index.html" ]; then
      echo "L ERROR: Missing docs-build/docs/$product/index.html"
      MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
  done

  if [ $MISSING_COUNT -gt 0 ]; then
    echo "L ERROR: $MISSING_COUNT documentation products missing index.html"
    echo "Cannot deploy incomplete documentation."
    exit 1
  fi

  # Show what we're about to merge
  echo "=Ê Documentation build summary:"
  for product in "${products[@]}"; do
    file_count=$(find "docs-build/docs/$product" -type f | wc -l)
    echo "  - $product: $file_count files"
  done

  echo "= Merging documentation to /docs/..."
  mkdir -p final-site/docs
  rsync -av --delete docs-build/docs/ final-site/docs/
  echo " Documentation merged successfully"

else
  echo "í  Skipping documentation merge (BUILD_DOCS=false)"

  # Check if docs exist from previous deployment
  if [ -d "final-site/docs" ]; then
    echo " Documentation preserved from previous deployment"
    product_count=$(find final-site/docs -mindepth 1 -maxdepth 1 -type d | wc -l)
    echo "  - Products: $product_count directories"
  else
    echo "   WARNING: No /docs/ directory in final-site!"
    echo "This might indicate missing previous deployment data."
  fi
fi
```

**Success Criteria**:
-  All products validated before merge
-  Missing index.html caught
-  Summary logged

---

### Step 3.3: Add Post-Merge Integrity Check

**Action**: !>740BL =>2K9 step 4;O verification ?>A;5 merge

**Implementation**:

Add new step after "Atomic Merge - Combine All Content":

```yaml
- name: Verify Merge Integrity
  run: |
    echo "= Verifying merged content integrity..."
    echo ""

    ERRORS=0
    WARNINGS=0

    # Check 1: Corporate site critical files
    echo "=== Corporate Site Checks ==="
    if [ -f "final-site/index.html" ]; then
      size=$(stat -f%z final-site/index.html 2>/dev/null || stat -c%s final-site/index.html)
      echo " index.html present ($size bytes)"
    else
      echo "L index.html MISSING"
      ERRORS=$((ERRORS + 1))
    fi

    if [ -f "final-site/404.html" ]; then
      echo " 404.html present"
    else
      echo "   404.html missing"
      WARNINGS=$((WARNINGS + 1))
    fi

    # Check 2: Documentation directory
    echo ""
    echo "=== Documentation Checks ==="
    if [ -d "final-site/docs" ]; then
      echo " /docs/ directory exists"

      # Check hub index
      if [ -f "final-site/docs/index.html" ]; then
        echo " /docs/index.html present"
      else
        echo "   /docs/index.html missing"
        WARNINGS=$((WARNINGS + 1))
      fi

      # Check each product
      products=("quiz" "hugo-templates" "web-terminal" "info-tech-cli")
      for product in "${products[@]}"; do
        if [ -f "final-site/docs/$product/index.html" ]; then
          size=$(stat -f%z "final-site/docs/$product/index.html" 2>/dev/null || stat -c%s "final-site/docs/$product/index.html")
          echo " $product: index.html present ($size bytes)"
        else
          echo "L $product: index.html MISSING"
          ERRORS=$((ERRORS + 1))
        fi
      done
    else
      echo "L /docs/ directory MISSING"
      ERRORS=$((ERRORS + 1))
    fi

    # Summary
    echo ""
    echo "=== Integrity Check Summary ==="
    echo "  - Errors: $ERRORS"
    echo "  - Warnings: $WARNINGS"
    echo ""

    if [ $ERRORS -gt 0 ]; then
      echo "L MERGE INTEGRITY CHECK FAILED"
      echo "Cannot proceed with deployment - content is incomplete."
      echo ""
      echo "Final-site structure:"
      find final-site -type f -name "index.html"
      exit 1
    fi

    if [ $WARNINGS -gt 0 ]; then
      echo "   Merge completed with $WARNINGS warnings"
      echo "Review logs for potential issues."
    else
      echo " Merge integrity check passed - all critical files present"
    fi
```

**Success Criteria**:
-  All critical files verified
-  Errors block deployment
-  Warnings logged but don't block

---

### Step 3.4: Update Workflow File

**Action**: Apply all safety enhancements

**Implementation**:
```bash
cd /root/info-tech-io/info-tech-io.github.io

# Edit workflow
vim .github/workflows/deploy-github-pages.yml

# Apply changes from Steps 3.1, 3.2, 3.3

# Review changes
git diff .github/workflows/deploy-github-pages.yml
```

---

### Step 3.5: Commit Safety Enhancements

**Implementation**:
```bash
git add .github/workflows/deploy-github-pages.yml

git commit -m "feat(workflow): add comprehensive merge safety checks

Add validation and integrity checks to prevent content loss during
atomic merge operations.

Safety enhancements:
1. Pre-merge validation
   - Verify build directories exist when expected
   - Check critical files present (index.html, 404.html)
   - Log build summaries before merge

2. Enhanced logging
   - Warn when expected content is missing
   - Show preservation of previous deployment content
   - Log file counts and sizes

3. Post-merge integrity check
   - Verify all critical files in final-site
   - Check corporate site files
   - Validate all 4 documentation products
   - Block deployment if any critical files missing

These checks ensure:
- Build failures caught before merge
- Incomplete builds don't deploy
- Previous content preserved correctly
- Clear errors for debugging

Related: #10, Epic: #2, Stage: 3
Implements: Stage 3 of Issue #10"

git push origin main
```

---

## Testing Plan

Will be tested in Stage 4:
- Trigger deployment with missing files (should fail)
- Trigger incremental deployment (should preserve content)
- Verify all checks execute correctly

---

## Rollback Plan

Same as Stage 2 - revert commit if issues occur.

---

## Definition of Done

- [ ] Pre-merge validation added for corporate site
- [ ] Pre-merge validation added for documentation
- [ ] Post-merge integrity check created
- [ ] All checks tested locally
- [ ] Workflow updated
- [ ] Changes committed
- [ ] Ready for Stage 4 (testing)

---

**Stage Status**: ó Ready After Stage 2
**Dependencies**: Stage 2 complete
**Blocks**: Stage 4
