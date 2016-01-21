use strict;
use warnings;
use HexChat qw(:all);

my $name = "colorize";
my $version = "0.1";

register($name, $version, "colorize nicks");
HexChat::printf("Loading %s version %s", $name, $version);

my @events = (
	"Channel Message",
	"Channel Action",
	"Channel Msg Hilight",
	"Channel Action Hilight",
	"Your Message",
	"Your Action"
);

sub on_unload {
	HexChat::printf("%s version %s unloaded", $name, $version);
}

for my $event (@events) {
	hook_print($event, \&colorize, { data => $event, priority => PRI_HIGH});
}

my $exit;

sub colorize {
	$exit = 0;

	my @msg = @{$_[0]};
	my $event = $_[1];
	my $nick = $msg[0];

	my $num = &text_color_of(HexChat::strip_code($nick));
	HexChat::printf("\cC%d%d", $num, $num);	
	$msg[0] = sprintf("\cC%d%s", $num, $msg[0]);
	emit_print($event, @msg) unless $exit;

	return EAT_ALL;
}

sub text_color_of {
	my @rcolors = ( 19, 20, 22, 24, 25, 26, 27, 28, 29 );
	my $sum = 0;
	for my $byte (split //, $_[0]) {
		$sum += ord($byte);
		#HexChat::printf("%s", ord($byte));
	}
	$sum %= $#rcolors / 2;
	return $rcolors[$sum];#sprintf("\cC%s%s", 24, HexChat::strip_code($_[0]))
}
