# Deploying Applications Using Helm

## What is Helm [The Kubernetes Package Manager]

As we know that running applications with Kubernetes will require maintaince of Kubernetes objects yaml configuration files. Solution to this problem is Heml

- Helm calls itself ”The Kubernetes package manager”. 
- It is a command-line tool that enables you to create and use so-called Helm Charts.

## Three Big Concepts

1. **Helm Chart** - A Chart is a Helm package. It contains all of the resource definitions necessary to run an application, tool, or service inside of a Kubernetes cluster.

2. **Repository** A Repository is the place where charts can be collected and shared.

2. **Release** A Release is an instance of a chart running in a Kubernetes cluster. One chart can often be installed many times into the same cluster. And each time it is installed, a new release is created.


**Helm Charts**
- Helm manages Kubernetes resource packages through Charts.
- A chart is a collection of files organized in a specific directory structure.
- The configuration information related to a chart is managed in the configuration.
- Finally you can  have a running instance of a chart with a specific config is called a release.

In other simmple way you can see helm as **Structured and Parameterized**  Kubernetes objects yaml configuration files collection. 

This **Structured and Parameterized** collections will have a way to provide input and based on this input Kubernetes objects will be created and maintained.


![alt](/images/helm.png)


So lets start with creating a helm chart. 

```
    
    $ helm create hello-world
    Creating hello-world
```

list the files created with helm create commond

```
    $ ls -lRt hello-world
    hello-world:
    total 12
    drwxr-xr-x 1 Sumit 197609    0 Jan 31 22:18 charts/
    drwxr-xr-x 1 Sumit 197609    0 Jan 31 22:18 templates/
    -rw-r--r-- 1 Sumit 197609 1804 Jan 31 22:18 values.yaml
    -rw-r--r-- 1 Sumit 197609 1147 Jan 31 22:18 Chart.yaml

    hello-world/charts:
    total 0

    hello-world/templates:
    total 22
    -rw-r--r-- 1 Sumit 197609 1822 Jan 31 22:18 _helpers.tpl
    drwxr-xr-x 1 Sumit 197609    0 Jan 31 22:18 tests/
    -rw-r--r-- 1 Sumit 197609 1763 Jan 31 22:18 NOTES.txt
    -rw-r--r-- 1 Sumit 197609  928 Jan 31 22:18 hpa.yaml
    -rw-r--r-- 1 Sumit 197609  328 Jan 31 22:18 serviceaccount.yaml
    -rw-r--r-- 1 Sumit 197609  373 Jan 31 22:18 service.yaml
    -rw-r--r-- 1 Sumit 197609 1856 Jan 31 22:18 deployment.yaml
    -rw-r--r-- 1 Sumit 197609 1064 Jan 31 22:18 ingress.yaml

    hello-world/templates/tests:
    total 1
    -rw-r--r-- 1 Sumit 197609 391 Jan 31 22:18 test-connection.yaml

```


1. **Chart.yaml**  - This is the main file that contains the description of our chart. Helm charts store their dependencies in 'charts/'. For chart developers, it is often easier to manage dependencies in 'Chart.   yaml' which declares all dependencies.

```
        $ cat Chart.yaml
        apiVersion: v2
        name: hello-world
        description: A Helm chart for Kubernetes

        # A chart can be either an 'application' or a 'library' chart.
        #
        # Application charts are a collection of templates that can be packaged into versioned archives
        # to be deployed.
        #
        # Library charts provide useful utilities or functions for the chart developer. They're included as
        # a dependency of application charts to inject those utilities and functions into the rendering
        # pipeline. Library charts do not define any templates and therefore cannot be deployed.
        type: application

        # This is the chart version. This version number should be incremented each time you make changes
        # to the chart and its templates, including the app version.
        # Versions are expected to follow Semantic Versioning (https://semver.org/)
        version: 0.1.0

        # This is the version number of the application being deployed. This version number should be
        # incremented each time you make changes to the application. Versions are not expected to
        # follow Semantic Versioning. They should reflect the version the application is using.
        # It is recommended to use it with quotes.
        appVersion: "1.16.0"


```

2. **values.yaml** - This is the file that contains the default values for our chart

```

    $ cat values.yaml
    # Default values for hello-world.
    # This is a YAML-formatted file.
    # Declare variables to be passed into your templates.

    replicaCount: 1

    image:
    repository: nginx
    pullPolicy: IfNotPresent
    # Overrides the image tag whose default is the chart appVersion.
    tag: ""

    imagePullSecrets: []
    nameOverride: ""
    fullnameOverride: ""

    serviceAccount:
    # Specifies whether a service account should be created
    create: true
    # Annotations to add to the service account
    annotations: {}
    # The name of the service account to use.
    # If not set and create is true, a name is generated using the fullname template
    name: ""

    podAnnotations: {}

    podSecurityContext: {}
    # fsGroup: 2000

    securityContext: {}
    # capabilities:
    #   drop:
    #   - ALL
    # readOnlyRootFilesystem: true
    # runAsNonRoot: true
    # runAsUser: 1000

    service:
    type: ClusterIP
    port: 80

    ingress:
    enabled: false
    annotations: {}
        # kubernetes.io/ingress.class: nginx
        # kubernetes.io/tls-acme: "true"
    hosts:
        - host: chart-example.local
        paths: []
    tls: []
    #  - secretName: chart-example-tls
    #    hosts:
    #      - chart-example.local

    resources: {}
    # We usually recommend not to specify default resources and to leave this as a conscious
    # choice for the user. This also increases chances charts run on environments with little
    # resources, such as Minikube. If you do want to specify resources, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
    # limits:
    #   cpu: 100m
    #   memory: 128Mi
    # requests:
    #   cpu: 100m
    #   memory: 128Mi

    autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 100
    targetCPUUtilizationPercentage: 80
    # targetMemoryUtilizationPercentage: 80

    nodeSelector: {}

    tolerations: []

    affinity: {}

```

3. **templates**   - This is the directory where Kubernetes resources are defined as templates.

```
    $ ls -lrt hello-world/templates/
    total 22
    -rw-r--r-- 1 Sumit 197609 1064 Jan 31 22:18 ingress.yaml
    -rw-r--r-- 1 Sumit 197609 1856 Jan 31 22:18 deployment.yaml
    -rw-r--r-- 1 Sumit 197609  373 Jan 31 22:18 service.yaml
    -rw-r--r-- 1 Sumit 197609  328 Jan 31 22:18 serviceaccount.yaml
    -rw-r--r-- 1 Sumit 197609  928 Jan 31 22:18 hpa.yaml
    -rw-r--r-- 1 Sumit 197609 1763 Jan 31 22:18 NOTES.txt
    drwxr-xr-x 1 Sumit 197609    0 Jan 31 22:18 tests/
    -rw-r--r-- 1 Sumit 197609 1822 Jan 31 22:18 _helpers.tpl

```

4. **charts**      - This is an optional directory that may contain sub-charts
    -   This can have charts packages for the sub or dependent application/servcies like database/message broker. 
5. **.helmignore** - This is where we can define patterns to ignore when packaging (similar in concept to .gitignore)