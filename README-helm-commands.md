# Helm Commands

## helm version

Usage : This Command shows you the helm version. 

    $ helm version
    version.BuildInfo{Version:"v3.5.1", GitCommit:"32c22239423b3b4ba6706d450bd044baffdcf9e6", GitTreeState:"clean", GoVersion:"go1.15.7"}

## helm create

Usage : 
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

Usage : 
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

Usage : 
1. lint command help you to examine a chart for possible issues


        $ helm lint helloworld/
        ==> Linting helloworld/
        [INFO] Chart.yaml: icon is recommended

        1 chart(s) linted, 0 chart(s) failed


## helm install

Usage : 
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

Usage : 
1. list the releases created with the helm install command

        $ helm list
        NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
        helloworld-rel  default         1               2021-02-01 06:32:42.3093696 -0500 EST   deployed        helloworld-0.1.0        1.16.0



## helm uninstall

Usage : 
1. uninstall the releases 

        $ helm uninstall helloworld-rel
        release "helloworld-rel" uninstalled

        $ kubectl get all
        NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
        service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   3d8h

        $ helm list
        NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION
