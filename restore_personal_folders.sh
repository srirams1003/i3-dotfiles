#!/bin/bash
# restore-personal-folders-rsync.sh

# Check if backup file is provided
if [ $# -eq 0 ]; then
    echo "❌ Usage: $0 <backup_zip_file>"
    echo "    Example: $0 personal_folders_backup_20251004_102355.zip"
    exit 1
fi

BACKUP_ZIP="$1"
EXTRACT_DIR="/tmp/personal_restore_$(date +%s)"

echo "📦 Extracting backup file..."
unzip -q "$BACKUP_ZIP" -d "$EXTRACT_DIR"

BACKUP_CONTENT="$EXTRACT_DIR/$(basename "$BACKUP_ZIP" .zip)"

# Check if backup content directory exists
if [ ! -d "$BACKUP_CONTENT" ]; then
    echo "❌ Backup content not found inside the zip."
    echo "   Expected: $BACKUP_CONTENT"
    rm -rf "$EXTRACT_DIR"
    exit 1
fi

echo "🚚 Restoring files to their destinations..."

# Use rsync -a (archive) to correctly merge all files, including hidden ones.
# The trailing slash on the source ($BACKUP_CONTENT/home/) is important.
# It means "copy the *contents* of this directory."

echo "🏠 Restoring home files to ~/"
rsync -a "$BACKUP_CONTENT/home/" "$HOME/"

echo "🖥️  Restoring Desktop files..."
rsync -a "$BACKUP_CONTENT/desktop/" "$HOME/Desktop/"

echo "📄 Restoring Documents files..."
rsync -a "$BACKUP_CONTENT/documents/" "$HOME/Documents/"

echo "📥 Restoring Downloads files..."
rsync -a "$BACKUP_CONTENT/downloads/" "$HOME/Downloads/"

# Clean up
rm -rf "$EXTRACT_DIR"

echo "✅ Restore completed!"
