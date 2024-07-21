#!/usr/bin/env bash

# The path to the X keyboard configuration directory
xkb_path="/usr/share/X11/xkb"


# Check if the directory exists
if [[ ! -d ${xkb_path} ]] ; then
    echo "Directory ${xkb_path} is not there, aborting. Check your xkeyboard-config installation."
    exit
fi

# Check if the symbols/ce file already exists before copying
if [[ ! -f ${xkb_path}/symbols/ce ]] ; then
    echo "Copying symbols/ce to ${xkb_path}/symbols/..."
    cp symbols/ce ${xkb_path}/symbols/
    echo "Copy complete."
else
    echo "File ${xkb_path}/symbols/ce already exists. Skipping copy."
fi

# Function to check and insert content into XML files
insert_if_not_exists_xml() {
    local file=$1
    local content=$2
    local marker=$3
    if ! grep -q "${marker}" "${file}"; then
        sed -i -e "/^.*<\/layoutList>/ {r ${content}" -e 'N}' "${file}"
        echo "Updated ${file} with new layout."
    else
        echo "Marker ${marker} found in ${file}. Skipping update."
    fi
}

# Function to check and insert content into LST files
insert_if_not_exists_lst() {
    local file=$1
    local content=$2
    local marker=$3
    if ! grep -q "${marker}" "${file}"; then
        sed -i -e "/^.*A user-defined custom Layout/ {r ${content}" -e 'N}' "${file}"
        echo "Updated ${file} with new entry."
    else
        echo "Marker ${marker} found in ${file}. Skipping update."
    fi
}

# Define markers for checking
xml_marker="<name>ce</name>"
lst_marker="Chechen (Latin, QWERTY, US)"

# Insert content into XML files if not already present
insert_if_not_exists_xml "${xkb_path}/rules/evdev.xml" "rules/evdev.xml" "${xml_marker}"
insert_if_not_exists_xml "${xkb_path}/rules/base.xml" "rules/evdev.xml" "${xml_marker}"

# Insert content into LST files if not already present
insert_if_not_exists_lst "${xkb_path}/rules/evdev.lst" "rules/evdev.lst" "${lst_marker}"
insert_if_not_exists_lst "${xkb_path}/rules/base.lst" "rules/evdev.lst" "${lst_marker}"

echo "Reboot your system to apply the changes."
