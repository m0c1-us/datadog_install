while true; do
    echo "$(date) - This is a test log entry" | sudo tee -a /var/log/custom.log
    echo "$(date) - Hey YO!!" | sudo tee -a /var/log/custom.log
    echo "$(date) - You Gettin’ Logs FOOL??!!" | sudo tee -a /var/log/custom.log
    echo "$(date) - You STILL Gettin’ Logs Homie??!!" | sudo tee -a /var/log/custom.log
sleep 5
done
