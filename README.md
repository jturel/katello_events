# Setup

Installing systemd services is the easiest way. Be sure to review & update the environment options.

For the Event Queue:
```
[vagrant@centos8-katello-devel katello]$ cat /etc/systemd/system/katello-event-queue.service 
[Unit]
Description=Katello Event Queue
Wants=katello-event-queue.service

[Service]
Type=simple
Environment=SSL_CLIENT_CERT=/home/vagrant/foreman-certs/client_cert.pem
Environment=SSL_CLIENT_KEY=/home/vagrant/foreman-certs/client_key.pem
Environment=KATELLO_URI=https://centos8-katello-devel.fedora-t480.example.com
Environment=HEARTBEAT_INTERVAL=25
ExecStart=/usr/bin/ruby -I /home/vagrant/katello_events/lib /home/vagrant/katello_events/bin/event_queue.rb
Restart=always
RestartSec=30
SyslogIdentifier=katello-event-queue

[Install]
WantedBy=multi-user.target
```

For Candlepin Events:
```
[vagrant@centos8-katello-devel katello]$ cat /etc/systemd/system/katello-candlepin-events.service 
[Unit]
Description=Katello Candlepin Events
Wants=katello-candlepin-events.service

[Service]
Type=simple
Environment=SSL_CLIENT_CERT=/home/vagrant/foreman-certs/client_cert.pem
Environment=SSL_CLIENT_KEY=/home/vagrant/foreman-certs/client_key.pem
Environment=SSL_CA_FILE=/etc/pki/katello/certs/katello-default-ca.crt
Environment=KATELLO_URI=https://centos8-katello-devel.fedora-t480.example.com
Environment=BROKER_HOST=localhost
Environment=BROKER_PORT=61613
Environment=QUEUE_NAME=katello.candlepin
Environment=SUBSCRIPTION_NAME=candlepin_events
Environment=CLIENT_ID=katello_candlepin_event_monitor
Environment=HEARTBEAT_INTERVAL=25
ExecStart=/usr/bin/ruby -I /home/vagrant/katello_events/lib /home/vagrant/katello_events/bin/candlepin_events.rb
Restart=always
RestartSec=30
SyslogIdentifier=katello-candlepin-events
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target
```

After this, the services can be managed with `systemctl`.
