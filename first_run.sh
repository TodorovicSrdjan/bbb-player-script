#!/bin/bash

putanja=$(echo "$(cd "$(dirname "$0")" && pwd )")

url="https://github.com/andrazznidar/bbb-player.git"

git clone $url && mv bbb-player .bbb-player || echo "Problem sa git-om ili komandom mv"; sudo apt-get install git; git clone $url && mv bbb-player .bbb-player|| exit 1

python3 -m venv "$putanja"/.bbb-player/env && source "$putanja"/.bbb-player/env/bin/activate || echo -e "\"venv\" nije instaliran"; sudo apt-get install python3-venv; python3 -m venv "$putanja"/.bbb-player/env && source "$putanja"/.bbb-player/env/bin/activate || exit 2

echo -e '\nVirtualnog okruzenja je kreirano\n'

pip install -r "$putanja"/.bbb-player/requirements.txt

echo -e '\nSvi potrebni programi su instalirani\n'

source "$putanja"/.bbb-player/env/bin/activate

echo 'Napravi stalni alias za skriptu (y|n)? '
read

if [[ "$REPLY" = 'y' || "$REPLY" = 'Y' ]]; then 
#    echo -e "export PATH=\"$PATH:$putanja\"" >> ~/.bash_profile
    echo -e "\n# BigBlueButton Player alias\nalias b3player=\"bash $putanja/b3player.sh\"" >> ~/.bash_aliases
    
    source ~/.bash_aliases
fi

mkdir "$putanja"/.bbb-player/downloadedMeetings 2>/dev/null || echo -e "Direktorijum \"downloadedMeetings\" je vec kreiran\n"

python "$putanja"/.bbb-player/bbb-player.py -s --no-check-certificate &

pid1=$!

sleep 1

echo -e "import webbrowser\\nwebbrowser.open_new_tab(\"http://localhost:5000/\")" | python

pid2=$!

wait $pid2

kill -9 $pid1

deactivate

exit
