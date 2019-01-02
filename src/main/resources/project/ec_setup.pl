# Data that drives the create step picker registration for this plugin.
use strict;
no warnings qw/redefine/;

use ElectricCommander;

my $ua = $upgradeAction;

ElectricUpgrader::on_upgrade($ua);

my %runAnt = (
    label       => "Ant - Run Ant",
    procedure   => "runAnt",
    description => "Run ant against a specific buildfile.",
    category    => "Build"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/Ant - Run Ant");

@::createStepPickerSteps = (\%runAnt);


# service subroutines

package ElectricUpgrader;

sub on_upgrade {
    my ($action) = @_;

    return 1 if $action ne 'upgrade';

    my $commander = ElectricCommander->new();
    my $steps = $commander->findObjects("procedureStep", {
        filter => [
            {
                propertyName => "subproject",
                operator     => "equals",
                operand1     => "/plugins/EC-Ant/project"
            },
            {
                propertyName => "subprocedure",
                operator     => "equals",
                operand1     => "runAnt"
            }
        ]
    });

    for my $step ($steps->findnodes("//step")) {
        my $projectName = $step->findvalue("projectName");
        my $procedureName = $step->findvalue("procedureName");
        my $stepName = $step->findvalue("stepName");

        my $parameters = $commander->getActualParameters({
            projectName     => $projectName,
            procedureName   => $procedureName,
            stepName        => $stepName});

        my $propertiesExists = 0;
        my $propsExists = 0;
        my $value;
        for my $parameter ($parameters->findnodes("//actualParameter")) {
            my $name = $parameter->findvalue("actualParameterName");
            if ($name eq "properties") {
                $propertiesExists = 1;
                $value = $parameter->findvalue("value");
            }
            if ($name eq "props") {
                $propsExists = 1;
            }
        }
        if ($propertiesExists && !$propsExists) {
            print "Renaming parameter 'properties' to 'props' for "
                . "step '$projectName:$procedureName:$stepName'\n";
            $commander->createActualParameter($projectName, $procedureName,
                $stepName, "props", { value => $value });
            $commander->deleteActualParameter($projectName, $procedureName,
                $stepName, "properties");
        }
    }

}

1;
