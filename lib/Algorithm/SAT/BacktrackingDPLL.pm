package Algorithm::SAT::BacktrackingDPLL;
use base 'Algorithm::SAT::Backtracking';
use Storable qw(dclone);
use Data::Dumper;

sub solve {

    # ### solve
    #
    # * `variables` is the list of all variables
    # * `clauses` is an array of clauses.
    # * `model` is a set of variable assignments.
    my $self      = shift;
    my $variables = shift;
    my $clauses   = shift;
    my $model     = defined $_[0] ? shift : {};
    my $impurity  = dclone($clauses);

    if ( !exists $self->{_impurity} ) {
        $self->{_impurity}->{$_}++ for ( map { @{$_} } @{$impurity} );
    }

    # If every clause is satisfiable, return the model which worked.
    return $model
        if (
        (   grep {
                ( defined $self->satisfiable( $_, $model )
                        and $self->satisfiable( $_, $model ) == 1 )
                    ? 0
                    : 1
            } @{$clauses}
        ) == 0
        );

    # If any clause is **exactly** false, return `false`; this model will not
    # work.
    return 0 if !$self->_consistency_check( $clauses, $model );

    $model = $self->_up( $variables, $clauses, $model )
        ;    # find unit clauses and sets them

    return 0 if !$self->_consistency_check( $clauses, $model );

    # Choose a new value to test by simply looping over the possible variables
    # and checking to see if the variable has been given a value yet.

    my $choice;
    foreach my $variable ( @{$variables} ) {
        $choice = $variable and last if ( !exists $model->{$variable} );
    }

    # If there are no more variables to try, return false.

    return 0 if ( !$choice );

    # Recurse into two cases. The variable we chose will need to be either
    # true or false for the expression to be satisfied.
    return $self->solve( $variables, $clauses,
        $self->update( $model, $choice, 1 ) )    #true
        || $self->solve( $variables, $clauses,
        $self->update( $model, $choice, 0 ) );    #false
}

sub _consistency_check {
    my $self    = shift;
    my $clauses = shift;
    my $model   = shift;
    return 0
        if (
        (   grep {
                ( defined $self->satisfiable( $_, $model )
                        and $self->satisfiable( $_, $model ) == 0 )
                    ? 1
                    : 0
            } @{$clauses}
        ) > 0
        );
    return 1;

}

sub _pure {
    my $self    = shift;
    my $literal = shift;

    #     Pure literal rule

    # if a variable only occurs positively in a formula, set it to true
    # if a variable only occurs negated in a formula, set it to false

    my $opposite
        = substr( $literal, 0, 1 ) eq "-"
        ? substr( $literal, 1 )
        : "-" . $literal;

    return 1
        if (
        (   exists $self->{_impurity}->{$literal}
            and $self->{_impurity}->{$literal} != 0
        )
        and (
            !exists $self->{_impurity}->{$opposite}
            or ( exists $self->{_impurity}->{$opposite}
                and $self->{_impurity}->{$opposite} == 0 )
        )
        );

    return 0;
}

sub _up {
    my $self      = shift;
    my $variables = shift;
    my $clauses   = shift;
    my $model     = defined $_[0] ? shift : {};
    use Data::Dumper;

    #Finding single clauses that must be true, and updating the model
    ( @{$_} != 1 )
        ? ()
        : ( substr( $_->[0], 0, 1 ) eq "-" ) ? (
        $self->_remove_literal( substr( $_->[0], 1 ), $clauses, $model )
        )    #XXX: to add: remove the positive clause form OR's
        : (     $self->_add_literal( "-" . $_->[0], $clauses )
            and $model->{ $_->[0] }
            = 1
        ) # XXX: if the literal is present, remove it from SINGLE ARRAYS in $clauses and from http://www.dis.uniroma1.it/~liberato/ar/dpll/dpll.html DPLL # with UP
        for ( @{$clauses} );
    return $model;
}

sub _remove_literal {
    my $self    = shift;
    my $literal = shift;
    my $clauses = shift;
    my $model   = shift;
    return
            if $model
        and exists $model->{$literal}
        and $model->{$literal} == 0;    #avoid cycle if already set
        #remove the literal from the model (set to false)
    &_delete_from_index( $literal, $clauses );

    return 1;
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
        and exists $model->{$literal}
        and $model->{$literal} == 1;    #avoid cycle if already set
        #remove the literal from the model (set to false)
    &_delete_from_index( $literal, $clauses );
    return 1;
}

sub _delete_from_index {
    my $string = shift;
    my $list   = shift;
    foreach my $c ( @{$list} ) {
        next if @{$c} <= 1;
        for ( my $index = scalar( @{$c} ); $index >= 0; --$index ) {
            splice( @{$c}, $index, 1 )
                if $c->[$index] eq $string;    # remove certain elements
        }
    }
}

1;
