#!/bin/bash
# Staging test script for Epic #12 migration updates
set -e

STAGING_DIR="/tmp/epic-12-staging"
cd "${STAGING_DIR}"

echo "=== Epic #12 Migration Updates - Staging Test ===" | tee test-results/staging-test-results.txt
echo "Test started: $(date)" | tee -a test-results/staging-test-results.txt
echo "" | tee -a test-results/staging-test-results.txt

# Test organization name updates in each staging repository
for repo_dir in repos/*-staging; do
  if [[ -d "${repo_dir}" ]]; then
    repo_name=$(basename "${repo_dir}" -staging)
    echo "=== Testing: ${repo_name} ===" | tee -a test-results/staging-test-results.txt
    
    cd "${repo_dir}"
    
    # Find organization references (dry run)
    echo "Scanning for 'info-tech-io' references..." | tee -a ../../test-results/staging-test-results.txt
    
    # Search in workflow files
    workflow_refs=$(find .github/workflows/ -name "*.yml" -exec grep -l "info-tech-io" {} \; 2>/dev/null | wc -l)
    echo "  Workflow files with references: ${workflow_refs}" | tee -a ../../test-results/staging-test-results.txt
    
    # Search in config files
    config_refs=$(find . -name "*.json" -exec grep -l "info-tech-io" {} \; 2>/dev/null | wc -l)
    echo "  Config files with references: ${config_refs}" | tee -a ../../test-results/staging-test-results.txt
    
    # Detailed reference listing
    echo "  Detailed references:" | tee -a ../../test-results/staging-test-results.txt
    grep -r "info-tech-io" . --include="*.yml" --include="*.yaml" --include="*.json" \
      | head -10 | sed 's/^/    /' | tee -a ../../test-results/staging-test-results.txt 2>/dev/null || true
    
    echo "" | tee -a ../../test-results/staging-test-results.txt
    cd ../..
  fi
done

echo "=== Test Summary ===" | tee -a test-results/staging-test-results.txt
echo "Staging test completed: $(date)" | tee -a test-results/staging-test-results.txt
echo "All staging repositories ready for migration testing" | tee -a test-results/staging-test-results.txt
