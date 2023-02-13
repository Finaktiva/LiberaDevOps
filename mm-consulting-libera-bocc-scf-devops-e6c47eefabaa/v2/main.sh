#!/bin/sh
set -ex

# Creates a context to execute functions
#
# Example call 
# $ sh main.sh function-name arg1 arg2 arg3

#Imports funtions
. ./resources/scripts/bash.sh
. ./resources/scripts/file-generation.sh
. ./resources/scripts/utils.sh

# Global vars
workdir=$(pwd)
cli_profile="lbocc-dev"
stage_name="bocc-dev"
stage_region="us-east-1"

# Repositories paths
backend_path="../../libera-bocc-scf-core-rest"
bpm_path="../../libera-bocc-scf-bpm"
bpm_services_path="../../libera-bocc-scf-bpm-services"
fronted_path="../../libera-bocc-scf-admin-portal"

"$@"
