[[ "$1" == "--verbose" ]] && v="1" # Enable verbose mode

function verbose {
	[[ "$v" == "1" ]] && echo -e "$1"
}

query=$(rofi -dmenu -P "Invidious | Search" -l 0 -width 500 | sed "s/+/%2B/g; s/ /+/g; s/'/&#39;/g")
verbose "Query: $query"

# Keskeytä, jos haku on tyhjä
[ -z $query ] && exit 0

notify-send -u low -t 4000 "Invidious" "Searching..."
website=$(curl -qs https://invidious.snopyta.org/search?q=$query)

# Get video results
results=$(echo "$website" | grep "<p>.*watch" | sed 's|<p><a href="|https://invidious.snopyta.org|g; s|">|;|g; s|</a></p>||g; s/^[[:space:]]*//g')

# Clean up results in case of special chars
results="$(echo "$results" | sed "s/&#39;/'/g")"

verbose "Results:\n$results"

# Get thumbnails
#thumbnails=$(echo "$website" | grep "<img.*thumbnail" | sed '/?sqp=/d; s|<img.*src="|https://invidious.snopyta.org|g; s|"/>||g; s/^[[:space:]]*//g' | nl -s ";")

# Show results in rofi menu
video_name=$(echo -e "$(echo "$results" | cut -d';' -f2)" | rofi -dmenu -l 10 -width 1280 -P "Results")
verbose "Video name: $video_name"

# Search for the link in results
notify-send -u low -t 4000 "Invidious" "Opening video:
$video_name"

verbose "Removing illegal characters"
video_name=$(echo "$video_name" | sed 's/\[//g; s/\]//g')
results=$(echo "$results" | sed 's/\[//g; s/\]//g')

verbose "Looking for the correct line"
urlLine=$(echo "$results" | grep ";$video_name$")
verbose "URL Line: $urlLine"
url=$(echo "$urlLine" | cut -d';' -f1)

verbose "Url: $url"

# Open the video in mpv
mpv --ytdl-format="bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio/best" $url
