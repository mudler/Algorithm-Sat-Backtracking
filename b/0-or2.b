#!/usr/bin/perl
use lib '../';
use Benchmark qw(:all);
use Data::Dumper;
use Algorithm::SAT::Expression;

my $result = cmpthese(
    1000,
    {   'SAT::Backtracking' => sub {
            my $expr = Algorithm::SAT::Expression->new;
            $expr->or( '-x1', 'x3',  'x4' );
            $expr->or( '-x2', 'x6',  'x4' );
            $expr->or( '-x2', '-x6', '-x3' );
            $expr->or( '-x4', '-x2' );
            $expr->or( 'x2',  '-x3', '-x1' );
            $expr->or( 'x2',  'x6',  'x3' );
            $expr->or( 'x2',  '-x6', '-x4' );
            $expr->or( 'x1',  'x5' );
            $expr->or( 'x1',  'x6' );
            $expr->or( '-x6', 'x3',  '-x5' );
            $expr->or( 'x1',  '-x3', '-x' );

            $expr->solve;
        },
        'SAT::Backtracking::DPLL' => sub {
            my $expr = Algorithm::SAT::Expression->new->with(
                "Algorithm::SAT::Backtracking::DPLL");

            $expr->or( '-x1', 'x3',  'x4' );
            $expr->or( '-x2', 'x6',  'x4' );
            $expr->or( '-x2', '-x6', '-x3' );
            $expr->or( '-x4', '-x2' );
            $expr->or( 'x2',  '-x3', '-x1' );
            $expr->or( 'x2',  'x6',  'x3' );
            $expr->or( 'x2',  '-x6', '-x4' );
            $expr->or( 'x1',  'x5' );
            $expr->or( 'x1',  'x6' );
            $expr->or( '-x6', 'x3',  '-x5' );
            $expr->or( 'x1',  '-x3', '-x5' );

            $expr->solve;
        },
        'SAT::Backtracking::DPLLProb' => sub {
            my $expr = Algorithm::SAT::Expression->new->with(
                "Algorithm::SAT::Backtracking::DPLLProb");
            $expr->or( '-x1', 'x3',  'x4' );
            $expr->or( '-x2', 'x6',  'x4' );
            $expr->or( '-x2', '-x6', '-x3' );
            $expr->or( '-x4', '-x2' );
            $expr->or( 'x2',  '-x3', '-x1' );
            $expr->or( 'x2',  'x6',  'x3' );
            $expr->or( 'x2',  '-x6', '-x4' );
            $expr->or( 'x1',  'x5' );
            $expr->or( 'x1',  'x6' );
            $expr->or( '-x6', 'x3',  '-x5' );
            $expr->or( 'x1',  '-x3', '-x5' );

            $expr->solve;
        },
        'Algorithm::SAT::Backtracking::Ordered' => sub {
            my $expr = Algorithm::SAT::Expression->new->with(
                "Algorithm::SAT::Backtracking::Ordered");
            $expr->or( '-x1', 'x3',  'x4' );
            $expr->or( '-x2', 'x6',  'x4' );
            $expr->or( '-x2', '-x6', '-x3' );
            $expr->or( '-x4', '-x2' );
            $expr->or( 'x2',  '-x3', '-x1' );
            $expr->or( 'x2',  'x6',  'x3' );
            $expr->or( 'x2',  '-x6', '-x4' );
            $expr->or( 'x1',  'x5' );
            $expr->or( 'x1',  'x6' );
            $expr->or( '-x6', 'x3',  '-x5' );
            $expr->or( 'x1',  '-x3', '-x5' );

            $expr->solve;
        },
        'Algorithm::SAT::Backtracking::DPLLFreq' => sub {
            my $expr = Algorithm::SAT::Expression->new->with(
                "Algorithm::SAT::Backtracking::DPLLFreq");
            $expr->or( '-x1', 'x3',  'x4' );
            $expr->or( '-x2', 'x6',  'x4' );
            $expr->or( '-x2', '-x6', '-x3' );
            $expr->or( '-x4', '-x2' );
            $expr->or( 'x2',  '-x3', '-x1' );
            $expr->or( 'x2',  'x6',  'x3' );
            $expr->or( 'x2',  '-x6', '-x4' );
            $expr->or( 'x1',  'x5' );
            $expr->or( 'x1',  'x6' );
            $expr->or( '-x6', 'x3',  '-x5' );
            $expr->or( 'x1',  '-x3', '-x5' );

            $expr->solve;
        },
        'Algorithm::SAT::Backtracking::DPLLUnFreq' => sub {
            my $expr = Algorithm::SAT::Expression->new->with(
                "Algorithm::SAT::Backtracking::DPLLUnFreq");
                    $expr->or( '-x1', 'x3',  'x4' );
            $expr->or( '-x2', 'x6',  'x4' );
            $expr->or( '-x2', '-x6', '-x3' );
            $expr->or( '-x4', '-x2' );
            $expr->or( 'x2',  '-x3', '-x1' );
            $expr->or( 'x2',  'x6',  'x3' );
            $expr->or( 'x2',  '-x6', '-x4' );
            $expr->or( 'x1',  'x5' );
            $expr->or( 'x1',  'x6' );
            $expr->or( '-x6', 'x3',  '-x5' );
            $expr->or( 'x1',  '-x3', '-x5' );

            $expr->solve;
        }

    }
);

