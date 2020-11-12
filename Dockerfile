FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet add package Contrast.SensorsNetCore --package-directory ./contrast 
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish /p:Platform=x64 -c Release -o out
COPY ./contrast_security.yaml ./out
COPY ./Contrast.NET.Core_1.6.1 ./out/contrast

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
COPY --from=build-env /app/out .

ENV CONTRAST_CONFIG_PATH /app/contrast_security.yaml
ENV CORECLR_PROFILER_PATH_64 /app/contrast/runtimes/linux-x64/native/ContrastProfiler.so
ENV CORECLR_PROFILER {8B2CE134-0948-48CA-A4B2-80DDAD9F5791}
ENV CORECLR_ENABLE_PROFILING 1
ENV CONTRAST_CORECLR_LOGS_DIRECTORY /opt/contrast/

ENV CONTRAST__APPLICATION__NAME hello-contrast

ENTRYPOINT ["dotnet", "hello-contrast.dll"]