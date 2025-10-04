#!/bin/bash
# restore-personal-folders-simple.sh

# Check if backup file is provided
if [ $# -eq 0 ]; then
    echo "❌ Usage: $0 <backup_zip_file>"
    echo "   Example: $0 personal_folders_backup_20251004_102355.zip"
    exit 1
fi

BACKUP_ZIP="$1"
EXTRACT_DIR="/tmp/personal_restore_$(date +%s)"

echo "📦 Extracting backup file..."
unzip -q "$BACKUP_ZIP" -d "$EXTRACT_DIR"

BACKUP_CONTENT="$EXTRACT_DIR/$(basename "$BACKUP_ZIP" .zip)"

echo "🚚 Moving files to their destinations..."

# Move home folder contents directly to ~
echo "🏠 Moving home files to ~/"
mv "$BACKUP_CONTENT/home"/* "$HOME/" 2>/dev/null || true

# Move the three specific folders
echo "🖥️  Moving Desktop files..."
mv "$BACKUP_CONTENT/desktop"/* "$HOME/Desktop/" 2>/dev/null || true

echo "📄 Moving Documents files..."
mv "$BACKUP_CONTENT/documents"/* "$HOME/Documents/" 2>/dev/null || true

echo "📥 Moving Downloads files..."
mv "$BACKUP_CONTENT/downloads"/* "$HOME/Downloads/" 2>/dev/null || true

# Clean up
rm -rf "$EXTRACT_DIR"

echo "✅ Restore completed! All files moved to their destinations."
