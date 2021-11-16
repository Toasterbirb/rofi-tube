instance="invidious.snopyta.org"

[[ "$1" == "--verbose" ]] && v="1" # Enable verbose mode

function verbose {
	[[ "$v" == "1" ]] && echo -e "$1"
}

query=$(rofi -dmenu -P "Invidious | Search" -l 0 -width 500 | sed "s/+/%2B/g; s/ /+/g; s/'/&#39;/g")
verbose "Query: $query"

# Keskeytä, jos haku on tyhjä
[ -z $query ] && exit 0

notify-send -u low -t 4000 "Invidious" "Searching..."
website=$(curl -qs https://${instance}/api/v1/search?q=${query})

# Get video results
results=$(jq '.[] | {title, videoId}' <<< "$website")
video_titles=$(jq -r '.title' <<< "$results")
verbose "Results:\n$video_titles"

# Show results in rofi menu
video_name=$(rofi -dmenu -l 10 -wdith 1280 -P "Results" <<< $video_titles)
verbose "Video name: $video_name"

# Search for the link in results
notify-send -u low -t 4000 "Invidious" "Opening video:
$video_name"

videoID=$(jq -r "select(.title == \"${video_name}\").videoId" <<< $results)
url="https://${instance}/watch?v=$videoID"

verbose "Url: $url"

# Open the video in mpv
mpv --ytdl-format="bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio/best" "$url"
