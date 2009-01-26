#!/usr/bin/perl -w
use strict;
use Carp;
use Cwd;
use File::Basename;
use File::Spec;
use Getopt::Std qw( getopts );

( my $Script = $0 ) =~ s{^.*/}{};

# ------------------------------------------------------------------------
# usage / help / command line options
# ------------------------------------------------------------------------
sub usage {
    warn "@_\n" if @_;
    $! = 0;    # clean exit status
    die <<USAGE;
Usage: $Script [options] [dir1 ... dirN]
options:
  -h       help
  -v       verbose

For each directory, search the '.sl' (SLang) files for 'define' statements
with one or more of the '<AUTOLOAD>', '<COMPLETE>' (or '<COMPLETION>') tags
and write these function names to the '_loader.sl' file in each directory.
The <EXTS="..."> tag is also supported, but it must occur after a mode
definition.

eg,
   public define foo()  % <AUTOLOAD> <COMPLETE>
   define bar()         % <AUTOLOAD>
   private define foo() % <AUTOLOAD> ignored! (cannot export a private)
   static  define foo() % <COMPLETE> ignored! (cannot export a static)
   define foo_mode()    % <EXTS="bar,baz">

A 'define' statement with an '<OVERLOAD>' tag indictes the file should
always be 'evalfile'd.

The short forms '<AUTO>' and '<OVER>' may be used for '<AUTOLOAD>'
and '<OVERLOAD>', respectively.

When no directories are specified on the command-line, uses the
directories given in the 'JED_LIBRARY' environment variable.

USAGE
}
# ------------------------------------------------------------------------

my %opt;
getopts('hv', \%opt) or usage();
$opt{h} and usage();

my $Verbose = delete $opt{v};   # not used very much

my $delim = ':';                # Unix
$delim = ';' if $^O =~ /^(os2|MSWin32|cygwin)$/;    # systems with drives

# ------------------------------------------------------------------------
my @jedlib = grep { defined } @ARGV ? @ARGV : $ENV{JED_LIBRARY};

# respect SLang-style (comma-delimited) or normal styles
@jedlib = grep { defined } map { /,/ ? split /,/ : split /$delim/ } @jedlib;

my $error = sub {
    my $msg = shift || 'unknown error';
    print STDERR "$_ ... $msg\n";
};

my %hash;       # avoid duplicates

# discover all problems first and convert to absolute paths
for (@jedlib) {
    stat or $error->('cannot stat'),     next;
    -e _ or $error->('does not exist'),  next;
    -d _ or $error->('not a directory'), next;
    -r _ or $error->('not readable'),    next;
    -w _ or $error->('not writable'),    next;
    $_ = Cwd::abs_path($_);
    $hash{$_}++;
}

@jedlib = sort keys %hash;
@jedlib or die "sorry no valid directories\n";    # stop

# slurp in the template
my $template = do { local $/; <DATA>; };

# ISO date format
my $Date = do {
    my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime(time);
    $year += 1900;
    $mon++;

    my $date = sprintf "%04d-%02d-%02d", $year, $mon, $mday;
    my $time = sprintf "%02d:%02d:%02d", $hour, $min, $sec;

    "$date $time";
};

$template =~ s/<<DATE>>/$Date/g;
$template =~ s/<<SCRIPT>>/$Script/g;

my $ext = '.sl';
for my $dir (@jedlib) {
    local *FILE;
    print STDERR "$dir\n";

    my $glob = File::Spec->catfile( $dir, "*$ext" );
    my $out  = File::Spec->catfile( $dir, "_loader.sl" );
    my @files = sort grep { -f } glob $glob;

    @files or next;

    my ( $autoload, $complete, %over, %exts );
    for ( @files ) {
        my $file = basename( $_, $ext );
        $file !~ /^_/ or next;
        open FILE, $_ or next;    # fail silently
        print STDERR "<FILE NAME=\"$file\">\n" if $Verbose;

        my ( @auto, @comp );
        while (<FILE>) {
            /^\s* (public)? \s* define \s+ (\w+)/x or next;
            my ( $type, $name ) = ( $1, $2 );

            if (/\<AUTO(?:LOAD)?\>/i) {
                push @auto, $name;
                print STDERR "\t<AUTOLOAD>$name</AUTOLOAD>\n" if $Verbose;
            }

            if (/\<COMPLET(E|ION)\>/i) {
                push @comp, $name;
                print STDERR "\t<COMPLETE>$name</COMPLETE>\n" if $Verbose;
            }

            if (/\<OVER(?:LOAD)?\>/i) {
                $over{$file}++;
                print STDERR "\t<OVERLOAD>$file</OVERLOAD>\n" if $Verbose;
            }

            if (    ( my ($val) = /\<EXTS?=[\"\']?([^\"\'\>]+?)[\"\']?\>/i )
                and ( my ($mode) = $name =~ /^(.+?)_mode$/ ) )
            {
                my @list = grep { defined and length } split /[\s.,:;]+/, $val;
                if (@list) {
                    $exts{$mode} = [@list];
                    print STDERR "\t<EXTS>@list</EXTS>\n" if $Verbose;
                }
            }
        }
        print STDERR "</FILE>\n" if $Verbose;
        close FILE;

        $autoload .= join (
            '' => "% <$file>\n",
            map { qq{\t"$_";\t"$file";\n} } sort @auto
        ) if @auto;

        $complete .= join (
            '' => "% <$file>\n",
            map { qq{\t"$_";\n} } sort @comp
        ) if @comp;
    }

    $autoload or $complete or %over or next;    # nothing found

    my $overload =
      join ( '' => map { qq{\t() = evalfile("$_");\n} } sort keys %over );

    my $extensions = join (
        '' => map {
            my $mode = $_;
            (
                "% extensions for <$mode> mode\n",
                (
                    map { qq{\tadd_mode_for_extension("$mode", "$_");\n} }
                    @{ $exts{$mode} }
                )
            )
        }
        sort keys %exts
    );

    # kill trailing newlines
    chomp ($autoload, $complete, $overload, $extensions);

    $autoload   ||= "%\tno function/filename pairs";
    $complete   ||= "%\tno function names";
    $overload   ||= "%\tno files for evalfile()";
    $extensions ||= "%\tno extensions/mode associations",

    my $code = $template;
    $code =~ s/<<DIR>>/$dir/g;
    $code =~ s/<<AUTOLOAD>>/$autoload/g;
    $code =~ s/<<COMPLETE>>/$complete/g;
    $code =~ s/<<OVERLOAD>>/$overload/g;
    $code =~ s/<<EXTS>>/$extensions/g;

    open FILE, "> $out" or warn "couldn't write to $out\n" and next;
    print FILE "$code\n";
}

exit 0;

__DATA__
% AUTOMATICALLY GENERATED [<<DATE>>] - DO NOT EDIT !!
% CHANGES MADE HERE WILL BE LOST THE NEXT TIME '<<SCRIPT>>' IS RUN !!
%
% _loader.sl: <<<DIR>>>
% ---------------------------------------------------------------------------
% this file is called by 'loader.sl' and defines autoloads/completions
% for SLang files in this directory
%
% NOTES:
%   '<<SCRIPT>>' searches for 'define' statements that have
%   any '<AUTOLOAD>', '<COMPLETE>', or '<COMPLETION>' tags
%   and adds these function names to this file.
%   The <EXTS="..."> tag (after a mode definition) is also supported.
%
%   eg,
%     public define foo()  % <AUTOLOAD> <COMPLETE>
%     define bar()         % <AUTOLOAD>
%     private define foo() % <AUTOLOAD> <= IGNORED (cannot export a private)
%     static  define foo() % <COMPLETE> <= IGNORED (cannot export a static)
%     define foo_mode()    % <EXTS="bar,baz">
%
%   any 'define' statement with an '<OVERLOAD>' tag indictes that an
%   'evalfile()' should always be used for the file.
%   This is useful for overloading standard library functions.
%
% ---------------------------------------------------------------------------
% list of function/filename pairs for autoload
%
$0 = _stkdepth();       % save stack depth
<<AUTOLOAD>>
(_stkdepth() - $0)/2;   % leave count on stack
_autoload;
% ---------------------------------------------------------------------------
% list of function names for completion
%
$0 = _stkdepth();       % save stack depth
<<COMPLETE>>
(_stkdepth() - $0);     % leave count on stack
_add_completion;
% ---------------------------------------------------------------------------
<<OVERLOAD>>
<<EXTS>>
% ----------------------------------------------------------------------- END
