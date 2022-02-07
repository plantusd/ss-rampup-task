FROM mcr.microsoft.com/mssql/server:2019-CU13-ubuntu-20.04

COPY ./scripts .
ENTRYPOINT ["env", "bash", "./entrypoint.sh"]
