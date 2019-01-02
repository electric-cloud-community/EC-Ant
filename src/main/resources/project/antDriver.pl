# -------------------------------------------------------------------------
# File
#    antDriver.pl
#
# Dependencies
#    None
#
# Template Version
#    1.0
#
# Date
#    11/05/2010
#
# Engineer
#    Alonso Blanco
#
# Copyright (c) 2011 Electric Cloud, Inc.
# All rights reserved
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use ElectricCommander;
use warnings;
use strict;
$| = 1;

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
use constant {
    SUCCESS => 0,
    ERROR   => 1,

    PLUGIN_NAME => 'EC-Ant',
    EXECUTABLE  => 'ant',

    GENERATE_REPORT        => 1,
    DO_NOT_GENERATE_REPORT => 0,
    REPORT_NAME            => 'MyPlugin Result',
    SEPARATOR_CHAR         => ';',

};

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
my $ec = new ElectricCommander();
$ec->abortOnError(0);

($ec->getProperty( "" ))->findvalue('//value')->string_value;
$::gBuildFile         = ($ec->getProperty("/myCall/buildfile"))->findvalue('//value')->string_value;
$::gAntLocation       = ($ec->getProperty("/myCall/antlocation"))->findvalue('//value')->string_value;
$::gLibraries         = ($ec->getProperty("/myCall/libraries"))->findvalue('//value')->string_value;
$::gProperties        = ($ec->getProperty("/myCall/props"))->findvalue('//value')->string_value;
$::gPropertyFile      = ($ec->getProperty("/myCall/propertyfile"))->findvalue('//value')->string_value;
$::gOutputLevel       = ($ec->getProperty("/myCall/outputlevel"))->findvalue('//value')->string_value;
$::gLogFile           = ($ec->getProperty("/myCall/logfile"))->findvalue('//value')->string_value;
$::gTarget            = ($ec->getProperty("/myCall/target"))->findvalue('//value')->string_value;
$::gDiagnostics       = ($ec->getProperty("/myCall/diagnostics"))->findvalue('//value')->string_value;
$::gDebug             = ($ec->getProperty("/myCall/debug"))->findvalue('//value')->string_value;
$::gPostpLine         = ($ec->getProperty("/myCall/postpline"))->findvalue('//value')->string_value;
$::gAdditionalOptions = ($ec->getProperty("/myCall/additionalcommands"))->findvalue('//value')->string_value;

# -------------------------------------------------------------------------
# Main functions
# -------------------------------------------------------------------------

########################################################################
# main - contains the whole process to be done by the plugin, it builds
#        the command line, sets the properties and the working directory
#
# Arguments:
#   none
#
# Returns:
#   none
#
########################################################################
sub main() {

    # create args array
    my @args = ();
    my %props;

    #evaluate if an ant custom location is given
    if ( $::gAntLocation && $::gAntLocation ne '' ) {
        push( @args, $::gAntLocation );
    }
    else {
        push( @args, EXECUTABLE );
    }

    if ( $::gOutputLevel && $::gOutputLevel ne '' ) {
        push( @args, '-' . $::gOutputLevel );
    }

    # if diagnostics set, issue ant diagnostic and we're done
    if ( $::gDiagnostics && $::gDiagnostics ne '' ) {

        push( @args, '-diagnostics' );
        $ec->setProperty("/myCall/commandLine", join(" ", @args)); 
        exit SUCCESS;
    }

    # if propertyfile: add to command string
    if ( $::gPropertyFile && $::gPropertyFile ne '' ) {
        push( @args, "-propertyfile $::gPropertyFile" );
    }

    # if properties: parse properties, add to command string
    if ( $::gProperties && $::gProperties ne '' ) {

        foreach my $p ( split( SEPARATOR_CHAR, $::gProperties ) ) {
            push( @args, "-D$p" );
        }

    }

    # if libraries: parse libraries, add to command string
    if ( $::gLibraries && $::gLibraries ne '' ) {
        foreach my $line ( split( /\n/, $::gLibraries ) ) {
            foreach my $lib ( split( SEPARATOR_CHAR, $line ) ) {
                push( @args, "-lib $lib" );
            }
        }
    }

    # if buildfile: add to command string
    if ( $::gBuildFile && $::gBuildFile ne '' ) {
        push( @args, "-buildfile $::gBuildFile" );
    }

    if ( $::gDebug && $::gDebug ne '' ) {
        push( @args, '-debug' );
    }

    if ( $::gLogFile && $::gLogFile ne '' ) {
        push( @args, '-logfile ' . $::gLogFile );
    }

    if ( $::gAdditionalOptions && $::gAdditionalOptions ne '' ) {
        push( @args, $::gAdditionalOptions );
    }

    # if target: add to command string
    if ( $::gTarget && $::gTarget ne '' ) {
        push( @args, $::gTarget );
    }
	
	# if target: add to command string
    if ( !( $::gPostpLine && $::gPostpLine ne '') ) {
        
		$::gPostpLine= 'postp --loadProperty /myProject/postp_matchers';
	}
    
    $ec->setProperty("/myCall/commandLine", join(" ", @args));
	$ec->setProperty("/myCall/postpLine", $::gPostpLine);
	 	

}

main();

1;

