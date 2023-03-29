# docker-host

Install the Docker engine.

For information about PTA and how to use it with this Ansible role please visit https://github.com/Forcepoint/fp-pta-overview/blob/master/README.md

It is assumed that the drives are already properly allocated for docker needs.
If this needs addressing, it should be done with Packer/Terraform, not Ansible.

## Requirements

None

## Role Variables

### REQUIRED

As of this writing (2020-01-29), this role does not apply with the gnome role as
you'll get a conflict with urllib3 being applied by pip and by yum.

### OPTIONAL

* docker_host_data_root: The default path to place docker related files, like pulled containers.
  Defaults to the directory as recommended by docker documentation.
* docker_host_ce_repo: The yum repository to download the docker installer from. 
  Defaults to the publicly available, docker hosted repo.
* docker_host_ce_repo_gpgkey: The GPG key to verify the downloads from the yum repository. 
  Defaults to the key for the publicly available, docker hosted repo.
* docker_host_registry_mirror: A registry mirror cache to use instead of the publicly available docker hub.
  If not present, uses the normal method. https://docs.docker.com/registry/recipes/mirror/
  https://www.jfrog.com/confluence/display/RTF/Docker+Registry
* docker_host_default_address_pools: Docker will create a subnet for networks docker creates, like during
  a docker compose. By default, this is 172.N.0.0/16. If your company's network uses 172 subnets, 
  you should change this default.
* docker_host_insecure_registry: An insecure registry to add to the docker daemon.
* docker_host_storage_opts: Storage options for the docker daemon. See https://docs.docker.com/engine/reference/commandline/dockerd/#options-per-storage-driver

## Dependencies

None

## Example Playbook

    - hosts: servers
      vars:
        docker_host_data_root: /mnt/secondary/extra/storage
        docker_host_ce_repo: https://artifactory.COMPANY.com/artifactory/download.docker.com/linux/centos/7/$basearch/stable
        docker_host_ce_repo_gpgkey: https://artifactory.COMPANY.com/artifactory/download.docker.com/linux/centos/gpg
        docker_host_registry_mirror: https://registry-1-docker-io.artifactory.COMPANY.com
        docker_host_default_address_pools: "[ {\"base\":\"182.0.0.0/16\",\"size\": 24} ]"
        docker_host_insecure_registry: https://nexus.COMPANY.com:5000
        docker_host_storage_opts: \"dm.basesize=20G\"
      roles:
         - role: docker-host

## License

BSD-3-Clause

## Author Information

Jeremy Cornett <jeremy.cornett@forcepoint.com>
