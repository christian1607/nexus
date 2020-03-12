# NEXUS
Vagrantfile para instalar Nexus Repository

# RUN
Just run: 
vagrant up

once done open your browser http://192.168.1.80:8081/ and that's it.

if you want to change some parameter just change it in the shell script, the shell script has these parameters

- USER=nexus
- GROUP=nexus
- SERVICE_NAME=nexus
- WORK_DIR=/app
- NEXUS_NAME=nexus

