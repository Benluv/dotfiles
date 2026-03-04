#!/bin/bash
# Calls Windows PowerShell to get battery percentage
percent=$(powershell.exe -Command "(Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining" | tr -d '\r')
if [ -z "$percent" ]; then
  echo "100" # Fallback if desktop has no battery
else
  echo "$percent"
fi
