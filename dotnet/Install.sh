# Deploying .NET Core Windows Applications on Docker

To deploy a .NET Core application in a Windows Docker container, follow these steps:

## Prerequisites
- Windows 10/11 Pro/Enterprise or Windows Server 2016/2019/2022
- Docker Desktop for Windows (with Windows containers enabled)
- .NET Core SDK installed

## Step 1: Create a Dockerfile

Create a `Dockerfile` in your project root (no file extension) with content like this:

```dockerfile
# Use the official Microsoft .NET Core runtime image for Windows
FROM mcr.microsoft.com/dotnet/aspnet:8.0-nanoserver-ltsc2022 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Build image
FROM mcr.microsoft.com/dotnet/sdk:8.0-nanoserver-ltsc2022 AS build
WORKDIR /src
COPY ["YourProject.csproj", "."]
RUN dotnet restore "YourProject.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "YourProject.csproj" -c Release -o /app/build

# Publish image
FROM build AS publish
RUN dotnet publish "YourProject.csproj" -c Release -o /app/publish

# Final image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "YourProject.dll"]
```

## Step 2: Build the Docker Image

Run this command in the directory containing your Dockerfile:

```powershell
docker build -t yourproject .
```

## Step 3: Run the Container

```powershell
docker run -d -p 8080:80 --name yourproject-container yourproject
```

## Windows-Specific Considerations

1. **Base Image Selection**:
   - Use Windows-specific tags like `nanoserver-ltsc2022` or `windowsservercore-ltsc2022`
   - Example: `mcr.microsoft.com/dotnet/aspnet:8.0-nanoserver-ltsc2022`

2. **Performance**:
   - Windows containers are larger than Linux containers
   - Consider using Nano Server for smaller footprint

3. **Networking**:
   - Windows containers handle networking differently than Linux containers
   - Use `--network` flags if you need specific networking configurations

## Alternative for Legacy .NET Core Versions

For .NET Core 3.1 or earlier, use these base images:
```dockerfile
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-nanoserver-1809 AS base
FROM mcr.microsoft.com/dotnet/core/sdk:3.1-nanoserver-1809 AS build
```

## Troubleshooting

- If you get errors about Windows containers not being enabled:
  - Right-click Docker Desktop icon → "Switch to Windows containers"
- For performance issues, ensure your host OS matches the container OS version (LTSC 2019, 2022, etc.)

Remember that Windows containers require matching Windows host/container versions for optimal compatibility.
