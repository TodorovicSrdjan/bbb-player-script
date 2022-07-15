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
Napomena: Ukoliko je alias vec jednom dodat potrebno je da se manuelno obrise.
Instrukcije za manuelno brisanje:
 Alias se nalazi dnu fajla "~/.bash_aliases". Obrisite liniju koja sadrzi sledeci tekst
 "# BigBlueButton Player alias" i liniju ispod nje.
END
# Takodje, potrebno je izbrisati putanju $putanja iz sistemske promenljive PATH
)

##############################################################################

# Broj sekundi nakon kojih se salje zahtev za skidanje sledeceg snimka
REQ_DELAY=5

if [[ $# > 2 ]]; then
    
    echo 'Moguce je prosledini najvise 2 argumenta'
    exit 1
elif [[ $# = 1 ]]; then   
    echo -e "$HELP_MSG\n"
    
    if [[ "$1" = '-h' || "$1" = '--help' ]]; then
        exit 0
    else
        exit 1
    fi
fi

putanja=$(echo "$(cd "$(dirname "$0")" && pwd )")

{ python3 -m venv "$putanja"/.bbb-player/env && source "$putanja"/.bbb-player/env/bin/activate;} || { echo -e "\"venv\" nije instaliran. Pokrenite skriptu first_run.sh" && exit 2; }

echo -e 'Virtualnog okruzenja je kreirano\n'

if [[ $# = 2 ]]; then
    
    if [[ "$1" = '-f' || "$1" = '--file' ]]; then
        
        cat "$2" | while read line 
        do
            
            IFS=' ' read link naziv <<< $line
            python "$putanja"/.bbb-player/bbb-player.py -d "$link" -n "$naziv" --no-check-certificate #&
            
            sleep $REQ_DELAY
        done
    else 
        python "$putanja"/.bbb-player/bbb-player.py -d "$1" -n "$2" --no-check-certificate
    fi
    
    deactivate
    
    exit 0
fi

select izbor in 'Skini meeting' 'Pregledaj meeting' 'Dodaj (trajni) alias' 'Izadji'
do
    case $izbor in
    'Skini meeting')
    
        echo 'Da li zelis da skines vise meeting-a?' 
        read
        if [[ "$REPLY" = 'y' || "$REPLY" = 'Y' ]]; then
            echo '\nUnesi putanju do fajla sa informacijama: '
            read
            
            cat "$REPLY" | while read line 
            do
                
                IFS=' ' read link naziv <<< $line
                python "$putanja"/.bbb-player/bbb-player.py -d "$link" -n "$naziv" --no-check-certificate #&
            
                sleep $REQ_DELAY
                
            done
            
            echo -e "\nSkidanje meetinga je zavrseno\n"
        
        else
            echo -e "\nUnesi link: "
            read link
            
            echo -e "\nUnesi naziv datog meeting-a: "
            read naziv
            
            python "$putanja"/.bbb-player/bbb-player.py -d "$link" -n "$naziv" --no-check-certificate
        fi
        ;;
        
    'Pregledaj meeting')
        # Pokrece server
        python "$putanja"/.bbb-player/bbb-player.py -s --no-check-certificate &
        pid1=$!
        
        sleep 1
        
        # Otvara stranicu u default-nom browseru
        echo -e "import webbrowser\\nwebbrowser.open_new_tab(\"http://localhost:5000/\")" | python
        pid2=$!
        
        wait $pid1 $pid2
        
        deactivate
        echo "Server je ugasen"
        exit 0
        ;;
        
    'Dodaj (trajni) alias')
        
        echo -e "$PERM_ALIAS_MSG\n"
        
        echo 'Da li zelite da nastavite sa dodavanjem aliasa (y|n)?'
        read
        
        if [[ "$REPLY" = 'y' || "$REPLY" = 'Y' ]]; then
            
#            echo -e "export PATH=\"$PATH:$putanja\"" >> ~/.bash_profile
            echo -e "\n# BigBlueButton Player alias\nalias b3player=\"bash $putanja/b3player.sh\"" >> ~/.bash_aliases
            
            source ~/.bashrc
        fi
        ;;
        
    'Izadji')
        deactivate
        exit 0
        ;;
        
    *)
        echo 'Nepoznata opcija. Pokusajte ponovo'
        ;;
    esac
done
