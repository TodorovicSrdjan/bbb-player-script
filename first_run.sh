#!/bin/bash

SCRIPT_PATH=$(echo "$(cd "$(dirname "$0")" && pwd )")

BBB_PLAYER_URL="https://github.com/andrazznidar/bbb-player.git"

{ git clone $BBB_PLAYER_URL && mv bbb-player .bbb-player; } || { echo "Problem with git or mv" && sudo apt-get install git -y && git clone $BBB_PLAYER_URL && mv bbb-player .bbb-player; } || exit 1

{ python3 -m venv "$SCRIPT_PATH"/.bbb-player/env && source "$SCRIPT_PATH"/.bbb-player/env/bin/activate; } || { echo -e "\"venv\" is not installed" && sudo apt-get install python3-venv -y && python3 -m venv "$SCRIPT_PATH"/.bbb-player/env && source "$SCRIPT_PATH"/.bbb-player/env/bin/activate; } || exit 2

echo -e '\nVirtual environment is created\n'

pip install -r "$SCRIPT_PATH"/.bbb-player/requirements.txt

echo -e '\nRequired programs are installed\n'

source "$SCRIPT_PATH"/.bbb-player/env/bin/activate

echo 'Create permanent alias for the script? (y|n) '
read

if [[ "$REPLY" = 'y' || "$REPLY" = 'Y' ]]; then 
#    echo -e "export PATH=\"$PATH:$SCRIPT_PATH\"" >> ~/.bash_profile
    echo -e "\n# BigBlueButton Player alias\nalias b3player=\"bash $SCRIPT_PATH/b3player.sh\"" >> ~/.bash_aliases
    
    source ~/.bash_aliases
fi

mkdir "$SCRIPT_PATH"/.bbb-player/downloadedMeetings 2>/dev/null || echo -e "Directorium \"downloadedMeetings\" already exists\n"

python "$SCRIPT_PATH"/.bbb-player/bbb-player.py -s --no-check-certificate &

pid1=$!

sleep 1

echo -e "import webbrowser\\nwebbrowser.open_new_tab(\"http://localhost:5000/\")" | python

pid2=$!

wait $pid2

kill -9 $pid1

deactivate

exit
