package Algorithm::SAT::Backtracking;
use 5.008001;
use strict;
use warnings;
use Storable qw(dclone);

our $VERSION = "0.01";

sub new {
    return bless {}, shift;
}

# This is an extremely simple implementation of the 'backtracking' algorithm for
# solving boolean satisfiability problems. It contains no optimizations.

# The input consists of a boolean expression in Conjunctive Normal Form.
# This means it looks something like this:
#
# `(blue OR green) AND (green OR NOT yellow)`
#
# We encode this as an array of strings with a `-` in front for negation:
#
# `[['blue', 'green'], ['green', '-yellow']]`
sub solve {

    # ### solve
    #
    # * `variables` is the list of all variables
    # * `clauses` is an array of clauses.
    # * `model` is a set of variable assignments.
    my $self      = shift;
    my $variables = shift;
    my $clauses   = shift;
    my $model     = shift // {};

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

# ### update
# Copies the model, then sets `choice` = `value` in the model, and returns it.
sub update {
    my $self   = shift;
    my $copy   = dclone(shift);
    my $choice = shift;
    my $value  = shift;
    $copy->{$choice} = $value;
    return $copy;
}

# ### resolve
# Resolve some variable to its actual value, or undefined.
sub resolve {
    my $self  = shift;
    my $var   = shift;
    my $model = shift;
    if ( substr( $var, 0, 1 ) eq "-" ) {
        my $value = $model->{ substr( $var, 1 ) };
        return !defined $value ? undef : $value == 0 ? 1 : 0;
    }
    else {
        return $model->{$var};
    }
}

# ### satisfiable
# Determines whether a clause is satisfiable given a certain model.
sub satisfiable {
    my $self    = shift;
    my $clauses = shift;
    my $model   = shift;
    my @clause  = @{$clauses};

    # If every variable is false, then the clause is false.
    return 0
        if (
        (   grep {
                ( defined $self->resolve( $_, $model )
                        and $self->resolve( $_, $model ) == 0 )
                    ? 0
                    : 1
            } @{$clauses}
        ) == 0
        );

    #If any variable is true, then the clause is true.
    return 1
        if (
        (   grep {
                ( defined $self->resolve( $_, $model )
                        and $self->resolve( $_, $model ) == 1 )
                    ? 1
                    : 0
            } @{$clauses}
        ) > 0
        );

    # Otherwise, we don't know what the clause is.
    return undef;
}

1;
__END__

=encoding utf-8

=head1 NAME

Algorithm::SAT::Backtracking - It's new $module

=head1 SYNOPSIS

    use Algorithm::SAT::Backtracking;

=head1 DESCRIPTION

Algorithm::SAT::Backtracking is ...

=head1 LICENSE

Copyright (C) mudler.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

mudler E<lt>mudler@dark-lab.netE<gt>

=cut

