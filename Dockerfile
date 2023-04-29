FROM lambci/lambda-base-2:build

# Run: docker run --rm --entrypoint dotnet lambci/lambda:dotnetcore3.1 --info
# Check https://dotnet.microsoft.com/download/dotnet-core/3.1 for versions
ENV DOTNET_ROOT=/var/lang/bin
ENV PATH=/root/.dotnet/tools:$DOTNET_ROOT:$PATH \
    LD_LIBRARY_PATH=/var/lang/lib:$LD_LIBRARY_PATH \
    AWS_EXECUTION_ENV=AWS_Lambda_dotnetcore3.1 \
    DOTNET_SDK_VERSION=3.1.201 \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    NUGET_XMLDOC_MODE=skip \
    SONAR_SCANNER_MSBUILD_VERSION=4.9.0.17385 \
    NODE_VERSION=10.19.0 \
    NEWMAN_VERSION=5.1.2

RUN rm -rf /var/runtime /var/lang && \
  curl https://lambci.s3.amazonaws.com/fs/dotnetcore3.1.tgz | tar -zx -C / && \
  curl -L https://dot.net/v1/dotnet-install.sh | bash -s -- -v $DOTNET_SDK_VERSION -i $DOTNET_ROOT && \
  mkdir /tmp/warmup && \
  cd /tmp/warmup && \
  dotnet new && \
  cd / && \
  rm -rf /tmp/warmup /tmp/NuGetScratch /tmp/.dotnet


# Add these as a separate layer as they get updated frequently
RUN pip install -U awscli boto3 aws-sam-cli==0.48.0 aws-lambda-builders==0.9.0 --no-cache-dir && \
  dotnet tool install --global Amazon.Lambda.Tools --version 3.3.1

# Install Sonar Scanner
RUN yum install -y wget java-1.8.0-openjdk \
    && wget https://github.com/SonarSource/sonar-scanner-msbuild/releases/download/$SONAR_SCANNER_MSBUILD_VERSION/sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-netcoreapp3.0.zip \
    && unzip sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-netcoreapp3.0.zip -d /sonar-scanner \
    && rm sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-netcoreapp3.0.zip \
    && chmod +x -R /sonar-scanner


# Newman stuff
RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash
RUN yum -y install nodejs
RUN node --version
RUN npm --version
RUN npm install -g newman \
    && newman --version


CMD ["dotnet", "build"]
