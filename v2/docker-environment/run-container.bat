docker run -itd                 ^
  --name lbocc-deployer         ^
  -v %LIBERA_BOCC_HOME%:/lbocc  ^
  -v %LIBERA_BOCC_HOME%/libera-bocc-scf-devops/credentials/.aws:/root/.aws  ^
  -v //var/run/docker.sock:/var/run/docker.sock  ^
  lbocc-deployer