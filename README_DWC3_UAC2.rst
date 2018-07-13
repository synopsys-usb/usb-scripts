DWC3 AUDIO TEST
===============

This is the instruction to run audio test using UAC2 driver with DWC3.
The audio format use for this test must be a .wav format at 48Khz.

Audio OUT Test
~~~~~~~~~~~~~~

Peripheral
++++++++++

1. Load the driver

.. code:: shell

  $ dwc3 load audio

2. Connect the USB cable to host

3. Wait for host to play audio

.. code:: shell

  $ dwc3 audio listen out

Host
++++

1. Play an audio file

.. code:: shell

  $ dwc3 audio play <file_to_play.wav>


Audio IN Test
~~~~~~~~~~~~~

Peripheral
++++++++++

1. Load the driver

.. code:: shell

  $ dwc3 load audio

2. Connect the USB cable to host

3. Wait for audio IN. Two options:

* Get audio from microphone

.. code:: shell

  $ dwc3 audio listen in

* Get audio from a file

.. code:: shell

  $ dwc3 audio listen in <file_to_send.wav>

Host
++++

1. Record the audio from peripheral.
   There are Two options:

* Save the audio to a file

.. code:: shell

  $ dwc3 audio record <file_to_save.wav>

* Play the audio to the default speaker

.. code:: shell

  $ dwc3 audio record
