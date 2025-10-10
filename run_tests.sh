#!/bin/bash

# Test Runner Script for Jarz POS Mobile Application
# This script provides convenient commands for running tests

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to print header
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Display usage information
usage() {
    print_header "Jarz POS Test Runner"
    echo "Usage: ./run_tests.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  all               Run all tests"
    echo "  unit              Run unit tests only"
    echo "  integration       Run integration tests only"
    echo "  coverage          Run tests with coverage report"
    echo "  watch             Run tests in watch mode"
    echo "  core              Run core service tests"
    echo "  features          Run feature tests"
    echo "  auth              Run authentication tests"
    echo "  pos               Run POS tests"
    echo "  kanban            Run kanban tests"
    echo "  services          Run business service tests"
    echo "  clean             Clean test artifacts"
    echo "  help              Display this help message"
    echo ""
    echo "Examples:"
    echo "  ./run_tests.sh all"
    echo "  ./run_tests.sh coverage"
    echo "  ./run_tests.sh auth"
    echo ""
}

# Function to run all tests
run_all_tests() {
    print_header "Running All Tests"
    flutter test
    if [ $? -eq 0 ]; then
        print_success "All tests passed!"
    else
        print_error "Some tests failed!"
        exit 1
    fi
}

# Function to run unit tests
run_unit_tests() {
    print_header "Running Unit Tests"
    flutter test --exclude-tags integration
    if [ $? -eq 0 ]; then
        print_success "All unit tests passed!"
    else
        print_error "Some unit tests failed!"
        exit 1
    fi
}

# Function to run integration tests
run_integration_tests() {
    print_header "Running Integration Tests"
    flutter test test/integration/
    if [ $? -eq 0 ]; then
        print_success "All integration tests passed!"
    else
        print_error "Some integration tests failed!"
        exit 1
    fi
}

# Function to run tests with coverage
run_coverage() {
    print_header "Running Tests with Coverage"
    
    # Run tests with coverage
    flutter test --coverage
    
    if [ $? -eq 0 ]; then
        print_success "Tests completed successfully!"
        
        # Check if lcov is installed
        if command -v lcov &> /dev/null && command -v genhtml &> /dev/null; then
            print_info "Generating HTML coverage report..."
            genhtml coverage/lcov.info -o coverage/html --quiet
            print_success "Coverage report generated at coverage/html/index.html"
            
            # Try to open the report
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open coverage/html/index.html
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                xdg-open coverage/html/index.html 2>/dev/null || echo "Open coverage/html/index.html in your browser"
            else
                print_info "Open coverage/html/index.html in your browser to view the report"
            fi
        else
            print_warning "lcov/genhtml not found. Install it to generate HTML coverage reports."
            print_info "Coverage data saved to coverage/lcov.info"
        fi
    else
        print_error "Tests failed!"
        exit 1
    fi
}

# Function to run tests in watch mode
run_watch() {
    print_header "Running Tests in Watch Mode"
    print_info "Tests will re-run when files change. Press Ctrl+C to stop."
    flutter test --watch
}

# Function to run core tests
run_core_tests() {
    print_header "Running Core Service Tests"
    flutter test test/core/
    if [ $? -eq 0 ]; then
        print_success "Core tests passed!"
    else
        print_error "Core tests failed!"
        exit 1
    fi
}

# Function to run feature tests
run_feature_tests() {
    print_header "Running Feature Tests"
    flutter test test/features/
    if [ $? -eq 0 ]; then
        print_success "Feature tests passed!"
    else
        print_error "Feature tests failed!"
        exit 1
    fi
}

# Function to run auth tests
run_auth_tests() {
    print_header "Running Authentication Tests"
    flutter test test/features/auth/
    if [ $? -eq 0 ]; then
        print_success "Auth tests passed!"
    else
        print_error "Auth tests failed!"
        exit 1
    fi
}

# Function to run POS tests
run_pos_tests() {
    print_header "Running POS Tests"
    flutter test test/features/pos/
    if [ $? -eq 0 ]; then
        print_success "POS tests passed!"
    else
        print_error "POS tests failed!"
        exit 1
    fi
}

# Function to run kanban tests
run_kanban_tests() {
    print_header "Running Kanban Tests"
    flutter test test/features/kanban/
    if [ $? -eq 0 ]; then
        print_success "Kanban tests passed!"
    else
        print_error "Kanban tests failed!"
        exit 1
    fi
}

# Function to run service tests
run_service_tests() {
    print_header "Running Business Service Tests"
    flutter test test/features/cash_transfer/ \
                test/features/stock_transfer/ \
                test/features/manufacturing/ \
                test/features/purchase/ \
                test/features/inventory_count/
    if [ $? -eq 0 ]; then
        print_success "Service tests passed!"
    else
        print_error "Service tests failed!"
        exit 1
    fi
}

# Function to clean test artifacts
clean_tests() {
    print_header "Cleaning Test Artifacts"
    rm -rf coverage/
    rm -rf .dart_tool/test/
    print_success "Test artifacts cleaned!"
}

# Main script logic
case "${1:-all}" in
    all)
        run_all_tests
        ;;
    unit)
        run_unit_tests
        ;;
    integration)
        run_integration_tests
        ;;
    coverage)
        run_coverage
        ;;
    watch)
        run_watch
        ;;
    core)
        run_core_tests
        ;;
    features)
        run_feature_tests
        ;;
    auth)
        run_auth_tests
        ;;
    pos)
        run_pos_tests
        ;;
    kanban)
        run_kanban_tests
        ;;
    services)
        run_service_tests
        ;;
    clean)
        clean_tests
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        print_error "Unknown option: $1"
        echo ""
        usage
        exit 1
        ;;
esac
