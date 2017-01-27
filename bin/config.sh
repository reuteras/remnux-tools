#!/bin/bash

dconf write /com/canonical/unity/launcher/favorites "['application://gnome-terminal.desktop', 'application://nautilus.desktop', 'application://google-chrome.desktop', 'application://firefox.desktop', 'application://unity-control-center.desktop', 'unity://running-apps', 'unity://expo-icon', 'unity://devices']"
dconf write /com/canonical/unity/lenses/remote-content-search 'none'
dconf write /org/gnome/desktop/screensaver/ubuntu-lock-on-suspend false
dconf write /org/gnome/desktop/screensaver/lock-enabled false
