# Helm Commands

## Install Helm 3

[Script to Install](install-helm3.sh)

## helm version

This Command shows you the helm version. 

    $ helm version
    version.BuildInfo{Version:"v3.5.1", GitCommit:"32c22239423b3b4ba6706d450bd044baffdcf9e6", GitTreeState:"clean", GoVersion:"go1.15.7"}

## helm create

1. This command is to create a helm chart or helm chart folder/file structure.  
2. This command will create a folder with name helloworld and few files and folders insider it. 

### List of files and folders created with Helm create
1. **Chart.yaml** - This is the main file that contains the description of our chart
2. **values.yaml** - This is the file that contains the default values for our chart
3. **templates**   - This is the directory where Kubernetes resources are defined as templates.
4. **charts**      - This is an optional directory that may contain sub-charts
    -   Helm charts store their dependencies in 'charts/'. For chart developers, it is often easier to manage dependencies in 'Chart.   yaml' which declares all dependencies.
    -   This can have charts packages for the sub or dependent application/servcies like database/message broker. 
    
5. **.helmignore** - This is where we can define patterns to ignore when packaging (similar in concept to .gitignore)

        $ helm create helloworld
        Creating helloworld

        $ tree helloworld/
        helloworld/
        |-- Chart.yaml
        |-- charts
        |-- templates
        |   |-- NOTES.txt
        |   |-- _helpers.tpl
        |   |-- deployment.yaml
        |   |-- hpa.yaml
        |   |-- ingress.yaml
        |   |-- service.yaml
        |   |-- serviceaccount.yaml
        |   `-- tests
        |       `-- test-connection.yaml
        `-- values.yaml

        3 directories, 10 files


## helm template

1. This command is to view the how all the kubernetes object configuration files are going to look like once provides values.yaml is applied.  
2. with this you can validate the object configuration files and see if values are applied correctly or not. 

        $ helm template helloworld
        ---
        # Source: helloworld/templates/serviceaccount.yaml
        apiVersion: v1
        kind: ServiceAccount
        metadata:
        name: RELEASE-NAME-helloworld
        labels:
            helm.sh/chart: helloworld-0.1.0
            app.kubernetes.io/name: helloworld
            app.kubernetes.io/instance: RELEASE-NAME
            app.kubernetes.io/version: "1.16.0"
            app.kubernetes.io/managed-by: Helm
        ---
        # Source: helloworld/templates/service.yaml
        apiVersion: v1
        kind: Service
        metadata:
        name: RELEASE-NAME-helloworld
        labels:
            helm.sh/chart: helloworld-0.1.0
            app.kubernetes.io/name: helloworld
            app.kubernetes.io/instance: RELEASE-NAME
            app.kubernetes.io/version: "1.16.0"
            app.kubernetes.io/managed-by: Helm
        spec:
        type: NodePort
        ports:
            - port: 80
            targetPort: http
            protocol: TCP
            name: http
        selector:
            app.kubernetes.io/name: helloworld
            app.kubernetes.io/instance: RELEASE-NAME
        ---
        # Source: helloworld/templates/deployment.yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: RELEASE-NAME-helloworld
        labels:
            helm.sh/chart: helloworld-0.1.0
            app.kubernetes.io/name: helloworld
            app.kubernetes.io/instance: RELEASE-NAME
            app.kubernetes.io/version: "1.16.0"
            app.kubernetes.io/managed-by: Helm
        spec:
        replicas: 1
        selector:
            matchLabels:
            app.kubernetes.io/name: helloworld
            app.kubernetes.io/instance: RELEASE-NAME
        template:
            metadata:
            labels:
                app.kubernetes.io/name: helloworld
                app.kubernetes.io/instance: RELEASE-NAME
            spec:
            serviceAccountName: RELEASE-NAME-helloworld
            securityContext:
                {}
            containers:
                - name: helloworld
                securityContext:
                    {}
                image: "nginx:1.16.0"
                imagePullPolicy: IfNotPresent
                ports:
                    - name: http
                    containerPort: 80
                    protocol: TCP
                livenessProbe:
                    httpGet:
                    path: /
                    port: http
                readinessProbe:
                    httpGet:
                    path: /
                    port: http
                resources:
                    {}
        ---
        # Source: helloworld/templates/tests/test-connection.yaml
        apiVersion: v1
        kind: Pod
        metadata:
        name: "RELEASE-NAME-helloworld-test-connection"
        labels:
            helm.sh/chart: helloworld-0.1.0
            app.kubernetes.io/name: helloworld
            app.kubernetes.io/instance: RELEASE-NAME
            app.kubernetes.io/version: "1.16.0"
            app.kubernetes.io/managed-by: Helm
        annotations:
            "helm.sh/hook": test
        spec:
        containers:
            - name: wget
            image: busybox
            command: ['wget']
            args: ['RELEASE-NAME-helloworld:80']
        restartPolicy: Never


## helm lint

1. lint command help you to examine a chart for possible issues


        $ helm lint helloworld/
        ==> Linting helloworld/
        [INFO] Chart.yaml: icon is recommended

        1 chart(s) linted, 0 chart(s) failed


## helm install

1. Install a chart m This command installs a chart archive.
    
    helm install <FIRST_ARGUMENT_RELEASE_NAME> <SECOND_ARGUMENT_CHART_NAME>


        $ helm install helloworld-rel helloworld
        NAME: helloworld-rel
        LAST DEPLOYED: Mon Feb  1 06:32:42 2021
        NAMESPACE: default
        STATUS: deployed
        REVISION: 1
        NOTES:
        1. Get the application URL by running these commands:
        export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services helloworld-rel)
        export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
        echo http://$NODE_IP:$NODE_PORT

    Recommanded approch is to install chart [which finally create k8s objects] understanr the name space. 

    kubectl create namespace <NAME_SPACE_NAME>

    helm install <FIRST_ARGUMENT_RELEASE_NAME> <SECOND_ARGUMENT_CHART_NAME> --namespace <NAME_SPACE_NAME>

        
        $ helm create hello-world
        Creating hello-world

        
        $ kubectl create namespace hello-world-ns
        namespace/hello-world-ns created

        $ helm lint hello-world/
        ==> Linting hello-world/
        [INFO] Chart.yaml: icon is recommended

        1 chart(s) linted, 0 chart(s) failed

        $ helm install hello-world-v1 hello-world --namespace hello-world-ns
        NAME: hello-world-v1
        LAST DEPLOYED: Tue Feb  2 01:30:14 2021
        NAMESPACE: hello-world-ns
        STATUS: deployed
        REVISION: 1
        NOTES:
        1. Get the application URL by running these commands:
        export POD_NAME=$(kubectl get pods --namespace hello-world-ns -l "app.kubernetes.io/name=hello-world,app.kubernetes.io/instance=hello-world-v1" -o jsonpath="{.items[0].metadata.name}")
        export CONTAINER_PORT=$(kubectl get pod --namespace hello-world-ns $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
        echo "Visit http://127.0.0.1:8080 to use your application"
        kubectl --namespace hello-world-ns port-forward $POD_NAME 8080:$CONTAINER_PORT

        $ kubectl get all --namespace hello-world-ns
        NAME                                  READY   STATUS    RESTARTS   AGE
        pod/hello-world-v1-6c459d46b7-zclm4   1/1     Running   0          2m23s

        NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
        service/hello-world-v1   ClusterIP   10.101.149.15   <none>        80/TCP    2m24s

        NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
        deployment.apps/hello-world-v1   1/1     1            1           2m24s

        NAME                                        DESIRED   CURRENT   READY   AGE
        replicaset.apps/hello-world-v1-6c459d46b7   1         1         1       2m23s




2. So Install means, its actually going to apply the templets with values provided in the values.xml

3. let see what all objects are creates with helloworld-rel. Here we can see a POD, Service , Deployment & ReplicaSet is created with just a single install command.  

        $ kubectl.exe get all
        NAME                                 READY   STATUS    RESTARTS   AGE
        pod/helloworld-rel-9d94cfff6-jg9b5   1/1     Running   0          22s

        NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
        service/helloworld-rel   NodePort    10.98.103.21   <none>        80:30563/TCP   23s

        NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
        deployment.apps/helloworld-rel   1/1     1            1           23s

        NAME                                       DESIRED   CURRENT   READY   AGE
        replicaset.apps/helloworld-rel-9d94cfff6   1         1         1       22s


## helm list

1. list the releases created with the helm install command

        $ helm list
        NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
        helloworld-rel  default         1               2021-02-01 06:32:42.3093696 -0500 EST   deployed        helloworld-0.1.0        1.16.0



## helm uninstall

1. uninstall the releases 

        $ helm uninstall helloworld-rel
        release "helloworld-rel" uninstalled

        $ kubectl get all
        NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
        service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   3d8h

        $ helm list
        NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION

## helm repo


### helm repo list

1. list chart repositories

        $ helm repo list
        NAME            URL
        stable          https://charts.helm.sh/stable
        bitnami         https://charts.bitnami.com/bitnami
        ingress-nginx   https://kubernetes.github.io/ingress-nginx


### helm repo add

1. add a chart repository

        $ helm repo add ingress-nginx   https://kubernetes.github.io/ingress-nginx
        "ingress-nginx" has been added to your repositories


### helm repo index

1. generate an index file given a directory containing packaged charts

            $ helm repo index hello-world

            $ tree hello-world
            hello-world/
            |-- Chart.yaml
            |-- charts
            |-- index.yaml
            |-- templates
            |   |-- NOTES.txt
            |   |-- _helpers.tpl
            |   |-- deployment.yaml
            |   |-- hpa.yaml
            |   |-- ingress.yaml
            |   |-- service.yaml
            |   |-- serviceaccount.yaml
            |   `-- tests
            |       `-- test-connection.yaml
            `-- values.yaml

            3 directories, 11 files


            $ cat hello-world/index.yaml
            apiVersion: v1
            entries: {}
            generated: "2021-02-02T01:41:43.9549077-05:00"


### helm repo remove

1. remove one or more chart repositories

            $ helm repo remove ingress-nginx
            "ingress-nginx" has been removed from your repositories


### helm repo update

1. update information of available charts locally from chart repositories

            $ helm repo update
            Hang tight while we grab the latest from your chart repositories...
            ...Successfully got an update from the "ingress-nginx" chart repository
            ...Successfully got an update from the "bitnami" chart repository
            ...Successfully got an update from the "stable" chart repository
            Update Complete. ⎈Happy Helming!⎈
  

## helm search

1. Search provides the ability to search for Helm charts in the various places they can be stored including the Artifact Hub and repositories you have added. Use search subcommands to search different locations for charts.
2.  **Helm search hub** - search for charts in the Artifact Hub or your own hub instance
3.  **Helm search repo** - search repositories for a keyword in charts

        $ helm repo list
        NAME            URL
        stable          https://charts.helm.sh/stable
        bitnami         https://charts.bitnami.com/bitnami
        ingress-nginx   https://kubernetes.github.io/ingress-nginx


        $ helm search repo postgres
        NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
        bitnami/postgresql                      10.2.6          11.10.0         Chart for PostgreSQL, an object-relational data...
        bitnami/postgresql-ha                   6.5.0           11.10.0         Chart for PostgreSQL with HA architecture (usin...
        stable/postgresql                       8.6.4           11.7.0          DEPRECATED Chart for PostgreSQL, an object-rela...
        stable/prometheus-postgres-exporter     1.3.1           0.8.0           DEPRECATED A Helm chart for prometheus postgres...
        stable/pgadmin                          1.2.2           4.18.0          pgAdmin is a web based administration tool for ...
        stable/stolon                           1.6.5           0.16.0          DEPRECATED - Stolon - PostgreSQL cloud native H...
        stable/gcloud-sqlproxy                  0.6.1           1.11            DEPRECATED Google Cloud SQL Proxy

        $ helm search hub postgres
        URL                                                     CHART VERSION   APP VERSION     DESCRIPTION
        https://artifacthub.io/packages/helm/groundhog2...      0.2.7           13.1            A Helm chart for PostgreSQL on Kubernetes
        https://artifacthub.io/packages/helm/appscode/s...      13.1.0          13.1.0          stash-postgres - PostgreSQL database plugin for...
        https://artifacthub.io/packages/helm/ibm-charts...      1.1.3                           Object-relational database management system (O...
        https://artifacthub.io/packages/helm/prometheus...      1.9.0           0.8.0           A Helm chart for prometheus postgres-exporter
        https://artifacthub.io/packages/helm/prometheus...      1.5.0           0.8.0           A Helm chart for prometheus postgres-exporter
        https://artifacthub.io/packages/helm/deliveryhe...      1.1.0           0.5             A controller for managing PostgreSQL databases,...
        https://artifacthub.io/packages/helm/bytebuilde...      2021.1.21       v2021.01.21     Stash PostgreSQL Addon Community Plan
        https://artifacthub.io/packages/helm/cetic/adminer      0.1.6           4.7.7           Adminer is a full-featured database management ...
        https://artifacthub.io/packages/helm/mina/archi...      0.4.7           1.16.0          A Helm chart for Mina Protocol's archive node
        https://artifacthub.io/packages/helm/adfinis/ba...      0.0.13          2.10            Chart for Barman PostgreSQL Backup and Recovery...
        https://artifacthub.io/packages/helm/hephy/data...      2.7.6                           A PostgreSQL database used by Hephy Workflow.
        https://artifacthub.io/packages/helm/drycc-cana...      1.0.0                           A PostgreSQL database used by Drycc Workflow.
        https://artifacthub.io/packages/helm/drycc/data...      1.0.2                           A PostgreSQL database used by Drycc Workflow.
        https://artifacthub.io/packages/helm/camptocamp...      0.0.6           1.0             Expose services and secret to access postgres d...
        https://artifacthub.io/packages/helm/kanister/k...      0.32.0          9.6.2           PostgreSQL w/ Kanister support based on stable/...
        https://artifacthub.io/packages/helm/cetic/pgadmin      0.1.12          4.13.0          pgAdmin is a web based administration tool for ...
        https://artifacthub.io/packages/helm/halkeye/pg...      0.1.5           4.11            pgAdmin is the most popular and feature rich Op...
        https://artifacthub.io/packages/helm/runix/pgad...      1.4.6           4.29.0          pgAdmin4 is a web based administration tool for...
        https://artifacthub.io/packages/helm/duyet/post...      9.3.3           11.9.0          Chart for PostgreSQL, an object-relational data...
        https://artifacthub.io/packages/helm/choerodon/...      3.18.4          10.7.0          Chart for PostgreSQL, an object-relational data...
        https://artifacthub.io/packages/helm/cetic/post...      0.2.1           11.5.0          PostgreSQL is an open-source object-relational ...
        https://artifacthub.io/packages/helm/bitnami/po...      10.2.6          11.10.0         Chart for PostgreSQL, an object-relational data...
        https://artifacthub.io/packages/helm/bitnami/po...      6.5.0           11.10.0         Chart for PostgreSQL with HA architecture (usin...
        https://artifacthub.io/packages/helm/halkeye/turtl      0.1.7           0.7             The secure, collaborative notebook - Totally pr...
