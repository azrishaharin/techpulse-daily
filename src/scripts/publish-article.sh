#!/bin/bash

# Publish an approved article from drafts to the main articles folder
# Usage: ./src/scripts/publish-article.sh 2025-06-05-samsung-galaxy-s25.mdx

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
DRAFTS_DIR="$REPO_DIR/src/content/articles/drafts"
ARTICLES_DIR="$REPO_DIR/src/content/articles"

# Check if gh is authenticated
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ Error: Not authenticated with GitHub. Run 'gh auth login' first."
    exit 1
fi

# Check for required argument
if [ -z "$1" ]; then
    echo "❌ Usage: $0 <draft-filename>"
    echo "   Example: $0 2025-06-05-samsung-galaxy-s25.mdx"
    exit 1
fi

DRAFT_FILE="$1"
DRAFT_PATH="$DRAFTS_DIR/$DRAFT_FILE"

# Check if draft file exists
if [ ! -f "$DRAFT_PATH" ]; then
    echo "❌ Error: Draft file not found: $DRAFT_PATH"
    exit 1
fi

# Extract slug from filename (remove date prefix and extension)
SLUG=$(echo "$DRAFT_FILE" | sed 's/^[0-9-]*-//' | sed 's/\.mdx$//' | sed 's/\.md$//')
NEW_FILENAME="${SLUG}.mdx"
NEW_PATH="$ARTICLES_DIR/$NEW_FILENAME"

echo "📝 Publishing draft: $DRAFT_FILE"
echo "   Slug: $SLUG"
echo "   Target: $NEW_PATH"

# Read the draft content
CONTENT=$(cat "$DRAFT_PATH")

# Update frontmatter: set approved to true
# Using sed to handle both mdx and md files
if [[ "$DRAFT_FILE" == *.mdx ]]; then
    UPDATED_CONTENT=$(echo "$CONTENT" | sed 's/^approved: false$/approved: true/' | sed 's/^approved:false$/approved: true/')
else
    UPDATED_CONTENT=$(echo "$CONTENT" | sed 's/^approved: false$/approved: true/' | sed 's/^approved:false$/approved: true/')
fi

# Write to new location
echo "$UPDATED_CONTENT" > "$NEW_PATH"

# Remove the draft
rm "$DRAFT_PATH"

# Git operations
cd "$REPO_DIR"
git add "$NEW_PATH"
git add "$DRAFT_PATH"  # This will be a delete, so git will handle it
git rm "$DRAFT_PATH" 2>/dev/null || true

# Commit with conventional message
git commit -m "publish: $SLUG"

# Push to origin main
echo "🚀 Pushing to origin main..."
git push origin main

if [ $? -eq 0 ]; then
    echo "✅ Successfully published: $SLUG"
else
    echo "❌ Failed to push to remote"
    exit 1
fi
