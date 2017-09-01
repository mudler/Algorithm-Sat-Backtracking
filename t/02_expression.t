use strict;
use Test::More 0.98;
use Algorithm::SAT::Backtracking;
use Algorithm::SAT::Expression;

my @algs = qw(
  Algorithm::SAT::Backtracking
  Algorithm::SAT::Backtracking::DPLL
  Algorithm::SAT::Backtracking::DPLLProb
  Algorithm::SAT::Backtracking::DPLLFreq
  Algorithm::SAT::Backtracking::DPLLUnFreq
  Algorithm::SAT::Backtracking::Ordered::DPLL
);

subtest "and()" => sub {
    foreach my $impl (@algs) {
        my $expr = Algorithm::SAT::Expression->new->with($impl);
        $expr->and( "blue", "green" );
        $expr->and('pink');
        ok( defined $expr->{_literals}->{pink},
            'expression contains a clause [pink] (' . $impl . ')' );
        ok( defined $expr->{_literals}->{blue},
            'expression contains a clause [blue]  (' . $impl . ')' );

        ok( defined $expr->{_literals}->{green},
            'expression contains a clause [green]  (' . $impl . ')' );
        ok( !!grep { "@{$_}" eq "pink" } @{ $expr->{_expr} } );
        ok( !!grep { "@{$_}" eq "blue" } @{ $expr->{_expr} } );
    }
};

subtest "or()" => sub {
    foreach my $impl (@algs) {
        my $expr = Algorithm::SAT::Expression->new->with($impl);
        $expr->or( "blue", "green" );
        $expr->or('pink');
        $expr->or( 'purple', '-yellow', 'green' );
        ok( !!grep { "@{$_}" eq "blue green" } @{ $expr->{_expr} } );

        $expr = Algorithm::SAT::Expression->new;
        $expr->or( '-foo@2.1', 'bar@2.2' );
        $expr->or( '-foo@2.3', 'bar@2.2' );
        $expr->or( '-baz@2.3', 'bar@2.3' );
        $expr->or( '-baz@1.2', 'bar@2.2' );
        ok( !!grep { "@{$_}" eq join( " ", '-foo@2.1', 'bar@2.2' ) }
              @{ $expr->{_expr} } );
        ok( !!grep { "@{$_}" eq join( " ", '-foo@2.3', 'bar@2.2' ) }
              @{ $expr->{_expr} } );
        ok( !!grep { "@{$_}" eq join( " ", '-baz@2.3', 'bar@2.3' ) }
              @{ $expr->{_expr} } );
        ok( !!grep { "@{$_}" eq join( " ", '-baz@1.2', 'bar@2.2' ) }
              @{ $expr->{_expr} } );
        is_deeply(
            $expr->solve,
            {
                'bar@2.2' => 1,
                'bar@2.3' => 1,
                'foo@2.3' => 1,
                'baz@2.3' => 1,
                'foo@2.1' => 1
            },
            "solving"
        );
    }
};

subtest "xor()" => sub {
    foreach my $impl (@algs) {
        my $expr = Algorithm::SAT::Expression->new->with($impl);
        $expr->xor( "foo", "bar" );
        ok( !!grep { "@{$_}" eq "-foo -bar" } @{ $expr->{_expr} } );
        $expr->xor( "foo", "bar", "baz" );
        ok( !!grep { "@{$_}" eq "foo bar baz" } @{ $expr->{_expr} } );
        ok( !!grep { "@{$_}" eq "-foo -bar" } @{ $expr->{_expr} } );
        ok( !!grep { "@{$_}" eq "-bar -baz" } @{ $expr->{_expr} } );
    }
};

subtest "not()" => sub {
    my $expr = Algorithm::SAT::Expression->new;
    is $expr->not('a'),  "-a", "Not a is -a";
    is $expr->not('-a'), "a",  "Not -a is a";
};

subtest "solve()" => sub {
    for my $impl (
        @algs,

        #  "Algorithm::SAT::Backtracking::Ordered",
        #  "Algorithm::SAT::Backtracking::Ordered::DPLL"
      )
    {
        my $exp       = Algorithm::SAT::Expression->new;
        my $backtrack = $impl->new;
        $exp->or( 'blue',  'green',  '-yellow' );
        $exp->or( '-blue', '-green', 'yellow' );
        $exp->or( 'pink',  'purple', 'green', 'blue', '-yellow' );
        my $model = $exp->solve();
        foreach my $clause ( @{ $exp->{_expr} } ) {
            is( $backtrack->satisfiable( $clause, $model ),
                1, "@{$clause} is satisfiable against the model ($impl)" );
        }
    }
};

done_testing;
