#!/bin/sh

# get filename from first argument
filename="$1"
destinationFileName="processed-with-source-dest,proxy$filename"
processedLineNumber=0

#from file read columns and save them to variables
while IFS=, read -r Timestamp SourceIP DestinationIP SourcePort DestinationPort Protocol PacketLength PacketType TrafficType PayloadData MalwareIndicators AnomalyScores Alerts AttackType AttackSignature ActionTaken SeverityLevel UserInformation DeviceInformation NetworkSegment GeoLocation ProxyInformation FirewallLogs IDSIPSAlerts LogSource
do
    # -i - ignore case -E - pattern -A - after match
    sourceInfo=$(whois $SourceIP | grep -i -E 'city:|country:')
    sourceCity=$( echo "$sourceInfo" | grep -i -E 'city:|City:' | cut -w -f2)
    sourceCountry=$( echo "$sourceInfo" | grep -i -E 'country:|Country:' | cut -w -f2)
    
    destInfo=$(whois $DestinationIP | grep -i -E 'city:|country:')
    destCity=$( echo "$destInfo" | grep -i -E 'city:|City:' | cut -w -f2)
    destCountry=$( echo "$destInfo" | grep -i -E 'country:|Country:' | cut -w -f2)

    proxyInfo=$(whois $ProxyInformation | grep -i -E 'city:|country:')
    proxyCity=$( echo "$proxyInfo" | grep -i -E 'city:|City:' | cut -w -f2)
    proxyCountry=$( echo "$proxyInfo" | grep -i -E 'country:|Country:' | cut -w -f2)

    newLine="$Timestamp,$SourceIP,$DestinationIP,$SourcePort,$DestinationPort,$Protocol,$PacketLength,$PacketType,$TrafficType,$PayloadData,$MalwareIndicators,$AnomalyScores,$Alerts,$AttackType,$AttackSignature,$ActionTaken,$SeverityLevel,$UserInformation,$DeviceInformation,$NetworkSegment,$GeoLocation,$ProxyInformation,$FirewallLogs,$IDSIPSAlerts,$LogSource,$destCity,$destCountry,$sourceCity,$sourceCountry,$proxyCity,$proxyCountry"

    processedLineNumber=$((processedLineNumber+1))
    echo "Number of processed lines: $processedLineNumber"
    echo $newLine >> $destinationFileName
done < "$filename"

echo "Processing finished. Processed lines: $processedLineNumber"