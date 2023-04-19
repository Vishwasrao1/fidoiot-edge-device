# This repository is used to simulate zero touch FDO Device onboarding client devices. Follow below steps to do the simulation.
It is assumed that the host machine already has docker engine along with docker-compose.

### Step 1 : Generate serial numbers for each edge-device-client
Run below script to generate as many serial numbers you want, intially we have kept the number to 10 devices. 
```console
$ bash serial_number_generator.sh
```

### Step 2 : Run docker-compose
```console
$ docker-compose up --build
```
This will create 10 instances of edge-device-client which support FDO onboarding to hawkbit server. If you want more you can just increase the client in docker-compose.ump file. 
This command will build the image of client and run it. Each client has it's own separate private key and identity.

### Step 3 : Simulate Manufacturing Process (Device Intialization Protocol)
The FDO Client SDK Linux device is compatible with FDO PRI components namely: Manufacturer, Rendezvous, and Owner.
To test the FDO Client SDK Linux device, setup the FDO PRI Manufacturer, FDO PRI Rendezvous, and FDO PRI Owner as per pri-fidoiot.
Run below command to simulate the process, this command will manufacture 10 device.

```console
$ bash manufacture.sh
```

```console
Device Initialization successfully.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@FIDO Device Initialization Complete@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```


### Step 4 : Simulate Ownership Transfer (Ownership transfer and TO0 Protocol)
The ownership transfer must be done when the device is handed over to the owner from manufacturer. this step will simulate the ownership voucher transfer between manufacturing server and owner server. The transfer of ownership voucher happens on https, so we must include secrets of of the servers to transfer the data.
#### You must copy secrets folder form  'pri-fidoiot/component-samples/demo/scripts/secrets' to root of this reposittory.

Once done run below transferownership script as given below, this will transfer the ownership to the owner server and initiate the TO0 protocol.

```console
$ bash transferownership.sh
```
```console
Client Certificate authentication mode is being used
Success in downloading SECP256R1 owner certificate to owner_cert_SECP256R1.txt
Success in downloading extended voucher for device with serial number lxfdo030VCW
Success in uploading voucher to owner for device with serial number lxfdo030VCW
GUID of the device is 8937c0d1-85d3-48e4-bec9-0fe65c9cd759
Success in triggering TO0 for lxfdo030VCW with GUID 8937c0d1-85d3-48e4-bec9-0fe65c9cd759
```

### Step 4 : Simulate Provisioning/Onboadring Process (TO1 and TO2 Protocol)
before running this script make sure you have hawkbit server up and running. This script will simulate TO1 and T02 protocol of FDO. In the end the device will be able to register itself to the hawkbit server. and you will be able to see the device on hawkbit UI.

```console
$ bash provision.sh
```
```console
Device onboarded successfully.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@FIDO Device Onboard Complete@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

To simulate the onboarding once again you can stop the running containers of edge device client and run below command to recreate them with new credentials.

```console
$ docker-compose up --force-recreate --build
```






