#!/usr/bin/perl -w

# Test the bare sigil syntax: $, @ and %

use strict;
use warnings;

use Test::More;

use Method::Signatures;

{
    package Placeholder;

    use lib 't/lib';
    use GenErrorRegex qw< required_error required_placeholder_error placeholder_badval_error placeholder_failed_constraint_error >;

    use Test::More;
    use Test::Exception;
    use Method::Signatures;

    method only_placeholder($) {
        return $self;
    }

    is( Placeholder->only_placeholder(23),    'Placeholder' );

#line 28
    throws_ok { Placeholder->only_placeholder() } required_placeholder_error('Placeholder', 0, 'only_placeholder', LINE => 28),
            'simple required placeholder error okay';

    method add_first_and_last($first!, $, $last = 22) {
        return $first + $last
    }

    is( Placeholder->add_first_and_last(18, 19, 20), 18 + 20 );
    is( Placeholder->add_first_and_last(18, 19),     18 + 22 );

#line 39
    throws_ok { Placeholder->add_first_and_last() } required_error('Placeholder', '$first', 'add_first_and_last', LINE => 39),
            'missing required/named param error okay';

#line 43
    throws_ok { Placeholder->add_first_and_last(18) } required_placeholder_error('Placeholder', 1, 'add_first_and_last', LINE => 43),
            'missing required placeholder after required param error okay';

    method constrained_placeholder(Int $ where { $_ < 10 }) {
        return $self;
    }

    is( Placeholder->constrained_placeholder(2), 'Placeholder' );

# line 53
    throws_ok { Placeholder->constrained_placeholder() } required_placeholder_error('Placeholder', 0, 'constrained_placeholder', LINE => 53),
            'missing requierd constrained placeholder';
    throws_ok { Placeholder->constrained_placeholder('foo') } placeholder_badval_error('Placeholder', 0, 'Int' => 'foo', 'constrained_placeholder', LINE => 55),
            'placeholder value wrong type';
    throws_ok { Placeholder->constrained_placeholder(99) } placeholder_failed_constraint_error('Placeholder', 0, 99 => '{$_<10}', 'constrained_placeholder', LINE => 57),
            'placeholder value wrong type';
}

done_testing();
