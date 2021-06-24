# bbb-player-script 

Skripte za skidanje BigBlueButton snimaka korišćenjem projekta [bbb-player](https://github.com/andrazznidar/bbb-player).

Skripta skida navedeni projekat, instalira potrebne biblioteke i omogućava jednostavnije skidanja jednog ili više snimaka.

Skriptu `first_run.sh` pokrenuti samo jednom komandom `sudo bash first_run.sh`. 
Nakon njenog pokretanja, sve potrebne biblioteke će biti instalirane i možete koristi glavnu skriptu pomoću komande `bash b3player.sh` ili samo komandom `b3player` ukoliko se odobrili kreiranje alias-a

Glavna prednost ove skripte je mogućnost preuzimanje snimaka uz pomoć fajla u kome se nalaze link i naziv za svaki meeting. 
To omogućava preuzimanje većeg broja meeting-a bez potrebe da korisnik pre svakog preuzimanja unosi date podatke i čeka da da se preuzimanje završi da bi otpočeo novo.

Takođe, postoji mogućnost da se kreira alias kojim će se skripta pozivati iz bilo kog direktorijuma.

Fajlovi i direktorijumi meeting-a se nalaze u `putanja/do/skripti/.bbb-player/downloadedMeetings/`

## Korišćenje

```
Usage: b3player [ -h | -f <source> | <link> <name> ]
       b3player [ --help | --file <source> | <link> <name> ]
    
    -h | --help:
           prints this message
    
    -f <source> | --file <source>:
           takes file as input source. Each line should have URI and meeting name, separated by an space character
```

