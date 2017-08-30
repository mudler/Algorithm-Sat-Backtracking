package Algorithm::SAT::Backtracking::DPLLUnFreq;
use base 'Algorithm::SAT::Backtracking::DPLL';
use strict;
use warnings;
our $VERSION = "0.14";

sub _choice {
    my ( undef, $variables, $model ) = @_;

    my %h_variables;

    $h_variables{$_}++ for grep { !exists $model->{$_} } @{$variables}; #Build a hash with variables that wasn't already tried yet
    return ~~
        ( sort { $h_variables{$a} <=> $h_variables{$b} } keys %h_variables )
        [0];    #choose the most unfrequently
}

1;

=encoding utf-8

=head1 NAME

Algorithm::SAT::Backtracking::DPLLUnFreq - A DPLL Frequentist Backtracking SAT solver written in pure Perl

=head1 SYNOPSIS


    # You can use it with Algorithm::SAT::Expression
    use Algorithm::SAT::Expression;

    my $expr = Algorithm::SAT::Expression->new->with("Algorithm::SAT::Backtracking::DPLLUnFreq");
    $expr->or( '-foo@2.1', 'bar@2.2' );
    $expr->or( '-foo@2.3', 'bar@2.2' );
    $expr->or( '-baz@2.3', 'bar@2.3' );
    $expr->or( '-baz@1.2', 'bar@2.2' );
    my $model = $exp->solve();

    # Or you can use it directly:
    use Algorithm::SAT::BacktrackingDPLLUnFreq;
    my $solver = Algorithm::SAT::Backtracking::DPLLUnFreq->new;
    my $variables = [ 'blue', 'green', 'yellow', 'pink', 'purple' ];
    my $clauses = [
        [ 'blue',  'green',  '-yellow' ],
        [ '-blue', '-green', 'yellow' ],
        [ 'pink', 'purple', 'green', 'blue', '-yellow' ]
    ];

    my $model = $solver->solve( $variables, $clauses );

=head1 DESCRIPTION

Algorithm::SAT::Backtracking::DPLLUnFreq is a pure Perl implementation of a SAT Backtracking solver.

Look at L<Algorithm::SAT::Backtracking> for a theory description.

L<Algorithm::SAT::Expression> use this module to solve Boolean expressions.

=head1 METHODS

Inherits all the methods from L<Algorithm::SAT::Backtracking::DPLL> and in this variant C<_choice()> it's overrided to choose the most unfrequent literal between that wasn't used before.

=head1 LICENSE

Copyright (C) mudler.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

mudler E<lt>mudler@dark-lab.netE<gt>

=head1 SEE ALSO

L<Algorithm::SAT::Expression>, L<Algorithm::SAT::Backtracking>,L<Algorithm::SAT::Backtracking::DPLL>, L<Algorithm::SAT::Backtracking::Ordered>, L<Algorithm::SAT::Backtracking::Ordered::DPLL>

=cut