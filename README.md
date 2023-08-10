# SQLite on Unikraft

This application starts an SQLite web server with Unikraft.
Follow the instructions below to set up, configure, build and run SQLite.

To get started immediately, you can use Unikraft's companion command-line companion tool, [`kraft`](https://github.com/unikraft/kraftkit).
Start by running the interactive installer:

```console
curl --proto '=https' --tlsv1.2 -sSf https://get.kraftkit.sh | sudo sh
```

Once installed, clone [this repository](https://github.com/unikraft/app-sqlite) and run `kraft build`:

```console
git clone https://github.com/unikraft/app-sqlite sqlite
cd sqlite/
kraft build
```

This will guide you through an interactive build process where you can select one of the available targets (architecture/platform combinations).
You will get a list of options out of which to select one:

```text
[?] select target:
  ▸ sqlite-fc-aarch64-initrd (fc/arm64)
    sqlite-fc-x86_64-initrd (fc/x86_64)
    sqlite-qemu-aarch64-9pfs (qemu/arm64)
    sqlite-qemu-aarch64-initrd (qemu/arm64)
    sqlite-qemu-x86_64-9pfs (qemu/x86_64)
    sqlite-qemu-x86_64-initrd (qemu/x86_64)
```

Otherwise, we recommend building for `qemu/x86_64` with an `initrd` support filesystem like so:

```console
kraft build --target sqlite-qemu-x86_64-initrd -j $(nproc)
```

Once built, you can instantiate the unikernel via:

```console
kraft run --initrd fs0/
```

## Work with the Basic Build & Run Toolchain (Advanced)

You can set up, configure, build and run the application from grounds up, without using the companion tool `kraft`.

### Quick Setup (aka TLDR)

For a quick setup, run the commands below.
Note that you still need to install the [requirements](#requirements).

For building and running everything for `x86_64`, follow the steps below:

```console
git clone https://github.com/unikraft/app-sqlite sqlite
cd sqlite/
mkdir .unikraft
git clone https://github.com/unikraft/unikraft .unikraft/unikraft
git clone https://github.com/unikraft/lib-sqlite .unikraft/libs/sqlite
git clone https://github.com/unikraft/lib-musl .unikraft/libs/musl
UK_DEFCONFIG=$(pwd)/.config.sqlite-qemu-x86_64-9pfs make defconfig
make -j $(nproc)
qemu-system-x86_64 \
    -fsdev local,id=myid,path="$(pwd)/fs0",security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
    -kernel build/sqlite_qemu-x86_64 -nographic
```

This will configure, build and run the `sqlite` application.
You can see how to test it in the [running section](#run).

The same can be done for `AArch64`, by running the commands below:

```console
make properclean
UK_DEFCONFIG=$(pwd)/.config.sqlite-qemu-aarch64-9pfs make defconfig
make -j $(nproc)
qemu-system-aarch64 \
    -fsdev local,id=myid,path="$(pwd)/fs0",security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
    -kernel build/sqlite_qemu-arm64 -nographic \
    -machine virt -cpu cortex-a57
```

Similar to the `x86_64` build, this will start the `sqlite` server.
Information about every step is detailed below.

### Requirements

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
sudo apt install -y --no-install-recommends \
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

### Set Up

The following repositories are required for SQLite:

* The application repository (this repository): [`app-sqlite`](https://github.com/unikraft/app-sqlite)
* The Unikraft core repository: [`unikraft`](https://github.com/unikraft/unikraft)
* Library repositories:
  * The SQLite "library" repository: [`lib-sqlite`](https://github.com/unikraft/lib-sqlite)
  * The standard C library: [`lib-musl`](https://github.com/unikraft/lib-musl)

Follow the steps below for the setup:

  1. First clone the [`app-sqlite` repository](https://github.com/unikraft/app-sqlite) in the `sqlite/` directory:

     ```console
     git clone https://github.com/unikraft/app-sqlite sqlite
     ```

     Enter the `sqlite/` directory:

     ```console
     cd sqlite/

     ls -F
     ```

     This will list the contents of the repository:

     ```text
     .config.sqlite-qemu-aarch64-9pfs  .config.sqlite-qemu-x86_64-9pfs [...] fs0/  kraft.yaml  Makefile  Makefile.uk  README.md  [...]
     ```

  1. While inside the `sqlite/` directory, create the `.unikraft/` directory:

     ```console
     mkdir .unikraft
     ```

     Enter the `.unikraft/` directory:

     ```console
     cd .unikraft/
     ```

  1. While inside the `.unikraft` directory, clone the [`unikraft` repository](https://github.com/unikraft/unikraft):

     ```console
     git clone https://github.com/unikraft/unikraft unikraft
     ```

  1. While inside the `.unikraft/` directory, create the `libs/` directory:

     ```console
     mkdir libs
     ```

  1. While inside the `.unikraft/` directory, clone the library repositories in the `libs/` directory:

     ```console
     git clone https://github.com/unikraft/lib-sqlite libs/sqlite

     git clone https://github.com/unikraft/lib-musl libs/musl
     ```

  1. Get back to the application directory:

     ```console
     cd ../
     ```

     Use the `tree` command to inspect the contents of the `.unikraft/` directory.
     It should print something like this:

     ```console
     tree -F -L 2 .unikraft/
     ```

     The layout of the `.unikraft/` repository should look something like this:

     ```text
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

### Configure

Configuring, building and running a Unikraft application depends on our choice of platform and architecture.
Currently, supported platforms are QEMU (KVM), Xen and linuxu.
QEMU (KVM) is known to be working, so we focus on that.

Supported architectures are x86_64 and AArch64.

Use the corresponding the configuration files (`config-...`), according to your choice of platform and architecture.

#### QEMU x86_64

Use the `.config.sqlite-qemu-x86_64-9pfs` configuration file together with `make defconfig` to create the configuration file:

```console
UK_DEFCONFIG=$(pwd)/.config.sqlite-qemu-x86_64-9pfs make defconfig
```

This results in the creation of the `.config` file:

```console
ls .config
.config
```

The `.config` file will be used in the build step.

#### QEMU AArch64

Use the `.config.sqlite-qemu-aarch64-9pfs` configuration file together with `make defconfig` to create the configuration file:

```console
UK_DEFCONFIG=$(pwd)/.config.sqlite-qemu-aarch64-9pfs make defconfig
```

Similar to the x86_64 configuration, this results in the creation of the `.config` file that will be used in the build step.

### Build

Building uses as input the `.config` file from above, and results in a unikernel image as output.
The unikernel output image, together with intermediary build files, are stored in the `build/` directory.

#### Clean Up

Before starting a build on a different platform or architecture, you must clean up the build output.
This may also be required in case of a new configuration.

Cleaning up is done with 3 possible commands:

* `make clean`: cleans all actual build output files (binary files, including the unikernel image)
* `make properclean`: removes the entire `build/` directory
* `make distclean`: removes the entire `build/` directory **and** the `.config` file

Typically, you would use `make properclean` to remove all build artifacts, but keep the configuration file.

#### QEMU x86_64

Building for QEMU x86_64 assumes you did the QEMU x86_64 configuration step above.
Build the Unikraft SQLite image for QEMU AArch64 by using the command below:

```console
make -j $(nproc)
```

This will print the list of files that are generated by the build system.

```text
[...]
  LD      sqlite_qemu-x86_64.dbg
  UKBI    sqlite_qemu-x86_64.dbg.bootinfo
  SCSTRIP sqlite_qemu-x86_64
  GZ      sqlite_qemu-x86_64.gz
make[1]: Leaving directory '/media/stefan/projects/unikraft/scripts/workdir/apps/app-sqlite/.unikraft/unikraft'
```

At the end of the build command, the `sqlite_qemu-x86_64` unikernel image is generated.
This image is to be used in the run step.

#### QEMU AArch64

If you had configured and build a unikernel image for another platform or architecture (such as x86_64) before, then:

1. Do a cleanup step with `make properclean`.

1. Configure for QEMU AAarch64, as shown above.

1. Follow the instructions below to build for QEMU AArch64.

Building for QEMU AArch64 assumes you did the QEMU AArch64 configuration step above.
Build the Unikraft SQLite image for QEMU AArch64 by using the same command as for x86_64:

```console
make -j $(nproc)
```

Similar to the x86_64 build, this will print the list of files that are generated by the build system.

```text
[...]
  LD      sqlite_qemu-arm64.dbg
  UKBI    sqlite_qemu-arm64.dbg.bootinfo
  SCSTRIP sqlite_qemu-arm64
  GZ      sqlite_qemu-arm64.gz
make[1]: Leaving directory '/media/stefan/projects/unikraft/scripts/workdir/apps/app-sqlite/.unikraft/unikraft'
```

Similarly to x86_64, at the end of the build command, the `sqlite_qemu-arm64` unikernel image is generated.
This image is to be used in the run step.

### Run

Run the resulting image using `qemu-system`.

#### QEMU x86_64

To run the QEMU x86_64 build, use `qemu-system-x86_64`:

```console
qemu-system-x86_64 \
    -fsdev local,id=myid,path=$(pwd)/fs0,security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
    -kernel build/sqlite_qemu-x86_64 -nographic
```

This will start the SQLite application:

```text
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

#### QEMU AArch64

To run the AArch64 build, use `qemu-system-aarch64`:

```console
qemu-system-aarch64 \
    -fsdev local,id=myid,path=$(pwd)/fs0,security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
    -kernel build/sqlite_qemu-arm64 -nographic \
    -machine virt -cpu max
```

This will start the SQLite application.
You can ignore the errors that appear at top:

```text
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

### Building and Running with initrd

The examples above use 9pfs as the filesystem interface.
In order two use initrd, you need to first create a CPIO archive that will be passed as the initial ramdisk:

```console
cd fs0 && find -depth -print | tac | bsdcpio -o --format newc > ../fs0.cpio && cd ..
```

Clean up previous configuration, use the initrd configuration and build the unikernel by using the commands:

```console
make distclean
UK_DEFCONFIG=$(pwd)/.config.sqlite-qemu-x86_64-initrd make defconfig
make -j $(nproc)
```

Then, run the resulting image with:

```console
qemu-system-x86_64 -kernel build/sqlite_qemu-x86_64 -nographic -initrd fs0.cpio
```

The commands for AArch64 are similar:

```console
make distclean
UK_DEFCONFIG=$(pwd)/.config.sqlite-qemu-aarch64-initrd make defconfig
make -j $(nproc)
qemu-system-aarch64 -kernel build/sqlite_qemu-arm64 -nographic -initrd fs0.cpio -append -machine virt -cpu max
```

### Building and Running with Firecracker

[Firecracker](https://firecracker-microvm.github.io/) is a lightweight VMM (*virtual machine manager*) that can be used as more efficient alternative to QEMU.

Configure and build commands are similar to a QEMU-based build with an initrd-based filesystem:

```console
make distclean
UK_DEFCONFIG=$(pwd)/.config.sqlite-fc-x86_64-initrd make defconfig
make -j $(nproc)
```

For running, a CPIO archive of the filesystem is required to be passed as the initial ramdisk:

```console
cd fs0 && find -depth -print | tac | bsdcpio -o --format newc > ../fs0.cpio && cd ..
```

To use Firecraker, you need to download a [Firecracker release](https://github.com/firecracker-microvm/firecracker/releases).
You can use the commands below to make the `firecracker-x86_64` executable from release v1.4.0 available globally in the command line:

```console
cd /tmp 
wget https://github.com/firecracker-microvm/firecracker/releases/download/v1.4.0/firecracker-v1.4.0-x86_64.tgz
tar xzf firecracker-v1.4.0-x86_64.tgz 
sudo cp release-v1.4.0-x86_64/firecracker-v1.4.0-x86_64 /usr/local/bin/firecracker-x86_64
```

To run a unikernel image, you need to configure a JSON file.
This is the `sqlite-fc-x86_64-initrd.json` file.
Pass this file to the `firecracker-x86_64` command to run the Unikernel instance:

```console
rm /tmp/firecracker.socket
firecracker-x86_64 --api-sock /tmp/firecracker.socket --config-file sqlite-fc-x86_64-initrd.json
```

Same as running with QEMU, the application will start:

```text
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                  Atlas 0.13.1~f7511c8b
sqlite> .exit
```
