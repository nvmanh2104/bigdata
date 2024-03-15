#!/bin/bash

echo ""

echo -e "\nBuild docker hadoop image\n"
sudo docker build -t aiv/hadoop:3.0 .

echo ""
