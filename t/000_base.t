use strict;
use warnings;

use FindBin;
use Cwd;
use Test::More tests => 3;

my $cwd = getcwd();
chdir($FindBin::Bin);
use_ok("Test::OBS::DownloadServer");

my $dls = Test::OBS::DownloadServer->new(8080);
$dls->document_root( $FindBin::Bin . "/htdocs");

ok($dls,"Checking creation of dls object");
my $pid;
{
  local *STDOUT;
  my $out;
  open(STDOUT,">",\$out);
  $pid = $dls->start_server();
}

#print "ps -ef|grep $pid\n";
`curl http://localhost:8080/test.txt 2>/dev/null 1> test.txt`;

open(my $fh,"<","test.txt");

my @content = <$fh>;

close($fh);

is_deeply(\@content,["test\n"],"Checking content of test.txt");


$dls->stop_server();

unlink("test.txt");

chdir($cwd);

exit 0;
