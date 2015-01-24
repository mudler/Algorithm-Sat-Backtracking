package Algorithm::SAT::Backtracking::Ordered;
use base 'Algorithm::SAT::Backtracking';
use Hash::Ordered;
##Ordered implementation, of course has its costs

sub _choice {
    my $self      = shift;
    my $variables = shift;
    my $model     = shift;
    my $choice;
    foreach my $variable ( @{$variables} ) {
        $choice = $variable and last if ( !$model->exists($variable) );
    }
    return $choice;
}

sub solve {
    my $self      = shift;
    my $variables = shift;
    my $clauses   = shift;
    my $model     = defined $_[0] ? shift : Hash::Ordered->new;
    return $self->SUPER::solve( $variables, $clauses, $model );
}

# ### update
# Copies the model, then sets `choice` = `value` in the model, and returns it, keeping the order of keys.
sub update {
    my $self   = shift;
    my $copy   = shift->clone;
    my $choice = shift;
    my $value  = shift;
    $copy->set( $choice => $value );
    return $copy;
}

# ### resolve
# Resolve some variable to its actual value, or undefined.
sub resolve {
    my $self  = shift;
    my $var   = shift;
    my $model = shift;
    if ( substr( $var, 0, 1 ) eq "-" ) {
        my $value = $model->get( substr( $var, 1 ) );
        return !defined $value ? undef : $value == 0 ? 1 : 0;
    }
    else {
        return $model->get($var);
    }
}

1;
