package Algorithm::SAT::Backtracking::Ordered::DPLL;
use Hash::Ordered;
use base "Algorithm::SAT::Backtracking::DPLL";
use Algorithm::SAT::Backtracking::DPLL
    "Algorithm::SAT::Backtracking::Ordered";
##Ordered implementation, of course has its costs
sub solve {
    my $self      = shift;
    my $variables = shift;
    my $clauses   = shift;
    my $model     = defined $_[0] ? shift : Hash::Ordered->new;
    return $self->SUPER::solve( $variables, $clauses, $model );
}

sub _up {
    my $self      = shift;
    my $variables = shift;
    my $clauses   = shift;
    my $model     = defined $_[0] ? shift : Hash::Ordered->new;

    #Finding single clauses that must be true, and updating the model
    ( @{$_} != 1 )
        ? ()
        : ( substr( $_->[0], 0, 1 ) eq "-" ) ? (
        do {
            my $literal = substr( $_->[0], 1 );
            $model->set( $literal => 0 );
            $self->_delete_from_index( $literal, $clauses );
            }
#remove the positive clause form OR's and add it to the model with a false value
        )
        : (
                $self->_add_literal( "-" . $_->[0], $clauses )
            and $model->set( $_->[0] => 1 )

        ) # if the literal is present, remove it from SINGLE ARRAYS in $clauses and add it to the model with a true value
        for ( @{$clauses} );
    return $model;
}

sub _add_literal {
    my $self    = shift;
    my $literal = shift;
    my $clauses = shift;
    my $model   = shift;
    $literal
        = ( substr( $literal, 0, 1 ) eq "-" )
        ? $literal
        : substr( $literal, 1 );
    return
            if $model
        and $model->exists($literal)
        and $model->set( $literal, 1 );    #avoid cycle if already set
         #remove the literal from the model (set to false)
    $model->set( $literal, 1 );
    $self->_delete_from_index( $literal, $clauses );
    return 1;
}

sub _choice {
    my $self      = shift;
    my $variables = shift;
    my $model     = shift;
    foreach my $variable ( @{$variables} ) {
        $choice = $variable and last if ( !$model->exists($variable) );
    }
    return $choice;
}

1;
