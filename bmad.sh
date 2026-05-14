#!/bin/zsh

# ============================================================================
# BMAD Game Dev Studio - Workflow Automation Script
# ============================================================================
# Automates the BMAD-METHOD development cycle for game development
# Supports: create-story, dev-story, code-review, epic processing, retrospectives
# Documentation: See BMAD-WORKFLOWS.md for detailed usage
# ============================================================================

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

# Function to check Godot artifacts (basic validation)
validate_godot_artifacts() {
    local story_key=$1
    local story_file="${STORIES_DIR}/${story_key}.md"
    
    echo -e "${BLUE}Validating Godot artifacts...${NC}"
    
    # Check for common patterns in story file
    if grep -q "\.gd\|\.tscn\|\.tres" "$story_file" 2>/dev/null; then
        echo -e "${GREEN}✓ Story references Godot files${NC}"
    else
        echo -e "${YELLOW}⚠ No Godot file references found in story${NC}"
    fi
    
    # Check for broken scene references in project
    local broken_scenes=$(find . -name "*.tscn" -exec grep -l "ext_resource.*path=\"res://.*\" id=" {} \; 2>/dev/null | wc -l)
    if [ "$broken_scenes" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Found ${broken_scenes} scenes with external resources (verify references)${NC}"
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
            echo -e "${YELLOW}⚠️  20 minutes elapsed - AI might be stuck. You can Ctrl+C to interrupt.${NC}"
        fi
    done
    printf "                                                    \r"
}

# Function to run AI with a prompt
run_ai() {
    local prompt=$1
    local cli=$2
    local model=$3
    
    echo -e "${CYAN}Using: ${cli} with model ${model}${NC}"
    echo -e "${YELLOW}⏳ This may take 1-15 minutes depending on complexity...${NC}"
    
    if [ "$cli" = "claude" ]; then
        if [ -n "$model" ]; then
            echo "$prompt" | $CLAUDE_BIN --print --dangerously-skip-permissions --model "$model" &
        else
            echo "$prompt" | $CLAUDE_BIN --print --dangerously-skip-permissions &
        fi
        local ai_pid=$!
        show_progress $ai_pid
        wait $ai_pid
        return $?
    elif [ "$cli" = "copilot" ]; then
        if [ -n "$model" ]; then
            echo "$prompt" | $COPILOT_BIN --prompt - --model "$model" &
        else
            echo "$prompt" | $COPILOT_BIN --prompt - &
        fi
        local ai_pid=$!
        show_progress $ai_pid
        wait $ai_pid
        return $?
    else
        echo -e "${YELLOW}Unknown CLI: $cli, falling back to claude${NC}"
        echo "$prompt" | $CLAUDE_BIN --print &
        local ai_pid=$!
        show_progress $ai_pid
        wait $ai_pid
        return $?
    fi
}

# Function to commit changes
git_commit() {
    local story_key=$1
    local phase=$2
    
    echo -e "${BLUE}Committing changes for ${story_key} (${phase})...${NC}"
    
    git add .
    git commit -m "$(cat <<EOF
${story_key}: ${phase}

Automated commit via bmad.sh
EOF
)"
    
    echo -e "${GREEN}✓ Committed${NC}"
}

# Parse arguments
COMMAND=$1
STORY_KEY=$2
shift 2 2>/dev/null || true

# Parse optional flags
USE_CLI=""
USE_MODEL=""

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
        *)
            shift
            ;;
    esac
done

if [ -z "$COMMAND" ]; then
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║      BMAD Game Dev Studio - Workflow Automation       ║${NC}"
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
    echo -e "  ${BLUE}status${NC} [epic-num]          Show epic progress and story status"
    echo -e "  ${BLUE}retro${NC} <epic-num>           Generate epic retrospective"
    echo -e "  ${BLUE}preflight${NC} <story-key>      Validate story is ready for next phase"
    echo -e "  ${BLUE}help${NC}                       Show this help message"
    echo ""
    echo -e "${BOLD}OPTIONS:${NC}"
    echo -e "  --cli <claude|copilot>    Choose AI CLI (defaults per phase)"
    echo -e "  --model <model-name>      Choose specific model"
    echo -e "  --skip-validation         Skip pre-flight checks"
    echo ""
    echo -e "${BOLD}DEFAULTS (edit script to customize):${NC}"
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
    echo -e "For detailed documentation: ${CYAN}cat BMAD-WORKFLOWS.md${NC}"
    echo ""
    exit 1
fi

case $COMMAND in
    help)
        # Show help (reuse the help display from above)
        COMMAND=""
        STORY_KEY=""
        exec "$0"
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
        
        # Validate Godot artifacts if story is in dev/review
        if [[ "$story_status" == "in-progress" || "$story_status" == "review" ]]; then
            echo -e "${BLUE}4. Validating Godot artifacts...${NC}"
            validate_godot_artifacts "$STORY_KEY"
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
        
        PROMPT="Generate a retrospective for Epic ${EPIC_NUM} following BMAD-METHOD.

1. Read all story files for epic ${EPIC_NUM} in ${STORIES_DIR}/
2. Read sprint-status.yaml to see all story statuses
3. Create retrospective document: ${STORIES_DIR}/epic-${EPIC_NUM}-retro-$(date +%Y-%m-%d).md

Include:
- What went well
- What could be improved
- Technical lessons learned
- Blockers encountered and how they were resolved
- Recommendations for next epic
- Metrics: stories completed, time estimates vs actual

Use bmad-help to ensure proper retrospective format."

        run_ai "$PROMPT" "$CLI" "$MODEL"
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
            $0 cycle "$story" ${USE_CLI:+--cli $USE_CLI} ${USE_MODEL:+--model $USE_MODEL}
            
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
        
        local story_status=$(get_status "$STORY_KEY")
        
        # Determine starting phase based on status
        if [[ "$story_status" == "backlog" ]]; then
            echo -e "${CYAN}Phase 1/3: Creating Story${NC}\n"
            if ! $0 create-story "$STORY_KEY" --skip-validation ${USE_CLI:+--cli $USE_CLI} ${USE_MODEL:+--model $USE_MODEL}; then
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
            if ! $0 dev-story "$STORY_KEY" --skip-validation ${USE_CLI:+--cli $USE_CLI} ${USE_MODEL:+--model $USE_MODEL}; then
                echo -e "${RED}✗ dev-story failed${NC}"
                exit 1
            fi
            story_status=$(get_status "$STORY_KEY")
            echo ""
        fi
        
        if [[ "$story_status" == "in-progress" || "$story_status" == "review" ]]; then
            echo -e "${YELLOW}⏸  TEST YOUR GAME NOW!${NC}"
            echo -e "${YELLOW}   Press Enter when ready for code review...${NC}"
            read
            
            echo -e "${CYAN}Phase 3/3: Code Review${NC}\n"
            if ! $0 code-review "$STORY_KEY" --skip-validation ${USE_CLI:+--cli $USE_CLI} ${USE_MODEL:+--model $USE_MODEL}; then
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
        if [[ ! "$*" =~ "--skip-validation" ]]; then
            check_git_clean
        fi
        
        PROMPT="Follow the BMAD-METHOD to create a story definition for ${STORY_KEY}.

IMPORTANT: First invoke the bmad-help skill to validate workflow state and ensure this is the correct next step.

1. Read the epic file in ${STORIES_DIR}/ to understand the story requirements
2. Create the story file ${STORY_KEY}.md in ${STORIES_DIR}/
3. Follow the BMAD story template structure
4. Include all necessary sections: Context, Requirements, Technical Approach, etc.

VALIDATION:
- Verify the story file follows BMAD standards
- Check that all required sections are present
- Ensure technical approach is sound

If there are any issues or the workflow state is incorrect, STOP and explain what needs attention.

When complete, summarize what was created."

        run_ai "$PROMPT" "$CLI" "$MODEL"
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
        if [[ ! "$*" =~ "--skip-validation" ]]; then
            check_git_clean
            validate_story_file "$STORY_KEY" || exit 1
        fi
        
        PROMPT="Follow the BMAD-METHOD to implement story ${STORY_KEY}.

IMPORTANT: First invoke the bmad-help skill to validate workflow state and ensure story is ready for development.

1. Read the story file ${STORIES_DIR}/${STORY_KEY}.md
2. Implement all requirements in the Godot project
3. Follow the technical approach specified in the story
4. Update the story file with implementation notes
5. Test that the implementation works

VALIDATION:
- Verify implementation matches story requirements
- Check for integration issues with existing systems
- Ensure code quality meets project standards

If there are blockers, missing requirements, or the story isn't ready, STOP and explain what's needed.

When complete, summarize what was implemented and any issues encountered."

        run_ai "$PROMPT" "$CLI" "$MODEL"
        update_status "$STORY_KEY" "review"
        git_commit "$STORY_KEY" "dev-story"
        
        echo -e "${GREEN}✓ Story implemented and committed${NC}"
        echo -e "${YELLOW}Next: TEST YOUR GAME, then run: ./bmad.sh code-review ${STORY_KEY}${NC}"
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
        if [[ ! "$*" =~ "--skip-validation" ]]; then
            check_git_clean
            validate_story_file "$STORY_KEY" || exit 1
            validate_godot_artifacts "$STORY_KEY"
        fi
        
        PROMPT="Review and fix the code for story ${STORY_KEY}. 

Read the story at ${STORIES_DIR}/${STORY_KEY}*.md and review all uncommitted changes in the repository.

Your task:
1. Identify bugs, edge cases, performance issues, and violations of Godot best practices
2. Fix any critical issues you find
3. Add missing error handling and validation
4. Improve code quality where needed
5. Update the story file with review findings

Focus on: type safety, null checks, resource management, signal handling, and Godot-specific patterns.

Fix all issues you find and summarize what was reviewed and fixed.

Provide a summary of the review and any fixes made."

        run_ai "$PROMPT" "$CLI" "$MODEL"
        update_status "$STORY_KEY" "done"
        git_commit "$STORY_KEY" "code-review"
        
        echo -e "${GREEN}✓ Code review complete and committed${NC}"
        echo -e "${GREEN}✓ Story ${STORY_KEY} is DONE!${NC}"
        echo -e "${YELLOW}Next: Move to the next story${NC}"
        ;;
        
    *)
        echo "Unknown command: $COMMAND"
        echo "Valid commands: create-story, dev-story, code-review"
        exit 1
        ;;
esac
