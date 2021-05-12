#!/bin/bash -li

putanja=$(echo "$(cd "$(dirname "$0")" && pwd )")

python3 -m venv "$putanja"/bbb-player/env && source "$putanja"/bbb-player/env/bin/activate

echo -e 'Virtualnog okruzenja je kreirano\n'

pip install -r "$putanja"/bbb-player/requirements.txt

echo -e '\nSvi potrebni programi su instalirani\n'

source "$putanja"/bbb-player/env/bin/activate

echo 'Napravi stalni alias za skriptu (y|n)? '
read

if [[ "$REPLY" = 'y' || "$REPLY" = 'Y' ]]; then 
#    echo -e "export PATH=\"$PATH:$putanja\"" >> ~/.bash_profile
    echo -e "\n# BigBlueButton Player alias\nalias b3player=\"bash $putanja/b3player.sh\"" >> ~/.bash_aliases
    
    source ~/.bash_aliases
fi

mkdir "$putanja"/bbb-player/downloadedMeetings 2>/dev/null || echo -e "Direktorijum \"downloadedMeetings\" je vec kreiran\n"

python "$putanja"/bbb-player/bbb-player.py -s --no-check-certificate &

pid1=$!

sleep 1

echo -e "import webbrowser\\nwebbrowser.open_new_tab(\"http://localhost:5000/\")" | python

pid2=$!

wait $pid1 $pid2

deactivate

exit
