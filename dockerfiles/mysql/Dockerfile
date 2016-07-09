FROM mysql:latest 

# Copy the database initialize script:
# Contents of /docker-entrypoint-initdb.d are run on mysqld startup. Any SQL files inside resources/mysql will be automatically imported.
ADD ./ /docker-entrypoint-initdb.d/ 