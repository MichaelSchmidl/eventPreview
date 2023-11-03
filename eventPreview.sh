#!/bin/bash

# Aufruf mit
#    LC_ALL=de_DE.UTF-8 /Users/mike/eventPreview.sh
#
# Ansonsten werden keine deutschen Wochentage angezeigt!
#
# icalBuddy scheint immer mit UTC zu rechnen. Daher muss man
# in showTodaysEvents() mit Sommer- und Winterzeit tricksen

#########################################################################################
showUpcommingEvents () {
   echo "$(date -v +2d +%A), $(date -v +2d '+%d.%B')"
   echo "-----------------"
   /usr/local/bin/icalBuddy -nc eventsFrom:today+2 to:today+2
   /usr/local/bin/reminders show-all | grep "(in 1 Tag" | cut -d: -f3- | sed "s/(in 1 Tag)//" | sed "s/^\ /* /g"
   echo ""

   for a in {3..7}
   do
      echo "$(date -v +${a}d +%A), $(date -v +${a}d '+%d.%B')"
      echo "-----------------"
      /usr/local/bin/icalBuddy -nc eventsFrom:today+${a} to:today+${a}
      /usr/local/bin/reminders show-all | grep "(in $((a-1)) Tagen" | cut -d: -f3- | sed "s/(in $((a-1)) Tagen)//" | sed "s/^\ /* /g"
      echo ""
   done

   echo ""
   echo ""
   echo "Vorschau"
   echo "-----------"
   /usr/local/bin/icalBuddy -nc -ic CountDown eventsFrom:today+1 to:today+365
}

#########################################################################################
showTomorrowEvents () {
    echo "Termine morgen, $(date -v +1d +%A), $(date -v +1d '+%d.%B')"
    echo "--------------------------------"
    /usr/local/bin/icalBuddy -nc eventsFrom:tomorrow to:tomorrow
    echo ""
    
    echo ""
    echo "demnächst zu erledigen"
    echo "----------------------"
    /usr/local/bin/reminders show-all | grep "(in" | grep -e "Stund" -e "Minute" | cut -d: -f3- | sed "s/^\ /* /g"
    echo ""
    
    echo ""
    echo "zu erledigen"
    echo "-----------"
    /usr/local/bin/reminders show-all | grep -v "(" | grep -v "Leihliste" | cut -d: -f3- | sed "s/^\ /* /g"
}

#########################################################################################
showTodaysEvents () {
   echo "Termine heute"
   echo "------------"
   if [ "$(date +%Z)" == "CET" ]; then
      # CET = normal
      /usr/local/bin/icalBuddy -nc eventsFrom:"$(date "+%Y-%m-%d %H:%M:%S") +0100" to:"$(date "+%Y-%m-%d 23:59:59") +0100"
   else
      # CEST = DST
      /usr/local/bin/icalBuddy -nc eventsFrom:"$(date "+%Y-%m-%d %H:%M:%S") +0200" to:"$(date "+%Y-%m-%d 23:59:59") +0200"
   fi
   echo ""
   
   echo ""
   echo "heutige Aufgaben"
   echo "---------------"
   /usr/local/bin/reminders show-all | grep "(vor" | cut -d: -f3- | sed "s/^\ /* /g"
}

#########################################################################################
if [ "$1" == "upcomming" ]; then
   showUpcommingEvents
elif [ "$1" == "tomorrow" ]; then
   showTomorrowEvents
elif [ "$1" == "now" ]; then
   showTodaysEvents
else
   echo "usage: $0 [upcomming] [tomorrow] [now]"
fi
