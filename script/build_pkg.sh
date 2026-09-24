#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# GLYPH Signal Studio — Sanitized & Privately Signed PKG Builder
# Ensures ZERO personal metadata, home directory paths, or user identifiers leak.
# ==============================================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_DIR="${ROOT_DIR}/release"
APP_NAME="GLYPH Studio"
VERSION="1.0.0"
BUNDLE_ID="com.glyphstudio.app"
PKG_IDENTIFIER="com.glyphstudio.app.pkg"
PKG_NAME="GLYPH-Studio-v1.0.0.pkg"
FINAL_PKG="${RELEASE_DIR}/${PKG_NAME}"
CHECKSUM_FILE="${RELEASE_DIR}/${PKG_NAME}.sha256"

echo "======================================================================"
echo " 📦 BUILDING SANITIZED & PRIVATELY SIGNED PKG: ${APP_NAME} v${VERSION}"
echo "======================================================================"

# 1. Ensure fresh Release build exists
make -C "${ROOT_DIR}" package

mkdir -p "${RELEASE_DIR}"
PAYLOAD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/glyph-pkg-payload.XXXXXX")"
trap 'rm -rf "${PAYLOAD_DIR}"' EXIT

echo "[1/6] Staging payload..."
cp -R "${RELEASE_DIR}/${APP_NAME}.app" "${PAYLOAD_DIR}/${APP_NAME}.app"

echo "[2/6] Sanitizing binary symbols and filesystem metadata..."
# Remove any AppleDouble, .DS_Store, or quarantine attributes
/usr/bin/xattr -cr "${PAYLOAD_DIR}" 2>/dev/null || true
/usr/bin/dot_clean -m "${PAYLOAD_DIR}" 2>/dev/null || true
find "${PAYLOAD_DIR}" \( -name '._*' -o -name '.DS_Store' \) -delete

# Strip non-global / debug symbols from binaries
if [ -f "${PAYLOAD_DIR}/${APP_NAME}.app/Contents/MacOS/GLYPHApp" ]; then
  strip -x "${PAYLOAD_DIR}/${APP_NAME}.app/Contents/MacOS/GLYPHApp" 2>/dev/null || true
fi
if [ -f "${PAYLOAD_DIR}/${APP_NAME}.app/Contents/Frameworks/GLYPHCore.framework/Versions/A/GLYPHCore" ]; then
  strip -x "${PAYLOAD_DIR}/${APP_NAME}.app/Contents/Frameworks/GLYPHCore.framework/Versions/A/GLYPHCore" 2>/dev/null || true
fi

echo "[3/6] Applying ad-hoc private code signatures..."
if [ -d "${PAYLOAD_DIR}/${APP_NAME}.app/Contents/Frameworks/GLYPHCore.framework" ]; then
  codesign --force --sign - --timestamp=none "${PAYLOAD_DIR}/${APP_NAME}.app/Contents/Frameworks/GLYPHCore.framework"
fi
codesign --force --sign - --timestamp=none "${PAYLOAD_DIR}/${APP_NAME}.app"
codesign --verify --deep --strict "${PAYLOAD_DIR}/${APP_NAME}.app"

sanitize_pkg_payload() {
  local package_path="$1"
  local work_dir
  local expanded_dir
  local payload_root
  local clean_payload
  local clean_package

  work_dir="$(mktemp -d "${TMPDIR:-/tmp}/glyph-pkg-clean.XXXXXX")"
  expanded_dir="${work_dir}/expanded"
  payload_root="${work_dir}/root"
  clean_payload="${expanded_dir}/Payload"
  clean_package="${work_dir}/clean.pkg"

  # Expand flat package
  pkgutil --expand "${package_path}" "${expanded_dir}"

  if [ -f "${expanded_dir}/Payload" ]; then
    mkdir -p "${payload_root}"
    # Unpack cpio archive
    (cd "${payload_root}" && gunzip -c "${expanded_dir}/Payload" | cpio -idm --quiet)
    find "${payload_root}" \( -name '._*' -o -name '.DS_Store' \) -delete

    # Re-pack cpio archive with root:wheel (0:0) ownership and no AppleDouble
    (
      cd "${payload_root}"
      COPYFILE_DISABLE=1 find . -print |
        LC_ALL=C sort |
        COPYFILE_DISABLE=1 cpio -o --format odc --owner 0:0 --quiet |
        gzip -c > "${clean_payload}"
    )

    # Filter AppleDouble and .DS_Store out of Bill of Materials (Bom)
    if [ -f "${expanded_dir}/Bom" ]; then
      local filtered_bom="${work_dir}/bom_filtered.txt"
      lsbom "${expanded_dir}/Bom" | grep -v -E '(^|/)\._|(^|/)\.DS_Store$' > "${filtered_bom}" || true
      mkbom -i "${filtered_bom}" "${expanded_dir}/Bom"
      local file_count
      file_count=$(wc -l < "${filtered_bom}" | tr -d ' ')
      if [ -f "${expanded_dir}/PackageInfo" ]; then
        sed -i '' -E "s/numberOfFiles=\"[0-9]+\"/numberOfFiles=\"${file_count}\"/g" "${expanded_dir}/PackageInfo"
      fi
    fi

    # Flatten back to final pkg
    pkgutil --flatten "${expanded_dir}" "${clean_package}"
    mv "${clean_package}" "${package_path}"
  fi
  rm -rf "${work_dir}"
}

echo "[4/6] Building .pkg installer with root/admin ownership sanitization..."
# --ownership recommended enforces root:admin, stripping local UID (501) and username
COPYFILE_DISABLE=1 pkgbuild \
  --root "${PAYLOAD_DIR}" \
  --install-location "/Applications" \
  --identifier "${PKG_IDENTIFIER}" \
  --version "${VERSION}" \
  --ownership recommended \
  --filter '(^|/)\._[^/]*$' \
  "${FINAL_PKG}"

echo " Sanitizing package payload & Bill of Materials..."
sanitize_pkg_payload "${FINAL_PKG}"

echo "[5/6] Privately code-signing the .pkg installer bundle..."
codesign --force --sign - --timestamp=none "${FINAL_PKG}"
codesign -dv --verbose=2 "${FINAL_PKG}"

echo "[6/6] Verifying privacy & zero-data leakage..."
# Check for any personal home directory leaks in package metadata
if strings "${FINAL_PKG}" | grep -q "/Users/${USER}"; then
  echo "❌ CRITICAL ERROR: Found personal path '/Users/${USER}' inside ${FINAL_PKG}!" >&2
  exit 1
fi

# Generate SHA-256 checksum
cd "${RELEASE_DIR}"
shasum -a 256 "${PKG_NAME}" | tee "${CHECKSUM_FILE}"

echo "======================================================================"
echo " ✅ SUCCESS: Sanitized installer ready!"
echo "    Package:  ${FINAL_PKG}"
echo "    Checksum: ${CHECKSUM_FILE}"
echo "======================================================================"
