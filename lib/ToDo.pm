#!/usr/bin/perl
package ToDo; 
require Exporter; 
use Tk; 

our @ISA = qw (Exporter); 
our @EXPORT = qw (mainnote $VERSION);
our @EXPORT_OK = (@EXPORT); 
our $VERSION = "1.0a"; 

my $datafile = "ToDo.pm.data";

sub mainnote {
	$w = new MainWindow( -title=>"ToDo");
	my $topl = $w -> Label (-text=>"Put Notes Here:", -background=>'black', -foreground=>'white') -> pack (-fill=>'x'); 
	my $men = $w -> Menu(-foreground=>'white', -background=>'black');
	$file = $men -> cascade (-tearoff=>0, -label=>"File");
	$file -> command (-label=>"New Note", -command=>\&initaddentry);
	$file -> command (-label=>"Save Notes to File...", -command=>\&savenotes);
	$file -> separator();
	$file -> command (-label=>"Exit", -command=>sub { exit; }); 
	
	$list = $w -> Listbox (-height=>35, -width=>40, -background=>'black', -foreground=>'white') -> pack (-fill=>'x');
	$addbutt = $w -> Button (-text=>"New Note", -command=>\&initaddentry, -activebackground=>"cyan", -background=>"black", -foreground=>'white' ) -> pack (-fill=>'x');
	$editbutt = $w -> Button (-text=>"Edit Note", -command=>\&initeditentry, -activebackground=>"cyan", -background=>"black", -foreground=>'white' ) -> pack (-fill=>'x');
	
	$deletebutt = $w -> Button (-text=>"Delete Note", -command=>\&deleteentry, -activebackground=>"cyan", -background=>"black", -foreground=>'white' ) -> pack (-fill=>'x');
	$exitbutt = $w -> Button (-text=>"Exit", -background=>'purple', -foreground=>'white', -command=>sub{exit;}) -> pack (-fill=>'x', -pady=>10);
	$w -> configure (-menu=>$men); 
	refreshlist(); 
	MainLoop();
	
	} 

sub initaddentry { 
	$addwin = new MainWindow(-title=>"Add Note"); 
	my $l = $addwin -> Label (-text=>"Type Note Text Here:", -foreground=>"white", -background=>"black") -> pack (-fill=>'x');  
	$addtxt = $addwin -> Entry (-width=>79, -foreground=>"white", -background=>"black") -> pack (-fill=>'x');
	$addtxt -> focusForce();
	$addbutt = $addwin -> Button (-foreground=>"white", -background=>"black", -text=>"Add Note", -activebackground=>"cyan", -command=>\&addentry) -> pack (-fill=>'x');
	$closebutt = $addwin -> Button (-foreground=>'white', -background=>"purple", -text=>"Close", -command=>sub { $addwin -> destroy(); } ) -> pack (-fill=>'x', -pady=>10);
	MainLoop(); 
	} 

sub addentry { 
	if (! $addtxt -> get() or $addtxt -> get () =~ /^\s*$/) {
		my $d = $addwin -> Dialog (-text=>"You Did Not Supply the Note",  title=>"Error");
		$d -> Show(); 
		return 0;
		} 
	if ( checkfordups () ) 
		{ 
		return 0; 
		} 
	$conts = $addtxt -> get();
	open (D, ">>$datafile");	
	print D "$conts\n";
	close (D);
	$addwin -> destroy();
	refreshlist(); 
	} 

sub savenotes { 
	
	open (D, $datafile);
	my @a = <D>; 
	close (D);
	chomp (@a); 
	if (scalar (@a)  == 0 or ! -e $datafile)
		{ 
		$die = $w -> Dialog (-title=>"Error", -text=>"There Are No Notes to Save."); 
		$die -> Show();
		return 0;
		} 
	$saved = $w -> getSaveFile (-title=>"Save Notes"); 
	open (S, ">$saved");
	print S "-Saved ToDo Notes-\n\n";
	foreach (@a) { 
		if ($_) { 
			print S "$_\n\n---\n\n"; 	
			} 
		} 	
	close (S);
	}
 
sub deleteentry { 
	my $n = $list -> get ($list->curselection()); 
	if (! $n) 
		{ 
		return 0; 
		} 
	open (D, $datafile);
	@notesd = <D>;
	close (D);
 	chomp (@notesd);
	unlink ($datafile); 
	open (D, ">>$datafile");
	foreach (@notesd) { 
		unless ($_ eq $n) {
			print D "$_\n";
			} 
		} 
	refreshlist(); 
	} 	

sub checkfordups { 
	open (D, $datafile);
	my @dat = <D>; 
	close (D);
	chomp (@dat); 
	my $d = $addwin -> Dialog (-title=>"Error", -text=>"A Duplicate Note Already Exists. Try Again.") ;
	foreach (@dat)
		{ 
		if ($_ eq $addtxt -> get( ) ) {
			$d -> Show();
			return 1; 
			} 
		} 
	return 0;
	} 

sub checkfordups2 { 
	open (D, $datafile);
	my @dat = <D>; 
	close (D);
	chomp (@dat); 
	my $d = $edwin -> Dialog (-title=>"Error", -text=>"A Duplicate Note Already Exists. Try Again.") ;
	foreach (@dat)
		{ 
		if ($_ eq $edtxt -> get( ) ) {
			$d -> Show();
			return 1; 
			} 
		} 
	return 0;
	} 

sub initeditentry { 
	$orig = $list->get ($list->curselection());
	if ($orig  eq '') 
		{ 
		print "REt 0\n";
		return 0; 
		} 
	$edwin = new MainWindow(-title=>"Edit Note"); 
	my $l = $edwin -> Label (-text=>"Type Note Text Here:", -foreground=>"white", -background=>"black") -> pack (-fill=>'x');  
	$edtxt = $edwin -> Entry (-width=>79, -foreground=>"white", -background=>"black") -> pack (-fill=>'x');
	$edtxt -> insert ('end', $orig );
	$edtxt -> focusForce();
	$edbutt = $edwin -> Button (-foreground=>"white", -background=>"black", -text=>"Edit Note", -activebackground=>"cyan", -command=>\&editentry) -> pack (-fill=>'x');
	$edclosebutt = $edwin -> Button (-foreground=>'white', -background=>"purple", -text=>"Close", -command=>sub { $edwin -> destroy(); } ) -> pack (-fill=>'x', -pady=>10);
	MainLoop(); 
	} 

sub editentry { 
	if (! $edtxt -> get() or $edtxt -> get () =~ /^\s*$/) {
		my $d = $edwin -> Dialog (-text=>"You Did Not Supply the Note",  title=>"Error");
		$d -> Show(); 
		return 0;
		} 
	if ( checkfordups2 () ) 
		{ 
		return 0; 
		} 	
	open (DREAD, $datafile);
	@a = <DREAD>; 
	close (DREAD); 
	unlink ($datafile);
	open  (D, ">>$datafile");
	my $k; 
	foreach  $k (@a) { 
		if ($k eq "$orig\n") {
			$k = $edtxt -> get(); 
			} 
		} 
	print D @a; 
	close D;
	refreshlist ();
	$edwin -> destroy();	
	} 

sub refreshlist	{ 
	$list -> delete (0, 'end'); 
	open (D, $datafile);
	@data = <D>;
	close (D);
	chomp (@data);
	foreach (@data) { 
		unless (! $_) { 
			$list-> insert ('end', $_);
			} 
		} 
	} 
1; 

__END__

=head1 NAME

ToDo - A Todo List. 

=head1 SYNOPSIS

  use ToDo;
  mainnote; 

=head1 DESCRIPTION

All you have to do is write the two lines mentioned above in synopsis. There is nothing else to it. The todo list is fairly complete and works pretty good. Enjoy! :-)

=head1 SEE ALSO

www.infusedlight.net  -  my web site. 

and see also the perl module Tk. 


=head1 AUTHOR

Robin Bank, E<lt>webmaster@infusedlight.net<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Robin Bank

Do whatever you want with it. 

=cut
