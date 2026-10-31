#!/usr/bin/env python3
# TinySA Ultra Tools
# Project: https://github.com/cyber-g/TinySA-Ultra-Tools
# Author: https://github.com/cyber-g
# Description: Trigger the tinySA Ultra calibration flow over the USB serial console.

import sys
import time
import serial

port = sys.argv[1] if len(sys.argv) > 1 else "/dev/ttyACM0"

with serial.Serial(port, 115200, timeout=20, write_timeout=5) as sa:
    def envoyer(commande):
        sa.write((commande + "\r").encode("ascii"))
        sa.flush()
        reponse = sa.read_until(b"ch> ")
        if not reponse.endswith(b"ch> "):
            raise RuntimeError(f"Pas de reponse complete : {reponse!r}")
        print(reponse.decode(errors="replace").strip())

    sa.reset_input_buffer()
    envoyer("")
    envoyer("refresh off")
    envoyer("menu 10 3 1")

    print("Verifier la page 'Connect CAL and RF', avec CALIBRATE dessous.")
    print("Verifier aussi le cable CAL-RF et l'ecran deverrouille.")
    if input("Taper OUI pour lancer : ").strip() == "OUI":
        try:
            envoyer("touch 240 51")
            time.sleep(0.2)
        finally:
            envoyer("release")
        print("Appui envoye. Verifier le resultat sur le tinySA.")
    else:
        envoyer("menu")
        print("Annule.")


