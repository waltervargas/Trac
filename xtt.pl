#!/usr/bin/perl
use Net::Trac;
use Net::Trac::Ticket;

sub searchTicket;
sub createTicket;

# Configuro la conexión al trac.
my $trac = Net::Trac::Connection->new(
        url      => 'http://localhost:8000/CNTI-14-09',
	user	 => 'anonymous',
	password => '123321...',
    );

# Antes de crear un ticket, debo buscar para no duplicar. 
my $ticket = searchTicket 'Esto es una prue';
$ticket = createTicket 'Esto es una prueba 2', 'La descripcion del ticket', 'Requerimiento 1', 'Segundo Sprint';
1;

sub searchTicket {
	my ($summary) = @_;
	my $search = Net::Trac::TicketSearch->new(connection => $trac); 
	$search->limit(1);
	$search->query(
		summary => { 'contains' => $summary },
	);	
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

