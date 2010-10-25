#!/usr/bin/perl
use Net::Trac;
use Net::Trac::Ticket;
use Spreadsheet::Read;
use utf8; 

sub searchTicket;
sub createTicket;

# Configuro la conexión al trac.
my $trac = Net::Trac::Connection->new(
    url      => 'https://desarrollo.covetel.com.ve/CNTI-14-09',
	user	 => 'walter',
	password => '',
    );

# Leo el archivo de tareas
my $ref = ReadData ("tareas.xls");

my $registrados = 0; 

# Tengo 30 tareas
foreach (1..30){
	my $summary 		= $ref->[1]->{'A'.$_};
	my $description 	= $ref->[1]->{'B'.$_};
	my $milestone	 	= $ref->[1]->{'C'.$_};
	my $component 		= $ref->[1]->{'D'.$_};
	
	# Busco en Trac por el summary del ticket, para no duplicarlo.
	my $m = $summary; 
	utf8::encode($m);
	print "Trabajando con: $m \n";
	if (!searchTicket $summary){
		my $ticket = createTicket $summary, $description, $component, $milestone;
		$registrados++;
		print "Ticket $ticket creado \n";  
	} else {
		print "Ya existe otro ticket con este titulo \n";
	}
	
}

print "\n";
print "Han sido registrados $registrados tickets nuevos \n";
 

1;


# Antes de crear un ticket, debo buscar para no duplicar. 
#my $ticket = searchTicket 'Esto es una prue';
#$ticket = createTicket 'Esto es una prueba 2', 'La descripcion del ticket', 'Requerimiento 1', 'Segundo Sprint';

sub searchTicket {
	my ($summary) = @_;
	# Quito los espacios en blanco adicionales. 
	$summary =~ s/\s+$//g;
	$summary =~ s/^\s+//g;
	utf8::encode($summary);

	my $search = Net::Trac::TicketSearch->new(connection => $trac); 
	$search->limit(1);
	$search->query(
		summary => { 'contains' => $summary },
	);	
	my ($r) = $search->results;

	if ($search->results->[0]){
		my $ticket = $search->results->[0];
		return $ticket; 
	}
	else {
		return undef;
	}
}


sub createTicket {
	my ($summary, $description, $component, $milestone) = @_; 
	my $ticket = Net::Trac::Ticket->new(connection => $trac); 
	my $id = $ticket->create(
		summary => $summary,
		description => $description, 
		component => $component,
		milestone => $milestone,
	);
	return $id;
}

