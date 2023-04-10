#!/usr/bin/perl
   
$CLAMSCAN = "/usr/bin/clamscan";
   
if (@ARGV != 1) {
    print "Usage: modsec_clamav.pl <filename>\n";
    exit;
}
   
my ($FILE) = @ARGV;
   
$cmd = "$CLAMSCAN --stdout --disable-summary $FILE";
$input = `$cmd`;
$input =~ m/^(.+)/;
$error_message = $1;
   
$output = "0 Unable to parse clamscan output";
   
if ($error_message =~ m/: Empty file\.$/) {
    $output = "1 empty file";
}
elsif ($error_message =~ m/: (.+) ERROR$/) {
    $output = "0 clamscan: $1";
}
elsif ($error_message =~ m/: (.+) FOUND$/) {
    $output = "0 clamscan: $1";
}
elsif ($error_message =~ m/: OK$/) {
    $output = "1 clamscan: OK";
}
   
print "$output\n";
EOL