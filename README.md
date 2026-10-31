# TinySA Ultra Tools

A small set of Linux helper scripts for interacting with a tinySA Ultra through its USB serial console.

> These tools target the tinySA Ultra specifically (480 × 320 display and built-in clock).

## Included tools

| File | Type | Purpose |
|---|---|---|
| `tinySA_set_time.sh` | Bash | Sets the tinySA Ultra clock from the host PC's current local time |
| `tinySA_calibrate.py` | Python | Opens the calibration menu and triggers a CAL-to-RF level calibration sequence |
| `tinySA_screenshot.sh` | Bash + Perl | Captures the display and saves a screenshot as a PPM image, then creates a PNG copy (requires Image Magick) |
| `tinySA_firmware_update.sh` | Bash | Downloads a tinySA firmware package and flashes it via DFU (requires dfu-util) |

All serial-based tools default to `/dev/ttyACM0`. A different device can normally be selected by passing it as the first argument.

## Requirements

- Linux
- A tinySA Ultra connected over USB
- Access to the serial port (for example, your user should be in the `dialout` group)
- `serial` for the calibration script. Preferred on Debian/Ubuntu:

  ```bash
  sudo apt install python3-serial
  ```

  If you do not have administrator rights, `pyserial` is an alternative:

  ```bash
  python3 -m pip install --user pyserial
  ```

- Perl for the screenshot utility (usually already installed on Linux systems)
- ImageMagick for the screenshot PNG conversion step
- `dfu-util` and `wget` for the firmware update utility

Obviously, close any other software that may already be using the tinySA serial port before running a script.

## Quick usage

### Set the tinySA clock

```bash
bash tinySA_set_time.sh # Defaults to /dev/ttyACM0
bash tinySA_set_time.sh /dev/ttyACM1
```

The script sends the host PC time. 

### Start CAL/RF calibration

1. Connect the CAL output to the RF input with a short SMA cable.
2. Power-on the tinySA.
3. Run:

   ```bash
   python3 tinySA_calibrate.py
   ```

4. Confirm that the tinySA shows the `Connect CAL and RF` page with `CALIBRATE` below it.
5. Type `OUI` to proceed (case sensitive), or anything else to cancel.

The USB cable can be disconnected during the calibration progress. 
The SMA cable must not. 

The script sends a remote touch sequence via the serial console to select the calibration entry. (This depends on the menu layout in the installed firmware, so check the device screen before confirming anything.)

### Capture a screenshot

```bash
bash tinySA_screenshot.sh
bash tinySA_screenshot.sh /dev/ttyACM0 capture.ppm
```

The script:

- sends `capture`
- reads exactly 307,200 bytes from the serial device (480 × 320 × 2 bytes, RGB565 big-endian)
- converts the raw data to a PPM image
- creates a PNG version with ImageMagick

### Update the firmware

Get the firmware (.bin file) exact name from : https://dfu.tinydevices.org/tinySA4/DFU/

```bash
bash tinySA_firmware_update.sh tinySA4_vX.X-XXX.bin
```

The script downloads the firmware from the tinySA DFU server, waits for the device to appear in DFU mode, and flashes the image using `dfu-util`.

Follow instructions given by the shell script execution. 

## Compatibility notes

These helpers are based on the tinySA firmware behavior and menu layout used by the upstream firmware sources in the tinySA project. Firmware versions may vary, and menu options or touch coordinates can differ between builds.

The current version of the firmware is : tinySA4_v1.4-266-g67a40ba.bin	2026-10-29

## Disclaimer

These scripts are provided as-is for Linux users working with tinySA Ultra hardware. They are not guaranteed to work on every firmware revision, so always confirm the device screen before proceeding with calibration or flashing.

## License

This project is distributed under the GNU GPL v3 license.
