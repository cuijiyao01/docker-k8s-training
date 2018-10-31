# Remarks on the solution helm chart

Each installation of this chart results in a different service name, which is part of the USER_ROUTE for ads. Therefore one has to change the value in the configmaps of ads and respawn the ads pod so the new value takes effect. 
Also the network policy of ads has to get adapted.
