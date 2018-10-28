#! /bin/bash

kill $(ps aux | grep python | grep -v grep | awk '{print $2}')
