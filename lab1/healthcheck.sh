IP=$1
RESPONSE=$(curl --write-out '%{http_code}' --silent -H "Accept: application/json" \
 --output /dev/null http://$IP/petclinic/api/owners?lastName=Franklin)

if [ $RESPONSE -eq 200 ]; then
    echo "GET healthcheck succesful"
else
    echo "GET healthcheck failed"
fi

RESPONSE=$(curl --write-out '%{http_code}' --silent \
  --request POST -H "Content-Type: application/json" \
  --data '{"id":null,"firstName":"Testnameid","lastName":"Testnameid","specialties":[{"id":3,"name":"dentistry"}]}' \
  --output /dev/null http://$IP/petclinic/api/vets)

if [ $RESPONSE -eq 201 ]; then
    echo "POST healthcheck succesful"
else
    echo "POST healthcheck failed"
fi