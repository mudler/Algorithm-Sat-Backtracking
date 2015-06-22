use strict;
use Test::More 0.98;
use Algorithm::SAT::Backtracking::Ordered;
use Algorithm::SAT::Expression;
use Algorithm::SAT::Backtracking::Ordered::DPLL;

subtest "and()" => sub {
    my $expr = Algorithm::SAT::Expression->new->with(
        "Algorithm::SAT::Backtracking::Ordered::DPLL");
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
    my $expr = Algorithm::SAT::Expression->new->with(
        "Algorithm::SAT::Backtracking::Ordered::DPLL");
    $expr->or( "blue", "green" );
    $expr->or('pink');
    $expr->or( 'purple', '-yellow', 'green' );
    ok( !!grep { "@{$_}" eq "blue green" } @{ $expr->{_expr} } );

    $expr = Algorithm::SAT::Expression->new->with(
        "Algorithm::SAT::Backtracking::Ordered::DPLL");
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
    my $ordered_hash = $expr->solve;
    my $solution     = {
        'bar@2.2' => 1,
        'bar@2.3' => 1,
        'foo@2.3' => 1,
        'baz@2.3' => 1,
        'foo@2.1' => 1
    };

    while (
        my ( $k, $v ) = each(
            %{$solution}

        )
        )
    {
        is( $ordered_hash->get($k), $v, "$k=>$v" );
    }

};

subtest "xor()" => sub {
    my $expr = Algorithm::SAT::Expression->new->with(
        "Algorithm::SAT::Backtracking::Ordered::DPLL");
    $expr->xor( "foo", "bar" );
    ok( !!grep { "@{$_}" eq "-foo -bar" } @{ $expr->{_expr} } );
    $expr->xor( "foo", "bar", "baz" );
    ok( !!grep { "@{$_}" eq "foo bar baz" } @{ $expr->{_expr} } );
    ok( !!grep { "@{$_}" eq "-foo -bar" } @{ $expr->{_expr} } );
    ok( !!grep { "@{$_}" eq "-bar -baz" } @{ $expr->{_expr} } );
};

subtest "solve()" => sub {
    my $exp = Algorithm::SAT::Expression->new->with(
        "Algorithm::SAT::Backtracking::Ordered::DPLL");
    my $backtrack = Algorithm::SAT::Backtracking::Ordered->new;
    $exp->or( 'blue',  'green',  '-yellow' );
    $exp->or( '-blue', '-green', 'yellow' );
    $exp->or( 'pink',  'purple', 'green', 'blue', '-yellow' );
    my $model = $exp->solve();
    foreach my $clause ( @{ $exp->{_expr} } ) {
        is( $backtrack->satisfiable( $clause, $model ),
            1, "@{$clause} is satisfiable against the model" );
    }
};

subtest "_pure()/_pure_unit()" => sub {
    my $agent = Algorithm::SAT::Backtracking::Ordered::DPLL->new;

    my $variables = [ 'blue', 'green', 'yellow', 'pink', 'purple', 'z' ];
    my $clauses = [
        [ 'blue',  'green',  '-yellow' ],
        [ '-blue', '-green', 'yellow' ],
        [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
        ['-z']
    ];

    my $model = $agent->solve( $variables, $clauses );
    is( $agent->_pure("yellow"), 0, "yellow is impure" );
    is( $agent->_pure("green"),  0, "green is impure" );
    is( $agent->_pure("pink"),   1, "pink is pure" );
    is( $agent->_pure("z"),      0, "z is impure" );


    my $exp = Algorithm::SAT::Expression->new->with(
        "Algorithm::SAT::Backtracking::Ordered::DPLL");
    $exp->or( 'blue',  'green',  '-yellow' );
    $exp->or( '-blue', '-green', 'yellow' );
    $exp->or( 'pink',  'purple', 'green', 'blue', '-yellow' );
    my $model = $exp->solve();
    is( $model->get('pink'), 1, "pink is true" );

    $exp = Algorithm::SAT::Backtracking::Ordered::DPLL->new;
    my $impurity = [
        [ 'blue',  'green',  '-yellow' ],
        [ '-blue', '-green', 'yellow' ],
        [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
    ];
    $model   = Hash::Ordered->new;
    $clauses = [
        [ 'blue',  'green',  '-yellow' ],
        [ '-blue', '-green', 'yellow' ],
        [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
        ['-z']
    ];
    $variables = [ 'blue', 'green', 'yellow', 'pink', 'purple' ];
    $exp->{_impurity}->{$_}++ for ( map { @{$_} } @{$impurity} );
    $exp->_pure_unit( $variables, $clauses, $model );

    is( $model->get('pink'), 1, "pink is setted to true by _pure_unit()" );

};

#todo: testfiles for _remove_literal , _up and _pure
subtest "_remove_literal()" => sub {
    my $agent = Algorithm::SAT::Backtracking::Ordered::DPLL->new;

    my $clauses = [
        [ 'blue',  'green',  '-yellow' ],
        [ '-blue', '-green', 'yellow' ],
        [ 'pink',  'purple', 'green', 'blue', '-yellow', 'blue' ], ['-z']
    ];

    $agent->_remove_literal( "blue", $clauses );

    is_deeply(
        $clauses,
        [   [ 'green', '-yellow' ],
            [ '-blue', '-green', 'yellow' ],
            [ 'pink', 'purple', 'green', '-yellow' ],
            ['-z']
        ],
        "removing blue from the model"
    );

};

subtest "_up()" => sub {
    my $agent     = Algorithm::SAT::Backtracking::Ordered::DPLL->new;
    my $variables = [ 'blue', 'green', 'yellow', 'pink', 'purple', 'z' ];
    my $clauses   = [
        [ 'blue',  'green',  '-yellow' ],
        [ '-blue', '-green', 'yellow' ],
        [ 'pink',  'purple', 'green', 'blue', '-yellow', 'z' ], ['-z']
    ];
    my $model = $agent->_up( $variables, $clauses, Hash::Ordered->new );
     is_deeply(
        $clauses,
        [   [ 'blue',  'green',  '-yellow' ],
            [ '-blue', '-green', 'yellow' ],
            [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
            ['-z']
        ],
        "z is removed from OR clauses"
    );
    is( $model->get("z"), 0, "z is false" );

};

subtest "_pure()" => sub {
    my $agent = Algorithm::SAT::Backtracking::Ordered::DPLL->new;

    my $variables = [ 'blue', 'green', 'yellow', 'pink', 'purple', 'z' ];
    my $clauses = [
        [ 'blue',  'green',  '-yellow' ],
        [ '-blue', '-green', 'yellow' ],
        [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
        ['-z']
    ];

    my $model = $agent->solve( $variables, $clauses );
    is( $agent->_pure("yellow"), 0, "yellow is impure" );
    is( $agent->_pure("green"),  0, "green is impure" );
    is( $agent->_pure("pink"),   1, "pink is pure" );
    is( $agent->_pure("z"),      0, "z is impure" );

};

subtest "_remove_clause_if_contains()" => sub {
    my $agent = Algorithm::SAT::Backtracking::Ordered::DPLL->new;

    my $variables = [ 'blue', 'green', 'yellow', 'pink', 'purple', 'z' ];
    my $clauses = [
        [ 'blue',  'green',  '-yellow' ],
        [ '-blue', '-green', 'yellow' ],
        [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
        ['-z']
    ];

    $agent->_remove_clause_if_contains( "yellow", $clauses );
    is_deeply(
        $clauses,
        [   [ 'blue', 'green', '-yellow' ],
            [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
            ['-z']
        ],
        "clauses containing yellow were removed"
    );

    $clauses = [
        [ 'blue',  'green',  '-yellow' ],
        [ '-blue', '-green', 'yellow' ],
        [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
        ['-z']
    ];
    $agent->_remove_clause_if_contains( "green", $clauses );
    is_deeply(
        $clauses,
        [ [ '-blue', '-green', 'yellow' ], ['-z'] ],
        "clauses containing green were removed"
    );

    $clauses = [
        [ 'blue',  'green',  '-yellow' ],
        [ '-blue', '-green', 'yellow' ],
        [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
        ['-z']
    ];
    $agent->_remove_clause_if_contains( "-green", $clauses );
    is_deeply(
        $clauses,
        [   [ 'blue', 'green', '-yellow' ],
            [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
            ['-z']
        ],
        "clauses containing -green were removed"
    );
    $clauses = [
        [ 'blue',  'green',  '-yellow' ],
        [ '-blue', '-green', 'yellow' ],
        [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
        ['-z']
    ];
    $agent->_remove_clause_if_contains( "-z", $clauses );
    is_deeply(
        $clauses,
        [   [ 'blue',  'green',  '-yellow' ],
            [ '-blue', '-green', 'yellow' ],
            [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
        ],
        "clauses containing -z were removed"
    );

};
done_testing;
