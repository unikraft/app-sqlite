# SQLite on Unikraft

This application starts an SQLite web server with Unikraft.
Follow the instructions below to set up, configure, build and run SQLite.

## Requirements

In order to set up, configure, build and run SQLite on Unikraft, the following packages are required:

* `build-essential` / `base-devel` / `@development-tools` (the meta-package that includes `make`, `gcc` and other development-related packages)
* `sudo`
* `flex`
* `bison`
* `git`
* `wget`
* `uuid-runtime`
* `qemu-system-x86`
* `qemu-system-arm`
* `qemu-kvm`
* `sgabios`
* `gcc-aarch64-linux-gnu`

GCC >= 8 is required to build SQLite on Unikraft.

On Ubuntu/Debian or other `apt`-based distributions, run the following command to install the requirements:

```console
$ sudo apt install -y --no-install-recommends \
  build-essential \
  sudo \
  gcc-aarch64-linux-gnu \
  libncurses-dev \
  libyaml-dev \
  flex \
  bison \
  git \
  wget \
  uuid-runtime \
  qemu-kvm \
  qemu-system-x86 \
  qemu-system-arm \
  sgabios
```

## Set Up

The following repositories are required for SQLite:

* The application repository (this repository): [`app-sqlite`](https://github.com/unikraft/app-sqlite)
* The Unikraft core repository: [`unikraft`](https://github.com/unikraft/unikraft)
* Library repositories:
  * The SQLite "library" repository: [`lib-sqlite`](https://github.com/unikraft/lib-sqlite)
  * The standard C library: [`lib-musl`](https://github.com/unikraft/lib-musl)

Follow the steps below for the setup:

  1. First clone the [`app-sqlite` repository](https://github.com/unikraft/app-sqlite) in the `sqlite/` directory:

     ```console
     $ git clone https://github.com/unikraft/app-sqlite sqlite
     ```

     Enter the `sqlite/` directory:

     ```console
     $ cd sqlite/

     $ ls -F
     config-qemu-aarch64  config-qemu-x86_64  fs0/  kraft.yaml  Makefile  Makefile.uk  README.md  run-qemu-aarch64.sh*  run-qemu-x86_64.sh*
     ```

  1. While inside the `sqlite/` directory, create the `.unikraft/` directory:

     ```console
     $ mkdir .unikraft
     ```

     Enter the `.unikraft/` directory:

     ```console
     $ cd .unikraft/
     ```

  1. While inside the `.unikraft` directory, clone the [`unikraft` repository](https://github.com/unikraft/unikraft):

     ```console
     $ git clone https://github.com/unikraft/unikraft unikraft
     ```

  1. While inside the `.unikraft/` directory, create the `libs/` directory:

     ```console
     $ mkdir libs
     ```

  1. While inside the `.unikraft/` directory, clone the library repositories in the `libs/` directory:

     ```console
     $ git clone https://github.com/unikraft/lib-sqlite libs/sqlite

     $ git clone https://github.com/unikraft/lib-musl libs/musl
     ```

  1. Get back to the application directory:

     ```console
     $ cd ../
     ```

     Use the `tree` command to inspect the contents of the `.unikraft/` directory.
     It should print something like this:

     ```console
     $ tree -F -L 2 .unikraft/
     .unikraft/
     |-- libs/
     |   |-- lwip/
     |   |-- musl/
     |   `-- sqlite/
     `-- unikraft/
         |-- arch/
         |-- Config.uk
         |-- CONTRIBUTING.md
         |-- COPYING.md
         |-- include/
         |-- lib/
         |-- Makefile
         |-- Makefile.uk
         |-- plat/
         |-- README.md
         |-- support/
         `-- version.mk

     10 directories, 7 files
     ```

## Configure

Configuring, building and running a Unikraft application depends on our choice of platform and architecture.
Currently, supported platforms are QEMU (KVM), Xen and linuxu.
QEMU (KVM) is known to be working, so we focus on that.

Supported architectures are x86_64 and AArch64.

Use the corresponding the configuration files (`config-...`), according to your choice of platform and architecture.

### QEMU x86_64

Use the `config-qemu-x86_64` configuration file together with `make defconfig` to create the configuration file:

```console
$ UK_DEFCONFIG=$(pwd)/config-qemu-x86_64 make defconfig
```

This results in the creation of the `.config` file:

```console
$ ls .config
.config
```

The `.config` file will be used in the build step.

### QEMU AArch64

Use the `config-qemu-aarch64` configuration file together with `make defconfig` to create the configuration file:

```console
$ UK_DEFCONFIG=$(pwd)/config-qemu-aarch64 make defconfig
```

Similar to the x86_64 configuration, this results in the creation of the `.config` file that will be used in the build step.

## Build

Building uses as input the `.config` file from above, and results in a unikernel image as output.
The unikernel output image, together with intermediary build files, are stored in the `build/` directory.

### Clean Up

Before starting a build on a different platform or architecture, you must clean up the build output.
This may also be required in case of a new configuration.

Cleaning up is done with 3 possible commands:

* `make clean`: cleans all actual build output files (binary files, including the unikernel image)
* `make properclean`: removes the entire `build/` directory
* `make distclean`: removes the entire `build/` directory **and** the `.config` file

Typically, you would use `make properclean` to remove all build artifacts, but keep the configuration file.

### QEMU x86_64

Building for QEMU x86_64 assumes you did the QEMU x86_64 configuration step above.
Build the Unikraft SQLite image for QEMU AArch64 by using the command below:

```console
$ make -j $(nproc)
[...]
  LD      sqlite_qemu-x86_64.dbg
  UKBI    sqlite_qemu-x86_64.dbg.bootinfo
  SCSTRIP sqlite_qemu-x86_64
  GZ      sqlite_qemu-x86_64.gz
make[1]: Leaving directory '/media/stefan/projects/unikraft/scripts/workdir/apps/app-sqlite/.unikraft/unikraft'
```

At the end of the build command, the `sqlite_qemu-x86_64` unikernel image is generated.
This image is to be used in the run step.

### QEMU AArch64

If you had configured and build a unikernel image for another platform or architecture (such as x86_64) before, then:

1. Do a cleanup step with `make properclean`.

1. Configure for QEMU AAarch64, as shown above.

1. Follow the instructions below to build for QEMU AArch64.

Building for QEMU AArch64 assumes you did the QEMU AArch64 configuration step above.
Build the Unikraft SQLite image for QEMU AArch64 by using the same command as for x86_64:

```console
$ make -j $(nproc)
[...]
  LD      sqlite_qemu-arm64.dbg
  UKBI    sqlite_qemu-arm64.dbg.bootinfo
  SCSTRIP sqlite_qemu-arm64
  GZ      sqlite_qemu-arm64.gz
make[1]: Leaving directory '/media/stefan/projects/unikraft/scripts/workdir/apps/app-sqlite/.unikraft/unikraft'
```

Similarly to x86_64, at the end of the build command, the `sqlite_qemu-arm64` unikernel image is generated.
This image is to be used in the run step.

## Run

Run the resulting image with the `run-...` scripts.

### QEMU x86_64

To run the QEMU x86_64 build, use `run-qemu-x86_64.sh`:

```console
$ ./run-qemu-x86_64.sh
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                  Atlas 0.13.1~5eb820bd
-- warning: cannot find home directory; cannot read ~/.sqliterc
SQLite version 3.40.1 2022-12-28 14:03:47
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite> .read script.sql
sqlite> .tables
tab
sqlite> select * from tab limit 3;
-1139020158890658636|4718309076706745182
4887119458146880213|395221908832267037
1007878203902392922|-8310175827322649876
sqlite> .open chinook.db
sqlite> .tables
Album          Employee       InvoiceLine    PlaylistTrack
Artist         Genre          MediaType      Track  
Customer       Invoice        Playlist       tab    
sqlite> select * from Album limit 3;
1|For Those About To Rock We Salute You|1
2|Balls to the Wall|2
3|Restless and Wild|2
sqlite> .exit
```

To close the QEMU Python3 application, use the `.exit` command or the `Ctrl+a x` keyboard shortcut;
that is press the `Ctrl` and `a` keys at the same time and then, separately, press the `x` key.

### QEMU AArch64

To run the AArch64 build, use `run-qemu-aarch64.sh`.
You can ignore the errors that appear at top.

```console
$ ./run-qemu-aarch64.sh
[    0.014856] ERR:  [libkvmvirtio] <virtio_bus.c @  140> Failed to find the driver for the virtio device 0x40338020 (id:1)
[    0.015369] ERR:  [libkvmvirtio] <virtio_pci.c @  425> Failed to register the virtio device: -14
[    0.015550] ERR:  [libkvmpci] <pci_bus_arm64.c @  100> PCI 00:01.00: Failed to initialize device driver
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                  Atlas 0.13.1~5eb820bd
-- warning: cannot find home directory; cannot read ~/.sqliterc
SQLite version 3.40.1 2022-12-28 14:03:47
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite> .read script.sql
sqlite> .tables
tab
sqlite> select * from tab limit 3;
-1139020158890658636|4718309076706745182
4887119458146880213|395221908832267037
1007878203902392922|-8310175827322649876
sqlite> .open chinook.db
sqlite> .tables
Album          Employee       InvoiceLine    PlaylistTrack
Artist         Genre          MediaType      Track  
Customer       Invoice        Playlist       tab    
sqlite> select * from Album limit 3;
1|For Those About To Rock We Salute You|1
2|Balls to the Wall|2
3|Restless and Wild|2
sqlite> .exit
```

Similarly, to close the QEMU SQLite server, use the `Ctrl+a x` keyboard shortcut.
