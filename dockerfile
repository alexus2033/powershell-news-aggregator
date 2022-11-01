FROM mcr.microsoft.com/powershell:lts-7.2-alpine-3.13

LABEL org.opencontainers.image.authors="alexus2033@github.com"

SHELL ["pwsh", "-Command"]

RUN Install-Module -Name Polaris -Scope AllUsers -Force \
 && Install-Module -Name PowerHTML -Scope AllUsers -Force

# disable reporting
ENV POWERSHELL_TELEMETRY_OPTOUT 1

# set your timezone here
ENV TZ=Europe/Berlin

# verbose output
ENV DEBUG 1

COPY . /var/news/

EXPOSE 8080/tcp

CMD ["pwsh", "-File", "/var/news/webServer.ps1"]