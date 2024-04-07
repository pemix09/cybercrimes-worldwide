#!/bin/sh

# get filename from first argument
filename="$1"

#from file read columns and save them to variables
while IFS=, read -r Timestamp SourceIP DestinationIP SourcePort DestinationPort Protocol PacketLength PacketType TrafficType PayloadData MalwareIndicators AnomalyScores Alerts AttackType AttackSignature ActionTaken SeverityLevel UserInformation DeviceInformation NetworkSegment GeoLocation ProxyInformation FirewallLogs IDSIPSAlerts LogSource
do
    echo "----------------------------"

    # -i - ignore case -E - pattern -A - after match
    sourceInfo=$(whois $SourceIP | grep -i -E 'city:|country:')
    sourceCity=$( echo "$sourceInfo" | grep -i -E 'city:|City:' | cut -w -f2)
    sourceCountry=$( echo "$sourceInfo" | grep -i -E 'country:|Country:' | cut -w -f2)

    echo "source city: $sourceCity"
    echo "source country: $sourceCountry"
    
    
    destInfo=$(whois $DestinationIP | grep -i -E 'city:|country:')
    destCity=$( echo "$destInfo" | grep -i -E 'city:|City:' | cut -w -f2)
    destCountry=$( echo "$destInfo" | grep -i -E 'country:|Country:' | cut -w -f2)

    echo "destination city: $destCity"
    echo "destination country: $destCountry"

done < "$filename"