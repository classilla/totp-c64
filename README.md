# TOTP-C64

TOTP-C64 lets your Commodore 64 be your two-factor authenticator. Because
what's more secure than an airgapped 8-bit computer for keeping your secrets?

This program demonstrates a cryptographic hash implementation on the 6502
(SHA-1) and a message authentication code (HMAC) using that hash. It also
demonstrates a quick and dirty analogue of `timegm()` for interfacing with
real-time clocks. And it's actually useful, as given proper inputs it will
faithfully generate timely and completely valid time-based one-time
password (TOTP) codes for entry.

Copyright 2022 Cameron Kaiser.  
All rights reserved.  
BSD 3-clause license (see terms below).

See more great projects and wonderful old tech at
[Old Vintage Computing Research](http://oldvcr.blogspot.com/).

![Screenshot.](/png/pic.png?raw=true "Screenshot.")

## How to use

Build it from source (see below), or grab a copy from the Releases tab.

Load it onto your Commodore 64, such as with an SD2IEC, or a transfer device
like a ZoomFloppy to a real floppy disk, or an 1541 Ultimate-II or U2+. I
use a U2 with a network connection, FTP the binary to the SD card, and then
command the U2 to load it into the Commodore's memory. It `LOAD`s and
`RUN`s like a BASIC program (in fact, the main menu *is* a BASIC program).

You can opt to load a binary key from disk, or enter a temporary (unsaved)
key in hexadecimal. If you load from a binary file, you can select the
offset and the keylength. Why, any file could be a key ...

With the key loaded, you can set the clock using either a connected device
that supports the CMD real-time clock command (`T-RA`) or enter the time
manually. Although the SD2IEC design supports a compatible RTC, note that many
SD2IEC clone implementations do not implement the full specification. The menu
will tell you if it got a valid response from the device.

For either option you next enter your timezone in hours from UTC (including
negative numbers: for example, PST is -8, AEDT is 11), and, if needed for your
timezone, minutes (for example, ACST is +0930, so enter 9 hours and then 30
minutes).

CMD RTC devices will be queried and will automatically start the TOTP display.

For manual entry, you then enter the current month, day and four-digit year
(years before 2000 are not supported), and the current hour in 24-hour
notation (8am = 8, 8pm = 20), followed by minutes and seconds. You should
enter the time slightly ahead by 10 or 15 seconds so that you can start
the clock as precisely as possible. Once you have pressed a key to start
the internal clock, the TOTP display will begin.

The TOTP display shows the current code in the middle of the screen and a
colour bar that fills up as the present 30-second interval expires and the
next code is displayed. Press F1 to exit the TOTP display and start over
with entering or loading a new key (or reloading the previous one).

## Usage notes

The TOTP display depends on a working CIA Time-of-Day clock. If the bar
does not advance, your CIA #1 may not be functioning correctly, or it may
not be getting a proper TOD signal from the 9V AC line. This signal passes
through a 2.7V Zener diode and a 74LS08 or 74LS14 or equivalent. If either
is defective, the TOD clock will fail to advance. The clock adjusts for
either 50Hz or 60Hz mains.

TOTP-C64 currently only supports the CMD real-time clock and compatible
implementations, though other supported devices are in the works (and pull
requests to add this support for your favourite Commodore RTC add-on are
welcome as long as they don't require significant additional modification
to other code).

TOTP-C64 does not currently support code generation intervals other than 30
seconds. This would require substantial reworking of the time computation
code since much of it is designed to avoid doing an expensive divide-by-30,
so adding adjustable intervals would not be trivial.

TOTP-C64 also does not currently support keys longer than 64 bytes. This might
be supported by hashing a longer key first, a la RFC 2104, and providing the
hash as the key instead. This exercise is left to the reader.

Finally, TOTP-C64 does not currently support key codes longer than 6 digits.
This could be done fairly easily by changing the code that extracts digits
from the decimal version of the hash to pull out more, but as sprites are
used to display the digits and there's no raster trickery, the maximum is 8.

## How to build

TOTP-C64 is primarily assembled with the
[`xa` cross assembler](http://www.floodgap.com/retrotech/xa/). This is a
highly portable 2-pass cross-assembler with a rich pre-processor that the
source code uses heavily. It should compile easily on any modern system.

The BASIC portion is tokenized and linked using two Perl-based tools in the
`tools/` directory; therefore you must have installed at least Perl 5.005.
The padlock sprite graphic is also converted into assembly source using a
Perl tool in the same directory. *Please note that the Perl tools exist under
a different license than the main source for TOTP-C64 and are provided for
your convenience only.*

Finally, the binary is compacted for efficiency and faster loading using
[`pucrunch`](http://a1bert.kapsi.fi/Dev/pucrunch/). This is also very
portable and should compile easily on any modern system.

If needed, first hange the `OBJ` in the `Makefile` to point to your desired
destination, which by default is `../prgs/totp` (this is to suit my VICE
setup). Then just `make`.

`pucrunch` is, strictly speaking, optional: if you don't have it, the build
process will err out but leave a file `totp.arc` in the working directory
as the linking step before crunching. This is runnable, just not compressed.

## Code notes

Much of the code should work on any 6502-based platform. However, you will
need to rewrite the TOTP graphical display (there is some remaining debug
code to simply emit the codes as text) and provide a substitute for the TOD
clock used for timing, depending on what your target system supports. The
BASIC menu also needs some reworking to be cross-platform.

## Support and filing issues and PRs

There is none. You use it at your own risk. If you use this in a
production environment, you are an interesting person, and interesting
is not a word generally favoured in security circles. There is no
warranty, not even the implied warranty of merchantability or fitness
for a particular purpose. It works for me. It may not work for you.

Bug reports may or may not be fixed, ever. They are slightly more likely to
be fixed if you include a clear, reproducible explanation, and somewhat
more likely still if you actually provide a patch, but neither is a
certainty.

I consider this project largely feature complete except for additional RTC
hardware support. Pull requests to add more features will likely be
ignored unless they are compelling. Issues filed to request them will
definitely be ignored, and probably deleted.

Pull requests to majorly refactor the code, change the assembler, nickel
and dime the performance (even if verifiable), or change the architecture
or target system will be rejected. For those, fork the project and make me
proud.

## License

TOTP-C64 is (C) 2022 Cameron Kaiser. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF/SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
