# edgemicro-k8s-custom-plugin

This project was originally published under GCP Cloud Source Repositories under the project named `apigee-k8s-edgemicro-sw`.  The Google Cloud Source repository name is `edgemicro-config`.  

The GCP Source Repository for the custom plugin is named `edgemicro-k8s-custom-plugin`, which is also under the `apigee-k8s-edgemicro-sw` repository.

This repo demonstrates how to build a CI/CD process for a custom Edge Microgateway plugin and it deploys that custom plugin to an Edge Microgateway running on Kubernetes.  The custom plugins are included within the Docker image, and the GCP build updates the deployment's container image based on the repository's tag and then pulls the updated image (based on the repo's tag) when a new pod is created.

Another option is to use a rolling upgrade by changing the last step in the `cloudbuild.yaml` and include the `edgemicro-deployment.yaml` file.

The advantage of using the approaches outlined above is that you this is zero Micorgateway downtime when you update the custom plugin.  

## Summary
* The logger plugin is based on the following [documentation](https://apigee.com/about/blog/api-technology/tutorial-adding-logger-plugin-apigee-edge-microgateway).  
* The `plugins/logger` directory contains the Microgateway custom plugin code.  
* This documentation follows the approach outlined in the [Microgateway Github repository](https://github.com/apigee-internal/microgateway/tree/master/kubernetes/docker/edgemicro#option-2-build-plugins-into-the-container).


## Prerequisites
1. Follow the prerequisites listed [here](#../README.md).
2. You should be familiar with [how to create a custom plugin](https://docs.apigee.com/api-platform/microgateway/2.5.x/develop-custom-plugins) in Edge Microgateway
3. This folder uses [Google Cloud Container Registry](https://cloud.google.com/container-registry)
4. copy your Edge Microgateway config file to this directory and ensure that it includes the following plugins. (see the example org-test-config.yaml)
```
  plugins:
    sequence:
      - oauth
      - logger
      - accumulate-response
  ```
5. Update the `microgateway.sh` file with your Apigee Edge org and environment names and include the Microgateway's key and secret which you received when you configured the microgateway.  


## Google Cloud Build
You should configure the build as shown below.  Notice that it will build only if you push a tag to the repository.  

![gcp-build-trigger](images/gcp-build-trigger.png)


## Secret.yaml
If you followed the instructions in "[creating a Kubernetes cluster](https://github.com/apigee-internal/microgateway/tree/master/kubernetes)", then you already created the `mgwsecret` in your K8S cluster. The Microgateway will use this secrets object to pull the Apigee organization name, environment, microgateway key & secret, and the Edge Microgateway configuration file.  The GCP Build will use this `secret.yaml` file to update the existing secret object in the Kubernetes cluster.  


## cloudbuild.yaml
The `cloudbuild.yaml` file contains six steps.  
1. executes `npm install` to install the plugins dependencies
2. build a docker image with the custom plugin code included in the image and updates the image tag
3. pushes the docker image to Google Cloud Containers within your GCP project
4. updates the secret.yaml file
5. applies the updated secret.yaml file (push the changes to the k8s cluster). **This does not update the existing Microgateway pods.**
6. updates the container image to the image pushed in step 3.  **This updates the containers to use the new container image.**


## Update the microgateway.sh file
Add the following to the microgateway.sh file.
* Apigee org
* Apigee env
* Microgateway key
* Microgateway secret

**You get the Microgateway Key and Secret after you run the edgemicro configure command.**


## Demo

1. Execute the following commands to trigger a build.
```
git tag -a v1 -m "version 1"
git push origin v1
```

or

```
./tag-add.sh v1
```

2. You should see all six build steps succeed.
![build steps](images/gcp-build-steps.png)

Once all steps in the build succeed you can view the pod revision history.

![pod revision history](images/gcp-pod-revisions.png)

3. Run the following shell script command to test that the new pod is using the updated Edgemicro config file.

```
for i in {1..20}; do curl http://$GATEWAY_IP/edgemicro_k8s_hello/ -H "x-api-key:YOUR_APIKEY"; done
```

You should see something similar to the what is shown below.
```
Hello world
Hello world
...
```

4. ssh into a running container.
```
kubectl get pods
```
Response:
```
NAME                                 READY     STATUS    RESTARTS   AGE
edge-microgateway-84f7cf8985-7nb4v   1/1       Running   0          50m
helloworld-69c457bf98-hzv74          1/1       Running   0          14d
```

```
kubectl exec -it edge-microgateway-84f7cf8985-7nb4v -- /bin/sh
```

5. You can view the Bunyan log file within the container by executing the following command.
```
vi /var/tmp/edgemicrogateway-bunyan-info.log
```

6. You can also view the edgemicro config file.
```
ls /opt/apigee/.edgemicro
vi /opt/apigee/.edgemicro/YOURORG-ENV-config.yaml
```


## Delete the tag from remote and local repositories
You can delete a tag from the remote repository with the following commands.
```
git push --delete origin v1
git tag --delete v1
```

or

```
./tag-delete.sh v1
```

## tag-delete.sh and tag-add.sh
`tag-delete.sh` and `tag-add.sh` are short cut scripts that executes both the `git tag` and `git push`.


## Notes
My GCP project contains two repositories named `edgemicro-config` and `edgemicro-k8s-custom-plugin`, which I have combined into a single Github repository; therefore some files are duplicated and this repository needs some reorganization.

* `handle-plugins.sh` is not used in this `cloudbuild.yaml` file.  This shell script was developed to zip the plugins into a single directory, but the zip command is not available in `gsutil` from Cloud Build.
* `edgemicro-deployment.yaml` also is not used in the `cloudbuild.yaml` file.  This file represents the deployment and could be used to create a rolling upgrade in the last step of `cloudbuild.yaml`.
