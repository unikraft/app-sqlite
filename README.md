# SQLite on Unikraft

This application starts a SQLite database.

To configure, build and run the application you need to have [kraft](https://github.com/unikraft/kraft) installed.

To be able to interact with the database, configure the application to run on the KVM platform:
```
$ kraft configure -p kvm -m x86_64
```

Build the application:
```
$ kraft build
```

And, finally, run the application:
```
$ kraft run
SQLite version 3.30.1 2019-10-10 20:19:45
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite>
```

If you want to have more control you can also configure, build and run the application manually.

To configure it for the KVM platform:
```
$ make menuconfig
```

Build the application:
```
$ make
```

Run the application:
```
sudo qemu-system-x86_64 -fsdev local,id=myid,path=$(pwd)/fs0,security_model=none \
                        -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
                        -kernel "build/app-sqlite_qemu-x86_64" \
                        -enable-kvm \
                        -nographic
```


For more information about `kraft` type ```kraft -h``` or read the
[documentation](http://docs.unikraft.org).
