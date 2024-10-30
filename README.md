# Installation Instructions

## Swap File Setup

The swap file will be created by the `swapfile.sh` script. If you have already set up a swap file, it promt you want swapfile or not y/n do your choice 

### Swap File Size

When running the `swapfile.sh` script, you will need to specify the size of the swap file. Use the following examples for size:

- Enter `1` for a 1 GB swap file
- Enter `2` for a 2 GB swap file
- Enter `15` for a 15 GB swap file
and so on.....

## Hibernation

Hibernation will work effectively if you use the `swapfile.sh` script to create the swap file or if you have any other properly configured swap file.
Note: The script is not compatible with swap partition.

## Important Warnings

Before running the installation script, please ensure the following:

1. **Debian Installation**: Please run the script as instructed.

2. **NVIDIA Drivers**: If you are using NVIDIA graphics, you must enable the non-free repository in your `sources.list`. This is essential for proper driver installation other wise it failed to install pkg from apt .

3. **Login Manager**: If you are using any display manager (such as LightDM, GDM, etc.), **do not use** the `ly` login manager. When prompted in the script, select "no" to avoid conflicts.

Follow the script carefully to ensure a smooth installation and configuration process.
