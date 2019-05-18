# Deep Security Smart Check test image

You can use the files in this directory to create a test image for Deep Security Smart Check. This image will trigger findings in the malware, vulnerability, content, and security checklist scanners.

## Build the image

```sh
docker build -t fake-image:latest .
```

## Tag the image

```sh
docker tag fake-image:latest registry.example.com/fake-image:latest
```

## Push the image

```sh
docker push registry.example.com/fake-image:latest
```
