#!/bin/bash

HELP_MSG=$(cat <<'END'
Usage: b3player [ -h | -f <source> | <link> <name> ]
	   b3player [ --help | --file <source> | <link> <name> ]

-h | --help:
	   prints this message

-f <source> | --file <source>:
	   takes file as input source. Each line should have URI and meeting name, separated by an space character
END
)

PERM_ALIAS_MSG=$(cat <<'END'
Note: 
If alias has been already added once it needs to be deleted manually.
Instructions:
 1. Find the alias at the end of the file "~/.bash_aliases"
 2. Delete line "# BigBlueButton Player alias" and the following line
END
# 3. Delete $SCRIPT_PATH from system variable PATH
)

##############################################################################

# Number of seconds after which the request for downloading the next meeting is sent
REQ_DELAY=5

if [[ $# > 2 ]]; then
    
    echo -e "b3player: submitted more then 2 arguments\nTry 'b3player -h' for more information."
    exit 1
elif [[ $# = 1 ]]; then   
    echo -e "$HELP_MSG\n"
    
    if [[ "$1" = '-h' || "$1" = '--help' ]]; then
        exit 0
    else
        exit 1
    fi
fi

SCRIPT_PATH=$(echo "$(cd "$(dirname "$0")" && pwd )")

{ python3 -m venv "$SCRIPT_PATH"/.bbb-player/env && source "$SCRIPT_PATH"/.bbb-player/env/bin/activate;} || { echo -e "\"venv\" is not installed. Please run first_run.sh to fix that." && exit 2; }

echo -e 'Virtual environment is created\n'

if [[ $# = 2 ]]; then
    
    if [[ "$1" = '-f' || "$1" = '--file' ]]; then
        
        cat "$2" | while read line 
        do
            
            IFS=' ' read link title <<< $line
            python "$SCRIPT_PATH"/.bbb-player/bbb-player.py -d "$link" -n "$title" --no-check-certificate #&
            
            sleep $REQ_DELAY
        done
    else 
        python "$SCRIPT_PATH"/.bbb-player/bbb-player.py -d "$1" -n "$2" --no-check-certificate
    fi
    
    deactivate
    
    exit 0
fi

select selected_option in 'Download meeting' 'Watch meeting' 'Add permanent alias' 'Quit'
do
    case $selected_option in
    'Download meeting')
    
        echo 'Do you want to download more than one meeting?' 
        read
        if [[ "$REPLY" = 'y' || "$REPLY" = 'Y' ]]; then
            echo '\nEnter the path to file with required information (titles, links, etc.): '
            read
            
            cat "$REPLY" | while read line 
            do
                
                IFS=' ' read link title <<< $line
                python "$SCRIPT_PATH"/.bbb-player/bbb-player.py -d "$link" -n "$title" --no-check-certificate #&
            
                sleep $REQ_DELAY
                
            done
            
            echo -e "\nMeetings are donwloaded\n"
        
        else
            echo -e "\nEnter link: "
            read link
            
            echo -e "\nEnter meeting title: "
            read title
            
            python "$SCRIPT_PATH"/.bbb-player/bbb-player.py -d "$link" -n "$title" --no-check-certificate
        fi
        ;;
        
    'Watch meeting')
        # start server
        python "$SCRIPT_PATH"/.bbb-player/bbb-player.py -s --no-check-certificate &
        pid1=$!
        
        sleep 1
        
        # open page in default browser
        echo -e "import webbrowser\\nwebbrowser.open_new_tab(\"http://localhost:5000/\")" | python
        pid2=$!
        
        wait $pid1 $pid2
        
        deactivate
        echo "Server is terminated."
        exit 0
        ;;
        
    'Add permanent alias')
        
        echo -e "$PERM_ALIAS_MSG\n"
        
        echo 'Are you sure you want to add permanent alias? (y|n)'
        read
        
        if [[ "$REPLY" = 'y' || "$REPLY" = 'Y' ]]; then
            
#            echo -e "export PATH=\"$PATH:$SCRIPT_PATH\"" >> ~/.bash_profile
            echo -e "\n# BigBlueButton Player alias\nalias b3player=\"bash $SCRIPT_PATH/b3player.sh\"" >> ~/.bash_aliases
            
            source ~/.bashrc
        fi
        ;;
        
    'Quit')
        deactivate
        exit 0
        ;;
        
    *)
        echo 'Unknown option. Please try again'
        ;;
    esac
done
