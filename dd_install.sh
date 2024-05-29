#!/bin/bash

# Prompt for the Datadog API key
read -p "Enter your Datadog API key: " DD_API_KEY

# Validate the API key is not empty
if [[ -z "$DD_API_KEY" ]]; then
  echo "Error: Please enter a valid Datadog API key."
  exit 1
fi
export DD_API_KEY=$DD_API_KEY

# Prompt for the Datadog Site

# Define available options and their corresponding DD_SITE values
echo "What cloud provider do you use?"
options=(
  "AWS"
  "Azure"
  "GCP"
  "EU"
  "Asia Pacific"
)
PS3="Select your Datadog site (enter the corresponding number): "
select opt in "${options[@]}"; do
  case $opt in
    "AWS")
      DD_SITE="datadoghq.com"
      echo "You chose the Datadog AWS site: $DD_SITE"
      break
      ;;
    "Azure")
      DD_SITE="us3.datadoghq.com"
      echo "You chose the Datadog Azure site: $DD_SITE"
      break
      ;;
    "GCP")
      DD_SITE="us5.datadoghq.com"
      echo "You chose the Datadog GCP site: $DD_SITE"
      break
      ;;
    "EU")
      DD_SITE="datadoghq.eu"
      echo "You chose EU site: $DD_SITE"
      break
      ;;
    "Asia Pacific")
      DD_SITE="ap1.datadoghq.com"
      echo "You chose AP1 site: $DD_SITE"
      break
      ;;
    *)
      echo "Invalid option. Please choose a number between 1 and ${#options[@]}."
      ;;
  esac
done

# Validate if a site was chosen
if [[ -z "$DD_SITE" ]]; then
  echo "No site selected. Exiting..."
  exit 1
fi

export DD_SITE="$DD_SITE"

# Enable APM Auto Instrumentation - https://docs.datadoghq.com/tracing/trace_collection/automatic_instrumentation/
export DD_APM_INSTRUMENTATION_ENABLED=host

# Start the script
echo "Datadog agent installation script execution initiated."

# Execute the installation command
bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"

# Enable Remote Configuration - https://docs.datadoghq.com/agent/remote_config/?tab=configurationyamlfile#enabling-remote-configuration
sudo tee -a /etc/datadog-agent/datadog.yaml <<EOF 
remote_configuration:
  enabled: true
EOF

# Enable Live Processes - https://docs.datadoghq.com/infrastructure/process/?tab=linuxwindows#installation
sudo tee -a /etc/datadog-agent/datadog.yaml <<EOF 
process_config:
  process_collection:
    enabled: true
EOF

# Enable Logs - https://docs.datadoghq.com/agent/logs/?tab=tailfiles
sudo tee -a /etc/datadog-agent/datadog.yaml <<EOF 
logs_enabled: true
EOF

# Enable I/O Stats - https://docs.datadoghq.com/infrastructure/process/?tab=linuxwindows#io-stats
sudo -u dd-agent install -m 0640 /etc/datadog-agent/system-probe.yaml.example /etc/datadog-agent/system-probe.yaml

sudo tee -a /etc/datadog-agent/system-probe.yaml <<EOF
system_probe_config:
  process_config:
    enabled: true
EOF

# Enable NPM - https://docs.datadoghq.com/network_monitoring/performance/setup/
sudo tee -a /etc/datadog-agent/system-probe.yaml <<EOF
network_config:
  enabled: true
EOF

# Enable USM - https://docs.datadoghq.com/universal_service_monitoring/setup/?tab=configurationfileslinux#non-containerized-services-on-linux
sudo tee -a /etc/datadog-agent/system-probe.yaml <<EOF
service_monitoring_config:
  enabled: true
  process_service_inference:
    enabled: true
EOF


# Restart the agent to apply changes
echo "Reticulating Splines..."
sudo systemctl stop datadog-agent
sleep 2
sudo systemctl start datadog-agent

# Show the Status of the Agent
echo "We are pausing for a minute to allow system probes to start. We will give you the status of the Datdog Agent as soon as possible."
sleep 60
sudo datadog-agent status
