# Kong Advanced Startup Script

A more advanced Kong containerised boot script that checks for Konnect cache before going live.

> ⚠️ **This is for Kong 2.8.x.x series only - 3.x will be supported soon**

To get this to run, you need to do two things:

* Build the readiness script into your Kong image
* Re-configure Helm deployment with adjustments to the readiness probe

## Building the Custom Image

Only two files here are needed to build the custom image: `Dockerfile` and `readiness.sh`

If you already have a custom image builder, simply merge the Dockerfile commands, and the script, into your own pipeline.

1. Adjust the source Kong tag in the `FROM` command of the `Dockerfile`

2. Build the image (in this example, 2.8.1.2):

```sh
docker build -t custom/kong-gateway:2.8.1.2-rhel7 .
```

3. Push it to your custom registry

## Re-configure Kong Deployment

First, if necessary, change the `image:` section so that your deployment runs the new custom image you are building.

Then, override the `readinessProbe:` section in your custom values file:

```yaml
readinessProbe:
  httpGet: null
  exec:
    command:
      - "sh"
      - "-c"
      - "/usr/local/bin/readiness.sh"
  initialDelaySeconds: 10
  timeoutSeconds: 5
  periodSeconds: 5
  successThreshold: 1
  failureThreshold: 5
```

* Adjust the `initialDelaySeconds` to be roughly the same time that you would 'normally' see your Kong gateway connect to Konnect and download its runtime group configuration.
* Set the `failureThreshold` to how many times the check should fail before rebooting the pod.

## Troubleshooting

There is a log written to `/tmp/readiness.log` - you can inspect this file to see exactly what's going wrong.
