# Reproduce docker swarm stop-grace-period unexpected behaviour

Docker swarm provides the `--stop-grace-period` flag on shutdown/update of a service, which indicates to the reaper that the container requires time to shutdown properly. This does however produce unexpected behaviour during update of a service. The following service log shows the behaviour:

```
grace-test_grace.1.v5hqsmvoch1t@linuxkit-025000000001    | 2018/01/25 10:08:39 Starting new server
grace-test_grace.1.v5hqsmvoch1t@linuxkit-025000000001    | 2018/01/25 10:08:48 Signal terminated received, sleeping for 1m30s
grace-test_grace.1.v5hqsmvoch1t@linuxkit-025000000001    | 2018/01/25 10:10:18 Exit
grace-test_grace.1.72yjxclc46lw@linuxkit-025000000001    | 2018/01/25 10:10:47 Signal terminated received, sleeping for 1m30s
grace-test_grace.1.imh2s338u947@linuxkit-025000000001    | 2018/01/25 10:11:45 Starting new server
grace-test_grace.1.72yjxclc46lw@linuxkit-025000000001    | 2018/01/25 10:12:17 Exit
```

The service was set to have a 2m grace period and sleeps for 1m30s before it actually exits. This works as expected, however a second instance is started after 1m, which is unexpected. The expected behaviour would be that docker waits for the old instance to exit before starting the new one.

This repository contains the necessary code to reproduce the problem.

## Requirements
- Go 1.8+
- docker-ce (17.12 used, but versions prior should reproduce as well)
- bash

## Reproduce

Use `./run.sh -brt` to reproduce the issue. Use ctl-c to exit the test.

```
$./run.sh -brt
-- Building docker image
Sending build context to Docker daemon  6.248MB
Step 1/4 : FROM alpine:3.6
 ---> 77144d8c6bdc
Step 2/4 : COPY gracetest /
 ---> Using cache
 ---> a95c61269c14
Step 3/4 : RUN chmod +x /gracetest
 ---> Using cache
 ---> 586c7c41745a
Step 4/4 : ENTRYPOINT ["/gracetest"]
 ---> Using cache
 ---> 74d16e026f97
Successfully built 74d16e026f97
Successfully tagged grace-test:local
-- Starting stack
Creating network grace-test_grace-test
Creating service grace-test_grace
...waiting for stack initialisation
-- Starting update test
grace-test_grace.1.rwmwa0wp7ci2@linuxkit-025000000001    | 2018/01/25 10:36:15 Starting new server
grace-test_grace.1.rwmwa0wp7ci2@linuxkit-025000000001    | 2018/01/25 10:36:24 Signal terminated received, sleeping for 1m30s
grace-test_grace.1.maa2a40dqz2n@linuxkit-025000000001    | 2018/01/25 10:37:22 Starting new server
grace-test_grace.1.rwmwa0wp7ci2@linuxkit-025000000001    | 2018/01/25 10:37:54 Exit
```