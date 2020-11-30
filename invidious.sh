query=$(rofi -dmenu -P "Invidious | Search" -l 0 -width 500 | sed 's/+/%2B/g; s/ /+/g')

# Keskeytä, jos haku on tyhjä
[ -z $query ] && exit 0

notify-send -u low -t 4000 "Invidious" "Searching: $(echo $query | sed 's/+/ /g')"
website=$(curl -qs https://invidious.snopyta.org/search?q=$query)

# Get video results
results=$(echo "$website" | grep "<p>.*watch" | sed 's|<p><a href="|https://invidious.snopyta.org|g; s|">|;|g; s|</a></p>||g; s/^[[:space:]]*//g')
echo "$results"

# Get thumbnails
#thumbnails=$(echo "$website" | grep "<img.*thumbnail" | sed '/?sqp=/d; s|<img.*src="|https://invidious.snopyta.org|g; s|"/>||g; s/^[[:space:]]*//g' | nl -s ";")

# Show results in rofi menu
video_name=$(echo -e "$(echo "$results" | cut -d';' -f2)" | rofi -dmenu -l 10 -width 1280 -P "Results")
echo "Video name: $video_name"

# Keskeytä, jos videota ei valittu
[ -z $video_name ] && exit 0

# Search for the link in results
notify-send -u low -t 4000 "Invidious" "Opening video:
$video_name"

echo "Looking for the correct line"
urlLine=$(echo "$results" | grep ";$video_name$")
echo "URL Line: $urlLine"
url=$(echo "$urlLine" | cut -d';' -f1)

echo "Url: $url"

# Open the video in mpv
mpv --ytdl-format="bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio/best" $url
