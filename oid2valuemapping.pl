#!/usr/bin/perl -w
use strict;
use POSIX;
use SNMP;
use XML::Simple;
use Getopt::Long;

my $mappings_name;

#### Getopt
## Getopt flags and options variables
my %options;
GetOptions( \%options, "oid=s", "name=s", "mibs-dir=s", "dir=s", "help" );

if ( defined($options{'help'}) || !defined($options{'oid'})) {
    die("Usage $0 --oid OID::to_map [--name values_mappings_name] [--mibs-dir /path/to/mibs] [--dir] [--help] \n");
}

if( defined($options{'dir'}) && ! -d $options{'dir'} ) {
    die("$options{'dir'} not a dir or $options{'dir'} is not accessible" );
}

if (defined($options{'mibs-dir'})) {
    SNMP::addMibDirs($options{'mibs-dir'});
}

$SNMP::save_descriptions=1;
SNMP::initMib();
SNMP::loadModules('ALL');


my $obj = $SNMP::MIB{$options{'oid'}};
unless( defined($obj) ) {
    die("Seems like OID is wrong.");
}

unless( defined( $obj->{enum}) && scalar(%{$obj->{enum}})) {
    die("Seems like $options{'oid'} does not have enumeration.")
}

if ( defined( $options{'name'})) {
    $mappings_name = $options{'name'};
} elsif( defined($obj->{textualConvention})  ) {
    $mappings_name = $obj->{textualConvention};
} else {
    $mappings_name = $obj->{label};
}


my $now = strftime('%Y-%m-%dT%H:%M:%SZ', gmtime(time()));

my $mapping = {
    'zabbix_export' =>  {
        'version'   => '3.0',
        'date'      => "$now",
        'value_maps' => [
                         {
                            'value_map' => [
                                            {
                                            'name' => "$mappings_name",
                                            'mappings' => [
                                                            {
                                                            'mapping' => [
                                                            ]
                                                            }
                                                           ]
                                            }
                                           ]
                         }
                        ]
    }
};

foreach my $i (keys(%{$obj->{enum}})) {
    push( @{$mapping->{'zabbix_export'}->{'value_maps'}[0]->{'value_map'}[0]->{'mappings'}[0]->{'mapping'}},
         { 'value' => "$obj->{enum}->{$i}", 'newvalue' => "$i" });
}

if ( defined($options{'dir'})) {
    print("Writing file $options{'dir'}/${mappings_name}.xml\n");
    XMLout( $mapping,  NoAttr =>1, AttrIndent => 1, KeepRoot => 1, XMLDecl => 1,
           OutputFile => "$options{'dir'}/${mappings_name}.xml" );
} else {
    my $xml = XMLout( $mapping,  NoAttr =>1, AttrIndent => 1, KeepRoot => 1, XMLDecl => 1 );
    print $xml;
}


