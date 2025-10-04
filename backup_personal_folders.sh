#!/bin/bash
# backup-personal-folders-rsync.sh

BACKUP_NAME="personal_folders_backup_$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="/tmp/$BACKUP_NAME"
ZIP_FILE="$HOME/${BACKUP_NAME}.zip"

# Create temporary backup directory structure
mkdir -p "$BACKUP_DIR/home"
mkdir -p "$BACKUP_DIR/desktop" 
mkdir -p "$BACKUP_DIR/documents"
mkdir -p "$BACKUP_DIR/downloads"

echo "📁 Creating backup structure..."

# Backup home excluding specified directories and hidden files
echo "📂 Backing up Home directory..."
rsync -a --exclude='.*' \
          --exclude='anaconda3' \
          --exclude='Music' \
          --exclude='Pictures' \
          --exclude='Desktop' \
          --exclude='Public' \
          --exclude='dotfiles' \
          --exclude='Documents' \
          --exclude='Downloads' \
          --exclude='Templates' \
          --exclude='Videos' \
          --exclude='VirtualBox VMs' \
          "$HOME/" "$BACKUP_DIR/home/" 2>/dev/null

# Backup the three folders with all contents (including hidden files)
echo "🖥️  Backing up Desktop..."
rsync -a "$HOME/Desktop/" "$BACKUP_DIR/desktop/" 2>/dev/null

echo "📄 Backing up Documents..."
rsync -a "$HOME/Documents/" "$BACKUP_DIR/documents/" 2>/dev/null

echo "📥 Backing up Downloads..."
rsync -a "$HOME/Downloads/" "$BACKUP_DIR/downloads/" 2>/dev/null

# Create zip file
echo "🗜️  Creating zip file..."
cd "/tmp" && zip -r "$ZIP_FILE" "$BACKUP_NAME"

# Clean up temporary directory
rm -rf "$BACKUP_DIR"

echo "✅ Backup completed: $ZIP_FILE"
echo "📊 File size: $(du -h "$ZIP_FILE" | cut -f1)"
