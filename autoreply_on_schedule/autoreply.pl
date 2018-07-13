#!/usr/bin/perl

use strict;
use MIME::Base64;

my ($to, $from) = @ARGV;
$from =~ s/autoreply.mailtest.avionics/mailtest.avionics/;

open MAIL, "| /usr/sbin/sendmail -t -oi";
print MAIL "To: $to\nFrom: noreply\@mailtest.avionics\nSubject: Notify\n";
print MAIL 'MIME-Version: 1.0', "\n";
print MAIL 'Content-Type: text/plain; charset="utf-8"', "\n";
print MAIL 'Content-Transfer-Encoding: base64', "\n\n";
# get text from file
open MSG, "/etc/postfix/autoreply_msg/noreply.msg";
my $msg = "autoreply from $from\n\n" . join ( "", <MSG> );
print MAIL encode_base64($msg), "\n";
close MSG;

close MAIL;