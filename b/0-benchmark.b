#!/usr/bin/perl
use lib '../';
use Benchmark qw(:all);
use Data::Dumper;
use Algorithm::SAT::Expression;
my $result = cmpthese(
    400,
    {   'SAT::Backtracking' => sub {
            my $expr = Algorithm::SAT::Expression->new;
            $expr->or( '-foo@2.1', 'bar@2.2' );
            $expr->or( '-foo@2.3', 'bar@2.2' );
            $expr->or( '-baz@2.3', 'bar@2.3' );
            $expr->or( '-baz@1.2', 'bar@2.2' );
            $expr->solve;
        },
        'SAT::BacktrackingDPLL' => sub {
            my $expr = Algorithm::SAT::Expression->new->with(
                "Algorithm::SAT::BacktrackingDPLL");
            $expr->or( '-foo@2.1', 'bar@2.2' );
            $expr->or( '-foo@2.3', 'bar@2.2' );
            $expr->or( '-baz@2.3', 'bar@2.3' );
            $expr->or( '-baz@1.2', 'bar@2.2' );
            $expr->solve;
        },
        'SAT::BacktrackingDPLLProb' => sub {
            my $expr = Algorithm::SAT::Expression->new->with(
                "Algorithm::SAT::BacktrackingDPLLProb");
            $expr->or( '-foo@2.1', 'bar@2.2' );
            $expr->or( '-foo@2.3', 'bar@2.2' );
            $expr->or( '-baz@2.3', 'bar@2.3' );
            $expr->or( '-baz@1.2', 'bar@2.2' );
            $expr->solve;
            }
    }
);

