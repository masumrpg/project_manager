#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter command not found. Please ensure Flutter is installed and in PATH." >&2
  exit 1
fi

flutter build linux --release

VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //; s/+.*//')
PKG_NAME="project-manager"
APP_ID="com.projectmanager.ProjectManager"
APP_DISPLAY_NAME="Project Manager"
APP_SUPPORT_DIR="$APP_ID"
HIVE_SUBDIR="hive"
ARCH="amd64"
DIST_DIR="$ROOT_DIR/dist/linux"
PKG_DIR="$DIST_DIR/${PKG_NAME}_${VERSION}_${ARCH}"
BUNDLE_DIR="$ROOT_DIR/build/linux/x64/release/bundle"

rm -rf "$PKG_DIR" "$DIST_DIR/${PKG_NAME}_${VERSION}_${ARCH}.deb"

mkdir -p \
  "$PKG_DIR/DEBIAN" \
  "$PKG_DIR/usr/bin" \
  "$PKG_DIR/usr/lib/$PKG_NAME" \
  "$PKG_DIR/usr/share/applications" \
  "$PKG_DIR/usr/share/icons/hicolor"

cp -r "$BUNDLE_DIR"/. "$PKG_DIR/usr/lib/$PKG_NAME/"

cat <<DESKTOP > "$PKG_DIR/usr/share/applications/${APP_ID}.desktop"
[Desktop Entry]
Name=$APP_DISPLAY_NAME
Comment=Organize and track your projects
Exec=project-manager
Icon=project-manager
Terminal=false
Type=Application
Categories=Utility;Productivity;
StartupWMClass=$APP_ID
DESKTOP

cat <<'LAUNCHER' > "$PKG_DIR/usr/bin/project-manager"
#!/bin/sh
exec /usr/lib/project-manager/project_manager "$@"
LAUNCHER
chmod 755 "$PKG_DIR/usr/bin/project-manager"

# Copy icon theme assets.
ICON_SOURCE_DIR="$ROOT_DIR/linux/runner/resources/icons/hicolor"
if [ -d "$ICON_SOURCE_DIR" ]; then
  find "$ICON_SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r size_dir; do
    rel_dir="${size_dir#$ICON_SOURCE_DIR/}"
    install_dir="$PKG_DIR/usr/share/icons/hicolor/$rel_dir/apps"
    mkdir -p "$install_dir"
    cp "$size_dir/apps/project-manager.png" "$install_dir/"
  done
fi

cat <<CONTROL > "$PKG_DIR/DEBIAN/control"
Package: $PKG_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: Project Manager Team <support@example.com>
Depends: libgtk-3-0 (>= 3.22), libstdc++6 (>= 9)
Description: Flutter-based project management dashboard
 Manage and track your projects with a modern desktop experience.
CONTROL

cat <<POSTINST > "$PKG_DIR/DEBIAN/postinst"
#!/bin/sh
set -e
cd /
rm -f /usr/share/applications/project-manager.desktop || true
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
POSTINST
chmod 755 "$PKG_DIR/DEBIAN/postinst"

cleanup_user_state() {
  user="\$1"
  [ -n "\$user" ] || return
  home_dir="\$(getent passwd "\$user" | cut -d: -f6 2>/dev/null)"
  [ -n "\$home_dir" ] || return

  rm -rf "\$home_dir/.local/share/$APP_SUPPORT_DIR" \
         "\$home_dir/.local/share/$APP_SUPPORT_DIR/$HIVE_SUBDIR" \
         "\$home_dir/.local/share/project_manager" \
         "\$home_dir/Documents/project_manager"
}

cat <<POSTRM > "$PKG_DIR/DEBIAN/postrm"
#!/bin/sh
set -e
cd /
rm -f /usr/share/applications/project-manager.desktop || true
if [ -n "\$SUDO_USER" ] && [ "\$SUDO_USER" != "root" ]; then
  cleanup_user_state "\$SUDO_USER"
fi
installer_user="\$(logname 2>/dev/null || true)"
if [ -n "\$installer_user" ] && [ "\$installer_user" != "root" ]; then
  cleanup_user_state "\$installer_user"
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
POSTRM
chmod 755 "$PKG_DIR/DEBIAN/postrm"

dpkg-deb --build "$PKG_DIR"
echo "Created Debian package: $DIST_DIR/${PKG_NAME}_${VERSION}_${ARCH}.deb"
