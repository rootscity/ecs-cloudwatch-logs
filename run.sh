#!/usr/bin/env bash
sed -i "s/%LOG_GROUP%/$LOG_GROUP/" /awslogs.conf
python ./awslogs-agent-setup.py -n -r $AWS_REGION -c /awslogs.conf
/usr/local/bin/supervisord
