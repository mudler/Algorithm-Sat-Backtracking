use strict;
use Test::More 0.98;
use Algorithm::SAT::Expression;

my @alg = qw(
  Algorithm::SAT::Backtracking::DPLL
  Algorithm::SAT::Backtracking::DPLLProb
  Algorithm::SAT::Backtracking::DPLLFreq
  Algorithm::SAT::Backtracking::DPLLUnFreq
);

eval "use $_" for @alg;

subtest "_pure()/_pure_unit()" => sub {
    for my $impl (
        @alg,
	#"Algorithm::SAT::Backtracking::Ordered",
	#"Algorithm::SAT::Backtracking::Ordered::DPLL"
      )
    {
        my $agent = $impl->new;

        my $variables = [ 'blue', 'green', 'yellow', 'pink', 'purple', 'z' ];
        my $clauses = [
            [ 'blue',  'green',  '-yellow' ],
            [ '-blue', '-green', 'yellow' ],
            [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
            ['-z']
        ];

        my $model = $agent->solve( $variables, $clauses );
        is( $agent->_pure("yellow"), 0, "yellow is impure ($impl)" );
        is( $agent->_pure("green"),  0, "green is impure" );
        is( $agent->_pure("pink"),   1, "pink is pure" );
        is( $agent->_pure("z"),      0, "z is impure" );
        my $exp = Algorithm::SAT::Expression->new->with($impl);
        $exp->or( 'blue',  'green',  '-yellow' );
        $exp->or( '-blue', '-green', 'yellow' );
        $exp->or( 'pink',  'purple', 'green', 'blue', '-yellow' );
        my $model = $exp->solve();
        is( $model->{'pink'}, 1, "pink is true" );

        $exp = $impl->new;
        my $impurity = [
            [ 'blue',  'green',  '-yellow' ],
            [ '-blue', '-green', 'yellow' ],
            [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
        ];
        $model   = {};
        $clauses = [
            [ 'blue',  'green',  '-yellow' ],
            [ '-blue', '-green', 'yellow' ],
            [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
            ['-z']
        ];
        $variables = [ 'blue', 'green', 'yellow', 'pink', 'purple' ];
        $exp->{_impurity}->{$_}++ for ( map { @{$_} } @{$impurity} );
        $exp->_pure_unit( $variables, $clauses, $model );

        is( $model->{'pink'}, 1, "pink is setted to true by _pure_unit()" );
    }

};

#todo: testfiles for _remove_literal , _up and _pure
subtest "_remove_literal()" => sub {
    for my $impl (@alg) {
        my $agent = $impl->new;

        my $clauses = [
            [ 'blue',  'green',  '-yellow' ],
            [ '-blue', '-green', 'yellow' ],
            [ 'pink',  'purple', 'green', 'blue', '-yellow', 'blue' ], ['-z']
        ];

        $agent->_remove_literal( "blue", $clauses );

        is_deeply(
            $clauses,
            [
                [ 'green', '-yellow' ],
                [ '-blue', '-green', 'yellow' ],
                [ 'pink', 'purple', 'green', '-yellow' ],
                ['-z']
            ],
            "removing blue from the model ($impl)"
        );
    }
};

subtest "_up()" => sub {
    for my $impl (@alg) {
        my $agent     = $impl->new;
        my $variables = [ 'blue', 'green', 'yellow', 'pink', 'purple', 'z' ];
        my $clauses   = [
            [ 'blue',  'green',  '-yellow' ],
            [ '-blue', '-green', 'yellow' ],
            [ 'pink',  'purple', 'green', 'blue', '-yellow', 'z' ], ['-z']
        ];

        my $model = $agent->_up( $variables, $clauses );
        is( $model->{z}, 0, "z is false" );
        is_deeply( $model, { z => 0 }, "model is correct" );
        is_deeply(
            $clauses,
            [
                [ 'blue',  'green',  '-yellow' ],
                [ '-blue', '-green', 'yellow' ],
                [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
                ['-z']
            ],
            "z is removed from OR clauses"
        );
    }
};

subtest "_pure()" => sub {
    for my $impl (@alg) {
        my $agent = $impl->new;

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
    }
};

subtest "_remove_clause_if_contains()" => sub {
    for my $impl (@alg) {
        my $agent = $impl->new;

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
            [
                [ 'blue', 'green', '-yellow' ],
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
            [
                [ 'blue', 'green', '-yellow' ],
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
            [
                [ 'blue',  'green',  '-yellow' ],
                [ '-blue', '-green', 'yellow' ],
                [ 'pink', 'purple', 'green', 'blue', '-yellow' ],
            ],
            "clauses containing -z were removed"
        );
    }
};
done_testing;
