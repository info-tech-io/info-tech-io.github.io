#!/bin/bash
# Custom Domain Validation Scripts - Epic #12
# Purpose: Comprehensive validation of docs.infotecha.ru custom domain setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CUSTOM_DOMAIN="docs.infotecha.ru"
GITHUB_DOMAIN="info-tech.github.io"
OLD_GITHUB_DOMAIN="info-tech-io.github.io"
LOG_FILE="/tmp/domain-validation-$(date +%Y%m%d-%H%M%S).log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Success/Error functions
success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}ℹ️ $1${NC}" | tee -a "$LOG_FILE"
}

# DNS Resolution Validation
validate_dns_resolution() {
    log "=== DNS Resolution Validation ==="

    info "Testing DNS resolution for $CUSTOM_DOMAIN..."

    # Test basic DNS resolution
    if nslookup "$CUSTOM_DOMAIN" &>/dev/null; then
        success "DNS resolution working"

        # Get resolved IP
        resolved_ip=$(nslookup "$CUSTOM_DOMAIN" | grep -A 2 "Name:" | tail -n 1 | awk '{print $2}' 2>/dev/null || echo "Unknown")
        info "Resolved to: $resolved_ip"
    else
        error "DNS resolution failed"
        return 1
    fi

    # Test CNAME record
    info "Testing CNAME record..."
    cname_target=$(dig +short "$CUSTOM_DOMAIN" CNAME 2>/dev/null | sed 's/\.$//')

    if [[ -n "$cname_target" ]]; then
        success "CNAME record found: $CUSTOM_DOMAIN → $cname_target"

        # Validate CNAME target
        if [[ "$cname_target" == "$GITHUB_DOMAIN" ]] || [[ "$cname_target" == "$OLD_GITHUB_DOMAIN" ]]; then
            success "CNAME target is correct GitHub domain"
        else
            warning "CNAME target may be incorrect: $cname_target"
        fi
    else
        warning "No CNAME record found, checking A records..."

        # Test A records
        a_records=$(dig +short "$CUSTOM_DOMAIN" A 2>/dev/null)
        if [[ -n "$a_records" ]]; then
            success "A records found:"
            echo "$a_records" | while read -r ip; do
                info "  → $ip"
            done
        else
            error "No A or CNAME records found"
            return 1
        fi
    fi

    # Test global DNS propagation
    info "Testing global DNS propagation..."
    dns_servers=("8.8.8.8" "1.1.1.1" "208.67.222.222" "9.9.9.9")
    success_count=0

    for server in "${dns_servers[@]}"; do
        if nslookup "$CUSTOM_DOMAIN" "$server" &>/dev/null; then
            success "DNS propagated to $server"
            ((success_count++))
        else
            warning "DNS not yet propagated to $server"
        fi
    done

    if [[ $success_count -ge 3 ]]; then
        success "DNS propagation looks good ($success_count/4 servers)"
    else
        warning "DNS propagation incomplete ($success_count/4 servers)"
    fi

    echo "" | tee -a "$LOG_FILE"
}

# HTTPS Access Validation
validate_https_access() {
    log "=== HTTPS Access Validation ==="

    info "Testing HTTPS access to $CUSTOM_DOMAIN..."

    # Test HTTPS connectivity
    http_status=$(curl -s -o /dev/null -w "%{http_code}" "https://$CUSTOM_DOMAIN/" --connect-timeout 10 --max-time 30 2>/dev/null || echo "000")

    if [[ "$http_status" == "200" ]]; then
        success "HTTPS access working (HTTP $http_status)"
    elif [[ "$http_status" == "000" ]]; then
        error "HTTPS connection failed"
        return 1
    else
        warning "HTTPS returned unexpected status: $http_status"
    fi

    # Test response headers
    info "Checking response headers..."
    response_headers=$(curl -I "https://$CUSTOM_DOMAIN/" --connect-timeout 10 --max-time 30 2>/dev/null)

    if echo "$response_headers" | grep -qi "github.com\|github"; then
        success "Response indicates GitHub Pages hosting"
    else
        warning "Response headers don't clearly indicate GitHub Pages"
    fi

    # Test SSL certificate
    info "Testing SSL certificate..."
    cert_info=$(echo | openssl s_client -servername "$CUSTOM_DOMAIN" -connect "$CUSTOM_DOMAIN":443 2>/dev/null | openssl x509 -noout -subject -dates -issuer 2>/dev/null)

    if [[ -n "$cert_info" ]]; then
        success "SSL certificate retrieved successfully"

        # Check certificate validity
        not_after=$(echo "$cert_info" | grep "notAfter" | sed 's/notAfter=//')
        if [[ -n "$not_after" ]]; then
            info "Certificate expires: $not_after"

            # Check if certificate expires in next 30 days
            exp_timestamp=$(date -d "$not_after" +%s 2>/dev/null || echo "0")
            current_timestamp=$(date +%s)
            days_until_expiry=$(( (exp_timestamp - current_timestamp) / 86400 ))

            if [[ $days_until_expiry -gt 30 ]]; then
                success "Certificate expires in $days_until_expiry days"
            elif [[ $days_until_expiry -gt 0 ]]; then
                warning "Certificate expires soon: $days_until_expiry days"
            else
                error "Certificate has expired or invalid date"
            fi
        fi

        # Check certificate issuer
        issuer=$(echo "$cert_info" | grep "issuer" | sed 's/issuer= //')
        if echo "$issuer" | grep -qi "let's encrypt"; then
            success "Certificate issued by Let's Encrypt (expected for GitHub Pages)"
        else
            info "Certificate issuer: $issuer"
        fi
    else
        error "Failed to retrieve SSL certificate"
        return 1
    fi

    echo "" | tee -a "$LOG_FILE"
}

# Content Validation
validate_content_accessibility() {
    log "=== Content Accessibility Validation ==="

    info "Testing documentation content accessibility..."

    # Test main page content
    main_content=$(curl -s "https://$CUSTOM_DOMAIN/" --connect-timeout 10 --max-time 30 2>/dev/null)

    if echo "$main_content" | grep -qi "infotecha\|documentation\|github pages"; then
        success "Main documentation page content found"
    else
        error "Main documentation page content missing or invalid"
        return 1
    fi

    # Test federated content paths
    federated_paths=("/quiz/" "/hugo-templates/" "/cli/" "/web-terminal/")
    success_count=0

    info "Testing federated documentation paths..."
    for path in "${federated_paths[@]}"; do
        full_url="https://$CUSTOM_DOMAIN$path"
        status=$(curl -s -o /dev/null -w "%{http_code}" "$full_url" --connect-timeout 10 --max-time 15 2>/dev/null || echo "000")

        if [[ "$status" == "200" ]]; then
            success "Federated path accessible: $path (HTTP $status)"
            ((success_count++))
        elif [[ "$status" == "404" ]]; then
            info "Federated path not found: $path (HTTP $status) - may be expected"
        else
            warning "Federated path issue: $path (HTTP $status)"
        fi
    done

    if [[ $success_count -gt 0 ]]; then
        success "Federated content accessibility: $success_count/${#federated_paths[@]} paths working"
    else
        warning "No federated paths accessible - may indicate configuration issue"
    fi

    # Test search functionality (if available)
    info "Testing search functionality..."
    search_url="https://$CUSTOM_DOMAIN/search/?q=test"
    search_status=$(curl -s -o /dev/null -w "%{http_code}" "$search_url" --connect-timeout 10 --max-time 15 2>/dev/null || echo "000")

    if [[ "$search_status" == "200" ]]; then
        success "Search functionality accessible"
    else
        info "Search not accessible or not implemented (HTTP $search_status)"
    fi

    echo "" | tee -a "$LOG_FILE"
}

# Performance Validation
validate_performance() {
    log "=== Performance Validation ==="

    info "Testing page load performance..."

    # Create curl timing format
    curl_format="time_namelookup:  %{time_namelookup}\n"
    curl_format+="time_connect:     %{time_connect}\n"
    curl_format+="time_appconnect:  %{time_appconnect}\n"
    curl_format+="time_pretransfer: %{time_pretransfer}\n"
    curl_format+="time_redirect:    %{time_redirect}\n"
    curl_format+="time_starttransfer: %{time_starttransfer}\n"
    curl_format+="----------\n"
    curl_format+="time_total:       %{time_total}\n"

    # Test performance
    perf_output=$(curl -w "$curl_format" -o /dev/null -s "https://$CUSTOM_DOMAIN/" --connect-timeout 15 --max-time 30 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        total_time=$(echo "$perf_output" | grep "time_total" | awk '{print $2}')

        if [[ -n "$total_time" ]]; then
            # Convert to milliseconds for easier reading
            total_ms=$(echo "$total_time * 1000" | bc 2>/dev/null || echo "unknown")

            if [[ "$total_ms" != "unknown" ]]; then
                if (( $(echo "$total_time < 3.0" | bc -l) )); then
                    success "Page load time: ${total_ms}ms (good)"
                elif (( $(echo "$total_time < 5.0" | bc -l) )); then
                    warning "Page load time: ${total_ms}ms (acceptable)"
                else
                    error "Page load time: ${total_ms}ms (too slow)"
                fi

                info "Performance breakdown:"
                echo "$perf_output" | tee -a "$LOG_FILE"
            else
                info "Performance test completed but timing calculation failed"
            fi
        else
            warning "Performance test completed but no timing data"
        fi
    else
        error "Performance test failed"
    fi

    echo "" | tee -a "$LOG_FILE"
}

# Redirect Validation
validate_redirects() {
    log "=== Redirect Validation ==="

    info "Testing GitHub automatic redirects..."

    # Test old GitHub domain redirect
    if curl -I "https://$OLD_GITHUB_DOMAIN/" --connect-timeout 10 --max-time 15 &>/dev/null; then
        redirect_status=$(curl -s -o /dev/null -w "%{http_code}" "https://$OLD_GITHUB_DOMAIN/" --connect-timeout 10 --max-time 15)
        redirect_location=$(curl -I "https://$OLD_GITHUB_DOMAIN/" --connect-timeout 10 --max-time 15 2>/dev/null | grep -i "location:" | awk '{print $2}' | tr -d '\r')

        if [[ "$redirect_status" == "301" ]] || [[ "$redirect_status" == "302" ]]; then
            success "GitHub automatic redirect working (HTTP $redirect_status)"
            if [[ -n "$redirect_location" ]]; then
                info "Redirects to: $redirect_location"
            fi
        elif [[ "$redirect_status" == "200" ]]; then
            warning "Old domain still serving content directly (no redirect)"
        else
            warning "Old domain returned unexpected status: $redirect_status"
        fi
    else
        warning "Cannot test old domain redirects (connection failed)"
    fi

    # Test new GitHub domain accessibility
    new_status=$(curl -s -o /dev/null -w "%{http_code}" "https://$GITHUB_DOMAIN/" --connect-timeout 10 --max-time 15 2>/dev/null || echo "000")

    if [[ "$new_status" == "200" ]]; then
        success "New GitHub domain accessible (HTTP $new_status)"
    elif [[ "$new_status" == "000" ]]; then
        warning "New GitHub domain not accessible (may not be migrated yet)"
    else
        warning "New GitHub domain returned status: $new_status"
    fi

    echo "" | tee -a "$LOG_FILE"
}

# Comprehensive validation function
validate_all() {
    log "=== Custom Domain Comprehensive Validation ==="
    log "Started: $(date)"
    log "Domain: $CUSTOM_DOMAIN"
    log "Log file: $LOG_FILE"
    echo "" | tee -a "$LOG_FILE"

    local validation_failed=false

    # Run all validations
    validate_dns_resolution || validation_failed=true
    validate_https_access || validation_failed=true
    validate_content_accessibility || validation_failed=true
    validate_performance || validation_failed=true
    validate_redirects || validation_failed=true

    # Summary
    log "=== Validation Summary ==="
    if [[ "$validation_failed" == "false" ]]; then
        success "All validations completed successfully"
        success "Custom domain is ready for production use"
    else
        warning "Some validations failed or had warnings"
        warning "Review the log for details and address issues"
    fi

    log "Completed: $(date)"
    log "Log file saved: $LOG_FILE"
    echo ""
    info "Full log available at: $LOG_FILE"
}

# Quick validation for monitoring
quick_validate() {
    local result=0

    # Quick DNS test
    if ! nslookup "$CUSTOM_DOMAIN" &>/dev/null; then
        echo "❌ DNS resolution failed"
        result=1
    fi

    # Quick HTTPS test
    local http_status=$(curl -s -o /dev/null -w "%{http_code}" "https://$CUSTOM_DOMAIN/" --connect-timeout 5 --max-time 10 2>/dev/null || echo "000")
    if [[ "$http_status" != "200" ]]; then
        echo "❌ HTTPS access failed (HTTP $http_status)"
        result=1
    fi

    if [[ $result -eq 0 ]]; then
        echo "✅ Quick validation passed"
    fi

    return $result
}

# Monitor function for continuous checking
monitor() {
    local interval=${1:-300}  # Default 5 minutes
    local max_failures=${2:-3}  # Max consecutive failures before alert
    local failure_count=0

    echo "Starting monitoring of $CUSTOM_DOMAIN (checking every ${interval} seconds)"
    echo "Maximum consecutive failures before alert: $max_failures"
    echo "Press Ctrl+C to stop"
    echo ""

    while true; do
        echo -n "$(date '+%Y-%m-%d %H:%M:%S'): "

        if quick_validate; then
            failure_count=0
        else
            ((failure_count++))
            if [[ $failure_count -ge $max_failures ]]; then
                echo "🚨 ALERT: $failure_count consecutive failures detected!"
                echo "🚨 Custom domain may require immediate attention!"
                # Here you could send alerts, notifications, etc.
            fi
        fi

        sleep "$interval"
    done
}

# Help function
show_help() {
    cat << EOF
Custom Domain Validation Scripts - Epic #12

Usage: $0 [COMMAND]

Commands:
    validate-all     Run comprehensive validation (default)
    quick           Quick validation check
    dns             DNS resolution validation only
    https           HTTPS access validation only
    content         Content accessibility validation only
    performance     Performance validation only
    redirects       Redirect validation only
    monitor [SECS]  Continuous monitoring (default: 300 seconds)
    help            Show this help message

Examples:
    $0                    # Run full validation
    $0 quick              # Quick check
    $0 monitor 60         # Monitor every minute
    $0 dns                # Check DNS only

Environment Variables:
    CUSTOM_DOMAIN         Custom domain to validate (default: docs.infotecha.ru)
    GITHUB_DOMAIN         New GitHub domain (default: info-tech.github.io)
    OLD_GITHUB_DOMAIN     Old GitHub domain (default: info-tech-io.github.io)

EOF
}

# Main execution
case "${1:-validate-all}" in
    "validate-all"|"all"|"")
        validate_all
        ;;
    "quick"|"q")
        quick_validate
        ;;
    "dns")
        validate_dns_resolution
        ;;
    "https"|"ssl")
        validate_https_access
        ;;
    "content")
        validate_content_accessibility
        ;;
    "performance"|"perf")
        validate_performance
        ;;
    "redirects"|"redirect")
        validate_redirects
        ;;
    "monitor")
        monitor "${2:-300}" "${3:-3}"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac