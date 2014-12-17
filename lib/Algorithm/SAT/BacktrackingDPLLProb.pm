package Algorithm::SAT::BacktrackingDPLLProb;
use base 'Algorithm::SAT::BacktrackingDPLL';
use List::Util qw(shuffle);

sub _choice {
    my $self=shift;
    my $variables = shift;
    my $model     = shift;
    my $choice
        = ( shuffle( grep { !exists $model->{$_} } @{$variables} ) )[0]
        ;    #probabilistic approach
             # If there are no more variables to try, return false.
    return $choice;
}

1;
