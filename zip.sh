#!/bin/bash

rm -f *zip
zip -q $(echo $HOSTNAME).zip *.txt *.csv 2>&1