#!/bin/bash
sed -i -e "/.* # mikespook.*/d" $HOME/.bashrc
echo '. $HOME/.mikespook/bashrc # mikespook' >> $HOME/.bashrc
