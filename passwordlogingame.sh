#!/bin/bash
clear
echo "

███████ ███    ██ ████████ ███████ ██████      ██████   █████  ███████ ███████ ██     ██  ██████  ██████  ██████
██      ████   ██    ██    ██      ██   ██     ██   ██ ██   ██ ██      ██      ██     ██ ██    ██ ██   ██ ██   ██
█████   ██ ██  ██    ██    █████   ██████      ██████  ███████ ███████ ███████ ██  █  ██ ██    ██ ██████  ██   ██
██      ██  ██ ██    ██    ██      ██   ██     ██      ██   ██      ██      ██ ██ ███ ██ ██    ██ ██   ██ ██   ██
███████ ██   ████    ██    ███████ ██   ██     ██      ██   ██ ███████ ███████  ███ ███   ██████  ██   ██ ██████
"
echo ""

attempts=1                                        # Initial attempts is 1
while true;                                       # Run forever until exit
do
        read -p "Password: " pass
    if [[ $pass = "Password123" ]]; then
        clear 
        echo "

███████ ███    ██ ████████ ███████ ██████      ██████   █████  ███████ ███████ ██     ██  ██████  ██████  ██████
██      ████   ██    ██    ██      ██   ██     ██   ██ ██   ██ ██      ██      ██     ██ ██    ██ ██   ██ ██   ██
█████   ██ ██  ██    ██    █████   ██████      ██████  ███████ ███████ ███████ ██  █  ██ ██    ██ ██████  ██   ██
██      ██  ██ ██    ██    ██      ██   ██     ██      ██   ██      ██      ██ ██ ███ ██ ██    ██ ██   ██ ██   ██
███████ ██   ████    ██    ███████ ██   ██     ██      ██   ██ ███████ ███████  ███ ███   ██████  ██   ██ ██████
"
echo ""
echo "Access Granted!"
echo ""
        echo "Congratulations. It took "$attempts" attempts"
       echo ""
        exit                                       # Exit program here
    fi
    if [[ $pass != "Password123" ]]; then
        clear
        echo "

███████ ███    ██ ████████ ███████ ██████      ██████   █████  ███████ ███████ ██     ██  ██████  ██████  ██████
██      ████   ██    ██    ██      ██   ██     ██   ██ ██   ██ ██      ██      ██     ██ ██    ██ ██   ██ ██   ██
█████   ██ ██  ██    ██    █████   ██████      ██████  ███████ ███████ ███████ ██  █  ██ ██    ██ ██████  ██   ██
██      ██  ██ ██    ██    ██      ██   ██     ██      ██   ██      ██      ██ ██ ███ ██ ██    ██ ██   ██ ██   ██
███████ ██   ████    ██    ███████ ██   ██     ██      ██   ██ ███████ ███████  ███ ███   ██████  ██   ██ ██████
"
            echo "Access Denied! - Attempts so far: $attempts"
        (( attempts ++ ))
    fi
done
