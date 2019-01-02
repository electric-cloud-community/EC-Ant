unshift(@::gMatchers,
  {
   id =>        "BuildFailed",
   pattern =>          q{Build failed|BUILD FAILED},
   action =>           q{&addSimpleError("BuildFailed", "Build failed");setProperty("outcome", "error" );updateSummary();},
  },
  {
    id =>       "BuildFileMissing",
    pattern =>         q{Buildfile: (.*) does not exist},
    action =>           q{&addSimpleError("BuildFileMissing", "Buildfile: $1 does not exist");setProperty("outcome", "error" );updateSummary();},
  },
  {
    id =>          "GetErrors",
    pattern =>     q{(.*)Tests run:\s(\d+),\sFailures:\s(\d+),\sErrors:\s(\d+),\s(.*)},
    action =>           q{&incTestResults("Tests run: $2","Failures: $3","Errors: $4");updateSummary();},
  },
);

sub incTestResults{
    my($run,$failed,$errors) = @_;
    my $numbers = ((defined $::gProperties{"results"}) ? $::gProperties{"results"} : "Tests run: 0 Failures: 0 Errors: 0");
    $run =~ s/Tests run: //;
    $failed =~ s/Failures: //;
    $errors =~ s/Errors: //;
    $numbers =~ m/Tests\srun:\s(\d+)\sFailures:\s(\d+)\sErrors:\s(\d+)/i;    
    $run += $1;
    $failed += $2;
    $errors += $3;
    $numbers = "Tests run: $run Failures: $failed Errors: $errors";    
    $::gProperties{"results"} = $numbers;
}

sub addSimpleError {
    my ($name, $customError) = @_;
    if(!defined $::gProperties{$name}){
        setProperty ($name, $customError);
    }
}

sub updateSummary() {    
    my $summary = (defined $::gProperties{"BuildFailed"}) ? $::gProperties{"BuildFailed"} . "\n" : "";
    $summary .= (defined $::gProperties{"BuildFileMissing"}) ? $::gProperties{"BuildFileMissing"} . "\n" : "";
    $summary .= (defined $::gProperties{"results"}) ? $::gProperties{"results"} . "\n" : "";

    setProperty ("summary", $summary);
}