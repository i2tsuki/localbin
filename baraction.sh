#!/bin/sh

set -u

exec 2>&1

{
  while (pgrep conky)
  do
      echo "kill -s KILL pgrep conky"
      kill -s KILL $(pgrep conky)
      sleep 1s
  done

  while (pgrep polybar)
  do
      echo "pkill -x polybar"
      pkill -x polybar
      sleep 1s
  done

  DISPLAYS="$(xrandr -q | grep -E '[^dis]*connected' -o --color=none | cut -d ' ' -f 1 | grep -v 'connected' --color=none | tr '\n' ' ')"
  for i in ${DISPLAYS}
  do
      echo $i
      if [ $i = "eDP-1" ]; then
	  echo "polybar top &"
          polybar top &
      elif [ $i = "DP-1" ]; then
	  echo "polybar top-DP-1 &"
          polybar top-DP-1 &
      fi
  done

  echo "Launching polybar"
} | ts '[%Y-%m-%d %H:%M:%S]' >> ${HOME}/.baraction-errors
