#!/bin/bash

source /etc/profile

USER_NAME="<CHANGE-ME>"
JAVA_VERSION="11"

# create new ssh key
[[ ! -f /home/$USER_NAME/.ssh/mykey ]] && \
mkdir -p /home/$USER_NAME/.ssh && \
ssh-keygen -f /home/$USER_NAME/.ssh/mykey -N '' && \
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh

# install packages
apt-get update
apt-get -y install docker.io unzip python3-pip
# add docker privileges
usermod -aG docker $USER_NAME

# install aws cli
AWS_CLI_EXECUTABLE_LOCATION=$(command -v aws)

echo 'Check if AWS CLI v2 is installed'
if [ -z "$AWS_CLI_EXECUTABLE_LOCATION" ];
  then
    echo 'Starting AWS CLI v2 installation...'
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    pip3 install botocore && \
    pip3 install boto3
  else
    echo 'AWS CLI v2 is already installed'
fi

#java
ACTUAL_JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)

echo 'Check if Java is installed'
if [ -z "$ACTUAL_JAVA_VERSION" ] || [ "$ACTUAL_JAVA_VERSION" != "$JAVA_VERSION" ];
  then
    echo 'Starting Java installation...'
    wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add - && \
    add-apt-repository 'deb https://apt.corretto.aws stable main' && \
    apt-get update && \
    apt-get install -y java-11-amazon-corretto-jdk && \
    sed -i '/export JAVA_HOME/d' /etc/profile && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto" >> /etc/profile && \
    echo "export PATH=$PATH:/usr/lib/jvm/java-11-amazon-corretto/bin" >> /etc/profile
  else
    echo "Java is already installed, version: $ACTUAL_JAVA_VERSION"
fi

##################
### OPTIONALLY ###
##################

GOOGLE_CHROME=$(google-chrome --version 2>&1 | awk -F ' ' '{print($1, $2)}')

echo 'Check if Google Chrome is installed'
if [ "$GOOGLE_CHROME" != "Google Chrome" ];
  then
    echo 'Starting Google Chrome installation...'
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb
  else
    echo "Google Chrome is already installed"
fi

INTELLIJ_IDEA=$(find /opt -type d -name 'idea*')

echo 'Check if Intellij Idea is installed'
if [ -z "$INTELLIJ_IDEA" ];
  then
    echo 'Starting Intellij Idea installation...'
    wget https://download-cf.jetbrains.com/idea/ideaIU-2020.2.2.tar.gz && \
    tar -zxvf ideaIU-2020.2.2.tar.gz && \
    mv /idea-IU-* /opt && \
    rm ideaIU-2020.2.2.tar.gz
  else
    echo "Intellij Idea is already installed"
fi

source /etc/profile

# clean up
apt-get clean