#!/usr/bin/bash

for i in {1..50};
do
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -i ./sql/setup.sql
    if [ $? -eq 0 ]
    then
        echo "Migration completed"
        break
    else
        echo "Migration is not ready yet..."
        sleep 1
    fi
done
