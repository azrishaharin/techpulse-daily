#!/bin/bash

# Publish all approved articles from drafts folder
# Usage: ./src/scripts/approve-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
DRAFTS_DIR="$REPO_DIR/src/content/articles/drafts"

# Check if gh is authenticated
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ Error: Not authenticated with GitHub. Run 'gh auth login' first."
    exit 1
fi

cd "$REPO_DIR"

# Find all draft files (excluding .gitkeep)
DRAFT_FILES=$(find "$DRAFTS_DIR" -type f ! -name '.gitkeep' ! -name '*.gitkeep' 2>/dev/null)

if [ -z "$DRAFT_FILES" ]; then
    echo "📭 No draft articles found in $DRAFTS_DIR"
    exit 0
fi

COUNT=0
FAILED=0

echo "📋 Found draft articles, starting publish..."

for DRAFT_PATH in $DRAFT_FILES; do
    DRAFT_FILE=$(basename "$DRAFT_PATH")
    SLUG=$(echo "$DRAFT_FILE" | sed 's/^[0-9-]*-//' | sed 's/\.mdx$//' | sed 's/\.md$//')
    
    echo ""
    echo "----------------------------------------"
    echo "📝 Publishing: $DRAFT_FILE"
    
    # Run the publish script for each draft
    if "$SCRIPT_DIR/publish-article.sh" "$DRAFT_FILE"; then
        ((COUNT++))
        echo "✅ Published: $SLUG"
    else
        ((FAILED++))
        echo "❌ Failed: $SLUG"
    fi
done

echo ""
echo "========================================"
echo "📊 Publish Summary"
echo "========================================"
echo "   Published: $COUNT"
echo "   Failed: $FAILED"
echo ""

if [ $COUNT -gt 0 ]; then
    echo "🎉 Successfully published $COUNT article(s)!"
else
    echo "ℹ️  No articles were published."
fi

exit 0
