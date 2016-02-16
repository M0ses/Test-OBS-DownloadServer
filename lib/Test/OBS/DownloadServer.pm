package Test::OBS::DownloadServer;

use HTTP::Server::Simple::CGI;
use Path::Class qw/file/;
use base qw(HTTP::Server::Simple::CGI);
use File::Type;
use FindBin;

sub dispatch      { $_[0]->{dispatch} = $_[1] ? $_[1] : $_[0]->{dispatch};  return $_[0]->{dispatch}}
sub pid           { $_[0]->{pid}      = $_[1] ? $_[1] : $_[0]->{pid};       return $_[0]->{pid}}
sub document_root { $_[0]->{document_root} = $_[1] ? $_[1] : $_[0]->{document_root};return $_[0]->{document_root}}

sub handle_request {
   my $self = shift;
   my $cgi  = shift;

   my $path = $cgi->path_info();
   my $handler = $self->{dispatch}->{$path};

   my $file = file($self->document_root,$path);

   if (ref($handler) eq "CODE") {
       print "HTTP/1.0 200 OK\r\n";
       $handler->($path);
   } elsif ( -f $file->stringify ) {
       print "HTTP/1.0 200 OK\r\n";
       $self->file_handler($file);
   } else {
       print "HTTP/1.0 404 Not found\r\n";
       print $cgi->header,
             $cgi->start_html('Not found'),
             $cgi->h1('Not found'),
             $cgi->end_html;
   }
}

sub file_handler {
  my $self  = shift;
  my $f     = shift;

  my $fc    = $f->slurp();
  my $l     = length($fc);
  my $ct    = File::Type->new()->checktype_filename($f);

  print "Content-Type: $ct\r\n";
  print "Content-Length: $l\r\n\r\n";
  print $fc;

}

sub start_server {
  my $self = shift;
  $self->pid(
    $self->background()
  )
};

sub stop_server {
  kill 15, $_[0]->pid;
};



1;
