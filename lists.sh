#!/bin/sh

# Toolpacks list

toolpack_repo="https://github.com/Azathothas/Toolpacks"
ARCH=x86_64
toolpack_readme="https://bin.pkgforge.dev/${ARCH}/AM.txt"
export toolpack_name="1" toolpack_description="2" toolpack_site="3" toolpack_dl="4" toolpack_ver="5"
toolpack_md=$(curl -Ls "$toolpack_readme" | grep -v "\.appimage ")
TOOLPACK_NAMES=$(echo "$toolpack_md" | cut -d' ' -f2- | awk '{print $1}')
for toolpack in $TOOLPACK_NAMES; do
        toolpack_arg=$(echo "$toolpack_md" | grep -i "^| $toolpack " | tr '|' '\n' | cut -c 2- | grep .)
        && toolpack_about_description=$(echo "$toolpack_arg" | awk -F: "NR==$toolpack_description" | sed 's/ $/./g')
        && echo "◆ $toolpack : $toolpack_about_description" >> "./$ARCH-toolpack"
done
wait
sort "./$ARCH-toolpack" | uniq > "./$ARCH-toolpack-new" && mv "./$ARCH-toolpack-new" "./$ARCH-toolpack" || exit 1

# AppImages list

APPIMAGE_NAMES=$(curl -Ls https://portable-linux-apps.github.io/appimages.md | tr '/)' '\n' | grep -i ".md$" | uniq | sed 's/.md$//g' | grep -v "\[")
for appimage in $APPIMAGE_NAMES; do
        grep "◆ $appimage :" "./$ARCH-apps" >> "./$ARCH-appimages" &
done
wait