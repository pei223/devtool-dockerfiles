
```
# build
docker build -t devtool-dockerfiles/keycloak:latest .

# run
docker run -d -p 8443:8443 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin --name=devtool-dockerfiles-keycloak --restart=always devtool-dockerfiles/keycloak:latest start --optimized --hostname-port=8443

# delete
docker rm -f devtool-dockerfiles-keycloak

# access 
https://localhost:8443/
```
