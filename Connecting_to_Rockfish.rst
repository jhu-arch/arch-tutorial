======================
Connecting to Rockfish
======================

In order to use the Rockfish system robustly by command lines.
* gateway: login.rockfish.jhu.edu
* OpenSSH SSH client (remote login program)
  * ssh -XY login.rockfish.jhu.edu -l userid
  * ssh -XY userid@login.rockfish.jhu.edu
* Login nodes [01 - 03]

** For Windows machines **
  You can use PuTTY or MobaXterm (Home Edition → Installer edition). MobaXterm provides both a SFTP application for file transfer and a SSH client for command lines with X-Windows (X11 server) system (for graphical user interface (GUI) running on Rockfish login nodes).

** For Mac OS machines **
  You can use Terminal program (installed within MacOS) for your SSH client. (In the taskbar, search for “terminal”.) However, for running graphical user interface (GUI) programs on Rockfish login nodes, the X11-server program XQuartz needs to be installed. See XQuartz for download instructions.

  .. note:: Make sure you have a SSH client and X11 server installed in your computer (Linux/MacOS).
