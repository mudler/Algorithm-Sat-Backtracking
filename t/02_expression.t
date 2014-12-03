use strict;
use Test::More 0.98;
use Data::Dumper;
use Algorithm::SAT::Backtracking;
use_ok("Algorithm::SAT::Expression");

subtest "and()" => sub {
    my $expr = Algorithm::SAT::Expression->new;
    $expr->and( "blue", "green" );
    $expr->and('pink');
    ok( defined $expr->{_literals}->{pink},
        'expression contains a clause [pink]'
    );
    ok( defined $expr->{_literals}->{blue},
        'expression contains a clause [blue]'
    );

    ok( defined $expr->{_literals}->{green},
        'expression contains a clause [green]'
    );

    ok( !!grep { "@{$_}" eq "pink" } @{ $expr->{_expr} } );
    ok( !!grep { "@{$_}" eq "blue" } @{ $expr->{_expr} } );
};

subtest "or()" => sub {
    my $expr = Algorithm::SAT::Expression->new;
    $expr->or( "blue", "green" );
    $expr->or('pink');
    $expr->or( 'purple', '-yellow', 'green' );

    ok( !!grep { "@{$_}" eq "blue green" } @{ $expr->{_expr} } );
};

subtest "xor()" => sub {
    my $expr = Algorithm::SAT::Expression->new;
    $expr->xor( "foo", "bar" );
    ok( !!grep { "@{$_}" eq "-foo -bar" } @{ $expr->{_expr} } );
    $expr->xor( "foo", "bar", "baz" );
    ok( !!grep { "@{$_}" eq "foo bar baz" } @{ $expr->{_expr} } );
    ok( !!grep { "@{$_}" eq "-foo -bar" } @{ $expr->{_expr} } );
    ok( !!grep { "@{$_}" eq "-bar -baz" } @{ $expr->{_expr} } );
};

subtest "solve()" => sub {
    my $exp       = Algorithm::SAT::Expression->new;
    my $backtrack = Algorithm::SAT::Backtracking->new;
    $exp->or( 'blue',  'green',  '-yellow' );
    $exp->or( '-blue', '-green', 'yellow' );
    $exp->or( 'pink',  'purple', 'green', 'blue', '-yellow' );
    my $model = $exp->solve();
    foreach my $clause ( @{ $exp->{_expr} } ) {
        is( $backtrack->satisfiable( $clause, $model ),
            1, "@{$clause} is satisfiable against the model" );
    }
    print Dumper($model);
};

done_testing;

