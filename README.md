# Packer for Sitecore

**Contents** [Overview] | [Getting started] | [Usage] | [Next steps] | [Contributing] | [Resources]  

This repository contains Packer templates for a local Sitecore hosting environment with IIS and and SQL Server on Windows, SOLR and Sitecore 9.0 building virtual machine images and Vagrant boxes for VirtualBox, provisioned with Chef.

## Overview

**Contents**

**Note** This section covers the details of the published [Vagrant boxes] this repository builds. See the [Getting started] section to build your own virtual machine images and Vagrant boxes.  

This repository contains [Packer] templates for the following scenarios:

- [Sitecore 9.0 hosting] using IIS, SQL Server 2016 and SOLR.

The virtual machine images and [Vagrant] boxes are built for [VirtualBox] and are provisioned using [Chef].

Most of the components, including the core operating systems, share the following characteristics:

* They are based on their publicly available versions. You might need to provide your own license(s) (for example, a valid Windows or Visual Studio license) to start or keep using them after their evaluation periods expire.
* They are installed using their latest available versions. The latest patches (for example, all the Windows Updates) are applied as well.
* Unless noted otherwise, they are installed using the default configuration options.

**IMPORTANT! Required licenses and distributions (not included)**
- Put **license.xml** file to **/src/components/sitecore/chef/cookbooks/gusztavvargadr_sitecore/files/license.xml**
- Put **dev.sitecore.net** credentials into **src/components/sitecore/chef/cookbooks/gusztavvargadr_sitecore/attributes/secret.rb**. You can find sample next to this file.
- Put a link to **SQL Server 2016 Dev SP1** into **src/components/sql/chef/cookbooks/gusztavvargadr_sql/attributes/2016_developer.rb**
---

[Overview]: #overview

[Packer]: https://www.packer.io/
[Vagrant]: https://www.vagrantup.com/
[VirtualBox]: https://www.virtualbox.org/
[Chef]: https://chef.io/chef/

### Operating systems

The following Vagrant boxes can be used for generic experiments on the respective platforms.

They contain the core operating system with the minimum configuration required to make Vagrant work, and some of the commonly used tools installed and options configured for easier provisioning. All the other Vagrant boxes below are based on these configurations as well.

- **Windows Server 2016**

In the box:

- **Windows Server 2016 Standard** 1607 (14393.1770)
  - Operating system
    - Administrator user with user name `vagrant` and password `vagrant` set to never expire
    - WinRM service enabled
    - UAC disabled
    - Windows Updates installed and service disabled
    - Windows Defender service disabled
    - Remote Desktop enabled
    - Generalized with Sysprep
  - Tools
    - [Chocolatey](https://chocolatey.org/packages/chocolatey/) 0.10.8
    - [7-Zip](https://chocolatey.org/packages/7zip/) 16.4.0
    - [Chef Client](https://chocolatey.org/packages/chef-client/) 13.4.24
    - **VirtualBox** [VirtualBox Guest Additions](https://www.virtualbox.org/manual/ch04.html) 5.2.4
      - Recommended to have VirtualBox version 5.2.4 or later on the host
  - Vagrant box
    - WinRM communicator
    - 2 CPU
    - 4 GB RAM
    - **VirtualBox** Port forwarding for RDP from 3389 to 33389 with auto correction

### Sitecore hosting

The following Vagrant boxes can be used for Sitecore 9.0 hosting scenarios.

They contain the respective hosting tools with the default configuration are based on the core [operating systems].

- **IIS 10**
  - **[Server][w16s-iis]** with Windows Server 2016 Standard
- **SQL Server 2016 SP1**
  - **[Developer][w16s-scsql16d]** with Windows Server 2016 Standard
- **SOLR 6.6.2**
  - **[Developer][w16s-scsolr]** with Solr 6.6.2
- **SOLR 6.6.2**
  - **[Developer][w16s-scsolr]** with Solr 6.6.2
- **Sitecore 9.0 Initial release**
  - **[Developer][w16s-sc90]** with Sitecore 9.0 installed via SIF

## Getting started

**Note** The rest of this document covers the details of building virtual machine images and Vagrant boxes, and assumes that you are familiar with the basics of [Packer]. If that's not the case, it's recommended that you take a quick look at its [getting started guide][PackerGettingStarted].  

**Note** Building the Packer templates have been tested on Windows hosts only, but they are supposed to run on any other platform as well, given that the actual virtualization provider (e.g. VirtualBox) supports it. [Let me know][Contributing] if you encounter any issues and I'm glad to help.  

Follow the steps below to install the required tools:

1. Install [Packer][PackerInstallation].
1. Install the [Chef Development Kit][ChefDKInstallation].
1. Install the tools for the virtualization provider you want to use.
    - **VirtualBox** Install [VirtualBox][VirtualBoxInstallation].

You are now ready to build a virtual machine image and a Vagrant box.

**Note** It is recommended to set up [caching for Packer][PackerCaching], so you can reuse the downloaded resources (e.g. OS ISOs) across different builds. Make sure you have a bunch of free disk space for the cache and the build artifacts.  

[Getting started]: #getting-started

[PackerGettingStarted]: https://www.packer.io/intro/getting-started/install.html
[PackerInstallation]: https://www.packer.io/docs/install/index.html
[ChefDKInstallation]: https://downloads.chef.io/chefdk/
[VirtualBoxInstallation]: https://www.virtualbox.org/wiki/Downloads/
[PackerCaching]: https://www.packer.io/docs/other/environment-variables.html#packer_cache_dir

## Usage

**Contents** [Building base images] | [Building images for distribution] | [Chaining builds further] | [Testing] | [Cleaning up]

This repository uses some [custom wrapper scripts][SourceCoreCake] using [Cake] to generate the Packer templates and the related resources (e.g. the unattended install configuration) required to build the virtual machine images. Besides supporting easier automation, this approach helps with reusing parts of the templates and the
related resources, and makes chaining builds and creating new configurations quite easy.

[Usage]: #usage

[SourceCoreCake]: src/core/cake/
[Cake]: http://cakebuild.net/

### Building base images

```powershell
$ .\ci.ps1 [info]
```

The output will be contain the section `packer-info` with the list of the templates:

```
...
========================================
packer-info
========================================
Executing task: packer-info
w16s-virtualbox-core: Info
w16s-dotnet-virtualbox-core: Info
w16s-iis-virtualbox-core: Info
w16s-scsql16d-virtualbox-core: Info
w16s-scsolr-virtualbox-core: Info
w16s-sc90-virtualbox-core: Info
...
```

You can filter this further to list only the templates for a given virtual machine image type. For example, to list the templates based on the `Windows Server 2016 Standard` image, invoke the `info` command with the `w16s` argument:

```powershell
$ .\ci.ps1 info w16s
```

**Note** You can use this filtering with all the `ci.ps1` commands below as well. It selects all the templates which contain the specified argument as a substring, so you can filter for components (`w16s`, `iis`, etc.) or providers (`virtualbox`) easily.  

The output will contain only the matching templates:

```
...
========================================
packer-info
========================================
Executing task: packer-info
w16s-scsolr-virtualbox-core: Info
...
```

This means that this configuration supports building some base images (`virtualbox-core`) mainly for reusing them in other configurations, and also boxes for distribution (`virtualbox-sysprep`). Under the hood, the `sysprep` configurations will simply start from the output of the `core` ones, so build times can be reduced significantly.

Now, invoke the `restore` command with the name of the template you want to build to create the resources required by Packer. For example, for VirtualBox, type the following command:

```powershell
$ .\ci.ps1 restore w16s-virtualbox-core
``` 

This will create the folder `build/w16s/virtualbox-core` in the root of your clone with all the files required to invoke the Packer build. This setup is self-contained, so you can adjust the parameters manually in `template.json` or the other resources and / or even copy it to a different machine and simply invoke `packer build template.json` there. Most of the time though, you just simply want to build as it is, as the templates are already preconfigured with some reasonable defaults. This can be done of course with the build script as well:

```powershell
$ .\ci.ps1 build w16s-virtualbox-core
```

This will trigger the Packer build process, which usually requires only patience. Depending on the selected configuration, a few minutes or hours later, the build output will be created, in this case in the `build/w16s/virtualbox-core/output` directory in the root of your clone. Virtual machine images like this can be directly used with the respective virtualization provider or Vagrant on the host machine.

[Building base images]: #building-base-images

### Building images for distribution

As mentioned above, based on Packer's support for starting builds from some virtualization providers' native image format, builds can reuse the output of a previous build. To build and image which can be distributed (e.g. after applying [Sysprep] as well), type the following command:

```powershell
$ .\ci.ps1 build w16s-virtualbox-sysprep
```

Note that this will include restoring the build folder with the template and the related resources automatically, and then invoking the build process in a single step. It will also reuse the output of the `w16s-virtualbox-core` build, so it does not need to do the same steps for a Vagrant box the original build already included (e.g. the core OS installation itself, installing Windows updates, etc.). Once the build completes, the native image and the Vagrant box will be available in the `build/w16s/virtualbox-sysprep/output` folder.

[Building images for distribution]: #building-images-for-distribution

[Sysprep]: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation
[VagrantDistribute]: https://www.vagrantup.com/docs/boxes/base.html#distributing-the-box

### Chaining builds further

Similarly to the process above, you can use build chaining to build more complex boxes. For example, the configuration for `Windows Server 2016 Standard` with `IIS` can be built like this:

```powershell
$ .\ci.ps1 build w16s-virtualbox-core
$ .\ci.ps1 build w16s-iis-virtualbox-core
$ .\ci.ps1 build w16s-iis-virtualbox-sysprep
```

As in the previous `w16s` sample, for this configuration the `w16s-iis-virtualbox-core` build will start from the output of `w16s-virtualbox-core` instead of starting with the core OS installation. Chanining builds like this has no limitations, so you can use this approach to build images with any number of components very effectively.

Note that the script can invoke the build of the dependencies automatically, so for the previous example you can simply type:

```powershell
$ .\ci.ps1 build w16s-iis-virtualbox-sysprep --recursive=true
```

This will in turn invoke the `restore` and `build` stages for the `w16s-virtualbox-core` and `w16s-iis-virtualbox-core` images as well. By default, `restore` and `build` is skipped if the output from a previous build exists. You can force the build to run again using the `rebuild` command instead, which will `clean` the build directories first.

[Chaining builds further]: #chaining-builds-further

### Testing

To help testing the build results, the reposiory contains a simple [Vagrantfile] to create virtual machines using directly the build outputs.

For example, to test the `core` `w16s` configurations, from the root of your clone you can type the following command to use the box files in the `build\w16s` folder:

```powershell
$ vagrant up w16s-core
```

This will import the locally built Vagrant box with the name `local/w16s-core` and will use that to spin up a new virtual machine for testing.

Similarly, you can test the `sysprep` ones as well before publishing:

```powershell
$ vagrant up w16s-sysprep
```

When working with multiple virtualization providers, you can specify which one to use for each test machine [using the command line][VagrantCLIUpProvider], or [define your preferences globally][VagrantPreferredProviders].

You can use the standard Vagrant commands to [clean up the boxes][VagrantCLIBox] after testing.

[Testing]: #testing

[Vagrantfile]: Vagrantfile
[VagrantCLIUpProvider]: https://www.vagrantup.com/docs/cli/up.html#provider-x
[VagrantPreferredProviders]: https://www.vagrantup.com/docs/other/environmental-variables.html#vagrant_preferred_providers
[VagrantCLIBox]: https://www.vagrantup.com/docs/cli/box.html

### Cleaning up

Though the `build` folders are excluded by default from the repository, they can consume significant disk space. You can manually delete the folders, but the build script provides support for this as well:

```
$ .\ci.ps1 clean w16s-iis-virtualbox-sysprep
```

Using the filtering, to clean up the artifacts of all the VirtualBox builds, you can type:

```powershell
$ .\ci.ps1 clean virtualbox
```

Omitting this parameter will apply the command to all the templates, so the following command will clean up everything:

```powershell
$ .\ci.ps1 clean
```

**Note** The `clean` command removes only the Packer build templates and artifacts, the eventually imported Vagrant boxes and virtual machines need to be removed manually.  

[Cleaning up]: #cleaning-up

## Next steps

Take a look at the repository of [virtual workstations] to easily automate and share your development environment configurations using the Vagrant boxes above.

[Next steps]: #next-steps

## Contributing

<!--
**Note** This section assumes you are familiar with the basics of [Chef]. If that's not the case, it's recommended that you take a quick look at its [getting started guide][ChefGettingStarted].

TODO: custom template and build
-->

Any feedback, [issues] or [pull requests] are welcome and greatly appreciated. Chek out the [milestones] for the list of planned releases.

[Contributing]: #contributing

[Issues]: https://github.com/asmagin/packer/issues/
[Pull requests]: https://github.com/asmagin/packer/pulls/
[Milestones]: https://github.com/asmagin/packer/milestones/ 

## Resources

This repository could not exist without the following great tools:

* [Packer]
* [Vagrant]
* [VirtualBox]
* [Chef]

This repository borrows awesome ideas and solutions from the following sources:

* [Gusztav Vargadr]
* [Matt Wrock]
* [Jacqueline]
* [Joe Fitzgerald]
* [Boxcutter]

[Resources]: #resources

[Gusztav Vargadr]: https://github.com/gusztavvargadr/packer/
[Matt Wrock]: https://github.com/mwrock/packer-templates/
[Jacqueline]: https://github.com/jacqinthebox/packer-templates/
[Joe Fitzgerald]: https://github.com/joefitzgerald/packer-windows/
[Boxcutter]: https://github.com/boxcutter/windows/
