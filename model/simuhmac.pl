#!/usr/bin/perl

# hmac sha-1 the hard way like an 8-bit CPU would do it

$carry = 0;
sub rol {
	my $v = shift;

	$v <<= 1;
	$v |= $carry;
	$carry = ($v & 256) ? 1 : 0;
	return ($v & 255);
}
sub ror {
	my $v = shift;
	my $nucarry = ($v & 1);

	$v >>= 1;
	$v |= ($carry) ? 128 : 0;
	$carry = $nucarry;
	return $v;
}
sub asl {
	my $v = shift;

	$v <<= 1;
	# no carry in
	$carry = ($v & 256) ? 1 : 0;
	return ($v & 255);
}
sub lsr {
	my $v = shift;

	$carry = ($v & 1);
	$v >>= 1;
	# no carry in
	return $v;
}
sub adc {
	my $v = shift;
	my $vv = shift;

	$v += $vv;
	$v += $carry;
	$carry = ($v & 256) ? 1 : 0;
	return ($v & 255);
}
sub clc { $carry = 0; }
sub sec { $carry = 1; }

# 32 bit "registers"
@temp = ( 0, 0, 0, 0 );
@work = ( 0, 0, 0, 0 );
@junk = ( 0, 0, 0, 0 );
@a = ( 0, 0, 0, 0 );
@b = ( 0, 0, 0, 0 );
@c = ( 0, 0, 0, 0 );
@d = ( 0, 0, 0, 0 );
@e = ( 0, 0, 0, 0 );
@f = ( 0, 0, 0, 0 );
@k = ( 0, 0, 0, 0 );

# hash results (keep contiguous in memory for copies)
@h0 = ( 0, 0, 0, 0 );
@h1 = ( 0, 0, 0, 0 );
@h2 = ( 0, 0, 0, 0 );
@h3 = ( 0, 0, 0, 0 );
@h4 = ( 0, 0, 0, 0 );

# hash stash
# dude you're getting a dell
@stash = (
	0, 0, 0, 0,
	0, 0, 0, 0,
	0, 0, 0, 0,
	0, 0, 0, 0,
	0, 0, 0, 0
);

@bytes = (
	0, 0, 0, 0, 0, 0, 0, 0, # 64
	0, 0, 0, 0, 0, 0, 0, 0, # 128
	0, 0, 0, 0, 0, 0, 0, 0, # 192
	0, 0, 0, 0, 0, 0, 0, 0, # 256
	0, 0, 0, 0, 0, 0, 0, 0, # 320
	0, 0, 0, 0, 0, 0, 0, 0, # 384
	0, 0, 0, 0, 0, 0, 0, 0, # 448
	0, 0, 0, 0, 0, 0, 0, -1 # 512 (16 32-bit words)
	,
	# extension for eighty 32-bit words
	0, 0, 0, 0, 0, 0, 0, 0, # 18
	0, 0, 0, 0, 0, 0, 0, 0, # 20
	0, 0, 0, 0, 0, 0, 0, 0, # 22
	0, 0, 0, 0, 0, 0, 0, 0, # 24
	0, 0, 0, 0, 0, 0, 0, 0, # 26
	0, 0, 0, 0, 0, 0, 0, 0, # 28
	0, 0, 0, 0, 0, 0, 0, 0, # 30
	0, 0, 0, 0, 0, 0, 0, 0, # 32

	0, 0, 0, 0, 0, 0, 0, 0, # 34
	0, 0, 0, 0, 0, 0, 0, 0, # 36
	0, 0, 0, 0, 0, 0, 0, 0, # 38
	0, 0, 0, 0, 0, 0, 0, 0, # 40
	0, 0, 0, 0, 0, 0, 0, 0, # 42
	0, 0, 0, 0, 0, 0, 0, 0, # 44
	0, 0, 0, 0, 0, 0, 0, 0, # 46
	0, 0, 0, 0, 0, 0, 0, 0, # 48

	0, 0, 0, 0, 0, 0, 0, 0, # 50
	0, 0, 0, 0, 0, 0, 0, 0, # 52
	0, 0, 0, 0, 0, 0, 0, 0, # 54
	0, 0, 0, 0, 0, 0, 0, 0, # 56
	0, 0, 0, 0, 0, 0, 0, 0, # 58
	0, 0, 0, 0, 0, 0, 0, 0, # 60
	0, 0, 0, 0, 0, 0, 0, 0, # 62
	0, 0, 0, 0, 0, 0, 0, 0, # 64

	0, 0, 0, 0, 0, 0, 0, 0, # 66
	0, 0, 0, 0, 0, 0, 0, 0, # 68
	0, 0, 0, 0, 0, 0, 0, 0, # 70
	0, 0, 0, 0, 0, 0, 0, 0, # 72
	0, 0, 0, 0, 0, 0, 0, 0, # 74
	0, 0, 0, 0, 0, 0, 0, 0, # 76
	0, 0, 0, 0, 0, 0, 0, 0, # 78
	0, 0, 0, 0, 0, 0, 0, 0  # 80
);

die("initial byte array is not 512 bits long\n") if ($bytes[63] != -1);

# initialize registers
# could do this with a simple byte copy loop
sub sha1_reset {
$h0[0] = 0x67;
$h0[1] = 0x45;
$h0[2] = 0x23;
$h0[3] = 0x01;

$h1[0] = 0xef;
$h1[1] = 0xcd;
$h1[2] = 0xab;
$h1[3] = 0x89;

$h2[0] = 0x98;
$h2[1] = 0xba;
$h2[2] = 0xdc;
$h2[3] = 0xfe;

$h3[0] = 0x10;
$h3[1] = 0x32;
$h3[2] = 0x54;
$h3[3] = 0x76;

$h4[0] = 0xc3;
$h4[1] = 0xd2;
$h4[2] = 0xe1;
$h4[3] = 0xf0;
}

# hash a chunk of 512 bits
# assumes byte array is already populated with message with terminating
# 0x80 and bit length, if required
sub sha1_chunk {
printf(STDOUT ("%02x" x 64)."\n\n", @bytes);

# extend the 16 32-bit words into eighty 32-bit words
for($i=16;$i<80;$i++) {
	$index = $i + $i + $i + $i;
	# or $index = $i + $i; $index += $index;

	$index3 = $i - 3;
	$index3 += $index3 + $index3 + $index3;

	$index8 = $i - 8;
	$index8 += $index8 + $index8 + $index8;

	$index14 = $i - 14;
	$index14 += $index14 + $index14 + $index14;

	$index16 = $i - 16;
	$index16 += $index16 + $index16 + $index16;

	$temp[0] = $bytes[$index3];
	$temp[1] = $bytes[$index3+1];
	$temp[2] = $bytes[$index3+2];
	$temp[3] = $bytes[$index3+3];

	$temp[0] ^= $bytes[$index8];
	$temp[1] ^= $bytes[$index8+1];
	$temp[2] ^= $bytes[$index8+2];
	$temp[3] ^= $bytes[$index8+3];

	$temp[0] ^= $bytes[$index14];
	$temp[1] ^= $bytes[$index14+1];
	$temp[2] ^= $bytes[$index14+2];
	$temp[3] ^= $bytes[$index14+3];

	$temp[0] ^= $bytes[$index16];
	$temp[1] ^= $bytes[$index16+1];
	$temp[2] ^= $bytes[$index16+2];
	$temp[3] ^= $bytes[$index16+3];

	# words are big endian
	$bytes[$index+3] = &asl($temp[3]);
	$bytes[$index+2] = &rol($temp[2]);
	$bytes[$index+1] = &rol($temp[1]);
	$bytes[$index] = &rol($temp[0]);
	$bytes[$index+3] = &adc($bytes[$index+3], 0);
}

printf(STDOUT ("%02x" x 320)."\n\n", @bytes);

$a[0] = $h0[0];
$a[1] = $h0[1];
$a[2] = $h0[2];
$a[3] = $h0[3];

$b[0] = $h1[0];
$b[1] = $h1[1];
$b[2] = $h1[2];
$b[3] = $h1[3];

$c[0] = $h2[0];
$c[1] = $h2[1];
$c[2] = $h2[2];
$c[3] = $h2[3];

$d[0] = $h3[0];
$d[1] = $h3[1];
$d[2] = $h3[2];
$d[3] = $h3[3];

$e[0] = $h4[0];
$e[1] = $h4[1];
$e[2] = $h4[2];
$e[3] = $h4[3];

for($i=0;$i<80;$i++) {
	if ($i < 20) { 
		# not b
		$temp[0] = $b[0] ^ 255;
		$temp[1] = $b[1] ^ 255;
		$temp[2] = $b[2] ^ 255;
		$temp[3] = $b[3] ^ 255;

		# b and c
		$junk[0] = $b[0] & $c[0];
		$junk[1] = $b[1] & $c[1];
		$junk[2] = $b[2] & $c[2];
		$junk[3] = $b[3] & $c[3];

#printf(STDOUT ("%02x%02x%02x%02x "x2)."<%02d\n",
#	$temp[0], $temp[1], $temp[2], $temp[3],
#	$junk[0], $junk[1], $junk[2], $junk[3],
#$i);

		# (not b) and d
		$temp[0] = $temp[0] & $d[0];
		$temp[1] = $temp[1] & $d[1];
		$temp[2] = $temp[2] & $d[2];
		$temp[3] = $temp[3] & $d[3];

		# f = (b and c) or ((not b) and d)
		$f[0] = $junk[0] | $temp[0];
		$f[1] = $junk[1] | $temp[1];
		$f[2] = $junk[2] | $temp[2];
		$f[3] = $junk[3] | $temp[3];

		$k[0] = 0x5a;
		$k[1] = 0x82;
		$k[2] = 0x79;
		$k[3] = 0x99;
	} elsif ($i < 40) {
		# f = b xor c
		$f[0] = $b[0] ^ $c[0];
		$f[1] = $b[1] ^ $c[1];
		$f[2] = $b[2] ^ $c[2];
		$f[3] = $b[3] ^ $c[3];

		# f = b xor c xor d
		$f[0] = $f[0] ^ $d[0];
		$f[1] = $f[1] ^ $d[1];
		$f[2] = $f[2] ^ $d[2];
		$f[3] = $f[3] ^ $d[3];

		$k[0] = 0x6e;
		$k[1] = 0xd9;
		$k[2] = 0xeb;
		$k[3] = 0xa1;
	} elsif ($i < 60) {
		# b and c
		$junk[0] = $b[0] & $c[0];
		$junk[1] = $b[1] & $c[1];
		$junk[2] = $b[2] & $c[2];
		$junk[3] = $b[3] & $c[3];

		# b and d 
		$temp[0] = $b[0] & $d[0];
		$temp[1] = $b[1] & $d[1];
		$temp[2] = $b[2] & $d[2];
		$temp[3] = $b[3] & $d[3];

		# c and d
		$work[0] = $c[0] & $d[0];
		$work[1] = $c[1] & $d[1];
		$work[2] = $c[2] & $d[2];
		$work[3] = $c[3] & $d[3];

		# f = (b and c) or (b and d)
		$f[0] = $junk[0] | $temp[0];
		$f[1] = $junk[1] | $temp[1];
		$f[2] = $junk[2] | $temp[2];
		$f[3] = $junk[3] | $temp[3];

		# f = (b and c) or (b and d) or (c and d)
		$f[0] = $f[0] | $work[0];
		$f[1] = $f[1] | $work[1];
		$f[2] = $f[2] | $work[2];
		$f[3] = $f[3] | $work[3];

		$k[0] = 0x8f;
		$k[1] = 0x1b;
		$k[2] = 0xbc;
		$k[3] = 0xdc;
	} else {
		# f = b xor c
		$f[0] = $b[0] ^ $c[0];
		$f[1] = $b[1] ^ $c[1];
		$f[2] = $b[2] ^ $c[2];
		$f[3] = $b[3] ^ $c[3];

		# f = b xor c xor d
		$f[0] = $f[0] ^ $d[0];
		$f[1] = $f[1] ^ $d[1];
		$f[2] = $f[2] ^ $d[2];
		$f[3] = $f[3] ^ $d[3];

		$k[0] = 0xca;
		$k[1] = 0x62;
		$k[2] = 0xc1;
		$k[3] = 0xd6;
	}


#printf(STDOUT ("%02x%02x%02x%02x "x7)."<%02d\n",
#	$a[0], $a[1], $a[2], $a[3],
#	$b[0], $b[1], $b[2], $b[3],
#	$c[0], $c[1], $c[2], $c[3],
#	$d[0], $d[1], $d[2], $d[3],
#	$e[0], $e[1], $e[2], $e[3],
#	$f[0], $f[1], $f[2], $f[3],
#	$k[0], $k[1], $k[2], $k[3],
#$i);

	# temp = (a leftrotate 5)
	# strength reduce to a leftrotate 8 followed by rightrotate 3
	$temp[0] = $a[1];
	$temp[1] = $a[2];
	$temp[2] = $a[3];
	$temp[3] = $a[0];
#printf(STDOUT "%02x%02x%02x%02x\n", $temp[0], $temp[1], $temp[2], $temp[3]);
	# big endian
	$temp[0] = &lsr($temp[0]);
	$temp[1] = &ror($temp[1]);
	$temp[2] = &ror($temp[2]);
	$temp[3] = &ror($temp[3]);
	$temp[0] |= 128 if ($carry); # bcc to skip
#printf(STDOUT "%02x%02x%02x%02x\n", $temp[0], $temp[1], $temp[2], $temp[3]);
	$temp[0] = &lsr($temp[0]);
	$temp[1] = &ror($temp[1]);
	$temp[2] = &ror($temp[2]);
	$temp[3] = &ror($temp[3]);
	$temp[0] |= 128 if ($carry); # bcc
#printf(STDOUT "%02x%02x%02x%02x\n", $temp[0], $temp[1], $temp[2], $temp[3]);
	$temp[0] = &lsr($temp[0]);
	$temp[1] = &ror($temp[1]);
	$temp[2] = &ror($temp[2]);
	$temp[3] = &ror($temp[3]);
	$temp[0] |= 128 if ($carry); # bcc
#printf(STDOUT "%02x%02x%02x%02x ", $temp[0], $temp[1], $temp[2], $temp[3]);

	# temp = temp + f + e + k + w[i]
	&clc;
	$temp[3] = &adc($temp[3], $f[3]);
	$temp[2] = &adc($temp[2], $f[2]);
	$temp[1] = &adc($temp[1], $f[1]);
	$temp[0] = &adc($temp[0], $f[0]);
#printf(STDOUT "%02x%02x%02x%02x ", $temp[0], $temp[1], $temp[2], $temp[3]);
	&clc;
	$temp[3] = &adc($temp[3], $e[3]);
	$temp[2] = &adc($temp[2], $e[2]);
	$temp[1] = &adc($temp[1], $e[1]);
	$temp[0] = &adc($temp[0], $e[0]);
#printf(STDOUT "%02x%02x%02x%02x ", $temp[0], $temp[1], $temp[2], $temp[3]);
	&clc;
	$temp[3] = &adc($temp[3], $k[3]);
	$temp[2] = &adc($temp[2], $k[2]);
	$temp[1] = &adc($temp[1], $k[1]);
	$temp[0] = &adc($temp[0], $k[0]);
#printf(STDOUT "%02x%02x%02x%02x | ", $temp[0], $temp[1], $temp[2], $temp[3]);

	$index = $i + $i;
	$index = $index + $index;
	&clc;
	$temp[3] = &adc($temp[3], $bytes[$index+3]);
	$temp[2] = &adc($temp[2], $bytes[$index+2]);
	$temp[1] = &adc($temp[1], $bytes[$index+1]);
	$temp[0] = &adc($temp[0], $bytes[$index]);

	# e = d
	$e[0] = $d[0];
	$e[1] = $d[1];
	$e[2] = $d[2];
	$e[3] = $d[3];

	# d = c
	$d[0] = $c[0];
	$d[1] = $c[1];
	$d[2] = $c[2];
	$d[3] = $c[3];

	# c = b leftrotate 30
	# optimize to rightrotate 2
	$c[0] = &lsr($b[0]);
	$c[1] = &ror($b[1]);
	$c[2] = &ror($b[2]);
	$c[3] = &ror($b[3]);
	$c[0] |= 128 if ($carry); # bcc to skip
	$c[0] = &lsr($c[0]);
	$c[1] = &ror($c[1]);
	$c[2] = &ror($c[2]);
	$c[3] = &ror($c[3]);
	$c[0] |= 128 if ($carry); # bcc

	# b = a
	$b[0] = $a[0];
	$b[1] = $a[1];
	$b[2] = $a[2];
	$b[3] = $a[3];

	# a = temp
	$a[0] = $temp[0];
	$a[1] = $temp[1];
	$a[2] = $temp[2];
	$a[3] = $temp[3];

printf(STDOUT ("%02x%02x%02x%02x "x5)."<%02d\n",
	$a[0], $a[1], $a[2], $a[3],
	$b[0], $b[1], $b[2], $b[3],
	$c[0], $c[1], $c[2], $c[3],
	$d[0], $d[1], $d[2], $d[3],
	$e[0], $e[1], $e[2], $e[3], $i);
}

&clc;
$h0[3] = &adc($h0[3], $a[3]);
$h0[2] = &adc($h0[2], $a[2]);
$h0[1] = &adc($h0[1], $a[1]);
$h0[0] = &adc($h0[0], $a[0]);

&clc;
$h1[3] = &adc($h1[3], $b[3]);
$h1[2] = &adc($h1[2], $b[2]);
$h1[1] = &adc($h1[1], $b[1]);
$h1[0] = &adc($h1[0], $b[0]);

&clc;
$h2[3] = &adc($h2[3], $c[3]);
$h2[2] = &adc($h2[2], $c[2]);
$h2[1] = &adc($h2[1], $c[1]);
$h2[0] = &adc($h2[0], $c[0]);

&clc;
$h3[3] = &adc($h3[3], $d[3]);
$h3[2] = &adc($h3[2], $d[2]);
$h3[1] = &adc($h3[1], $d[1]);
$h3[0] = &adc($h3[0], $d[0]);

&clc;
$h4[3] = &adc($h4[3], $e[3]);
$h4[2] = &adc($h4[2], $e[2]);
$h4[1] = &adc($h4[1], $e[1]);
$h4[0] = &adc($h4[0], $e[0]);

}

# append 0x80 to the message bytes ("stop bit")
# test vector 1: ""
# da39a3ee5e6b4b0d3255bfef95601890afd80709
#$bytes[0] = 128;
#$bytes[63] = 0; # big endian int

if(0) {
# test vector 2: "a0dc"
# 039090f40312df6da7f9969239dfff35667f1cea
$bytes[0] = 97; # 'a'
$bytes[1] = 48; # '0'
$bytes[2] = 100; # 'd'
$bytes[3] = 99; # 'c'
$bytes[4] = 128;
$bytes[63] = 32;

&sha1_reset;
&sha1_chunk;
# hash result is h0 || h1 || h2 || h3 || h4
printf("%02x" x 20,
	$h0[0], $h0[1], $h0[2], $h0[3],
	$h1[0], $h1[1], $h1[2], $h1[3],
	$h2[0], $h2[1], $h2[2], $h2[3],
	$h3[0], $h3[1], $h3[2], $h3[3],
	$h4[0], $h4[1], $h4[2], $h4[3]); print"\n";

$offset = $h4[3] & 0xf;
print "offset = $offset\n";
exit;
}

# TOTP-HOTP demo
# counter: 00 00 00 00 00 00 01 02
# key: 01 02 03 04

# assuming the key is not longer than 512 bits, there are four chunks of SHA-1.
# chunk 1: key padded to 64 bytes xor 0x36

$bytes[0] = 0x01 ^ 0x36;
$bytes[1] = 0x02 ^ 0x36;
$bytes[2] = 0x03 ^ 0x36;
$bytes[3] = 0x04 ^ 0x36;
for($i=4;$i<64;$i++) { $bytes[$i] = 0x36; }

&sha1_reset;
&sha1_chunk;

# hash result is h0 || h1 || h2 || h3 || h4
printf("%02x" x 20,
	$h0[0], $h0[1], $h0[2], $h0[3],
	$h1[0], $h1[1], $h1[2], $h1[3],
	$h2[0], $h2[1], $h2[2], $h2[3],
	$h3[0], $h3[1], $h3[2], $h3[3],
	$h4[0], $h4[1], $h4[2], $h4[3]); print"\n";

# chunk 2: 8 byte counter || 0x80 || 53 nulls || 0x02 || 0x40
for($i=0;$i<64;$i++) { $bytes[$i] = 0x00; }
$bytes[0] = 0x00;
$bytes[1] = 0x00;
$bytes[2] = 0x00;
$bytes[3] = 0x00;
$bytes[4] = 0x00;
$bytes[5] = 0x00;
$bytes[6] = 0x01;
$bytes[7] = 0x02;
$bytes[8] = 0x80;
$bytes[62] = 0x02;
$bytes[63] = 0x40;

# do not reset
&sha1_chunk;

printf("%02x" x 20,
	$h0[0], $h0[1], $h0[2], $h0[3],
	$h1[0], $h1[1], $h1[2], $h1[3],
	$h2[0], $h2[1], $h2[2], $h2[3],
	$h3[0], $h3[1], $h3[2], $h3[3],
	$h4[0], $h4[1], $h4[2], $h4[3]); print"\n";

# preserve h0-h4 for chunk 4
for($i=0;$i<4;$i++) { $stash[0+$i] = $h0[$i]; }
for($i=0;$i<4;$i++) { $stash[4+$i] = $h1[$i]; }
for($i=0;$i<4;$i++) { $stash[8+$i] = $h2[$i]; }
for($i=0;$i<4;$i++) { $stash[12+$i] = $h3[$i]; }
for($i=0;$i<4;$i++) { $stash[16+$i] = $h4[$i]; }

# reset
# chunk 3: key padded to 64 bytes xor 0x5c
$bytes[0] = 0x01 ^ 0x5c;
$bytes[1] = 0x02 ^ 0x5c;
$bytes[2] = 0x03 ^ 0x5c;
$bytes[3] = 0x04 ^ 0x5c;
for($i=4;$i<64;$i++) { $bytes[$i] = 0x5c; }

&sha1_reset;
&sha1_chunk;

printf("%02x" x 20,
	$h0[0], $h0[1], $h0[2], $h0[3],
	$h1[0], $h1[1], $h1[2], $h1[3],
	$h2[0], $h2[1], $h2[2], $h2[3],
	$h3[0], $h3[1], $h3[2], $h3[3],
	$h4[0], $h4[1], $h4[2], $h4[3]); print"\n";

# chunk 4: result from chunk 2 (20 bytes) || 0x80 || 41 nulls || 0x02 || 0xa0
for($i=0;$i<20;$i++) { $bytes[$i] = $stash[$i]; }
for($i=20;$i<64;$i++) { $bytes[$i] = 0x00; }
$bytes[20] = 0x80;
$bytes[62] = 0x02;
$bytes[63] = 0xa0;

# do not reset
&sha1_chunk;

printf("%02x" x 20,
	$h0[0], $h0[1], $h0[2], $h0[3],
	$h1[0], $h1[1], $h1[2], $h1[3],
	$h2[0], $h2[1], $h2[2], $h2[3],
	$h3[0], $h3[1], $h3[2], $h3[3],
	$h4[0], $h4[1], $h4[2], $h4[3]); print"\n";

$offset = $h4[3] & 0xf;
@hashy = (@h0, @h1, @h2, @h3, @h4);

$binary = (0
        | (($hashy[$offset] & 0x7f) << 24)
        | (($hashy[$offset+1] & 0xff) << 16)
        | (($hashy[$offset+2] & 0xff) << 8)
        | (($hashy[$offset+3] & 0xff))
);
printf(STDOUT "offset = $offset, binary = 0x%08x %i\n", $binary, $binary);
# modulo 10e6
$binary = $binary % 1000000;
print "$binary\n";


