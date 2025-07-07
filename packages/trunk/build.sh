TERMUX_PKG_HOMEPAGE=https://trunkrs.dev/
TERMUX_PKG_DESCRIPTION="Build, bundle & ship your Rust WASM application to the web"
TERMUX_PKG_LICENSE="Apache-2.0,MIT"
TERMUX_PKG_MAINTAINER="Konstantin Podsvirov @podsvirov"
TERMUX_PKG_VERSION="0.21.14"
TERMUX_PKG_SRCURL=https://github.com/trunk-rs/trunk/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=8687bcf96bdc4decee88458745bbb760ad31dfd109e955cf455c2b64caeeae2f
TERMUX_PKG_BUILD_DEPENDS='openssl'
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_VERSION_REGEXP='\d+\.\d+\.\d+'

termux_pkg_auto_update() {
	local latest_release
	latest_release="$(git ls-remote --tags https://github.com/trunk-rs/trunk.git \
	| grep -oP "refs/tags/v${TERMUX_PKG_UPDATE_VERSION_REGEXP}$" \
	| sort -V \
	| tail -n1)"

	if [[ "${latest_release}" == "${TERMUX_PKG_VERSION}" ]]; then
		echo "INFO: No update needed. Already at version '${TERMUX_PKG_VERSION}'."
		return
	fi

	termux_pkg_upgrade_version "${latest_release}"
}

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs "$TERMUX_PKG_MAKE_PROCESSES" \
		--target "$CARGO_TARGET_NAME" \
		--release \
		--all-features
}

termux_step_make_install() {
	install -Dm755 -t "$TERMUX_PREFIX"/bin target/"$CARGO_TARGET_NAME"/release/trunk
}
