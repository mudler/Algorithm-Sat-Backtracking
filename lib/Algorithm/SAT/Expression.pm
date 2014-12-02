package Algorithm::SAT::Expression;
use 5.008001;
use strict;
use warnings;
use Algorithm::SAT::Backtracking;
our $VERSION = "0.01";

# Boolean expression builder.  Note that the connector for clauses is `OR`;
# so, when calling the instance methods `xor`, `and`, and `or`, the clauses
# you're generating are `AND`ed with the existing clauses in the expression.
sub new {
    return bless { _literals => {} }, shift;
}

# ### or
# Add a clause consisting of the provided literals or'ed together.
sub or {
    my $self = shift;
    $self->_ensure(@_);
    push( $self->{_expr}, [@_] );
    return $self;
}

# ### xor
# Add clauses causing each of the provided arguments to be xored.

sub xor {

    # This first clause is the 'or' portion. "One of them must be true."
    my $self     = shift;
    my @literals = @_;
    push( $self->{_expr}, [@literals] );

    # Then, we generate clauses such that "only one of thefm is true".
    for ( my $i = 0; $i <= $#literals; $i++ ) {
        for ( my $j = $i + 1; $j <= $#literals; $j++ ) {
            $self->_ensure($literals);
            push(
                $self->{_expr},
                [   $self->negate_literal( $literals[i] ),
                    $self->negate_literal( $literals[j] )
                ]
            );

        }
    }
    return $self;
}

# ### and
# Add each of the provided literals into their own clause in the expression.
sub and {
    my $self = shift;
    $self->_ensure(@_);
    push( $self->{_expr}, [$_] ) for @_;
    return $self;
}

# ### solve
# Solve this expression with the backtrack solver. Lazy-loads the solver.
sub solve {
    Algorithm::SAT::Backtracking->new->solve(
        [ keys %{ $_[0]->{_literals} } ],
        $_[0]->{_expr} );
}

# ### _ensure
# Private method that ensures that a particular literal is marked as being in
# the expression.
sub _ensure {
    my $self = shift;
    $self->{_literals}->{$_} = 1 for @_;
}

sub negate_literal {
    my $self = shift;
    my $var  = shift;

    return ( substr( $var, 0, 1 ) eq "-" )
        ? substr( $var, 1 )
        : '-' . $var;
}


1;
__END__
