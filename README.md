## Gymhaan – TerminalServ Bootstrap

Use TS Bootstrap to set up your *Ubuntu 13.04* Terminal Server blazing fast.
Easy to use and super fast setup are our aims.

## Install

Clone this Repo to your desired *Ubuntu 13.04* machine, then let's go.

```sh
git clone https://github.com/gymbuntu/ts-bootstrap ~/ts-bootstrap
```

## Configuration

### LDAP Authentication – ldap-auth.conf

Edit the `ldap-auth.conf` file which defines all your ldap settings. These settings should match the settings you've made in the `slapd.conf` file of course. If you have installed the ldap server on another machine, be shure to edit the `LDAP_SERVER` var to match the machine's host name or ip address.

### LTSP Server configuration

The following files define the settings for the ltsp server you'll setup.

### LTSP Image Build – ltsp-build-server.conf

This file stores all configuration which is used to build your ltsp image. It will be copied to `/etc/ltsp/ltsp-build-client.conf`

### LTSP Image Update – ltsp-update-image.conf

This file defines all settings that will be used to update your ltsp image. It will be copied to `/etc/lstp/ltsp-update-image.conf`

## Usage

### LDAP Authentication

To make your server use ldap for user authentication you'll only need to do two steps.

At first run our script. This will setup ldap auth and install all required packages.

```sh
./ldap-auth.sh install
```

Then, you'll need to edit the `/etc/pam.d/common-session` file.

You'll have to place the following line before any pam_ldap and pam_krb5 settings

```sh
session required        pam_mkhomedir.so umask=0077 skel=/etc/skel
```

(We use `umask=0077` because it's loads more safe.)

Now ldap authentication should work. Try it using some creditials you created on your ldap server.

### LTSP Server

To get your ltsp server running super fast, we created `ltsp-server.sh`

Install the ltsp server on your machine using

```sh
./ltsp-server.sh install
```

#### Install the configuration files

To use the configuration files for building and updating the ltsp image, run the following command to install the configuration files.

```sh
./ltsp-server.sh configure
```

### LTSP Image Building

To build a new ltsp image you use one of the following commands.

You can either use the default command

```sh
sudo ltsp-build-client
```

Or you can use our build in script

```sh
./ltsp-server.sh build-client
```

### LTSP Image Updating

To update an existing ltsp image you also can use one of the following commands.

Use the default command

```sh
sudo ltsp-update-image
```

Or you can use our build in script

```sh
./ltsp-server.sh update-image
```

Please note that our build in scripts are only rudimentary and may __not__ work.

## Thanks

Thanks to Roland Stiebel with whom I did this whole project. We hope this whole thing will help some people getting their ldap server up and running without struggling too much with all the f***ed up console shit.

A project by @fharbe