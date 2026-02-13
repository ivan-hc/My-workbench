#!/bin/sh

# Clone AM
if [ ! -d ./AM ]; then
	git clone https://github.com/ivan-hc/AM.git
fi

FIVE_YEARS_AGO=$(date -u -d "1 years ago" +"%Y")

_archived_list() {
	user_repo=$(grep "^SITE=" "$arg" | head -1 | awk -F'"' '/^SITE=/{print $2}')
	if curl -s "https://api.gh.pkgforge.dev/repos/$user_repo" | grep -q '"archived".* true,'; then
		echo "$arg" | sed s:.*/:: >> archived-list.tmp
	fi
}

_obsolete_list() {
	user_repo=$(grep "^SITE=" "$arg" | head -1 | awk -F'"' '/^SITE=/{print $2}')
	date=$(curl -s "https://api.gh.pkgforge.dev/repos/$user_repo/releases" | grep -oP '"updated_at": "\K\d{4}' | head -1)
	if [ "$date" -lt "$FIVE_YEARS_AGO" ]; then
		echo "$arg $date" | sed s:.*/:: >> obsolete-list.tmp
	fi
}

# Determine archived repositories
for arg in AM/programs/x86_64/*; do
	if grep -q "^version=.*api.github.com" "$arg" && grep -q "^SITE=" "$arg"; then
		_archived_list &
	fi
done
wait

sort -u archived-list.tmp > archived-apps


# Determine repositories repositories no more updated in the last 5 years
for arg in AM/programs/x86_64/*; do
	if grep -q "^version=.*api.github.com" "$arg" && grep -q "^SITE=" "$arg"; then
		_obsolete_list &
	fi
done
wait

sort -u obsolete-list.tmp > obsolete-apps

rm -f archived-list.tmp obsolete-list.tmp
