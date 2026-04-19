#!/bin/sh

ARCH="$(uname -m)"

busybox_utils=$(busybox --list | xargs)
utils="7z file curl $busybox_utils"

# --------------------- USE POTABLE2APPIMAGE TO CONVERT BINARIES IN APPIMAGES

_potable2appimage() {
	if ! command -v potable2appimage 1>/dev/null; then
		if [ ! -f ./potable2appimage ]; then
			echo " Downloading potable2appimage..." && curl -#Lo potable2appimage https://raw.githubusercontent.com/ivan-hc/portable2appimage/refs/heads/main/portable2appimage && chmod a+x ./potable2appimage || exit 1
		fi
		sed -i -- 's/ _appimagetool / _appimagetool --appimage-extract-and-run /g' ./potable2appimage
		./potable2appimage "$@"
	else
		sed -i -- 's/ _appimagetool / _appimagetool --appimage-extract-and-run /g' ./potable2appimage
		potable2appimage "$@"
	fi
}

# --------------------- ONELF

_onelf() {
	if ! command -v onelf 1>/dev/null; then
		if [ ! -f ./onelf ]; then
			echo " Downloading onelf..." && curl -#Lo onelf https://github.com/QaidVoid/onelf/releases/download/0.2.3/onelf-"$ARCH"-linux && chmod a+x ./onelf || exit 1
		fi
		./onelf "$@"
	else
		onelf "$@"
	fi
}

_use_onelf() {
	mkdir -p am-bins
	for b in $utils; do
		bin="$(which "$b" | head -1)"
		_onelf bundle-libs bins/"$b" --from-binary "$bin"
		_onelf pack bins/"$b" -o "$b".bin --command bin/"$b" --level 22
		mv "$b".bin am-bins/
	done
}

# --------------------- QUICK-SHARUN

_quick_sharun() {
	if ! command -v quick-sharun 1>/dev/null; then
		if [ ! -f ./quick-sharun ]; then
			echo " Downloading quick-sharun..." && curl -#Lo quick-sharun https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh && chmod a+x ./quick-sharun || exit 1
		fi
		./quick-sharun "$@"
	else
		quick-sharun "$@"
	fi
}

_use_quick_sharun() {
	for b in $utils; do
		_quick_sharun --make-static-bin --dst-dir am-bins "$(which "$b" | head -1)"
	done
}

# --------------------- SHARUN

_sharun() {
	if ! command -v sharun 1>/dev/null; then
		if [ ! -f ./sharun ]; then
			echo " Downloading sharun..." && curl -#Lo sharun https://github.com/VHSgunzo/sharun/releases/download/v0.8.1/sharun-"$ARCH" && chmod a+x ./sharun || exit 1
		fi
		./sharun "$@"
	else
		sharun "$@"
	fi
}

_use_sharun() {
	for b in $utils; do
		_sharun lib4bin --with-wrappe --dst-dir am-bins "$(which "$b" | head -1)"
	done
}

# --------------------- RUN ONE BETWEEN ONELF AND SHARUN

#_use_onelf
#_use_quick_sharun
_use_sharun

# --------------------- EXPORT TO APPIMAGES

#cd am-bins || exit 1
#executables=$(ls | xargs)
#for e in $executables; do _potable2appimage $e; done
#cd .. || exit 1

mv am-bins/* ./

echo "Success!"
