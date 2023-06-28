# IWA (Insecure Web App) Java Edition

## Overview

_IWA (Insecure Web App) Java Edition_ is an example Java/Spring Web Application for use in **DevSecOps** scenarios and demonstrations.
It includes some examples of bad and insecure code - which can be found using static and dynamic application
security testing tools such as those provided by [Micro Focus Fortify](https://www.microfocus.com/en-us/cyberres/application-security).

The application is intended to provide the functionality of a typical "online pharmacy", including purchasing Products (medication)
and requesting Services (prescriptions, health checks etc). It has a modern-ish HTML front end (with some JavaScript) and a Swagger based API.

*Please note: the application should not be used in a production environment!*

## Forking the Repository

In order to execute example scenarios for yourself it is recommended that you "fork" a copy of this repository into
your own GitHub account. The process of "forking" is described in detail in the [GitHub documentation](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) - you can start the process by clicking on the "Fork" button at the top right.

## Building the Application

To build the application, execute the following from the command line:

```
mvn clean package
```

This will create a JAR file (called `iwa.jar`) in the `target` directory.

To build a WAR file for deployment to an application server such as [Apache Tomcat](http://tomcat.apache.org/)
execute the following:

```
mvn -Pwar clean package
```

This will create a WAR file (called `iwa.war`) in the `target` directory.

## Running the Application

### Development (IDE/command line)

To run (and test) locally in development mode, execute the following from the command line:

```
mvn spring-boot:run
```

### Release (Docker Image)

The JAR file can be built into a [Docker](https://www.docker.com/) image using the provided `Dockerfile` and the
following commands:

```
mvn -Pjar clean package
docker build -t iwa -f Dockerfile .
```

or on Windows:

```
mvn -Pjar clean package
docker build -t iwa -f Dockerfile.win .
```

This image can then be executed using the following commands:

```
docker run -d -p 8888:8080 iwa
```

## Using the Application

To use the application navigate to the URL: [http://localhost:8888](http://localhost:8888). You can carry out a number of
actions unauthenticated, but if you want to login you can do so as one of the following users:

- **user1@localhost.com/password**
- **user2@localhost.com/password**
  
There is also an administrative user:

- **admin@localhost.com/password**

Upon login, you will be subsequently asked for a Multi-Factor Authentication (MFA) code. This functionality
is not yet enabled and you can enter anything here, e.g. `12345`.

### REST APIs 
To run (and test) locally in development mode, Go to Home Page -> My Account -> API Explorer OR
use the following URL: [http://localhost:8888/swagger-ui/index.html?configUrl=/v3/api-docs/swagger-config](http://localhost:8888/swagger-ui/index.html?configUrl=/v3/api-docs/swagger-config)

### API Authentication
every API endpoint is behind authenitcation and thus require to authenticate with JWT Token before pro
Go To "Site" Operations and expand on :
```
/api/v3/site/sign-in
```
Click "Try it Out" button, provide administrative username and password mentioned above and hit "Execute" button.

Copy the "accessToken" value from response and paste into Swagger Authorization (padlock) icon.

Now, go ahead and try the API methods.

## Licensing

This application is made available under the [GNU General Public License V3](LICENSE)
