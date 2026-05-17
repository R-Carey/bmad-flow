#!/bin/zsh

# ============================================================================
# BMAD Flow - Workflow Automation Script
# ============================================================================
# Automates the BMAD-METHOD development cycle for any project
# Supports: create-story, dev-story, code-review, epic processing, retrospectives
# Documentation: See docs/BMAD-WORKFLOWS.md for detailed usage
# ============================================================================

BMAD_FLOW_VERSION="1.5.0"

set -e

# Load configuration from bmad-config.sh if it exists
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/bmad-config.sh" ]; then
    source "$SCRIPT_DIR/bmad-config.sh"
else
    echo "Warning: bmad-config.sh not found, using defaults"
fi

# Set defaults if not configured
: ${BMAD_CLAUDE_BIN:="claude"}
: ${BMAD_COPILOT_BIN:="copilot"}
: ${BMAD_CREATE_CLI:="claude"}
: ${BMAD_CREATE_MODEL:="sonnet"}
: ${BMAD_DEV_CLI:="claude"}
: ${BMAD_DEV_MODEL:="claude-sonnet-4-6"}
: ${BMAD_REVIEW_CLI:="copilot"}
: ${BMAD_REVIEW_MODEL:="gpt-5.3-codex"}
: ${BMAD_STATUS_FILE:="_bmad-output/implementation-artifacts/sprint-status.yaml"}
: ${BMAD_APP_NOUN:="app"}
: ${BMAD_TEST_FILE_PATTERN:=""}
: ${BMAD_TEST_RUN_INSTRUCTIONS:=""}
: ${BMAD_TEST_PASS_INDICATOR:=""}
: ${BMAD_TEST_FAIL_INDICATOR:=""}
: ${BMAD_GIT_COAUTHOR:=""}
: ${BMAD_TEST_CMD:=""}
: ${BMAD_STORIES_DIR:="_bmad-output/implementation-artifacts"}

# Use config values
CLAUDE_BIN="$BMAD_CLAUDE_BIN"
COPILOT_BIN="$BMAD_COPILOT_BIN"
DEFAULT_CREATE_CLI="$BMAD_CREATE_CLI"
DEFAULT_CREATE_MODEL="$BMAD_CREATE_MODEL"
DEFAULT_DEV_CLI="$BMAD_DEV_CLI"
DEFAULT_DEV_MODEL="$BMAD_DEV_MODEL"
DEFAULT_REVIEW_CLI="$BMAD_REVIEW_CLI"
DEFAULT_REVIEW_MODEL="$BMAD_REVIEW_MODEL"
STATUS_FILE="$BMAD_STATUS_FILE"
STORIES_DIR="$BMAD_STORIES_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Progress bar characters
FILLED='█'
EMPTY='░'

# Function to update story status in sprint-status.yaml
update_status() {
    local story_key=$1
    local new_status=$2
    
    echo -e "${BLUE}Updating status: ${story_key} → ${new_status}${NC}"
    
    # Use sed to update the status (macOS compatible)
    # Match story key as prefix, then replace everything after the colon
    sed -i '' "/^  ${story_key}[^:]*:/s/:.*$/: ${new_status}/" "$STATUS_FILE"
}

# Function to get current story status
get_status() {
    local story_key=$1
    # Match the story key as a prefix (handles both "2-7" and full "2-7-three-resolution-types")
    grep "^  ${story_key}[:-]" "$STATUS_FILE" 2>/dev/null | awk '{print $2}'
}

# Function to check if git working directory is clean
check_git_clean() {
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "${RED}⚠ Warning: Git working directory has uncommitted changes${NC}"
        echo -e "${YELLOW}This may cause conflicts with automated commits${NC}"
        
        # Check if we're in an interactive terminal
        if [[ -t 0 ]]; then
            read -q "REPLY?Continue anyway? (y/n) "
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${RED}Aborted${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}Non-interactive mode: Continuing anyway...${NC}"
        fi
    fi
}

# Function to validate story file exists
validate_story_file() {
    local story_key=$1
    
    # Find story file by prefix (e.g., "2-7" matches "2-7-three-resolution-types.md")
    local story_file=$(ls "${STORIES_DIR}/${story_key}"*.md 2>/dev/null | head -1)
    
    if [ -z "$story_file" ] || [ ! -f "$story_file" ]; then
        echo -e "${RED}✗ Story file not found: ${STORIES_DIR}/${story_key}*.md${NC}"
        echo -e "${YELLOW}Run: ./bmad.sh create-story ${story_key}${NC}"
        return 1
    fi
    return 0
}

# Function to validate project artifacts (extensible per tech stack)
validate_project_artifacts() {
    local story_key=$1
    local story_file=$(ls "${STORIES_DIR}/${story_key}"*.md 2>/dev/null | head -1)

    echo -e "${BLUE}Validating project artifacts...${NC}"

    if [ -z "$story_file" ]; then
        echo -e "${YELLOW}⚠ No story file found to validate artifacts${NC}"
        return 0
    fi

    # Build extension grep pattern from BMAD_FILE_EXTENSIONS (e.g. ".gd .tscn .tres")
    local ext_grep=""
    if [ -n "${BMAD_FILE_EXTENSIONS:-}" ]; then
        # Convert ".gd .tscn .tres" → "\.(gd|tscn|tres)"
        ext_grep=$(echo "$BMAD_FILE_EXTENSIONS" | \
            tr ' ' '\n' | sed 's/^\.//' | tr '\n' '|' | sed 's/|$//')
    else
        # Fallback: common source/config extensions
        ext_grep="gd|tscn|tres|js|ts|py|rb|dart|cs|vue|jsx|tsx"
    fi

    # Extract file-like references from the story
    local file_refs
    file_refs=$(grep -oE "[a-zA-Z0-9_./-]+\.(${ext_grep})" "$story_file" 2>/dev/null \
        | sort -u | head -25)

    if [ -z "$file_refs" ]; then
        echo -e "${YELLOW}⚠ No file references detected in story — skipping artifact check${NC}"
        return 0
    fi

    local found=0 missing=0
    echo -e "${CYAN}Referenced files:${NC}"
    while IFS= read -r f; do
        if [ -f "$f" ]; then
            echo -e "  ${GREEN}✓${NC} ${f}"
            found=$((found + 1))
        else
            echo -e "  ${YELLOW}·${NC} ${f} ${YELLOW}(not yet created)${NC}"
            missing=$((missing + 1))
        fi
    done <<< "$file_refs"

    echo ""
    if [ $found -gt 0 ]; then
        echo -e "${GREEN}✓ ${found} artifact(s) present, ${missing} pending creation${NC}"
    else
        echo -e "${YELLOW}⚠ All referenced files are pending (expected before dev-story runs)${NC}"
    fi
}

# Function to draw progress bar
draw_progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    echo -n "["
    for ((i=0; i<filled; i++)); do echo -n "${FILLED}"; done
    for ((i=0; i<empty; i++)); do echo -n "${EMPTY}"; done
    echo "] ${percentage}% (${current}/${total})"
}

# Function to get all stories for an epic
get_epic_stories() {
    local epic_num=$1
    grep "^  ${epic_num}-[0-9]" "$STATUS_FILE" | awk '{print $1}' | sed 's/:$//' | sort -V
}

# Function to count stories by status
count_stories_by_status() {
    local epic_num=$1
    local target_status=$2
    get_epic_stories "$epic_num" | while read story; do
        local story_status=$(get_status "$story")
        if [ "$story_status" = "$target_status" ]; then
            echo "$story"
        fi
    done | wc -l | tr -d ' '
}

# Function to display epic status
show_epic_status() {
    local epic_num=$1
    local epic_status=$(get_status "epic-${epic_num}")
    
    echo -e "\n${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║              Epic ${epic_num} Status Overview                     ║${NC}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${CYAN}Epic Status:${NC} ${epic_status}"
    echo ""
    
    local total=$(get_epic_stories "$epic_num" | wc -l | tr -d ' ')
    local done=$(count_stories_by_status "$epic_num" "done")
    local review=$(count_stories_by_status "$epic_num" "review")
    local in_progress=$(count_stories_by_status "$epic_num" "in-progress")
    local ready=$(count_stories_by_status "$epic_num" "ready-for-dev")
    local backlog=$(count_stories_by_status "$epic_num" "backlog")
    
    echo -e "${GREEN}✓ Done:${NC}        $done stories"
    echo -e "${MAGENTA}⊙ Review:${NC}      $review stories"
    echo -e "${YELLOW}◉ In Progress:${NC} $in_progress stories"
    echo -e "${BLUE}○ Ready:${NC}       $ready stories"
    echo -e "${CYAN}· Backlog:${NC}     $backlog stories"
    echo -e "${BOLD}  Total:${NC}       $total stories"
    echo ""
    
    echo -e "${CYAN}Progress:${NC}"
    draw_progress_bar "$done" "$total"
    echo ""
    
    echo -e "${CYAN}Stories by Status:${NC}"
    echo ""
    
    get_epic_stories "$epic_num" | while read story; do
        local story_status=$(get_status "$story")
        local icon=""
        local color=""
        
        case $story_status in
            done) icon="✓"; color=$GREEN ;;
            review) icon="⊙"; color=$MAGENTA ;;
            in-progress) icon="◉"; color=$YELLOW ;;
            ready-for-dev) icon="○"; color=$BLUE ;;
            backlog) icon="·"; color=$CYAN ;;
        esac
        
        echo -e "  ${color}${icon} ${story}${NC} (${story_status})"
    done
    echo ""
}

# Function to show a progress spinner with periodic updates
show_progress() {
    local pid=$1
    local delay=0.5
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local elapsed=0
    local last_update=0
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [${CYAN}%c${NC}] Working... (%ds elapsed)\r" "$spinstr" $elapsed
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        elapsed=$((elapsed + 1))
        
        # Print periodic status update every 30 seconds
        if [ $((elapsed % 60)) -eq 0 ] && [ $elapsed -ne $last_update ]; then
            printf "\n"
            echo -e "${YELLOW}⏱  Still working... ${elapsed}s elapsed (this is normal for complex tasks)${NC}"
            last_update=$elapsed
        fi
        
        # Warning after 20 minutes
        if [ $elapsed -eq 1200 ]; then
            printf "\n"
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}⚠️  WARNING: 20 minutes elapsed - AI might be stuck${NC}"
            echo -e "${CYAN}What to do:${NC}"
            echo -e "  1. Press ${BOLD}Ctrl+C${NC} to interrupt"
            echo -e "  2. Run: ${BOLD}git status${NC} to see what was done"
            echo -e "  3. Check if files were modified/created"
            echo -e "  4. If work looks complete:"
            echo -e "     • Continue manually: ${BOLD}./bmad.sh <next-phase> <story-key>${NC}"
            echo -e "  5. If work incomplete:"
            echo -e "     • Retry: ${BOLD}./bmad.sh <same-command> <story-key>${NC}"
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            printf "\n"
        fi
    done
    printf "                                                    \r"
}

# Session usage log
USAGE_LOG="/tmp/bmad-usage-session-$(date +%Y-%m-%d).log"

# Function to parse and display token/request usage from AI output
show_usage_stats() {
    local output_file=$1
    local tokens_line=$(grep -i "Tokens\|tokens" "$output_file" 2>/dev/null | grep -i "↑\|input\|cached" | tail -1)
    local requests_line=$(grep -i "Requests\|requests\|Premium" "$output_file" 2>/dev/null | tail -1)
    
    if [ -n "$tokens_line" ] || [ -n "$requests_line" ]; then
        echo ""
        echo -e "${BLUE}┌─ Usage ───────────────────────────────────────────────┐${NC}"
        [ -n "$tokens_line" ] && echo -e "${BLUE}│${NC} ${tokens_line}"
        [ -n "$requests_line" ] && echo -e "${BLUE}│${NC} ${requests_line}"
        echo -e "${BLUE}└───────────────────────────────────────────────────────┘${NC}"
        
        # Log usage to session file for cumulative tracking
        echo "$(date +%H:%M:%S) | ${COMMAND:-unknown} ${STORY_KEY:-} | ${tokens_line} ${requests_line}" >> "$USAGE_LOG"
    fi
}

# Function to show cumulative session usage
show_session_usage() {
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║              Session Usage Summary                        ║${NC}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}\n"
    
    if [ ! -f "$USAGE_LOG" ]; then
        echo -e "${YELLOW}No usage data yet today. Run a command to start tracking.${NC}"
        return
    fi
    
    local call_count=$(wc -l < "$USAGE_LOG" | tr -d ' ')
    echo -e "${CYAN}Today's AI calls:${NC} ${call_count}"
    echo ""
    echo -e "${CYAN}Call History:${NC}"
    echo -e "${BLUE}─────────────────────────────────────────────────────────────${NC}"
    
    while IFS= read -r line; do
        echo -e "  ${line}"
    done < "$USAGE_LOG"
    
    echo -e "${BLUE}─────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${YELLOW}💡 Tips to reduce token usage:${NC}"
    echo -e "  • Use --model sonnet for simple tasks (create-story)"
    echo -e "  • Save opus/codex for complex implementation"
    echo -e "  • Run 'code-review' with a different model than 'dev-story'"
    echo ""
}

# Function to highlight important messages the AI flagged for the user
show_important_messages() {
    local output_file=$1
    if grep -qi "MANUAL:\|test.*yourself\|you should.*test\|STOP\|cannot.*complete\|unable to\|requires.*user\|please check\|please test\|please verify" "$output_file" 2>/dev/null; then
        echo ""
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}📋 IMPORTANT: Items that need your attention:${NC}"
        grep -i "MANUAL:\|test.*yourself\|you should.*test\|STOP\|cannot.*complete\|unable to\|requires.*user\|please check\|please test\|please verify" "$output_file" 2>/dev/null | head -5
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi
}

# Function to extract and display story-specific test guidance before the test pause
show_story_test_hints() {
    local story_key=$1
    local story_file=$(ls "${STORIES_DIR}/${story_key}"*.md 2>/dev/null | head -1)

    echo -e "\n${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${YELLOW}📋  WHAT TO TEST — Story ${story_key}${NC}"
    echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    if [ -z "$story_file" ]; then
        echo -e "${YELLOW}⚠  No story file found — test manually based on epic requirements.${NC}\n"
        return
    fi

    local app_noun="${BMAD_APP_NOUN:-app}"

    # Show automated test files if a pattern is configured in bmad-config.sh
    if [ -n "${BMAD_TEST_FILE_PATTERN:-}" ]; then
        local test_files
        test_files=$(grep -oE "$BMAD_TEST_FILE_PATTERN" "$story_file" 2>/dev/null | sort -u)
        if [ -n "$test_files" ]; then
            echo -e "${CYAN}🧪 Automated Tests to Run:${NC}"
            [ -n "${BMAD_TEST_RUN_INSTRUCTIONS:-}" ] && \
                echo -e "${BLUE}   How to run:${NC} ${BMAD_TEST_RUN_INSTRUCTIONS}"
            [ -n "${BMAD_TEST_PASS_INDICATOR:-}" ] && \
                echo -e "${BLUE}   ✅ Pass:${NC}    ${BMAD_TEST_PASS_INDICATOR}"
            [ -n "${BMAD_TEST_FAIL_INDICATOR:-}" ] && \
                echo -e "${BLUE}   ❌ Fail:${NC}    ${BMAD_TEST_FAIL_INDICATOR}\n"
            echo "$test_files" | while IFS= read -r f; do
                echo -e "  ${GREEN}▶${NC}  ${BOLD}${f}${NC}"
            done
            echo ""
        fi
    fi

    # Show Acceptance Criteria section headers as a checklist
    local ac_headers
    ac_headers=$(grep -E '^### AC[0-9]' "$story_file" 2>/dev/null)
    if [ -n "$ac_headers" ]; then
        echo -e "${CYAN}✅ Acceptance Criteria to Verify:${NC}"
        echo -e "${BLUE}   The code review AI will check these — spot-check them in your ${app_noun} too.${NC}\n"
        echo "$ac_headers" | while IFS= read -r ac; do
            echo -e "  ${YELLOW}□${NC}  ${ac}"
        done
        echo ""
    fi

    # Show numbered test assertions (e.g. under AC5 or "Assertions" section)
    local assertions
    assertions=$(awk '/Assertions|AC5.*[Tt]est|automated test/,/^---/' "$story_file" 2>/dev/null \
        | grep -E '^\s*[0-9]+\.' | head -15)
    if [ -n "$assertions" ]; then
        echo -e "${CYAN}🔬 Specific Assertions (the automated tests cover these):${NC}"
        echo "$assertions" | while IFS= read -r line; do
            echo -e "  ${YELLOW}□${NC}  ${line}"
        done
        echo ""
    fi

    # Surface any explicit MANUAL: notes in the story
    local manual_items
    manual_items=$(grep -iE 'MANUAL:|manually test|manual step' "$story_file" 2>/dev/null | head -5)
    if [ -n "$manual_items" ]; then
        echo -e "${RED}⚠️  Manual Steps Required:${NC}"
        echo "$manual_items" | while IFS= read -r item; do
            echo -e "  ${RED}▸${NC}  ${item}"
        done
        echo ""
    fi

    echo -e "${YELLOW}Complete the checks above before continuing — the code review will verify ACs are implemented.${NC}"
    echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to run AI with a prompt
run_ai() {
    local prompt=$1
    local cli=$2
    local model=$3
    local output_file="/tmp/bmad-ai-output-$$.txt"
    
    echo -e "${CYAN}Using: ${cli} with model ${model}${NC}"
    echo -e "${YELLOW}⏳ This may take 1-15 minutes depending on complexity...${NC}"
    
    if [ "$cli" = "claude" ]; then
        if [ -n "$model" ]; then
            echo "$prompt" | $CLAUDE_BIN --print --dangerously-skip-permissions --model "$model" > "$output_file" 2>&1 &
        else
            echo "$prompt" | $CLAUDE_BIN --print --dangerously-skip-permissions > "$output_file" 2>&1 &
        fi
        local ai_pid=$!
        show_progress $ai_pid
        wait $ai_pid
        local exit_code=$?
        
        # Check for rate limit errors
        if grep -q "hit your limit\|rate limit\|too many requests" "$output_file" 2>/dev/null; then
            echo ""
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${RED}⚠️  CLAUDE API RATE LIMIT REACHED${NC}"
            echo -e "${YELLOW}Claude has hit its rate limit.${NC}"
            grep "resets\|limit" "$output_file" 2>/dev/null | head -1
            echo ""
            echo -e "${GREEN}✨ EASY FIX: Switch to Copilot CLI (separate rate limits!)${NC}"
            echo -e "${CYAN}Copilot supports both GPT and Claude models:${NC}"
            echo ""
            echo -e "  ${BOLD}${MAGENTA}./bmad.sh ${COMMAND} ${STORY_KEY} --cli copilot --model gpt-5.3-codex${NC}"
            echo -e "  ${BOLD}${MAGENTA}./bmad.sh ${COMMAND} ${STORY_KEY} --cli copilot --model claude-sonnet-4.6${NC}"
            echo ""
            echo -e "${CYAN}Or wait for Claude CLI rate limit to reset (time shown above):${NC}"
            echo -e "  ${BOLD}./bmad.sh ${COMMAND} ${STORY_KEY}${NC}"
            echo ""
            echo -e "${YELLOW}💡 Tip: Copilot CLI has separate rate limits from Claude CLI!${NC}"
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            rm -f "$output_file"
            return 1
        fi
        
        # Display output and clean up
        cat "$output_file"
        
        # Show token usage summary
        show_usage_stats "$output_file"
        
        # Highlight important messages the AI flagged for the user
        show_important_messages "$output_file"
        
        rm -f "$output_file"
        return $exit_code
        
    elif [ "$cli" = "copilot" ]; then
        if [ -n "$model" ]; then
            $COPILOT_BIN -p "$prompt" --model "$model" --allow-all-tools > "$output_file" 2>&1 &
        else
            $COPILOT_BIN -p "$prompt" --allow-all-tools > "$output_file" 2>&1 &
        fi
        local ai_pid=$!
        show_progress $ai_pid
        wait $ai_pid
        local exit_code=$?
        
        # Check for model not available error — only fire when exit_code is non-zero
        # to avoid false positives from AI output containing phrases like "No matches found"
        if [ $exit_code -ne 0 ] && grep -qi "model.*not available\|model.*not found\|invalid model\|unknown model\|no such model" "$output_file" 2>/dev/null; then
            echo ""
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${RED}⚠️  COPILOT MODEL ERROR${NC}"
            cat "$output_file"
            echo ""
            echo -e "${CYAN}Valid Copilot models include:${NC}"
            echo -e "  claude-sonnet-4.6, gpt-5.3-codex, gpt-5.5-medium, gpt-5.4"
            echo -e "${YELLOW}Note: Effort levels (low/medium/high) are set via /model in interactive mode${NC}"
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            rm -f "$output_file"
            return 1
        fi
        
        # Check for rate limit errors
        if grep -qi "rate limit\|quota exceeded\|too many requests\|limit reached" "$output_file" 2>/dev/null; then
            echo ""
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${RED}⚠️  COPILOT RATE LIMIT REACHED${NC}"
            echo -e "${GREEN}✨ Switch to Claude CLI (separate rate limits!):${NC}"
            echo -e "  ${BOLD}./bmad.sh ${COMMAND} ${STORY_KEY} --cli claude --model sonnet${NC}"
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            rm -f "$output_file"
            return 1
        fi
        
        # Show output on failure even if no specific error matched
        if [ $exit_code -ne 0 ]; then
            echo -e "${RED}Copilot returned an error:${NC}"
            cat "$output_file"
            rm -f "$output_file"
            return $exit_code
        fi
        
        # Display output and clean up
        cat "$output_file"
        
        # Show token usage summary
        show_usage_stats "$output_file"
        
        # Highlight important messages the AI flagged for the user
        show_important_messages "$output_file"
        
        rm -f "$output_file"
        return $exit_code
    else
        echo -e "${YELLOW}Unknown CLI: $cli, falling back to claude${NC}"
        echo "$prompt" | $CLAUDE_BIN --print --dangerously-skip-permissions > "$output_file" 2>&1 &
        local ai_pid=$!
        show_progress $ai_pid
        wait $ai_pid
        local exit_code=$?
        
        # Display output and clean up
        cat "$output_file"
        rm -f "$output_file"
        return $exit_code
    fi
}

# Function to commit changes
git_commit() {
    local story_key=$1
    local phase=$2

    echo -e "${BLUE}Committing changes for ${story_key} (${phase})...${NC}"

    git add .

    local trailer=""
    [ -n "${BMAD_GIT_COAUTHOR:-}" ] && trailer=$'\n\n'"Co-authored-by: ${BMAD_GIT_COAUTHOR}"

    if ! git commit -m "${story_key}: ${phase}

Automated commit via bmad.sh${trailer}"; then
        echo -e "${YELLOW}ℹ Nothing new to commit (AI may have committed directly)${NC}"
    fi

    echo -e "${GREEN}✓ Committed${NC}"
}

# Parse arguments
COMMAND=$1
STORY_KEY=$2
shift 2 2>/dev/null || true

# Parse optional flags
USE_CLI=""
USE_MODEL=""

SKIP_VALIDATION=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --cli)
            USE_CLI="$2"
            shift 2
            ;;
        --model)
            USE_MODEL="$2"
            shift 2
            ;;
        --skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [ -z "$COMMAND" ]; then
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║      BMAD Flow - Workflow Automation  v${BMAD_FLOW_VERSION}      ║${NC}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}INDIVIDUAL STORY COMMANDS:${NC}"
    echo -e "  ${GREEN}create-story${NC} <story-key>   Create story definition from epic"
    echo -e "  ${GREEN}dev-story${NC} <story-key>      Implement the story"
    echo -e "  ${GREEN}code-review${NC} <story-key>    Review and fix implemented code"
    echo ""
    echo -e "${BOLD}BATCH COMMANDS:${NC}"
    echo -e "  ${YELLOW}epic${NC} <epic-num>            Process all backlog stories in epic"
    echo -e "  ${YELLOW}cycle${NC} <story-key>          Run full cycle for one story (all phases)"
    echo ""
    echo -e "${BOLD}UTILITY COMMANDS:${NC}"
    echo -e "  ${BLUE}next${NC}                       Show what to do next (recommended command)"
    echo -e "  ${BLUE}status${NC} [epic-num]          Show epic progress and story status"
    echo -e "  ${BLUE}config${NC}                     Show active configuration and binary status"
    echo -e "  ${BLUE}usage${NC}                      Show today's AI token/request usage"
    echo -e "  ${BLUE}retro${NC} <epic-num>           Generate epic retrospective"
    echo -e "  ${BLUE}preflight${NC} <story-key>      Validate story is ready for next phase"
    echo -e "  ${BLUE}version${NC}                    Show bmad-flow version"
    echo -e "  ${BLUE}help${NC}                       Show this help message"
    echo ""
    echo -e "${BOLD}OPTIONS:${NC}"
    echo -e "  --cli <claude|copilot>    Choose AI CLI (defaults per phase)"
    echo -e "  --model <model-name>      Choose specific model"
    echo -e "  --skip-validation         Skip pre-flight checks"
    echo ""
    echo -e "${BOLD}MODEL SELECTION (Choose best model for each phase):${NC}"
    echo ""
    echo -e "  ${GREEN}For complex implementation - use most capable:${NC}"
    echo -e "    ./bmad.sh dev-story 2-8 --cli claude --model claude-opus-4-7-high"
    echo ""
    echo -e "  ${GREEN}For fast iteration - use efficient model:${NC}"
    echo -e "    ./bmad.sh create-story 2-8 --cli claude --model claude-sonnet-4-6"
    echo ""
    echo -e "  ${GREEN}For analytical code review - use GPT:${NC}"
    echo -e "    ./bmad.sh code-review 2-8 --cli copilot --model gpt-5.3-codex"
    echo ""
    echo -e "  ${GREEN}Full cycle with specific model:${NC}"
    echo -e "    ./bmad.sh cycle 2-8 --cli copilot --model gpt-5.5-medium"
    echo ""
    echo -e "  ${YELLOW}💡 Tip: Claude & Copilot have separate rate limits - switch if one is limited!${NC}"
    echo -e "  ${YELLOW}💡 Best practice: Use DIFFERENT models for dev vs review to catch more bugs!${NC}"
    echo ""
    echo -e "${BOLD}DEFAULTS (edit bmad-config.sh to customize):${NC}"
    echo -e "  create-story: ${DEFAULT_CREATE_CLI} (${DEFAULT_CREATE_MODEL})"
    echo -e "  dev-story:    ${DEFAULT_DEV_CLI} (${DEFAULT_DEV_MODEL})"
    echo -e "  code-review:  ${DEFAULT_REVIEW_CLI} (${DEFAULT_REVIEW_MODEL})"
    echo ""
    echo -e "${BOLD}WORKFLOW CYCLES:${NC}"
    echo ""
    echo -e "  ${CYAN}1. Single Story Cycle:${NC}"
    echo -e "     ./bmad.sh create-story 2-7  →  [test]  →  ./bmad.sh dev-story 2-7"
    echo -e "     →  [test]  →  ./bmad.sh code-review 2-7  →  DONE"
    echo ""
    echo -e "  ${CYAN}2. Quick Single Story (automated):${NC}"
    echo -e "     ./bmad.sh cycle 2-7   # Runs all phases with test pauses"
    echo ""
    echo -e "  ${CYAN}3. Process Entire Epic:${NC}"
    echo -e "     ./bmad.sh epic 2   # Processes all backlog stories in Epic 2"
    echo ""
    echo -e "  ${CYAN}4. Check Progress:${NC}"
    echo -e "     ./bmad.sh status 2   # View Epic 2 status and remaining work"
    echo ""
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo -e "  ./bmad.sh status 2"
    echo -e "  ./bmad.sh create-story 2-7"
    echo -e "  ./bmad.sh dev-story 2-7 --cli claude --model claude-sonnet-4-6"
    echo -e "  ./bmad.sh code-review 2-7 --cli copilot --model gpt-5.3-codex"
    echo -e "  ./bmad.sh epic 2"
    echo ""
    echo -e "For detailed documentation: ${CYAN}cat docs/BMAD-WORKFLOWS.md${NC}"
    echo ""
    exit 1
fi

case $COMMAND in
    help)
        COMMAND=""
        STORY_KEY=""
        exec "$0"
        ;;
    
    usage)
        show_session_usage
        exit 0
        ;;

    version)
        echo "bmad-flow v${BMAD_FLOW_VERSION}"
        exit 0
        ;;

    config)
        echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${CYAN}║            BMAD Flow Configuration  v${BMAD_FLOW_VERSION}          ║${NC}"
        echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}\n"

        echo -e "${BOLD}Project:${NC}"
        echo -e "  App noun:    ${CYAN}${BMAD_APP_NOUN}${NC}"
        echo -e "  Tech stack:  ${CYAN}${BMAD_TECH_STACK:-not set}${NC}"
        echo -e "  Status file: ${CYAN}${STATUS_FILE}${NC}"
        echo -e "  Stories dir: ${CYAN}${STORIES_DIR}${NC}"
        if [ -n "${BMAD_FILE_EXTENSIONS:-}" ]; then
            echo -e "  File exts:   ${CYAN}${BMAD_FILE_EXTENSIONS}${NC}"
        fi
        echo ""

        echo -e "${BOLD}AI Configuration:${NC}"
        echo -e "  ${CYAN}Phase 1 — Create Story:${NC}  ${DEFAULT_CREATE_CLI} / ${DEFAULT_CREATE_MODEL}"
        echo -e "  ${CYAN}Phase 2 — Dev Story:${NC}     ${DEFAULT_DEV_CLI} / ${DEFAULT_DEV_MODEL}"
        echo -e "  ${CYAN}Phase 3 — Code Review:${NC}   ${DEFAULT_REVIEW_CLI} / ${DEFAULT_REVIEW_MODEL}"
        echo ""

        echo -e "${BOLD}Binaries:${NC}"
        if command -v "$CLAUDE_BIN" &>/dev/null; then
            echo -e "  ${GREEN}✓ Claude CLI:${NC}  $CLAUDE_BIN  $(${CLAUDE_BIN} --version 2>/dev/null | head -1 || true)"
        else
            echo -e "  ${RED}✗ Claude CLI:${NC}  $CLAUDE_BIN  ${RED}← not found!${NC}"
        fi
        if command -v "$COPILOT_BIN" &>/dev/null; then
            echo -e "  ${GREEN}✓ Copilot CLI:${NC} $COPILOT_BIN"
        else
            echo -e "  ${RED}✗ Copilot CLI:${NC} $COPILOT_BIN  ${RED}← not found!${NC}"
        fi
        echo ""

        echo -e "${BOLD}Testing:${NC}"
        if [ -n "${BMAD_TEST_CMD:-}" ]; then
            echo -e "  Test command: ${CYAN}${BMAD_TEST_CMD}${NC}"
        else
            echo -e "  Test command: ${YELLOW}not configured${NC}"
        fi
        if [ -n "${BMAD_TEST_FILE_PATTERN:-}" ]; then
            echo -e "  Test pattern: ${CYAN}${BMAD_TEST_FILE_PATTERN}${NC}"
        else
            echo -e "  Test pattern: ${YELLOW}not configured${NC}"
        fi
        [ -n "${BMAD_TEST_RUN_INSTRUCTIONS:-}" ] && \
            echo -e "  How to run:   ${CYAN}${BMAD_TEST_RUN_INSTRUCTIONS}${NC}"
        [ -n "${BMAD_TEST_PASS_INDICATOR:-}" ] && \
            echo -e "  Pass looks:   ${GREEN}${BMAD_TEST_PASS_INDICATOR}${NC}"
        [ -n "${BMAD_TEST_FAIL_INDICATOR:-}" ] && \
            echo -e "  Fail looks:   ${RED}${BMAD_TEST_FAIL_INDICATOR}${NC}"
        echo ""

        echo -e "${BOLD}Git:${NC}"
        if [ -n "${BMAD_GIT_COAUTHOR:-}" ]; then
            echo -e "  Co-author: ${CYAN}${BMAD_GIT_COAUTHOR}${NC}"
        else
            echo -e "  Co-author: ${YELLOW}not configured (set BMAD_GIT_COAUTHOR in bmad-config.sh)${NC}"
        fi
        echo ""

        echo -e "${YELLOW}To edit: nano bmad-config.sh${NC}"
        exit 0
        ;;

    next)
        # Show what to do next
        echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${CYAN}║                    What's Next?                           ║${NC}"
        echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}\n"
        
        # Find the current active epic
        local active_epic=$(grep "^  epic-[0-9]*:" "$STATUS_FILE" | grep "in-progress" | head -1 | sed 's/.*epic-\([0-9]*\).*/\1/')
        
        if [ -z "$active_epic" ]; then
            echo -e "${YELLOW}No active epic found. Start one with: ./bmad.sh cycle <story-key>${NC}"
            exit 0
        fi
        
        echo -e "${CYAN}Active Epic:${NC} ${active_epic}"
        echo ""
        
        # Find first non-done story and its status
        local next_story=""
        local next_status=""
        local next_cmd=""
        
        while IFS= read -r story; do
            local s_status=$(get_status "$story")
            if [ "$s_status" != "done" ]; then
                next_story="$story"
                next_status="$s_status"
                break
            fi
        done <<< "$(get_epic_stories "$active_epic")"
        
        if [ -z "$next_story" ]; then
            echo -e "${GREEN}✓ All stories in Epic ${active_epic} are done!${NC}"
            echo -e "${YELLOW}Run: ./bmad.sh retro ${active_epic}${NC}"
            exit 0
        fi
        
        # Determine the right command based on status
        case $next_status in
            backlog)
                next_cmd="./bmad.sh create-story ${next_story}"
                echo -e "${CYAN}Next Story:${NC} ${next_story} (${next_status})"
                echo -e "${CYAN}Action:${NC}     Create the story definition"
                ;;
            ready-for-dev)
                next_cmd="./bmad.sh dev-story ${next_story}"
                echo -e "${CYAN}Next Story:${NC} ${next_story} (${next_status})"
                echo -e "${CYAN}Action:${NC}     Implement the story"
                ;;
            in-progress|review)
                next_cmd="./bmad.sh code-review ${next_story}"
                echo -e "${CYAN}Next Story:${NC} ${next_story} (${next_status})"
                echo -e "${CYAN}Action:${NC}     Run code review"
                ;;
        esac
        
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}▶ Run:${NC}  ${BOLD}${next_cmd}${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${YELLOW}Or run full automated cycle:${NC} ${BOLD}./bmad.sh cycle ${next_story}${NC}"
        echo ""
        
        # Show quick progress
        local total=$(get_epic_stories "$active_epic" | wc -l | tr -d ' ')
        local done_count=$(count_stories_by_status "$active_epic" "done")
        echo -e "${CYAN}Epic ${active_epic} Progress:${NC}"
        draw_progress_bar "$done_count" "$total"
        echo ""
        exit 0
        ;;
        
    status)
        # Show epic status
        EPIC_NUM=$STORY_KEY
        if [ -z "$EPIC_NUM" ]; then
            echo -e "${RED}Usage: ./bmad.sh status <epic-number>${NC}"
            exit 1
        fi
        show_epic_status "$EPIC_NUM"
        exit 0
        ;;
        
    preflight)
        # Pre-flight check for story
        if [ -z "$STORY_KEY" ]; then
            echo -e "${RED}Usage: ./bmad.sh preflight <story-key>${NC}"
            exit 1
        fi
        
        echo -e "${CYAN}Running pre-flight checks for ${STORY_KEY}...${NC}\n"
        
        # Check git status
        echo -e "${BLUE}1. Checking git working directory...${NC}"
        check_git_clean
        echo -e "${GREEN}✓ Git working directory clean${NC}\n"
        
        # Check story file
        echo -e "${BLUE}2. Checking story file...${NC}"
        if validate_story_file "$STORY_KEY"; then
            echo -e "${GREEN}✓ Story file exists${NC}\n"
        else
            exit 1
        fi
        
        # Check story status
        echo -e "${BLUE}3. Checking story status...${NC}"
        local story_status=$(get_status "$STORY_KEY")
        echo -e "   Current status: ${CYAN}${story_status}${NC}"
        echo -e "${GREEN}✓ Status check complete${NC}\n"
        
        # Validate project artifacts if story is in dev/review
        if [[ "$story_status" == "in-progress" || "$story_status" == "review" ]]; then
            echo -e "${BLUE}4. Validating project artifacts...${NC}"
            validate_project_artifacts "$STORY_KEY"
            echo ""
        fi
        
        echo -e "${GREEN}✓ All pre-flight checks passed${NC}"
        exit 0
        ;;
        
    retro)
        # Generate retrospective
        EPIC_NUM=$STORY_KEY
        if [ -z "$EPIC_NUM" ]; then
            echo -e "${RED}Usage: ./bmad.sh retro <epic-number>${NC}"
            exit 1
        fi
        
        CLI="${USE_CLI:-$DEFAULT_CREATE_CLI}"
        MODEL="${USE_MODEL:-$DEFAULT_CREATE_MODEL}"
        
        echo -e "${GREEN}=== Generating Epic ${EPIC_NUM} Retrospective ===${NC}"
        
        _AI_PROMPT="Generate a retrospective for Epic ${EPIC_NUM}. Read story files in ${STORIES_DIR}/ and sprint-status.yaml.

Create ${STORIES_DIR}/epic-${EPIC_NUM}-retro-$(date +%Y-%m-%d).md with: what went well, improvements, lessons learned, blockers and resolutions, metrics (stories done, estimates vs actual), recommendations for next epic."

        run_ai "$_AI_PROMPT" "$CLI" "$MODEL"
        update_status "epic-${EPIC_NUM}-retrospective" "done"
        git_commit "epic-${EPIC_NUM}" "retrospective"
        
        echo -e "${GREEN}✓ Retrospective generated and committed${NC}"
        exit 0
        ;;
        
    epic)
        # Process entire epic
        EPIC_NUM=$STORY_KEY
        if [ -z "$EPIC_NUM" ]; then
            echo -e "${RED}Usage: ./bmad.sh epic <epic-number>${NC}"
            exit 1
        fi
        
        echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${CYAN}║          Processing Epic ${EPIC_NUM} - All Stories               ║${NC}"
        echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}\n"
        
        # Show initial status
        show_epic_status "$EPIC_NUM"
        
        # Get all non-done stories
        local stories=$(get_epic_stories "$EPIC_NUM" | while read story; do
            local story_status=$(get_status "$story")
            if [ "$story_status" != "done" ]; then
                echo "$story"
            fi
        done)
        
        if [ -z "$stories" ]; then
            echo -e "${GREEN}✓ All stories in Epic ${EPIC_NUM} are complete!${NC}"
            exit 0
        fi
        
        local total=$(echo "$stories" | wc -l | tr -d ' ')
        local current=0
        
        echo "$stories" | while read story; do
            current=$((current + 1))
            
            echo -e "\n${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BOLD}${YELLOW}  Story ${current}/${total}: ${story}${NC}"
            echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
            
            # Run cycle for this story
            local -a epic_args=()
            [[ -n "$USE_CLI" ]] && epic_args+=(--cli "$USE_CLI")
            [[ -n "$USE_MODEL" ]] && epic_args+=(--model "$USE_MODEL")
            $0 cycle "$story" "${epic_args[@]}"
            
            echo -e "\n${GREEN}✓ Story ${story} complete (${current}/${total})${NC}\n"
        done
        
        # Show final status
        echo -e "\n${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${GREEN}║           Epic ${EPIC_NUM} Processing Complete!                ║${NC}"
        echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}\n"
        
        show_epic_status "$EPIC_NUM"
        
        echo -e "${YELLOW}Generate retrospective with: ./bmad.sh retro ${EPIC_NUM}${NC}"
        exit 0
        ;;
        
    cycle)
        # Run full cycle for one story
        if [ -z "$STORY_KEY" ]; then
            echo -e "${RED}Usage: ./bmad.sh cycle <story-key>${NC}"
            exit 1
        fi
        
        echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${CYAN}║         Running Full Cycle for ${STORY_KEY}                  ║${NC}"
        echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}\n"
        
        # Do git check once at the start
        check_git_clean
        
        # Build extra args array (zsh requires array for proper word splitting)
        local -a extra_args=(--skip-validation)
        [[ -n "$USE_CLI" ]] && extra_args+=(--cli "$USE_CLI")
        [[ -n "$USE_MODEL" ]] && extra_args+=(--model "$USE_MODEL")
        
        local story_status=$(get_status "$STORY_KEY")
        
        # Determine starting phase based on status
        if [[ "$story_status" == "backlog" ]]; then
            echo -e "${CYAN}Phase 1/3: Creating Story${NC}\n"
            if ! $0 create-story "$STORY_KEY" "${extra_args[@]}"; then
                echo -e "${RED}✗ create-story failed${NC}"
                exit 1
            fi
            story_status=$(get_status "$STORY_KEY")
            echo ""
        fi
        
        if [[ "$story_status" == "ready-for-dev" || "$story_status" == "backlog" ]]; then
            echo -e "${YELLOW}⏸  Pause: Review story file if needed, then press Enter to continue...${NC}"
            read
            
            echo -e "${CYAN}Phase 2/3: Implementing Story${NC}\n"
            if ! $0 dev-story "$STORY_KEY" "${extra_args[@]}"; then
                echo -e "${RED}✗ dev-story failed${NC}"
                exit 1
            fi
            story_status=$(get_status "$STORY_KEY")
            echo ""
        fi
        
        if [[ "$story_status" == "in-progress" || "$story_status" == "review" ]]; then
            show_story_test_hints "$STORY_KEY"
            local _app_noun_up
            _app_noun_up=$(echo "${BMAD_APP_NOUN:-app}" | tr '[:lower:]' '[:upper:]')
            echo -e "${YELLOW}⏸  TEST YOUR ${_app_noun_up} NOW — review the checklist above${NC}"
            echo -e "${YELLOW}   Press Enter when you have tested and are ready for code review...${NC}"
            read
            
            echo -e "${CYAN}Phase 3/3: Code Review${NC}\n"
            if ! $0 code-review "$STORY_KEY" "${extra_args[@]}"; then
                echo -e "${RED}✗ code-review failed${NC}"
                exit 1
            fi
            story_status=$(get_status "$STORY_KEY")
            echo ""
        fi
        
        echo -e "${GREEN}✓ Full cycle complete for ${STORY_KEY}${NC}"
        exit 0
        ;;
        
    create-story)
        if [ -z "$STORY_KEY" ]; then
            echo -e "${RED}Usage: ./bmad.sh create-story <story-key>${NC}"
            exit 1
        fi
        
        # Set defaults for this phase
        CLI="${USE_CLI:-$DEFAULT_CREATE_CLI}"
        MODEL="${USE_MODEL:-$DEFAULT_CREATE_MODEL}"
        
        echo -e "${GREEN}=== Creating Story: ${STORY_KEY} ===${NC}"
        
        # Pre-flight check (unless skipped)
        if [[ "$SKIP_VALIDATION" != "true" ]]; then
            check_git_clean
        fi
        
        _AI_PROMPT="Read the epic file in ${STORIES_DIR}/ and create story file ${STORIES_DIR}/${STORY_KEY}.md.

Include: title, context, testable acceptance criteria, technical approach, and dependencies. Follow BMAD-METHOD story structure. Write the file now."

        run_ai "$_AI_PROMPT" "$CLI" "$MODEL"
        update_status "$STORY_KEY" "ready-for-dev"
        git_commit "$STORY_KEY" "create-story"
        
        echo -e "${GREEN}✓ Story created and committed${NC}"
        echo -e "${YELLOW}Next: Test if needed, then run: ./bmad.sh dev-story ${STORY_KEY}${NC}"
        ;;
        
    dev-story)
        if [ -z "$STORY_KEY" ]; then
            echo -e "${RED}Usage: ./bmad.sh dev-story <story-key>${NC}"
            exit 1
        fi
        
        # Set defaults for this phase
        CLI="${USE_CLI:-$DEFAULT_DEV_CLI}"
        MODEL="${USE_MODEL:-$DEFAULT_DEV_MODEL}"
        
        echo -e "${GREEN}=== Implementing Story: ${STORY_KEY} ===${NC}"
        
        # Pre-flight check (unless skipped)
        if [[ "$SKIP_VALIDATION" != "true" ]]; then
            check_git_clean
            validate_story_file "$STORY_KEY" || exit 1
        fi
        
        local _test_hint=""
        [ -n "${BMAD_TEST_CMD:-}" ] && \
            _test_hint=$'\n'"To run automated tests: ${BMAD_TEST_CMD} <test-file> (if binary unavailable it will print MANUAL instructions)"

        _AI_PROMPT="Implement story ${STORY_KEY}. Read ${STORIES_DIR}/${STORY_KEY}*.md for requirements.

Implement all acceptance criteria. Follow the technical approach in the story file.${_test_hint}

If you encounter blockers or cannot complete something, say 'MANUAL: <what needs attention>'.

Summarize what was implemented when done."

        _AI_EXIT=0
        run_ai "$_AI_PROMPT" "$CLI" "$MODEL" || _AI_EXIT=$?

        if [ $_AI_EXIT -ne 0 ]; then
            echo ""
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}⚠️  AI reported issues — scroll up and review the output above${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            if [[ -t 0 ]]; then
                read -q "REPLY?Update status to 'review' and continue? (y/n) "
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo -e "${RED}Aborted — fix the issues above and re-run dev-story${NC}"
                    exit 1
                fi
            else
                echo -e "${YELLOW}Non-interactive mode: continuing despite AI issues${NC}"
            fi
        fi

        update_status "$STORY_KEY" "review"
        git_commit "$STORY_KEY" "dev-story"

        echo -e "${GREEN}✓ Story implemented and committed${NC}"
        local app_noun_up
        app_noun_up=$(echo "${BMAD_APP_NOUN:-app}" | tr '[:lower:]' '[:upper:]')
        echo -e "${YELLOW}Next: TEST YOUR ${app_noun_up}, then run: ./bmad.sh code-review ${STORY_KEY}${NC}"
        ;;
        
    code-review)
        if [ -z "$STORY_KEY" ]; then
            echo -e "${RED}Usage: ./bmad.sh code-review <story-key>${NC}"
            exit 1
        fi
        
        # Set defaults for this phase
        CLI="${USE_CLI:-$DEFAULT_REVIEW_CLI}"
        MODEL="${USE_MODEL:-$DEFAULT_REVIEW_MODEL}"
        
        echo -e "${GREEN}=== Code Review: ${STORY_KEY} ===${NC}"
        
        # Pre-flight check (unless skipped)
        if [[ "$SKIP_VALIDATION" != "true" ]]; then
            check_git_clean
            validate_story_file "$STORY_KEY" || exit 1
            validate_project_artifacts "$STORY_KEY"
        fi
        
        # Build AC list from story file to inject into the review prompt
        local story_file_cr
        story_file_cr=$(ls "${STORIES_DIR}/${STORY_KEY}"*.md 2>/dev/null | head -1)
        local ac_list=""
        if [ -n "$story_file_cr" ]; then
            ac_list=$(grep -E '^### AC[0-9]' "$story_file_cr" 2>/dev/null | sed 's/^### //' | \
                awk '{print NR". "$0}')
        fi

        _AI_PROMPT="Code review for story ${STORY_KEY}.

STEP 1 — READ THE STORY: Read ${STORIES_DIR}/${STORY_KEY}*.md for the full requirements and acceptance criteria.

STEP 2 — VERIFY EACH ACCEPTANCE CRITERION is fully implemented:
${ac_list:-  (see story file for ACs)}

For each AC: state whether it PASSES or FAILS, and fix any that fail.

STEP 3 — GENERAL CODE REVIEW of all changes for this story:
- Bugs, edge cases, off-by-one errors
- Missing or incorrect error handling
- Best-practice violations for the project tech stack
- Anything the automated tests do not cover

If something requires manual testing by the developer, say 'MANUAL: <what to test>'.

Summarize: AC results (pass/fail), bugs fixed, and anything left for manual verification."

        _AI_EXIT=0
        run_ai "$_AI_PROMPT" "$CLI" "$MODEL" || _AI_EXIT=$?

        if [ $_AI_EXIT -ne 0 ]; then
            echo ""
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}⚠️  AI reported issues — scroll up and review the output above${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            if [[ -t 0 ]]; then
                read -q "REPLY?Mark story as done and commit anyway? (y/n) "
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo -e "${RED}Aborted — fix the issues above and re-run code-review${NC}"
                    exit 1
                fi
            else
                echo -e "${YELLOW}Non-interactive mode: continuing despite AI issues${NC}"
            fi
        fi
        update_status "$STORY_KEY" "done"
        git_commit "$STORY_KEY" "code-review"
        
        echo -e "${GREEN}✓ Code review complete and committed${NC}"
        echo -e "${GREEN}✓ Story ${STORY_KEY} is DONE!${NC}"
        echo -e "${YELLOW}Next: Move to the next story${NC}"
        ;;
        
    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}"
        echo -e "Run ${BOLD}./bmad.sh help${NC} for valid commands"
        exit 1
        ;;
esac
