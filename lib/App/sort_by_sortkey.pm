package App::sort_by_sortkey;

use 5.010001;
use strict;
use warnings;
use Log::ger;

use AppBase::Sort;
use AppBase::Sort::File ();
use Perinci::Sub::Util qw(gen_modified_sub);

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

gen_modified_sub(
    output_name => 'sort_by_sortkey',
    base_name   => 'AppBase::Sort::sort_appbase',
    summary     => 'Sort lines of text by a SortKey module',
    description => <<'MARKDOWN',

This utility lets you sort lines of text using one of the available SortKey::*
perl modules.

MARKDOWN
    add_args    => {
        %AppBase::Sort::File::argspecs_files,
        sortkey_module => {
            schema => "perl::sortkey::modname_with_optional_args",
            pos => 0,
            req => 1,
        },
    },
    modify_args => {
        files => sub {
            my $argspec = shift;
            #delete $argspec->{pos};
            #delete $argspec->{slurpy};
        },
    },
    modify_meta => sub {
        my $meta = shift;

        $meta->{examples} = [
            {
                src_plang => 'bash',
                src => q[ someprog ... | sort-by-sortkey Num::length],
                test => 0,
                'x.doc.show_result' => 0,
            },
        ];
        $meta->{links} //= [];
        push @{ $meta->{links} }, {url=>'pm:SortKey'};
        push @{ $meta->{links} }, {url=>'prog:sort-by-sorter'};
        push @{ $meta->{links} }, {url=>'prog:sort-by-comparer'};
    },
    output_code => sub {
        require Module::Load::Util;

        my %oc_args = @_;

        AppBase::Sort::File::set_source_arg(\%oc_args);
        $oc_args{_gen_keygen} = sub {
            my $gc_args = shift;
            (
                Module::Load::Util::call_module_function_with_optional_args(
                    {ns_prefix=>"SortKey", function=>"gen_keygen"},
                    $gc_args->{sortkey_module}),                 # elem0: keygen
                ($gc_args->{sortkey_module} =~ /\ANum::/ ? 1:0), # elem1: is_numeric?
            );
        };
        AppBase::Sort::sort_appbase(%oc_args);
    },
);

1;
# ABSTRACT:
