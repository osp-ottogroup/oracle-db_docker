# oracle-db_docker
This repo contains the Dockerfiles and scripts needed to build Docker images with an already installed Oracle Database instance.

Purpose for these images is use for development and test DBs, not production.
A quick start in seconds of a container with a fresh usable running DB instance is especially helpful in CI piplines.

## Steps to build an Oracle DB instance inside a Docker image
### Step 1: Build Docker image for Oracle DB software package

Use Oracle's official Dockerfiles at https://github.com/oracle/docker-images.

Follow the instruction from https://github.com/oracle/docker-images/tree/master/OracleDatabase

#### Example steps for single instance Oracle 12.1.0.2 Enterprise Edition:
* Download the Dockerfile package by `git clone https://github.com/oracle/docker-images.git`
* Download software package for 12.1.0.2 EE from https://edelivery.oracle.com/osdc/faces/SoftwareDelivery
* Store the downloaded software package at docker-images/OracleDatabase/SingleInstance/dockerfiles/12.1.0.2 
* create the Docker image by executing:

      cd docker-images/OracleDatabase/SingleInstance/dockerfiles
      ./buildContainerImage.sh -v 12.1.0.2 -e -t oracle/database:12.1.0.2-ee  -o '--build-arg SLIMMING=false'

  * rename zip files according to the error message if they did not have the expected name (like `linuxamd64_12102_database_1of2.zip`) 
  * the `-o '--build-arg SLIMMING=false'` is needed only if you plan to patch the image in the next step. 
Otherwise the image will be slimmed down by removing unneded packages like sqldeveloper, but patching such a slimmed image becomes impossible.
* The resulting Docker image is named `oracle/database:12.1.0.2-ee`

### Step 2: Patch the image created in step 1
Creates an image with current patch state of underlying OS and Oracle software.
Patching requires a complete ORACLE_HOME, so be aware of setting `-o '--build-arg SLIMMING=false'` in the previous step.
As part of the image build unnecessary packages are removed after patching to reduce the size of the resulting image.
This way you cannot patch an already patched image. You need to always patch the original database image.
- Change dir to oracle_db_patch
- Download patch file as well as the OPatch utility according to the DB release and store them in current directory
- Run "./build_db_image.sh \<VERSION\> \<patch file.zip\> \<opatch file.zip\>"
- Tag created image according to DB release and push it to your local registry

#### Example steps for 12.1.0.2 EE
- Download opatch tool according to your DB release from https://updates.oracle.com/download/6880880.html
- store the zip file with opatch it in folder `oracle_db_patched`
- Download the current patch set bundle, store it also in  folder `oracle_db_patched`
- Build a new image with patched software and stripped from unused packages by:

      cd oracle_db_patched
      ./build_db_image.sh 12.1.0.2-ee p34386266_121020_Linux-x86-64.zip p6880880_122010_Linux-x86-64.zip

- the resulting Docker image is named `oracle/database_patched:12.1.0.2-ee`

### Step 3: Create an image with a preinstalled database instance
Creates an image with an already installed DB instance.
The default password for sytem accounts is "oracle".
- Change dir to the folder `oracle_db_prebuilt`
- Run `./build_db_image.sh <BASE_IMAGE> <TARGET_IMAGE>` 
- Tag the created image and push to your local registry

#### Example steps for 12.1.0.2 EE
- Build the image 

      cd oracle_db_prebuilt
      ./build_db_image.sh oracle/database_patched:12.1.0.2-ee oracle/database_prebuilt:12.1.0.2-ee

### Step 4: Create a container with a running DB instance

To create an container based on the example image execute:

      docker run -p 1521:1521 oracle/database_prebuilt:12.1.0.2-ee 

Due to the copy on write at file level of Docker's overlay file system it takes some seconds to clone the touched datafiles, then the DB is running.

## Enrich the image with business related additions

In addition to the raw DB instance you may build an additional image based on step 3 enriched with business structures.

Due to Docker's "copy on write" implementation at file level for the "overlay2" storage driver each data file is cloned at DB start during update of some header bytes.
Using multistage builds with single-layer Docker images prevents from increasing the size of each image by the size of the datafiles.<br/>
As an alternative you may use the "devicemapper" storage driver in direct-lvm mode, which does copy on write at block level.
However,  the "devicemapper" storage driver is marked deprecated in favor of "overlay2".

### Example for 12.1.0.2 EE
Build a new image with:
* modified instance settings for memory
* an DB-user BUSINESS created
* the schema SYS analyzed
* SQL files placed for execution at each DB startup at $ORACLE_BASE/scripts/startup

```
cd oracle_db_prebuilt_enriched
./build_db_image.sh oracle/database_prebuilt:12.1.0.2-ee oracle/database_prebuilt_enriched:12.1.0.2-ee
```

## Alternative: Use existing Docker images from container-registry.oracle.com
https://container-registry.oracle.com contains Docker images for the current release of several Oracle products including Oracle-DB. 

### Free release 23.x (23ai) for development and test
Gerald Venzl (Oracle employee) provides enhanced Docker images for relase 23.
See: https://github.com/gvenzl/oci-oracle-free/blob/main/README.md

You can proceed with step 3 using the provided images. 

## Reminder
Please note that a valid license is regularly required to run and operate an Oracle Database instance.
