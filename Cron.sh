#!/bin/bash

CRONTEMP="/tmp/current_cron.$$"

print_menu() {
  echo ""
  echo "=========================="
  echo "  Cron Manager (Admin Mode)"
  echo "=========================="
  echo "1) List Cron Jobs"
  echo "2) Add Cron Job"
  echo "3) Delete Cron Job"
  echo "4) Disable Cron Job"
  echo "5) Enable Cron Job"
  echo "6) Exit"
  echo ""
}

use_sudo_for_user() {
  [[ "$1" != "$(whoami)" ]] || [[ "$1" == "root" ]]
}

get_crontab() {
  local user="$1"
  if use_sudo_for_user "$user"; then
    sudo crontab -l -u "$user" 2>/dev/null
  else
    crontab -l -u "$user" 2>/dev/null
  fi
}

save_crontab() {
  local user="$1"
  local file="$2"
  if use_sudo_for_user "$user"; then
    sudo crontab -u "$user" "$file"
  else
    crontab -u "$user" "$file"
  fi
}

list_cron_jobs() {
  read -p "Enter user to view (blank = current): " user
  user=${user:-$(whoami)}
  echo ""
  echo "📋 Current Cron Jobs for user [$user]:"
  local jobs
  jobs=$(get_crontab "$user")
  if [[ -z "$jobs" ]]; then
    echo ""
    echo "No cron jobs found."
  else
    echo ""
    echo "$jobs" | nl -w2 -s'. '
  fi
}

add_cron_job() {
  echo ""
  echo "➕ Add a new cron job"
  read -p "Enter user to execute as [default: $(whoami)]: " user
  [[ -z "$user" ]] && user=$(whoami)

  echo ""
  echo "Choose time specification:"
  echo "1) Custom (minute, hour, etc.)"
  echo "2) @reboot"
  echo "3) @daily"
  echo "4) @weekly"
  echo "5) @monthly"
  echo "6) @yearly"
  echo "7) Cancel"
  echo ""
  read -p "Enter choice [1-7]: " timing_choice

  case $timing_choice in
    1)
      read -p "Minute (0-59): " min
      read -p "Hour (0-23): " hour
      read -p "Day of Month (1-31): " dom
      read -p "Month (1-12): " mon
      read -p "Day of Week (0-6): " dow
      schedule="$min $hour $dom $mon $dow"
      ;;
    2) schedule="@reboot" ;;
    3) schedule="@daily" ;;
    4) schedule="@weekly" ;;
    5) schedule="@monthly" ;;
    6) schedule="@yearly" ;;
    *) echo "❌ Cancelled."; return ;;
  esac

  read -p "Enter the full command to run: " command
  echo ""
  if ! command -v "${command%% *}" &>/dev/null; then
    echo ""
    echo "⚠️ Warning: '${command%% *}' not found. Proceed anyway? (y/n)"
    read confirm
    [[ "$confirm" != "y" ]] && return
  fi

  cron_entry="$schedule $command"
  get_crontab "$user" > "$CRONTEMP" 2>/dev/null || touch "$CRONTEMP"
  echo "$cron_entry" >> "$CRONTEMP"
  save_crontab "$user" "$CRONTEMP"

  echo ""
  echo "✅ Cron job added for user [$user]."
}

delete_cron_job() {
  read -p "Enter user to modify [default: $(whoami)]: " user
  [[ -z "$user" ]] && user=$(whoami)

  get_crontab "$user" > "$CRONTEMP" || touch "$CRONTEMP"
  echo ""
  list_cron_jobs "$user"
  echo ""
  read -p "Enter job number to delete: " job_number
  sed "${job_number}d" "$CRONTEMP" > "${CRONTEMP}.tmp"
  mv "${CRONTEMP}.tmp" "$CRONTEMP"
  save_crontab "$user" "$CRONTEMP"
  echo ""
  echo "🗑️ Cron job #$job_number deleted."
}

disable_cron_job() {
  read -p "Enter user to modify [default: $(whoami)]: " user
  [[ -z "$user" ]] && user=$(whoami)

  get_crontab "$user" > "$CRONTEMP" || touch "$CRONTEMP"
  echo ""
  list_cron_jobs "$user"
  echo ""
  read -p "Enter job number to disable: " job_number
  sed -i "${job_number}s/^/#DISABLED: /" "$CRONTEMP"
  save_crontab "$user" "$CRONTEMP"
  echo ""
  echo "🚫 Cron job #$job_number disabled."
}

enable_cron_job() {
  read -p "Enter user to modify [default: $(whoami)]: " user
  [[ -z "$user" ]] && user=$(whoami)

  get_crontab "$user" > "$CRONTEMP" || touch "$CRONTEMP"
  echo ""
  grep '^#DISABLED: ' "$CRONTEMP" | nl -w2 -s'. '
  echo ""
  read -p "Enter job number to enable (from above list): " job_number

  # Find the actual disabled lines
  mapfile -t disabled_jobs < <(grep '^#DISABLED: ' "$CRONTEMP")
  if [[ "$job_number" =~ ^[0-9]+$ ]] && (( job_number >= 1 && job_number <= ${#disabled_jobs[@]} )); then
    disabled_line="${disabled_jobs[$((job_number - 1))]}"
    enabled_line="${disabled_line//#DISABLED: /}"
    sed -i "s|$disabled_line|$enabled_line|" "$CRONTEMP"
    save_crontab "$user" "$CRONTEMP"
    echo ""
    echo "✅ Cron job #$job_number enabled."
  else
    echo ""
    echo "❌ Invalid job number."
  fi
}

while true; do
  print_menu
  read -p "Choose an option [1-6]: " option
  echo ""
  case "$option" in
    1) list_cron_jobs ;;
    2) add_cron_job ;;
    3) delete_cron_job ;;
    4) disable_cron_job ;;
    5) enable_cron_job ;;
    6) echo "👋 Goodbye!" ; exit ;;
    *) echo "❌ Invalid option." ;;
  esac
done
