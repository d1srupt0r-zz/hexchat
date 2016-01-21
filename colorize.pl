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

my @rcolors = ( 19, 20, 22, 24, 25, 26, 27, 28, 29 );
my $exit;

hook_command("colorz", \&colorz, { help_text => "Usage: /colorz to show a list of available colors."});

sub colorz {
	for my $color (@rcolors) {
		HexChat::printf("\cC%d%s", $color, $color);
	}
	return EAT_ALL;
}

sub colorize {
	$exit = 0;

	my @msg = @{$_[0]};
	my $event = $_[1];
	my $nick = HexChat::strip_code($msg[0]);
	my $num = &text_color_of($nick);

	#HexChat::printf("\cC%d%d | %s", $num, $num, $event);
	my $custom = $msg[2] 
		? sprintf("\cC%d%s\cC%d%s", 0, $msg[2], $num, $nick)
		: sprintf("\cC%d%s", $num, $nick);

	HexChat::emit_print($event, $custom, $msg[1]) unless $exit;
	return EAT_ALL;
}

sub text_color_of {
	my $sum = 0;
	for my $byte (split //, $_[0]) {
		$sum += ord($byte);
	}
	$sum %= $#rcolors / 2;
	return $rcolors[rand($sum)];
}
