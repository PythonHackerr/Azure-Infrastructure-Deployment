echo -e "[Unit]\n\
Description=Petclinic backend service\n\
After=network.target\n\
StartLimitIntervalSec=0\n\n\
[Service]\n\
Type=simple\n\
Restart=always\n\
RestartSec=1\n\
User=azureuser\n\
WorkingDirectory=/home/azureuser/spring-petclinic-rest\n\
ExecStart=/home/azureuser/spring-petclinic-rest/mvnw spring-boot:run\n\n\
[Install]\n\
WantedBy=multi-user.target\n" | sudo tee /etc/systemd/system/backend.service